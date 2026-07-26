# ygg - Yggdrasil CLI dispatcher
<#
.SYNOPSIS
  Yggdrasil CLI - dispatches subcommands for environment checks, seed operations,
  capability gating, and installation.
.DESCRIPTION
  Usage: ygg subcommand [args...]
  Subcommands:
    doctor     - run environment verification checks
    plant      - interactive wizard to generate a working seed installation
    verify     - run deterministic conformance checks and queue judgment assertions
    gate-l1    - run L1 static capability gate (schema, loadability, triggers, DVA)
    gate-l2    - run L2 behavioural capability gate (assertions, quality, integrity)
    heartbeat  - run daily heartbeat: goal staleness, staging, active unit
#>

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Determine the subcommand and arguments.
# Use $args (automatic variable) to avoid shadowing issues with a param named $Args.
$resolvedSubcommand = ""
$resolvedArgs = @()

if ($args.Count -gt 0) {
    $resolvedSubcommand = $args[0]
    if ($args.Count -gt 1) {
        $resolvedArgs = $args[1..($args.Count - 1)]
    }
}

# Also support the legacy param style via explicit -Subcommand
if (-not $resolvedSubcommand) {
    # Check for -Subcommand parameter
    for ($i = 0; $i -lt $args.Count - 1; $i++) {
        if ($args[$i] -eq '-Subcommand' -or $args[$i] -eq '--Subcommand') {
            $resolvedSubcommand = $args[$i + 1]
        }
    }
}

if (-not $resolvedSubcommand) { $resolvedSubcommand = "" }
switch ($resolvedSubcommand.ToLower()) {
    "doctor" {
        & (Join-Path -Path $scriptDir -ChildPath "ygg-doctor.ps1") @resolvedArgs
        exit $LASTEXITCODE
    }
    "plant" {
        & (Join-Path -Path $scriptDir -ChildPath "ygg-plant.ps1") @resolvedArgs
        exit $LASTEXITCODE
    }
    "verify" {
        & (Join-Path -Path $scriptDir -ChildPath "ygg-verify.ps1") @resolvedArgs
        exit $LASTEXITCODE
    }
    "gate-l1" {
        & (Join-Path -Path $scriptDir -ChildPath "ygg-gate-l1.ps1") @resolvedArgs
        exit $LASTEXITCODE
    }
    "gate-l2" {
        & (Join-Path -Path $scriptDir -ChildPath "ygg-gate-l2.ps1") @resolvedArgs
        exit $LASTEXITCODE
    }
    "heartbeat" {
        & (Join-Path -Path $scriptDir -ChildPath "ygg-heartbeat.ps1") @resolvedArgs
        exit $LASTEXITCODE
    }
    default {
        if ($resolvedSubcommand) {
            Write-Host "Unknown subcommand: $resolvedSubcommand" -ForegroundColor Red
            Write-Host ""
        }
        Write-Host "ygg - Yggdrasil CLI" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Usage: ygg subcommand [args...]" -ForegroundColor White
        Write-Host ""
        Write-Host "Subcommands:" -ForegroundColor White
        Write-Host "  doctor     Run environment verification checks" -ForegroundColor Gray
        Write-Host "  plant      Interactive wizard to generate a working seed installation" -ForegroundColor Gray
        Write-Host "  verify     Run deterministic conformance checks and queue judgment assertions" -ForegroundColor Gray
        Write-Host "  gate-l1    Run L1 static capability gate (schema, loadability, triggers, DVA)" -ForegroundColor Gray
        Write-Host "  gate-l2    Run L2 behavioural capability gate (assertions, quality, integrity)" -ForegroundColor Gray
        Write-Host "  heartbeat  Run daily heartbeat: goal staleness, staging, active unit" -ForegroundColor Gray
        exit 1
    }
}
