# ygg-kernel.ps1 - Kernel artifact management
[CmdletBinding()]
param([Parameter(Position=0)][string]$Command = "")

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot   = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")
$distDir   = Join-Path -Path $yggRoot -ChildPath "dist"
$lockDir   = Join-Path -Path $yggRoot -ChildPath ".ygg"
$lockFile  = Join-Path -Path $yggRoot -ChildPath ".ygg-lock"

$kernelPatterns = @(
    "seed\constitution\*.md",
    "seed\protocols\*.md",
    "seed\adapters\*\agents\*.md",
    "seed\adapters\*\model-assignment.md",
    "seed\conformance\*.md"
)

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

if ($Command -eq "build") {
    $version = (Get-Date).ToString('yyyyMMdd-HHmmss')
    $kernelVerDir = Join-Path $distDir -ChildPath "kernel-$version"
    $null = New-Item -ItemType Directory -Path $kernelVerDir -Force
    $manifest = @()
    foreach ($pattern in $kernelPatterns) {
        $files = Get-ChildItem -Path (Join-Path $yggRoot -ChildPath $pattern) -Recurse -File -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            $rel = $f.FullName.Substring($yggRoot.Length + 1)
            $td = Split-Path (Join-Path $kernelVerDir -ChildPath $rel) -Parent
            $null = New-Item -ItemType Directory -Path $td -Force
            Copy-Item $f.FullName (Join-Path $kernelVerDir -ChildPath $rel) -Force
            $h = (Get-FileHash $f.FullName -Algorithm SHA256).Hash
            $manifest += @{path = $rel; hash = $h}
        }
    }
    $manifestJson = $manifest | ConvertTo-Json -Compress
    Write-Utf8NoBom -Path (Join-Path $kernelVerDir -ChildPath "manifest.json") -Content $manifestJson
    Write-Utf8NoBom -Path (Join-Path $kernelVerDir -ChildPath "KERNEL_VERSION") -Content $version
    Write-Host "Kernel $version built - $($manifest.Count) files" -ForegroundColor Green
    Write-Host "  dist\kernel-$version" -ForegroundColor Gray
    exit 0
}

if ($Command -eq "verify") {
    if (-not (Test-Path $lockFile)) { Write-Host "No seed.lock found"; exit 1 }
    $lock = Get-Content $lockFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $errors = 0
    foreach ($entry in $lock.manifest) {
        $fp = Join-Path $yggRoot -ChildPath $entry.path
        if (-not (Test-Path $fp)) { Write-Host "MISSING: $($entry.path)" -ForegroundColor Red; $errors++ }
        else {
            $ch = (Get-FileHash $fp -Algorithm SHA256).Hash
            if ($ch -ne $entry.hash) { Write-Host "CHANGED: $($entry.path)" -ForegroundColor Red; $errors++ }
        }
    }
    if ($errors -gt 0) { Write-Host "FAILED ($errors mismatches)" -ForegroundColor Red; exit 1 }
    Write-Host "PASS - all $($lock.manifest.Count) files match" -ForegroundColor Green
    exit 0
}

if ($Command -eq "status") {
    if (Test-Path $lockFile) {
        $lock = Get-Content $lockFile -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host "Kernel: $($lock.version)" -ForegroundColor Cyan
        Write-Host "Files:  $($lock.manifest.Count)" -ForegroundColor Gray
    } else {
        Write-Host "No kernel bound" -ForegroundColor Yellow
    }
    exit 0
}

if ($Command -eq "upgrade") {
    # ygg kernel upgrade [project] - re-bind project to latest kernel
    # Snapshot before/after, diff, report

    $targetProject = $args | Select-Object -First 1
    if (-not $targetProject) { $targetProject = "" }

    # Find the latest kernel in dist/
    $kernelDirs = Get-ChildItem -Path $distDir -Directory -Filter "kernel-*" -ErrorAction SilentlyContinue |
        Sort-Object { $_.Name -replace "kernel-", "" } -Descending
    if ($kernelDirs.Count -eq 0) {
        Write-Host "No kernel artifacts found in dist/" -ForegroundColor Red
        exit 1
    }
    $latestKernel = $kernelDirs[0]
    $latestVersion = $latestKernel.Name -replace "kernel-", ""

    # Read current lock
    if (-not (Test-Path $lockFile)) {
        Write-Host "No .ygg-lock found. Cannot upgrade." -ForegroundColor Red
        exit 1
    }
    $currentLock = Get-Content $lockFile -Raw -Encoding UTF8 | ConvertFrom-Json
    
    # Determine current kernel version by checking which kernel dir matches
    $currentVersion = "unknown"
    foreach ($kdir in $kernelDirs) {
        $manifestFile = Join-Path $kdir.FullName -ChildPath "manifest.json"
        if (Test-Path $manifestFile) {
            $manifest = Get-Content $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($manifest.Count -eq $currentLock.Count) {
                $match = $true
                for ($i = 0; $i -lt $manifest.Count; $i++) {
                    if ($manifest[$i].hash -ne $currentLock[$i].hash) { $match = $false; break }
                }
                if ($match) {
                    $currentVersion = $kdir.Name -replace "kernel-", ""
                    break
                }
            }
        }
    }

    if ($currentVersion -eq $latestVersion) {
        Write-Host "Already on latest kernel: $latestVersion" -ForegroundColor Green
        exit 0
    }

    Write-Host "Kernel upgrade" -ForegroundColor Cyan
    Write-Host "  Current: $currentVersion" -ForegroundColor Gray
    Write-Host "  Latest:  $latestVersion" -ForegroundColor Gray
    Write-Host ""

    # Snapshot current lock
    $snapshotDir = Join-Path $yggRoot -ChildPath "work\snapshots"
    if (-not (Test-Path $snapshotDir)) {
        $null = New-Item -ItemType Directory -Path $snapshotDir -Force
    }
    $timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
    $preSnapshot = Join-Path $snapshotDir -ChildPath "pre-upgrade-$timestamp.json"
    $preContent = $currentLock | ConvertTo-Json -Depth 10
    Write-Utf8NoBom -Path $preSnapshot -Content $preContent
    Write-Host "  Pre-snapshot:  $preSnapshot" -ForegroundColor DarkGray

    # Read new kernel manifest
    $newManifestFile = Join-Path $latestKernel.FullName -ChildPath "manifest.json"
    if (-not (Test-Path $newManifestFile)) {
        Write-Host "ERROR: Latest kernel has no manifest.json" -ForegroundColor Red
        exit 1
    }
    $newManifest = Get-Content $newManifestFile -Raw -Encoding UTF8 | ConvertFrom-Json

    # Build new lock entries from manifest
    # Paths in manifest may be absolute (starting with \) or relative
    $newLock = @()
    foreach ($entry in $newManifest) {
        $entryPath = $entry.path
        # Convert absolute paths to relative by stripping leading \projects\yggdrasil\
        if ($entryPath.StartsWith("\projects\yggdrasil\")) {
            $entryPath = $entryPath.Substring("\projects\yggdrasil\".Length)
        }
        $newLock += @{
            path = $entryPath
            hash = $entry.hash
        }
    }

    # Write new lock
    $newLockJson = $newLock | ConvertTo-Json -Compress
    $backupLock = Join-Path $yggRoot -ChildPath ".ygg-lock.pre-upgrade"
    Copy-Item $lockFile $backupLock -Force
    Write-Utf8NoBom -Path $lockFile -Content $newLockJson

    # Verify the new binding
    $errors = 0
    foreach ($entry in $newLock) {
        $fp = Join-Path $yggRoot -ChildPath $entry.path
        if (-not (Test-Path $fp)) {
            Write-Host "  MISSING after upgrade: $($entry.path)" -ForegroundColor Red
            $errors++
        } else {
            $ch = (Get-FileHash $fp -Algorithm SHA256).Hash
            if ($ch -ne $entry.hash) {
                Write-Host "  MISMATCH after upgrade: $($entry.path)" -ForegroundColor Red
                $errors++
            }
        }
    }

    # Post-snapshot
    $postSnapshot = Join-Path $snapshotDir -ChildPath "post-upgrade-$timestamp.json"
    $postContent = $newLock | ConvertTo-Json -Depth 10
    Write-Utf8NoBom -Path $postSnapshot -Content $postContent

    if ($errors -gt 0) {
        Write-Host ""
        Write-Host "UPGRADE FAILED - $errors errors detected" -ForegroundColor Red
        Write-Host "  Rolling back to previous lock..." -ForegroundColor Yellow
        Copy-Item $backupLock $lockFile -Force
        Write-Host "  Rollback complete. Previous lock restored." -ForegroundColor Green
        Write-Host "  Pre-snapshot:  $preSnapshot" -ForegroundColor DarkGray
        Write-Host "  Post-snapshot: $postSnapshot" -ForegroundColor DarkGray
        exit 1
    }

    # Update registry if present
    $registryFile = Join-Path $yggRoot -ChildPath "seed\registry\projects.json"
    if (Test-Path $registryFile) {
        $reg = Get-Content $registryFile -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($p in $reg.projects) {
            $p.kernel = $latestVersion
            $p.last_active = (Get-Date).ToString("yyyy-MM-dd")
        }
        $regJson = $reg | ConvertTo-Json -Depth 10
        Write-Utf8NoBom -Path $registryFile -Content $regJson
    }

    # Clean up backup
    Remove-Item $backupLock -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "UPGRADE COMPLETE" -ForegroundColor Green
    Write-Host "  Kernel: $currentVersion -> $latestVersion" -ForegroundColor White
    Write-Host "  Files:  $($newLock.Count) bound" -ForegroundColor Gray
    Write-Host "  Pre-snapshot:  $preSnapshot" -ForegroundColor DarkGray
    Write-Host "  Post-snapshot: $postSnapshot" -ForegroundColor DarkGray
    exit 0
}

Write-Host "Usage: ygg kernel build | verify | status | upgrade" -ForegroundColor Cyan
exit 0
