# ygg plant — interactive seed installation wizard
<#
.SYNOPSIS
  Interactive wizard that asks seven questions and generates a working seed installation.
.DESCRIPTION
  Usage: ygg plant [target-directory]
  Default target-directory: current working directory.
  Asks seven questions about consequences (not attributes), writes answers to
  a manifest, then calls ygg-generate.ps1 to produce the installation.
.EXAMPLE
  ygg plant
  ygg plant C:\projects\my-project
#>

param(
    [string]$TargetDirectory = ""
)

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")
$seedDir = Join-Path -Path $yggRoot -ChildPath "seed"

# Resolve target directory
if ([string]::IsNullOrWhiteSpace($TargetDirectory)) {
    $TargetDirectory = (Get-Location).Path
}
$TargetDirectory = [System.IO.Path]::GetFullPath($TargetDirectory)

# ---- Pre-checks ----
if (-not (Test-Path -LiteralPath $TargetDirectory -PathType Container)) {
    Write-Host "Error: Target directory does not exist: $TargetDirectory" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path -LiteralPath $seedDir -PathType Container)) {
    Write-Host "Error: Seed directory not found at $seedDir" -ForegroundColor Red
    Write-Host "       ygg plant must be run from within the yggdrasil repository." -ForegroundColor Red
    exit 1
}

$existingItems = Get-ChildItem -LiteralPath $TargetDirectory -Force -ErrorAction SilentlyContinue
$hasVisibleContents = @($existingItems | Where-Object { $_.Name -ne '.git' }).Count -gt 0

if ($hasVisibleContents) {
    Write-Host "Warning: Target directory '$TargetDirectory' is not empty." -ForegroundColor Yellow
    $cont = Read-Host "Continue anyway? (y/N)"
    if ($cont -ne 'y' -and $cont -ne 'Y') {
        Write-Host "Aborted." -ForegroundColor Yellow
        exit 1
    }
}

# ---- Banner ----
Write-Host @"

╔══════════════════════════════════════════════════╗
║          ygg plant — seed installation           ║
║                                                  ║
║  Eight questions about consequences, not trivia. ║
║  Each answer writes a behavioural rule, not an   ║
║  attribute.                                      ║
╚══════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Host "Target: $TargetDirectory" -ForegroundColor DarkCyan
Write-Host "Source seed: $seedDir" -ForegroundColor DarkCyan
Write-Host ""

# ---- Question 1: Host ----
Write-Host "─── Question 1 of 7: Host ───" -ForegroundColor Cyan
Write-Host "Which host runtime will run this seed? This determines which adapter"
Write-Host "templates to use and how the seed's constitution is loaded."
Write-Host ""
Write-Host "  1) OpenCode Go     — primary host, provides OpenCode soil and model access"
Write-Host "  2) Claude Code     — second soil, for portability verification"
Write-Host "  3) Ollama          — local inference host, verification bench only"
Write-Host "  4) Other           — a host not yet in the adapter registry"
Write-Host ""
$hostChoice = Read-Host "Choice (1-4) [1]"
if ([string]::IsNullOrWhiteSpace($hostChoice)) { $hostChoice = "1" }

$hostMap = @{ "1" = "opencode"; "2" = "claude"; "3" = "ollama"; "4" = "other" }
while ($hostMap.ContainsKey($hostChoice) -eq $false) {
    Write-Host "Invalid choice. Please enter 1, 2, 3, or 4." -ForegroundColor Red
    $hostChoice = Read-Host "Choice (1-4) [1]"
    if ([string]::IsNullOrWhiteSpace($hostChoice)) { $hostChoice = "1" }
}
$answersHost = $hostMap[$hostChoice]

$hostLabels = @{ "opencode" = "OpenCode Go"; "claude" = "Claude Code"; "ollama" = "Ollama"; "other" = "Other" }
Write-Host "  → $($hostLabels[$answersHost])" -ForegroundColor Green
Write-Host ""

# ---- Question 2: Multi-machine ----
Write-Host "─── Question 2 of 7: Multi-machine ───" -ForegroundColor Cyan
Write-Host "Will this seed run on more than one machine? If yes, the .ygg pointer"
Write-Host "must be gitignored (each machine has its own path), and adapter templates"
Write-Host "will include multi-machine fallback logic."
Write-Host ""
$multiMachine = Read-Host "Run on multiple machines? (y/N) [n]"
if ([string]::IsNullOrWhiteSpace($multiMachine)) { $multiMachine = "n" }
while ($multiMachine -notin @("y", "Y", "n", "N")) {
    Write-Host "Please enter 'y' or 'n'." -ForegroundColor Red
    $multiMachine = Read-Host "Run on multiple machines? (y/N) [n]"
    if ([string]::IsNullOrWhiteSpace($multiMachine)) { $multiMachine = "n" }
}
$answersMultiMachine = ($multiMachine -eq "y" -or $multiMachine -eq "Y")
Write-Host "  → $(if ($answersMultiMachine) { 'Yes — .ygg will be gitignored; multi-machine strategy active' } else { 'No — single-machine installation' })" -ForegroundColor Green
Write-Host ""

# ---- Question 3: Model access ----
Write-Host "─── Question 3 of 7: Model access ───" -ForegroundColor Cyan
Write-Host "What model access do you have? This drives tier routing — which roles"
Write-Host "get frontier models vs local/cheap models."
Write-Host ""
Write-Host "  1) Frontier API only  — all calls through a paid API (OpenAI, Anthropic, etc.)"
Write-Host "  2) Local only         — all inference runs locally (Ollama, llama.cpp, etc.)"
Write-Host "  3) Both               — route orchestrator and build roles to frontier;"
Write-Host "                          read-only, review, and opposition seats to local"
Write-Host ""
$modelChoice = Read-Host "Choice (1-3) [3]"
if ([string]::IsNullOrWhiteSpace($modelChoice)) { $modelChoice = "3" }
$modelMap = @{ "1" = "frontier"; "2" = "local"; "3" = "both" }
while ($modelMap.ContainsKey($modelChoice) -eq $false) {
    Write-Host "Invalid choice. Please enter 1, 2, or 3." -ForegroundColor Red
    $modelChoice = Read-Host "Choice (1-3) [3]"
    if ([string]::IsNullOrWhiteSpace($modelChoice)) { $modelChoice = "3" }
}
$answersModel = $modelMap[$modelChoice]

$modelLabels = @{ "frontier" = "Frontier API only"; "local" = "Local only"; "both" = "Both — tiered routing" }
Write-Host "  → $($modelLabels[$answersModel])" -ForegroundColor Green
Write-Host ""

# ---- Question 4: Single-model ----
Write-Host "─── Question 4 of 7: Single-model ───" -ForegroundColor Cyan
Write-Host "Will this run with a single model? If yes, councils (the Thing) will be"
Write-Host "labeled as structured self-checks, not independent review — because"
Write-Host "one model in several seats produces one opinion in several voices."
Write-Host ""
$singleModel = Read-Host "Single model only? (Y/n) [y]"
if ([string]::IsNullOrWhiteSpace($singleModel)) { $singleModel = "y" }
while ($singleModel -notin @("y", "Y", "n", "N")) {
    Write-Host "Please enter 'y' or 'n'." -ForegroundColor Red
    $singleModel = Read-Host "Single model only? (Y/n) [y]"
    if ([string]::IsNullOrWhiteSpace($singleModel)) { $singleModel = "y" }
}
$answersSingleModel = ($singleModel -eq "y" -or $singleModel -eq "Y")
Write-Host "  → $(if ($answersSingleModel) { 'Yes — councils labeled as structured self-checks' } else { 'No — multi-model councils available for independent review' })" -ForegroundColor Green
Write-Host ""

# ---- Question 5: Who commits ----
Write-Host "─── Question 5 of 7: Version control ───" -ForegroundColor Cyan
Write-Host "Who controls version control commits? This affects the seed's commit"
Write-Host "policy and whether the companion may propose or execute commits."
Write-Host ""
Write-Host "  1) Me (gardener)            — I commit at my discretion. Never commit,"
Write-Host "                                  never remind me. Ready-to-Commit notes only."
Write-Host "  2) Companion with approval  — The companion may prepare commits but must"
Write-Host "                                  ask before executing each one."
Write-Host "  3) Companion autonomously   — The companion may commit approved changes"
Write-Host "                                  without per-commit approval."
Write-Host ""
$commitChoice = Read-Host "Choice (1-3) [1]"
if ([string]::IsNullOrWhiteSpace($commitChoice)) { $commitChoice = "1" }
$commitMap = @{ "1" = "gardener"; "2" = "companion-approval"; "3" = "companion-auto" }
while ($commitMap.ContainsKey($commitChoice) -eq $false) {
    Write-Host "Invalid choice. Please enter 1, 2, or 3." -ForegroundColor Red
    $commitChoice = Read-Host "Choice (1-3) [1]"
    if ([string]::IsNullOrWhiteSpace($commitChoice)) { $commitChoice = "1" }
}
$answersCommit = $commitMap[$commitChoice]

$commitLabels = @{
    "gardener" = "Gardener commits only — companion never touches git"
    "companion-approval" = "Companion may prepare commits but asks before each"
    "companion-auto" = "Companion commits autonomously"
}
Write-Host "  → $($commitLabels[$answersCommit])" -ForegroundColor Green
Write-Host ""

# ---- Question 6: Personality preset ----
Write-Host "─── Question 6 of 7: Personality ───" -ForegroundColor Cyan
Write-Host "Choose a personality preset. This affects the companion's register,"
Write-Host "standing rules, and communication style in identity.md."
Write-Host ""
Write-Host "  1) Default   — Direct, plain, calibrated. No preamble, no closing"
Write-Host "                  pleasantries. Critical feedback expected."
Write-Host "  2) Minimal   — Ultra-brief. Answer in as few words as possible."
Write-Host "                  No orientation, no disclosure elaboration."
Write-Host "  3) Explicit  — Verbose. Full preamble, elaborated reasoning,"
Write-Host "                  explicit confirmation before acting."
Write-Host ""
$personalityChoice = Read-Host "Choice (1-3) [1]"
if ([string]::IsNullOrWhiteSpace($personalityChoice)) { $personalityChoice = "1" }
$personalityMap = @{ "1" = "default"; "2" = "minimal"; "3" = "explicit" }
while ($personalityMap.ContainsKey($personalityChoice) -eq $false) {
    Write-Host "Invalid choice. Please enter 1, 2, or 3." -ForegroundColor Red
    $personalityChoice = Read-Host "Choice (1-3) [1]"
    if ([string]::IsNullOrWhiteSpace($personalityChoice)) { $personalityChoice = "1" }
}
$answersPersonality = $personalityMap[$personalityChoice]

$personalityLabels = @{ "default" = "Default — direct and plain"; "minimal" = "Minimal — ultra-brief"; "explicit" = "Explicit — verbose and thorough" }
Write-Host "  → $($personalityLabels[$answersPersonality])" -ForegroundColor Green
Write-Host ""

# ---- Question 7: Quality bar ----
Write-Host "─── Question 7 of 7: Quality bar ───" -ForegroundColor Cyan
Write-Host "Select quality bar. This sets the default quality threshold in the"
Write-Host "project profile template and affects conformance expectations."
Write-Host ""
Write-Host "  1) MVP       — Minimum viable. Working is enough. Sparse tests,"
Write-Host "                  minimal documentation, single-pass validation."
Write-Host "  2) Standard  — Production-quality. Tests, docs, validation,"
Write-Host "                  before-creation sequence required."
Write-Host "  3) Strict    — High-assurance. Formal verification where possible,"
Write-Host "                  full conformance suite, mandatory council for"
Write-Host "                  architecture decisions."
Write-Host ""
$qualityChoice = Read-Host "Choice (1-3) [2]"
if ([string]::IsNullOrWhiteSpace($qualityChoice)) { $qualityChoice = "2" }
$qualityMap = @{ "1" = "mvp"; "2" = "standard"; "3" = "strict" }
while ($qualityMap.ContainsKey($qualityChoice) -eq $false) {
    Write-Host "Invalid choice. Please enter 1, 2, or 3." -ForegroundColor Red
    $qualityChoice = Read-Host "Choice (1-3) [2]"
    if ([string]::IsNullOrWhiteSpace($qualityChoice)) { $qualityChoice = "2" }
}
$answersQuality = $qualityMap[$qualityChoice]

$qualityLabels = @{ "mvp" = "MVP — minimum viable"; "standard" = "Standard — production-quality"; "strict" = "Strict — high-assurance" }
Write-Host "  → $($qualityLabels[$answersQuality])" -ForegroundColor Green
Write-Host ""

# ---- Question 8: Notifications ----
Write-Host "─── Question 8 of 8: Notifications ───" -ForegroundColor Cyan
Write-Host "Would you like to receive push notifications (daily briefings, goal-stall"
Write-Host "alerts) from the companion? This is optional — the heartbeat runs and writes"
Write-Host "to logs regardless."
Write-Host ""
Write-Host "  1) Skip — log-only mode, no push notifications"
Write-Host "  2) Telegram — requires a bot token and chat ID"
Write-Host "  3) ntfy.sh — requires a topic name (free, no account needed)"
Write-Host "  4) Discord — requires a webhook URL"
Write-Host ""
$notifChoice = Read-Host "Choice (1-4) [1]"
if ([string]::IsNullOrWhiteSpace($notifChoice)) { $notifChoice = "1" }
$notifMap = @{ "1" = "skip"; "2" = "telegram"; "3" = "ntfy"; "4" = "discord" }
while ($notifMap.ContainsKey($notifChoice) -eq $false) {
    Write-Host "Invalid choice. Please enter 1, 2, 3, or 4." -ForegroundColor Red
    $notifChoice = Read-Host "Choice (1-4) [1]"
    if ([string]::IsNullOrWhiteSpace($notifChoice)) { $notifChoice = "1" }
}
$answersNotif = $notifMap[$notifChoice]
$notifLabels = @{ "skip" = "Log-only (no push)"; "telegram" = "Telegram"; "ntfy" = "ntfy.sh"; "discord" = "Discord" }

$notifValue = ""
if ($answersNotif -eq "telegram") {
    Write-Host ""
    Write-Host "  Telegram setup:" -ForegroundColor Cyan
    Write-Host "  You need a bot token from @BotFather and your chat ID."
    Write-Host "  These are secrets — they will NOT be stored in any file."
    Write-Host "  They will be printed at the end for you to set as environment variables."
    Write-Host ""
    $botToken = Read-Host "  Bot token (from @BotFather)"
    $chatId = Read-Host "  Chat ID (numeric, from /getUpdates)"
    $notifValue = "telegram|$botToken|$chatId"
    Write-Host "  → Telegram configured" -ForegroundColor Green
} elseif ($answersNotif -eq "ntfy") {
    Write-Host ""
    Write-Host "  ntfy.sh setup:" -ForegroundColor Cyan
    Write-Host "  Choose a unique topic name (e.g., ygg-<yourname>-<random>)."
    Write-Host "  Subscribe to this topic in the ntfy.sh app to receive notifications."
    Write-Host ""
    $topic = Read-Host "  Topic name"
    $notifValue = "ntfy|$topic"
    Write-Host "  → ntfy.sh configured with topic: $topic" -ForegroundColor Green
} elseif ($answersNotif -eq "discord") {
    Write-Host ""
    Write-Host "  Discord setup:" -ForegroundColor Cyan
    Write-Host "  Create a webhook in your Discord server (Server Settings → Integrations)."
    Write-Host "  The webhook URL is a secret — it will NOT be stored in any file."
    Write-Host ""
    $webhook = Read-Host "  Webhook URL"
    $notifValue = "discord|$webhook"
    Write-Host "  → Discord configured" -ForegroundColor Green
} else {
    Write-Host "  → Skipped — log-only mode" -ForegroundColor Green
}
Write-Host ""

# ---- Summary ----
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Summary of your choices:" -ForegroundColor White
Write-Host ""
Write-Host "  Host:               $($hostLabels[$answersHost])"
Write-Host "  Multi-machine:      $(if ($answersMultiMachine) { 'Yes' } else { 'No' })"
Write-Host "  Model access:       $($modelLabels[$answersModel])"
Write-Host "  Single model:       $(if ($answersSingleModel) { 'Yes — self-check councils' } else { 'No — multi-model councils' })"
Write-Host "  Who commits:        $($commitLabels[$answersCommit])"
Write-Host "  Personality:        $($personalityLabels[$answersPersonality])"
Write-Host "  Quality bar:        $($qualityLabels[$answersQuality])"
Write-Host "  Notifications:      $($notifLabels[$answersNotif])"
Write-Host ""

$confirm = Read-Host "Proceed with installation? (Y/n) [y]"
if ([string]::IsNullOrWhiteSpace($confirm)) { $confirm = "y" }
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Installation cancelled." -ForegroundColor Yellow
    exit 1
}

# ---- Build answers hashtable ----
$answers = @{
    "host"              = $answersHost
    "hostLabel"         = $hostLabels[$answersHost]
    "multiMachine"      = $answersMultiMachine
    "modelAccess"       = $answersModel
    "modelAccessLabel"  = $modelLabels[$answersModel]
    "singleModel"       = $answersSingleModel
    "whoCommits"        = $answersCommit
    "whoCommitsLabel"   = $commitLabels[$answersCommit]
    "personality"       = $answersPersonality
    "personalityLabel"  = $personalityLabels[$answersPersonality]
    "qualityBar"        = $answersQuality
    "qualityBarLabel"   = $qualityLabels[$answersQuality]
    "notifications"     = $answersNotif
    "notifValue"        = $notifValue
    "timestamp"         = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    "sourceSeed"        = $seedDir
    "schemaVersion"     = "1"
}

# ---- Write manifest ----
$manifest = @{
    "answers"        = $answers
    "meta"           = @{
        "wizard"       = "ygg-plant.ps1"
        "version"      = "1"
        "generatedAt"  = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        "sourceSeed"   = $seedDir
    }
}

$manifestPath = Join-Path -Path $TargetDirectory -ChildPath "ygg-plant.json"
$manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Encoding UTF8
Write-Host "Manifest written to: $manifestPath" -ForegroundColor DarkCyan

# ---- Call generator ----
Write-Host ""
Write-Host "─── Generating seed installation ───" -ForegroundColor Cyan

$generatorPath = Join-Path -Path $scriptDir -ChildPath "ygg-generate.ps1"
if (-not (Test-Path -LiteralPath $generatorPath -PathType Leaf)) {
    Write-Error "Generator script not found at $generatorPath"
    exit 1
}

& $generatorPath -TargetDirectory $TargetDirectory -ManifestPath $manifestPath
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "✓ Seed installation complete!" -ForegroundColor Green
    Write-Host "  Target: $TargetDirectory" -ForegroundColor DarkCyan
    Write-Host ""

    # ---- Optional: install daemon ----
    Write-Host "─── Optional: install always-on daemon ───" -ForegroundColor Cyan
    Write-Host "The ygg daemon runs in the background to receive Telegram messages"
    Write-Host "and send daily heartbeat briefings automatically."
    Write-Host ""
    $installDaemon = Read-Host "Install ygg daemon as a scheduled task? (y/N) [n]"
    if ([string]::IsNullOrWhiteSpace($installDaemon)) { $installDaemon = "n" }
    if ($installDaemon -eq "y" -or $installDaemon -eq "Y") {
        Write-Host ""
        Write-Host "  Installing ygg daemon scheduled task..." -ForegroundColor DarkCyan
        $installScript = Join-Path -Path $scriptDir -ChildPath "ygg-daemon-install.ps1"
        if (Test-Path -LiteralPath $installScript -PathType Leaf) {
            & $installScript
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Daemon scheduled task created." -ForegroundColor Green
                Write-Host "  Start it now with: ygg daemon start" -ForegroundColor DarkCyan
            } else {
                Write-Host "  ⚠ Daemon installation may need administrator privileges." -ForegroundColor Yellow
                Write-Host "  Run manually: ygg daemon install" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ⚠ Daemon installer not found at: $installScript" -ForegroundColor Yellow
            Write-Host "  Install manually: ygg daemon install" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  Skipped. Install later with: ygg daemon install" -ForegroundColor DarkGray
    }
    Write-Host ""

    Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Review the generated files in $TargetDirectory"
Write-Host "  2. Run 'ygg doctor' to verify the installation"
Write-Host "  3. Run 'ygg daemon start' to enable always-on presence"
Write-Host "  4. Open the project in your host runtime"
if ($answersNotif -ne "skip") {
    Write-Host ""
    Write-Host "Notification setup instructions:" -ForegroundColor Yellow
    if ($answersNotif -eq "telegram") {
        Write-Host "  Set these environment variables in your PowerShell profile:" -ForegroundColor Yellow
        Write-Host "    [Environment]::SetEnvironmentVariable('TELEGRAM_BOT_TOKEN', '<token>', 'User')"
        Write-Host "    [Environment]::SetEnvironmentVariable('TELEGRAM_CHAT_ID', '<chat_id>', 'User')"
    } elseif ($answersNotif -eq "ntfy") {
        Write-Host "  Set this environment variable in your PowerShell profile:" -ForegroundColor Yellow
        Write-Host "    [Environment]::SetEnvironmentVariable('NTFY_TOPIC', '<topic>', 'User')"
    } elseif ($answersNotif -eq "discord") {
        Write-Host "  Set this environment variable in your PowerShell profile:" -ForegroundColor Yellow
        Write-Host "    [Environment]::SetEnvironmentVariable('DISCORD_WEBHOOK', '<url>', 'User')"
    }
}
Write-Host ""
} else {
    Write-Host ""
    Write-Host "✗ Seed installation encountered errors (exit code: $exitCode)." -ForegroundColor Red
    Write-Host "  Check the output above for details." -ForegroundColor Red
}

exit $exitCode
