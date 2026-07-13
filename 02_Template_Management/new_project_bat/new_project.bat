@echo off
chcp 65001 > nul
REM ============================================================
REM  Bootstrap a new IAR project for Codex automation
REM
REM  Usage (run from the project root):
REM      <path-to-template>\new_project.bat
REM
REM  This script will:
REM    1. Create .scripts\ directory
REM    2. Copy build.bat, fix_build.bat, lib\ from template
REM    3. Create project.env.bat from project.env.bat.example
REM    4. Create .gitignore entries for project.env.bat and build_logs
REM    5. Print next steps
REM ============================================================

setlocal

set "TEMPLATE_DIR=%~dp0"
if "%TEMPLATE_DIR:~-1%"=="\" set "TEMPLATE_DIR=%TEMPLATE_DIR:~0,-1%"

set "PROJECT_ROOT=%CD%"
set "SCRIPTS_DIR=%PROJECT_ROOT%\.scripts"

echo ============================================================
echo  Bootstrap Codex automation into:
echo  %PROJECT_ROOT%
echo ============================================================

if not exist "%SCRIPTS_DIR%" goto :CREATE_SCRIPTS_DIR
echo [WARN] .scripts\ already exists. Files will be overwritten.
choice /C YN /M "Continue"
if errorlevel 2 goto :ABORT
:CREATE_SCRIPTS_DIR
if not exist "%SCRIPTS_DIR%" mkdir "%SCRIPTS_DIR%"

REM Copy scripts
echo Copying scripts...
copy /Y "%TEMPLATE_DIR%\build.bat"     "%SCRIPTS_DIR%\build.bat"     > nul
copy /Y "%TEMPLATE_DIR%\fix_build.bat" "%SCRIPTS_DIR%\fix_build.bat" > nul
xcopy /Y /E /I "%TEMPLATE_DIR%\lib"     "%SCRIPTS_DIR%\lib"           > nul

REM Create project.env.bat from example
if not exist "%SCRIPTS_DIR%\project.env.bat" (
    copy /Y "%TEMPLATE_DIR%\project.env.bat.example" "%SCRIPTS_DIR%\project.env.bat" > nul
    echo [OK] Created .scripts\project.env.bat
) else (
    echo [WARN] .scripts\project.env.bat already exists, not overwriting.
)

REM Update .gitignore
set "GITIGNORE=%PROJECT_ROOT%\.gitignore"
if exist "%GITIGNORE%" (
    findstr /C:"\.scripts\project\.env" "%GITIGNORE%" > nul 2>&1
    if errorlevel 1 (
        echo.>> "%GITIGNORE%"
        echo # Codex automation generated files>> "%GITIGNORE%"
        echo .scripts\project.env.bat>> "%GITIGNORE%"
        echo build_logs\>> "%GITIGNORE%"
        echo [OK] Appended entries to .gitignore
    ) else (
        echo [OK] .gitignore already has Codex entries
    )
) else (
    echo # Codex automation generated files> "%GITIGNORE%"
    echo .scripts\project.env.bat>> "%GITIGNORE%"
    echo build_logs\>> "%GITIGNORE%"
    echo [OK] Created .gitignore
)

echo.
echo ============================================================
echo  Done!
echo ============================================================
echo.
echo Next steps:
echo   1. Edit .scripts\project.env.bat with your actual paths:
echo        - IAR_BIN
echo        - IAR_PROJECT_FILE
echo        - IAR_CONFIG
echo.
echo   2. Test it works:
echo        .scripts\build.bat build
echo.
echo   3. If you have compile errors, try the auto-fix loop:
echo        .scripts\fix_build.bat 5
echo.
echo   4. Copy AGENTS.md from the template to your project root
echo      (or use the one from this template).
echo.
echo Optional:
echo   - Add Codex config: .codex\config.toml
echo   - See template README for more automation scripts.
echo.

goto :EOF

:ABORT
echo Aborted.
exit /b 1
