# ygg-regression-check.ps1 - Regression detection for staging ratification.
# Part of the ygg CLI suite.
<#
.SYNOPSIS
  Captures pre/post snapshots of doctor, provenance, and conformance state,
  then diffs them to detect regressions.
.DESCRIPTION
  Usage: ygg regression-check [pre|post] ["description of change"]

  pre   ["desc"]  - Capture pre-change snapshot to work/.regression-snapshot/
  post  ["desc"]  - Capture post-change snapshot, diff against pre, generate report

  Exit codes:
    0 - PASS  (no regressions, no changes detected)
    1 - FLAG  (non-critical changes detected, review recommended)
    2 - FAIL  (regression found, action required)
.EXAMPLE
  & .\ygg-regression-check.ps1 pre
  # ... make changes ...
  & .\ygg-regression-check.ps1 post "Added Y17 conformance assertion"
#>

# --- Parse arguments ---
$action = ""
$description = ""
if ($args.Count -gt 0) { $action = $args[0].ToLower() }
if ($args.Count -gt 1) { $description = $args[1] }

# --- Resolve project root ---
function Get-ProjectRoot {
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

$script:ProjectRoot = Get-ProjectRoot
$script:SnapshotDir = Join-Path -Path $script:ProjectRoot -ChildPath "work\.regression-snapshot"
$script:WorkDir = Join-Path -Path $script:ProjectRoot -ChildPath "work"

# Ensure directories exist
if (-not (Test-Path -LiteralPath $script:WorkDir)) {
    New-Item -ItemType Directory -Path $script:WorkDir -Force | Out-Null
}
if (-not (Test-Path -LiteralPath $script:SnapshotDir)) {
    New-Item -ItemType Directory -Path $script:SnapshotDir -Force | Out-Null
}

# --- UTF-8 without BOM writer ---
function Write-Utf8NoBom {
    param([string]$FilePath, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($FilePath, $Content, $utf8NoBom)
}

# --- Strip ANSI escape sequences ---
function Remove-AnsiEscapes {
    param([string]$Text)
    return ($Text -replace '\x1b\[\d+(?:;\d+)*m', '')
}

# ===================================================================
# SNAPSHOT FUNCTIONS
# ===================================================================

function Capture-DoctorSnapshot {
    param([string]$OutFile)

    $doctorScript = Join-Path -Path $script:ProjectRoot -ChildPath "tools\ygg\ygg-doctor.ps1"
    if (-not (Test-Path -LiteralPath $doctorScript)) {
        Write-Utf8NoBom -FilePath $OutFile -Content "ERROR: ygg-doctor.ps1 not found at $doctorScript`n"
        return
    }

    # Run doctor in a child process to isolate its exit code.
    # *>&1 inside the child captures all PS streams (including Write-Host) to stdout.
    # This is a PS redirection on a PS script, not 2>&1 on a native command.
    $psExe = Join-Path -Path $PSHOME -ChildPath "powershell.exe"
    $escapedPath = $doctorScript -replace "'", "''"
    $cmd = "& { & '$escapedPath' *>&1 }"
    $rawOutput = & $psExe -NoProfile -NonInteractive -Command $cmd

    # Join output lines and strip ANSI colour codes from redirected Write-Host
    $text = ($rawOutput -join "`n")
    $text = Remove-AnsiEscapes -Text $text
    if (-not $text.EndsWith("`n")) { $text += "`n" }

    Write-Utf8NoBom -FilePath $OutFile -Content $text
}

function Capture-ProvenanceSnapshot {
    param([string]$OutFile)

    $provenanceFile = Join-Path -Path $script:ProjectRoot -ChildPath "seed\memory\provenance.md"
    if (-not (Test-Path -LiteralPath $provenanceFile)) {
        Write-Utf8NoBom -FilePath $OutFile -Content "ERROR: provenance.md not found`n"
        return
    }

    $content = Get-Content -Path $provenanceFile -Raw
    $lines = $content -split "`n"

    # Find the standing counts table (starts with "| Domain |" header)
    $inTable = $false
    $tableLines = @()

    foreach ($line in $lines) {
        $trimmed = $line.Trim()

        # Detect header row
        if ($trimmed -match '^\|\s*Domain\s*\|') {
            $inTable = $true
            $tableLines += $trimmed
            continue
        }

        # Detect separator row
        if ($inTable -and $trimmed -match '^\|[\s:.-]+\|') {
            $tableLines += $trimmed
            continue
        }

        # Table data rows
        if ($inTable -and $trimmed -match '^\|') {
            $tableLines += $trimmed
            continue
        }

        # End of table (non-pipe line after table started)
        if ($inTable -and $trimmed -notmatch '^\|' -and $tableLines.Count -gt 2) {
            break
        }
    }

    $result = ($tableLines -join "`n") + "`n"
    Write-Utf8NoBom -FilePath $OutFile -Content $result
}

function Capture-ConformanceSnapshot {
    param([string]$OutFile)

    $conformanceDir = Join-Path -Path $script:ProjectRoot -ChildPath "seed\conformance"
    if (-not (Test-Path -LiteralPath $conformanceDir -PathType Container)) {
        Write-Utf8NoBom -FilePath $OutFile -Content "ERROR: conformance directory not found`n"
        return
    }

    $yFiles = Get-ChildItem -Path $conformanceDir -Filter "Y*.md" -File |
        Where-Object { $_.Name -match '^Y\d+' } |
        Sort-Object { [int]($_.BaseName -replace '^Y(\d+).*$', '$1') }

    $results = @()

    foreach ($f in $yFiles) {
        $content = Get-Content -Path $f.FullName -Raw
        $shortId = $f.BaseName -replace '^Y(\d+).*$', 'Y$1'

        # Detect ticked verdict checkboxes: - [x] PASS, - [X] FAIL, - [x] PARTIAL
        $hasTickedPass    = $content -match '(?m)^-\s*\[[xX]\]\s*PASS'
        $hasTickedFail    = $content -match '(?m)^-\s*\[[xX]\]\s*FAIL'
        $hasTickedPartial = $content -match '(?m)^-\s*\[[xX]\]\s*PARTIAL'

        $status = "untested"
        if ($hasTickedPass)         { $status = "PASS" }
        elseif ($hasTickedFail)     { $status = "FAIL" }
        elseif ($hasTickedPartial)  { $status = "PARTIAL" }

        $results += "$shortId|$status"
    }

    $result = ($results -join "`n") + "`n"
    Write-Utf8NoBom -FilePath $OutFile -Content $result
}

function Take-Snapshot {
    param([string]$Prefix)  # "pre" or "post"

    $doctorFile     = Join-Path -Path $script:SnapshotDir -ChildPath "$Prefix-doctor.txt"
    $provenanceFile = Join-Path -Path $script:SnapshotDir -ChildPath "$Prefix-provenance.txt"
    $conformanceFile = Join-Path -Path $script:SnapshotDir -ChildPath "$Prefix-conformance.txt"

    Write-Host "Capturing $Prefix-snapshot..." -ForegroundColor Cyan

    Write-Host "  [1/3] Doctor checks..." -ForegroundColor DarkGray -NoNewline
    Capture-DoctorSnapshot -OutFile $doctorFile
    Write-Host " done" -ForegroundColor DarkGray

    Write-Host "  [2/3] Provenance standing counts..." -ForegroundColor DarkGray -NoNewline
    Capture-ProvenanceSnapshot -OutFile $provenanceFile
    Write-Host " done" -ForegroundColor DarkGray

    Write-Host "  [3/3] Conformance assertions..." -ForegroundColor DarkGray -NoNewline
    Capture-ConformanceSnapshot -OutFile $conformanceFile
    Write-Host " done" -ForegroundColor DarkGray

    Write-Host "$Prefix-snapshot captured." -ForegroundColor Green
}

# ===================================================================
# DIFF FUNCTIONS
# ===================================================================

function Compare-DoctorSnapshots {
    param([string]$PreFile, [string]$PostFile)

    $result = @{
        PreStatus   = "no snapshot"
        PostStatus  = "no snapshot"
        Regression  = $false
        NewFailures = @()
    }

    if (-not (Test-Path -LiteralPath $PreFile))  { return $result }
    if (-not (Test-Path -LiteralPath $PostFile)) { return $result }

    $preContent  = Get-Content -Path $PreFile  -Raw
    $postContent = Get-Content -Path $PostFile -Raw

    # Extract summary line: "Summary: X passed, Y failed"
    $preMatch  = [regex]::Match($preContent,  'Summary:\s*(\d+)\s*passed,\s*(\d+)\s*failed')
    $postMatch = [regex]::Match($postContent, 'Summary:\s*(\d+)\s*passed,\s*(\d+)\s*failed')

    if ($preMatch.Success) {
        $result.PreStatus = "$($preMatch.Groups[1].Value) passed, $($preMatch.Groups[2].Value) failed"
    }
    if ($postMatch.Success) {
        $result.PostStatus = "$($postMatch.Groups[1].Value) passed, $($postMatch.Groups[2].Value) failed"
    }

    # Extract individual [FAIL] check names from each snapshot
    $preFailNames  = @()
    $postFailNames = @()

    $preFailMatches  = [regex]::Matches($preContent,  '\[FAIL\]\s+([^\n]+)')
    $postFailMatches = [regex]::Matches($postContent, '\[FAIL\]\s+([^\n]+)')

    foreach ($m in $preFailMatches)  { $preFailNames  += $m.Groups[1].Value.Trim() }
    foreach ($m in $postFailMatches) { $postFailNames += $m.Groups[1].Value.Trim() }

    # New failures = in post but not in pre
    foreach ($pf in $postFailNames) {
        if ($preFailNames -notcontains $pf) {
            $result.NewFailures += $pf
            $result.Regression = $true
        }
    }

    return $result
}

function Parse-ProvenanceTable {
    param([string]$Content)

    $rows = @{}
    $lines = $Content -split "`n"

    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        # Skip header and separator
        if ($trimmed -match '^\|\s*Domain\s*\|') { continue }
        if ($trimmed -match '^\|[\s:.-]+\|') { continue }

        if ($trimmed -match '^\|') {
            # Split by pipe, trim, remove empty entries from leading/trailing pipes
            $cols = $trimmed -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
            if ($cols.Count -ge 2) {
                $domain = $cols[0]
                # Store columns 1-4 (numeric counts) and column 6 (autonomy status)
                $encounters  = if ($cols.Count -gt 1) { $cols[1] } else { "?" }
                $stops       = if ($cols.Count -gt 2) { $cols[2] } else { "?" }
                $overrides   = if ($cols.Count -gt 3) { $cols[3] } else { "?" }
                $corrections = if ($cols.Count -gt 4) { $cols[4] } else { "?" }
                $autonomy    = if ($cols.Count -gt 6) { $cols[6] } else { "?" }

                $rows[$domain] = @{
                    Encounters  = $encounters
                    Stops       = $stops
                    Overrides   = $overrides
                    Corrections = $corrections
                    Autonomy    = $autonomy
                    Raw         = $trimmed
                }
            }
        }
    }
    return $rows
}

function Compare-ProvenanceSnapshots {
    param([string]$PreFile, [string]$PostFile)

    $result = @{
        Changed        = $false
        AddedDomains   = @()
        RemovedDomains = @()
        ChangedDomains = @()
        PreRows        = @{}
        PostRows       = @{}
    }

    if (-not (Test-Path -LiteralPath $PreFile))  { return $result }
    if (-not (Test-Path -LiteralPath $PostFile)) { return $result }

    $preContent  = Get-Content -Path $PreFile  -Raw
    $postContent = Get-Content -Path $PostFile -Raw

    $result.PreRows  = Parse-ProvenanceTable -Content $preContent
    $result.PostRows = Parse-ProvenanceTable -Content $postContent

    # Find added and changed domains
    foreach ($domain in $result.PostRows.Keys) {
        if (-not $result.PreRows.ContainsKey($domain)) {
            $result.AddedDomains += $domain
            $result.Changed = $true
        } else {
            $preRaw  = $result.PreRows[$domain].Raw
            $postRaw = $result.PostRows[$domain].Raw
            if ($preRaw -ne $postRaw) {
                $result.ChangedDomains += $domain
                $result.Changed = $true
            }
        }
    }

    # Find removed domains
    foreach ($domain in $result.PreRows.Keys) {
        if (-not $result.PostRows.ContainsKey($domain)) {
            $result.RemovedDomains += $domain
            $result.Changed = $true
        }
    }

    return $result
}

function Compare-ConformanceSnapshots {
    param([string]$PreFile, [string]$PostFile)

    $result = @{
        Changed     = $false
        Changes     = @()
        Regressions = @()
    }

    if (-not (Test-Path -LiteralPath $PreFile))  { return $result }
    if (-not (Test-Path -LiteralPath $PostFile)) { return $result }

    $preLines  = Get-Content -Path $PreFile
    $postLines = Get-Content -Path $PostFile

    $preStatus  = @{}
    $postStatus = @{}

    foreach ($line in $preLines) {
        if ($line -match '^(Y\d+)\|(.+)$') {
            $preStatus[$Matches[1]] = $Matches[2].Trim()
        }
    }

    foreach ($line in $postLines) {
        if ($line -match '^(Y\d+)\|(.+)$') {
            $postStatus[$Matches[1]] = $Matches[2].Trim()
        }
    }

    # Check for changes in existing and new assertions
    foreach ($id in ($postStatus.Keys | Sort-Object)) {
        if (-not $preStatus.ContainsKey($id)) {
            $result.Changes += "New assertion $id ($($postStatus[$id]))"
            $result.Changed = $true
        } elseif ($preStatus[$id] -ne $postStatus[$id]) {
            $old = $preStatus[$id]
            $new = $postStatus[$id]
            $changeDesc = "$id : $old -> $new"
            $result.Changes += $changeDesc
            $result.Changed = $true

            # Regression: PASS/PARTIAL -> untested/FAIL, or untested -> FAIL
            if ($new -eq "FAIL") {
                $result.Regressions += $changeDesc
            } elseif ($old -eq "PASS" -and $new -ne "PASS") {
                $result.Regressions += $changeDesc
            }
        }
    }

    # Check for removed assertions
    foreach ($id in ($preStatus.Keys | Sort-Object)) {
        if (-not $postStatus.ContainsKey($id)) {
            $changeDesc = "Removed assertion $id (was $($preStatus[$id]))"
            $result.Changes += $changeDesc
            $result.Regressions += $changeDesc
            $result.Changed = $true
        }
    }

    return $result
}

# ===================================================================
# REPORT GENERATION
# ===================================================================

function Generate-Report {
    param(
        [hashtable]$DoctorDiff,
        [hashtable]$ProvenanceDiff,
        [hashtable]$ConformanceDiff,
        [string]$ChangeDescription
    )

    $now = Get-Date
    $dateStamp = $now.ToString("yyyy-MM-dd")
    $timeStamp = $now.ToString("yyyy-MM-dd HH:mm")
    $reportFile = Join-Path -Path $script:WorkDir -ChildPath "regression-$dateStamp.md"

    # Determine verdict
    $hasRegression = $false
    $hasFlag = $false

    # Doctor regressions
    if ($DoctorDiff.Regression) { $hasRegression = $true }

    # Provenance: removed domains = regression, other changes = flag
    if ($ProvenanceDiff.RemovedDomains.Count -gt 0) { $hasRegression = $true }
    if ($ProvenanceDiff.Changed) { $hasFlag = $true }

    # Conformance regressions
    if ($ConformanceDiff.Regressions.Count -gt 0) { $hasRegression = $true }
    if ($ConformanceDiff.Changed -and $ConformanceDiff.Regressions.Count -eq 0) { $hasFlag = $true }

    $verdict = "PASS"
    $exitCode = 0
    if ($hasRegression) {
        $verdict = "FAIL"
        $exitCode = 2
    } elseif ($hasFlag) {
        $verdict = "FLAG"
        $exitCode = 1
    }

    # Build report
    $sb = New-Object System.Text.StringBuilder

    $null = $sb.AppendLine("# Regression Check -- $timeStamp")
    $null = $sb.AppendLine("")
    $null = $sb.AppendLine("## Change audited")
    if ([string]::IsNullOrWhiteSpace($ChangeDescription)) {
        $null = $sb.AppendLine("No description provided.")
    } else {
        $null = $sb.AppendLine($ChangeDescription)
    }
    $null = $sb.AppendLine("")

    # Doctor check section
    $null = $sb.AppendLine("## Doctor check")
    $null = $sb.AppendLine("Pre: $($DoctorDiff.PreStatus)")
    $null = $sb.AppendLine("Post: $($DoctorDiff.PostStatus)")
    if ($DoctorDiff.Regression) {
        $null = $sb.AppendLine("Regression: YES")
        if ($DoctorDiff.NewFailures.Count -gt 0) {
            $null = $sb.AppendLine("")
            $null = $sb.AppendLine("New failures:")
            foreach ($f in $DoctorDiff.NewFailures) {
                $null = $sb.AppendLine("- $f")
            }
        }
    } else {
        $null = $sb.AppendLine("Regression: NO")
    }
    $null = $sb.AppendLine("")

    # Provenance standing counts section
    $null = $sb.AppendLine("## Provenance standing counts")
    if (-not $ProvenanceDiff.Changed) {
        $null = $sb.AppendLine("No changes detected.")
    } else {
        $null = $sb.AppendLine("| Domain | Before | After | Delta |")
        $null = $sb.AppendLine("|---|---|---|---|")

        # All domains from both pre and post
        $allDomains = @($ProvenanceDiff.PreRows.Keys + $ProvenanceDiff.PostRows.Keys) | Sort-Object -Unique

        foreach ($domain in $allDomains) {
            $before = ""
            $after = ""
            $delta = ""

            if ($ProvenanceDiff.PreRows.ContainsKey($domain)) {
                $pr = $ProvenanceDiff.PreRows[$domain]
                $before = "$($pr.Encounters) / $($pr.Stops) / $($pr.Overrides) / $($pr.Corrections)"
            } else {
                $before = "(new)"
            }

            if ($ProvenanceDiff.PostRows.ContainsKey($domain)) {
                $po = $ProvenanceDiff.PostRows[$domain]
                $after = "$($po.Encounters) / $($po.Stops) / $($po.Overrides) / $($po.Corrections)"
            } else {
                $after = "(removed)"
            }

            if ($ProvenanceDiff.RemovedDomains -contains $domain) {
                $delta = "**REMOVED**"
            } elseif ($ProvenanceDiff.AddedDomains -contains $domain) {
                $delta = "new domain"
            } elseif ($ProvenanceDiff.ChangedDomains -contains $domain) {
                $delta = "changed"
            } else {
                $delta = "--"
            }

            $null = $sb.AppendLine("| $domain | $before | $after | $delta |")
        }
    }
    $null = $sb.AppendLine("")

    # Conformance assertions section
    $null = $sb.AppendLine("## Conformance assertions")
    if (-not $ConformanceDiff.Changed) {
        $null = $sb.AppendLine("No changes detected.")
    } else {
        foreach ($change in $ConformanceDiff.Changes) {
            if ($ConformanceDiff.Regressions -contains $change) {
                $null = $sb.AppendLine("- **$change** (REGRESSION)")
            } else {
                $null = $sb.AppendLine("- $change")
            }
        }
    }
    $null = $sb.AppendLine("")

    # Verdict section
    $null = $sb.AppendLine("## Verdict")
    $null = $sb.AppendLine("**$verdict**")
    $null = $sb.AppendLine("")
    switch ($verdict) {
        "PASS" { $null = $sb.AppendLine("No regressions detected. All checks stable.") }
        "FLAG" { $null = $sb.AppendLine("Non-critical changes detected. Review recommended.") }
        "FAIL" { $null = $sb.AppendLine("Regression detected. Action required before ratification.") }
    }

    $reportContent = $sb.ToString()
    Write-Utf8NoBom -FilePath $reportFile -Content $reportContent

    return @{
        File     = $reportFile
        Verdict  = $verdict
        ExitCode = $exitCode
    }
}

# ===================================================================
# MAIN
# ===================================================================

switch ($action) {
    "pre" {
        Take-Snapshot -Prefix "pre"
        Write-Host ""
        Write-Host "Pre-snapshot ready. Make your changes, then run:" -ForegroundColor Yellow
        Write-Host "  ygg regression-check post `"description of change`"" -ForegroundColor Cyan
        exit 0
    }
    "post" {
        # Verify pre-snapshot exists
        $preDoctor = Join-Path -Path $script:SnapshotDir -ChildPath "pre-doctor.txt"
        if (-not (Test-Path -LiteralPath $preDoctor)) {
            Write-Host "ERROR: No pre-snapshot found. Run 'ygg regression-check pre' first." -ForegroundColor Red
            exit 2
        }

        # Take post-snapshot
        Take-Snapshot -Prefix "post"
        Write-Host ""

        # Diff
        Write-Host "Comparing snapshots..." -ForegroundColor Cyan

        $preDoctorFile      = Join-Path -Path $script:SnapshotDir -ChildPath "pre-doctor.txt"
        $postDoctorFile     = Join-Path -Path $script:SnapshotDir -ChildPath "post-doctor.txt"
        $preProvenanceFile  = Join-Path -Path $script:SnapshotDir -ChildPath "pre-provenance.txt"
        $postProvenanceFile = Join-Path -Path $script:SnapshotDir -ChildPath "post-provenance.txt"
        $preConformanceFile = Join-Path -Path $script:SnapshotDir -ChildPath "pre-conformance.txt"
        $postConformanceFile = Join-Path -Path $script:SnapshotDir -ChildPath "post-conformance.txt"

        $doctorDiff      = Compare-DoctorSnapshots      -PreFile $preDoctorFile      -PostFile $postDoctorFile
        $provenanceDiff  = Compare-ProvenanceSnapshots   -PreFile $preProvenanceFile  -PostFile $postProvenanceFile
        $conformanceDiff = Compare-ConformanceSnapshots   -PreFile $preConformanceFile -PostFile $postConformanceFile

        # Generate report
        $reportResult = Generate-Report -DoctorDiff $doctorDiff `
                                        -ProvenanceDiff $provenanceDiff `
                                        -ConformanceDiff $conformanceDiff `
                                        -ChangeDescription $description

        Write-Host ""
        Write-Host "Report written to: $($reportResult.File)" -ForegroundColor Green

        # Colour the verdict
        switch ($reportResult.Verdict) {
            "PASS" { Write-Host "Verdict: PASS - no regressions" -ForegroundColor Green }
            "FLAG" { Write-Host "Verdict: FLAG - non-critical changes detected" -ForegroundColor Yellow }
            "FAIL" { Write-Host "Verdict: FAIL - regression detected" -ForegroundColor Red }
        }

        # Clean up snapshot files
        $snapshotFiles = Get-ChildItem -Path $script:SnapshotDir -File
        foreach ($sf in $snapshotFiles) {
            Remove-Item -LiteralPath $sf.FullName -Force
        }

        exit $reportResult.ExitCode
    }
    default {
        Write-Host "ygg regression-check - regression detection for staging ratification" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Usage: ygg regression-check <pre|post> [`"description`"]" -ForegroundColor White
        Write-Host ""
        Write-Host "  pre   Capture pre-change snapshot (doctor, provenance, conformance)" -ForegroundColor Gray
        Write-Host "  post  Capture post-change snapshot, diff, generate report" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Exit codes: 0=PASS  1=FLAG  2=FAIL" -ForegroundColor Gray
        exit 1
    }
}
