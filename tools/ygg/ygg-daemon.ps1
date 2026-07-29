# ygg daemon - Yggdrasil background process
<#
.SYNOPSIS
  Yggdrasil background daemon.
.DESCRIPTION
  Persistent background process managing heartbeat scheduling, Telegram listener,
  and health endpoint. Subcommands: start, stop, status, install, uninstall.
  Launched by `ygg daemon start`. Runs until stopped via .ygg-daemon-stop signal
  file, Ctrl+C, or process termination.
.EXAMPLE
  ygg daemon start
  ygg daemon status
  ygg daemon stop
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Command = ""
)

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot   = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")
$seedDir   = Join-Path -Path $yggRoot -ChildPath "seed"
$memoryDir = Join-Path -Path $seedDir -ChildPath "memory"
$logDir    = Join-Path -Path $memoryDir -ChildPath "log"

# Remote message logs live OUTSIDE seed/memory/ [E47 condition 5].
# They contain text an untrusted third party chose. Writing that into the memory tree put
# attacker-controlled content in the same directory the bootstrap reads, one directory away
# from profile.md and goals.md - which is the private-data leg of the lethal trifecta sitting
# in the same place as the untrusted-content leg. The heartbeat log stays under
# seed/memory/log/: it is generated from local files and is not remote input.
$remoteLogDir = Join-Path -Path $yggRoot -ChildPath "logs\remote"

$pidFile        = Join-Path -Path $yggRoot -ChildPath ".ygg-daemon.pid"
$stopSignalFile = Join-Path -Path $yggRoot -ChildPath ".ygg-daemon-stop"
$statusFile     = Join-Path -Path $yggRoot -ChildPath ".ygg-daemon.json"

# =====================================================================
# TOKEN RETRIEVAL - same pattern as ygg-listen.ps1
# =====================================================================
$script:tgToken  = if ($env:TELEGRAM_BOT_TOKEN) { $env:TELEGRAM_BOT_TOKEN } else { [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "User") }
$script:tgChatId = if ($env:TELEGRAM_CHAT_ID) { $env:TELEGRAM_CHAT_ID } else { [Environment]::GetEnvironmentVariable("TELEGRAM_CHAT_ID", "User") }
# Auto-detect chat ID file -- persists across restarts without env var
$script:chatIdFile = Join-Path -Path $yggRoot -ChildPath ".ygg-daemon-chat-id"
# The .ygg-daemon-chat-id fallback is NOT read at startup any more [E47]. That file was written
# by the removed first-message adoption, so trusting it would restore the same defect across a
# restart -- an ID nobody authorized, promoted to owner by persistence alone. Configure
# TELEGRAM_CHAT_ID (user environment variable) instead. Delete the stale file.
if ($false) {
    $script:tgChatId = Get-Content $script:chatIdFile -Raw -Encoding UTF8 | ForEach-Object { $_.Trim() }
    Write-Host "  Chat ID loaded from $($script:chatIdFile)" -ForegroundColor DarkGray
}

# =====================================================================
# IDENTITY CACHE (read once, used for "who are you")
# =====================================================================
$script:identityName    = "Odin"
$script:identitySummary = "I am Odin, a governed companion. This is the remote channel. It is read-only: I can read the project and tell you where things stand, but I cannot edit, commit, or approve anything from here. Those need a local session. Rate-limited and injection-protected."
$identityPath = Join-Path -Path $seedDir -ChildPath "constitution/identity.md"
if (Test-Path -LiteralPath $identityPath -PathType Leaf) {
    $idContent = Get-Content -Path $identityPath -Raw -Encoding UTF8
    if ($idContent -match '^\*\*(\w+)\.\*\*') { $script:identityName = $matches[1] }
    $gardenerMatch = if ($idContent -match '\*\*Gardener:\*\*\s*(\S+)') { $matches[1] } else { "the gardener" }
    $script:identitySummary = "I am $($script:identityName), a governed companion. This is the remote channel. It is read-only: I can read the project and tell you where things stand, but I cannot edit, commit, or approve anything from here. Those need a local session. Rate-limited and injection-protected."
}

# =====================================================================
# STATE VARIABLES
# =====================================================================
$script:messagesProcessed   = 0
$script:injectionBlocked    = 0
$script:ratificationBlocked = 0
$script:lastActivity        = $null
$script:shutdownRequested   = $false
$script:heartbeatCount      = 0
$script:lastHeartbeatDate   = $null
$script:startTime           = $null
$script:pollOffset          = 0
$script:rateLimitTracker    = @{}   # ChatId -> timestamp of last request
$script:conversationHistory = @{}   # ChatId -> list of last 10 exchanges ("user: ..." / "bot: ...")

# =====================================================================
# HELPER FUNCTIONS
# =====================================================================

function Get-Timestamp {
    return (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
}

function Write-MessageLog {
    <#
    .SYNOPSIS
      Appends a message log entry to seed/memory/log/listener-YYYY-MM-DD.md.
      Y09 compliant - writes only to seed/memory/log/.
    #>
    param([string]$MessageText, [string]$FromUser, [string]$Stage, [string]$ResponseText = "")

    $today   = (Get-Date).ToString('yyyy-MM-dd')
    $logFile = Join-Path -Path $remoteLogDir -ChildPath "listener-$today.md"

    if (-not (Test-Path -LiteralPath $remoteLogDir -PathType Container)) {
        New-Item -ItemType Directory -Path $remoteLogDir -Force | Out-Null
    }

    # Remote text is truncated and stripped of newlines before storage [E47 condition 5].
    # Untruncated multi-line attacker text written into a Markdown file can forge log entries
    # below its own - a message containing a newline and "- 2026-01-01 | from: ..." would read
    # as a separate, earlier, legitimate entry. One entry, one line, bounded length.
    $safeText = ($MessageText -replace '[\r\n]+', ' ')
    if ($safeText.Length -gt 300) { $safeText = $safeText.Substring(0, 300) + '...[truncated]' }

    $timestamp = Get-Timestamp
    $entry     = "- $timestamp | from: $FromUser | stage: $Stage | text: $safeText"
    if ($ResponseText) {
        $responseTruncated = ($ResponseText -replace '[\r\n]+', ' ')
        if ($responseTruncated.Length -gt 200) { $responseTruncated = $responseTruncated.Substring(0, 200) + '...' }
        $entry += " | response: $responseTruncated"
    }

    if (Test-Path -LiteralPath $logFile -PathType Leaf) {
        Add-Content -Path $logFile -Value "`r`n$entry" -Encoding UTF8
    } else {
        Set-Content -Path $logFile -Value $entry -Encoding UTF8
    }
}

function Send-TelegramTyping {
    <#
    .SYNOPSIS
      Shows "typing..." indicator in Telegram while the bot is processing.
    #>
    param([string]$ChatId)
    $tgToken = if ($env:TELEGRAM_BOT_TOKEN) { $env:TELEGRAM_BOT_TOKEN } else { [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "User") }
    if (-not $tgToken) { return }
    try {
        $null = Invoke-RestMethod -Uri "https://api.telegram.org/bot${tgToken}/sendChatAction" `
            -Method Post -ContentType "application/json" `
            -Body (@{ chat_id = $ChatId; action = "typing" } | ConvertTo-Json) `
            -ErrorAction SilentlyContinue
    } catch {
        # Silently ignore -- typing indicator is best-effort
    }
}

function Send-TelegramMessage {
    <#
    .SYNOPSIS
      Sends a reply message via Telegram Bot API.
    #>
    param([string]$ChatId, [string]$Text)

    if (-not $script:tgToken) { 
        $errLog = Join-Path -Path $yggRoot -ChildPath ".ygg-send-debug.log"
        "$(Get-Date -Format 'HH:mm:ss') | SEND SKIPPED: tgToken is null" | Out-File $errLog -Encoding UTF8 -Append
        return 
    }
    if ([string]::IsNullOrWhiteSpace($Text)) { $Text = "(empty response)" }

    # Telegram's hard limit is 4096 UTF-16 code units. Trim defensively here as well as at
    # the caller, because error strings reach this function without passing through that path.
    if ($Text.Length -gt 4000) { $Text = $Text.Substring(0, 4000) + "... [truncated]" }

    $body = @{ chat_id = $ChatId; text = $Text } | ConvertTo-Json -Depth 3

    # WHY THE BYTE ARRAY: Windows PowerShell 5.1's Invoke-RestMethod encodes a *string* body
    # using the system codepage (CP1252 here), not UTF-8. Every non-ASCII character the model
    # emits -- arrows, em dashes, check marks -- became invalid UTF-8 on the wire and Telegram
    # rejected the whole request with "400 Bad Request". That is the sole cause of the three
    # send failures recorded in .ygg-send-debug.log on 2026-07-28. Encoding to UTF-8 bytes
    # explicitly and declaring the charset is the fix. [E73]
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)

    try {
        $response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($script:tgToken)/sendMessage" `
            -Method Post -ContentType "application/json; charset=utf-8" -Body $bodyBytes -ErrorAction Stop
        if (-not $response.ok) {
            $errLog = Join-Path -Path $yggRoot -ChildPath ".ygg-send-debug.log"
            "$(Get-Date -Format 'HH:mm:ss') | sendMessage returned not-ok" | Out-File $errLog -Encoding UTF8 -Append
        }
    } catch {
        # Telegram explains *why* it rejected a request in the response body. The previous
        # handler logged only the status line, which is why three identical "400 Bad Request"
        # entries carried no diagnosis. Read the body.
        $detail = ""
        try {
            $resp = $_.Exception.Response
            if ($resp) {
                $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
                $detail = $reader.ReadToEnd()
                $reader.Close()
            }
        } catch {}
        $errLog = Join-Path -Path $yggRoot -ChildPath ".ygg-send-debug.log"
        "$(Get-Date -Format 'HH:mm:ss') | sendMessage FAILED: $($_.Exception.Message) | len=$($Text.Length) | telegram-said: $detail" | Out-File $errLog -Encoding UTF8 -Append
    }
}

function Test-InjectionAttempt {
    <#
    .SYNOPSIS
      Y04 check - detects embedded instruction patterns.
    #>
    param([string]$Text)

    $patterns = @(
        'ignore previous instructions',
        'ignore all previous',
        'system prompt',
        'you are now',
        'new instructions',
        'override'
    )
    $lower = $Text.ToLower()
    foreach ($p in $patterns) {
        if ($lower.Contains($p)) { return $true }
    }
    return $false
}

function Test-RatificationAttempt {
    <#
    .SYNOPSIS
      Y10 check - detects ratification attempt patterns.
    #>
    param([string]$Text)

    $lower = $Text.ToLower()
    return ($lower.Contains('ratify')          -or
            $lower.Contains('approve all')     -or
            ($lower -match '\bapprove\b')      -or
            $lower.Contains('accept all'))
}

function Test-Y04Disclaimer {
    <#
    .SYNOPSIS
      Checks if the injection message carries an explicit Y04 disclaimer,
      allowing the message to proceed for testing purposes.
    #>
    param([string]$Text)

    return ($Text -match '(?i)this is a test of Y04' -or
            $Text -match '(?i)Y04 disclaim'         -or
            $Text -match '(?i)Y04 test'             -or
            $Text -match '(?i)disclaimed')
}

function Test-RateLimit {
    <#
    .SYNOPSIS
      Rate limiting -- maximum 1 request per 30 seconds per chat ID.
      Returns $true if the request should be blocked.
    #>
    param([string]$ChatId)

    if ($script:rateLimitTracker.ContainsKey($ChatId)) {
        $lastRequest = $script:rateLimitTracker[$ChatId]
        $elapsed = ((Get-Date) - $lastRequest).TotalSeconds
        if ($elapsed -lt 30) {
            return $true
        }
    }
    return $false
}

function Invoke-YggCommand {
    <#
    .SYNOPSIS
      Runs a ygg command directly (fast, local). E.g. Invoke-YggCommand "doctor".
    #>
    param([string]$Arguments)

    $yggScript = Join-Path -Path $scriptDir -ChildPath "ygg.ps1"
    if (-not (Test-Path -LiteralPath $yggScript -PathType Leaf)) {
        return "ygg command not available (ygg.ps1 not found)."
    }

    try {
        # Split arguments and invoke ygg.ps1 with them
        $argList = if ($Arguments) { $Arguments.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries) } else { @() }
        $output = & $yggScript $argList *>&1 | Out-String
        return $output.Trim()
    } catch {
        return "ygg command failed: $($_.Exception.Message)"
    }
}

function Invoke-OpenCodeRun {
    <#
    .SYNOPSIS
      Runs 'opencode run' with the given arguments and captures output.
      Prompt is written to a temp file to avoid PowerShell quoting issues.
      Also runs a typing-indicator loop while the command is executing.
    #>
    # The prompt is ALWAYS delivered by file and piped to stdin, never as a -p argument.
    # Passing it as an argument required escaping embedded quotes, and any argument-splitting
    # in this function then shredded the prompt at its spaces. Piping removes the whole class.
    # $AgentName is a bare token from a fixed allowlist, so it is safe to pass as an argument.
    param([string]$AgentName, [string]$ChatId, [string]$PromptFile)

    try {
        # Run via PowerShell job to avoid deadlocks.
        #
        # THREE DEFECTS FIXED HERE [E74]:
        #  1. The $PromptFile branch ignored $args2 and hardcoded its own command line with no
        #     --agent flag, so every general-path message reached opencode's DEFAULT agent under
        #     a config granting edit and bash. Patching the caller could not have helped -- the
        #     argument was discarded here. $Arguments is now honoured on both branches.
        #  2. Start-Job launches a fresh PowerShell with the user profile as its working
        #     directory, so 'opencode' resolved outside the seed and .ygg was not found. The
        #     job now sets its location to the project root.
        #  3. 2>&1 merged opencode's error stream into the reply, so stack traces were sent to
        #     the user as if they were the answer. Streams are now separated.
        $job = Start-Job -ScriptBlock {
            param($pf, $agent, $workDir)
            Set-Location -LiteralPath $workDir
            $ErrorActionPreference = 'Continue'
            if (-not ($pf -and (Test-Path $pf))) { return @{ Out = ''; Err = '' } }
            $prompt = Get-Content $pf -Raw -Encoding UTF8

            # Fixed argument vector. --agent is never omitted: an agent is chosen explicitly
            # for every remote invocation, so remote text can never reach the host default.
            #
            # stderr goes to a FILE, never to 2>&1 [E77]. In Windows PowerShell 5.1, redirecting a
            # native command's stderr inside a pipeline wraps each line in a NativeCommandError
            # and sets $? to false even on exit code 0. `opencode` here is a .ps1 shim that itself
            # pipes into the .exe, so the wrapping broke the shim and the gardener received
            #   opencode.exe : At C:\nodejs\opencode.ps1:12 char:12
            # instead of an answer. A file redirect captures the same text without the wrapping.
            $errFile = [System.IO.Path]::GetTempFileName()
            $r = ($prompt | & opencode run -m opencode-go/deepseek-v4-flash --agent $agent 2>$errFile) | Out-String
            $e = if (Test-Path $errFile) { Get-Content $errFile -Raw -ErrorAction SilentlyContinue } else { '' }
            Remove-Item $errFile -Force -ErrorAction SilentlyContinue
            Remove-Item $pf -Force -ErrorAction SilentlyContinue
            return @{ Out = $r; Err = $e }
        } -ArgumentList $PromptFile, $AgentName, $yggRoot

        # Continuously send typing indicator while the job runs
        $typingJob = Start-Job -ScriptBlock {
            param($tgToken, $chatId)
            for ($i = 0; $i -lt 24; $i++) {
                try {
                    $null = Invoke-RestMethod -Uri "https://api.telegram.org/bot${tgToken}/sendChatAction" `
                        -Method Post -ContentType "application/json" `
                        -Body (@{ chat_id = $chatId; action = "typing" } | ConvertTo-Json) `
                        -ErrorAction SilentlyContinue
                } catch {}
                Start-Sleep -Seconds 5
            }
        } -ArgumentList $script:tgToken, $ChatId

        # Wait for main job with timeout. Receive-Job WITHOUT 2>&1 [E77] -- merging the job's
        # error stream here is what put PowerShell error furniture (+ CategoryInfo, + FullyQualified
        # ErrorId, + PSComputerName) into the gardener's replies.
        $job | Wait-Job -Timeout 120 | Out-Null
        $result = $job | Receive-Job
        $null = Wait-Job $typingJob -Timeout 3 2>$null
        Remove-Job $typingJob -ErrorAction SilentlyContinue
        Remove-Job $job -ErrorAction SilentlyContinue

        # The job returns @{ Out; Err }. stdout is the answer; stderr is inspected for the
        # agent-binding warning and never shown to the user.
        $stderrText = ''
        if ($result -is [hashtable]) {
            $output     = [string]$result.Out
            $stderrText = [string]$result.Err
        } else {
            $output = ($result | Out-String)
        }

        # ---- FAIL CLOSED on agent fallback [E75] ----
        # 'opencode run --agent X' requires X to be mode: primary. Naming a subagent prints
        #   agent "X" is a subagent, not a primary agent. Falling back to default agent
        # and then SERVES THE REQUEST ANYWAY from the host default -- which holds edit and bash.
        # The failure is silent from the user's side: a normal-looking answer comes back, produced
        # by an agent nobody authorized. A security control that degrades to "no control" without
        # stopping is not a control. If the flag did not bind, discard the output entirely.
        if ($stderrText -match 'is a subagent, not a primary agent' -or
            $stderrText -match 'Falling back to default agent' -or
            $output     -match 'is a subagent, not a primary agent' -or
            $output     -match 'Falling back to default agent') {
            $errLog = Join-Path -Path $yggRoot -ChildPath ".ygg-send-debug.log"
            "$(Get-Date -Format 'HH:mm:ss') | REFUSED: --agent did not bind; opencode fell back to the default agent. Output discarded." | Out-File $errLog -Encoding UTF8 -Append
            return "The remote channel could not reach its designated read-only agent, so the request was refused rather than answered by an unrestricted one. This needs a local session to fix."
        }

        # Strip ANSI, headers, collapse blanks
        $output = $output -replace '\e\[[\d;]*[a-zA-Z]', ''
        $output = $output -replace '(?m)^\s*>.*$', ''

        # ---- Strip opencode's tool-trace lines [E76] ----
        # The model's file reads were being relayed to the gardener as part of the answer:
        #   -> Read roadmap/SLICES.md
        #   Let me check the work index and current phase detail.
        # These are the search, not the finding. Remove them.
        # NOTE: every non-ASCII character below is built from a char code, never written as a
        # literal. A literal saved into a .ps1 that PowerShell 5.1 then reads as ANSI corrupts
        # the surrounding string and breaks the parse - which is exactly how this block was
        # broken on first write.
        $arrow = [string][char]0x2192
        $output = $output -replace ('(?m)^\s*(' + $arrow + '|->)\s*(Read|Write|Edit|Glob|Grep|Bash|List|Search)\b.*$'), ''
        $output = $output -replace '(?m)^\s*(Let me|I''ll|I will|Now let me|First,? let me)\b.*$', ''
        $output = $output -replace '(?m)^\s*\+\s*(CategoryInfo|FullyQualifiedErrorId|PSComputerName)\b.*$', ''

        # ---- Repair mojibake before it reaches the phone [E73] ----
        # Some model output arrives already CP437-mangled. Map the common runs back to ASCII
        # rather than shipping them; the channel has produced corrupted glyphs repeatedly.
        $mojibakeMap = @{
            ([string][char]0x0393 + [char]0x00E5 + [char]0x00C6) = '->'   # was U+2192
            ([string][char]0x0393 + [char]0x00C7 + [char]0x00F6) = '-'    # was U+2014 em dash
            ([string][char]0x0393 + [char]0x00BF + [char]0x00E5) = '*'    # was U+2605 star
        }
        foreach ($k in $mojibakeMap.Keys) { $output = $output.Replace($k, $mojibakeMap[$k]) }

        # Any remaining non-ASCII is transliterated to its nearest safe form.
        $translit = @{
            0x2018 = "'"; 0x2019 = "'"
            0x201C = '"'; 0x201D = '"'
            0x2013 = '-'; 0x2014 = '-'
            0x2192 = '->'
            0x2605 = ''; 0x2606 = ''; 0x2713 = ''; 0x2714 = ''
            0x2705 = ''; 0x274C = ''; 0x2757 = ''
        }
        foreach ($code in $translit.Keys) {
            $output = $output.Replace([string][char]$code, $translit[$code])
        }

        # ---- Strip markdown, which renders as literal punctuation on a phone [E76] ----
        # The gardener's report arrived containing '**P2 - Portability MVP**' and '## Roles'.
        # Telegram's default parse mode is plain text, so these are shown verbatim as asterisks
        # and hashes. ratatoskr.md instructs the agent not to emit them; this is the safety net
        # for when it does anyway.
        $output = $output -replace '\*\*([^*]+)\*\*', '$1'      # bold
        $output = $output -replace '(?m)^\s{0,3}#{1,6}\s+', ''  # headings
        $output = $output -replace '(?m)^\s*[-*]\s+', '- '      # normalise bullets
        $output = $output -replace '`{3}[a-z]*', ''             # code fences
        $output = $output -replace '`([^`]+)`', '$1'            # inline code

        $output = $output -replace '\r?\n\s*\r?\n', "`r`n"
        $output = $output.Trim()
        
        # If output is just "True" or empty, indicate timeout/failure
        if ([string]::IsNullOrWhiteSpace($output) -or $output -eq "True") {
            $output = "Command produced no output. The prompt may be too long or the model timed out."
        }
    } catch {
        $output = "Execution failed: $($_.Exception.Message)"
    }

    # Truncate for Telegram
    if ($output.Length -gt 4000) {
        $output = $output.Substring(0, 4000) + "... [truncated]"
    }

    return $output.Trim()
}

function Process-Message {
    <#
    .SYNOPSIS
      Processes a single Telegram message through the Y10 -> Y04 -> routing pipeline.
    #>
    param([string]$Text, [string]$ChatId, [int]$UpdateId)

    # ---- Stage 0: sender authorization ----
    # Previously there was none. If no chat ID was configured, the FIRST sender to message the
    # bot was silently adopted as the owner and persisted to .ygg-daemon-chat-id. Anyone who
    # found the bot before the gardener did became the authorized user. The channel is now
    # closed by default: TELEGRAM_CHAT_ID must be set in configuration, and a message from any
    # other chat is logged and dropped without a reply. Silence, not an error message --
    # replying confirms the bot exists to an unauthorized prober. [E47]
    if (-not $script:tgChatId) {
        Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "blocked-no-owner-configured"
        Write-Host "  REFUSED: TELEGRAM_CHAT_ID is not configured; the channel is closed." -ForegroundColor Red
        return
    }
    if ($ChatId -ne $script:tgChatId) {
        Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "blocked-unauthorized-sender"
        Write-Host "  REFUSED: message from unauthorized chat $ChatId" -ForegroundColor Red
        return
    }

    # ---- Stage 1: Y10 check - ratification refusal ----
    if (Test-RatificationAttempt -Text $Text) {
        Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "blocked-y10"
        $script:ratificationBlocked++
        $script:lastActivity = Get-Timestamp
        Send-TelegramMessage -ChatId $ChatId -Text "Remote ratification is not honoured per Y10. Valid channels: local session or version-control commit."
        return
    }

    # ---- Stage 2: Y04 check - injection detection ----
    if (Test-InjectionAttempt -Text $Text) {
        if (Test-Y04Disclaimer -Text $Text) {
            Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "y04-disclaimed"
        } else {
            Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "blocked-y04"
            $script:injectionBlocked++
            $script:lastActivity = Get-Timestamp
            Send-TelegramMessage -ChatId $ChatId -Text "Embedded instructions detected and refused. Content treated as untrusted per Y04."
            return
        }
    }

    # ---- Stage 3: Remote execution ----
    $script:messagesProcessed++
    $script:lastActivity = Get-Timestamp
    # First-message chat-ID adoption REMOVED [E47]. It made the channel self-authorizing:
    # whoever messaged first became the owner. Authorization is now checked at Stage 0 above
    # and comes from configuration only. Execution cannot reach this line for an unknown chat.
    # Send immediate acknowledgment so user knows bot is working
    Send-TelegramMessage -ChatId $ChatId -Text "Received. Processing..."
    # Show typing indicator so the user knows the bot is working
    Send-TelegramTyping -ChatId $ChatId

    $lowerText = $Text.ToLower().Trim()

    # === Fast path 1: Legacy status/briefing -- run heartbeat ===
    if ($lowerText -eq 'status' -or $lowerText -eq 'briefing') {
        Write-Host "  Processing status/briefing request from $ChatId" -ForegroundColor DarkCyan
        $heartbeatScript = Join-Path -Path $scriptDir -ChildPath "ygg-heartbeat.ps1"
        if (Test-Path -LiteralPath $heartbeatScript -PathType Leaf) {
            try {
                $output = & $heartbeatScript --full *>&1 | Out-String
                Send-TelegramMessage -ChatId $ChatId -Text $output
                Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "status-briefing" -ResponseText $output
            } catch {
                $errMsg = "Heartbeat failed: $($_.Exception.Message)"
                Send-TelegramMessage -ChatId $ChatId -Text $errMsg
                Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "status-briefing" -ResponseText $errMsg
            }
        } else {
            $errMsg = "Heartbeat script not found."
            Send-TelegramMessage -ChatId $ChatId -Text $errMsg
            Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "status-briefing" -ResponseText $errMsg
        }
        return
    }

    # === Fast path 2: Legacy doctor -- run doctor script ===
    if ($lowerText -eq 'doctor') {
        Write-Host "  Processing doctor request from $ChatId" -ForegroundColor DarkCyan
        $doctorScript = Join-Path -Path $scriptDir -ChildPath "ygg-doctor.ps1"
        if (Test-Path -LiteralPath $doctorScript -PathType Leaf) {
            try {
                $output = & $doctorScript *>&1 | Out-String
                Send-TelegramMessage -ChatId $ChatId -Text $output
                Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "doctor" -ResponseText $output
            } catch {
                $errMsg = "Doctor check failed: $($_.Exception.Message)"
                Send-TelegramMessage -ChatId $ChatId -Text $errMsg
                Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "doctor" -ResponseText $errMsg
            }
        } else {
            $errMsg = "Doctor script not found."
            Send-TelegramMessage -ChatId $ChatId -Text $errMsg
            Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "doctor" -ResponseText $errMsg
        }
        return
    }

    # === Fast path 3: Legacy who-are-you -- identity summary ===
    if ($lowerText -match '^who are you' -or $lowerText -eq 'who are you?' -or $lowerText -eq 'who are you') {
        Send-TelegramMessage -ChatId $ChatId -Text $script:identitySummary
        Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "who-are-you" -ResponseText $script:identitySummary
        return
    }

    # === Fast path 4: ygg-prefixed commands -- run locally ===
    if ($lowerText -match '^ygg\s+') {
        $yggArgs = $Text.Substring(4).Trim()

        # Subcommand allowlist [E47]. This branch previously forwarded ANY subcommand -- so
        # 'ygg plant', 'ygg daemon', 'ygg gate-l1' and 'ygg gate-l2' were all remotely
        # reachable, and it sat ABOVE the rate-limit check so they were unthrottled too.
        # Only read-only, side-effect-free subcommands are permitted from the remote channel.
        $remoteAllowedYgg = @('doctor', 'heartbeat', 'verify')
        $yggSub = ($yggArgs -split '\s+')[0].ToLower()
        if ($yggSub -notin $remoteAllowedYgg) {
            $errMsg = "Subcommand 'ygg $yggSub' is not available remotely. Allowed: doctor, heartbeat, verify. State-changing subcommands (plant, gate-l1, gate-l2, daemon) are local-only."
            Send-TelegramMessage -ChatId $ChatId -Text $errMsg
            Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "blocked-ygg-subcommand" -ResponseText $errMsg
            return
        }

        # Rate limit applies here too. It previously did not, because this branch returned
        # before reaching the check below.
        if (Test-RateLimit -ChatId $ChatId) {
            $msg = "Rate limit active. Please wait 30 seconds between requests."
            Send-TelegramMessage -ChatId $ChatId -Text $msg
            Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "rate-limited" -ResponseText $msg
            return
        }

        Write-Host "  Processing ygg command '$yggArgs' from $ChatId" -ForegroundColor DarkCyan
        $output = Invoke-YggCommand -Arguments $yggArgs
        Send-TelegramMessage -ChatId $ChatId -Text $output
        Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "ygg-command" -ResponseText $output
        return
    }

    # === Rate limit check (applies to remote execution only) ===
    if (Test-RateLimit -ChatId $ChatId) {
        $msg = "Rate limit active. Please wait 30 seconds between requests."
        Send-TelegramMessage -ChatId $ChatId -Text $msg
        Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "rate-limited"
        return
    }

    # Track this request for rate limiting
    $script:rateLimitTracker[$ChatId] = Get-Date

    # === @-prefixed: agent invocation ===
    if ($Text -match '^@(\w+)\s*(.*)$') {
        $agentName  = $matches[1].ToLower()
        $agentPrompt = $matches[2].Trim()

        # Security: restrict to read-only agents (Yggdrasil rule -- never builder/deployment)
        $allowedAgents = @("ratatoskr")  # primary-mode + read-only only [E75]
        if ($agentName -notin $allowedAgents) {
            $errMsg = "Agent '@$agentName' is not available remotely. The remote channel serves one agent, ratatoskr, which is read-only. The roster agents (skuld, var, huginn, kvasir and the rest) are subagents - opencode cannot start them directly, and naming one silently falls back to an unrestricted default. Use a local session for those."
            Send-TelegramMessage -ChatId $ChatId -Text $errMsg
            Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "agent-restricted" -ResponseText $errMsg
            return
        }

        Write-Host "  Invoking agent @$agentName from $ChatId" -ForegroundColor DarkCyan
        # Escape embedded double-quotes for the -p argument
        # Prompt goes via file, not -p. No quote escaping, no splitting hazard. [E74]
        $agentPromptFile = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "ygg-prompt-$(Get-Random).txt"
        $agentPrompt | Out-File -FilePath $agentPromptFile -Encoding UTF8 -Force
        $output = Invoke-OpenCodeRun -AgentName $agentName -ChatId $ChatId -PromptFile $agentPromptFile
        if (Test-Path $agentPromptFile) { Remove-Item $agentPromptFile -Force -ErrorAction SilentlyContinue }
        $stageTag = "agent-$agentName"
    } else {
        # === General prompt with project context ===
        Write-Host "  Processing general prompt from $ChatId" -ForegroundColor DarkCyan
        
        # Build project context + conversation history
        $contextLines = @()
        $contextLines += "[Project: Yggdrasil governed companion seed]"
        
        # Read SLICES.md for phase status
        $slicesPath = Join-Path -Path $scriptDir -ChildPath "..\..\roadmap\SLICES.md"
        $unitPath = $null
        if (Test-Path $slicesPath) {
            foreach ($line in (Get-Content $slicesPath -Encoding UTF8)) {
                if ($line -match '^\|\s*[A-Za-z]\d*\s*\|') {
                    $contextLines += $line.Trim()
                }
                if ($line -match '^\|\s*(\w+)\s*\|\s*``(.*?)``.*\|\s*In Progress') {
                    $unitPath = Join-Path -Path $scriptDir -ChildPath "..\..\roadmap\$($matches[2])"
                }
            }
        }
        # Read [HUMAN] tasks
        $humanTasks = @()
        if ($unitPath -and (Test-Path $unitPath)) {
            foreach ($tLine in (Get-Content $unitPath -Encoding UTF8)) {
                if ($tLine -match '\[ \]\s+(\S+)\s+\*\*\[HUMAN\]\*\*\s+(.+)') {
                    $humanTasks += "$($matches[1]): $($matches[2])"
                }
            }
        }
        if ($humanTasks.Count -gt 0) {
            $contextLines += "[Open tasks: $($humanTasks -join ' | ')]"
        }

        # Read session-state.md for ephemeral session planning context
        $sessionStatePath = Join-Path -Path $scriptDir -ChildPath "..\..\work\session-state.md"
        if (Test-Path $sessionStatePath) {
            $sessionLines = @()
            foreach ($ssLine in (Get-Content $sessionStatePath -Encoding UTF8)) {
                $trimmed = $ssLine.Trim()
                if ($trimmed.Length -gt 0 -and $trimmed -notmatch '^#') {
                    $sessionLines += $trimmed
                }
            }
            if ($sessionLines.Count -gt 0) {
                $contextLines += "[Session context: $($sessionLines -join ' | ')]"
            }
        }

        # Inject conversation history (last 6 exchanges)
        $history = @()
        if ($script:conversationHistory.ContainsKey($ChatId)) {
            $history = $script:conversationHistory[$ChatId]
        }
        
        $context = $contextLines -join "`n"
        $fullPrompt = "$context"
        if ($history.Count -gt 0) {
            $fullPrompt += "`n`n[Conversation so far:]"
            $fullPrompt += "`n$($history -join "`n")"
        }
        $fullPrompt += "`n`n---`nUser: $Text`nAssistant:"
        
        # Write prompt to temp file, pass via pipeline to avoid quoting issues
        $promptFile = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "ygg-prompt-$(Get-Random).txt"
        $fullPrompt | Out-File -FilePath $promptFile -Encoding UTF8 -Force
        # The general path is pinned to a READ-ONLY agent. Remote text must never reach an agent
        # holding edit or bash. ratatoskr is the only primary-mode read-only agent; naming any
        # roster agent here silently falls back to the default. [E74][E75][E47]
        $output = Invoke-OpenCodeRun -AgentName "ratatoskr" -ChatId $ChatId -PromptFile $promptFile
        if (Test-Path $promptFile) { Remove-Item $promptFile -Force -ErrorAction SilentlyContinue }
        $stageTag = "general"
    }

    Send-TelegramMessage -ChatId $ChatId -Text $output
    Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage $stageTag -ResponseText $output
    
    # Save conversation history for continuity (last 10 exchanges per chat)
    if (-not $script:conversationHistory.ContainsKey($ChatId)) {
        $script:conversationHistory[$ChatId] = @()
    }
    $hist = $script:conversationHistory[$ChatId]
    $hist += "User: $Text"
    $hist += "Assistant: $(($output -replace "`n", ' ').Substring(0, [Math]::Min(200, $output.Length)))"
    if ($hist.Count -gt 10) { $hist = $hist[-10..-1] }
    $script:conversationHistory[$ChatId] = $hist
}

function Update-HealthFile {
    <#
    .SYNOPSIS
      Writes runtime daemon status to .ygg-daemon.json.
      Not under seed/memory/ - this is ephemeral runtime state.
    #>
    $uptime = if ($script:startTime) { [math]::Round(((Get-Date) - $script:startTime).TotalSeconds) } else { 0 }
    $statusData = @{
        status                = if ($script:shutdownRequested) { "stopped" } else { "running" }
        timestamp             = Get-Timestamp
        uptime_seconds        = $uptime
        heartbeats_sent       = $script:heartbeatCount
        messages_received     = $script:messagesProcessed
        injection_blocked     = $script:injectionBlocked
        ratification_blocked  = $script:ratificationBlocked
        last_activity         = $script:lastActivity
        pid                   = [int]$pid
    } | ConvertTo-Json
    $statusData | Out-File -FilePath $statusFile -Encoding UTF8 -Force
}

function Invoke-Heartbeat {
    <#
    .SYNOPSIS
      Runs ygg-heartbeat.ps1 with auto-retry (3 attempts, 30s delay).
    #>
    $heartbeatScript = Join-Path -Path $scriptDir -ChildPath "ygg-heartbeat.ps1"
    if (-not (Test-Path -LiteralPath $heartbeatScript -PathType Leaf)) {
        Write-Host "  [WARN] Heartbeat script not found: $heartbeatScript" -ForegroundColor DarkYellow
        return
    }

    $retries = 0
    while ($retries -lt 3) {
        try {
            Write-Host "  $(Get-Timestamp) Running heartbeat..." -ForegroundColor DarkCyan
            & $heartbeatScript
            if ($LASTEXITCODE -eq 0) {
                $script:heartbeatCount++
                Write-Host "  Heartbeat completed successfully." -ForegroundColor DarkCyan
                return
            } else {
                Write-Host "  [WARN] Heartbeat exited with code $LASTEXITCODE" -ForegroundColor DarkYellow
            }
        } catch {
            Write-Host "  [WARN] Heartbeat attempt $($retries+1) failed: $_" -ForegroundColor DarkYellow
        }
        $retries++
        if ($retries -lt 3) {
            Write-Host "  Retrying heartbeat in 30 seconds..." -ForegroundColor DarkYellow
            for ($i = 0; $i -lt 30; $i++) {
                if ($script:shutdownRequested) { return }
                Start-Sleep -Seconds 1
            }
        }
    }
    Write-Host "  [ERROR] Heartbeat failed after 3 retries." -ForegroundColor Red
}

function Invoke-TelegramPoll {
    <#
    .SYNOPSIS
      Polls Telegram getUpdates API with auto-retry (3 attempts, 30s delay).
    #>
    if (-not $script:tgToken) { return }

    $updatesUrl = "https://api.telegram.org/bot$($script:tgToken)/getUpdates"
    $retries    = 0

    while ($retries -lt 3) {
        try {
            $response = Invoke-RestMethod -Uri $updatesUrl `
                -Method Post `
                -Body @{ offset = $script:pollOffset } `
                -ErrorAction Stop

            if ($response.ok -and $response.result -and $response.result.Count -gt 0) {
                $maxId = 0
                foreach ($update in $response.result) {
                    if ($update.update_id -gt $maxId) { $maxId = $update.update_id }

                    $msg = $update.message
                    if ($msg -and (-not [string]::IsNullOrEmpty($msg.text))) {
                        $chatId = $msg.chat.id
                        $text   = $msg.text
                        $displayText = if ($text.Length -gt 50) { $text.Substring(0, 50) + '...' } else { $text }
                        Write-Host "  $(Get-Timestamp) - Message from $chatId : $displayText" -ForegroundColor DarkGray
                        Process-Message -Text $text -ChatId $chatId -UpdateId $update.update_id
                    }
                }

                if ($maxId -gt 0) {
                    $script:pollOffset = $maxId + 1
                }
            }

            return  # success - exit function
        } catch [System.Net.WebException] {
            if ($null -ne $_.Exception.Response -and $_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::Unauthorized) {
                Write-Host "  [ERROR] Invalid Telegram bot token (401)" -ForegroundColor Red
                $script:tgToken = $null  # disable further polling
                return
            }
            Write-Host "  [WARN] Telegram poll attempt $($retries+1) failed (WebException)" -ForegroundColor DarkYellow
        } catch {
            Write-Host "  [WARN] Telegram poll attempt $($retries+1) failed: $_" -ForegroundColor DarkYellow
        }

        $retries++
        if ($retries -lt 3) {
            for ($i = 0; $i -lt 30; $i++) {
                if ($script:shutdownRequested) { return }
                Start-Sleep -Seconds 1
            }
        }
    }
    Write-Host "  [ERROR] Telegram polling failed after 3 retries." -ForegroundColor Red
}

# =====================================================================
# COMMAND: _run  (internal - actual daemon process loop)
# =====================================================================

function Start-DaemonLoop {
    <#
    .SYNOPSIS
      The persistent daemon loop. Launched in background by `start`.
    #>
    $script:startTime         = Get-Date
    $script:shutdownRequested = $false

    # Write PID file
    $pid | Out-File -FilePath $pidFile -Encoding ASCII -Force

    # Ctrl+C handler
    try {
        $null = Register-ObjectEvent -InputObject ([Console]) -EventName CancelKeyPress -Action {
            $global:shutdownRequested = $true
        } -SupportEvent -ErrorAction SilentlyContinue
    } catch {
        # Ctrl+C handling not available on this host - stop-signal file still works
    }

    # Initial health file write
    Update-HealthFile

    Write-Host "=== Yggdrasil Daemon ===" -ForegroundColor Cyan
    Write-Host "PID: $pid" -ForegroundColor DarkCyan
    Write-Host "Working directory: $yggRoot" -ForegroundColor DarkGray
    Write-Host "Stop with Ctrl+C or .ygg-daemon-stop file" -ForegroundColor DarkCyan
    Write-Host ""

    if (-not $script:tgToken) {
        Write-Host "  [INFO] TELEGRAM_BOT_TOKEN not set - Telegram listener disabled" -ForegroundColor DarkYellow
    }

    # Timing trackers
    $lastPollTime       = $null
    $lastHealthUpdate   = $null
    $lastHeartbeatCheck = $null

    # ---- MAIN LOOP ----
    while (-not $script:shutdownRequested) {
        $now = Get-Date

        # ---- Check stop signal file ----
        if (Test-Path -LiteralPath $stopSignalFile -PathType Leaf) {
            Write-Host "`nStop signal file detected (.ygg-daemon-stop). Exiting." -ForegroundColor Yellow
            break
        }

        # ---- Telegram poll (every 10 seconds) ----
        if ($script:tgToken -and (-not $lastPollTime -or ($now - $lastPollTime).TotalSeconds -ge 10)) {
            $lastPollTime = $now
            Invoke-TelegramPoll
        }

        # ---- Heartbeat check (every 60 seconds) ----
        if (-not $lastHeartbeatCheck -or ($now - $lastHeartbeatCheck).TotalMinutes -ge 1) {
            $lastHeartbeatCheck = $now
            $heartbeatDue = (-not $script:lastHeartbeatDate) -or (($now - $script:lastHeartbeatDate).TotalHours -ge 24)
            if ($heartbeatDue) {
                Invoke-Heartbeat
                $script:lastHeartbeatDate = $now
            }
        }

        # ---- Health file update (every 60 seconds) ----
        if (-not $lastHealthUpdate -or ($now - $lastHealthUpdate).TotalSeconds -ge 60) {
            $lastHealthUpdate = $now
            Update-HealthFile
        }

        Start-Sleep -Seconds 1
    }

    # ---- CLEANUP ----
    $script:shutdownRequested = $true

    if (Test-Path -LiteralPath $pidFile -PathType Leaf) {
        Remove-Item -Path $pidFile -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $stopSignalFile -PathType Leaf) {
        Remove-Item -Path $stopSignalFile -Force -ErrorAction SilentlyContinue
    }

    # Final health file with stopped status
    Update-HealthFile

    Write-Host ""
    Write-Host "Daemon stopped at $(Get-Timestamp)" -ForegroundColor Green
    exit 0
}

# =====================================================================
# COMMAND: start  (launcher - checks stale PID, spawns background daemon)
# =====================================================================

function Start-DaemonLauncher {
    <#
    .SYNOPSIS
      Checks for existing daemon, spawns a hidden PowerShell process running _run.
    #>
    # Clean any stale stop signal
    if (Test-Path -LiteralPath $stopSignalFile -PathType Leaf) {
        Remove-Item -Path $stopSignalFile -Force -ErrorAction SilentlyContinue
    }

    # Check if already running
    if (Test-Path -LiteralPath $pidFile -PathType Leaf) {
        $existingPid = (Get-Content $pidFile -Raw).Trim()
        if ($existingPid -and (Get-Process -Id $existingPid -ErrorAction SilentlyContinue)) {
            Write-Host "Daemon already running (PID: $existingPid). Use 'ygg daemon stop' or 'ygg daemon status'." -ForegroundColor Yellow
            exit 1
        }
        # Stale PID file - clean up
        Remove-Item -Path $pidFile -Force -ErrorAction SilentlyContinue
    }

    # Spawn background daemon process
    $selfPath = Join-Path -Path $scriptDir -ChildPath "ygg-daemon.ps1"
    $psArgs   = "-NoProfile -ExecutionPolicy Bypass -File `"$selfPath`" _run"
    Start-Process -WindowStyle Hidden -FilePath powershell.exe -ArgumentList $psArgs

    # Brief wait to let the daemon write its PID
    Start-Sleep -Seconds 2

    if (Test-Path -LiteralPath $pidFile -PathType Leaf) {
        $newPid = (Get-Content $pidFile -Raw).Trim()
        Write-Host "Daemon started (PID: $newPid)" -ForegroundColor Green
    } else {
        Write-Host "Daemon may not have started. Check with 'ygg daemon status'." -ForegroundColor Yellow
    }
    exit 0
}

# =====================================================================
# COMMAND: stop
# =====================================================================

function Stop-Daemon {
    <#
    .SYNOPSIS
      Signals the daemon to stop via .ygg-daemon-stop, waits, then force-kills if needed.
    #>
    # Write stop signal file
    Set-Content -Path $stopSignalFile -Value "stop" -Encoding ASCII -NoNewline

    if (Test-Path -LiteralPath $pidFile -PathType Leaf) {
        $filePid = (Get-Content $pidFile -Raw).Trim()
        if ($filePid -and (Get-Process -Id $filePid -ErrorAction SilentlyContinue)) {
            Write-Host "Stop signal sent to daemon (PID: $filePid). Waiting for graceful shutdown..." -ForegroundColor Yellow

            # Wait up to 10 seconds
            $waited = 0
            while ($waited -lt 10 -and (Get-Process -Id $filePid -ErrorAction SilentlyContinue)) {
                Start-Sleep -Seconds 1
                $waited++
            }

            # Force kill if still running
            if (Get-Process -Id $filePid -ErrorAction SilentlyContinue) {
                Stop-Process -Id $filePid -Force -ErrorAction SilentlyContinue
                Write-Host "Daemon process terminated." -ForegroundColor Yellow
            } else {
                Write-Host "Daemon stopped gracefully." -ForegroundColor Green
            }
        } else {
            Write-Host "Daemon process not running. Cleaning up stale PID file." -ForegroundColor Yellow
        }
        Remove-Item -Path $pidFile -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Daemon not running (no PID file)." -ForegroundColor Yellow
    }

    # Clean up stop signal file
    if (Test-Path -LiteralPath $stopSignalFile -PathType Leaf) {
        Remove-Item -Path $stopSignalFile -Force -ErrorAction SilentlyContinue
    }

    # Write final stopped status
    $statusData = @{
        status               = "stopped"
        timestamp            = Get-Timestamp
        uptime_seconds       = 0
        heartbeats_sent      = 0
        messages_received    = 0
        injection_blocked    = 0
        ratification_blocked = 0
        last_activity        = $null
        pid                  = $null
    } | ConvertTo-Json
    $statusData | Out-File -FilePath $statusFile -Encoding UTF8 -Force

    Write-Host "Daemon stopped." -ForegroundColor Green
    exit 0
}

# =====================================================================
# COMMAND: status
# =====================================================================

function Show-DaemonStatus {
    <#
    .SYNOPSIS
      Displays the output contract - daemon status block with counters.
    #>
    $running   = $false
    $daemonPid = $null

    if (Test-Path -LiteralPath $pidFile -PathType Leaf) {
        $filePid = (Get-Content $pidFile -Raw).Trim()
        if ($filePid -and (Get-Process -Id $filePid -ErrorAction SilentlyContinue)) {
            $running   = $true
            $daemonPid = $filePid
        }
    }

    # Read stats from status file
    $hbCount = 0; $msgCount = 0; $injBlocked = 0; $ratBlocked = 0
    $lastActivity   = $null
    $uptimeSeconds  = 0

    if (Test-Path -LiteralPath $statusFile -PathType Leaf) {
        try {
            $json = Get-Content $statusFile -Raw -Encoding UTF8 | ConvertFrom-Json
            $hbCount       = $json.heartbeats_sent
            $msgCount      = $json.messages_received
            $injBlocked    = $json.injection_blocked
            $ratBlocked    = $json.ratification_blocked
            $lastActivity  = $json.last_activity
            $uptimeSeconds = $json.uptime_seconds
        } catch {
            # Corrupted status file - ignore
        }
    }

    Write-Host "=== Yggdrasil Daemon ===" -ForegroundColor Cyan

    if ($running) {
        Write-Host "Status: running" -ForegroundColor Green
    } else {
        Write-Host "Status: stopped" -ForegroundColor Yellow
    }

    $uptime = [TimeSpan]::FromSeconds($uptimeSeconds)
    Write-Host "Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor Gray
    Write-Host "Heartbeats sent: $hbCount" -ForegroundColor Gray
    Write-Host "Messages received: $msgCount" -ForegroundColor Gray
    Write-Host "Injection attempts blocked: $injBlocked" -ForegroundColor Gray
    Write-Host "Ratification attempts blocked: $ratBlocked" -ForegroundColor Gray
    Write-Host "Last activity: $(if ($lastActivity) { $lastActivity } else { '---' })" -ForegroundColor Gray
    Write-Host "PID: $(if ($daemonPid) { $daemonPid } else { '---' })" -ForegroundColor Gray

    exit 0
}

# =====================================================================
# DISPATCH
# =====================================================================

switch ($Command.ToLower()) {
    "start" { Start-DaemonLauncher }
    "stop"  { Stop-Daemon }
    "status" { Show-DaemonStatus }
    "_run"  { Start-DaemonLoop }
    "install" {
        & (Join-Path -Path $scriptDir -ChildPath "ygg-daemon-install.ps1")
        exit $LASTEXITCODE
    }
    "uninstall" {
        & (Join-Path -Path $scriptDir -ChildPath "ygg-daemon-install.ps1") -Uninstall
        exit $LASTEXITCODE
    }
    default {
        Write-Host "Usage: ygg daemon {start|stop|status|install|uninstall}" -ForegroundColor White
        Write-Host ""
        @("start     Launch the daemon in the background",
          "stop      Stop the daemon cleanly",
          "status    Show runtime stats (uptime, message counts, heartbeat count, last activity)",
          "install   Register as a Windows scheduled task (starts at boot)",
          "uninstall Remove the scheduled task") | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Gray
        }
        exit 0
    }
}
