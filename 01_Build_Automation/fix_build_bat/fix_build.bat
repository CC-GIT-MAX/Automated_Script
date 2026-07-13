@echo off
chcp 65001 > nul
REM ============================================================
REM  IAR compile-fix auto loop (portable across projects)
REM
REM  Reads configuration from .scripts\project.env
REM  Usage: .\.scripts\fix_build.bat [max_retry]
REM
REM  Exit codes:
REM      0 = build passed
REM      1 = max_retry exhausted
REM      2 = codex command not found
REM      3 = config / path error
REM ============================================================

setlocal enabledelayedexpansion

set "MAX_RETRY=%~1"
if "%MAX_RETRY%"=="" set "MAX_RETRY=5"

call "%~dp0lib\common.bat"
if errorlevel 1 exit /b 99

set "LOG_DIR_ABS=%PROJECT_ROOT%\%LOG_DIR%"

echo ============================================================
echo  Compile-Fix Auto Loop
echo  Project : %PROJECT_NAME% (%MCU_FAMILY%)
echo  Project root : %PROJECT_ROOT%
echo  Max retry    : %MAX_RETRY%
echo ============================================================

where codex >nul 2>&1
if errorlevel 1 goto :NO_CODEX

if not exist "%~dp0build.bat" goto :NO_BUILDBAT

set "ATTEMPT=0"
set "FINAL_RC=1"

:RETRY_LOOP
set /a ATTEMPT+=1
echo.
echo ==== Attempt %ATTEMPT% / %MAX_RETRY% ====

call "%~dp0build.bat" build
set "BUILD_RC=%ERRORLEVEL%"

if not %BUILD_RC% EQU 0 goto :HANDLE_FAIL

echo [OK] Build passed after %ATTEMPT% attempt(s).
set "FINAL_RC=0"
goto :DONE

:HANDLE_FAIL
echo [FAIL] Build failed, invoking codex...

set "LATEST_LOG="
for /f "delims=" %%F in ('dir /b /od /a-d "%LOG_DIR_ABS%\build_*.log" 2^>nul') do set "LATEST_LOG=%%F"

if "!LATEST_LOG!"=="" goto :NO_LOG

set "LOG_PATH=%LOG_DIR_ABS%\!LATEST_LOG!"
echo   Log file: !LOG_PATH!
echo   Calling codex to fix...

codex exec --skip-git-repo-check -C "%PROJECT_ROOT%" -s workspace-write ^
  "Read the IAR build log at !LOG_PATH!. Project is %PROJECT_NAME% on MCU %MCU_FAMILY%. Fix the compile errors following AGENTS.md rules. Constraints: do not modify startup_*.s / startup_*.c; do not modify *.icf / *.sct linker scripts; do not modify .ewp / .eww project files; change at most 1 file per cycle; do not commit; print final git diff summary."

set "CODEX_RC=%ERRORLEVEL%"
if !CODEX_RC! NEQ 0 (
    echo [WARN] codex returned non-zero exit code !CODEX_RC!, continuing to verify build.
)

if %ATTEMPT% GEQ %MAX_RETRY% goto :MAX_RETRY_REACHED
timeout /t 2 /nobreak >nul
goto :RETRY_LOOP

:NO_CODEX
echo [ERROR] codex command not found. Install Codex CLI and add to PATH.
echo          https://github.com/openai/codex
set "FINAL_RC=2"
goto :DONE

:NO_BUILDBAT
echo [ERROR] build.bat not found.
set "FINAL_RC=3"
goto :DONE

:NO_LOG
echo [ERROR] No %LOG_DIR%\build_*.log found.
set "FINAL_RC=3"
goto :DONE

:MAX_RETRY_REACHED
echo.
echo [FAIL] Max retry %MAX_RETRY% reached. Manual intervention needed.
echo        Last log: !LOG_PATH!
set "FINAL_RC=1"
goto :DONE

:DONE
endlocal
exit /b %FINAL_RC%
