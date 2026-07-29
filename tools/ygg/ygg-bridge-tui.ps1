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
        selectSession       = $true
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
        Uri         = $uri
        Method      = $Method
        TimeoutSec  = $TimeoutSec
        Headers     = (Get-BridgeHeaders -Config $Config)
        ErrorAction = 'Stop'
    }
    if ($null -ne $Body) {
        $params['Body']        = ($Body | ConvertTo-Json -Depth 6 -Compress)
        $params['ContentType'] = 'application/json'
    }

    try {
        return Invoke-RestMethod @params
    } catch {
        Write-Host "  [WARN] bridge $Method $Path failed: $($_.Exception.Message)" -ForegroundColor DarkYellow
        return $null
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

function Get-BridgeSessionId {
    <#
    .SYNOPSIS
      Decides which session the remote prompt joins, in priority order:
        1. the session a TUI currently has in the foreground  (GET /api/session/active)
        2. the session id remembered from last time           (work/remote-session.json)
        3. the most recently updated session on the server    (GET /session)
        4. a new session                                      (POST /session)

      (1) is what makes the remote message land in the conversation the gardener is actually
      looking at. The rest are fallbacks so the channel still works with no TUI attached.
    #>
    param($Config, [string]$Root)

    # --- 1. foreground session owned by an attached TUI ---
    $active = Invoke-BridgeApi -Config $Config -Path '/api/session/active' -Method Get -TimeoutSec 10
    if ($active -and $active.data) {
        $ids = @($active.data.PSObject.Properties.Name)
        if ($ids.Count -gt 0 -and $ids[0] -match '^ses') {
            return $ids[0]
        }
    }

    # --- 2. remembered session ---
    $stateFile = Join-Path -Path $Root -ChildPath "work\remote-session.json"
    if (Test-Path -LiteralPath $stateFile -PathType Leaf) {
        try {
            $st = Get-Content -LiteralPath $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($st.sessionID -match '^ses') {
                # Confirm it still exists; a deleted session would 404 on every prompt.
                $probe = Invoke-BridgeApi -Config $Config -Path "/session/$($st.sessionID)" -Method Get -TimeoutSec 10
                if ($probe) { return $st.sessionID }
            }
        } catch { }
    }

    # --- 3. most recently updated existing session ---
    $sessions = Invoke-BridgeApi -Config $Config -Path '/session' -Method Get -TimeoutSec 20
    if ($sessions) {
        $newest = @($sessions) | Where-Object { $_.id -match '^ses' } |
                  Sort-Object -Property { $_.time.updated } -Descending | Select-Object -First 1
        if ($newest) { return $newest.id }
    }

    # --- 4. create one ---
    $created = Invoke-BridgeApi -Config $Config -Path '/session' -Method Post `
                   -Body @{ title = 'Remote channel' } -TimeoutSec 30
    if ($created -and $created.id) { return $created.id }

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

    # Bring the TUI to the session we are about to write into, so the submitted prompt is not
    # delivered to a conversation that is off-screen.
    if ($Config.selectSession -and $SessionId) {
        $null = Invoke-BridgeApi -Config $Config -Path '/tui/select-session' -Method Post `
                    -Body @{ sessionID = $SessionId } -TimeoutSec 15
    }

    # Clear anything half-typed, otherwise the remote text is appended to it and both are
    # submitted as one malformed prompt.
    $null = Invoke-BridgeApi -Config $Config -Path '/tui/clear-prompt' -Method Post -TimeoutSec 15

    $appended = Invoke-BridgeApi -Config $Config -Path '/tui/append-prompt' -Method Post `
                    -Body @{ text = $Text } -TimeoutSec 20
    if ($null -eq $appended) { return $false }

    $submitted = Invoke-BridgeApi -Config $Config -Path '/tui/submit-prompt' -Method Post -TimeoutSec 20
    return ($null -ne $submitted)
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

    $sessionId = Get-BridgeSessionId -Config $Config -Root $Root
    if (-not $sessionId) {
        return @{ Ok = $false; Reason = 'no-session' }
    }
    Save-BridgeSessionId -Root $Root -SessionId $sessionId

    $baseline = Get-BridgeLastMessageId -Config $Config -SessionId $sessionId

    if (-not (Send-BridgePrompt -Config $Config -Text $Text -SessionId $sessionId)) {
        return @{ Ok = $false; Reason = 'submit-failed' }
    }

    $timeout = if ($Config.replyTimeoutSeconds -gt 0) { [int]$Config.replyTimeoutSeconds } else { 300 }
    $reply = Wait-BridgeReply -Config $Config -SessionId $sessionId `
                 -AfterMessageId $baseline -TimeoutSeconds $timeout

    if ($null -eq $reply) {
        # The prompt DID land in the TUI and may still be running. Say so precisely rather than
        # reporting a generic failure - the work is not lost, only the wait was.
        return @{ Ok = $false; Reason = 'reply-timeout'; SessionId = $sessionId }
    }

    return @{ Ok = $true; Text = $reply; SessionId = $sessionId }
}
