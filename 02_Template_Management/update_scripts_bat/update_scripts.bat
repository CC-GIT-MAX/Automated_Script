@echo off
chcp 65001 > nul
REM ============================================================
REM  Update project scripts from the shared template
REM
REM  Usage (run from the project root):
REM      C:\path\to\template\update_scripts.bat [--apply] [--no-backup]
REM
REM  Safety rules:
REM    - NEVER overwrite project.env.bat
REM    - NEVER delete scripts that exist in .scripts/ but not in template/
REM    - Always back up before overwriting
REM    - Dry-run by default; --apply to actually copy
REM ============================================================

setlocal enabledelayedexpansion

set "TEMPLATE_DIR=%~dp0"
if "%TEMPLATE_DIR:~-1%"=="\" set "TEMPLATE_DIR=%TEMPLATE_DIR:~0,-1%"
set "COMPARE_SCRIPT=%TEMPLATE_DIR%\..\..\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1"
set "TMP_RESULT=%TEMP%\codex_update_result_%RANDOM%.txt"
set "PROJECT_ROOT=%CD%"
set "SCRIPTS_DIR=%PROJECT_ROOT%\.scripts"

REM ---- Define the explicit file list before validating paths ----
set "FILE_BUILD_SRC=%TEMPLATE_DIR%\..\..\01_Build_Automation\build_bat\build.bat"
set "FILE_BUILD_DST=%SCRIPTS_DIR%\build.bat"
set "FILE_FIX_SRC=%TEMPLATE_DIR%\..\..\01_Build_Automation\fix_build_bat\fix_build.bat"
set "FILE_FIX_DST=%SCRIPTS_DIR%\fix_build.bat"
set "FILE_COMMON_SRC=%TEMPLATE_DIR%\..\..\03_Helper_Libraries\common_bat\common.bat"
set "FILE_COMMON_DST=%SCRIPTS_DIR%\lib\common.bat"
set "FILE_DAILY_SRC=%TEMPLATE_DIR%\..\daily_report_bat\daily_report.bat"
set "FILE_DAILY_DST=%SCRIPTS_DIR%\daily_report.bat"
set "FILE_WEEKLY_SRC=%TEMPLATE_DIR%\..\weekly_report_bat\weekly_report.bat"
set "FILE_WEEKLY_DST=%SCRIPTS_DIR%\weekly_report.bat"
set "FILE_WEEKLY_PS1_SRC=%TEMPLATE_DIR%\..\weekly_report_bat\weekly_report.ps1"
set "FILE_WEEKLY_PS1_DST=%SCRIPTS_DIR%\weekly_report.ps1"
set "FILE_MONTHLY_SRC=%TEMPLATE_DIR%\..\monthly_report_bat\monthly_report.bat"
set "FILE_MONTHLY_DST=%SCRIPTS_DIR%\monthly_report.bat"
set "FILE_MONTHLY_PS1_SRC=%TEMPLATE_DIR%\..\monthly_report_bat\monthly_report.ps1"
set "FILE_MONTHLY_PS1_DST=%SCRIPTS_DIR%\monthly_report.ps1"

set "APPLY=0"
set "DO_BACKUP=1"
set "EXIT_CODE=0"
:PARSE_ARGS
if "%~1"=="" goto :PARSE_DONE
if /i "%~1"=="--apply" set "APPLY=1"
if /i "%~1"=="--no-backup" set "DO_BACKUP=0"
shift
goto :PARSE_ARGS
:PARSE_DONE

echo ============================================================
echo  Update project scripts from template
echo  Template : %TEMPLATE_DIR%
echo  Project  : %PROJECT_ROOT%
echo ============================================================

if not exist "%SCRIPTS_DIR%" (
    echo [ERROR] .scripts\ not found. Run new_project.bat first.
    set "EXIT_CODE=1"
    goto :DONE
)
if not exist "%FILE_BUILD_SRC%" (
    echo [ERROR] Template incomplete. Missing build.bat.
    set "EXIT_CODE=1"
    goto :DONE
)
if not exist "%COMPARE_SCRIPT%" (
    echo [ERROR] Template missing compare_hash.ps1
    set "EXIT_CODE=1"
    goto :DONE
)

set "CHANGE_COUNT=0"
set "NEW_COUNT=0"
echo Scanning for differences...
call :CHECK_ONE "%FILE_BUILD_SRC%" "%FILE_BUILD_DST%" "build.bat"
call :CHECK_ONE "%FILE_FIX_SRC%" "%FILE_FIX_DST%" "fix_build.bat"
call :CHECK_ONE "%FILE_COMMON_SRC%" "%FILE_COMMON_DST%" "lib\common.bat"
call :CHECK_ONE "%FILE_DAILY_SRC%" "%FILE_DAILY_DST%" "daily_report.bat"
call :CHECK_ONE "%FILE_WEEKLY_SRC%" "%FILE_WEEKLY_DST%" "weekly_report.bat"
call :CHECK_ONE "%FILE_WEEKLY_PS1_SRC%" "%FILE_WEEKLY_PS1_DST%" "weekly_report.ps1"
call :CHECK_ONE "%FILE_MONTHLY_SRC%" "%FILE_MONTHLY_DST%" "monthly_report.bat"
call :CHECK_ONE "%FILE_MONTHLY_PS1_SRC%" "%FILE_MONTHLY_PS1_DST%" "monthly_report.ps1"

echo.
if %CHANGE_COUNT% EQU 0 if %NEW_COUNT% EQU 0 (
    echo [OK] All scripts are up to date.
    goto :DONE
)

echo Summary: %CHANGE_COUNT% to update, %NEW_COUNT% to add.
echo.
if %APPLY%==0 (
    set /p CONFIRM="Apply these changes? (y/N): "
    if /i not "!CONFIRM!"=="y" (
        echo Aborted.
        goto :DONE
    )
)

if %DO_BACKUP%==1 (
    for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')"`) do set "TS=%%T"
    if "!TS!"=="" set "TS=00000000_000000"
    set "BACKUP_DIR=%SCRIPTS_DIR%\backup\!TS!"
    if not exist "!BACKUP_DIR!" mkdir "!BACKUP_DIR!"
    if not exist "!BACKUP_DIR!\lib" mkdir "!BACKUP_DIR!\lib"
    echo Backing up current scripts to .scripts\backup\!TS!\ ...
    if exist "%FILE_BUILD_DST%" copy /Y "%FILE_BUILD_DST%" "!BACKUP_DIR!\build.bat" > nul
    if exist "%FILE_FIX_DST%" copy /Y "%FILE_FIX_DST%" "!BACKUP_DIR!\fix_build.bat" > nul
    if exist "%FILE_COMMON_DST%" copy /Y "%FILE_COMMON_DST%" "!BACKUP_DIR!\lib\common.bat" > nul
    if exist "%FILE_DAILY_DST%" copy /Y "%FILE_DAILY_DST%" "!BACKUP_DIR!\daily_report.bat" > nul
    if exist "%FILE_WEEKLY_DST%" copy /Y "%FILE_WEEKLY_DST%" "!BACKUP_DIR!\weekly_report.bat" > nul
    if exist "%FILE_WEEKLY_PS1_DST%" copy /Y "%FILE_WEEKLY_PS1_DST%" "!BACKUP_DIR!\weekly_report.ps1" > nul
    if exist "%FILE_MONTHLY_DST%" copy /Y "%FILE_MONTHLY_DST%" "!BACKUP_DIR!\monthly_report.bat" > nul
    if exist "%FILE_MONTHLY_PS1_DST%" copy /Y "%FILE_MONTHLY_PS1_DST%" "!BACKUP_DIR!\monthly_report.ps1" > nul
    if exist "%SCRIPTS_DIR%\project.env.bat" copy /Y "%SCRIPTS_DIR%\project.env.bat" "!BACKUP_DIR!\project.env.bat" > nul
)

echo Applying changes...
call :APPLY_ONE "%FILE_BUILD_SRC%" "%FILE_BUILD_DST%" "build.bat"
call :APPLY_ONE "%FILE_FIX_SRC%" "%FILE_FIX_DST%" "fix_build.bat"
call :APPLY_ONE "%FILE_COMMON_SRC%" "%FILE_COMMON_DST%" "lib\common.bat"
call :APPLY_ONE "%FILE_DAILY_SRC%" "%FILE_DAILY_DST%" "daily_report.bat"
call :APPLY_ONE "%FILE_WEEKLY_SRC%" "%FILE_WEEKLY_DST%" "weekly_report.bat"
call :APPLY_ONE "%FILE_WEEKLY_PS1_SRC%" "%FILE_WEEKLY_PS1_DST%" "weekly_report.ps1"
call :APPLY_ONE "%FILE_MONTHLY_SRC%" "%FILE_MONTHLY_DST%" "monthly_report.bat"
call :APPLY_ONE "%FILE_MONTHLY_PS1_SRC%" "%FILE_MONTHLY_PS1_DST%" "monthly_report.ps1"

echo.
echo [DONE] Scripts updated. Your project.env.bat was preserved.

:DONE
if exist "!TMP_RESULT!" del "!TMP_RESULT!" > nul 2>&1
endlocal & exit /b %EXIT_CODE%

:CHECK_ONE
if not exist "%~1" (
    echo   [ERROR] %~3 - template source is missing
    set "EXIT_CODE=1"
    goto :EOF
)
if not exist "%~2" (
    echo   [NEW]   %~3 - will be added
    set /a NEW_COUNT+=1
    goto :EOF
)
powershell -NoProfile -ExecutionPolicy Bypass -File "!COMPARE_SCRIPT!" "%~1" "%~2" > "!TMP_RESULT!" 2>&1
set "RESULT="
set /p RESULT=<"!TMP_RESULT!"
if "!RESULT!"=="SAME" (
    echo   [SAME]  %~3 - no change
) else (
    echo   [DIFF]  %~3 - will be updated
    set /a CHANGE_COUNT+=1
)
goto :EOF

:APPLY_ONE
if not exist "%~2" (
    copy /Y "%~1" "%~2" > nul
    echo   [OK]   %~2 ^(new^)
    goto :EOF
)
powershell -NoProfile -ExecutionPolicy Bypass -File "!COMPARE_SCRIPT!" "%~1" "%~2" > "!TMP_RESULT!" 2>&1
set "RESULT="
set /p RESULT=<"!TMP_RESULT!"
if "!RESULT!"=="SAME" (
    echo   [SKIP] %~2 ^(same^)
) else (
    copy /Y "%~1" "%~2" > nul
    echo   [OK]   %~2 ^(updated^)
)
goto :EOF
