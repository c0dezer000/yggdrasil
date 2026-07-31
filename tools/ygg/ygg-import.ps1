# ygg-import.ps1 - Import an existing project into governance
[CmdletBinding()]
param(
    [Parameter(Position=0)][string]$Name = "",
    [Parameter(Position=1)][string]$Path = ""
)

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot   = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")
$registryFile = Join-Path -Path $yggRoot -ChildPath "seed\registry\projects.json"
$lockFile     = Join-Path -Path $yggRoot -ChildPath ".ygg-lock"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

if (-not $Path) {
    Write-Host "Usage: ygg import <project-name> <path>" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Registers an existing directory as a governed project." -ForegroundColor Gray
    Write-Host "Creates seed.lock pointing at the current kernel." -ForegroundColor Gray
    Write-Host "Stops at the onboarding human correction pass." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Host "Path does not exist: $Path" -ForegroundColor Red
    exit 1
}

$Path = (Resolve-Path -LiteralPath $Path).Path
$projId = $Name.ToLower() -replace "[^a-z0-9-]", "-"

Write-Host "ygg import - Import Existing Project" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Name: $Name" -ForegroundColor White
Write-Host "  ID:   $projId" -ForegroundColor White
Write-Host "  Path: $Path" -ForegroundColor White
Write-Host ""

# Create .ygg pointer if not present
$yggPointer = Join-Path -Path $Path -ChildPath ".ygg"
if (-not (Test-Path -LiteralPath $yggPointer)) {
    Write-Utf8NoBom -Path $yggPointer -Content $Path
    Write-Host "  Created .ygg pointer" -ForegroundColor Green
} else {
    Write-Host "  .ygg pointer already exists" -ForegroundColor Gray
}

# Create seed.lock pointing at current kernel
$targetLock = Join-Path -Path $Path -ChildPath ".ygg-lock"
if (Test-Path -LiteralPath $lockFile) {
    $lockContent = Get-Content -LiteralPath $lockFile -Raw -Encoding UTF8
    Write-Utf8NoBom -Path $targetLock -Content $lockContent
    Write-Host "  Created .ygg-lock (bound to current kernel)" -ForegroundColor Green

    # Extract kernel version
    $kernelVer = ""
    $lock = $lockContent | ConvertFrom-Json
    if ($lock -is [array] -and $lock.Count -gt 0) {
        $firstPath = $lock[0].path
        $parts = $firstPath -split "\\"
        foreach ($p in $parts) {
            if ($p -like "kernel-*") { $kernelVer = $p -replace "^kernel-", ""; break }
        }
    }
} else {
    Write-Host "  WARNING: No kernel lock found in seed installation" -ForegroundColor Yellow
    $kernelVer = ""
}

# Register in registry
$reg = $null
if (Test-Path -LiteralPath $registryFile) {
    $raw = Get-Content -LiteralPath $registryFile -Raw -Encoding UTF8
    $reg = $raw | ConvertFrom-Json
} else {
    $reg = @{ version = 1; projects = @() }
}

$existing = $reg.projects | Where-Object { $_.id -eq $projId }
if ($existing) {
    # Update existing entry
    foreach ($p in $reg.projects) {
        if ($p.id -eq $projId) {
            $p.path = $Path
            $p.kernel = $kernelVer
            $p.status = "importing"
            $p.last_active = (Get-Date).ToString("yyyy-MM-dd")
        }
    }
    Write-Host "  Updated existing registry entry" -ForegroundColor Green
} else {
    $newProj = @{
        id          = $projId
        name        = $Name
        path        = $Path
        kernel      = $kernelVer
        status      = "importing"
        last_active = (Get-Date).ToString("yyyy-MM-dd")
        governed    = $false
    }
    $reg.projects = @($reg.projects) + @($newProj)
    Write-Host "  Registered in seed/registry/projects.json" -ForegroundColor Green
}

$json = $reg | ConvertTo-Json -Depth 10
Write-Utf8NoBom -Path $registryFile -Content $json

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host " STOPPED AT HUMAN CORRECTION PASS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "The project has been registered and bound to the kernel." -ForegroundColor White
Write-Host ""
Write-Host "Per seed/protocols/onboard.md, the next step is the mandatory" -ForegroundColor White
Write-Host "human correction pass (step 5). This requires the gardener to:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Review the project's existing files and conventions" -ForegroundColor Gray
Write-Host "  2. Correct any misclassifications or misunderstandings" -ForegroundColor Gray
Write-Host "  3. Approve the project profile and initial conventions" -ForegroundColor Gray
Write-Host "  4. Ratify the project in seed/memory/projects.md" -ForegroundColor Gray
Write-Host ""
Write-Host "No autonomous work may proceed until this pass is complete." -ForegroundColor Yellow
Write-Host ""
Write-Host "To continue after the correction pass:" -ForegroundColor Gray
Write-Host "  ygg switch $projId" -ForegroundColor Cyan
exit 0
