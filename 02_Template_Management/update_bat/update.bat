@echo off
chcp 65001 > nul
REM ============================================================
REM  Project-local wrapper to update from template
REM
REM  This wrapper knows where the template lives on YOUR machine.
REM  Edit the TEMPLATE_DIR line below once, then call this file
REM  from project root to update scripts.
REM
REM  Usage (from project root):
REM      .scripts\update [--apply] [--no-backup]
REM ============================================================

REM ===== EDIT THIS LINE to point at your template =====
set "TEMPLATE_DIR=C:\Users\25237\Documents\Codex\2026-07-13\codex-cli\outputs\template"
REM =====================================================

if not exist "%TEMPLATE_DIR%\update_scripts.bat" (
    echo [ERROR] Template not found at: %TEMPLATE_DIR%
    echo         Edit TEMPLATE_DIR in this file.
    exit /b 1
)

call "%TEMPLATE_DIR%\update_scripts.bat" %*
