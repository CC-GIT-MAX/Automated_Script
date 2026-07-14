@echo off
chcp 65001 > nul
REM ============================================================
REM  daily_report.bat -- generate / append a daily work report
REM
REM  Usage (from project root):
REM      .scripts\daily_report                       REM create today's report
REM      .scripts\daily_report 2026-07-13            REM create a report for a specific date
REM      .scripts\daily_report --regen               REM overwrite today's report from scratch
REM      .scripts\daily_report --append "fixed UART"  REM append a line to today's report
REM
REM  Behavior:
REM    1. Reads .scripts\project.env.bat for project identity
REM    2. Pre-fills date, project name, MCU family
REM    3. Creates .scripts\reports\daily\<DATE>.md as a template
REM    4. Opens the file in the default editor (or Notepad)
REM
REM  Exit codes:
REM    0 = success
REM    3 = reports dir not writable
REM    99 = common.bat loader failed
REM ============================================================

setlocal enabledelayedexpansion

call "%~dp0lib\common.bat"
if errorlevel 1 exit /b 99

REM ---- Parse args ---------------------------------------------
set "TARGET_DATE="
set "REGEN=0"
set "APPEND_TEXT="

:PARSE_ARGS
if "%~1"=="" goto :PARSE_DONE
if /i "%~1"=="--regen" set "REGEN=1"
if /i "%~1"=="--append" (
    set "APPEND_TEXT=%~2"
    shift
)
powershell -NoProfile -Command "if ('%~1' -match '^\d{4}-\d{2}-\d{2}$') { exit 0 } else { exit 1 }" >nul 2>&1
if not errorlevel 1 set "TARGET_DATE=%~1"
shift
goto :PARSE_ARGS
:PARSE_DONE

if "%TARGET_DATE%"=="" (
    for /f "delims=" %%D in (powershell -NoProfile -Command "(Get-Date).ToString('yyyy-MM-dd')") do set "TARGET_DATE=%%D"
)

set "REPORTS_DIR=%PROJECT_ROOT%\.scripts\reports\daily"
set "REPORT_FILE=%REPORTS_DIR%\%TARGET_DATE%.md"

if not exist "%REPORTS_DIR%" mkdir "%REPORTS_DIR%" 2>nul
if not exist "%REPORTS_DIR%" (
    echo [ERROR] Cannot create %REPORTS_DIR%
    exit /b 3
)

REM ---- Append mode --------------------------------------------
if not "%APPEND_TEXT%"=="" (
    >> "%REPORT_FILE%" echo - %APPEND_TEXT%
    echo [OK] Appended to %REPORT_FILE%
    type "%REPORT_FILE%"
    endlocal
    exit /b 0
)

REM ---- Skip if exists and not regen --------------------------
if "%REGEN%"=="1" goto :WRITE_FILE
if exist "%REPORT_FILE%" (
    echo [SKIP] %REPORT_FILE% already exists. Use --regen to overwrite.
    endlocal
    exit /b 0
)

REM ---- Write the template -------------------------------------
:WRITE_FILE
> "%REPORT_FILE%" (
    echo # Daily Report -- %TARGET_DATE%
    echo.
    echo **Project**: %PROJECT_NAME% ^(%MCU_FAMILY%^)
    echo **Author**:   %USERNAME%
    echo **Generated**: %DATE% %TIME%
    echo.
    echo ## Today's Commits
    echo.
    echo - ^(add manually or run: git log --since=today^)
    echo.
    echo ## Done
    echo.
    echo -
    echo.
    echo ## In Progress
    echo.
    echo -
    echo.
    echo ## Blocked / Risks
    echo.
    echo -
    echo.
    echo ## Tomorrow's Plan
    echo.
    echo -
    echo.
    echo ## Notes
    echo.
    echo -
)

echo [OK] Created %REPORT_FILE%
echo.
echo Edit it with your tasks, then run:
echo   .scripts\daily_report --append "completed item"

start " "%REPORT_FILE%" 2>nul

endlocal
exit /b 0
