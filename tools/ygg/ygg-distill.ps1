<#
.SYNOPSIS
  Distill durable memory into a compressed profile for the local model tier (<=2K tokens).

.DESCRIPTION
  Reads the three durable memory files (profile.md, goals.md, projects.md) from
  seed/memory/, applies the distillation rules defined in seed/protocols/distill-local.md,
  and writes the compressed output to seed/memory/distilled-local.md.

  Reports token counts before and after for each file, and verifies the total fits within
  2K tokens. Token count is estimated using a whitespace-split word count (rough proxy).

  Exit code 0 on success, non-zero if over budget.

.EXAMPLE
  & "tools/ygg/ygg-distill.ps1"
#>

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")
$seedDir = Join-Path -Path $yggRoot -ChildPath "seed"
$memoryDir = Join-Path -Path $seedDir -ChildPath "memory"
$logDir = Join-Path -Path $memoryDir -ChildPath "log"

$profilePath = Join-Path -Path $memoryDir -ChildPath "profile.md"
$goalsPath = Join-Path -Path $memoryDir -ChildPath "goals.md"
$projectsPath = Join-Path -Path $memoryDir -ChildPath "projects.md"
$outputPath = Join-Path -Path $memoryDir -ChildPath "distilled-local.md"

# ---- Token-counting helper ----
function Get-TokenCount {
    param([string]$Text)
    # Rough estimate: split on whitespace and count resulting tokens
    if ([string]::IsNullOrWhiteSpace($Text)) { return 0 }
    $tokens = $Text -split '\s+' | Where-Object { $_ -ne '' }
    return $tokens.Count
}

# ---- Read source files ----
if (-not (Test-Path -LiteralPath $profilePath -PathType Leaf)) {
    Write-Host "ERROR: profile.md not found at $profilePath" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path -LiteralPath $goalsPath -PathType Leaf)) {
    Write-Host "ERROR: goals.md not found at $goalsPath" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path -LiteralPath $projectsPath -PathType Leaf)) {
    Write-Host "ERROR: projects.md not found at $projectsPath" -ForegroundColor Red
    exit 1
}

$profileRaw = Get-Content -Path $profilePath -Raw -Encoding UTF8
$goalsRaw = Get-Content -Path $goalsPath -Raw -Encoding UTF8
$projectsRaw = Get-Content -Path $projectsPath -Raw -Encoding UTF8

# ---- Token counts before distillation ----
$profileTokensBefore = Get-TokenCount -Text $profileRaw
$goalsTokensBefore = Get-TokenCount -Text $goalsRaw
$projectsTokensBefore = Get-TokenCount -Text $projectsRaw
$totalTokensBefore = $profileTokensBefore + $goalsTokensBefore + $projectsTokensBefore

Write-Host "=== Memory Token Counts (Before Distillation) ===" -ForegroundColor Cyan
Write-Host "  profile.md:    $profileTokensBefore tokens"
Write-Host "  goals.md:      $goalsTokensBefore tokens"
Write-Host "  projects.md:   $projectsTokensBefore tokens"
Write-Host "  TOTAL:         $totalTokensBefore tokens"
Write-Host ""

# ---- Distill profile.md ----
$profileLines = $profileRaw -split "`n"

# Build distilled profile content
$distilledProfile = @()

# Identity section: Name, Address me as, Location, Role
$distilledProfile += "## Profile (distilled)"
$distilledProfile += ""

# Parse the identity table
$inIdentity = $false
$identityData = @{}
foreach ($line in $profileLines) {
    if ($line -match '^\| Name \|') { $inIdentity = $true }
    if ($inIdentity) {
        if ($line -match '^\| (\w[^|]*) \| (.+) \|$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $identityData[$key] = $value
        }
        elseif ($line -match '^\| (\w[^|]*) \|') {
            # Handle multi-word keys
            if ($line -match '^\| ([^|]+) \| ([^|]+) \|$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                $identityData[$key] = $value
            }
        }
        # Stop at next table header or end of table
        if ($line -match '^## ' -and -not ($line -match '^\|')) { break }
    }
}

# Actually let me do this more carefully by scanning for key patterns
# Clear and rebuild
$identityData = @{}
$inTable = $false
$tableRows = @()
foreach ($line in $profileLines) {
    if ($line -match '^\| Fact \| Value \|') {
        $inTable = $true
        continue
    }
    if ($inTable -and $line -match '^\| ') {
        if ($line -match '^\| (.+?) \| (.+?) \|\s*$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $tableRows += @{ Key = $key; Value = $value }
        } elseif ($line -match '^\| (.+?) \| (.+)') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $tableRows += @{ Key = $key; Value = $value }
        }
    } elseif (-not ($line -match '^\|')) {
        if ($inTable) { $inTable = $false }
    }
}

# Extract identity facts
$name = ""; $addressMe = ""; $location = ""; $role = ""; $osShell = ""; $modelRouting = ""; $costPosture = ""
foreach ($row in $tableRows) {
    switch -Regex ($row.Key) {
        '^Name$'          { $name = $row.Value }
        '^Address me as'  { $addressMe = $row.Value }
        '^Location'       { $location = $row.Value }
        '^Role'           { $role = $row.Value }
        '^OS / shell'     { $osShell = $row.Value }
        '^Model routing'  { $modelRouting = $row.Value }
        '^Cost posture'   { $costPosture = $row.Value }
    }
}

$distilledProfile += "- **Name:** $name ($addressMe)"
$distilledProfile += "- **Location:** $location"
$distilledProfile += "- **Role:** $role"
$distilledProfile += "- **OS / shell:** $osShell"
$distilledProfile += "- **Model routing:** $modelRouting"
$distilledProfile += "- **Cost posture:** $costPosture"
$distilledProfile += ""

# Standing instructions 1-8 as single-line summaries
$distilledProfile += "### Standing instructions"
$instructionLines = @()
$inInstructions = $false
$currentNum = 0
foreach ($line in $profileLines) {
    if ($line -match 'Standing instructions') { $inInstructions = $true; continue }
    if ($line -match '^## Standing constraints') { $inInstructions = $false; break }
    if ($inInstructions -and $line -match '^\d+\.\s+\*\*(.+?)\*\*') {
        $currentNum++
        $summary = $matches[1].Trim()
        $instructionLines += "$currentNum. $summary"
    }
}
if ($instructionLines.Count -eq 0) {
    # Fallback: try simpler pattern
    $inInstructions = $false
    foreach ($line in $profileLines) {
        if ($line -match 'Standing instructions') { $inInstructions = $true; continue }
        if ($line -match '^## Standing constraints') { $inInstructions = $false; break }
        if ($inInstructions -and $line -match '^\d+\.\s+(.+?)(?:\.\s|$)') {
            $currentNum++
            $summary = $matches[1].Trim()
            # Trim parenthetical origin citations
            $summary = $summary -replace '\s*\(.*\)\s*$', ''
            $instructionLines += "$currentNum. $summary"
        }
    }
}
foreach ($il in $instructionLines) {
    $distilledProfile += "- $il"
}
$distilledProfile += ""

# Standing constraints as single-line summaries
$distilledProfile += "### Standing constraints"
$constraintLines = @()
$inConstraints = $false
$currentConstraint = ""
foreach ($line in $profileLines) {
    if ($line -match '^## Standing constraints') { $inConstraints = $true; continue }
    if ($inConstraints -and $line -match '^## ') { $inConstraints = $false; break }
    if ($inConstraints) {
        if ($line -match '^- (.+)') {
            # Save any previous multi-line constraint
            if ($currentConstraint) { $constraintLines += "- $currentConstraint" }
            $currentConstraint = $matches[1].Trim()
        } elseif ($line -match '^\s+(.+)$' -and $currentConstraint) {
            # Continuation line of a multi-line constraint
            $currentConstraint += " $($matches[1].Trim())"
        } elseif ([string]::IsNullOrWhiteSpace($line) -and $currentConstraint) {
            # Empty line: save current constraint
            $constraintLines += "- $currentConstraint"
            $currentConstraint = ""
        }
    }
}
# Save last constraint if any
if ($currentConstraint) { $constraintLines += "- $currentConstraint" }
foreach ($cl in $constraintLines) {
    $distilledProfile += $cl
}
$distilledProfile += ""

$distilledProfileText = $distilledProfile -join "`n"

# ---- Distill goals.md ----
$goalsLines = $goalsRaw -split "`n"

$distilledGoals = @()
$distilledGoals += "## Goals (distilled)"
$distilledGoals += ""

# Parse the goals table
$goalsRows = @()
$inGoalsTable = $false
$headerLine = $false
$columns = @()
foreach ($line in $goalsLines) {
    if ($line -match '^\| # \| Goal \|') {
        $headerLine = $true
        $inGoalsTable = $true
        # Parse column indices
        $parts = ($line -split '\|') | ForEach-Object { $_.Trim() }
        $columns = $parts | Where-Object { $_ -ne '' }
        continue
    }
    if ($inGoalsTable -and $line -match '^\| ') {
        $parts = ($line -split '\|') | ForEach-Object { $_.Trim() }
        $parts = $parts | Where-Object { $_ -ne '' }
        if ($parts.Count -ge 3) {
            $goalsRows += @{
                Number = $parts[0]
                Goal   = $parts[1]
                Status = if ($parts.Count -ge 4) { $parts[3] } else { "" }
                BlockedBy = if ($parts.Count -ge 6) { $parts[5] } else { "" }
            }
        }
    } elseif (-not ($line -match '^\|')) {
        if ($inGoalsTable) { $inGoalsTable = $false }
    }
}

$distilledGoals += "| # | Goal | Status |"
$distilledGoals += "|---|---|---|"
foreach ($gr in $goalsRows) {
    $goalText = $gr.Goal
    $statusText = $gr.Status
    # Only include Blocked by if non-empty (handle hyphen, em-dash, and empty as empty markers)
    $emdash = [char]0x2014
    if ($gr.BlockedBy -and $gr.BlockedBy -ne '-' -and $gr.BlockedBy -ne $emdash) {
        $statusText = "$statusText (blocked: $($gr.BlockedBy))"
    }
    $distilledGoals += "| $($gr.Number) | $goalText | $statusText |"
}
$distilledGoals += ""

$distilledGoalsText = $distilledGoals -join "`n"

# ---- Distill projects.md ----
$projectsLines = $projectsRaw -split "`n"

$distilledProjects = @()
$distilledProjects += "## Projects (distilled)"
$distilledProjects += ""

# Parse the projects table
$projectsRows = @()
$inProjectsTable = $false
foreach ($line in $projectsLines) {
    if ($line -match '^\| Project \| Location \|') {
        $inProjectsTable = $true
        continue
    }
    if ($inProjectsTable -and $line -match '^\| ') {
        $parts = ($line -split '\|') | ForEach-Object { $_.Trim() }
        $parts = $parts | Where-Object { $_ -ne '' }
        if ($parts.Count -ge 3) {
            $projectsRows += @{
                Name     = $parts[0]
                Location = $parts[1]
                StatePtr = if ($parts.Count -ge 3) { $parts[2] } else { "" }
                Status   = if ($parts.Count -ge 4) { $parts[3] } else { "" }
            }
        }
    } elseif (-not ($line -match '^\|')) {
        if ($inProjectsTable) { $inProjectsTable = $false }
    }
}

$distilledProjects += "| Project | Location | State pointer | Status |"
$distilledProjects += "|---|---|---|---|"
foreach ($pr in $projectsRows) {
    $distilledProjects += "| $($pr.Name) | $($pr.Location) | $($pr.StatePtr) | $($pr.Status) |"
}
$distilledProjects += ""

$distilledProjectsText = $distilledProjects -join "`n"

# ---- Session digest ----
$digestText = ""
$digestAvailable = $false
if (Test-Path -LiteralPath $logDir -PathType Container) {
    $logFiles = Get-ChildItem -LiteralPath $logDir -Filter "*.md" -File | Sort-Object -Property Name -Descending
    if ($logFiles.Count -gt 0) {
        $latestDigest = $logFiles[0].FullName
        $digestContent = Get-Content -Path $latestDigest -Raw -Encoding UTF8
        $digestAvailable = $true
        $digestText = @"
## Most recent session digest

(from $($logFiles[0].Name))

$digestContent
"@
    }
}

if (-not $digestAvailable) {
    $digestText = @"
## Session digest

No session digests found in seed/memory/log/. This is expected for a fresh seed.
"@
}

# ---- Assemble output ----
$outputLines = @()

$outputLines += "# Distilled Memory Profile - Local Tier"
$outputLines += ""
$outputLines += "> Auto-generated by ygg-distill.ps1 on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')."
$outputLines += "> Conforms to seed/protocols/distill-local.md [SELF-GOVERNANCE]."
$outputLines += ""
$outputLines += "**Budget:** ≤2,000 tokens (local tier)."
$outputLines += ""

# Profile section
$outputLines += $distilledProfileText

# Goals section
$outputLines += $distilledGoalsText

# Projects section
$outputLines += $distilledProjectsText

# Session digest section
$outputLines += $digestText

# Omitted items note
$outputLines += ""
$outputLines += "## Omitted from source files"
$outputLines += ""
$outputLines += "The following were omitted to stay within the 2K token budget per distill-local.md:"
$outputLines += ""
$outputLines += "- **profile.md:** Full environment table (Machines, Editor, Version control, Local inference, View layer), Access details, Communication preferences, epigraph/header quotes, verbose descriptions, origin citations on instructions."
$outputLines += "- **goals.md:** 'Why it matters' column, 'Blocked by' column (when empty), 'Last movement' column, bootstrap rule note."
$outputLines += "- **projects.md:** Notes sections, 'How this file changes' section, 'Last touched' column, self-reference rule note."

$outputText = $outputLines -join "`n"

# ---- Write output ----
$outputDir = Split-Path -Path $outputPath -Parent
if (-not (Test-Path -LiteralPath $outputDir -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Ensure no BOM (UTF8 without BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outputPath, $outputText, $utf8NoBom)

# ---- Token counts after distillation ----
$profileTokensAfter = Get-TokenCount -Text $distilledProfileText
$goalsTokensAfter = Get-TokenCount -Text $distilledGoalsText
$projectsTokensAfter = Get-TokenCount -Text $distilledProjectsText
$digestTokens = Get-TokenCount -Text $digestText
$totalTokensAfter = Get-TokenCount -Text $outputText

Write-Host "=== Memory Token Counts (After Distillation) ===" -ForegroundColor Green
Write-Host "  distilled profile:   $profileTokensAfter tokens"
Write-Host "  distilled goals:     $goalsTokensAfter tokens"
Write-Host "  distilled projects:  $projectsTokensAfter tokens"
Write-Host "  session digest:      $digestTokens tokens"
Write-Host "  TOTAL:               $totalTokensAfter tokens"
Write-Host "  Characters:          $($outputText.Length) chars"
Write-Host ""

Write-Host "=== Budget Verification ===" -ForegroundColor Cyan
Write-Host "  Budget limit: 2,000 tokens"
Write-Host "  Used:         $totalTokensAfter tokens"
Write-Host "  Remaining:    $([math]::Max(0, 2000 - $totalTokensAfter)) tokens"

if ($totalTokensAfter -le 2000) {
    Write-Host "  VERDICT: WITHIN BUDGET" -ForegroundColor Green
    Write-Host ""

    Write-Host "=== Reduction Summary ===" -ForegroundColor Cyan
    Write-Host "  profile.md:    $profileTokensBefore → $profileTokensAfter ($(if ($profileTokensBefore -gt 0) { [math]::Round((1 - $profileTokensAfter / $profileTokensBefore) * 100, 0) } else { 0 })% reduction)"
    Write-Host "  goals.md:      $goalsTokensBefore → $goalsTokensAfter ($(if ($goalsTokensBefore -gt 0) { [math]::Round((1 - $goalsTokensAfter / $goalsTokensBefore) * 100, 0) } else { 0 })% reduction)"
    Write-Host "  projects.md:   $projectsTokensBefore → $projectsTokensAfter ($(if ($projectsTokensBefore -gt 0) { [math]::Round((1 - $projectsTokensAfter / $projectsTokensBefore) * 100, 0) } else { 0 })% reduction)"
    Write-Host "  TOTAL:         $totalTokensBefore → $totalTokensAfter ($(if ($totalTokensBefore -gt 0) { [math]::Round((1 - $totalTokensAfter / $totalTokensBefore) * 100, 0) } else { 0 })% reduction)"
    Write-Host ""
    Write-Host "Distilled profile written to: $outputPath" -ForegroundColor Green
    exit 0
} else {
    Write-Host "  VERDICT: OVER BUDGET by $($totalTokensAfter - 2000) tokens" -ForegroundColor Red
    Write-Host ""
    Write-Host "ERROR: Distilled profile exceeds 2K token budget." -ForegroundColor Red
    exit 2
}
