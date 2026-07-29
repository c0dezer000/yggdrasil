# ygg-serve.ps1 - start the shared opencode server for the interactive bridge
<#
.SYNOPSIS
  Starts `opencode serve` in the project root and prints the attach command.
.DESCRIPTION
  The interactive bridge needs one opencode SERVER that both the gardener's TUI and the
  daemon talk to. This starts it in the project root, which is required for the project's
  agents (.opencode/agents/) and opencode.json to resolve.

  Usage:
    ygg serve                 # foreground, Ctrl+C to stop
    ygg serve -Background     # hidden process, logs to logs/opencode-server.log

  Then, in the terminal you want to watch:
    opencode attach http://127.0.0.1:4096
.PARAMETER Port
  Port to listen on. Must match `url` in .ygg-bridge.json.
.PARAMETER Background
  Run hidden instead of in this console.
#>

[CmdletBinding()]
param(
    [int]$Port = 4096,
    [switch]$Background
)

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot   = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")

# Refuse to start a second server on the same port. Two servers means the daemon and the TUI
# can silently end up on different ones, which is exactly the split-brain the bridge exists to
# remove.
$inUse = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($inUse) {
    Write-Host "Port $Port is already listening (PID $($inUse[0].OwningProcess))." -ForegroundColor Yellow
    Write-Host "If that is already your opencode server, attach to it:" -ForegroundColor Gray
    Write-Host "  opencode attach http://127.0.0.1:$Port" -ForegroundColor Cyan
    exit 1
}

# The server is unauthenticated unless a password is set. It binds to loopback, so it is not
# reachable from the network, but any local process can drive an agent that holds edit and bash.
# Set OPENCODE_SERVER_PASSWORD (and the matching `password` in .ygg-bridge.json) on any machine
# where that matters.
if (-not $env:OPENCODE_SERVER_PASSWORD) {
    Write-Host "  [WARN] OPENCODE_SERVER_PASSWORD is not set - the server will accept any local client." -ForegroundColor DarkYellow
}

Write-Host "Starting opencode server on 127.0.0.1:$Port" -ForegroundColor Cyan
Write-Host "Project root: $yggRoot" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Attach your visible session with:" -ForegroundColor Gray
Write-Host "  opencode attach http://127.0.0.1:$Port" -ForegroundColor Cyan
Write-Host ""

if ($Background) {
    $logDir = Join-Path -Path $yggRoot -ChildPath "logs"
    if (-not (Test-Path -LiteralPath $logDir -PathType Container)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    $logFile = Join-Path -Path $logDir -ChildPath "opencode-server.log"
    $inner   = "Set-Location '$yggRoot'; opencode serve --port $Port --hostname 127.0.0.1 *> '$logFile'"
    Start-Process -FilePath 'powershell.exe' `
        -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', $inner `
        -WindowStyle Hidden
    Start-Sleep -Seconds 5

    $up = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    if ($up) {
        Write-Host "Server running in background (PID $($up[0].OwningProcess)). Log: $logFile" -ForegroundColor Green
        exit 0
    }
    Write-Host "Server did not come up. Check $logFile" -ForegroundColor Red
    exit 1
}

Set-Location -LiteralPath $yggRoot
& opencode serve --port $Port --hostname 127.0.0.1
