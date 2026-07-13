@echo off
REM ============================================================
REM  Common helpers for all projects
REM  Source this from build.bat / fix_build.bat
REM
REM  Usage:
REM      call "%~dp0lib\common.bat"
REM ============================================================

if "%PROJECT_ENV_LOADED%"=="1" goto :EOF

set "SCRIPT_DIR=%~dp0"
REM Normalize PROJECT_ROOT by resolving ..\ segments via pushd/popd
pushd "%SCRIPT_DIR%..\.." >nul 2>&1
set "PROJECT_ROOT=%CD%"
popd >nul 2>&1

REM The .bat extension is REQUIRED on the env file. Without it,
REM cmd treats it as data, not a script, and the set statements
REM never run. See project.env.bat.example for the format.
set "ENV_FILE=%PROJECT_ROOT%\.scripts\project.env.bat"

if not exist "%ENV_FILE%" (
    echo [ERROR] project.env.bat not found at %ENV_FILE%
    echo         Run new_project.bat first to bootstrap a new project.
    exit /b 99
)

call "%ENV_FILE%"

if "%IAR_BIN%"=="" goto :ENV_MISSING
if "%IAR_PROJECT_FILE%"=="" goto :ENV_MISSING
if "%IAR_CONFIG%"=="" goto :ENV_MISSING

if not "%LOG_DIR%"=="" goto :ENV_LOGDIR_OK
set "LOG_DIR=build_logs"
:ENV_LOGDIR_OK

if "%PROJECT_NAME%"=="" set "PROJECT_NAME=%IAR_PROJECT_FILE%"

if "%MCU_FAMILY%"=="" set "MCU_FAMILY=UNSPECIFIED"
if "%BOARD_NAME%"=="" set "BOARD_NAME=UNSPECIFIED"

set "PROJECT_ENV_LOADED=1"
goto :EOF

:ENV_MISSING
echo [ERROR] project.env.bat is missing required variables.
echo         Required: IAR_BIN, IAR_PROJECT_FILE, IAR_CONFIG
echo         See project.env.bat.example for full list.
exit /b 99


