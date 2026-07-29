# ygg-session-state.ps1 - update or clear the ephemeral session-state file
# Invoked via: .\tools\ygg\ygg.cmd session-state --update "<content>" | --clear

# DR1: path computed from $PSScriptRoot alone
$repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$workDir = Join-Path -Path $repoRoot -ChildPath "work"
$targetPath = Join-Path -Path $workDir -ChildPath "session-state.md"

# DR2: verify parent and leaf
$resolvedParent = Split-Path -Path $targetPath -Parent
$leaf = Split-Path -Path $targetPath -Leaf
if ($resolvedParent -ne $workDir -or $leaf -ne 'session-state.md') {
    Write-Host "session-state: path safety check failed" -ForegroundColor Red
    exit 1
}

# DR6: never create work/
if (-not (Test-Path -LiteralPath $workDir -PathType Container)) {
    Write-Host "session-state: work/ directory not found; refusing to write" -ForegroundColor Red
    exit 1
}

# DR5: header constants (source of truth for the five Item-1 literals)
$headerLines = @(
    '# Ephemeral session state'
    ''
    'Overwritten in place, never appended.'
    'Not a durable-memory path.'
    'Durable facts route through seed/memory/staging.md and two-step ratification.'
    ''
    'Intent only: this file does not restate active unit, goal staleness, staging counts, or open human-tagged tasks.'
)
$headerText = $headerLines -join "`n"

# Usage
function Write-Usage {
    Write-Host "Usage: ygg session-state --update `"<content>`"" -ForegroundColor White
    Write-Host "       ygg session-state --clear" -ForegroundColor White
}

# DR3: parse verbs
$hasUpdate = $false
$hasClear = $false
$content = $null
$i = 0
while ($i -lt $args.Count) {
    $a = $args[$i]
    if ($a -eq '--update') {
        $hasUpdate = $true
        $i++
        if ($i -lt $args.Count) {
            $content = $args[$i]
            $i++
        }
    } elseif ($a -eq '--clear') {
        $hasClear = $true
        $i++
    } else {
        Write-Host "session-state: unknown argument: $a" -ForegroundColor Red
        Write-Usage
        exit 1
    }
}

# DR3: verb allowlist
if ($hasUpdate -and $hasClear) {
    Write-Host "session-state: --update and --clear are mutually exclusive" -ForegroundColor Red
    Write-Usage
    exit 1
}
if (-not $hasUpdate -and -not $hasClear) {
    Write-Host "session-state: specify --update or --clear" -ForegroundColor Red
    Write-Usage
    exit 1
}

# DR4: missing or whitespace-only content
if ($hasUpdate) {
    if ($null -eq $content -or ($content.Trim().Length -eq 0)) {
        Write-Host "session-state: --update requires non-empty content" -ForegroundColor Red
        exit 1
    }
}

# Build full content string before opening the target (DR7)
if ($hasUpdate) {
    $fullText = $headerText + "`n`n" + $content
} else {
    $fullText = $headerText
}

# DR7: write with UTF-8 no BOM, complete content built before target opened
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($targetPath, $fullText, $utf8NoBom)

if ($hasUpdate) {
    Write-Host "session-state: updated" -ForegroundColor Green
} else {
    Write-Host "session-state: cleared" -ForegroundColor Green
}

# DR8: explicit exit
exit 0
