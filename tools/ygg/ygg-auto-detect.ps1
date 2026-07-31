# ygg-auto-detect.ps1 — Automatic project detection on shell start
<#
.SYNOPSIS
  Detects whether the current directory belongs to a governed project and
  makes it active automatically. Run from the PowerShell profile.
.DESCRIPTION
  When a shell opens in a directory that:
    - is the Yggdrasil seed root, or
    - contains a .ygg-lock or seed\registry marker, or
    - is registered in the machine registry
  this script sets it as the active project. No manual switch needed.
.EXAMPLE
  In $PROFILE: & "C:\projects\yggdrasil\tools\ygg\ygg-auto-detect.ps1"
#>

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot   = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")
$registryPath = Join-Path -Path $yggRoot -ChildPath "seed\registry\projects.json"

# ---- Find the nearest governed root from the current directory ----
$current = (Get-Location).Path

function Test-GovernedRoot {
    param([string]$Dir)
    if (Test-Path (Join-Path $Dir ".ygg-lock")) { return $true }
    if (Test-Path (Join-Path $Dir "seed\registry\projects.json")) { return $true }
    if (Test-Path (Join-Path $Dir ".ygg")) {
        $item = Get-Item (Join-Path $Dir ".ygg") -Force -ErrorAction SilentlyContinue
        if ($item -and -not $item.PSIsContainer) { return $true }
    }
    return $false
}

# Walk up the directory tree looking for a governed root
$probe = $current
$found = $null
while ($probe) {
    if (Test-GovernedRoot -Dir $probe) { $found = $probe; break }
    $parent = Split-Path $probe -Parent
    if ($parent -eq $probe) { break }
    $probe = $parent
}

if (-not $found) {
    # Not inside any governed project - leave the active project as-is
    exit 0
}

# ---- Determine which project this is ----
$projectName = Split-Path $found -Leaf
if ($found -eq $yggRoot) { $projectName = "yggdrasil" }

# ---- Record the active project marker ----
$activeFile = Join-Path -Path $yggRoot -ChildPath "work\active-project.txt"
if (-not (Test-Path (Join-Path $yggRoot "work"))) {
    $null = New-Item -ItemType Directory -Path (Join-Path $yggRoot "work") -Force
}
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($activeFile, $projectName, $utf8NoBom)

# ---- Print confirmation (once per shell, quiet otherwise) ----
if ($env:YGG_QUIET -ne "1") {
    Write-Host ""
    Write-Host "  [ygg] Project: $projectName" -ForegroundColor DarkCyan
    Write-Host "        Root:   $found" -ForegroundColor DarkGray
    Write-Host ""
}

exit 0
