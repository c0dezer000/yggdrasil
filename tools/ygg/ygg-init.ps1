# ygg-init.ps1 - Initialize a new governed project
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

if (-not $Name) {
    Write-Host "Usage: ygg init <project-name> [path]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Creates a new project directory and registers it." -ForegroundColor Gray
    Write-Host "Stops at Gate 1 - no artifacts created until plan approval." -ForegroundColor Yellow
    exit 1
}

# Default path: sibling directory
if (-not $Path) {
    $parentDir = Split-Path -Path $yggRoot -Parent
    $Path = Join-Path -Path $parentDir -ChildPath $Name
}

# Validate path is not inside an existing project
if (Test-Path -LiteralPath $Path) {
    $existingYgg = Join-Path -Path $Path -ChildPath ".ygg"
    if (Test-Path -LiteralPath $existingYgg) {
        Write-Host "Directory already contains a Yggdrasil project: $Path" -ForegroundColor Red
        exit 1
    }
}

$projId = $Name.ToLower() -replace "[^a-z0-9-]", "-"

Write-Host "ygg init - New Project" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Name: $Name" -ForegroundColor White
Write-Host "  ID:   $projId" -ForegroundColor White
Write-Host "  Path: $Path" -ForegroundColor White
Write-Host ""

# Create the project directory
if (-not (Test-Path -LiteralPath $Path)) {
    $null = New-Item -ItemType Directory -Path $Path -Force
    Write-Host "  Created directory: $Path" -ForegroundColor Green
} else {
    Write-Host "  Using existing directory: $Path" -ForegroundColor Gray
}

# Create .ygg pointer
$yggPointer = Join-Path -Path $Path -ChildPath ".ygg"
Write-Utf8NoBom -Path $yggPointer -Content $Path
Write-Host "  Created .ygg pointer" -ForegroundColor Green

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
    Write-Host "  Project already registered: $projId" -ForegroundColor Yellow
} else {
    # Get current kernel version
    $kernelVer = ""
    if (Test-Path -LiteralPath $lockFile) {
        $lock = Get-Content -LiteralPath $lockFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($lock -is [array] -and $lock.Count -gt 0) {
            $firstPath = $lock[0].path
            $parts = $firstPath -split "\\"
            foreach ($p in $parts) {
                if ($p -like "kernel-*") { $kernelVer = $p -replace "^kernel-", ""; break }
            }
        }
    }

    $newProj = @{
        id          = $projId
        name        = $Name
        path        = (Resolve-Path -LiteralPath $Path).Path
        kernel      = $kernelVer
        status      = "importing"
        last_active = (Get-Date).ToString("yyyy-MM-dd")
        governed    = $false
    }
    $reg.projects = @($reg.projects) + @($newProj)
    $json = $reg | ConvertTo-Json -Depth 10
    Write-Utf8NoBom -Path $registryFile -Content $json
    Write-Host "  Registered in seed/registry/projects.json" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host " STOPPED AT GATE 1 - PLAN APPROVAL" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "The project directory has been created and registered." -ForegroundColor White
Write-Host "No governance artifacts have been created." -ForegroundColor White
Write-Host ""
Write-Host "Next steps (require gardener approval):" -ForegroundColor Gray
Write-Host "  1. Define project scope and objectives" -ForegroundColor Gray
Write-Host "  2. Pass Gate 1 (Plan Approval)" -ForegroundColor Gray
Write-Host "  3. Pass Gate 2 (Naming Confirmation)" -ForegroundColor Gray
Write-Host "  4. Run ygg import to continue onboarding" -ForegroundColor Gray
Write-Host ""
Write-Host "See seed/protocols/onboard.md for the full onboarding protocol." -ForegroundColor DarkGray
exit 0
