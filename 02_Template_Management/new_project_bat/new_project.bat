@echo off
chcp 65001 > nul
REM ============================================================
REM  Bootstrap a new IAR project for Codex automation
REM
REM  Usage (run from the target project root):
REM      D:\path\to\Automated_Script_Summary\02_Template_Management\new_project_bat\new_project.bat
REM ============================================================

setlocal
set "BOOTSTRAP_DIR=%~dp0"
if "%BOOTSTRAP_DIR:~-1%"=="\" set "BOOTSTRAP_DIR=%BOOTSTRAP_DIR:~0,-1%"
set "REPO_ROOT=%BOOTSTRAP_DIR%\..\.."
set "PROJECT_ROOT=%CD%"
set "SCRIPTS_DIR=%PROJECT_ROOT%\.scripts"
set "EXIT_CODE=0"

set "BUILD_SRC=%REPO_ROOT%\01_Build_Automation\build_bat\build.bat"
set "FIX_SRC=%REPO_ROOT%\01_Build_Automation\fix_build_bat\fix_build.bat"
set "COMMON_SRC=%REPO_ROOT%\03_Helper_Libraries\common_bat\common.bat"
set "DAILY_SRC=%REPO_ROOT%\02_Template_Management\daily_report_bat\daily_report.bat"
set "WEEKLY_BAT_SRC=%REPO_ROOT%\02_Template_Management\weekly_report_bat\weekly_report.bat"
set "WEEKLY_PS1_SRC=%REPO_ROOT%\02_Template_Management\weekly_report_bat\weekly_report.ps1"
set "MONTHLY_BAT_SRC=%REPO_ROOT%\02_Template_Management\monthly_report_bat\monthly_report.bat"
set "MONTHLY_PS1_SRC=%REPO_ROOT%\02_Template_Management\monthly_report_bat\monthly_report.ps1"
set "WATCHER_SRC=%REPO_ROOT%\04_File_Watcher\auto_build_watcher_ps1\auto_build_watcher.ps1"
set "UPDATE_WRAPPER_SRC=%REPO_ROOT%\02_Template_Management\update_bat\update.bat"
set "ENV_EXAMPLE_SRC=%REPO_ROOT%\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat"
set "PROJECT_AGENTS_SRC=%REPO_ROOT%\05_Documentation\AGENTS_md\AGENTS.md"

echo ============================================================
echo  Bootstrap Codex automation into:
echo  %PROJECT_ROOT%
echo ============================================================

for %%F in ("%BUILD_SRC%" "%FIX_SRC%" "%COMMON_SRC%" "%DAILY_SRC%" "%WEEKLY_BAT_SRC%" "%WEEKLY_PS1_SRC%" "%MONTHLY_BAT_SRC%" "%MONTHLY_PS1_SRC%" "%WATCHER_SRC%" "%UPDATE_WRAPPER_SRC%" "%ENV_EXAMPLE_SRC%" "%PROJECT_AGENTS_SRC%") do (
    if not exist "%%~fF" (
        echo [ERROR] Required template file missing: %%~fF
        set "EXIT_CODE=1"
        goto :DONE
    )
)

if exist "%SCRIPTS_DIR%" (
    echo [WARN] .scripts\ already exists. Managed files will be overwritten.
    choice /C YN /M "Continue"
    if errorlevel 2 goto :ABORT
)

if not exist "%SCRIPTS_DIR%" mkdir "%SCRIPTS_DIR%"
if not exist "%SCRIPTS_DIR%\lib" mkdir "%SCRIPTS_DIR%\lib"

echo Copying scripts...
copy /Y "%BUILD_SRC%" "%SCRIPTS_DIR%\build.bat" > nul
copy /Y "%FIX_SRC%" "%SCRIPTS_DIR%\fix_build.bat" > nul
copy /Y "%COMMON_SRC%" "%SCRIPTS_DIR%\lib\common.bat" > nul
copy /Y "%DAILY_SRC%" "%SCRIPTS_DIR%\daily_report.bat" > nul
copy /Y "%WEEKLY_BAT_SRC%" "%SCRIPTS_DIR%\weekly_report.bat" > nul
copy /Y "%WEEKLY_PS1_SRC%" "%SCRIPTS_DIR%\weekly_report.ps1" > nul
copy /Y "%MONTHLY_BAT_SRC%" "%SCRIPTS_DIR%\monthly_report.bat" > nul
copy /Y "%MONTHLY_PS1_SRC%" "%SCRIPTS_DIR%\monthly_report.ps1" > nul
copy /Y "%WATCHER_SRC%" "%SCRIPTS_DIR%\auto_build_watcher.ps1" > nul
copy /Y "%UPDATE_WRAPPER_SRC%" "%SCRIPTS_DIR%\update.bat" > nul

if not exist "%SCRIPTS_DIR%\project.env.bat" (
    copy /Y "%ENV_EXAMPLE_SRC%" "%SCRIPTS_DIR%\project.env.bat" > nul
    echo [OK] Created .scripts\project.env.bat
) else (
    echo [SKIP] Existing .scripts\project.env.bat was preserved.
)

if not exist "%PROJECT_ROOT%\AGENTS.md" (
    copy /Y "%PROJECT_AGENTS_SRC%" "%PROJECT_ROOT%\AGENTS.md" > nul
    echo [OK] Created project AGENTS.md
) else (
    echo [SKIP] Existing project AGENTS.md was preserved.
)

set "GITIGNORE=%PROJECT_ROOT%\.gitignore"
if not exist "%GITIGNORE%" type nul > "%GITIGNORE%"
findstr /X /C:".scripts/project.env.bat" "%GITIGNORE%" > nul 2>&1
if errorlevel 1 echo .scripts/project.env.bat>> "%GITIGNORE%"
findstr /X /C:"build_logs/" "%GITIGNORE%" > nul 2>&1
if errorlevel 1 echo build_logs/>> "%GITIGNORE%"
findstr /X /C:".scripts/reports/" "%GITIGNORE%" > nul 2>&1
if errorlevel 1 echo .scripts/reports/>> "%GITIGNORE%"
findstr /X /C:".scripts/backup/" "%GITIGNORE%" > nul 2>&1
if errorlevel 1 echo .scripts/backup/>> "%GITIGNORE%"
echo [OK] Runtime output entries are present in .gitignore.

echo.
echo [DONE] Bootstrap completed.
echo Next steps:
echo   1. Edit .scripts\project.env.bat.
echo   2. Run .scripts\build.bat build.
echo   3. See 05_Documentation\operation_guides\README.md in the repository.
goto :DONE

:ABORT
echo Aborted.
set "EXIT_CODE=1"

:DONE
endlocal & exit /b %EXIT_CODE%
