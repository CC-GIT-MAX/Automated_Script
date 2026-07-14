@echo off
chcp 65001 > nul
REM ============================================================
REM  weekly_report.bat -- generate a weekly report from daily entries
REM
REM  Usage (from project root):
REM      .scripts\weekly_report                              REM this week (Mon-Sun)
REM      .scripts\weekly_report --from 2026-07-06 --to 2026-07-12   explicit range
REM      .scripts\weekly_report --no-codex                   skip Codex, manual template only
REM ============================================================

setlocal

REM IMPORTANT: cache %~dp0 BEFORE any shift/goto operations
set "_WR_SCRIPT_DIR=%~dp0"

call "%_WR_SCRIPT_DIR%lib\common.bat"
if errorlevel 1 exit /b 99

set _WR_ARGS=
:WR_PARSE
if "%~1"=="" goto :WR_DONE
if /i "%~1"=="--no-codex" (
    set _WR_ARGS=%_WR_ARGS% -NoCodex
    shift
    goto :WR_PARSE
)
if /i "%~1"=="--from" (
    set _WR_ARGS=%_WR_ARGS% -From "%~2"
    shift
    shift
    goto :WR_PARSE
)
if /i "%~1"=="--to" (
    set _WR_ARGS=%_WR_ARGS% -To "%~2"
    shift
    shift
    goto :WR_PARSE
)
set _WR_ARGS=%_WR_ARGS% %1
shift
goto :WR_PARSE
:WR_DONE

powershell -NoProfile -ExecutionPolicy Bypass -File "%_WR_SCRIPT_DIR%weekly_report.ps1" -ProjectRoot "%PROJECT_ROOT%" -ProjectName "%PROJECT_NAME%" -McuFamily "%MCU_FAMILY%" %_WR_ARGS%
endlocal
exit /b %ERRORLEVEL%