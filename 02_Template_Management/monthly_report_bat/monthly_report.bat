@echo off
chcp 65001 > nul
REM ============================================================
REM  monthly_report.bat -- generate a monthly report from daily entries
REM
REM  Usage (from project root):
REM      .scripts\monthly_report                          REM this month
REM      .scripts\monthly_report 2026-07                  explicit month (YYYY-MM)
REM      .scripts\monthly_report --from 2026-07-01 --to 2026-07-31   explicit range
REM      .scripts\monthly_report --no-codex               skip Codex, manual template only
REM ============================================================

setlocal

REM IMPORTANT: cache %~dp0 BEFORE any shift/goto operations
set "_MR_SCRIPT_DIR=%~dp0"

call "%_MR_SCRIPT_DIR%lib\common.bat"
if errorlevel 1 exit /b 99

set _MR_ARGS=
:MR_PARSE
if "%~1"=="" goto :MR_DONE
if /i "%~1"=="--no-codex" (
    set _MR_ARGS=%_MR_ARGS% -NoCodex
    shift
    goto :MR_PARSE
)
if /i "%~1"=="--from" (
    set _MR_ARGS=%_MR_ARGS% -From "%~2"
    shift
    shift
    goto :MR_PARSE
)
if /i "%~1"=="--to" (
    set _MR_ARGS=%_MR_ARGS% -To "%~2"
    shift
    shift
    goto :MR_PARSE
)
REM YYYY-MM month argument
echo %~1 | findstr /R "^[0-9][0-9][0-9][0-9]-[0-9][0-9]$" >nul
if not errorlevel 1 (
    set _MR_ARGS=%_MR_ARGS% -Month "%~1"
    shift
    goto :MR_PARSE
)
set _MR_ARGS=%_MR_ARGS% %1
shift
goto :MR_PARSE
:MR_DONE

powershell -NoProfile -ExecutionPolicy Bypass -File "%_MR_SCRIPT_DIR%monthly_report.ps1" -ProjectRoot "%PROJECT_ROOT%" -ProjectName "%PROJECT_NAME%" -McuFamily "%MCU_FAMILY%" %_MR_ARGS%
endlocal
exit /b %ERRORLEVEL%