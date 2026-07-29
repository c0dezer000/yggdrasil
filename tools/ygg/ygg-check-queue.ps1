# ygg-check-queue.ps1 — Task handoff bridge for local session
<#
.SYNOPSIS
  Reads queued Telegram tasks for local session execution, or writes results back.
.DESCRIPTION
  Mode 1 (no args): check work/task-queue.md, print pending task, clear queue
  Mode 2 (-TaskId + -Result): write completion result to work/task-result.md
  Mode 3 (-Ratify): process a ratification request from the queue
.EXAMPLE
  ygg check-queue
  ygg check-queue -TaskId "task-20260729-143022" -Result "completed"
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$TaskId = "",
    [Parameter(Position = 1)]
    [string]$Result = "",
    [switch]$Ratify
)

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$yggRoot   = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..\..")
$workDir   = Join-Path -Path $yggRoot -ChildPath "work"
$taskQueueFile  = Join-Path -Path $workDir -ChildPath "task-queue.md"
$taskResultFile = Join-Path -Path $workDir -ChildPath "task-result.md"
$stagingFile    = Join-Path -Path $yggRoot -ChildPath "seed\memory\staging.md"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

# ---- Mode 3: Process ratification ----
if ($Ratify) {
    if (-not (Test-Path $stagingFile)) { Write-Host "No staging file found."; exit 1 }
    $content = Get-Content $stagingFile -Raw -Encoding UTF8
    $count = 0
    $content = $content -replace '(?m)^(.*)status:\s*proposed(.*)$', '${1}status: **ratified 2026-07-29**${2}'
    $count = ([regex]::Matches($content, 'status:\s*\*\*ratified 2026-07-29\*\*')).Count
    Write-Utf8NoBom -Path $stagingFile -Content $content
    Write-Host "Ratified $count proposal(s) in staging.md"
    exit 0
}

# ---- Mode 2: Write result ----
if ($TaskId -and $Result) {
    if (-not (Test-Path -LiteralPath $workDir -PathType Container)) {
        New-Item -ItemType Directory -Path $workDir -Force | Out-Null
    }
    $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $resultContent = "TASK_ID: $TaskId`r`nTIMESTAMP: $timestamp`r`nRESULT:`r`n$Result`r`nEND"
    Write-Utf8NoBom -Path $taskResultFile -Content $resultContent
    exit 0
}

# ---- Mode 1: Check queue ----
if (-not (Test-Path -LiteralPath $taskQueueFile -PathType Leaf)) { exit 0 }
$content = Get-Content -Path $taskQueueFile -Raw -Encoding UTF8
if ([string]::IsNullOrWhiteSpace($content)) { exit 0 }

$parts = $content.Trim() -split '\|', 3
if ($parts.Count -lt 3) { exit 0 }

$taskId    = $parts[0].Trim()
$timestamp = $parts[1].Trim()
$prompt    = $parts[2].Trim()

# Clear queue (write empty)
Write-Utf8NoBom -Path $taskQueueFile -Content ""

Write-Host ">>> Telegram: $prompt" -ForegroundColor Cyan
Write-Host ""
$script:lastTaskId = $taskId

exit 0
