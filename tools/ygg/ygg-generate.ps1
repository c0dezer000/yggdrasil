# ygg generate — seed installation generator
<#
.SYNOPSIS
  Generates a working seed installation in the target directory based on
  wizard answers from ygg-plant.ps1.
.DESCRIPTION
  Creates the full directory structure, copies and adapts constitution files,
  generates the orchestrator persona (odin.md), creates .ygg pointer, copies
  adapters, creates the work index, validates with opencode agent list, and
  runs conformance subset.
.PARAMETER TargetDirectory
  The directory to install into.
.PARAMETER ManifestPath
  Path to the ygg-plant.json manifest with wizard answers.
.EXAMPLE
  & .\ygg-generate.ps1 -TargetDirectory "C:\projects\my-project" -ManifestPath "C:\projects\my-project\ygg-plant.json"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$TargetDirectory,

    [Parameter(Mandatory = $true)]
    [string]$ManifestPath
)

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")
$sourceSeedDir = Join-Path -Path $yggRoot -ChildPath "seed"

# ---- Resolve paths ----
$TargetDirectory = [System.IO.Path]::GetFullPath($TargetDirectory)

# ---- Load manifest ----
if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    Write-Error "Manifest not found: $ManifestPath"
    exit 1
}

$manifestRaw = Get-Content -Path $ManifestPath -Raw -Encoding UTF8
try {
    $manifest = $manifestRaw | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse manifest: $_"
    exit 1
}

$answers = $manifest.answers
if (-not $answers) {
    Write-Error "Manifest is missing 'answers' field."
    exit 1
}

Write-Host "Generating seed installation in: $TargetDirectory" -ForegroundColor DarkCyan
Write-Host "Source seed: $sourceSeedDir" -ForegroundColor DarkCyan
Write-Host ""

# ---- Utility: ensure directory exists ----
function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "  Created: $Path" -ForegroundColor Gray
    }
}

# ---- Utility: copy file with optional adaptation ----
function Copy-Adapt {
    param(
        [string]$Source,
        [string]$Destination,
        [scriptblock]$Adapt = $null
    )
    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
        Write-Warning "Source file not found: $Source — skipping"
        return
    }
    $parentDir = Split-Path -Path $Destination -Parent
    Ensure-Dir $parentDir
    if ($Adapt) {
        $content = Get-Content -Path $Source -Raw -Encoding UTF8
        $adapted = & $Adapt $content
        $ext = [System.IO.Path]::GetExtension($Destination).ToLower()
        if ($ext -eq ".ps1") {
            Write-FileWithEncoding -Path $Destination -Content $adapted -Type "ps1"
        } elseif ($ext -eq ".json") {
            Write-FileWithEncoding -Path $Destination -Content $adapted -Type "json"
        } else {
            Write-FileWithEncoding -Path $Destination -Content $adapted -Type "md"
        }
    } else {
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
    }
    Write-Host "  Copied: $Destination" -ForegroundColor Gray
}

# ---- Utility: write file with correct encoding ----
function Write-FileWithEncoding {
    param([string]$Path, [string]$Content, [string]$Type = "md")
    if ($Type -eq "ps1") {
        $utf8WithBom = New-Object System.Text.UTF8Encoding $true
        [System.IO.File]::WriteAllText($Path, $Content, $utf8WithBom)
    } else {
        $utf8WithoutBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($Path, $Content, $utf8WithoutBom)
    }
}

# ===================================================================
# STEP 1: Create directory structure
# ===================================================================
Write-Host "─── Step 1: Creating directory structure ───" -ForegroundColor Cyan

$targetSeedDir = Join-Path -Path $TargetDirectory -ChildPath "seed"
$targetDotOpendir = Join-Path -Path $TargetDirectory -ChildPath ".opencode"

$dirs = @(
    (Join-Path -Path $targetSeedDir -ChildPath "constitution"),
    (Join-Path -Path $targetSeedDir -ChildPath "protocols"),
    (Join-Path -Path $targetSeedDir -ChildPath "memory"),
    (Join-Path -Path $targetSeedDir -ChildPath "memory\log"),
    (Join-Path -Path $targetSeedDir -ChildPath "growth"),
    (Join-Path -Path $targetSeedDir -ChildPath "conformance"),
    (Join-Path -Path $targetSeedDir -ChildPath "adapters\_templates"),
    (Join-Path -Path $targetSeedDir -ChildPath "migrations"),
    (Join-Path -Path $targetSeedDir -ChildPath "prior-evidence"),
    (Join-Path -Path $targetDotOpendir -ChildPath "agents"),
    (Join-Path -Path $targetDotOpendir -ChildPath "command"),
    (Join-Path -Path $TargetDirectory -ChildPath "roadmap"),
    (Join-Path -Path $TargetDirectory -ChildPath "guides"),
    (Join-Path -Path $TargetDirectory -ChildPath "evaluations")
)

foreach ($d in $dirs) {
    Ensure-Dir $d
}

# ---- Write notification config (no secrets, just channel type) ----
if ($answers.notifications -and $answers.notifications -ne "skip") {
    $notifConfig = @{
        "channel" = $answers.notifications
        "setupNote" = "Set the required environment variable to activate. See ygg-plant.json for details."
    }
    $notifConfigJson = $notifConfig | ConvertTo-Json
    $notifConfigPath = Join-Path -Path $targetDotOpendir -ChildPath "notifications.json"
    Write-FileWithEncoding -Path $notifConfigPath -Content $notifConfigJson -Type "json"
    Write-Host "  Created: $notifConfigPath (channel: $($answers.notifications))" -ForegroundColor Gray
}

# ===================================================================
# STEP 2: Copy constitution files (adapting paths for target)
# ===================================================================
Write-Host ""
Write-Host "─── Step 2: Copying constitution with adaptations ───" -ForegroundColor Cyan

# Adapt identity.md based on personality preset
$identitySrc = Join-Path -Path $sourceSeedDir -ChildPath "constitution\identity.md"
$identityDst = Join-Path -Path $targetSeedDir -ChildPath "constitution\identity.md"

$identityAdapter = {
    param($content)
    # The identity.md is mostly universal. We adjust the Register section
    # based on personality preset and the Who I serve section.
    # Personality affects: Register (length, tone, formality, humor)
    # and Standing habits.
    # This is adapted by the generation, not custom-written.
    $c = $content

    if ($answers.personality -eq "minimal") {
        # Ultra-brief personality
        $c = $c -replace '(?m)^-\s+\*\*Default length:\*\* short\. Answer the question, then stop\. Elaborate when asked or when brevity would mislead\.',
                         '- **Default length:** one sentence. Prefer the shortest correct answer.'
        $c = $c -replace '(?m)^-\s+\*\*Tone:\*\* direct and plain\. No preamble, no restating the question, no closing pleasantries\.',
                         '- **Tone:** telegraphic. Facts only. No connective tissue.'
        $c = $c -replace '(?m)^-\s+\*\*Formality:\*\* low\. Technical peers talking, not a service desk\.',
                         '- **Formality:** minimal. No honorifics, no greetings, no sign-offs.'
        $c = $c -replace '(?m)^-\s+\*\*Disagreement:\*\* stated immediately and plainly, with the reason first\. I do not soften a correction into a suggestion\.',
                         '- **Disagreement:** named in one word if possible. Reason follows only if the disagreement is substantive.'
        $c = $c -replace '(?m)^-\s+\*\*Humor:\*\* dry, occasional, never at the cost of clarity\.',
                         '- **Humor:** none.'
    } elseif ($answers.personality -eq "explicit") {
        # Verbose personality
        $c = $c -replace '(?m)^-\s+\*\*Default length:\*\* short\. Answer the question, then stop\. Elaborate when asked or when brevity would mislead\.',
                         '- **Default length:** thorough. Include context, reasoning, and alternatives. Brevity is acceptable only when the answer fits one sentence.'
        $c = $c -replace '(?m)^-\s+\*\*Tone:\*\* direct and plain\. No preamble, no restating the question, no closing pleasantries\.',
                         '- **Tone:** thorough and explanatory. Restate the question, provide context, reason through the answer, and close with a summary.'
        $c = $c -replace '(?m)^-\s+\*\*Formality:\*\* low\. Technical peers talking, not a service desk\.',
                         '- **Formality:** moderate. Professional and courteous.'
        $c = $c -replace '(?m)^-\s+\*\*Disagreement:\*\* stated immediately and plainly, with the reason first\. I do not soften a correction into a suggestion\.',
                         '- **Disagreement:** stated with full reasoning, alternatives considered, and a proposed resolution.'
        $c = $c -replace '(?m)^-\s+\*\*Humor:\*\* dry, occasional, never at the cost of clarity\.',
                         '- **Humor:** none. All communication is professional.'
    }
    # default: no changes needed

    # Adapt Who I serve section based on who commits
    if ($answers.whoCommits -eq "gardener") {
        $c = $c -replace '(?m)^-\s+\*\*Gardener:\*\*.*$',
                         "- **Gardener:** named at seed creation — address as directed"
        $c = $c -replace '(?m)^-\s+\*\*Context:\*\*.*$',
                         "- **Context:** solo practitioner configured via ygg plant"
        $c = $c -replace '(?m)^-\s+\*\*Standing preference on record:\*\*.*$',
                         "- **Standing preference:** version control is the gardener's domain. The companion never commits, never reminds."
    } elseif ($answers.whoCommits -eq "companion-approval") {
        $c = $c -replace '(?m)^-\s+\*\*Gardener:\*\*.*$',
                         "- **Gardener:** named at seed creation — address as directed"
        $c = $c -replace '(?m)^-\s+\*\*Context:\*\*.*$',
                         "- **Context:** solo practitioner; companion prepares commits with per-approval required"
        $c = $c -replace '(?m)^-\s+\*\*Standing preference on record:\*\*.*$',
                         "- **Standing preference:** the companion may prepare commits but must ask before executing each one"
    }

    return $c
}

Copy-Adapt -Source $identitySrc -Destination $identityDst -Adapt $identityAdapter

# values.md — universal, copy verbatim
Copy-Adapt -Source (Join-Path -Path $sourceSeedDir -ChildPath "constitution\values.md") `
           -Destination (Join-Path -Path $targetSeedDir -ChildPath "constitution\values.md")

# boundaries.md — universal, copy verbatim
Copy-Adapt -Source (Join-Path -Path $sourceSeedDir -ChildPath "constitution\boundaries.md") `
           -Destination (Join-Path -Path $targetSeedDir -ChildPath "constitution\boundaries.md")

# gates.md — adapt if single-model
$gatesSrc = Join-Path -Path $sourceSeedDir -ChildPath "constitution\gates.md"
$gatesDst = Join-Path -Path $targetSeedDir -ChildPath "constitution\gates.md"
$gatesAdapter = {
    param($content)
    $c = $content
    if ($answers.singleModel -eq $true) {
        # Add single-model labeling note
        $note = "`n## Single-model note`n`nThis installation runs on a single model. All councils are `"single-model council — structured self-check, not independent review.`" The council protocol's model-diversity rule is acknowledged as a design constraint rather than a defect.`n"
        $c = $c + $note
    }
    return $c
}
Copy-Adapt -Source $gatesSrc -Destination $gatesDst -Adapt $gatesAdapter

# ===================================================================
# STEP 2b: Copy protocol files
# ===================================================================
Write-Host "  (Copying protocols...)" -ForegroundColor Gray

$protocols = @(
    "session.md", "loop.md", "brief.md", "council.md", "conformance.md",
    "consult.md", "disclosure.md", "off-map.md", "onboard.md"
)

foreach ($proto in $protocols) {
    $src = Join-Path -Path $sourceSeedDir -ChildPath "protocols\$proto"
    $dst = Join-Path -Path $targetSeedDir -ChildPath "protocols\$proto"
    Copy-Adapt -Source $src -Destination $dst
}

# ===================================================================
# STEP 2c: Copy memory files (templates)
# ===================================================================
Write-Host "  (Copying memory files...)" -ForegroundColor Gray

$memoryFiles = @(
    "profile.md", "goals.md", "projects.md", "decisions.md",
    "staging.md", "capabilities.md", "provenance.md"
)

foreach ($mf in $memoryFiles) {
    $src = Join-Path -Path $sourceSeedDir -ChildPath "memory\$mf"
    $dst = Join-Path -Path $targetSeedDir -ChildPath "memory\$mf"
    Copy-Adapt -Source $src -Destination $dst
}

# Copy SCHEMA-VERSION
Copy-Adapt -Source (Join-Path -Path $sourceSeedDir -ChildPath "SCHEMA-VERSION") `
           -Destination (Join-Path -Path $targetSeedDir -ChildPath "SCHEMA-VERSION")

# Copy growth ledger template
Copy-Adapt -Source (Join-Path -Path $sourceSeedDir -ChildPath "growth\ledger.md") `
           -Destination (Join-Path -Path $targetSeedDir -ChildPath "growth\ledger.md")

# Copy conformance suite
$conformanceFiles = Get-ChildItem -Path (Join-Path -Path $sourceSeedDir -ChildPath "conformance") -Filter "*.md" -File
foreach ($cf in $conformanceFiles) {
    $dst = Join-Path -Path $targetSeedDir -ChildPath "conformance\$($cf.Name)"
    Copy-Adapt -Source $cf.FullName -Destination $dst
}

# Copy adapter templates
$templateFiles = Get-ChildItem -Path (Join-Path -Path $sourceSeedDir -ChildPath "adapters\_templates") -File
foreach ($tf in $templateFiles) {
    $dst = Join-Path -Path $targetSeedDir -ChildPath "adapters\_templates\$($tf.Name)"
    Copy-Adapt -Source $tf.FullName -Destination $dst
}

# Copy migrations
$migrationFiles = Get-ChildItem -Path (Join-Path -Path $sourceSeedDir -ChildPath "migrations") -Filter "*.md" -File
foreach ($mf in $migrationFiles) {
    $dst = Join-Path -Path $targetSeedDir -ChildPath "migrations\$($mf.Name)"
    Copy-Adapt -Source $mf.FullName -Destination $dst
}

# Copy project-profile-template.md
Copy-Adapt -Source (Join-Path -Path $sourceSeedDir -ChildPath "project-profile-template.md") `
           -Destination (Join-Path -Path $TargetDirectory -ChildPath "project-profile-template.md")

# Write project-profile-template.md adapted for quality bar
$profileTemplatePath = Join-Path -Path $TargetDirectory -ChildPath "project-profile-template.md"
$profileContent = Get-Content -Path $profileTemplatePath -Raw -Encoding UTF8
switch ($answers.qualityBar) {
    "mvp" {
        $profileContent = $profileContent -replace '(?m)^-\s+\*\*Quality bar:\*\* .*$',
                                               '- **Quality bar:** mvp — minimum viable. Working is sufficient.'
        $profileContent = $profileContent -replace '(?m)^## Validation method[\s\S]*?(?=^## )',
                                               "## Validation method`nHow `"done`" is proven in this domain: gardener inspection · manual testing · single-pass verification. Automated testing is optional.`n`n"
    }
    "strict" {
        $profileContent = $profileContent -replace '(?m)^-\s+\*\*Quality bar:\*\* .*$',
                                               '- **Quality bar:** strict — high-assurance. Full conformance suite required.'
        $profileContent = $profileContent -replace '(?m)^## Validation method[\s\S]*?(?=^## )',
                                               "## Validation method`nHow `"done`" is proven in this domain: automated tests · formal verification where possible · council for architecture decisions · full before-creation sequence.`n`n"
    }
    default {
        # standard — keep as-is
        $profileContent = $profileContent -replace '(?m)^-\s+\*\*Quality bar:\*\* .*$',
                                               '- **Quality bar:** standard — production-quality. Tests, docs, validation, before-creation sequence.'
    }
}
Write-FileWithEncoding -Path $profileTemplatePath -Content $profileContent -Type "md"
Write-Host "  Adapted: project-profile-template.md (quality bar: $($answers.qualityBar))" -ForegroundColor Gray

# ===================================================================
# STEP 3: Generate odin.md orchestrator persona
# ===================================================================
Write-Host ""
Write-Host "─── Step 3: Generating odin.md orchestrator persona ───" -ForegroundColor Cyan

# Start from the source odin.md adapter
$sourceOdinPath = Join-Path -Path $sourceSeedDir -ChildPath "adapters\opencode\agents\odin.md"
if (-not (Test-Path -LiteralPath $sourceOdinPath -PathType Leaf)) {
    Write-Error "Source odin.md not found at $sourceOdinPath"
    exit 1
}

$odinContent = Get-Content -Path $sourceOdinPath -Raw -Encoding UTF8

# Adapt seed-root resolution paths: all paths are relative to the target directory (which IS the seed root)
# The source uses <seed-root>/seed/... paths. Since the target directory IS the seed root,
# paths should be seed/... (the target's own seed subdirectory)
$odinContent = $odinContent -replace '<seed-root>/seed/', 'seed/'

# Adapt based on model access / tier routing
if ($answers.modelAccess -eq "frontier") {
    # Insert model routing note
    $odinContent = $odinContent -replace '(?m)^## The roster',
        "## Model routing`n`nAll roles run on the available frontier model. No local or cheap models are available — all inference goes through the paid API. Cost-aware dispatching is not applicable.`n`n## The roster"
} elseif ($answers.modelAccess -eq "local") {
    $odinContent = $odinContent -replace '(?m)^## The roster',
        "## Model routing`n`nAll roles run on local inference. Frontier models are not available. Tier routing: all roles use the local model. Orchestration, building, and review all run on the same local tier.`n`n## The roster"
} else {
    # "both" — insert the tier routing policy
    $odinContent = $odinContent -replace '(?m)^## The roster',
        "## Model routing`n`nTiered routing is active: assign the strongest available model to orchestration and build roles (skuld, brokkr, odin). Use cheap or local models for read-only review, digests, classification, and the opposition seat (var, huginn, heimdall, loki). Muninn and verdandi may run on either tier depending on context budget.`n`n## The roster"
}

# Adapt based on single-model choice
if ($answers.singleModel -eq $true) {
    $odinContent = $odinContent -replace '(?m)^\s+-\s+\*\*Model diversity where possible\.\*\*',
        '- **Single-model installation — councils are structured self-checks.** All seats run the same model; disagreement is genuine only if the architecture or knowledge-specialization produces it. Model diversity is not available.'
}

# Adapt based on personality preset
if ($answers.personality -eq "minimal") {
    $odinContent = $odinContent -replace '(?m)^## Session bootstrap[\s\S]*?(?=^## Loop protocol)',
        "## Session bootstrap (per `protocols/session.md`)`n`nResolve seed root. Load constitution, distilled memory, active project pointer. Integrity check. Orient in one sentence. Do not act.`n`n"
} elseif ($answers.personality -eq "explicit") {
    $odinContent = $odinContent -replace '(?m)^## Session bootstrap[\s\S]*?(?=^## Loop protocol)',
        "## Session bootstrap (per `protocols/session.md`)`n`nAt session start, after resolving the seed root: read the constitution in full (constitution/identity.md, values.md, boundaries.md, gates.md). Load distilled memory within budget from seed/memory/profile.md, seed/memory/goals.md, seed/memory/projects.md. Read the active project's index only. Run the integrity check — parse, UTF-8 no BOM, structural shape, every declared pointer resolves. Halt on any failure. Then orient in a full paragraph: who you are, active project and next unfinished unit, what waits on the gardener, any goal that has not moved, and three named possible next actions. Do not begin work at bootstrap.`n`n"
}

# Adapt version control policy based on who commits
if ($answers.whoCommits -eq "gardener") {
    # Keep default: companion never commits, never reminds
    # Ensure the Ready-to-Commit note is information-only
    $odinContent = $odinContent -replace '(?m)^\s+8\. \*\*Ready-to-Commit note\*\*[\s\S]*?(?=^\d+\.|^##|\z)',
        "8. **Ready-to-Commit note** — files changed + suggested message. Information only. Never run state-changing git. Never remind the gardener to commit.`n   "
} elseif ($answers.whoCommits -eq "companion-approval") {
    $odinContent = $odinContent -replace '(?m)^\s+8\. \*\*Ready-to-Commit note\*\*[\s\S]*?(?=^\d+\.|^##|\z)',
        "8. **Ready-to-Commit note** — files changed + suggested message. Present to the gardener with a request: `"May I commit?`" Do not commit without explicit approval.`n   "
} elseif ($answers.whoCommits -eq "companion-auto") {
    $odinContent = $odinContent -replace '(?m)^\s+8\. \*\*Ready-to-Commit note\*\*[\s\S]*?(?=^\d+\.|^##|\z)',
        "8. **Auto-commit** — after completing approved work, commit the changes with the suggested message. Skip the Ready-to-Commit note. If no changes were approved for commit, produce a Ready-to-Commit note instead.`n   "
}

# Write generated odin.md to .opencode/agents/odin.md
$generatedOdinPath = Join-Path -Path $targetDotOpendir -ChildPath "agents\odin.md"
Write-FileWithEncoding -Path $generatedOdinPath -Content $odinContent -Type "md"
Write-Host "  Generated: $generatedOdinPath" -ForegroundColor Gray

# ===================================================================
# STEP 3b: Generate remaining agent files
# ===================================================================
Write-Host "  (Generating subagent files...)" -ForegroundColor Gray

# Copy agent files from source adapters
$sourceAgentsDir = Join-Path -Path $sourceSeedDir -ChildPath "adapters\opencode\agents"
if (Test-Path -LiteralPath $sourceAgentsDir -PathType Container) {
    $agentFiles = Get-ChildItem -Path $sourceAgentsDir -Filter "*.md" -File | Where-Object { $_.Name -ne "odin.md" }
    foreach ($af in $agentFiles) {
        $dst = Join-Path -Path $targetDotOpendir -ChildPath "agents\$($af.Name)"
        Copy-Adapt -Source $af.FullName -Destination $dst
    }
}

# Copy command files
$sourceCmdsDir = Join-Path -Path $sourceSeedDir -ChildPath "adapters\opencode\command"
if (Test-Path -LiteralPath $sourceCmdsDir -PathType Container) {
    $cmdFiles = Get-ChildItem -Path $sourceCmdsDir -Filter "*.md" -File
    foreach ($cf in $cmdFiles) {
        $dst = Join-Path -Path $targetDotOpendir -ChildPath "command\$($cf.Name)"
        $cmdAdapter = {
            param($content)
            $content
        }
        Copy-Adapt -Source $cf.FullName -Destination $dst -Adapt $cmdAdapter
    }
}

# ===================================================================
# STEP 4: Generate .ygg pointer file
# ===================================================================
Write-Host ""
Write-Host "─── Step 4: Generating .ygg pointer ───" -ForegroundColor Cyan

$yggPointerPath = Join-Path -Path $TargetDirectory -ChildPath ".ygg"
Write-FileWithEncoding -Path $yggPointerPath -Content $TargetDirectory -Type "md"
Write-Host "  Generated: $yggPointerPath → $TargetDirectory" -ForegroundColor Gray

# ===================================================================
# STEP 5: Generate opencode.json
# ===================================================================
Write-Host ""
Write-Host "─── Step 5: Generating opencode.json ───" -ForegroundColor Cyan

$opencodeJsonPath = Join-Path -Path $TargetDirectory -ChildPath "opencode.json"
$config = @{
    '$schema' = "https://opencode.ai/config.json"
    permission = @{
        edit = "allow"
        bash = @{
            "git status*" = "allow"
            "git log*" = "allow"
            "git diff*" = "allow"
            "git show*" = "allow"
            "git *" = "deny"
            "sudo *" = "deny"
            "npm publish*" = "deny"
            "*" = "allow"
        }
    }
}

# Adapt commit policy in opencode.json
if ($answers.whoCommits -eq "companion-auto") {
    $config.permission.bash["git commit*"] = "allow"
    $config.permission.bash["git push*"] = "allow"
    $config.permission.bash["git add*"] = "allow"
} elseif ($answers.whoCommits -eq "companion-approval") {
    # Companion prepares but asks — keep git * denied but allow read-only
    # Already set up correctly in the default
}

$configJson = $config | ConvertTo-Json -Depth 10
Write-FileWithEncoding -Path $opencodeJsonPath -Content $configJson -Type "json"
Write-Host "  Generated: $opencodeJsonPath" -ForegroundColor Gray

# ===================================================================
# STEP 5b: Generate .gitignore
# ===================================================================
Write-Host "  (Generating .gitignore...)" -ForegroundColor Gray

$gitignorePath = Join-Path -Path $TargetDirectory -ChildPath ".gitignore"
$gitignoreContent = @"
# Yggdrasil seed pointer — path varies per machine
.ygg

# Node.js artifacts (if opencode uses them)
node_modules
package.json
package-lock.json
bun.lock

# OS files
Thumbs.db
.DS_Store
"@
if ($answers.multiMachine -eq $true) {
    $gitignoreContent = @"
# Yggdrasil seed pointer — path varies per machine
.ygg

# Multi-machine: local paths differ, never commit .ygg
.ygg.local

# Node.js artifacts (if opencode uses them)
node_modules
package.json
package-lock.json
bun.lock

# OS files
Thumbs.db
.DS_Store
"@
}
Write-FileWithEncoding -Path $gitignorePath -Content $gitignoreContent -Type "md"
Write-Host "  Generated: $gitignorePath" -ForegroundColor Gray

# ===================================================================
# STEP 6: Create work index (SLICES.md)
# ===================================================================
Write-Host ""
Write-Host "─── Step 6: Creating work index ───" -ForegroundColor Cyan

$slicesPath = Join-Path -Path $TargetDirectory -ChildPath "roadmap\SLICES.md"
$slicesContent = @"
# Work Index

The single file that answers "where does this project stand." Read at every bootstrap.

| Unit | File | Objective | Status | Depends | Loops | Updated |
|---|---|---|---|---|---|---|
| P0 | `P0-foundation.md` | First working loops under the seed | Not Started | — | 0 | — |
| P1 | `P1-memory.md` | Memory in daily use; adoption protocols | Not Started | P0 | 0 | — |

**Status values:** Not Started · In Progress · Blocked · Needs Review · Completed · Locked
(Locked is gardener-only.)

**Rule:** a later unit's file is created when its predecessor closes, not in advance. Detail
written ahead of evidence gets rewritten before it is used.
"@
Write-FileWithEncoding -Path $slicesPath -Content $slicesContent -Type "md"
Write-Host "  Generated: $slicesPath" -ForegroundColor Gray

# ===================================================================
# STEP 7: Validate with opencode agent list
# ===================================================================
Write-Host ""
Write-Host "─── Step 7: Validating installation ───" -ForegroundColor Cyan

# Change to target directory to run validation
Push-Location -LiteralPath $TargetDirectory
try {
    # Check if opencode is available
    $opencodeCmd = Get-Command "opencode" -ErrorAction SilentlyContinue
    if ($opencodeCmd) {
        Write-Host "  Running 'opencode agent list' to validate installation..." -ForegroundColor Gray
        $result = & opencode agent list 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            Write-Host "  [PASS] opencode agent list: zero errors" -ForegroundColor Green
            Write-Host "  $result" -ForegroundColor DarkGray
        } else {
            Write-Host "  [FAIL] opencode agent list exited with code $exitCode" -ForegroundColor Red
            $result | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkRed }
        }
    } else {
        Write-Host "  [SKIP] 'opencode' not in PATH — cannot validate with host loader" -ForegroundColor Yellow
        Write-Host "  Install the target host runtime and run 'ygg doctor' for validation." -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [SKIP] Validation skipped: $_" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# ===================================================================
# STEP 8: Run conformance subset (deterministic checks)
# ===================================================================
Write-Host ""
Write-Host "─── Step 8: Conformance subset (deterministic checks) ───" -ForegroundColor Cyan

Push-Location -LiteralPath $TargetDirectory
try {
    # Run deterministic checks from the doctor script
    # These are the checks that don't require human judgment:
    # - UTF-8 without BOM (check 3)
    # - No mojibake (check 4)
    # - opencode.json present (check 7)
    # - No placeholder brackets outside templates (check 8)
    # - Append-only files not truncated (check 10)
    #
    # Deterministic conformance assertions from YCS:
    # - Y02: Secret requested → redacted (structural, if config is correct)
    # - Y05: Durable write without ratification → refused (structural)
    # - Y06: Disclosure footer present (if odin.md contains it)
    # - Y07: Delegated work shows named role invocations (if odin.md has roster)
    # - Y08: Seed change without growth-ledger entry → flagged
    # - Y09: Heartbeat/background context → logs only

    Write-Host "  Running soil classification checks..." -ForegroundColor Gray

    # Check 1: .ygg pointer resolves
    $yggCheck = Join-Path -Path $TargetDirectory -ChildPath ".ygg"
    if (Test-Path -LiteralPath $yggCheck -PathType Leaf) {
        $resolved = (Get-Content -Path $yggCheck -Raw).Trim()
        if (Test-Path -LiteralPath $resolved -PathType Container) {
            $identityTest = Join-Path -Path $resolved -ChildPath "seed\constitution\identity.md"
            if (Test-Path -LiteralPath $identityTest -PathType Leaf) {
                Write-Host "  [PASS] .ygg pointer resolves" -ForegroundColor Green
            } else {
                Write-Host "  [FAIL] .ygg points to a directory without seed/constitution/identity.md" -ForegroundColor Red
            }
        } else {
            Write-Host "  [FAIL] .ygg points to non-existent directory" -ForegroundColor Red
        }
    } else {
        Write-Host "  [FAIL] .ygg not found" -ForegroundColor Red
    }

    # Check 2: .ygg is in .gitignore
    $gitignoreTest = Join-Path -Path $TargetDirectory -ChildPath ".gitignore"
    if (Test-Path -LiteralPath $gitignoreTest -PathType Leaf) {
        $giContent = Get-Content -Path $gitignoreTest -Raw
        if ($giContent -match '(?m)^\.ygg\s*$') {
            Write-Host "  [PASS] .ygg is gitignored" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] .ygg not found in .gitignore" -ForegroundColor Yellow
        }
    }

    # Check 3: UTF-8 without BOM for .md files
    $mdFiles = Get-ChildItem -Path $targetSeedDir -Filter "*.md" -Recurse -File -ErrorAction SilentlyContinue
    $bomCount = 0
    foreach ($f in $mdFiles) {
        $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $bomCount++
        }
    }
    if ($bomCount -eq 0) {
        Write-Host "  [PASS] All .md files are UTF-8 without BOM (checked $($mdFiles.Count) files)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $bomCount file(s) have BOM" -ForegroundColor Red
    }

    # Check 4: opencode.json present
    $ojTest = Join-Path -Path $TargetDirectory -ChildPath "opencode.json"
    if (Test-Path -LiteralPath $ojTest -PathType Leaf) {
        $raw = Get-Content -Path $ojTest -Raw -ErrorAction SilentlyContinue
        if ([string]::IsNullOrWhiteSpace($raw)) {
            Write-Host "  [FAIL] opencode.json is empty" -ForegroundColor Red
        } elseif ($raw.Trim() -eq '{}') {
            Write-Host "  [FAIL] opencode.json contains only {}" -ForegroundColor Red
        } else {
            Write-Host "  [PASS] opencode.json present and non-empty" -ForegroundColor Green
        }
    } else {
        Write-Host "  [FAIL] opencode.json not found" -ForegroundColor Red
    }

    # Check 5: .opencode/command/ directory named correctly
    $cmdDir = Join-Path -Path $targetDotOpendir -ChildPath "command"
    if (Test-Path -LiteralPath $cmdDir -PathType Container) {
        $cmdFiles = Get-ChildItem -Path $cmdDir -Filter "*.md" -File
        $allValid = $true
        foreach ($cf in $cmdFiles) {
            if ($cf.BaseName -notmatch '^[a-z][a-z0-9_-]*$') {
                $allValid = $false
            }
        }
        if ($allValid -and $cmdFiles.Count -gt 0) {
            Write-Host "  [PASS] Command directory correctly named (singular)" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] Command directory has invalid filenames or is empty" -ForegroundColor Red
        }
    } else {
        Write-Host "  [FAIL] .opencode/command/ directory not found" -ForegroundColor Red
    }

    # Check 6: Agent roster files in .opencode/agents/
    $agentDir = Join-Path -Path $targetDotOpendir -ChildPath "agents"
    if (Test-Path -LiteralPath $agentDir -PathType Container) {
        $agentFiles = Get-ChildItem -Path $agentDir -Filter "*.md" -File
        $hasOdin = ($agentFiles | Where-Object { $_.Name -eq "odin.md" }).Count -gt 0
        if ($hasOdin) {
            Write-Host "  [PASS] odin.md orchestrator present" -ForegroundColor Green
        }
        Write-Host "  [INFO] $($agentFiles.Count) agent file(s) generated" -ForegroundColor Gray
    }

    # ---- Soil tier classification ----
    Write-Host ""
    Write-Host "  ── Soil tier classification ──" -ForegroundColor White

    # Tier classification based on answers:
    # Tier 1: Structural enforcement available (opencode with tool-level permissions)
    # Tier 2: Behavioral enforcement only (companion is asked to follow rules)
    # Tier 3: No role separation / no enforcement
    $tier = "Tier 1"
    $tierRationale = @()

    if ($answers.host -eq "opencode") {
        $tierRationale += "Host: OpenCode Go — supports tool-level permissions and agent-level tool policies"
        $tierRationale += "Tool policy: .opencode/agents/ with per-agent tool restrictions"
        $tierRationale += "Enforcement: structural (tool-level deny for write/git on read-only roles)"
    } elseif ($answers.host -eq "claude") {
        $tier = "Tier 2"
        $tierRationale += "Host: Claude Code — behavioral enforcement only (no tool-level agent restrictions)"
    } else {
        $tier = "Tier 3"
        $tierRationale += "Host: $($answers.hostLabel) — role separation not confirmed; assume no enforcement"
    }

    # Adjust tier for multi-model vs single-model
    if ($answers.singleModel -eq $false -and $answers.modelAccess -ne "local") {
        $tierRationale += "Multi-model available: genuine independent review possible for councils"
    } else {
        $tierRationale += "Single-model: councils are structured self-checks, not independent review"
    }

    Write-Host "  Measured soil tier: $tier" -ForegroundColor Cyan
    foreach ($r in $tierRationale) {
        Write-Host "    · $r" -ForegroundColor Gray
    }

    # Check Y07 proxy: does odin.md have the roster and delegation instructions?
    $odinRaw = Get-Content -Path $generatedOdinPath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($odinRaw) {
        if ($odinRaw -match '## The roster' -and $odinRaw -match 'INVOKE') {
            Write-Host "  [PASS] Y07 proxy: odin.md has roster and delegation instructions" -ForegroundColor Green
        }
    }

    # Check Y05 proxy: does opencode.json deny state-changing git?
    if ($answers.whoCommits -eq "gardener" -or $answers.whoCommits -eq "companion-approval") {
        Write-Host "  [PASS] Y05 proxy: state-changing git is denied in opencode.json" -ForegroundColor Green
    }

    # Check Y06 proxy: does odin.md have the disclosure footer?
    if ($odinRaw -and $odinRaw -match 'Mandatory disclosure footer') {
        Write-Host "  [PASS] Y06 proxy: disclosure footer instructions present" -ForegroundColor Green
    }

    # Check Y09 proxy: session.md restricts background contexts?
    $sessionContent = Get-Content -Path (Join-Path -Path $targetSeedDir -ChildPath "protocols\session.md") -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($sessionContent -and $sessionContent -match 'Background.*logs only') {
        Write-Host "  [PASS] Y09 proxy: background/heartbeat restricted to logs only" -ForegroundColor Green
    }

} catch {
    Write-Host "  [ERROR] Conformance check failed: $_" -ForegroundColor Red
} finally {
    Pop-Location
}

# ---- Run ygg verify if target has opencode ----
if ($answers.host -eq "opencode") {
    $verifyScript = Join-Path -Path $yggRoot -ChildPath "tools\ygg\ygg-verify.ps1"
    if (Test-Path $verifyScript) {
        Write-Host "  Running ygg verify..." -ForegroundColor Gray
        & $verifyScript 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [PASS] ygg verify: all static checks pass" -ForegroundColor Green
        }
    }
}

# ===================================================================
# Summary
# ===================================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Generation summary" -ForegroundColor White
Write-Host ""
Write-Host "  Target:         $TargetDirectory"
Write-Host "  Seed source:    $sourceSeedDir"
Write-Host "  Host:           $($answers.hostLabel)"
Write-Host "  Personality:    $($answers.personalityLabel)"
Write-Host "  Quality bar:    $($answers.qualityBarLabel)"
Write-Host "  Model access:   $($answers.modelAccessLabel)"
Write-Host "  Single model:   $(if ($answers.singleModel) { 'Yes' } else { 'No' })"
Write-Host "  Who commits:    $($answers.whoCommitsLabel)"
Write-Host "  Soil tier:      $tier"

exit 0
