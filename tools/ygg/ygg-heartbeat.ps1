# ygg heartbeat -- P3 daily presence check
<#
.SYNOPSIS
  Performs a daily heartbeat check: goal staleness, pending staging, active unit status.
  Produces a structured daily briefing appended to seed/memory/log/heartbeat-YYYY-MM-DD.md.
.DESCRIPTION
  Usage: ygg heartbeat [--full]

  Default behavior:
    - If no heartbeat has been written today, writes the full structured briefing.
    - If a heartbeat already exists for today, appends only a one-line status entry.

  Flags:
    --full   Always write the full structured briefing, even if one already exists today.

  Checks:
    1. Goal staleness -- goals.md parsed; goals with Last movement > 14 days flagged STALLED.
    2. Pending staging -- staging.md proposals counted; those older than 48h reported.
    3. Active unit status -- SLICES.md read; active unit + open [HUMAN] tasks reported.

  Y09 compliance: writes only to seed/memory/log/. No durable memory files touched.
.EXAMPLE
  ygg heartbeat
.EXAMPLE
  ygg heartbeat --full
#>

# ---- Argument parsing ----
$forceFull = $false
if ($args -contains '--full') {
    $forceFull = $true
}

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")
$seedDir = Join-Path -Path $yggRoot -ChildPath "seed"
$memoryDir = Join-Path -Path $seedDir -ChildPath "memory"
$logDir = Join-Path -Path $memoryDir -ChildPath "log"
$roadmapDir = Join-Path -Path $yggRoot -ChildPath "roadmap"

$today = (Get-Date).ToString('yyyy-MM-dd')
$todayDate = [datetime]::Today

# ---- Utility: parse a markdown table row into trimmed cells ----
function Parse-TableRow {
    param([string]$Line)
    return ($Line.Trim('| ') -split '\|' | ForEach-Object { $_.Trim() })
}

# =====================================================================
# 1. CHECK GOAL STALENESS
# =====================================================================
$goalsPath = Join-Path -Path $memoryDir -ChildPath "goals.md"
$goalsReport = @()

if (Test-Path -LiteralPath $goalsPath -PathType Leaf) {
    $goalsLines = Get-Content -Path $goalsPath -Encoding UTF8
    $inTable = $false
    foreach ($line in $goalsLines) {
        # Detect the table header
        if ($line -match '^\|\s*#\s*\|') { $inTable = $true; continue }
        if (-not $inTable) { continue }
        # Skip separator rows
        if ($line -match '^\|[- :]+\|') { continue }
        # Match data rows
        if ($line -match '^\|.*\|.*\|.*\|') {
            $cells = Parse-TableRow -Line $line
            if ($cells.Count -ge 6) {
                $num        = $cells[0]
                $goalName   = $cells[1]
                $status     = $cells[3]
                $lastMove   = $cells[4]

                if ($lastMove -match '^\d{4}-\d{2}-\d{2}$') {
                    $lastDate = [datetime]::ParseExact($lastMove, 'yyyy-MM-dd', $null)
                    $daysSince = ($todayDate - $lastDate).Days
                    $isStalled = ($status -ne 'done' -and $daysSince -gt 14)
                    $goalsReport += @{
                        Num       = $num
                        Name      = $goalName
                        Status    = $status
                        LastMove  = $lastMove
                        Stalled   = $isStalled
                        DaysSince = $daysSince
                    }
                }
            }
        }
    }
}

# =====================================================================
# 2. CHECK PENDING STAGING ITEMS
# =====================================================================
$stagingPath = Join-Path -Path $memoryDir -ChildPath "staging.md"
$totalProposals = 0
$oldProposals = 0

if (Test-Path -LiteralPath $stagingPath -PathType Leaf) {
    $stagingContent = Get-Content -Path $stagingPath -Raw -Encoding UTF8

    # Find all "### Proposed YYYY-MM-DD" lines
    $proposalMatches = [regex]::Matches($stagingContent, '(?m)^### Proposed (\d{4}-\d{2}-\d{2})')
    $totalProposals = $proposalMatches.Count

    $cutoffDate = $todayDate.AddDays(-2)
    foreach ($match in $proposalMatches) {
        $propDate = [datetime]::ParseExact($match.Groups[1].Value, 'yyyy-MM-dd', $null)
        if ($propDate -lt $cutoffDate) {
            $oldProposals++
        }
    }
}

# =====================================================================
# 3. CHECK ACTIVE UNIT STATUS
# =====================================================================
$slicesPath = Join-Path -Path $roadmapDir -ChildPath "SLICES.md"
$activeUnit = $null
$humanTasks = @()

if (Test-Path -LiteralPath $slicesPath -PathType Leaf) {
    $slicesLines = Get-Content -Path $slicesPath -Encoding UTF8
    $inSliceTable = $false
    $foundUnits = @()

    foreach ($line in $slicesLines) {
        if ($line -match '^\|\s*Unit\s*\|') { $inSliceTable = $true; continue }
        if (-not $inSliceTable) { continue }
        if ($line -match '^\|[- :]+\|') { continue }
        if ($line -match '^\|.*\|.*\|.*\|') {
            $cells = Parse-TableRow -Line $line
            if ($cells.Count -ge 4) {
                $unitId   = $cells[0]
                $unitFile = $cells[1] -replace '^`(.*)`$', '$1'
                $unitObj  = $cells[2]
                $unitStatus = $cells[3]
                $foundUnits += @{
                    Id     = $unitId
                    File   = $unitFile
                    Name   = $unitObj
                    Status = $unitStatus
                }
            }
        }
    }

    # Find the active unit -- the highest-numbered unit that is "In Progress"
    # and whose file exists.
    for ($i = $foundUnits.Count - 1; $i -ge 0; $i--) {
        if ($foundUnits[$i].Status -eq 'In Progress') {
            $unitFilePath = Join-Path -Path $roadmapDir -ChildPath $foundUnits[$i].File
            if (Test-Path -LiteralPath $unitFilePath -PathType Leaf) {
                $activeUnit = $foundUnits[$i]
                $activeUnit.FilePath = $unitFilePath
                break
            }
        }
    }
}

# Parse [HUMAN] tasks from the active unit file
if ($activeUnit) {
    $unitContent = Get-Content -Path $activeUnit.FilePath -Encoding UTF8
    foreach ($line in $unitContent) {
        # Match: - [ ] <id> **[HUMAN]** <name> -- ...
        if ($line -match '^\s*-\s*\[\s*\]\s+(\S+)\s+\*\*\[HUMAN\]\*\*\s+(.*?)\s*(?:\u2014|$|\[)') {
            $taskId = $matches[1]
            $taskName = $matches[2]
            $humanTasks += @{
                Id   = $taskId
                Name = $taskName
            }
        }
    }
}

# =====================================================================
# 4. COMPUTE SUMMARY VALUES (for one-line format)
# =====================================================================
$stalledCount = 0
foreach ($g in $goalsReport) {
    if ($g.Stalled) { $stalledCount++ }
}
$activeUnitName = if ($activeUnit) { $activeUnit.Id } else { 'none' }
$now = Get-Date
$oneLine = "{0} -- heartbeat | active: {1} | goals: {2} stalled | staging: {3} | human: {4}" -f `
    $now.ToString('HH:mm'), $activeUnitName, $stalledCount, $totalProposals, $humanTasks.Count

# =====================================================================
# 5. BUILD THE FULL BRIEFING
# =====================================================================
$briefingLines = @()
$briefingLines += "=== Daily Briefing ==="
$briefingLines += "Date: $today"

if ($activeUnit) {
    $briefingLines += "Active unit: $($activeUnit.Id) -- $($activeUnit.Status)"
} else {
    $briefingLines += "Active unit: (none) -- Not Started"
}

$briefingLines += ""
$briefingLines += "--- Goals ---"

if ($goalsReport.Count -eq 0) {
    $briefingLines += "(no goals found)"
} else {
    foreach ($g in $goalsReport) {
        $stalledTag = if ($g.Stalled) { ' STALLED' } else { '' }
        $briefingLines += "$($g.Num): $($g.Name) -- $($g.Status) (last movement: $($g.LastMove))$stalledTag"
    }
}

$briefingLines += ""
$briefingLines += "--- Staging ---"
$briefingLines += "Pending proposals: $totalProposals"
$briefingLines += "Older than 48h: $oldProposals"

$briefingLines += ""
$briefingLines += "--- Open [HUMAN] tasks ---"

if ($humanTasks.Count -eq 0) {
    $briefingLines += "(none)"
} else {
    foreach ($t in $humanTasks) {
        $briefingLines += "$($t.Id): $($t.Name)"
    }
}

$briefingLines += ""
$briefingLines += "=== End Briefing ==="

$briefingText = $briefingLines -join "`r`n"

# =====================================================================
# 6. WRITE TO LOG (with idempotency guard)
# =====================================================================
$logFile = Join-Path -Path $logDir -ChildPath "heartbeat-$today.md"

# Ensure log directory exists
if (-not (Test-Path -LiteralPath $logDir -PathType Container)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$fileExistsBefore = Test-Path -LiteralPath $logFile -PathType Leaf

if ($forceFull -or -not $fileExistsBefore) {
    # First heartbeat of the day (or --full forced): write full structured briefing
    $textToWrite = $briefingText
    $isFullBriefing = $true
} else {
    # Subsequent heartbeat today: append one-line status only
    $textToWrite = $oneLine
    $isFullBriefing = $false
}

# Add a blank line separator if the log file already has content
$separator = ""
if ($fileExistsBefore) {
    $existing = Get-Content -Path $logFile -Raw -Encoding UTF8
    if (-not [string]::IsNullOrWhiteSpace($existing)) {
        $separator = "`r`n"
    }
}

Add-Content -Path $logFile -Value "$separator$textToWrite" -Encoding UTF8

# =====================================================================
# 7. SEND NOTIFICATIONS (if configured)
# =====================================================================
# Reads environment variables to detect configured channels.
# No channel = log-only mode (no errors, no warnings).

# --- Telegram ---
# Check process-level ($env:) first, then fall back to User scope (persistent)
$tgToken = if ($env:TELEGRAM_BOT_TOKEN) { $env:TELEGRAM_BOT_TOKEN } else { [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "User") }
$tgChatId = if ($env:TELEGRAM_CHAT_ID) { $env:TELEGRAM_CHAT_ID } else { [Environment]::GetEnvironmentVariable("TELEGRAM_CHAT_ID", "User") }
if ($tgToken -and $tgChatId) {
    $tgBody = @{ chat_id = $tgChatId; text = $textToWrite } | ConvertTo-Json
    try {
        $tgResponse = Invoke-RestMethod -Uri "https://api.telegram.org/bot$tgToken/sendMessage" `
            -Method Post -ContentType "application/json" -Body $tgBody -ErrorAction Stop
        Write-Host "  Telegram notification sent" -ForegroundColor DarkCyan
    } catch {
        Write-Host "  Telegram notification failed: $_" -ForegroundColor DarkYellow
    }
}

# --- ntfy.sh ---
$ntfyTopic = if ($env:NTFY_TOPIC) { $env:NTFY_TOPIC } else { [Environment]::GetEnvironmentVariable("NTFY_TOPIC", "User") }
if ($ntfyTopic) {
    try {
        $null = Invoke-RestMethod -Uri "https://ntfy.sh/$ntfyTopic" `
            -Method Post -Body $textToWrite -ErrorAction Stop
        Write-Host "  ntfy.sh notification sent" -ForegroundColor DarkCyan
    } catch {
        Write-Host "  ntfy.sh notification failed: $_" -ForegroundColor DarkYellow
    }
}

# --- Discord ---
$discordWebhook = if ($env:DISCORD_WEBHOOK) { $env:DISCORD_WEBHOOK } else { [Environment]::GetEnvironmentVariable("DISCORD_WEBHOOK", "User") }
if ($discordWebhook) {
    $discordBody = @{ content = $textToWrite } | ConvertTo-Json
    try {
        $null = Invoke-RestMethod -Uri $discordWebhook `
            -Method Post -ContentType "application/json" -Body $discordBody -ErrorAction Stop
        Write-Host "  Discord notification sent" -ForegroundColor DarkCyan
    } catch {
        Write-Host "  Discord notification failed: $_" -ForegroundColor DarkYellow
    }
}

# =====================================================================
# 8. OUTPUT TO CONSOLE
# =====================================================================
Write-Host ""
Write-Host $textToWrite -ForegroundColor Cyan
Write-Host ""
Write-Host "Heartbeat written to: $logFile" -ForegroundColor Green
if ($isFullBriefing) {
    Write-Host "Full daily briefing written" -ForegroundColor DarkCyan
} else {
    Write-Host "One-line status appended (full briefing already written today)" -ForegroundColor DarkCyan
}
if ($tgToken -or $ntfyTopic -or $discordWebhook) {
    Write-Host "Notifications sent via configured channel(s)" -ForegroundColor DarkCyan
} else {
    Write-Host "No notification channel configured (log-only mode)" -ForegroundColor DarkGray
}
Write-Host ""

# =====================================================================
# 9. EXIT CLEANLY
# =====================================================================
exit 0
