# weekly_report.ps1 - companion to weekly_report.bat
param(
    [Parameter(Mandatory=$true)][string]$ProjectRoot,
    [string]$ProjectName = "Unknown",
    [string]$McuFamily = "Unknown",
    [string]$From,
    [string]$To,
    [switch]$NoCodex
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$reportsDir = Join-Path $ProjectRoot ".scripts\reports"
$dailyDir = Join-Path $reportsDir "daily"
$weeklyDir = Join-Path $reportsDir "weekly"

if (-not (Test-Path $dailyDir)) {
    Write-Host "[WARN] No daily reports directory: $dailyDir"
    Write-Host "[WARN] Run .scripts\daily_report first."
}

if (-not (Test-Path $weeklyDir)) {
    New-Item -ItemType Directory -Path $weeklyDir -Force | Out-Null
}

if (-not $From -and -not $To) {
    $today = Get-Date
    $daysFromMonday = [int]$today.DayOfWeek - 1
    if ($daysFromMonday -lt 0) { $daysFromMonday = 6 }
    $monday = $today.AddDays(-$daysFromMonday)
    if ($monday -gt $today) { $monday = $monday.AddDays(-7) }
    $sunday = $monday.AddDays(6)
    $From = $monday.ToString("yyyy-MM-dd")
    $To = $sunday.ToString("yyyy-MM-dd")
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
Write-Host " Weekly Report Generator"
Write-Host " Project : $ProjectName ($McuFamily)"
Write-Host " Range   : $From to $To"
Write-Host "============================================================"

$dailyFiles = @()
if (Test-Path $dailyDir) {
    $dailyFiles = Get-ChildItem -Path $dailyDir -Filter "*.md" -File |
        Where-Object { $_.Name -ge "$From.md" -and $_.Name -le "$To.md" } |
        Sort-Object Name
}

Write-Host ""
Write-Host "Found $($dailyFiles.Count) daily report(s) in range."

$weekTag = "${From}_to_${To}"
$outputFile = Join-Path $weeklyDir "weekly_${weekTag}.md"

$report = New-Object System.Collections.Generic.List[string]
[void]$report.Add("# Weekly Report -- $From to $To")
[void]$report.Add("")
[void]$report.Add("**Project**: $ProjectName ($McuFamily)")
[void]$report.Add("**Range**:    $From to $To")
[void]$report.Add("**Author**:   $env:USERNAME")
[void]$report.Add("**Generated**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$report.Add("**Source**:   $($dailyFiles.Count) daily report(s)")
[void]$report.Add("")

function Add-ManualTemplate {
    param($report)
    [void]$report.Add("## Done This Week")
    [void]$report.Add("")
    [void]$report.Add("(Synthesize from daily reports below.)")
    [void]$report.Add("")
    [void]$report.Add("## In Progress")
    [void]$report.Add("")
    [void]$report.Add("(Synthesize from daily reports below.)")
    [void]$report.Add("")
    [void]$report.Add("## Blockers / Risks")
    [void]$report.Add("")
    [void]$report.Add("(Synthesize from daily reports below.)")
    [void]$report.Add("")
    [void]$report.Add("## Plan for Next Week")
    [void]$report.Add("")
    [void]$report.Add("(Synthesize from daily reports below.)")
    [void]$report.Add("")
    [void]$report.Add("## Statistics")
    [void]$report.Add("")
    [void]$report.Add("- Total daily reports: $($dailyFiles.Count)")
    [void]$report.Add("- Date range: $From to $To")
}

if (-not $NoCodex -and (Get-Command codex -ErrorAction SilentlyContinue)) {
    Write-Host "Invoking Codex to synthesize weekly report..."
    $tmpInput = Join-Path $env:TEMP "weekly_input_$([guid]::NewGuid().Guid).txt"
    $inputLines = @()
    $inputLines += "Synthesize a weekly work report from the following daily entries."
    $inputLines += "Project: $ProjectName ($McuFamily)"
    $inputLines += "Period: $From to $To"
    $inputLines += ""
    $inputLines += "Required sections:"
    $inputLines += "## Done This Week"
    $inputLines += "## In Progress"
    $inputLines += "## Blockers / Risks"
    $inputLines += "## Plan for Next Week"
    $inputLines += "## Statistics"
    $inputLines += ""
    $inputLines += "---DAILY ENTRIES---"
    foreach ($f in $dailyFiles) {
        $inputLines += ""
        $inputLines += "===== $($f.Name) ====="
        $inputLines += (Get-Content $f.FullName -Raw)
    }
    Set-Content -Path $tmpInput -Value $inputLines -Encoding ASCII

    $codexArgs = @(
        "exec", "--skip-git-repo-check",
        "-C", $ProjectRoot, "-s", "workspace-write",
        "-c", 'model="gpt-5.1"',
        "Read the file at $tmpInput and synthesize a weekly report in Markdown. Write ONLY the synthesized report to stdout -- no commentary, no preamble, no explanation."
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

Set-Content -Path $outputFile -Value ($report -join "`n") -Encoding UTF8
Write-Host ""
Write-Host "[OK] Generated $outputFile"
Write-Host "Open it with: notepad `"$outputFile`""