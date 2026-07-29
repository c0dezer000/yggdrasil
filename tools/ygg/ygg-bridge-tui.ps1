# ygg-bridge-tui.ps1 - interactive bridge to a running opencode server
<#
.SYNOPSIS
  Delivers a remote prompt into the VISIBLE opencode TUI, as though it were typed there.
.DESCRIPTION
  Dot-sourced by ygg-daemon.ps1. Provides the "Option E" execution path:

      Telegram -> daemon -> opencode server (HTTP) -> the TUI you are looking at

  The previous path shelled out to `opencode run`, which starts a NEW headless process and a
  NEW session every time. Nothing it did was ever visible in the terminal, and no two remote
  messages shared a conversation. This module instead talks to a running `opencode serve`
  process over HTTP and drives the attached TUI directly:

      POST /tui/append-prompt   {text}   -- text appears in the TUI prompt box
      POST /tui/submit-prompt            -- submits it, exactly as pressing Enter would
      GET  /session/{id}/message         -- read the assistant's reply back out

  Requirement: the gardener runs the server and attaches a TUI to it:

      opencode serve --port 4096                  (terminal 1, or `ygg serve`)
      opencode attach http://127.0.0.1:4096       (terminal 2 - the visible session)

  If the server is not reachable this module reports failure and the daemon falls back to the
  existing headless path, so the channel degrades rather than breaking.

  ---------------------------------------------------------------------------------------
  READ THIS BEFORE ENABLING [governance]
  ---------------------------------------------------------------------------------------
  The headless path pins every remote invocation to an explicit read-only agent
  (`--agent ratatoskr`), and fails closed if that flag does not bind [E75]. That control
  exists so remote text can never reach an agent holding edit and bash.

  Submitting into the TUI CANNOT carry that guarantee. /tui/submit-prompt runs the prompt
  under whatever agent and model the TUI currently has selected - which may be odin, with
  full tools. Enabling this path trades the agent-pinning control for the interactive
  experience. That is a real reduction in containment, not a technicality.

  For that reason the bridge requires TWO independent opt-ins in .ygg-bridge.json:
  `enabled` and `agentPinningWaived`. One flag would let it be switched on without the
  trade being acknowledged.
#>

# =====================================================================
# CONFIG
# =====================================================================

function Get-BridgeConfig {
    <#
    .SYNOPSIS
      Reads .ygg-bridge.json from the project root. Returns a config object, disabled by
      default when the file is missing or malformed.
    #>
    param([string]$Root)

    $default = [pscustomobject]@{
        enabled             = $false
        url                 = 'http://127.0.0.1:4096'
        password            = $null
        username            = 'opencode'
        replyTimeoutSeconds = 300
        agentPinningWaived  = $false
        selectSession       = $false   # do not navigate the TUI; use the session on screen
    }

    $cfgPath = Join-Path -Path $Root -ChildPath ".ygg-bridge.json"
    if (-not (Test-Path -LiteralPath $cfgPath -PathType Leaf)) { return $default }

    try {
        $raw = Get-Content -LiteralPath $cfgPath -Raw -Encoding UTF8
        if ([string]::IsNullOrWhiteSpace($raw)) { return $default }
        $parsed = $raw | ConvertFrom-Json
    } catch {
        # A malformed config must not silently enable a path that waives a security control.
        Write-Host "  [WARN] .ygg-bridge.json is not valid JSON; interactive bridge stays disabled." -ForegroundColor DarkYellow
        return $default
    }

    foreach ($prop in @('enabled','url','password','username','replyTimeoutSeconds','agentPinningWaived','selectSession')) {
        if ($null -ne $parsed.PSObject.Properties[$prop]) {
            $default.$prop = $parsed.$prop
        }
    }
    return $default
}

function Test-BridgeEnabled {
    <#
    .SYNOPSIS
      True only when BOTH opt-ins are set. See the governance note at the top of this file.
    #>
    param($Config)
    if (-not $Config.enabled) { return $false }
    if (-not $Config.agentPinningWaived) {
        Write-Host "  [INFO] Interactive bridge is enabled but agentPinningWaived is false - staying on the headless path." -ForegroundColor DarkYellow
        return $false
    }
    return $true
}

# =====================================================================
# HTTP
# =====================================================================

function Get-BridgeHeaders {
    param($Config)
    $h = @{}
    if ($Config.password) {
        $pair  = "$($Config.username):$($Config.password)"
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
        $h['Authorization'] = 'Basic ' + [Convert]::ToBase64String($bytes)
    }
    return $h
}

function Invoke-BridgeApi {
    <#
    .SYNOPSIS
      One place for every server call, so timeouts and auth are consistent.
      Returns $null on failure rather than throwing - callers decide whether to fall back.
    #>
    param(
        $Config,
        [string]$Path,
        [string]$Method = 'Get',
        $Body = $null,
        [int]$TimeoutSec = 20
    )

    $uri = ($Config.url.TrimEnd('/')) + $Path
    $params = @{
        Uri             = $uri
        Method          = $Method
        TimeoutSec      = $TimeoutSec
        Headers         = (Get-BridgeHeaders -Config $Config)
        UseBasicParsing = $true
        ErrorAction     = 'Stop'
    }
    if ($null -ne $Body) {
        $params['Body']        = ([System.Text.Encoding]::UTF8.GetBytes(($Body | ConvertTo-Json -Depth 6 -Compress)))
        $params['ContentType'] = 'application/json; charset=utf-8'
    }

    try {
        # The response is read as RAW BYTES and decoded as UTF-8 explicitly, rather than letting
        # Invoke-RestMethod decode it.
        #
        # Windows PowerShell 5.1 decodes a JSON response body as Latin-1 when the server does not
        # spell out a charset, so every non-ASCII character arrives as its individual UTF-8 bytes
        # reinterpreted one-per-character. An em dash (U+2014, bytes E2 80 94) came back as
        # U+00E2 U+0080 U+0094 - "P3 - Always-on Presence" rendered as "P3 a<80><94> Always-on".
        # Verified against a real reply on this host. The daemon's mojibake repair map [E73]
        # covers a different CP437 mangling and does not catch this one, so every bridge reply
        # containing a dash or a curly quote would have reached the phone corrupted.
        $resp  = Invoke-WebRequest @params
        $bytes = $resp.RawContentStream.ToArray()
        if ($bytes.Length -eq 0) { return $null }
        $text  = [System.Text.Encoding]::UTF8.GetString($bytes)
        if ([string]::IsNullOrWhiteSpace($text)) { return $null }
        return ($text | ConvertFrom-Json)
    } catch {
        Write-Host "  [WARN] bridge $Method $Path failed: $($_.Exception.Message)" -ForegroundColor DarkYellow
        return $null
    }
}

function Invoke-BridgeAction {
    <#
    .SYNOPSIS
      POSTs to an endpoint whose success is the HTTP status, not the response body.
      Returns $true on 2xx, $false otherwise.
    .DESCRIPTION
      The /tui/* endpoints return little or nothing. Judging them by their body - as
      Invoke-BridgeApi does - would read an empty 200 as failure, and a false 'submit-failed'
      makes the daemon fall back to the headless path AFTER the prompt has already been
      submitted to the TUI. The instruction would then run twice, once in the terminal and once
      headless. For a write-capable agent that is the worst failure this bridge could have, so
      these calls are judged by status code instead.
    #>
    param($Config, [string]$Path, $Body = $null, [int]$TimeoutSec = 20)

    $uri = ($Config.url.TrimEnd('/')) + $Path
    $params = @{
        Uri             = $uri
        Method          = 'Post'
        TimeoutSec      = $TimeoutSec
        Headers         = (Get-BridgeHeaders -Config $Config)
        UseBasicParsing = $true
        ErrorAction     = 'Stop'
    }
    if ($null -ne $Body) {
        $params['Body']        = ($Body | ConvertTo-Json -Depth 6 -Compress)
        $params['ContentType'] = 'application/json'
    }

    try {
        $resp = Invoke-WebRequest @params
        return ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 300)
    } catch {
        Write-Host "  [WARN] bridge POST $Path failed: $($_.Exception.Message)" -ForegroundColor DarkYellow
        return $false
    }
}

function Test-BridgeServer {
    <#
    .SYNOPSIS
      Cheap reachability probe. GET /session/status is read-only and invokes no model.
    #>
    param($Config)
    $uri = ($Config.url.TrimEnd('/')) + '/session/status'
    try {
        $null = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 5 `
                    -Headers (Get-BridgeHeaders -Config $Config) -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# =====================================================================
# SESSION RESOLUTION
# =====================================================================

function Get-BridgeRememberedSessionId {
    <#
    .SYNOPSIS
      The session the last remote message landed in, or $null. Used only for diagnostics and
      for the opt-in selectSession behaviour - never to decide where a prompt goes.
    #>
    param([string]$Root)

    $stateFile = Join-Path -Path $Root -ChildPath "work\remote-session.json"
    if (-not (Test-Path -LiteralPath $stateFile -PathType Leaf)) { return $null }
    try {
        $st = Get-Content -LiteralPath $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($st.sessionID -match '^ses') { return $st.sessionID }
    } catch { }
    return $null
}

function Get-BridgeSessionSnapshot {
    <#
    .SYNOPSIS
      Map of sessionID -> last-updated timestamp, taken BEFORE submitting.
      Used to work out which session the TUI actually put the prompt in.
    #>
    param($Config)

    $snap = @{}
    $sessions = Invoke-BridgeApi -Config $Config -Path '/session' -Method Get -TimeoutSec 30
    if (-not $sessions) { return $snap }
    foreach ($s in @($sessions)) {
        if ($s.id -match '^ses') {
            $snap[$s.id] = [int64]($s.time.updated)
        }
    }
    return $snap
}

function Find-BridgeTargetSession {
    <#
    .SYNOPSIS
      Identifies which session received the prompt, by finding the session whose transcript now
      ends in a user message matching $Text. Returns @{ SessionId; MessageId } or $null.
    .DESCRIPTION
      This replaces choosing a session up front, which was the design error behind the first
      live test: /api/session/active returns an empty object even with a TUI attached, so the
      bridge fell through to POST /session and then /tui/select-session, creating a fresh
      session and navigating the gardener's terminal away from the conversation they were in.

      Nothing about DELIVERY ever needed a session id. /tui/append-prompt types into the TUI's
      prompt box and /tui/submit-prompt submits it to whatever session that TUI is already
      showing - which is exactly the desired behaviour. A session id is needed only to read the
      answer back, and that can be discovered after the fact.
    #>
    param($Config, $Snapshot, [string]$Text, [int]$TimeoutSeconds = 20)

    $wanted   = $Text.Trim()
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 2

        $sessions = Invoke-BridgeApi -Config $Config -Path '/session' -Method Get -TimeoutSec 30
        if (-not $sessions) { continue }

        # Only sessions that changed since the snapshot are candidates. A session absent from
        # the snapshot is new since we looked, so it counts too.
        $candidates = @($sessions) | Where-Object {
            $_.id -match '^ses' -and (
                -not $Snapshot.ContainsKey($_.id) -or
                [int64]($_.time.updated) -gt $Snapshot[$_.id]
            )
        } | Sort-Object -Property { $_.time.updated } -Descending

        foreach ($c in $candidates) {
            $msgs = Invoke-BridgeApi -Config $Config -Path "/session/$($c.id)/message" -Method Get -TimeoutSec 30
            if (-not $msgs) { continue }

            # Compare against the LAST user message in the transcript, with no fixed window.
            #
            # This originally scanned only the final four messages, which failed against real
            # data: by the time the poll runs, the agent has usually emitted several assistant
            # messages after the prompt (a five-message transcript had the user turn at index 0),
            # so the window slid straight past it. The prompt just submitted is by definition the
            # newest user turn, so find that and compare - no window, no guesswork.
            $all      = @($msgs)
            $lastUser = $null
            for ($i = $all.Count - 1; $i -ge 0; $i--) {
                if ($all[$i].info.role -eq 'user') { $lastUser = $all[$i]; break }
            }
            if ($null -eq $lastUser) { continue }

            $body = (@($lastUser.parts) |
                     Where-Object { $_.type -eq 'text' } |
                     ForEach-Object { $_.text }) -join "`n"
            if ($body.Trim() -eq $wanted) {
                return @{ SessionId = $c.id; MessageId = $lastUser.info.id }
            }
        }
    }

    return $null
}

function Save-BridgeSessionId {
    param([string]$Root, [string]$SessionId)
    $workDir = Join-Path -Path $Root -ChildPath "work"
    if (-not (Test-Path -LiteralPath $workDir -PathType Container)) {
        New-Item -ItemType Directory -Path $workDir -Force | Out-Null
    }
    $stateFile = Join-Path -Path $workDir -ChildPath "remote-session.json"
    $payload = @{ sessionID = $SessionId; updated = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') } |
               ConvertTo-Json -Compress
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($stateFile, $payload, $utf8NoBom)
}

# =====================================================================
# PROMPT DELIVERY + REPLY
# =====================================================================

function Get-BridgeLastMessageId {
    <#
    .SYNOPSIS
      Id of the newest message in the session, recorded BEFORE submitting so the reply can be
      identified as "an assistant message newer than this one". Without a baseline the poller
      would immediately match the previous turn's answer and return a stale reply.
    #>
    param($Config, [string]$SessionId)

    $msgs = Invoke-BridgeApi -Config $Config -Path "/session/$SessionId/message" -Method Get -TimeoutSec 30
    if (-not $msgs) { return $null }
    $last = @($msgs) | Select-Object -Last 1
    if ($last -and $last.info) { return $last.info.id }
    return $null
}

function Send-BridgePrompt {
    <#
    .SYNOPSIS
      Puts the text into the TUI prompt box and submits it - the remote message becomes
      visibly, literally typed input in the gardener's terminal.
    #>
    param($Config, [string]$Text, [string]$SessionId)

    # By default the TUI is NOT navigated anywhere. The prompt goes into whichever session is
    # already on screen, which is what "continue the conversation I am looking at" means.
    #
    # selectSession is opt-in and defaults to false. Setting it true forces the terminal to
    # jump to the remembered session before submitting. That is occasionally useful - pinning
    # the remote channel to one dedicated conversation - but on the first live test it was the
    # behaviour that yanked the gardener out of their active conversation, so it is no longer
    # the default and never fires without a remembered id.
    if ($Config.selectSession -and $SessionId) {
        $null = Invoke-BridgeAction -Config $Config -Path '/tui/select-session' `
                    -Body @{ sessionID = $SessionId } -TimeoutSec 15
    }

    # Clear anything half-typed, otherwise the remote text is appended to it and both are
    # submitted as one malformed prompt.
    $null = Invoke-BridgeAction -Config $Config -Path '/tui/clear-prompt' -TimeoutSec 15

    if (-not (Invoke-BridgeAction -Config $Config -Path '/tui/append-prompt' `
                  -Body @{ text = $Text } -TimeoutSec 20)) {
        # Nothing was submitted, so the caller may safely fall back.
        return $false
    }

    if (-not (Invoke-BridgeAction -Config $Config -Path '/tui/submit-prompt' -TimeoutSec 20)) {
        # The text is sitting in the prompt box unsubmitted. Clear it so it does not get
        # prepended to whatever the gardener types next.
        $null = Invoke-BridgeAction -Config $Config -Path '/tui/clear-prompt' -TimeoutSec 15
        return $false
    }

    return $true
}

function Wait-BridgeReply {
    <#
    .SYNOPSIS
      Polls the session transcript for an assistant message newer than $AfterMessageId and
      returns its text. Returns $null on timeout.
    #>
    param($Config, [string]$SessionId, [string]$AfterMessageId, [int]$TimeoutSeconds = 300)

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 3

        $msgs = Invoke-BridgeApi -Config $Config -Path "/session/$SessionId/message" -Method Get -TimeoutSec 30
        if (-not $msgs) { continue }
        $all = @($msgs)

        # Everything after the baseline message. With no baseline, consider the whole transcript.
        $tail = $all
        if ($AfterMessageId) {
            $idx = -1
            for ($i = 0; $i -lt $all.Count; $i++) {
                if ($all[$i].info.id -eq $AfterMessageId) { $idx = $i; break }
            }
            if ($idx -ge 0) {
                if ($idx -ge $all.Count - 1) { continue }   # nothing new yet
                $tail = $all[($idx + 1)..($all.Count - 1)]
            }
        }

        $assistant = @($tail) | Where-Object { $_.info.role -eq 'assistant' } | Select-Object -Last 1
        if (-not $assistant) { continue }

        # Only return once the turn is finished. time.completed is absent while streaming, and
        # returning early would relay a half-written answer to the phone.
        if (-not $assistant.info.time -or -not $assistant.info.time.completed) { continue }

        $text = (@($assistant.parts) |
                 Where-Object { $_.type -eq 'text' -and -not $_.synthetic -and -not $_.ignored } |
                 ForEach-Object { $_.text }) -join "`n"

        if (-not [string]::IsNullOrWhiteSpace($text)) { return $text.Trim() }
    }

    return $null
}

# =====================================================================
# ORCHESTRATION
# =====================================================================

function Invoke-TuiBridge {
    <#
    .SYNOPSIS
      Full interactive path. Returns a hashtable:
        @{ Ok = $true;  Text = '<assistant reply>' }
        @{ Ok = $false; Reason = '<why>' }   -- caller should fall back to the headless path.
    #>
    param($Config, [string]$Root, [string]$Text)

    if (-not (Test-BridgeServer -Config $Config)) {
        return @{ Ok = $false; Reason = 'server-unreachable' }
    }

    # Snapshot BEFORE submitting so the receiving session can be identified afterwards.
    $snapshot = Get-BridgeSessionSnapshot -Config $Config

    # selectSession is opt-in; the remembered id is only consulted when it is on.
    $pinned = if ($Config.selectSession) { Get-BridgeRememberedSessionId -Root $Root } else { $null }

    if (-not (Send-BridgePrompt -Config $Config -Text $Text -SessionId $pinned)) {
        # A /tui/* call returned non-2xx, so nothing was submitted. Safe for the caller to fall
        # back to the headless path.
        return @{ Ok = $false; Reason = 'submit-failed' }
    }

    $target = Find-BridgeTargetSession -Config $Config -Snapshot $snapshot -Text $Text -TimeoutSeconds 20
    if ($null -eq $target) {
        # The POSTs succeeded but no session shows the prompt. Most likely no TUI is attached,
        # so the server accepted the call with nothing listening.
        #
        # This deliberately does NOT report a reason the daemon falls back on. The submit was
        # accepted, so the prompt may yet appear; re-running it headlessly could execute the
        # same instruction twice. An unanswered message is recoverable, a duplicated one is not.
        return @{ Ok = $false; Reason = 'delivery-unconfirmed' }
    }

    Save-BridgeSessionId -Root $Root -SessionId $target.SessionId

    $timeout = if ($Config.replyTimeoutSeconds -gt 0) { [int]$Config.replyTimeoutSeconds } else { 300 }
    $reply = Wait-BridgeReply -Config $Config -SessionId $target.SessionId `
                 -AfterMessageId $target.MessageId -TimeoutSeconds $timeout

    if ($null -eq $reply) {
        # The prompt DID land in the TUI and may still be running. Say so precisely rather than
        # reporting a generic failure - the work is not lost, only the wait was.
        return @{ Ok = $false; Reason = 'reply-timeout'; SessionId = $target.SessionId }
    }

    return @{ Ok = $true; Text = $reply; SessionId = $target.SessionId }
}
