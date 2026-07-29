# ygg embed -- Embedding pipeline for seed knowledge
<#
.SYNOPSIS
  Re-embed all seed and deliberation markdown files using nomic-embed-text via Ollama.
.DESCRIPTION
  Recursively finds all .md files under seed/ (excluding seed/memory/log/archive/)
  and deliberation/, chunks each file into passages of ~500 chars with ~50 char overlap,
  calls the Ollama API for embeddings, and stores the index in work/embed-index.json.
  Usage: ygg embed
  Usage: ygg embed --update
.EXAMPLE
  ygg embed
  ygg embed --update
#>

param(
    [switch]$Update
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$repoRoot = (Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "..\..")).Path

# --- Pre-flight checks ---

# Check Ollama is running
try {
    $null = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5
} catch {
    Write-Host "ERROR: Ollama is not running or not reachable at http://localhost:11434" -ForegroundColor Red
    Write-Host ""
    Write-Host "Start Ollama first:" -ForegroundColor Yellow
    Write-Host "  ollama serve" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or if Ollama is installed but not running, start the Ollama application." -ForegroundColor Yellow
    exit 1
}

# Check nomic-embed-text model is available
try {
    $tagsResponse = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 10
    $modelNames = @()
    if ($tagsResponse.models) {
        foreach ($m in $tagsResponse.models) {
            if ($m.name) {
                $modelNames += $m.name
            }
        }
    }
    $hasEmbedModel = $false
    foreach ($name in $modelNames) {
        if ($name -like "nomic-embed-text*") {
            $hasEmbedModel = $true
            break
        }
    }
    if (-not $hasEmbedModel) {
        Write-Host "ERROR: nomic-embed-text model is not installed in Ollama." -ForegroundColor Red
        Write-Host ""
        Write-Host "Pull it with:" -ForegroundColor Yellow
        Write-Host "  ollama pull nomic-embed-text" -ForegroundColor Gray
        exit 1
    }
} catch {
    Write-Host "ERROR: Could not query Ollama models: $_" -ForegroundColor Red
    exit 1
}

Write-Host "ygg embed -- Building embedding index" -ForegroundColor Cyan
Write-Host ""

# --- Collect markdown files ---

$seedDir = Join-Path -Path $repoRoot -ChildPath "seed"
$delibDir = Join-Path -Path $repoRoot -ChildPath "deliberation"
$archiveDir = Join-Path -Path $repoRoot -ChildPath "seed\memory\log\archive"

$mdFiles = @()

if (Test-Path -LiteralPath $seedDir) {
    $seedFiles = Get-ChildItem -LiteralPath $seedDir -Filter "*.md" -Recurse -File
    foreach ($f in $seedFiles) {
        # Exclude archive directory
        if ($archiveDir -and $f.FullName -like "$archiveDir*") {
            continue
        }
        $mdFiles += $f
    }
}

if (Test-Path -LiteralPath $delibDir) {
    $delibFiles = Get-ChildItem -LiteralPath $delibDir -Filter "*.md" -Recurse -File
    foreach ($f in $delibFiles) {
        $mdFiles += $f
    }
}

if ($mdFiles.Count -eq 0) {
    Write-Host "ERROR: No markdown files found under seed/ or deliberation/." -ForegroundColor Red
    exit 1
}

Write-Host "Found $($mdFiles.Count) markdown files." -ForegroundColor Gray

# --- Chunking function ---
function Get-Chunks {
    param(
        [string]$Text,
        [int]$ChunkSize = 500,
        [int]$Overlap = 50
    )

    if ($Text.Length -eq 0) { return @() }

    $chunkList = New-Object System.Collections.Generic.List[object]
    $start = 0
    while ($start -lt $Text.Length) {
        $end = [Math]::Min($start + $ChunkSize, $Text.Length)
        $chunkText = $Text.Substring($start, $end - $start)
        $chunkObj = New-Object PSObject -Property @{
            text   = $chunkText
            offset = $start
        }
        $chunkList.Add($chunkObj) | Out-Null
        $start = $start + $ChunkSize - $Overlap
        if ($start -ge $Text.Length) { break }
    }

    return ,$chunkList.ToArray()
}

# --- Embedding function ---
function Get-Embedding {
    param(
        [string]$Text
    )

    $body = @{ model = "nomic-embed-text"; prompt = $Text } | ConvertTo-Json
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:11434/api/embeddings" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 60
        return $response.embedding
    } catch {
        Write-Host "ERROR: Failed to get embedding from Ollama: $_" -ForegroundColor Red
        return $null
    }
}

# --- Build index ---

$allChunks = @()
$totalChunks = 0
$fileCount = 0

foreach ($file in $mdFiles) {
    $content = ""
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    } catch {
        Write-Host "  WARN: Could not read $($file.FullName): $_" -ForegroundColor Yellow
        continue
    }

    if ($content.Trim().Length -eq 0) { continue }

    $chunks = Get-Chunks -Text $content
    if ($chunks.Count -eq 0) { continue }

    $fileCount++
    # Compute relative path from repo root with forward slashes
    $relativePath = $file.FullName.Substring($repoRoot.Length)
    if ($relativePath.StartsWith("\") -or $relativePath.StartsWith("/")) {
        $relativePath = $relativePath.Substring(1)
    }
    $relativePath = $relativePath.Replace("\", "/")

    Write-Host "  Embedding $($chunks.Count) chunks from $relativePath" -ForegroundColor Gray

    foreach ($chunk in $chunks) {
        $vector = Get-Embedding -Text $chunk.text
        if ($null -eq $vector) {
            Write-Host "  WARN: Skipping chunk at offset $($chunk.offset) in $relativePath" -ForegroundColor Yellow
            continue
        }

        $allChunks += @{
            text   = $chunk.text
            file   = $relativePath
            offset = $chunk.offset
            vector = $vector
        }
        $totalChunks++
    }
}

# --- Write index ---

$workDir = Join-Path -Path $repoRoot -ChildPath "work"
if (-not (Test-Path -LiteralPath $workDir)) {
    New-Item -ItemType Directory -Path $workDir | Out-Null
}

$indexPath = Join-Path -Path $workDir -ChildPath "embed-index.json"

$index = @{
    version = 1
    model   = "nomic-embed-text"
    updated = (Get-Date -Format "yyyy-MM-dd")
    chunks  = $allChunks
}

$jsonText = $index | ConvertTo-Json -Depth 10

# Write UTF-8 without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($indexPath, $jsonText, $utf8NoBom)

Write-Host ""
Write-Host "Done. Indexed $totalChunks chunks from $fileCount files." -ForegroundColor Green
Write-Host "Index written to: work\embed-index.json" -ForegroundColor Green

exit 0
