# ============================================================
#  File watcher: auto-build on .c/.h save
#
#  When any .c or .h file in app/, board/, platform/,
#  middleware/ is modified, run .scripts\build.bat.
#  If build fails, ask user whether to invoke codex to fix.
#
#  Run in a separate PowerShell window, keep it open.
#  Ctrl+C to stop.
# ============================================================

$projectRoot = Split-Path -Parent $PSScriptRoot
$buildScript = Join-Path $projectRoot ".scripts\build.bat"
$fixScript   = Join-Path $projectRoot ".scripts\fix_build.bat"

# Watched paths (relative to project root)
$watchedDirs = @("app", "board", "platform", "middleware", "rtos")

# Debounce: skip rebuilds within 3 seconds of the last one
$debounceSeconds = 3
$lastBuild = Get-Date 0

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Auto-build watcher started" -ForegroundColor Cyan
Write-Host "  Project: $projectRoot" -ForegroundColor Cyan
Write-Host "  Watch : $($watchedDirs -join ', ')" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Use FileSystemWatcher for each directory
$watchers = @()
foreach ($dir in $watchedDirs) {
    $fullPath = Join-Path $projectRoot $dir
    if (-not (Test-Path $fullPath)) { continue }

    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $fullPath
    $watcher.IncludeSubdirectories = $true
    $watcher.Filter = "*.*"
    $watcher.EnableRaisingEvents = $true

    $action = {
        $path = $Event.SourceEventArgs.FullPath
        $ext  = [System.IO.Path]::GetExtension($path).ToLower()
        if ($ext -notin @(".c", ".h", ".cpp", ".hpp", ".s", ".S")) { return }

        # Debounce
        $script:lastBuild = $script:lastBuild
        $now = Get-Date
        $elapsed = ($now - $script:lastBuild).TotalSeconds
        if ($elapsed -lt $script:debounceSeconds) { return }
        $script:lastBuild = $now

        Write-Host ""
        Write-Host "[$now] Detected change: $path" -ForegroundColor Yellow

        # Build
        Write-Host "Building..." -ForegroundColor Cyan
        & cmd /c "`"$buildScript`" build" | Out-Null
        $rc = $LASTEXITCODE

        if ($rc -eq 0) {
            Write-Host "[OK] Build succeeded" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] Build failed (exit $rc)" -ForegroundColor Red

            # Ask user whether to invoke codex
            $answer = Read-Host "Invoke codex to fix? (y/N)"
            if ($answer -eq "y" -or $answer -eq "Y") {
                Write-Host "Invoking codex fix loop..." -ForegroundColor Magenta
                & cmd /c "`"$fixScript`" 5"
            }
        }
    }

    Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action | Out-Null
    $watchers += $watcher
}

Write-Host ""
Write-Host "Watching for file changes... (Ctrl+C to exit)" -ForegroundColor Green
Write-Host ""

# Keep the script running
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
finally {
    foreach ($w in $watchers) {
        $w.EnableRaisingEvents = $false
        $w.Dispose()
    }
}
