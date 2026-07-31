# ygg-projects.ps1 - Project registry management
[CmdletBinding()]
param(
    [Parameter(Position=0)][string]$Command = "",
    [Parameter(Position=1)][string]$Arg1 = "",
    [Parameter(Position=2)][string]$Arg2 = ""
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

function Read-Registry {
    if (-not (Test-Path -LiteralPath $registryFile)) {
        Write-Host "Registry not found: $registryFile" -ForegroundColor Red
        return $null
    }
    $raw = Get-Content -LiteralPath $registryFile -Raw -Encoding UTF8
    return $raw | ConvertFrom-Json
}

function Write-Registry {
    param([object]$Registry)
    $json = $Registry | ConvertTo-Json -Depth 10
    Write-Utf8NoBom -Path $registryFile -Content $json
}

function Get-CurrentKernelVersion {
    if (-not (Test-Path -LiteralPath $lockFile)) { return "" }
    $lock = Get-Content -LiteralPath $lockFile -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($lock -is [array] -and $lock.Count -gt 0) {
        $firstPath = $lock[0].path
        $parts = $firstPath -split "\\"
        foreach ($p in $parts) {
            if ($p -like "kernel-*") { return $p -replace "^kernel-", "" }
        }
    }
    return ""
}

switch ($Command.ToLower()) {
    "list" {
        $reg = Read-Registry
        if ($null -eq $reg) { exit 1 }
        if ($reg.projects.Count -eq 0) {
            Write-Host "No projects registered." -ForegroundColor Yellow
            exit 0
        }
        Write-Host "Registered projects:" -ForegroundColor Cyan
        Write-Host ""
        foreach ($p in $reg.projects) {
            $govTag = if ($p.governed) { "[governed]" } else { "[known, not governed]" }
            $govColor = if ($p.governed) { "Green" } else { "Yellow" }
            Write-Host "  $($p.id)" -ForegroundColor White -NoNewline
            Write-Host " - $($p.name)" -ForegroundColor Gray -NoNewline
            Write-Host " ($($p.status))" -ForegroundColor Cyan -NoNewline
            Write-Host " $govTag" -ForegroundColor $govColor
            Write-Host "    path:   $($p.path)" -ForegroundColor DarkGray
            Write-Host "    kernel: $($p.kernel)" -ForegroundColor DarkGray
            Write-Host "    active: $($p.last_active)" -ForegroundColor DarkGray
        }
        exit 0
    }

    "add" {
        if (-not $Arg1 -or -not $Arg2) {
            Write-Host "Usage: ygg projects add <name> <path>" -ForegroundColor Cyan
            exit 1
        }
        $projName = $Arg1
        $projPath = $Arg2

        if (-not (Test-Path -LiteralPath $projPath)) {
            Write-Host "Path does not exist: $projPath" -ForegroundColor Red
            exit 1
        }
        $projPath = (Resolve-Path -LiteralPath $projPath).Path

        $reg = Read-Registry
        if ($null -eq $reg) { exit 1 }

        $existing = $reg.projects | Where-Object { $_.name -eq $projName -or $_.id -eq $projName.ToLower() }
        if ($existing) {
            Write-Host "Project already registered: $($existing.id)" -ForegroundColor Red
            exit 1
        }

        $projId = $projName.ToLower() -replace "[^a-z0-9-]", "-"
        $kernelVer = Get-CurrentKernelVersion

        $newProj = @{
            id          = $projId
            name        = $projName
            path        = $projPath
            kernel      = $kernelVer
            status      = "importing"
            last_active = (Get-Date).ToString("yyyy-MM-dd")
            governed    = $false
        }

        $reg.projects = @($reg.projects) + @($newProj)
        Write-Registry -Registry $reg

        Write-Host "Project registered: $projId" -ForegroundColor Green
        Write-Host "  path:   $projPath" -ForegroundColor Gray
        Write-Host "  kernel: $kernelVer" -ForegroundColor Gray
        Write-Host "  status: importing (not yet governed)" -ForegroundColor Yellow
        exit 0
    }

    "remove" {
        if (-not $Arg1) {
            Write-Host "Usage: ygg projects remove <name>" -ForegroundColor Cyan
            exit 1
        }
        $projName = $Arg1

        $reg = Read-Registry
        if ($null -eq $reg) { exit 1 }

        $match = $reg.projects | Where-Object { $_.name -eq $projName -or $_.id -eq $projName.ToLower() }
        if (-not $match) {
            Write-Host "Project not found: $projName" -ForegroundColor Red
            exit 1
        }

        $reg.projects = @($reg.projects | Where-Object { $_.id -ne $match.id })
        Write-Registry -Registry $reg

        Write-Host "Project deregistered: $($match.id)" -ForegroundColor Green
        Write-Host "  Files left on disk at: $($match.path)" -ForegroundColor Yellow
        exit 0
    }

    "switch" {
        if (-not $Arg1) {
            Write-Host "Usage: ygg switch <project-name>" -ForegroundColor Cyan
            exit 1
        }
        $targetName = $Arg1

        $reg = Read-Registry
        if ($null -eq $reg) { exit 1 }

        $target = $reg.projects | Where-Object { $_.name -eq $targetName -or $_.id -eq $targetName.ToLower() }
        if (-not $target) {
            Write-Host "Project not found: $targetName" -ForegroundColor Red
            exit 1
        }

        if (-not $target.governed) {
            Write-Host "Project is known but not governed. No autonomous work permitted." -ForegroundColor Red
            Write-Host "  Ratify in seed/memory/projects.md before switching." -ForegroundColor Yellow
            exit 1
        }

        if (-not (Test-Path -LiteralPath $target.path)) {
            Write-Host "Project path does not exist: $($target.path)" -ForegroundColor Red
            exit 1
        }

        # Write session digest for outgoing project
        $today = (Get-Date).ToString("yyyy-MM-dd")
        $digestDir = Join-Path -Path $yggRoot -ChildPath "seed\memory\log"
        if (-not (Test-Path -LiteralPath $digestDir)) {
            $null = New-Item -ItemType Directory -Path $digestDir -Force
        }
        $digestFile = Join-Path -Path $digestDir -ChildPath "switch-$today.md"
        $digestContent = "# Session Switch - $today`n`n"
        $digestContent += "Outgoing: $($yggRoot)`n"
        $digestContent += "Incoming: $($target.path)`n"
        $digestContent += "Target:   $($target.id)`n"
        Write-Utf8NoBom -Path $digestFile -Content $digestContent

        # Update the .ygg pointer file in the target project
        $yggPointer = Join-Path -Path $target.path -ChildPath ".ygg"
        Write-Utf8NoBom -Path $yggPointer -Content $target.path

        # Update last_active
        foreach ($p in $reg.projects) {
            if ($p.id -eq $target.id) {
                $p.last_active = $today
                $p.status = "active"
            }
        }
        Write-Registry -Registry $reg

        Write-Host "Switched to project: $($target.id)" -ForegroundColor Green
        Write-Host "  path: $($target.path)" -ForegroundColor Gray
        Write-Host "  kernel: $($target.kernel)" -ForegroundColor Gray
        Write-Host "  Session digest written: $digestFile" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "NOTE: Full WRAP/BOOTSTRAP session boundary requires human session restart." -ForegroundColor Yellow
        exit 0
    }

    "status" {
        $yggPointer = Join-Path -Path $yggRoot -ChildPath ".ygg"
        if (Test-Path -LiteralPath $yggPointer) {
            $currentPath = (Get-Content -LiteralPath $yggPointer -Raw -Encoding UTF8).Trim()
            Write-Host "Current project root: $currentPath" -ForegroundColor Cyan
        } else {
            Write-Host "No .ygg pointer found." -ForegroundColor Yellow
        }

        $reg = Read-Registry
        if ($null -eq $reg) { exit 1 }

        $current = $reg.projects | Where-Object { $_.path -eq $yggRoot.Path }
        if ($current) {
            Write-Host ""
            Write-Host "Project: $($current.id) ($($current.name))" -ForegroundColor White
            Write-Host "  Kernel:   $($current.kernel)" -ForegroundColor Gray
            Write-Host "  Status:   $($current.status)" -ForegroundColor Gray
            Write-Host "  Governed: $($current.governed)" -ForegroundColor Gray
            Write-Host "  Active:   $($current.last_active)" -ForegroundColor Gray
        } else {
            Write-Host "  (not in registry)" -ForegroundColor Yellow
        }

        # Kernel status
        if (Test-Path -LiteralPath $lockFile) {
            $lock = Get-Content -LiteralPath $lockFile -Raw -Encoding UTF8 | ConvertFrom-Json
            $fileCount = 0
            if ($lock -is [array]) { $fileCount = $lock.Count }
            Write-Host ""
            Write-Host "Kernel: $fileCount files bound" -ForegroundColor Cyan
        } else {
            Write-Host ""
            Write-Host "Kernel: not bound" -ForegroundColor Yellow
        }
        exit 0
    }

    default {
        Write-Host "Usage: ygg projects <list|add|remove> [args...]" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Commands:" -ForegroundColor White
        Write-Host "  list              List all registered projects" -ForegroundColor Gray
        Write-Host "  add <name> <path> Register a new project" -ForegroundColor Gray
        Write-Host "  remove <name>     Deregister a project (leaves files on disk)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Also: ygg switch <name>  - switch active project context" -ForegroundColor Gray
        Write-Host "      ygg status         - show current project and kernel" -ForegroundColor Gray
        exit 1
    }
}
