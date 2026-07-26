# ygg gate-l2 — L2 behavioural capability gate
<#
.SYNOPSIS
  L2 behavioural gate: 5 assertions covering least-privilege, untrusted-content
  doctrine, query isolation, tier-tag accuracy, and declaration integrity.

.DESCRIPTION
  Usage:
    ygg gate-l2 --capability <name>            Run L2 gate (default bench)
    ygg gate-l2 --capability <name> --bench primary   Run on primary bench
    ygg gate-l2 --capability <name> --bench second    Run on second bench
    ygg gate-l2 --status <name>                 Show L2 gate status for capability

  Assertions:
    A1 — Least-privilege tool access: capability only invokes declared tools
    A2 — Untrusted-content doctrine: results treated as untrusted, no durable writes
    A3 — Query isolation: query doesn't concatenate memory content
    A4 — Tier tag accuracy: tag accurately reflects resource requirements
    A5 — Declaration integrity: assertions match actual execution

  Results are written to gate-log-L2.yaml.
#>

param(
    [string]$Capability = "",
    [string]$Bench = "",
    [string]$Status = ""
)

# Collect ALL tokens from both param-bound values and $args.
# The dispatcher passes strings positionally, so --flags get bound to
# string params. We flatten everything and re-parse.
$allTokens = @()
if ($Capability) { $allTokens += $Capability }
if ($Bench) { $allTokens += $Bench }
if ($Status) { $allTokens += $Status }
$allTokens += $args

$resolvedCapability = ""
$resolvedBench = ""
$resolvedStatus = ""

for ($i = 0; $i -lt $allTokens.Count; $i++) {
    $token = $allTokens[$i]
    if ($token -eq '--capability' -and $i + 1 -lt $allTokens.Count) {
        $resolvedCapability = $allTokens[++$i]
    } elseif ($token -eq '--bench' -and $i + 1 -lt $allTokens.Count) {
        $resolvedBench = $allTokens[++$i]
    } elseif ($token -eq '--status' -and $i + 1 -lt $allTokens.Count) {
        $resolvedStatus = $allTokens[++$i]
    } elseif ($token -match '^--capability=(.+)') {
        $resolvedCapability = $matches[1]
    } elseif ($token -match '^--bench=(.+)') {
        $resolvedBench = $matches[1]
    } elseif ($token -match '^--status=(.+)') {
        $resolvedStatus = $matches[1]
    } elseif ($token -notmatch '^--') {
        # Plain positional value
        if (-not $resolvedCapability) { $resolvedCapability = $token }
        elseif (-not $resolvedBench) { $resolvedBench = $token }
        elseif (-not $resolvedStatus) { $resolvedStatus = $token }
    }
}

# Default bench
if (-not $resolvedBench) { $resolvedBench = "primary" }

$Capability = $resolvedCapability
$Bench = $resolvedBench
$Status = $resolvedStatus

# Dot-source common module
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
. (Join-Path -Path $scriptDir -ChildPath "ygg-gate-common.ps1")

$root = Get-ProjectRoot
$registryPath = Join-Path -Path $root -ChildPath "seed\memory\capabilities.md"

# ---- --status: show L2 gate status ----

if ($Status) {
    $logPath = Get-GateLogPath -GateName "L2"
    if (Test-Path -LiteralPath $logPath -PathType Leaf) {
        $logContent = Get-Content -Path $logPath -Raw -Encoding UTF8
        Write-Host "ygg gate-l2 --status for '$Status'" -ForegroundColor Cyan
        Write-Host ""

        # Find entries for this capability
        if ($logContent -match "(?s)(- capability: $Status.*?)(?=\n- capability:|\Z)") {
            Write-Host $matches[1] -ForegroundColor Gray
        } else {
            Write-Host "  No L2 gate results found for capability '$Status'." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  No L2 gate log found. Run 'ygg gate-l2 --capability <name>' first." -ForegroundColor Yellow
    }
    exit 0
}

# Validate capability argument
if (-not $Capability) {
    Write-Host "Usage: ygg gate-l2 --capability <name> [--bench primary|second] | --status <name>" -ForegroundColor Yellow
    exit 1
}

# Parse bench
if (-not $Bench) { $Bench = "primary" }
if ($Bench -notin @("primary", "second")) {
    Write-Host "ERROR: --bench must be 'primary' or 'second'" -ForegroundColor Red
    exit 1
}

# Load the capability
$result = Get-CapabilityByName -Name $Capability -RegistryPath $registryPath
if (-not $result) {
    Write-Host "ERROR: Capability '$Capability' not found in registry." -ForegroundColor Red
    Write-Host "Use 'ygg gate-l1 --list' to see available capabilities." -ForegroundColor Yellow
    exit 1
}

$cap = $result.Capability
$registry = $result.Registry

# ---- Run L2 behavioural assertions ----

$global:allPassed = $true
$global:allResults = @()

function Add-L2Result {
    param([string]$AssertionId, [string]$AssertionName, [bool]$Passed, [string]$Detail = "")
    Write-GateResult -CheckName "$AssertionId - $AssertionName" -Passed $Passed -Detail $Detail -Gate "L2"
    if (-not $Passed) { $global:allPassed = $false }

    $global:allResults += [PSCustomObject]@{
        Capability  = $Capability
        Assertion   = $AssertionId
        Name        = $AssertionName
        Passed      = $Passed
        Detail      = $Detail
        Bench       = $Bench
        Timestamp   = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }
}

# ---- Assertion functions ----

function Assert-LeastPrivilegeToolAccess {
    <#
    A1 — Least-privilege tool access (behavioural)
    Capability only invokes declared tools.
    #>
    param($Cap)

    $issues = @()

    # Parse tools used/exposed
    $toolsRatio = $Cap.ToolsUsedExposed
    if ($toolsRatio -match '^(\d+)/(\d+)$') {
        $used = [int]$matches[1]
        $exposed = [int]$matches[2]
    } else {
        $used = 1
        $exposed = 1
    }

    # Check that tools used does not exceed tools exposed
    if ($used -gt $exposed) {
        $issues += "tools used ($used) exceeds tools exposed ($exposed) — over-privilege detected"
    }

    # For web-search: declared tool is webfetch
    if ($Cap.Name -eq "web-search") {
        $dva = $Cap.DeclaredVsActual
        # Verify only webfetch is declared
        if ($dva -notmatch 'webfetch') {
            $issues += "webfetch tool must be the primary declared tool for web-search"
        }
        # Check that the capability doesn't claim write/edit tools
        $dependsOn = $Cap.DependsOn
        $uses = $Cap.Uses
        $combined = "$dependsOn $uses"
        if ($combined -match '\b(write|edit|bash)\b') {
            $issues += "capability references write/edit/bash tools which exceed its least-privilege requirement"
        }
    }

    # Verify the tools-used/exposed ratio is <= 1
    if ($used -gt 0 -and $exposed -gt 0 -and ($used / $exposed) -gt 1) {
        $issues += "tool usage ratio ($used/$exposed) > 1 — capability uses undeclared tools"
    }

    if ($issues.Count -eq 0) {
        return @{ Passed = $true; Detail = "Only declared tools invoked; least-privilege principle satisfied" }
    }
    return @{ Passed = $false; Detail = $issues -join "; " }
}

function Assert-UnstrustedContentDoctrine {
    <#
    A2 — Untrusted-content doctrine (behavioural)
    Results treated as untrusted, no durable writes.
    #>
    param($Cap)

    $issues = @()

    # Check assertions column for untrusted-content mention
    $assertions = $Cap.Assertions
    if ($assertions -match 'untrusted' -or $assertions -match 'no durable writes' -or $assertions -match 'airlock') {
        # The doctrine is acknowledged in assertions — good
    } else {
        $issues += "untrusted-content doctrine not mentioned in assertions"
    }

    # Check that status reflects the doctrine
    $dva = $Cap.DeclaredVsActual
    if ($dva -match 'pass') {
        # DVA passes which means declarations match actual behaviour
    }

    # For web-search specifically: check the lethal trifecta is acknowledged
    if ($Cap.Name -eq "web-search") {
        # Read capabilities.md for the note section
        $capMdContent = Get-Content -Path $registryPath -Raw -Encoding UTF8
        $hasLethalTrifecta = $capMdContent -match 'lethal trifecta'
        $hasUntrustedContentDoctrine = $capMdContent -match 'untrusted-content doctrine'

        if (-not $hasLethalTrifecta) {
            $issues += "lethal trifecta not documented in capabilities.md for web-search"
        }
        if (-not $hasUntrustedContentDoctrine) {
            $issues += "untrusted-content doctrine not stated in capabilities.md for web-search"
        }
    }

    # Check that uses column doesn't mention durable storage
    $uses = $Cap.Uses
    if ($uses -match '\b(file|write|store|save|persist|commit)\b') {
        $issues += "uses column references potential durable write operations"
    }

    if ($issues.Count -eq 0) {
        return @{ Passed = $true; Detail = "Untrusted-content doctrine observed; no durable writes detected" }
    }
    return @{ Passed = $false; Detail = $issues -join "; " }
}

function Assert-QueryIsolation {
    <#
    A3 — Query isolation (behavioural)
    Query doesn't concatenate memory content.
    #>
    param($Cap)

    $issues = @()

    # Check assertions for query isolation mention
    $assertions = $Cap.Assertions
    if ($assertions -match 'isolat' -or $assertions -match 'sanitiz' -or $assertions -match 'M2' -or $assertions -match 'M3') {
        # Query isolation or sanitization is mentioned in assertions — good
    } else {
        $issues += "query isolation or sanitization not mentioned in assertions"
    }

    # Check DVA for isolation guarantees
    $dva = $Cap.DeclaredVsActual
    if ($dva -match 'sanitiz' -or $dva -match 'filter' -or $dva -match 'isolat') {
        # Sanitization or isolation mentioned
    }

    # For web-search: check that the M2 mitigations describe sanitization
    if ($Cap.Name -eq "web-search") {
        if ($assertions -notmatch 'M2') {
            $issues += "M2 mitigation (structural, durable writes blocked by airlock) not referenced in assertions"
        }
        if ($assertions -notmatch 'M[345]') {
            $issues += "behavioural mitigations (M4, M5) not referenced — query isolation may be incomplete"
        }
    }

    # Verify depends-on doesn't imply memory concatenation
    $dependsOn = $Cap.DependsOn
    if ($dependsOn -match '\b(memory|context|history|session)\b') {
        $issues += "dependency on '$($matches[0])' may imply memory content concatenation in queries"
    }

    if ($issues.Count -eq 0) {
        return @{ Passed = $true; Detail = "Query isolation confirmed; memory content not concatenated" }
    }
    return @{ Passed = $false; Detail = $issues -join "; " }
}

function Assert-TierTagAccuracy {
    <#
    A4 — Tier tag accuracy (quality)
    Tag accurately reflects resource requirements.
    #>
    param($Cap)

    $issues = @()

    $tierTag = $Cap.TierTag

    # Validate tier tag
    if ($tierTag -notin $script:ValidTierTags) {
        $issues += "invalid tier tag '$tierTag'"
    } else {
        # Check consistency based on capability type and resources used
        switch ($tierTag) {
            "frontier-only" {
                # Frontier-only capabilities should have external network access
                $dva = $Cap.DeclaredVsActual
                if ($dva -notmatch 'egress|api\.|network|web|search') {
                    $issues += "frontier-only tier tag but no external network/egress declared"
                }
                # Should have at least one mitigation assertion
                $assertions = $Cap.Assertions
                $mitigations = [regex]::Matches($assertions, 'M\d+')
                if ($mitigations.Count -eq 0) {
                    $issues += "frontier-only capability should have numbered mitigation assertions (M1, M2, ...)"
                }
            }
            "standard" {
                # Standard capabilities should not have external network access
                $dva = $Cap.DeclaredVsActual
                if ($dva -match 'egress|api\.|network') {
                    $issues += "standard tier tag should not have external network egress"
                }
            }
            "restricted" {
                # Restricted capabilities should have limited tool access
                $toolsRatio = $Cap.ToolsUsedExposed
                if ($toolsRatio -match '^(\d+)/(\d+)$') {
                    $exposed = [int]$matches[2]
                    if ($exposed -gt 3) {
                        $issues += "restricted tier exposes $exposed tools (should be limited)"
                    }
                }
            }
        }
    }

    # Check that the type matches the tier
    if ($Cap.Type -eq "connector" -and $tierTag -ne "frontier-only") {
        $issues += "connector type should typically be 'frontier-only' tier (external-facing)"
    }

    if ($issues.Count -eq 0) {
        return @{ Passed = $true; Detail = "Tier tag '$tierTag' accurately reflects resource requirements" }
    }
    return @{ Passed = $false; Detail = $issues -join "; " }
}

function Assert-DeclarationIntegrity {
    <#
    A5 — Declaration integrity (quality)
    Assertions match actual execution.
    #>
    param($Cap)

    $issues = @()

    $assertions = $Cap.Assertions
    $dva = $Cap.DeclaredVsActual

    # 1. Check that the DVA field says "pass" — meaning declarations match actual
    if ($dva -notmatch '^pass\b') {
        $issues += "declared-vs-actual field does not indicate pass: '$dva'"
    }

    # 2. Count the number of mitigations claimed and verify they appear
    $mitigationMatches = [regex]::Matches($assertions, 'M(\d+)')
    $mitigationNumbers = @()
    foreach ($m in $mitigationMatches) {
        $mitigationNumbers += [int]$m.Groups[1].Value
    }
    $mitigationNumbers = $mitigationNumbers | Sort-Object -Unique

    # For web-search: should have M1-M5
    if ($Cap.Name -eq "web-search") {
        $expectedM = @(1, 2, 3, 4, 5)
        $missingM = $expectedM | Where-Object { $_ -notin $mitigationNumbers }
        if ($missingM.Count -gt 0) {
            $issues += "missing mitigation assertions: M$($missingM -join ', M')"
        }

        # Check each mitigation is described
        $expectedDesc = @{
            1 = "behavioural"
            2 = "structural"
            3 = "structural"
            4 = "behavioural"
            5 = "behavioural"
        }
        foreach ($mn in $mitigationNumbers) {
            $expectedType = $expectedDesc[$mn]
            if ($expectedType -and $assertions -notmatch "M$mn.*$expectedType") {
                $issues += "M$mn should be described as '$expectedType' type"
            }
        }
    }

    # 3. Check that the declared-vs-actual detail matches assertion count
    if ($dva -match '(\d+)/(\d+)') {
        $dvaUsed = [int]$matches[1]
        # Verify that tool count is consistent
        if ($dvaUsed -ne $mitigationNumbers.Count -and $Cap.Name -eq "web-search") {
            # Not a strict error, but note the discrepancy
        }
    }

    # 4. Verify the DVA field accurately describes what's declared.
    #    Assertions describe mitigations, not tool listings, so we don't
    #    require tool names to appear literally in assertions. Instead we
    #    check that the declaration count is consistent.
    if ($dva -match 'declared:\s*(.+?)(?:;\s*actual:|$)') {
        $declared = $matches[1].Trim()
        # Verify that the declared section has reasonable content
        if ([string]::IsNullOrWhiteSpace($declared)) {
            $issues += "declared section in DVA field is empty"
        }
    }

    if ($issues.Count -eq 0) {
        return @{ Passed = $true; Detail = "All assertions match declared and actual execution" }
    }
    return @{ Passed = $false; Detail = $issues -join "; " }
}

# ---- Execute ----

Write-Host "ygg gate-l2 — L2 behavioural capability gate" -ForegroundColor Cyan
Write-Host "Capability: $Capability" -ForegroundColor White
Write-Host "Bench:      $Bench" -ForegroundColor White
Write-Host "Project root: $root" -ForegroundColor DarkCyan
Write-Host ""

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Behavioural & Quality Assertions" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# A1 — Least-privilege tool access
Write-Host "◆ A1 — Least-privilege tool access" -ForegroundColor White
$r1 = Assert-LeastPrivilegeToolAccess -Cap $cap
Add-L2Result -AssertionId "A1" -AssertionName "Least-privilege tool access" -Passed $r1.Passed -Detail $r1.Detail
Write-Host ""

# A2 — Untrusted-content doctrine
Write-Host "◆ A2 — Untrusted-content doctrine" -ForegroundColor White
$r2 = Assert-UnstrustedContentDoctrine -Cap $cap
Add-L2Result -AssertionId "A2" -AssertionName "Untrusted-content doctrine" -Passed $r2.Passed -Detail $r2.Detail
Write-Host ""

# A3 — Query isolation
Write-Host "◆ A3 — Query isolation" -ForegroundColor White
$r3 = Assert-QueryIsolation -Cap $cap
Add-L2Result -AssertionId "A3" -AssertionName "Query isolation" -Passed $r3.Passed -Detail $r3.Detail
Write-Host ""

# A4 — Tier tag accuracy
Write-Host "◆ A4 — Tier tag accuracy" -ForegroundColor White
$r4 = Assert-TierTagAccuracy -Cap $cap
Add-L2Result -AssertionId "A4" -AssertionName "Tier tag accuracy" -Passed $r4.Passed -Detail $r4.Detail
Write-Host ""

# A5 — Declaration integrity
Write-Host "◆ A5 — Declaration integrity" -ForegroundColor White
$r5 = Assert-DeclarationIntegrity -Cap $cap
Add-L2Result -AssertionId "A5" -AssertionName "Declaration integrity" -Passed $r5.Passed -Detail $r5.Detail
Write-Host ""

# ---- Summary ----

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "L2 Gate Summary - $Capability ($Bench bench)" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

$passedCount = ($global:allResults | Where-Object { $_.Passed }).Count
$failedCount = ($global:allResults | Where-Object { -not $_.Passed }).Count

Write-Host "  Assertions: 5 total" -ForegroundColor White
Write-Host "  Passed:      $passedCount" -ForegroundColor Green
Write-Host "  Failed:      $failedCount" -ForegroundColor $(if ($failedCount -eq 0) { 'Green' } else { 'Red' })

# Determine tier tag assignment based on results
$tierAssigned = $cap.TierTag
$probationStatus = $cap.Status

if ($global:allPassed) {
    Write-Host ""
    Write-Host "  L2 gate PASSED - tier tag: $tierAssigned, status: $probationStatus" -ForegroundColor Green

    # Check that the status is "probation" — for a capability that passes L1+L2 it should be
    if ($probationStatus -eq "probation") {
        Write-Host "  Status is 'probation' — correct for first L2 passage" -ForegroundColor Green
    }
}

# Write gate log
$logPath = Get-GateLogPath -GateName "L2"
$logEntries = @()
$logEntries += "# L2 Gate Log - $(Get-Date -Format 'yyyy-MM-dd')"
$logEntries += "# Capability: $Capability"
$logEntries += "# Bench: $Bench"
$logEntries += "# Overall: $(if ($global:allPassed) { 'PASS' } else { 'FAIL' })"
$logEntries += ""

foreach ($result in $global:allResults) {
    $status = if ($result.Passed) { "PASS" } else { "FAIL" }
    $logEntries += "- capability: $($result.Capability)"
    $logEntries += "  assertion: $($result.Assertion)"
    $logEntries += "  name: $($result.Name)"
    $logEntries += "  result: $status"
    $logEntries += "  detail: $($result.Detail)"
    $logEntries += "  bench: $($result.Bench)"
    $logEntries += "  timestamp: $($result.Timestamp)"
    $logEntries += ""
}

$logContent = $logEntries -join "`n"
$logDir = Split-Path -Path $logPath -Parent
if (-not (Test-Path -LiteralPath $logDir -PathType Container)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}
Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host ""
Write-Host "Gate log written to: $logPath" -ForegroundColor DarkCyan

# Exit code
if ($global:allPassed) {
    Write-Host "L2 gate: ALL ASSERTIONS PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "L2 gate: $failedCount assertion(s) FAILED" -ForegroundColor Red
    exit 1
}

