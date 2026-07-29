# ygg retrieve --semantic -- Semantic retrieval via local embeddings
<#
.SYNOPSIS
  Semantic search across embedded seed knowledge using Ollama embeddings.
.DESCRIPTION
  Takes a query string, gets its embedding via Ollama (nomic-embed-text),
  computes cosine similarity against every chunk in work/embed-index.json,
  and returns the top 5 results ranked by similarity.
  Usage: ygg retrieve --semantic "<query>"
  Invoked via: ygg-retrieve.ps1 when --semantic flag is detected.
.EXAMPLE
  ygg retrieve --semantic "find the decision about session-state"
#>

param(
    [Parameter(Position = 0)]
    [string]$Query = ""
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$repoRoot = (Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "..\..")).Path

if (-not $Query) {
    Write-Host "ygg retrieve --semantic -- Semantic search" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: ygg retrieve --semantic `"<query>`"" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  ygg retrieve --semantic `"find the decision about session-state`"" -ForegroundColor Gray
    Write-Host "  ygg retrieve --semantic `"what is the lethal trifecta?`"" -ForegroundColor Gray
    exit 1
}

# --- Pre-flight checks ---

# Check Ollama is running
try {
    $null = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5
} catch {
    Write-Host "ERROR: Ollama is not running or not reachable at http://localhost:11434" -ForegroundColor Red
    Write-Host ""
    Write-Host "Start Ollama first:" -ForegroundColor Yellow
    Write-Host "  ollama serve" -ForegroundColor Gray
    exit 1
}

# Check index exists
$indexPath = Join-Path -Path $repoRoot -ChildPath "work\embed-index.json"
if (-not (Test-Path -LiteralPath $indexPath)) {
    Write-Host "ERROR: Embedding index not found at work\embed-index.json" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run the embedding pipeline first:" -ForegroundColor Yellow
    Write-Host "  ygg embed" -ForegroundColor Gray
    exit 1
}

# --- Get query embedding ---

Write-Host "Embedding query..." -ForegroundColor Gray

$queryBody = @{ model = "nomic-embed-text"; prompt = $Query } | ConvertTo-Json
try {
    $queryResponse = Invoke-RestMethod -Uri "http://localhost:11434/api/embeddings" -Method Post -Body $queryBody -ContentType "application/json" -TimeoutSec 60
    $queryVector = $queryResponse.embedding
} catch {
    Write-Host "ERROR: Failed to get query embedding from Ollama: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ensure nomic-embed-text is installed:" -ForegroundColor Yellow
    Write-Host "  ollama pull nomic-embed-text" -ForegroundColor Gray
    exit 1
}

if ($null -eq $queryVector -or $queryVector.Count -eq 0) {
    Write-Host "ERROR: Empty embedding returned for query." -ForegroundColor Red
    exit 1
}

# --- Load index ---

$indexText = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
$index = $indexText | ConvertFrom-Json

if ($null -eq $index.chunks -or $index.chunks.Count -eq 0) {
    Write-Host "ERROR: Embedding index is empty. Run 'ygg embed' first." -ForegroundColor Red
    exit 1
}

# --- Cosine similarity ---

function Get-CosineSimilarity {
    param(
        [double[]]$A,
        [double[]]$B
    )

    if ($A.Count -ne $B.Count) { return 0.0 }

    $dotProduct = 0.0
    $normA = 0.0
    $normB = 0.0

    for ($i = 0; $i -lt $A.Count; $i++) {
        $dotProduct += $A[$i] * $B[$i]
        $normA += $A[$i] * $A[$i]
        $normB += $B[$i] * $B[$i]
    }

    $denominator = [Math]::Sqrt($normA) * [Math]::Sqrt($normB)
    if ($denominator -eq 0) { return 0.0 }

    return $dotProduct / $denominator
}

# --- Compute similarities ---

$results = @()

foreach ($chunk in $index.chunks) {
    # Convert the stored vector to a double array
    $chunkVector = [double[]]$chunk.vector
    $similarity = Get-CosineSimilarity -A $queryVector -B $chunkVector

    $results += @{
        file       = $chunk.file
        offset     = $chunk.offset
        similarity = $similarity
        text       = $chunk.text
    }
}

# Sort by similarity descending, take top 5
$sorted = $results | Sort-Object { $_.similarity } -Descending | Select-Object -First 5

# --- Display results ---

Write-Host ""
Write-Host "Semantic search: `"$Query`"" -ForegroundColor Cyan
Write-Host "Model: $($index.model) | Chunks searched: $($index.chunks.Count)" -ForegroundColor Gray
Write-Host ""

$rank = 0
foreach ($r in $sorted) {
    $rank++
    $score = [Math]::Round($r.similarity, 4)
    $excerpt = $r.text
    if ($excerpt.Length -gt 120) {
        $excerpt = $excerpt.Substring(0, 120) + "..."
    }
    # Clean up the excerpt for display
    $excerpt = $excerpt -replace "`r`n", " "
    $excerpt = $excerpt -replace "`n", " "

    Write-Host "  $rank. " -ForegroundColor White -NoNewline
    Write-Host "$($r.file)" -ForegroundColor Cyan -NoNewline
    Write-Host " (score: $score)" -ForegroundColor Yellow
    Write-Host "     $excerpt" -ForegroundColor Gray
    Write-Host ""
}

exit 0
