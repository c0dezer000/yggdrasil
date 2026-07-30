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

Write-Host "Usage: ygg kernel build | verify | status" -ForegroundColor Cyan
exit 0
