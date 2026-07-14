# monthly_report.ps1 - companion to monthly_report.bat
param(
    [Parameter(Mandatory=$true)][string]$ProjectRoot,
    [string]$ProjectName = "Unknown",
    [string]$McuFamily = "Unknown",
    [string]$Month,
    [string]$From,
    [string]$To,
    [switch]$NoCodex
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$reportsDir = Join-Path $ProjectRoot ".scripts\reports"
$dailyDir = Join-Path $reportsDir "daily"
$weeklyDir = Join-Path $reportsDir "weekly"
$monthlyDir = Join-Path $reportsDir "monthly"

if (-not (Test-Path $dailyDir)) {
    Write-Host "[WARN] No daily reports directory: $dailyDir"
}
if (-not (Test-Path $weeklyDir)) {
    Write-Host "[WARN] No weekly reports directory: $weeklyDir"
}
if (-not (Test-Path $monthlyDir)) {
    New-Item -ItemType Directory -Path $monthlyDir -Force | Out-Null
}

# Determine range from Month or From/To
if (-not $Month -and -not $From) {
    $Month = Get-Date -Format "yyyy-MM"
}

if ($Month -and -not $From) {
    try {
        $firstOfMonth = [DateTime]::ParseExact("$Month-01", "yyyy-MM-dd", $null)
        $From = $firstOfMonth.ToString("yyyy-MM-dd")
        $To = $firstOfMonth.AddMonths(1).AddDays(-1).ToString("yyyy-MM-dd")
    } catch {
        Write-Host "[ERROR] Invalid month: $Month (expected YYYY-MM)"
        exit 3
    }
}

if (-not $To) { $To = $From }
if (-not $Month) {
    $Month = ($From -split "-")[0] + "-" + ($From -split "-")[1]
}

if ($From -notmatch "^\d{4}-\d{2}-\d{2}$") {
    Write-Host "[ERROR] Invalid FROM date: $From (expected YYYY-MM-DD)"
    exit 3
}
if ($To -notmatch "^\d{4}-\d{2}-\d{2}$") {
    Write-Host "[ERROR] Invalid TO date: $To (expected YYYY-MM-DD)"
    exit 3
}

Write-Host "============================================================"
Write-Host " Monthly Report Generator"
Write-Host " Project : $ProjectName ($McuFamily)"
Write-Host " Period  : $From to $To"
Write-Host "============================================================"

# Gather daily files in range
$dailyFiles = @()
if (Test-Path $dailyDir) {
    $dailyFiles = Get-ChildItem -Path $dailyDir -Filter "*.md" -File |
        Where-Object { $_.Name -ge "$From.md" -and $_.Name -le "$To.md" } |
        Sort-Object Name
}

# Gather weekly files in range
$weeklyFiles = @()
if (Test-Path $weeklyDir) {
    $weeklyFiles = Get-ChildItem -Path $weeklyDir -Filter "weekly_*.md" -File |
        Where-Object {
            # Extract FROM date from filename "weekly_YYYY-MM-DD_to_YYYY-MM-DD.md"
            if ($_.Name -match "weekly_(\d{4}-\d{2}-\d{2})_to_") {
                $matches[1] -ge $From -and $matches[1] -le $To
            } else { $false }
        } |
        Sort-Object Name
}

Write-Host ""
Write-Host "Found $($dailyFiles.Count) daily report(s) and $($weeklyFiles.Count) weekly report(s)."

$outputFile = Join-Path $monthlyDir "monthly_$Month.md"

$report = New-Object System.Collections.Generic.List[string]
[void]$report.Add("# Monthly Report -- $Month")
[void]$report.Add("")
[void]$report.Add("**Project**: $ProjectName ($McuFamily)")
[void]$report.Add("**Period**:   $From to $To")
[void]$report.Add("**Author**:   $env:USERNAME")
[void]$report.Add("**Generated**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$report.Add("**Sources**: $($dailyFiles.Count) daily report(s), $($weeklyFiles.Count) weekly report(s)")
[void]$report.Add("")

function Add-ManualTemplate {
    param($report)
    [void]$report.Add("## Executive Summary")
    [void]$report.Add("")
    [void]$report.Add("(Synthesize from daily and weekly reports below.)")
    [void]$report.Add("")
    [void]$report.Add("## Major Accomplishments")
    [void]$report.Add("")
    [void]$report.Add("(Synthesize from entries.)")
    [void]$report.Add("")
    [void]$report.Add("## In-Progress Initiatives")
    [void]$report.Add("")
    [void]$report.Add("(Synthesize from entries.)")
    [void]$report.Add("")
    [void]$report.Add("## Blockers and Risks")
    [void]$report.Add("")
    [void]$report.Add("(Synthesize from entries.)")
    [void]$report.Add("")
    [void]$report.Add("## Statistics")
    [void]$report.Add("")
    [void]$report.Add("- Total daily reports: $($dailyFiles.Count)")
    [void]$report.Add("- Total weekly reports: $($weeklyFiles.Count)")
    [void]$report.Add("- Period: $From to $To")
    [void]$report.Add("")
    [void]$report.Add("## Trends and Observations")
    [void]$report.Add("")
    [void]$report.Add("(Manual entry.)")
    [void]$report.Add("")
    [void]$report.Add("## Plan for Next Month")
    [void]$report.Add("")
    [void]$report.Add("(Manual entry.)")
}

if (-not $NoCodex -and (Get-Command codex -ErrorAction SilentlyContinue)) {
    Write-Host "Invoking Codex to synthesize monthly report..."
    $tmpInput = Join-Path $env:TEMP "monthly_input_$([guid]::NewGuid().Guid).txt"
    $inputLines = @()
    $inputLines += "Synthesize a MONTHLY work report from the daily and weekly entries below."
    $inputLines += "Project: $ProjectName ($McuFamily)"
    $inputLines += "Period: $From to $To (month $Month)"
    $inputLines += ""
    $inputLines += "Required sections:"
    $inputLines += "## Executive Summary"
    $inputLines += "## Major Accomplishments"
    $inputLines += "## In-Progress Initiatives"
    $inputLines += "## Blockers and Risks"
    $inputLines += "## Statistics"
    $inputLines += "## Trends and Observations"
    $inputLines += "## Plan for Next Month"
    $inputLines += ""
    $inputLines += "Tone: management-friendly, concise, evidence-based."
    $inputLines += ""
    $inputLines += "---DAILY ENTRIES---"
    foreach ($f in $dailyFiles) {
        $inputLines += ""
        $inputLines += "===== $($f.Name) ====="
        $inputLines += (Get-Content $f.FullName -Raw)
    }
    if ($weeklyFiles.Count -gt 0) {
        $inputLines += ""
        $inputLines += "---WEEKLY ENTRIES---"
        foreach ($f in $weeklyFiles) {
            $inputLines += ""
            $inputLines += "===== $($f.Name) ====="
            $inputLines += (Get-Content $f.FullName -Raw)
        }
    }
    Set-Content -Path $tmpInput -Value $inputLines -Encoding ASCII

    $codexArgs = @(
        "exec", "--skip-git-repo-check",
        "-C", $ProjectRoot, "-s", "workspace-write",
        "-c", 'model="gpt-5.1"',
        "Read the file at $tmpInput and synthesize a monthly report in Markdown. Write ONLY the synthesized report to stdout -- no commentary, no preamble, no explanation."
    )
    $output = & codex @codexArgs 2>$null
    if ($LASTEXITCODE -eq 0 -and $output) {
        foreach ($line in $output) {
            [void]$report.Add($line)
        }
    } else {
        Write-Host "[WARN] Codex did not produce a usable summary. Using manual template."
        Add-ManualTemplate $report
    }
    Remove-Item $tmpInput -ErrorAction SilentlyContinue
} else {
    if (-not $NoCodex) {
        Write-Host "[WARN] codex CLI not found. Using manual template."
    }
    Add-ManualTemplate $report
}

[void]$report.Add("")
[void]$report.Add("---")
[void]$report.Add("")
[void]$report.Add("## Source: Daily Reports")
[void]$report.Add("")
foreach ($f in $dailyFiles) {
    $name = $f.Name.Substring(0, 10)
    [void]$report.Add("")
    [void]$report.Add("### $name")
    [void]$report.Add("")
    $content = (Get-Content $f.FullName -Raw).TrimEnd()
    foreach ($line in ($content -split "`n")) {
        [void]$report.Add($line)
    }
    [void]$report.Add("")
}

if ($weeklyFiles.Count -gt 0) {
    [void]$report.Add("")
    [void]$report.Add("## Source: Weekly Reports")
    [void]$report.Add("")
    foreach ($f in $weeklyFiles) {
        [void]$report.Add("")
        [void]$report.Add("### $($f.Name)")
        [void]$report.Add("")
        $content = (Get-Content $f.FullName -Raw).TrimEnd()
        foreach ($line in ($content -split "`n")) {
            [void]$report.Add($line)
        }
        [void]$report.Add("")
    }
}

Set-Content -Path $outputFile -Value ($report -join "`n") -Encoding UTF8
Write-Host ""
Write-Host "[OK] Generated $outputFile"
Write-Host "Open it with: notepad `"$outputFile`""