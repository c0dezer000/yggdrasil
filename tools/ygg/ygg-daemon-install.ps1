# ygg-daemon-install.ps1 — Register or unregister Yggdrasil Daemon scheduled task
<#
.SYNOPSIS
  Creates or removes the Windows scheduled task for the Yggdrasil daemon.
.DESCRIPTION
  Install: Registers a task named "Yggdrasil Daemon" that runs at logon.
  Uninstall: Removes the task.
  Run whether user is logged on or not, restart on failure 3 times.
.PARAMETER Uninstall
  Remove the scheduled task instead of creating it.
.EXAMPLE
  .\ygg-daemon-install.ps1
  .\ygg-daemon-install.ps1 -Uninstall
#>

[CmdletBinding()]
param(
    [switch]$Uninstall
)

$taskName = "Yggdrasil Daemon"

# =====================================================================
# UNINSTALL
# =====================================================================
if ($Uninstall) {
    $existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existing) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Scheduled task '$taskName' unregistered." -ForegroundColor Green
    } else {
        Write-Host "Scheduled task '$taskName' not found." -ForegroundColor Yellow
    }
    exit 0
}

# =====================================================================
# INSTALL
# =====================================================================

# Resolve the actual path to ygg.ps1
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggScript = Join-Path -Path $scriptDir -ChildPath "ygg.ps1"
$yggRoot   = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")

# Validate that ygg.ps1 exists
if (-not (Test-Path -LiteralPath $yggScript -PathType Leaf)) {
    Write-Host "ERROR: ygg.ps1 not found at $yggScript" -ForegroundColor Red
    exit 1
}

# Build the command argument
$commandArg = "-NoProfile -ExecutionPolicy Bypass -Command `"& '$yggScript' daemon start`""

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument $commandArg `
    -WorkingDirectory $yggRoot

$trigger = New-ScheduledTaskTrigger -AtLogon

$settings = New-ScheduledTaskSettingsSet `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force

Write-Host "Scheduled task '$taskName' registered." -ForegroundColor Green
Write-Host "  Command: powershell.exe $commandArg" -ForegroundColor Gray
Write-Host "  Start in: $yggRoot" -ForegroundColor Gray
Write-Host "  Runs at logon as SYSTEM." -ForegroundColor Gray
Write-Host "  Restart on failure: 3 times at 1-minute intervals." -ForegroundColor Gray

exit 0
