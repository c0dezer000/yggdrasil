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
# Result files are per-task. A single shared task-result.md was raced by every waiting poll
# job in the daemon; see the matching note in ygg-daemon.ps1.
function Get-TaskResultFile { param([string]$Id) Join-Path -Path $workDir -ChildPath "task-result-$Id.md" }
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
    Write-Utf8NoBom -Path (Get-TaskResultFile -Id $TaskId) -Content $resultContent
    exit 0
}

# ---- Mode 1: Check queue ----
# Pops ONE task and leaves the rest. This previously read the whole file with -Raw, split it on
# the first two pipes, and then blanked the file -- so with more than one queued task it treated
# every line after the first as part of task one's prompt and destroyed them all.
if (-not (Test-Path -LiteralPath $taskQueueFile -PathType Leaf)) { exit 0 }
$lines = @(Get-Content -Path $taskQueueFile -Encoding UTF8 | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($lines.Count -eq 0) { exit 0 }

$parts = $lines[0].Trim() -split '\|', 3
if ($parts.Count -lt 3) {
    # Malformed head-of-queue entry: drop it rather than blocking the queue forever.
    $remainder = if ($lines.Count -gt 1) { ($lines[1..($lines.Count - 1)] -join "`r`n") + "`r`n" } else { "" }
    Write-Utf8NoBom -Path $taskQueueFile -Content $remainder
    Write-Host "Discarded malformed queue entry." -ForegroundColor DarkYellow
    exit 1
}

$taskId    = $parts[0].Trim()
$timestamp = $parts[1].Trim()
$prompt    = $parts[2].Trim()

# Rewrite the queue without the popped entry, preserving the remaining tasks.
$remainder = if ($lines.Count -gt 1) { ($lines[1..($lines.Count - 1)] -join "`r`n") + "`r`n" } else { "" }
Write-Utf8NoBom -Path $taskQueueFile -Content $remainder

# The task id is printed. It was previously assigned to $script:lastTaskId and then discarded
# when the script exited, leaving the operator no way to know which id to report back to.
Write-Host "TASK_ID: $taskId" -ForegroundColor DarkGray
Write-Host "QUEUED : $timestamp" -ForegroundColor DarkGray
Write-Host "PENDING: $($lines.Count - 1) more" -ForegroundColor DarkGray
Write-Host ">>> Telegram: $prompt" -ForegroundColor Cyan
Write-Host ""

exit 0
