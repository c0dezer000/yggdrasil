# ygg gate-l1 — L1 static capability gate
<#
.SYNOPSIS
  L1 static gate: schema validity, host loadability, trigger overlap,
  declared-vs-actual, and under-declaration flag.

.DESCRIPTION
  Usage:
    ygg gate-l1 --capability <name>    Check one capability
    ygg gate-l1 --list                  List all capabilities in registry
    ygg gate-l1 --all                   Check every capability

  Each check outputs PASS/FAIL. Exits 0 on all pass, 1 on any fail.

  Checks:
    1. Schema validity       — 12 columns populated, valid types/patterns
    2. Host loadability      — referenced file paths exist, tools available
    3. Trigger overlap       — no other entry uses the same trigger
    4. Declared vs actual    — tool/path/network usage fits declarations
    5. Under-declaration flag — paranoid re-check for hidden paths/mismatches
#>

param(
    [string]$Capability = "",
    [switch]$List,
    [switch]$All
)

# Collect ALL tokens from both param-bound $Capability and $args.
# The dispatcher passes strings positionally, so --flags get bound to
# string params. We flatten everything and re-parse.
$allTokens = @()
if ($Capability) { $allTokens += $Capability }
$allTokens += $args

$resolvedCapability = ""
$resolvedList = $List.IsPresent  # in case -List was used as true switch
$resolvedAll = $All.IsPresent

for ($i = 0; $i -lt $allTokens.Count; $i++) {
    $token = $allTokens[$i]
    if ($token -eq '--list') {
        $resolvedList = $true
    } elseif ($token -eq '--all') {
        $resolvedAll = $true
    } elseif ($token -eq '--capability' -and $i + 1 -lt $allTokens.Count) {
        $resolvedCapability = $allTokens[++$i]
    } elseif ($token -match '^--capability=(.+)') {
        $resolvedCapability = $matches[1]
    } elseif (-not $resolvedCapability -and $token -notmatch '^--') {
        # Plain positional value (could be the capability name)
        $resolvedCapability = $token
    }
}

$Capability = $resolvedCapability
$List = $resolvedList
$All = $resolvedAll

# Dot-source common module
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
. (Join-Path -Path $scriptDir -ChildPath "ygg-gate-common.ps1")

$root = Get-ProjectRoot
$registryPath = Join-Path -Path $root -ChildPath "seed\memory\capabilities.md"

# ---- --list: enumerate capabilities ----

if ($List) {
    $registry = Get-CapabilitiesRegistry -RegistryPath $registryPath
    Write-Host "ygg gate-l1 -- capabilities in registry" -ForegroundColor Cyan
    Write-Host ""

    if ($registry.Capabilities.Count -eq 0) {
        Write-Host "  (no capabilities found)" -ForegroundColor Yellow
        exit 0
    }

    Write-Host "  $($registry.Capabilities.Count) capability(ies) registered" -ForegroundColor White
    Write-Host ""
    foreach ($cap in $registry.Capabilities) {
        $statusColor = switch ($cap.Status) {
            "active"    { "Green" }
            "probation" { "Yellow" }
            "deprecated" { "DarkGray" }
            "rejected"  { "Red" }
            default     { "Gray" }
        }
        Write-Host "  $($cap.Name)" -ForegroundColor Cyan -NoNewline
        Write-Host "  type=$($cap.Type)  tier=$($cap.TierTag)  status=$($cap.Status)" -ForegroundColor $statusColor
        Write-Host "         tools: $($cap.ToolsUsedExposed)  depends: $($cap.DependsOn)  uses: $($cap.Uses)"
    }
    exit 0
}

# ---- Determine which capabilities to check ----

$registry = Get-CapabilitiesRegistry -RegistryPath $registryPath

if ($All) {
    $targets = $registry.Capabilities
} elseif ($Capability) {
    $match = $registry.Capabilities | Where-Object { $_.Name -eq $Capability }
    if (-not $match) {
        Write-Host "ERROR: Capability '$Capability' not found in registry." -ForegroundColor Red
        Write-Host "Use 'ygg gate-l1 --list' to see available capabilities." -ForegroundColor Yellow
        exit 1
    }
    $targets = @($match)
} else {
    Write-Host "Usage: ygg gate-l1 --capability <name> | --list | --all" -ForegroundColor Yellow
    exit 1
}

# ---- Run gate checks ----

$global:allPassed = $true
$global:allResults = @()

function Add-GateResult {
    param([string]$Cap, [int]$CheckNum, [string]$CheckName, [bool]$Passed, [string]$Detail = "")
    Write-GateResult -CheckName "C$CheckNum - $CheckName" -Passed $Passed -Detail $Detail -Gate "L1"
    if (-not $Passed) { $global:allPassed = $false }

    $global:allResults += [PSCustomObject]@{
        Capability = $Cap
        Check      = "C$CheckNum"
        Name       = $CheckName
        Passed     = $Passed
        Detail     = $Detail
        Timestamp  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }
}

function Get-FileRefsFromCap {
    <#
    .SYNOPSIS
      Extract file path references from a capability's source/provenance column.
    #>
    param($Cap)
    $refs = @()
    $src = $Cap.SourceProvenance
    # Match paths like seed/memory/staging.md, seed/memory/provenance.md
    $m = [regex]::Matches($src, '[a-zA-Z0-9_/.-]+\.md')
    foreach ($mm in $m) {
        $refs += $mm.Value
    }
    # Also check the depends-on and uses columns for path references
    $depends = $Cap.DependsOn
    $m2 = [regex]::Matches($depends, '[a-zA-Z0-9_/.-]+\.md')
    foreach ($mm in $m2) {
        $refs += $mm.Value
    }
    $uses = $Cap.Uses
    $m3 = [regex]::Matches($uses, '[a-zA-Z0-9_/.-]+\.md')
    foreach ($mm in $m3) {
        $refs += $mm.Value
    }
    return ($refs | Select-Object -Unique)
}

function Get-ToolsFromCap {
    <#
    .SYNOPSIS
      Extract tool names from a capability (depends-on and uses columns).
    #>
    param($Cap)
    $tools = @()
    # depends-on and uses columns list tools
    $depends = $Cap.DependsOn
    $uses = $Cap.Uses
    # Split on commas, semicolons, and
    $text = "$depends $uses"
    # Common tool names end with "tool", "skill", or are known names
    $m = [regex]::Matches($text, '\b(\w+(?:\s+\w+)*)\b')
    foreach ($mm in $m) {
        $t = $mm.Value.Trim()
        if ($t -match '(tool|skill|api|agent)$' -or
            $t -in @('webfetch', 'read', 'write', 'glob', 'grep', 'bash', 'edit')) {
            $tools += $t
        }
    }
    return ($tools | Select-Object -Unique)
}

function Get-TriggerFromCap {
    <#
    .SYNOPSIS
      Extract trigger/s from a capability's uses/depends columns.
      A trigger is a phrase like "research skill (huginn)" or "webfetch tool".
    #>
    param($Cap)
    $triggers = @()
    # Uses column: "research skill (huginn)"
    if ($Cap.Uses -match '(\w+(?:\s+\w+)*)\s*\(?(\w+)?\)?') {
        $triggers += $Cap.Uses.Trim()
    }
    # Depends-on column
    if ($Cap.DependsOn) {
        $triggers += $Cap.DependsOn.Trim()
    }
    return ($triggers | Where-Object { $_ -ne "" } | Select-Object -Unique)
}

# ---- Check functions ----

function Test-SchemaValidity {
    param($Cap)

    $issues = @()

    # Check all 12 columns are populated
    if ([string]::IsNullOrWhiteSpace($Cap.Name)) { $issues += "name is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.Type)) { $issues += "type is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.Version)) { $issues += "version is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.SourceProvenance)) { $issues += "source/provenance is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.Ratified)) { $issues += "ratified is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.Assertions)) { $issues += "assertions is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.DeclaredVsActual)) { $issues += "declared-vs-actual is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.ToolsUsedExposed)) { $issues += "tools used/exposed is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.TierTag)) { $issues += "tier tag is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.DependsOn)) { $issues += "depends on is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.Uses)) { $issues += "uses is empty" }
    if ([string]::IsNullOrWhiteSpace($Cap.Status)) { $issues += "status is empty" }

    # Validate column count (12 expected)
    if ($Cap.ColumnCount -lt 12) {
        $issues += "only $($Cap.ColumnCount) columns (expected 12)"
    }

    # Validate type
    if ($Cap.Type -and $Cap.Type -notin $script:ValidTypes) {
        $issues += "invalid type '$($Cap.Type)' (valid: $($script:ValidTypes -join ', '))"
    }

    # Validate status
    if ($Cap.Status -and $Cap.Status -notin $script:ValidStatuses) {
        $issues += "invalid status '$($Cap.Status)' (valid: $($script:ValidStatuses -join ', '))"
    }

    # Validate tier tag
    if ($Cap.TierTag -and $Cap.TierTag -notin $script:ValidTierTags) {
        $issues += "invalid tier tag '$($Cap.TierTag)' (valid: $($script:ValidTierTags -join ', '))"
    }

    # Validate tools-used/exposed format (should be like "1/1" or "2/3")
    if ($Cap.ToolsUsedExposed -notmatch '^\d+/\d+$') {
        $issues += "tools used/exposed '$($Cap.ToolsUsedExposed)' does not match format 'N/N'"
    }

    # Validate ratified is a date-like string
    if ($Cap.Ratified -and $Cap.Ratified -notmatch '\d{4}-\d{2}-\d{2}') {
        $issues += "ratified '$($Cap.Ratified)' is not a date (expected YYYY-MM-DD)"
    }

    if ($issues.Count -eq 0) {
        return @{ Passed = $true; Detail = "All 12 columns valid" }
    }
    return @{ Passed = $false; Detail = $issues -join "; " }
}

function Test-HostLoadability {
    param($Cap)

    $issues = @()

    # 1. Check referenced file paths exist
    $refs = Get-FileRefsFromCap -Cap $Cap
    foreach ($ref in $refs) {
        $fullPath = Join-Path -Path $root -ChildPath $ref
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            $issues += "referenced file not found: $ref"
        }
    }

    # 2. Check specific paths for web-search capability
    if ($Cap.Name -eq "web-search") {
        # Research skill
        $researchSkill = Join-Path -Path $env:USERPROFILE -ChildPath ".config\opencode\skills\research\SKILL.md"
        if (-not (Test-Path -LiteralPath $researchSkill -PathType Leaf)) {
            $issues += "research skill not found at expected path: $researchSkill"
        }

        # Huginn agent file
        $huginnPath = Join-Path -Path $root -ChildPath "seed\adapters\opencode\agents\huginn.md"
        if (-not (Test-Path -LiteralPath $huginnPath -PathType Leaf)) {
            $issues += "huginn agent file not found: $huginnPath"
        }

        # webfetch tool availability — built-in opencode host tool (not a config entry)
        # Verify by checking the research skill references webfetch
        if (Test-Path -LiteralPath $researchSkill -PathType Leaf) {
            $skillContent = Get-Content -Path $researchSkill -Raw -Encoding UTF8
            if ($skillContent -notmatch 'webfetch|URL|fetch|web') {
                $issues += "research skill does not reference web fetching capability"
            }
        }
    }

    # 3. Check referenced agents exist as files
    $uses = $Cap.Uses
    if ($uses -match '\((\w+)\)') {
        $agentName = $matches[1]
        $agentPath = Join-Path -Path $root -ChildPath "seed\adapters\opencode\agents\$agentName.md"
        if (-not (Test-Path -LiteralPath $agentPath -PathType Leaf)) {
            $issues += "referenced agent '$agentName' file not found at: seed\adapters\opencode\agents\$agentName.md"
        }
    }

    if ($issues.Count -eq 0) {
        return @{ Passed = $true; Detail = "All referenced paths exist, tools loadable" }
    }
    return @{ Passed = $false; Detail = $issues -join "; " }
}

function Test-TriggerOverlap {
    param($Cap, $AllCaps)

    $issues = @()
    $myTriggers = Get-TriggerFromCap -Cap $Cap

    foreach ($other in $AllCaps) {
        if ($other.Name -eq $Cap.Name) { continue }
        $otherTriggers = Get-TriggerFromCap -Cap $other

        foreach ($mt in $myTriggers) {
            foreach ($ot in $otherTriggers) {
                if ($mt -eq $ot) {
                    $issues += "trigger '$mt' also used by capability '$($other.Name)'"
                }
            }
        }
    }

    if ($issues.Count -eq 0) {
        return @{ Passed = $true; Detail = "No trigger overlap detected" }
    }
    return @{ Passed = $false; Detail = $issues -join "; " }
}

function Test-DeclaredVsActual {
    param($Cap)

    $issues = @()

    # Parse the declared-vs-actual column
    $dva = $Cap.DeclaredVsActual

    # Expected format: "pass (declared: ...; actual: ...)" or "fail (...)"
    $declaredSection = if ($dva -match 'declared:\s*(.+?)(?:;\s*actual:|$)') { $matches[1].Trim() } else { "" }
    $actualSection = if ($dva -match 'actual:\s*(.+)') { $matches[1].Trim() -replace '\)$', '' } else { "" }

    # 1. Check tools ratio: tools used <= tools exposed
    $toolsRatio = $Cap.ToolsUsedExposed
    if ($toolsRatio -match '^(\d+)/(\d+)$') {
        $used = [int]$matches[1]
        $exposed = [int]$matches[2]
        if ($used -gt $exposed) {
            $issues += "tools used ($used) exceeds tools exposed ($exposed)"
        }
    }

    # 2. Check declared vs actual match
    if ($declaredSection -and $actualSection) {
        # Check if actual usage is a subset of declared
        # Extract declared tools/egress from the declared section
        $declaredTools = @()
        $declaredEgress = @()
        if ($declaredSection -match 'webfetch') { $declaredTools += "webfetch" }
        if ($declaredSection -match 'egress to ([^\s;]+)') { $declaredEgress += $matches[1] }

        # Extract actual tools/egress from actual section
        $actualTools = @()
        $actualEgress = @()
        if ($actualSection -match 'webfetch') { $actualTools += "webfetch" }
        if ($actualSection -match 'egress to ([^\s;]+)') { $actualEgress += $matches[1] }

        # Check: every actual tool must be declared
        foreach ($at in $actualTools) {
            if ($at -notin $declaredTools) {
                $issues += "actual tool '$at' not declared"
            }
        }

        # Check: every actual egress target must be declared
        foreach ($ae in $actualEgress) {
            if ($ae -notin $declaredEgress) {
                $issues += "actual egress to '$ae' not declared"
            }
        }
    } else {
        # Parse the DVA field differently — look for "pass" or "fail" prefix
        if ($dva -match '^pass\b') {
            # The field says pass, which means declared matches actual
            # Still verify no under-declaration
        } elseif ($dva -match '^fail\b') {
            $issues += "declared-vs-actual column reports FAIL"
        }
    }

    # 3. Check that the status is consistent
    # If DVA is "pass" but status is "rejected", flag it
    if ($dva -match '^pass\b' -and $Cap.Status -eq 'rejected') {
        $issues += "declared-vs-actual is 'pass' but status is 'rejected' (inconsistent)"
    }

    if ($issues.Count -eq 0) {
        return @{ Passed = $true; Detail = "Declared and actual usage match; tools/exposed ratio valid" }
    }
    return @{ Passed = $false; Detail = $issues -join "; " }
}

function Test-UnderDeclaration {
    param($Cap)

    $issues = @()

    # Paranoid re-check for hidden paths, tool usage mismatches, undeclared egress

    # 1. Check source/provenance for hidden or unexpected file references
    $src = $Cap.SourceProvenance
    # Look for references outside seed/
    $extRefs = [regex]::Matches($src, '(?:\.\./|[A-Z]:\\)')
    if ($extRefs.Count -gt 0) {
        $issues += "source/provenance contains external references: $($extRefs.Value -join ', ')"
    }

    # 2. Check depends-on for undeclared dependencies
    $depends = $Cap.DependsOn
    if ($depends -match ',') {
        # Multiple dependencies — verify each is described in assertions
        $deps = $depends -split ',' | ForEach-Object { $_.Trim() }
        $assertions = $Cap.Assertions
        foreach ($d in $deps) {
            if ($d -and $assertions -notmatch [regex]::Escape($d)) {
                $issues += "dependency '$d' not mentioned in assertions"
            }
        }
    }

    # 3. Check tools-used/exposed for over-provisioning
    $toolsRatio = $Cap.ToolsUsedExposed
    if ($toolsRatio -match '^(\d+)/(\d+)$') {
        $used = [int]$matches[1]
        $exposed = [int]$matches[2]
        if ($exposed -gt $used * 2 -and $used -gt 0) {
            $issues += "over-provisioning: $used tools used but $exposed exposed (ratio > 2x)"
        }
    }

    # 4. For web-search, check egress is properly declared
    if ($Cap.Name -eq "web-search") {
        $dva = $Cap.DeclaredVsActual
        if ($dva -notmatch 'api\.duckduckgo\.com') {
            $issues += "egress target api.duckduckgo.com not declared in declared-vs-actual column"
        }
        # Check that the uses column mentions the research skill
        if ($Cap.Uses -notmatch 'research') {
            $issues += "uses column should mention research skill"
        }
    }

    # 5. Check for missing version updates
    if ($Cap.Version -eq "1" -and $Cap.Status -ne "deprecated") {
        # Single-version capabilities that aren't deprecated — acceptable
    }

    if ($issues.Count -eq 0) {
        return @{ Passed = $true; Detail = "No under-declaration or hidden issues found" }
    }
    return @{ Passed = $false; Detail = $issues -join "; " }
}

# ---- Execute checks for each target ----

Write-Host "ygg gate-l1 — L1 static capability gate" -ForegroundColor Cyan
Write-Host "Project root: $root" -ForegroundColor DarkCyan
Write-Host ""

foreach ($cap in $targets) {
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Capability: $($cap.Name)" -ForegroundColor White
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    # Check 1: Schema validity
    Write-Host "◆ Check 1 — Schema validity" -ForegroundColor White
    $r1 = Test-SchemaValidity -Cap $cap
    Add-GateResult -Cap $cap.Name -CheckNum 1 -CheckName "Schema validity" -Passed $r1.Passed -Detail $r1.Detail
    Write-Host ""

    # Check 2: Host loadability
    Write-Host "◆ Check 2 — Host loadability" -ForegroundColor White
    $r2 = Test-HostLoadability -Cap $cap
    Add-GateResult -Cap $cap.Name -CheckNum 2 -CheckName "Host loadability" -Passed $r2.Passed -Detail $r2.Detail
    Write-Host ""

    # Check 3: Trigger overlap
    Write-Host "◆ Check 3 — Trigger overlap" -ForegroundColor White
    $r3 = Test-TriggerOverlap -Cap $cap -AllCaps $registry.Capabilities
    Add-GateResult -Cap $cap.Name -CheckNum 3 -CheckName "Trigger overlap" -Passed $r3.Passed -Detail $r3.Detail
    Write-Host ""

    # Check 4: Declared vs actual
    Write-Host "◆ Check 4 — Declared vs actual" -ForegroundColor White
    $r4 = Test-DeclaredVsActual -Cap $cap
    Add-GateResult -Cap $cap.Name -CheckNum 4 -CheckName "Declared vs actual" -Passed $r4.Passed -Detail $r4.Detail
    Write-Host ""

    # Check 5: Under-declaration flag
    Write-Host "◆ Check 5 — Under-declaration flag" -ForegroundColor White
    $r5 = Test-UnderDeclaration -Cap $cap
    Add-GateResult -Cap $cap.Name -CheckNum 5 -CheckName "Under-declaration flag" -Passed $r5.Passed -Detail $r5.Detail
    Write-Host ""
}

# ---- Summary ----

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "L1 Gate Summary" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

$passedCount = ($global:allResults | Where-Object { $_.Passed }).Count
$failedCount = ($global:allResults | Where-Object { -not $_.Passed }).Count
$totalCount = $global:allResults.Count

Write-Host "  Total checks: $totalCount" -ForegroundColor White
Write-Host "  Passed:       $passedCount" -ForegroundColor Green
Write-Host "  Failed:       $failedCount" -ForegroundColor $(if ($failedCount -eq 0) { 'Green' } else { 'Red' })

# Write gate log
$logPath = Get-GateLogPath -GateName "L1"
$logEntries = @()
$logEntries += "# L1 Gate Log - $(Get-Date -Format 'yyyy-MM-dd')"
$logEntries += "# Capability: $($targets.Count) capability(ies) checked"
$logEntries += ""

foreach ($result in $global:allResults) {
    $status = if ($result.Passed) { "PASS" } else { "FAIL" }
    $logEntries += "- capability: $($result.Capability)"
    $logEntries += "  check: $($result.Check)"
    $logEntries += "  name: $($result.Name)"
    $logEntries += "  result: $status"
    $logEntries += "  detail: $($result.Detail)"
    $logEntries += "  timestamp: $($result.Timestamp)"
    $logEntries += ""
}

$logContent = $logEntries -join "`n"
# Ensure directory exists
$logDir = Split-Path -Path $logPath -Parent
if (-not (Test-Path -LiteralPath $logDir -PathType Container)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}
Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "Gate log written to: $logPath" -ForegroundColor DarkCyan
Write-Host ""

# Exit code
if ($global:allPassed) {
    Write-Host "L1 gate: ALL CHECKS PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "L1 gate: $failedCount check(s) FAILED" -ForegroundColor Red
    exit 1
}

