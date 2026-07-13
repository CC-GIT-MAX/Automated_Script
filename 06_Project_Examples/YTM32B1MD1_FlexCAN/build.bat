@echo off
chcp 65001 > nul
REM ============================================================
REM  IAR build wrapper (portable across projects)
REM
REM  Reads configuration from .scripts\project.env
REM  Usage: build.bat [build^|clean^|rebuild^|make]
REM ============================================================

setlocal

call "%~dp0lib\common.bat"
if errorlevel 1 exit /b 99

set "MODE=%~1"
if "%MODE%"=="" set "MODE=build"

REM Resolve absolute project path for iarbuild
set "IAR_PROJECT_PATH=%PROJECT_ROOT%\%IAR_PROJECT_SUBPATH%\%IAR_PROJECT_FILE%"

if not exist "%IAR_PROJECT_PATH%" (
    echo [ERROR] IAR project file not found: %IAR_PROJECT_PATH%
    echo         Check IAR_PROJECT_FILE and IAR_PROJECT_SUBPATH in project.env
    exit /b 3
)

if not exist "%PROJECT_ROOT%\%LOG_DIR%" mkdir "%PROJECT_ROOT%\%LOG_DIR%"

REM ASCII-safe timestamp via PowerShell
for /f "delims=" %%T in ('powershell -NoProfile -Command "(Get-Date).ToString(\"yyyyMMdd_HHmmss\")"') do set "TS=%%T"
set "LOG_FILE=%PROJECT_ROOT%\%LOG_DIR%\%MODE%_%TS%.log"

echo ============================================================
echo  IAR Build Script
echo  Project : %PROJECT_NAME% (%MCU_FAMILY% / %BOARD_NAME%)
echo  File    : %IAR_PROJECT_PATH%
echo  Config  : %IAR_CONFIG%
echo  Mode    : %MODE%
echo  Log     : %LOG_FILE%
echo ============================================================

"%IAR_BIN%" "%IAR_PROJECT_PATH%" -%MODE% %IAR_CONFIG% > "%LOG_FILE%" 2>&1
set "RC=%ERRORLEVEL%"

if %RC% EQU 0 (
    echo [OK]  Build succeeded.
) else (
    echo [FAIL] Build failed with code %RC%.
    echo        See log: %LOG_FILE%
)

endlocal
exit /b %RC%
