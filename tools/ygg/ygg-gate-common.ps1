# ygg-gate-common.ps1 — Shared functions for L1 and L2 capability gates
<#
.SYNOPSIS
  Shared module for parsing capabilities.md, extracting table rows, and common
  validation utilities used by both gate-l1 and gate-l2.

.DESCRIPTION
  This file is dot-sourced by both gate scripts. It provides:
    - Get-CapabilitiesRegistry     — parse capabilities.md into structured objects
    - Get-CapabilityByName         — return one capability by name
    - Get-ProjectRoot              — locate project root via .ygg marker
    - Write-GateResult             — standardised pass/fail output
#>

# ---- Path resolution ----

$script:CommonScriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

function Get-ProjectRoot {
    <#
    .SYNOPSIS
      Walk up from the current directory until we find the .ygg marker file.
    #>
    $probe = Get-Location
    $dir = $probe
    while ($dir -and (Test-Path -LiteralPath $dir)) {
        $yggPath = Join-Path -Path $dir -ChildPath ".ygg"
        if (Test-Path -LiteralPath $yggPath -PathType Leaf) {
            return $dir
        }
        $parent = Split-Path -Path $dir -Parent
        if ($parent -eq $dir) { break }
        $dir = $parent
    }
    return $probe
}

# ---- Capabilities registry parsing ----

$script:RequiredColumns = @(
    "name",
    "type",
    "version",
    "source / provenance",
    "ratified",
    "assertions",
    "declared-vs-actual",
    "tools used / exposed",
    "tier tag",
    "depends on",
    "uses",
    "status"
)

$script:ValidTypes = @("connector", "skill", "role", "tool")
$script:ValidStatuses = @("probation", "active", "deprecated", "rejected")
$script:ValidTierTags = @("frontier-only", "standard", "restricted")

function Get-CapabilitiesRegistry {
    <#
    .SYNOPSIS
      Parse seed/memory/capabilities.md and return an array of capability objects.

    .DESCRIPTION
      Each capability object has properties matching the 12 columns, plus a
      RawRow property with the original table row text.

    .PARAMETER RegistryPath
      Optional explicit path to capabilities.md. Defaults to seed/memory/capabilities.md
      under the project root.
    #>
    param(
        [string]$RegistryPath = ""
    )

    if ([string]::IsNullOrEmpty($RegistryPath)) {
        $root = Get-ProjectRoot
        $RegistryPath = Join-Path -Path $root -ChildPath "seed\memory\capabilities.md"
    }

    if (-not (Test-Path -LiteralPath $RegistryPath -PathType Leaf)) {
        Write-Error "Capabilities registry not found at: $RegistryPath"
        return @()
    }

    $content = Get-Content -Path $RegistryPath -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($content)) {
        Write-Error "Capabilities registry is empty."
        return @()
    }

    $lines = $content -split "`n"
    $inTable = $false
    $headerLine = $null
    $headerIndex = -1
    $dataRows = @()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        # Detect table start — a line starting with | and containing --- separator pattern
        if ($line -match '^\|.*\|.*\|.*\|') {
            # Check if this is the separator line (contains :--- or ---)
            if ($line -match '^\|[\s:]*-+[\s:\|]') {
                $inTable = $true
                continue
            }

            if (-not $inTable) {
                # This is the header row
                $headerLine = $line
                $headerIndex = $i
                $inTable = $true
                continue
            }

            # This is a data row
            $dataRows += $line
        } else {
            # We've left the table
            if ($inTable -and $dataRows.Count -gt 0) {
                break
            }
            $inTable = $false
        }
    }

    # Parse header to get column names
    $headerCols = @()
    if ($headerLine) {
        # Split by pipe, trim each column
        $headerCols = $headerLine -split '\|' | ForEach-Object { $_.Trim() }
        # Remove first/last if empty (leading/trailing pipe)
        if ($headerCols.Count -gt 0 -and [string]::IsNullOrEmpty($headerCols[0])) {
            $headerCols = $headerCols[1..($headerCols.Count - 1)]
        }
        if ($headerCols.Count -gt 0 -and [string]::IsNullOrEmpty($headerCols[-1])) {
            $headerCols = $headerCols[0..($headerCols.Count - 2)]
        }
    }

    # Parse each data row into a capability object
    $capabilities = @()
    foreach ($row in $dataRows) {
        $cols = $row -split '\|' | ForEach-Object { $_.Trim() }
        # Remove first/last if empty
        if ($cols.Count -gt 0 -and [string]::IsNullOrEmpty($cols[0])) {
            $cols = $cols[1..($cols.Count - 1)]
        }
        if ($cols.Count -gt 0 -and [string]::IsNullOrEmpty($cols[-1])) {
            $cols = $cols[0..($cols.Count - 2)]
        }

        $cap = [PSCustomObject]@{
            Name             = if ($cols.Count -ge 1) { $cols[0] } else { "" }
            Type             = if ($cols.Count -ge 2) { $cols[1] } else { "" }
            Version          = if ($cols.Count -ge 3) { $cols[2] } else { "" }
            SourceProvenance = if ($cols.Count -ge 4) { $cols[3] } else { "" }
            Ratified         = if ($cols.Count -ge 5) { $cols[4] } else { "" }
            Assertions       = if ($cols.Count -ge 6) { $cols[5] } else { "" }
            DeclaredVsActual = if ($cols.Count -ge 7) { $cols[6] } else { "" }
            ToolsUsedExposed = if ($cols.Count -ge 8) { $cols[7] } else { "" }
            TierTag          = if ($cols.Count -ge 9) { $cols[8] } else { "" }
            DependsOn        = if ($cols.Count -ge 10) { $cols[9] } else { "" }
            Uses             = if ($cols.Count -ge 11) { $cols[10] } else { "" }
            Status           = if ($cols.Count -ge 12) { $cols[11] } else { "" }
            RawRow           = $row
            ColumnCount      = $cols.Count
        }
        $capabilities += $cap
    }

    # Validate columns
    $result = [PSCustomObject]@{
        Capabilities  = $capabilities
        HeaderColumns = $headerCols
        RequiredCount = $script:RequiredColumns.Count
        RegistryPath  = $RegistryPath
    }

    return $result
}

function Get-CapabilityByName {
    <#
    .SYNOPSIS
      Retrieve a single capability from the registry by name.
    #>
    param(
        [string]$Name,
        [string]$RegistryPath = ""
    )

    $registry = Get-CapabilitiesRegistry -RegistryPath $RegistryPath
    $match = $registry.Capabilities | Where-Object { $_.Name -eq $Name }
    if (-not $match) {
        return $null
    }
    return @{
        Registry   = $registry
        Capability = $match
    }
}

function Write-GateResult {
    <#
    .SYNOPSIS
      Standardised pass/fail output for gate checks.
    #>
    param(
        [string]$CheckName,
        [bool]$Passed,
        [string]$Detail = "",
        [string]$Gate = ""
    )

    $gateTag = if ($Gate) { "[$Gate] " } else { "" }
    if ($Passed) {
        Write-Host "  ${gateTag}[PASS] $CheckName" -ForegroundColor Green
    } else {
        Write-Host "  ${gateTag}[FAIL] $CheckName" -ForegroundColor Red
        if ($Detail) { Write-Host "         $Detail" -ForegroundColor DarkRed }
    }
}

function Get-GateLogPath {
    <#
    .SYNOPSIS
      Return the path to a gate log file.
    #>
    param(
        [string]$GateName  # "L1" or "L2"
    )

    $root = Get-ProjectRoot
    return Join-Path -Path $root -ChildPath "seed\memory\gate-log-$GateName.yaml"
}

# Functions are exported by dot-sourcing; Export-ModuleMember is not used.

