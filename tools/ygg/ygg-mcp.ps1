# ygg-mcp.ps1 — MCP server bridge (plumbing only, no server activation)
<#
.SYNOPSIS
  Communicate with MCP servers via stdin/stdout JSON-RPC.
  Builds the bridge; no server is activated until Gate 4 is passed.
#>

[CmdletBinding()]
param(
    [Parameter(Position=0)][string]$Command = "",
    [Parameter(Position=1)][string]$ServerCmd = "",
    [Parameter(Position=2)][string]$Args = ""
)

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot   = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

# ---- List available MCP servers ----
if ($Command -eq "list-available") {
    Write-Host ""
    Write-Host "Available MCP Servers" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Memory:     npx -y @modelcontextprotocol/server-memory"
    Write-Host "              Knowledge graph (entities/relations/observations)"
    Write-Host "              Status: NOT ACTIVATED - pending Gate 4" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Git:        uvx mcp-server-git --repository C:\projects\yggdrasil"
    Write-Host "              Structured git access (read-only)"
    Write-Host "              Status: NOT ACTIVATED - pending Gate 4" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Filesystem: npx -y @modelcontextprotocol/server-filesystem C:\projects\yggdrasil"
    Write-Host "              Smart file editing with diff preview"
    Write-Host "              Status: NOT ACTIVATED - pending Gate 4" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "Lethal trifecta is already COMPLETE in current configuration." -ForegroundColor Yellow
    Write-Host "Each MCP server activation is a per-expansion Gate 4 encounter." -ForegroundColor Yellow
    Write-Host "Activation requires resulting-configuration assessment." -ForegroundColor Yellow
    exit 0
}

# ---- Show bridge status ----
if ($Command -eq "status") {
    Write-Host ""
    Write-Host "MCP Bridge Status" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Bridge:      built (ygg mcp)" -ForegroundColor Green
    Write-Host "  Servers:     0 activated" -ForegroundColor Yellow
    Write-Host "  Trifecta:    COMPLETE (all legs active)" -ForegroundColor Yellow
    Write-Host "  Gate 4:      NOT PASSED for any MCP server" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  To activate: gardener must pass Gate 4 with" -ForegroundColor Gray
    Write-Host "  resulting-configuration lethal-trifecta assessment." -ForegroundColor Gray
    exit 0
}

# ---- Request Gate 4 for a server ----
if ($Command -eq "request-gate") {
    if (-not $ServerCmd) {
        Write-Host "Usage: ygg mcp request-gate --server ""<cmd>"" --name ""<name>""" -ForegroundColor Yellow
        exit 1
    }
    $name = "unnamed-mcp-server"
    if ($Args) { $name = $Args }
    Write-Host ""
    Write-Host "Gate 4 Request: $name" -ForegroundColor Cyan
    Write-Host "Server command: $ServerCmd" -ForegroundColor White
    Write-Host ""
    Write-Host "LEGACY TRIFECTA:" -ForegroundColor Yellow
    Write-Host "  Private data:     YES (pre-existing)"
    Write-Host "  Untrusted input:  YES (MCP server output)"
    Write-Host "  External comms:   YES (pre-existing daemon)"
    Write-Host "  Result:           COMPLETE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Mitigations and Gate 4 passage are the gardener's decision." -ForegroundColor Gray
    exit 0
}

# ---- tools/list and tools/call ----
if ($Command -eq "tools/list" -or $Command -eq "tools/call") {
    if (-not $ServerCmd) {
        Write-Host "Error: --server is required" -ForegroundColor Red
        exit 1
    }
    # Check Gate 4
    $gateFile = Join-Path $yggRoot -ChildPath "work\.mcp-gate-passed"
    if (-not (Test-Path $gateFile)) {
        Write-Host ""
        Write-Host "GATE 4 NOT PASSED" -ForegroundColor Red
        Write-Host "=================" -ForegroundColor Red
        Write-Host "MCP servers cannot be activated until Gate 4 is passed." -ForegroundColor Yellow
        Write-Host "The bridge is built, but no server is started without" -ForegroundColor Yellow
        Write-Host "explicit gardener approval (resulting-configuration form)." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To request Gate 4: ygg mcp request-gate --server ""$ServerCmd""" -ForegroundColor Gray
        exit 1
    }
    # Build JSON-RPC request
    $requestId = [DateTime]::UtcNow.Ticks
    if ($Command -eq "tools/list") {
        $reqStr = "{""jsonrpc"":""2.0"",""id"":$requestId,""method"":""tools/list"",""params"":{}}"
    } else {
        $reqStr = "{""jsonrpc"":""2.0"",""id"":$requestId,""method"":""tools/call"",""params"":$Args}"
    }
    # Parse server command
    $parts = $ServerCmd -split ' ', 2
    $exe = $parts[0]
    $exeArgs = ""
    if ($parts.Count -gt 1) { $exeArgs = $parts[1] }
    # Spawn process
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $exe
        $psi.Arguments = $exeArgs
        $psi.RedirectStandardInput = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        if (-not $proc) {
            Write-Host "Failed to start: $ServerCmd" -ForegroundColor Red
            exit 1
        }
        $proc.StandardInput.WriteLine($reqStr)
        $proc.StandardInput.Close()
        $out = $proc.StandardOutput.ReadToEnd()
        $err = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit(10000) | Out-Null
        $proc.Dispose()
        if ($err) { Write-Host "stderr: $err" -ForegroundColor DarkYellow }
        if (-not $out) {
            Write-Host "No response from MCP server" -ForegroundColor Red
            exit 1
        }
        Write-Host "Response: $out" -ForegroundColor Green
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    exit 0
}

# ---- Help ----
Write-Host ""
Write-Host "Usage: ygg mcp <command>" -ForegroundColor Cyan
Write-Host ""
Write-Host "Commands:"
Write-Host "  list-available              List documented MCP servers"
Write-Host "  status                      Show bridge status"
Write-Host "  request-gate                Request Gate 4 for a server"
Write-Host "  tools/list --server <cmd>   List tools (GATE-BLOCKED)"
Write-Host "  tools/call --server <cmd>   Call tool (GATE-BLOCKED)"
Write-Host ""
Write-Host "Note: tools/list and tools/call require Gate 4 passage first."
exit 0
