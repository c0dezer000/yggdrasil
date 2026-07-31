# ygg-profile-hook.ps1 — Install the Yggdrasil shell hook into $PROFILE
<#
.SYNOPSIS
  Adds the auto-detect hook to the PowerShell profile so every new shell
  automatically detects the governed project it opened in.
.EXAMPLE
  & "C:\projects\yggdrasil\tools\ygg\ygg-profile-hook.ps1"
#>

$profilePath = $PROFILE
$profileDir = Split-Path $profilePath -Parent
if (-not (Test-Path $profileDir)) { $null = New-Item -ItemType Directory -Path $profileDir -Force }

$hookLine = "& `"C:\projects\yggdrasil\tools\ygg\ygg-auto-detect.ps1`""

$content = ""
if (Test-Path $profilePath) { $content = Get-Content $profilePath -Raw -Encoding UTF8 }

if ($content -match 'ygg-auto-detect') {
    Write-Host "Hook already installed." -ForegroundColor DarkYellow
} else {
    $addition = "`r`n# Yggdrasil project auto-detection`r`n$hookLine`r`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::AppendAllText($profilePath, $addition, $utf8NoBom)
    Write-Host "Hook installed in $profilePath" -ForegroundColor Green
    Write-Host "Open a new PowerShell window to activate." -ForegroundColor Gray
}
