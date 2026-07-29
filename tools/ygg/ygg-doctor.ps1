# ygg doctor - environment verification tool. Part of the ygg CLI suite.
<#
.SYNOPSIS
  Runs environment checks against the Yggdrasil seed and reports pass/fail.
.DESCRIPTION
  Checks performed:
    1.  Seed root resolves - .ygg exists and points to a valid seed directory
    2.  .ygg is gitignored - .gitignore contains .ygg
    3.  Every canonical file is UTF-8 without BOM - scans .md files under seed/
    4.  No mojibake sequences - scans for corrupted UTF-8 byte sequences
    5.  Adapters load under host's own loader - runs opencode agent list
    6.  Command directories correctly named - .opencode/command/ files
    7.  opencode.json present and non-empty - exists with content beyond {}
    8.  No placeholder brackets outside _templates/ - no <...> patterns outside
    9.  Every capabilities.md entry has a corresponding file
    10. Append-only files were not truncated on last write
.EXAMPLE
  & .\ygg-doctor.ps1
#>

$script:passed = 0
$script:failed = 0
$script:failures = @()

function Write-Result {
    param([string]$CheckName, [bool]$Passed, [string]$Detail = "")
    if ($Passed) {
        Write-Host "  [PASS] $CheckName" -ForegroundColor Green
        $script:passed++
    } else {
        Write-Host "  [FAIL] $CheckName" -ForegroundColor Red
        if ($Detail) { Write-Host "         $Detail" -ForegroundColor DarkRed }
        $script:failed++
        $script:failures += "$CheckName - $Detail"
    }
}

# Determine project root from script location, .ygg, or working directory
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

$ProjectRoot = Get-ProjectRoot
Write-Host "ygg doctor - environment check" -ForegroundColor Cyan
Write-Host "Project root: $ProjectRoot" -ForegroundColor DarkCyan
Write-Host ""

# ---- Check 1: Seed root resolves ----
Write-Host "[1/10] Seed root resolves" -ForegroundColor White
$yggPointer = Join-Path -Path $ProjectRoot -ChildPath ".ygg"
if (Test-Path -LiteralPath $yggPointer -PathType Leaf) {
    $resolvedRaw = Get-Content -Path $yggPointer -Raw
    $resolvedRoot = $resolvedRaw.Trim()
    if ([string]::IsNullOrEmpty($resolvedRoot)) {
        Write-Result -CheckName "Seed root resolves" -Passed $false -Detail ".ygg file is empty"
    } elseif (-not (Test-Path -LiteralPath $resolvedRoot -PathType Container)) {
        Write-Result -CheckName "Seed root resolves" -Passed $false -Detail "Path '$resolvedRoot' from .ygg does not exist"
    } else {
        $identityMd = Join-Path -Path $resolvedRoot -ChildPath "seed\constitution\identity.md"
        if (Test-Path -LiteralPath $identityMd -PathType Leaf) {
            Write-Result -CheckName "Seed root resolves" -Passed $true
        } else {
            Write-Result -CheckName "Seed root resolves" -Passed $false -Detail "identity.md not found at $identityMd"
        }
    }
} else {
    Write-Result -CheckName "Seed root resolves" -Passed $false -Detail ".ygg file not found at $yggPointer"
}

# ---- Check 2: .ygg is gitignored ----
Write-Host "[2/10] .ygg is gitignored" -ForegroundColor White
$gitignore = Join-Path -Path $ProjectRoot -ChildPath ".gitignore"
if (Test-Path -LiteralPath $gitignore -PathType Leaf) {
    $content = Get-Content -Path $gitignore -Raw
    if ($content -match '(?m)^\.ygg\s*$') {
        Write-Result -CheckName ".ygg is gitignored" -Passed $true
    } else {
        Write-Result -CheckName ".ygg is gitignored" -Passed $false -Detail ".gitignore does not contain .ygg on its own line"
    }
} else {
    Write-Result -CheckName ".ygg is gitignored" -Passed $false -Detail ".gitignore file not found"
}

# ---- Check 3: Every canonical file is UTF-8 without BOM ----
Write-Host "[3/10] Every canonical file is UTF-8 without BOM" -ForegroundColor White
$mdFiles = Get-ChildItem -Path (Join-Path -Path $ProjectRoot -ChildPath "seed") -Filter "*.md" -Recurse -File
$bomFiles = @()
foreach ($f in $mdFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $bomFiles += $f.FullName
    }
}
if ($bomFiles.Count -eq 0) {
    Write-Result -CheckName "UTF-8 without BOM" -Passed $true
} else {
    Write-Result -CheckName "UTF-8 without BOM" -Passed $false -Detail "Files with BOM: $($bomFiles -join '; ')"
}

# ---- Check 4: No mojibake sequences ----
Write-Host "[4/10] No mojibake sequences" -ForegroundColor White
# Scan for specific byte sequences that indicate CP1252-written-as-UTF-8 corruption.
# We match longer characteristic sequences (5+ bytes) that are extremely unlikely
# in legitimate text, avoiding false positives on isolated single Unicode chars.
function Test-MojibakeBytes {
    param([byte[]]$Bytes)
    # Patterns that indicate double-encoded CP1252 content.
    # These are the byte sequences of common mojibake strings like
    # Acent (double-encoded cent sign), A"double-encoded curly quotes, etc.
    $patterns = @(
        # Acent = 0xC3 0x82 0xC2 0xA2 - double-encoded cent sign
        @(0xC3, 0x82, 0xC2, 0xA2),
        # Aeuro = 0xC3 0x82 0xC2 0xAC - double-encoded euro sign
        @(0xC3, 0x82, 0xC2, 0xAC),
        # A para = 0xC3 0x82 0xC2 0xB6 - double-encoded pilcrow
        @(0xC3, 0x82, 0xC2, 0xB6),
        # A sect = 0xC3 0x82 0xC2 0xA7 - double-encoded section sign
        @(0xC3, 0x82, 0xC2, 0xA7),
        # Replacement char triple: 0xEF 0xBF 0xBD
        @(0xEF, 0xBF, 0xBD),
        # Longer mojibake sequences (em-dash, curly quotes, etc.)
        # A cent A not euro - common mojibake run
        @(0xC3, 0x82, 0xC2, 0xA2, 0xC3, 0x82, 0xC2, 0xAC),
        # Triple sequence: A A A (accented char repeated)
        @(0xC3, 0x82, 0xC3, 0x82, 0xC3, 0x82),
        # --- UTF-8 rendered through CP437/CP850, then re-saved as UTF-8 [E48] ---
        # Every 3-byte UTF-8 sequence starting 0xE2 (arrows, dashes, quotes, check marks)
        # renders in CP437 as GREEK CAPITAL GAMMA followed by two Latin-1 chars.
        # 0xCE 0x93 is Gamma; the following 0xC3/0xC2 lead byte is what makes it mojibake
        # rather than legitimate Greek text.
        #   ##  = 0xCE93 0xC3A5 0xC386  (was 0xE2 0x86 0x92, RIGHTWARDS ARROW)
        #   ##  = 0xCE93 0xC387 0xC3B6  (was 0xE2 0x80 0x94, EM DASH)
        @(0xCE, 0x93, 0xC3),
        @(0xCE, 0x93, 0xC2)
        # NOT scanned: 0xC3A2 0xE2 0x82 0xAC (UTF-8 em dash read as CP1252). Both odin
        # personas quote that sequence verbatim, inside backticks, as the worked example
        # teaching an operator to recognise corruption. Scanning for it flags the
        # documentation that exists to describe it. A check that fires on its own
        # specimen is the defect it is looking for. [E48]
    )
    foreach ($pat in $patterns) {
        $plen = $pat.Length
        for ($i = 0; $i -le $Bytes.Length - $plen; $i++) {
            $match = $true
            for ($j = 0; $j -lt $plen; $j++) {
                if ($Bytes[$i + $j] -ne $pat[$j]) { $match = $false; break }
            }
            if ($match) { return $true }
        }
    }
    return $false
}

$mojibakeFiles = @()
foreach ($f in $mdFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    if (Test-MojibakeBytes -Bytes $bytes) {
        $mojibakeFiles += $f.FullName
    }
}
if ($mojibakeFiles.Count -eq 0) {
    Write-Result -CheckName "No mojibake sequences" -Passed $true
} else {
    Write-Result -CheckName "No mojibake sequences" -Passed $false -Detail "Files with mojibake: $($mojibakeFiles -join '; ')"
}

# ---- Check 5: Adapters load under host's own loader ----
Write-Host "[5/10] Adapters load under host's own loader" -ForegroundColor White
try {
    # First check if opencode is available
    $opencodeCheck = Get-Command "opencode" -ErrorAction SilentlyContinue
    if (-not $opencodeCheck) {
        Write-Result -CheckName "Adapters load" -Passed $false -Detail "'opencode' command not found in PATH"
    } else {
        $opencodeResult = & opencode agent list 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            # An installed Claude adapter must be reported against too. This check previously
            # ran only 'opencode agent list' while reporting under the name "Adapters load"
            # (plural), so the Claude adapter passed without any loader having seen it. [E48]
            $claudeAgentDir = Join-Path -Path $ProjectRoot -ChildPath ".claude\agents"
            if (Test-Path $claudeAgentDir) {
                $claudeCmd = Get-Command "claude" -ErrorAction SilentlyContinue
                if ($claudeCmd) {
                    $null = & claude doctor 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Result -CheckName "Adapters load (opencode + claude)" -Passed $true
                    } else {
                        Write-Result -CheckName "Adapters load (opencode + claude)" -Passed $false -Detail "opencode OK; 'claude doctor' exited with code $LASTEXITCODE"
                    }
                } else {
                    Write-Result -CheckName "Adapters load (opencode only)" -Passed $false -Detail "opencode OK, but a Claude adapter is installed at .claude/agents and 'claude' is not in PATH - the Claude adapter has NOT been checked by any loader. This is not a pass."
                }
            } else {
                Write-Result -CheckName "Adapters load (opencode only)" -Passed $true
            }
        } else {
            $stderr = $opencodeResult | Out-String
            Write-Result -CheckName "Adapters load" -Passed $false -Detail "opencode agent list exited with code $exitCode"
        }
    }
} catch {
    Write-Result -CheckName "Adapters load" -Passed $false -Detail "Could not run 'opencode agent list': $_"
}

# ---- Check 6: Command directories correctly named ----
Write-Host "[6/10] Command directories correctly named" -ForegroundColor White
$commandDir = Join-Path -Path $ProjectRoot -ChildPath ".opencode\command"
if (Test-Path -LiteralPath $commandDir -PathType Container) {
    $cmdFiles = Get-ChildItem -Path $commandDir -Filter "*.md" -File
    if ($cmdFiles.Count -gt 0) {
        $allValid = $true
        $invalidNames = @()
        foreach ($cf in $cmdFiles) {
            if ($cf.BaseName -notmatch '^[a-z][a-z0-9_-]*$') {
                $allValid = $false
                $invalidNames += $cf.Name
            }
        }
        if ($allValid) {
            Write-Result -CheckName "Command directories correctly named" -Passed $true
        } else {
            Write-Result -CheckName "Command directories correctly named" -Passed $false -Detail "Invalid command filenames: $($invalidNames -join '; ')"
        }
    } else {
        Write-Result -CheckName "Command directories correctly named" -Passed $false -Detail "No .md files in .opencode\command\"
    }
} else {
    Write-Result -CheckName "Command directories correctly named" -Passed $false -Detail ".opencode\command\ directory not found"
}

# ---- Check 7: opencode.json present and non-empty ----
Write-Host "[7/10] opencode.json present and non-empty" -ForegroundColor White
$opencodeJson = Join-Path -Path $ProjectRoot -ChildPath "opencode.json"
if (Test-Path -LiteralPath $opencodeJson -PathType Leaf) {
    $raw = Get-Content -Path $opencodeJson -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($raw)) {
        Write-Result -CheckName "opencode.json present and non-empty" -Passed $false -Detail "File is empty"
    } else {
        $trimmed = $raw.Trim()
        if ($trimmed -eq '{}') {
            Write-Result -CheckName "opencode.json present and non-empty" -Passed $false -Detail "File contains only {}"
        } else {
            Write-Result -CheckName "opencode.json present and non-empty" -Passed $true
        }
    }
} else {
    Write-Result -CheckName "opencode.json present and non-empty" -Passed $false -Detail "opencode.json not found at $opencodeJson"
}

# ---- Check 8: No placeholder brackets outside _templates/ ----
Write-Host "[8/10] No placeholder brackets outside _templates/" -ForegroundColor White
# Scan for unfilled placeholder brackets (stubs that should have been replaced).
# The Yggdrasil seed uses <...> notation INTENTIONALLY in specification files:
# - protocol files document message/format conventions
# - agent charters document output format templates
# - conformance files document evaluation path conventions
# - memory files document entry format conventions
# - constitution files document variable references like <seed-root>
# - project-profile-template.md is a template despite not being in _templates/
# - growth/ledger.md and migrations/ use it in documentation
# - template files in _templates/ are excluded
#
# We flag only simple unfilled stubs that look like forgotten placeholders:
# short tokens like <todo>, <fixme>, or patterns that clearly indicate
# an unsubstituted template value.

$templatesDir = Join-Path -Path $ProjectRoot -ChildPath "seed\adapters\_templates"

# Directories where <...> is used intentionally for documentation
$intentionalDirPatterns = @(
    (Join-Path -Path $ProjectRoot -ChildPath "seed\protocols\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "seed\conformance\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "seed\adapters\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "seed\memory\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "seed\constitution\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "seed\growth\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "seed\migrations\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "guides\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "prior-evidence\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "roadmap\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "evaluations\*"),
    (Join-Path -Path $ProjectRoot -ChildPath "spec\*")
)

# Files outside _templates/ but known to use <...> intentionally
$intentionalFiles = @(
    (Join-Path -Path $ProjectRoot -ChildPath "seed\project-profile-template.md"),
    (Join-Path -Path $ProjectRoot -ChildPath "GUIDE.md")
)

# Scan ALL .md files in the project, not just under seed/
$allMdFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.md" -Recurse -File |
    Where-Object { $_.FullName -notlike "$templatesDir\*" }

$bracketFiles = @()
foreach ($f in $allMdFiles) {
    # Skip if in an intentional directory
    $isSkipped = $false
    foreach ($pattern in $intentionalDirPatterns) {
        if ($f.FullName -like $pattern) { $isSkipped = $true; break }
    }
    if ($isSkipped) { continue }
    # Skip intentional files
    if ($intentionalFiles -contains $f.FullName) { continue }
    # Skip .git directory
    if ($f.FullName -like "$ProjectRoot\.git\*") { continue }
    # Skip session-*.md files (contain tool XML output)
    if ($f.BaseName -like 'session-*') { continue }

    $text = Get-Content -Path $f.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $text) { continue }
    # Flag placeholder-like patterns: obvious unfilled stubs.
    # We match <todo>, <fixme>, <hack>, <xxx> or their uppercase variants,
    # or patterns like <INSERT_SOMETHING> that clearly indicate an unsubstituted value.
    if ($text -match '<\s*(?:todo|fixme|hack|xxx|change_?this|insert|your_?name)\s*>' -or
        $text -match '<\s*(?:INSERT|TODO|FIXME|HACK|XXX)\s*>') {
        $bracketFiles += $f.FullName
    }
}

# Generated agent files must never carry the literal template's own scaffolding.
# This is the E41/E46 signature: the 24-line "LITERAL TEMPLATE" comment block was copied
# ahead of the frontmatter, so the host's parser never saw a document start and the agent
# silently did not exist. Inspection passed it; only the loader disagreed. [E48]
$agentDirs = @(
    (Join-Path -Path $ProjectRoot -ChildPath "seed\adapters\claude\agents"),
    (Join-Path -Path $ProjectRoot -ChildPath "seed\adapters\opencode\agents"),
    (Join-Path -Path $ProjectRoot -ChildPath ".claude\agents"),
    (Join-Path -Path $ProjectRoot -ChildPath ".opencode\agents")
)
foreach ($dir in $agentDirs) {
    if (-not (Test-Path $dir)) { continue }
    foreach ($af in (Get-ChildItem -Path $dir -Filter "*.md" -File -ErrorAction SilentlyContinue)) {
        $bytes = [System.IO.File]::ReadAllBytes($af.FullName)
        # Frontmatter must begin at byte 0. A BOM or a comment block ahead of it means
        # the host does not see this file as an agent at all.
        if ($bytes.Length -lt 3 -or $bytes[0] -ne 0x2D -or $bytes[1] -ne 0x2D -or $bytes[2] -ne 0x2D) {
            $bracketFiles += $af.FullName
            continue
        }
        $atext = Get-Content -Path $af.FullName -Raw -ErrorAction SilentlyContinue
        if ($atext -match 'LITERAL TEMPLATE' -or
            $atext -match 'Fill ONLY the <slots>' -or
            $atext -match '<lowercase-with-hyphens>' -or
            $atext -match '<alias or full model ID') {
            $bracketFiles += $af.FullName
        }
    }
}

$bracketFiles = $bracketFiles | Sort-Object -Unique
if ($bracketFiles.Count -eq 0) {
    Write-Result -CheckName "No unfilled stubs; generated agents carry no template scaffolding" -Passed $true
} else {
    $relPaths = $bracketFiles | ForEach-Object { $_.Replace($ProjectRoot, '').TrimStart('\') }
    Write-Result -CheckName "No unfilled stubs; generated agents carry no template scaffolding" -Passed $false -Detail "Files with template scaffolding or unfilled stubs: $($relPaths -join '; ')"
}

# ---- Check 9: Every capabilities.md entry has a corresponding file ----
Write-Host "[9/10] Every capabilities.md entry has a corresponding file" -ForegroundColor White
$capMd = Join-Path -Path $ProjectRoot -ChildPath "seed\memory\capabilities.md"
if (Test-Path -LiteralPath $capMd -PathType Leaf) {
    $capText = Get-Content -Path $capMd -Raw
    if ([string]::IsNullOrWhiteSpace($capText)) {
        Write-Result -CheckName "Capabilities entries reference existing files" -Passed $false -Detail "capabilities.md is empty"
    } else {
        $missingFiles = @()
        # Parse table rows - look for markdown table rows containing pipe-separated fields
        $rows = $capText -split "`n" | Where-Object { $_ -match '^\|' -and $_ -notmatch '^\|:?-+:?\|' -and $_ -notmatch '^\|\s*\|$' }
        foreach ($row in $rows) {
            $cols = $row -split '\|' | ForEach-Object { $_.Trim() }
            if ($cols.Count -ge 5) {
                $sourceCol = $cols[4]  # source / provenance column (0-indexed: col 4)
                # Extract file paths from the source column - match paths starting with seed/
                $matches = [regex]::Matches($sourceCol, 'seed/[^\s;,\)]+')
                foreach ($m in $matches) {
                    $ref = $m.Value
                    # Strip section references like §17-43
                    $cleanRef = $ref -replace '§.*$', ''
                    $fullPath = Join-Path -Path $ProjectRoot -ChildPath $cleanRef
                    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
                        $missingFiles += "$ref (from capabilities.md)"
                    }
                }
            }
        }
        if ($missingFiles.Count -eq 0) {
            Write-Result -CheckName "Capabilities entries reference existing files" -Passed $true
        } else {
            Write-Result -CheckName "Capabilities entries reference existing files" -Passed $false -Detail "Missing files: $($missingFiles -join '; ')"
        }
    }
} else {
    Write-Result -CheckName "Capabilities entries reference existing files" -Passed $false -Detail "capabilities.md not found at $capMd"
}

# ---- Check 10: Append-only files not truncated on last write ----
Write-Host "[10/10] Append-only files not truncated" -ForegroundColor White
$appendOnlyFiles = @(
    Join-Path -Path $ProjectRoot -ChildPath "seed\growth\ledger.md"
    Join-Path -Path $ProjectRoot -ChildPath "seed\memory\provenance.md"
)
$truncatedFiles = @()
foreach ($f in $appendOnlyFiles) {
    if (Test-Path -LiteralPath $f -PathType Leaf) {
        $content = Get-Content -Path $f -Raw -ErrorAction SilentlyContinue
        if ([string]::IsNullOrWhiteSpace($content)) {
            $truncatedFiles += "$f (empty)"
        } else {
            $lines = $content -split "`n"
            $nonBlankLines = $lines | Where-Object { $_.Trim() -ne '' }
            if ($nonBlankLines.Count -gt 0) {
                $lastNonBlank = $nonBlankLines[-1].Trim()
                # Check if the last non-blank line looks complete (natural ending)
                $looksComplete = $lastNonBlank -match '[\.\|\)\]>]$' -or
                                 $lastNonBlank -match '^#{1,6}\s' -or
                                 $lastNonBlank -match '^[\*\-\+]' -or
                                 $lastNonBlank -match '^\|' -or
                                 $lastNonBlank -match '^---' -or
                                 $lastNonBlank -match '^\d+\.' -or
                                 $lastNonBlank -match ':$' -or
                                 # A provenance ledger entry: ISO date, then the documented
                                 # "YYYY-MM-DD - type - domain - line - evidence: <path>" shape.
                                 # These end in a FILE PATH, not punctuation, so the heuristic
                                 # above reported every correctly-formed append as a truncation.
                                 # The check was firing on the file's own documented entry
                                 # format - the same defect class as E33/E48. [E78]
                                 ($lastNonBlank -match '^\d{4}-\d{2}-\d{2}\s' -and
                                  $lastNonBlank -match 'evidence:')
                if (-not $looksComplete) {
                    $truncatedFiles += "$f (last line appears incomplete)"
                }
            }
        }
    } else {
        $truncatedFiles += "$f (not found)"
    }
}
if ($truncatedFiles.Count -eq 0) {
    Write-Result -CheckName "Append-only files not truncated" -Passed $true
} else {
    Write-Result -CheckName "Append-only files not truncated" -Passed $false -Detail "Issues: $($truncatedFiles -join '; ')"
}

# ---- Summary ----
Write-Host ""
$total = $script:passed + $script:failed
Write-Host "Summary: $($script:passed) passed, $($script:failed) failed" -ForegroundColor $(if ($script:failed -eq 0) { 'Green' } else { 'Yellow' })

if ($script:failures.Count -gt 0) {
    Write-Host "Failed checks:" -ForegroundColor Red
    foreach ($f in $script:failures) {
        Write-Host "  - $f" -ForegroundColor Red
    }
}

if ($script:failed -gt 0) {
    exit 1
} else {
    exit 0
}
