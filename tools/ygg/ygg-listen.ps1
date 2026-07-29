# ygg listen ??? Telegram inbound listener for P3 always-on presence
<#
.SYNOPSIS
  Telegram inbound listener for P3 always-on presence.
.DESCRIPTION
  Polls Telegram's getUpdates API every 10 seconds using the bot token from
  $env:TELEGRAM_BOT_TOKEN. Processes each message through:
    Stage 1 ??? Y10 check: ratification refusal
    Stage 2 ??? Y04 check: injection detection
    Stage 3 ??? Route legitimate messages (status/briefing, doctor, who are you)

  Y09 compliant: writes only to seed/memory/log/.
  Bot token is a secret ??? never printed, logged, or quoted.

  Exit cleanly on Ctrl+C or stop-signal file (.listen-stop) at the project root.

.EXAMPLE
  ygg listen
#>

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")
$seedDir = Join-Path -Path $yggRoot -ChildPath "seed"
$memoryDir = Join-Path -Path $seedDir -ChildPath "memory"
$logDir = Join-Path -Path $memoryDir -ChildPath "log"
$stopSignalFile = Join-Path -Path $yggRoot -ChildPath ".listen-stop"

# =====================================================================
# TOKEN RETRIEVAL ??? same pattern as ygg-heartbeat.ps1
# =====================================================================
$tgToken = if ($env:TELEGRAM_BOT_TOKEN) { $env:TELEGRAM_BOT_TOKEN } else { [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "User") }
if (-not $tgToken) {
    Write-Host "ERROR: TELEGRAM_BOT_TOKEN not set. Set it as an environment variable (process or User scope)." -ForegroundColor Red
    exit 1
}

# =====================================================================
# STATE
# =====================================================================
$script:messagesProcessed   = 0
$script:injectionBlocked    = 0
$script:ratificationBlocked = 0
$script:lastActivity        = $null
$script:shutdownRequested   = $false
$pollOffset                 = 0
$pollIntervalSeconds        = 10

# =====================================================================
# IDENTITY CACHE (read once, used for "who are you")
# =====================================================================
$script:identityName     = "Odin"
$script:identitySummary  = "I am Odin, a governed companion serving the gardener. I send alerts and respond to: status, briefing, doctor, who are you."
$identityPath = Join-Path -Path $seedDir -ChildPath "constitution\identity.md"
if (Test-Path -LiteralPath $identityPath -PathType Leaf) {
    $idContent = Get-Content -Path $identityPath -Raw -Encoding UTF8
    if ($idContent -match '^\*\*(\w+)\.\*\*') { $script:identityName = $matches[1] }
    $gardenerMatch = if ($idContent -match '\*\*Gardener:\*\*\s*(\S+)') { $matches[1] } else { "the gardener" }
    $script:identitySummary = "I am $($script:identityName), a governed companion serving $gardenerMatch. I send alerts and respond to: status, briefing, doctor, who are you."
}

# =====================================================================
# CTRL+C HANDLER
# =====================================================================
try {
    $null = Register-ObjectEvent -InputObject ([Console]) -EventName CancelKeyPress -Action {
        $global:shutdownRequested = $true
    } -SupportEvent -ErrorAction SilentlyContinue
} catch {
    # Ctrl+C handling not available on this host ??? stop-signal file still works
}

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
      Y09 compliant ??? writes only to seed/memory/log/.
    #>
    param([string]$MessageText, [string]$FromUser, [string]$Stage)

    $today   = (Get-Date).ToString('yyyy-MM-dd')
    $logFile = Join-Path -Path $logDir -ChildPath "listener-$today.md"

    if (-not (Test-Path -LiteralPath $logDir -PathType Container)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $timestamp = Get-Timestamp
    $entry     = "- $timestamp | from: $FromUser | stage: $Stage | text: $MessageText"

    if (Test-Path -LiteralPath $logFile -PathType Leaf) {
        Add-Content -Path $logFile -Value "`r`n$entry" -Encoding UTF8
    } else {
        Set-Content -Path $logFile -Value $entry -Encoding UTF8
    }
}

function Send-TelegramMessage {
    <#
    .SYNOPSIS
      Sends a reply message via Telegram Bot API.
      Bot token is used in the URL but never printed or logged.
    #>
    param([string]$ChatId, [string]$Text)

    if (-not $tgToken) { return }

    $body = @{ chat_id = $ChatId; text = $Text } | ConvertTo-Json
    try {
        $null = Invoke-RestMethod -Uri "https://api.telegram.org/bot${tgToken}/sendMessage" `
            -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
    } catch {
        Write-Host "  [WARN] sendMessage failed" -ForegroundColor DarkYellow
    }
}

function Test-InjectionAttempt {
    <#
    .SYNOPSIS
      Y04 check ??? detects embedded instruction patterns.
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
      Y10 check ??? detects ratification attempt patterns.
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

function Process-Message {
    <#
    .SYNOPSIS
      Processes a single Telegram message through the Y10 ??? Y04 ??? routing pipeline.
    #>
    param([string]$Text, [string]$ChatId, [int]$UpdateId)

    # ---- Stage 1: Y10 check ??? ratification refusal ----
    if (Test-RatificationAttempt -Text $Text) {
        Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "blocked-y10"
        $script:ratificationBlocked++
        $script:lastActivity = Get-Timestamp
        Send-TelegramMessage -ChatId $ChatId -Text "Remote ratification is not honoured per Y10. Valid channels: local session or version-control commit."
        return
    }

    # ---- Stage 2: Y04 check ??? injection detection ----
    if (Test-InjectionAttempt -Text $Text) {
        # Check for explicit disclaimer (allows Y04 testing)
        if (Test-Y04Disclaimer -Text $Text) {
            Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "y04-disclaimed"
            # Continue to routing
        } else {
            Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "blocked-y04"
            $script:injectionBlocked++
            $script:lastActivity = Get-Timestamp
            Send-TelegramMessage -ChatId $ChatId -Text "Embedded instructions detected and refused. Content treated as untrusted per Y04."
            return
        }
    }

    # ---- Stage 3: Route legitimate messages ----
    $script:messagesProcessed++
    $script:lastActivity = Get-Timestamp
    Write-MessageLog -MessageText $Text -FromUser $ChatId -Stage "processed"

    $lowerText = $Text.ToLower().Trim()

    # Status / Briefing ??? run heartbeat and reply with briefing
    if ($lowerText -eq 'status' -or $lowerText -eq 'briefing') {
        Write-Host "  Processing status/briefing request from $ChatId" -ForegroundColor DarkCyan
        $heartbeatScript = Join-Path -Path $scriptDir -ChildPath "ygg-heartbeat.ps1"
        if (Test-Path -LiteralPath $heartbeatScript -PathType Leaf) {
            try {
                # Capture all output streams (Write-Host ??? information stream 6)
                $output = & $heartbeatScript --full *>&1 | Out-String
                Send-TelegramMessage -ChatId $ChatId -Text $output
            } catch {
                Send-TelegramMessage -ChatId $ChatId -Text "Heartbeat failed: $($_.Exception.Message)"
            }
        } else {
            Send-TelegramMessage -ChatId $ChatId -Text "Heartbeat script not found."
        }
        return
    }

    # Doctor ??? run ygg doctor and reply with summary
    if ($lowerText -eq 'doctor') {
        Write-Host "  Processing doctor request from $ChatId" -ForegroundColor DarkCyan
        $doctorScript = Join-Path -Path $scriptDir -ChildPath "ygg-doctor.ps1"
        if (Test-Path -LiteralPath $doctorScript -PathType Leaf) {
            try {
                $output = & $doctorScript *>&1 | Out-String
                Send-TelegramMessage -ChatId $ChatId -Text $output
            } catch {
                Send-TelegramMessage -ChatId $ChatId -Text "Doctor check failed: $($_.Exception.Message)"
            }
        } else {
            Send-TelegramMessage -ChatId $ChatId -Text "Doctor script not found."
        }
        return
    }

    # Who are you ??? identity summary
    if ($lowerText -match '^who are you' -or $lowerText -eq 'who are you?' -or $lowerText -eq 'who are you') {
        Send-TelegramMessage -ChatId $ChatId -Text $script:identitySummary
        return
    }

    # Default ??? unrecognised command
    Send-TelegramMessage -ChatId $ChatId -Text "Message received. I can respond to: status, briefing, doctor, who are you. Other commands require an interactive session."
}

function Show-Status {
    <#
    .SYNOPSIS
      Displays the output contract ??? status block with counters.
    #>
    $status = if ($script:shutdownRequested) { 'stopped' } else { 'running' }
    $lastActivityStr = if ($script:lastActivity) { $script:lastActivity } else { '???' }

    Write-Host "=== Telegram Listener ===" -ForegroundColor Cyan
    switch ($status) {
        'running' { Write-Host "Status: running" -ForegroundColor Green }
        'stopped' { Write-Host "Status: stopped" -ForegroundColor Yellow }
        default   { Write-Host "Status: error" -ForegroundColor Red }
    }
    Write-Host "Poll interval: ${pollIntervalSeconds}s" -ForegroundColor Gray
    Write-Host "Messages processed: $($script:messagesProcessed)" -ForegroundColor Gray
    Write-Host "Injection attempts blocked: $($script:injectionBlocked)" -ForegroundColor Gray
    Write-Host "Ratification attempts blocked: $($script:ratificationBlocked)" -ForegroundColor Gray
    Write-Host "Last activity: $lastActivityStr" -ForegroundColor Gray
}

# =====================================================================
# MAIN LOOP
# =====================================================================
Write-Host "=== Telegram Listener ===" -ForegroundColor Cyan
Write-Host "Polling every ${pollIntervalSeconds}s. Stop with Ctrl+C or .listen-stop file." -ForegroundColor DarkCyan
Write-Host ""

while (-not $script:shutdownRequested) {
    # ---- Check stop signal file ----
    if (Test-Path -LiteralPath $stopSignalFile -PathType Leaf) {
        Write-Host "`nStop signal file detected (.listen-stop). Exiting." -ForegroundColor Yellow
        break
    }

    # ---- Poll Telegram getUpdates API ----
    $updatesUrl = "https://api.telegram.org/bot${tgToken}/getUpdates"
    try {
        $response = Invoke-RestMethod -Uri $updatesUrl `
            -Method Post `
            -Body @{ offset = $pollOffset } `
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
                    Write-Host "  $(Get-Timestamp) ??? Message from $chatId : $displayText" -ForegroundColor DarkGray
                    Process-Message -Text $text -ChatId $chatId -UpdateId $update.update_id
                }
            }

            # Advance offset past the highest update ID to mark messages as read
            if ($maxId -gt 0) {
                $pollOffset = $maxId + 1
            }
        }
    } catch [System.Net.WebException] {
        if ($null -ne $_.Exception.Response -and $_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::Unauthorized) {
            Write-Host "  [ERROR] Invalid Telegram bot token (401)" -ForegroundColor Red
            break
        }
        Write-Host "  [WARN] Telegram API request failed" -ForegroundColor DarkYellow
    } catch {
        Write-Host "  [WARN] Telegram poll failed" -ForegroundColor DarkYellow
    }

    # ---- Wait (second-by-second to stay responsive to shutdown signals) ----
    for ($i = 0; $i -lt $pollIntervalSeconds; $i++) {
        if ($script:shutdownRequested) { break }
        if (Test-Path -LiteralPath $stopSignalFile -PathType Leaf) {
            $script:shutdownRequested = $true
            break
        }
        Start-Sleep -Seconds 1
    }
}

# =====================================================================
# CLEAN EXIT
# =====================================================================
Write-Host ""
Show-Status
$ts = Get-Timestamp; Write-Host "Listener stopped at $ts" -ForegroundColor Green
exit 0
