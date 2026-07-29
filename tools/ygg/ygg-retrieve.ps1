# ygg retrieve -- Knowledge-index lookup
<#
.SYNOPSIS
  Look up file paths by topic in the knowledge index.
.DESCRIPTION
  Greps seed/memory/knowledge-index.md for the given topic and returns matching
  file paths with one-line descriptions. Grep-based; no embeddings or indexing.
  Usage: ygg retrieve --topic <topic>
  Usage: ygg retrieve <topic>
.EXAMPLE
  ygg retrieve --topic security
  ygg retrieve architecture
  ygg retrieve "session-state"
#>

param(
    [Parameter(Position = 0)]
    [Alias("t")]
    [string]$Topic = "",

    [switch]$semantic
)

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# If --semantic flag is present, delegate to semantic retrieval
if ($semantic) {
    $semanticScript = Join-Path -Path $scriptDir -ChildPath "ygg-retrieve-semantic.ps1"
    if ($Topic) {
        & $semanticScript $Topic
    } else {
        & $semanticScript
    }
    exit $LASTEXITCODE
}

$indexPath = Join-Path -Path $scriptDir -ChildPath "..\..\seed\memory\knowledge-index.md"
$indexPath = (Resolve-Path -Path $indexPath -ErrorAction SilentlyContinue).Path

if (-not $indexPath) {
    Write-Host "ERROR: knowledge-index.md not found at seed\memory\knowledge-index.md" -ForegroundColor Red
    exit 1
}

# Resolve topic from positional or named parameter
if (-not $Topic) {
    Write-Host "ygg retrieve -- Knowledge-index lookup" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: ygg retrieve --topic <topic>" -ForegroundColor White
    Write-Host ""
    Write-Host "Available topics (grep the index for full list):" -ForegroundColor White
    Select-String -Path $indexPath -Pattern '^### ' | ForEach-Object {
        $_.Line -replace '^### ', '- '
    } | Sort-Object | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
    exit 1
}

$topicLower = $Topic.ToLower()

# Read the index and find matching sections
$content = Get-Content -Path $indexPath -Raw
$sections = $content -split '(?=^### )' -split '(?=^## )'

$found = $false
$inSection = $false
$sectionName = ""

foreach ($chunk in $sections) {
    $chunk = $chunk.Trim()
    if (-not $chunk) { continue }

    # Check if this is a topic section header
    if ($chunk -match '^### (.+)$') {
        $sectionName = $matches[1]
        $sectionNameLower = $sectionName.ToLower()
        # Check for exact match on topic name
        if ($sectionNameLower -eq $topicLower) {
            $inSection = $true
            $found = $true
            Write-Host "## $sectionName" -ForegroundColor Cyan
        } else {
            $inSection = $false
        }
    } elseif ($chunk -match '^## (.+)$') {
        $inSection = $false
    } elseif ($inSection) {
        # Print lines from this section
        $lines = $chunk -split "`n"
        foreach ($line in $lines) {
            $line = $line.Trim()
            if ($line -match '^- (.+) \u2014 (.+)$') {
                $path = $matches[1]
                $desc = $matches[2]
                Write-Host "  $path" -ForegroundColor White -NoNewline
                Write-Host " -- $desc" -ForegroundColor Gray
            }
        }
    }
}

# Also search domain sections for broader topic matches
if (-not $found) {
    $inDomain = $false
    foreach ($chunk in $sections) {
        $chunk = $chunk.Trim()
        if (-not $chunk) { continue }
        if ($chunk -match '^## (.+)$') {
            $domainName = $matches[1]
            $domainNameLower = $domainName.ToLower()
            if ($domainNameLower -eq $topicLower) {
                $inDomain = $true
                $found = $true
                Write-Host "## $domainName" -ForegroundColor Cyan
            } else {
                $inDomain = $false
            }
        } elseif ($inDomain -and $chunk -match '^- (.+) \u2014 (.+)$') {
            $path = $matches[1]
            $desc = $matches[2]
            Write-Host "  $path" -ForegroundColor White -NoNewline
            Write-Host " -- $desc" -ForegroundColor Gray
        }
    }
}

if (-not $found) {
    # Fallback: grep for any line containing the topic
    $matches = Select-String -Path $indexPath -Pattern $topicLower -CaseSensitive:$false -SimpleMatch
    if ($matches) {
        Write-Host "No exact topic or domain match for '$Topic'." -ForegroundColor Yellow
        Write-Host "Lines referencing '$Topic':" -ForegroundColor Yellow
        $matches | ForEach-Object {
            $line = $_.Line.Trim()
            if ($line -match '^(- .+)$') {
                Write-Host "  $_" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "No matches found for topic: $Topic" -ForegroundColor Red
        Write-Host ""
        Write-Host "Run 'ygg retrieve' with no arguments to list available topics." -ForegroundColor Gray
        exit 1
    }
}

exit 0
