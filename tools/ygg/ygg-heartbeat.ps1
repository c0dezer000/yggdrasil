# ygg heartbeat — P3 daily presence check
<#
.SYNOPSIS
  Performs a daily heartbeat check: goal staleness, pending staging, active unit status.
  Produces a structured daily briefing appended to seed/memory/log/heartbeat-YYYY-MM-DD.md.
.DESCRIPTION
  Usage: ygg heartbeat

  Checks:
    1. Goal staleness — goals.md parsed; goals with Last movement > 14 days flagged STALLED.
    2. Pending staging — staging.md proposals counted; those older than 48h reported.
    3. Active unit status — SLICES.md read; active unit + open [HUMAN] tasks reported.

  Y09 compliance: writes only to seed/memory/log/. No durable memory files touched.
.EXAMPLE
  ygg heartbeat
#>

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

    # Find the active unit — the highest-numbered unit that is "In Progress"
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
        # Match: - [ ] <id> **[HUMAN]** <name> — ...
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
# 4. BUILD THE BRIEFING
# =====================================================================
$briefingLines = @()
$dash = [char]0x2014
$briefingLines += "=== Daily Briefing ==="
$briefingLines += "Date: $today"

if ($activeUnit) {
    $briefingLines += "Active unit: $($activeUnit.Id) $dash $($activeUnit.Status)"
} else {
    $briefingLines += "Active unit: (none) $dash Not Started"
}

$briefingLines += ""
$briefingLines += "--- Goals ---"

if ($goalsReport.Count -eq 0) {
    $briefingLines += "(no goals found)"
} else {
    foreach ($g in $goalsReport) {
        $stalledTag = if ($g.Stalled) { ' STALLED' } else { '' }
        $briefingLines += "$($g.Num): $($g.Name) $dash $($g.Status) (last movement: $($g.LastMove))$stalledTag"
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

$briefing = $briefingLines -join "`r`n"

# =====================================================================
# 5. WRITE TO LOG
# =====================================================================
$logFile = Join-Path -Path $logDir -ChildPath "heartbeat-$today.md"

# Ensure log directory exists
if (-not (Test-Path -LiteralPath $logDir -PathType Container)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Add a blank line separator if the log file already has content
$separator = ""
if (Test-Path -LiteralPath $logFile -PathType Leaf) {
    $existing = Get-Content -Path $logFile -Raw -Encoding UTF8
    if (-not [string]::IsNullOrWhiteSpace($existing)) {
        $separator = "`r`n"
    }
}

Add-Content -Path $logFile -Value "$separator$briefing" -Encoding UTF8

# =====================================================================
# 6. OUTPUT TO CONSOLE
# =====================================================================
Write-Host ""
Write-Host $briefing -ForegroundColor Cyan
Write-Host ""
Write-Host "Heartbeat written to: $logFile" -ForegroundColor Green
Write-Host ""

# =====================================================================
# 7. EXIT CLEANLY
# =====================================================================
exit 0
