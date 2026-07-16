# AGENTS.md -- update_scripts.bat

## What it does

The core of the template-to-project sync. Detects which files in the template
differ from those in a target project, optionally backs them up, and copies
the new versions.

This is the **script that does the work**; the project''s `.scripts\update.bat`
is a thin wrapper that calls this one.

## How to call it

```bat
C:\path\to\template\update_scripts.bat                 REM dry-run
C:\path\to\template\update_scripts.bat --apply         REM apply
C:\path\to\template\update_scripts.bat --apply --no-backup   REM CI mode
```

Must be run from the **target project''s root directory** (uses `%CD%`).

## Inputs

- Current working directory = target project root
- `TEMPLATE_DIR` (set by the wrapper `update.bat`, or auto-detected to `%~dp0`)

## Outputs

- Console output showing `[SAME]`, `[DIFF]`, `[NEW]` status for each tracked file
- `.scripts\backup\<TIMESTAMP>\` -- backup of files about to be overwritten
- Updated files in `.scripts\`

## Files managed (hard-coded explicit list)

| Template source | Project destination |
|---|---|
| `build.bat` | `.scripts\build.bat` |
| `fix_build.bat` | `.scripts\fix_build.bat` |
| `lib\common.bat` | `.scripts\lib\common.bat` |
| `daily_report_bat\daily_report.bat` | `.scripts\daily_report.bat` |
| `weekly_report_bat\weekly_report.bat` | `.scripts\weekly_report.bat` |
| `weekly_report_bat\weekly_report.ps1` | `.scripts\weekly_report.ps1` |
| `monthly_report_bat\monthly_report.bat` | `.scripts\monthly_report.bat` |
| `monthly_report_bat\monthly_report.ps1` | `.scripts\monthly_report.ps1` |

## Files PRESERVED (never touched)

- `.scripts\project.env.bat` (per-project config)
- `.scripts\auto_build_watcher.ps1` (project-specific helpers)
- Any other file in `.scripts\` not in the managed list

## Why an explicit file list?

We do NOT scan the template directory because:
- `for %%F in (...)` with `%%~pF` strips the drive letter, breaking `if` comparisons
- Auto-discovery of nested files is fragile
- A hard-coded list is auditable

## Adding a new file to the sync list

Open this script and find the four paired sections:
1. Variable definitions: `set "FILE_NEW_SRC=..."` and `set "FILE_NEW_DST=..."`
2. Scan phase: `call :CHECK_ONE "%FILE_NEW_SRC%" "%FILE_NEW_DST%" "new.bat"`
3. Apply phase: `call :APPLY_ONE "%FILE_NEW_SRC%" "%FILE_NEW_DST%" "new.bat"`
4. Backup phase: add an `if exist ... copy /Y ...` line
5. Update this AGENTS.md `Files managed` table

## Known issues

- Hash comparison uses a PowerShell helper (`lib\compare_hash.ps1`) which adds
  startup latency (~200ms per file). Acceptable for ~8 files.
- The `--no-backup` flag is dangerous in production. Use only in CI.

## Future work

- Support more files via a config file (e.g. `template_files.txt` listing what to sync)
- Add `--diff` mode that prints `git diff`-style output for changes
## Dependency manifest (transplant this script by copying)

`update_scripts.bat` is the **template-to-project sync engine**. It reads
exactly one helper (`compare_hash.ps1`) and the same 8 managed scripts that
`new_project.bat` deploys.

| Slot | Source in this repo | Runtime path (when called from the shared template) |
|---|---|---|
| Entry script | `02_Template_Management/update_scripts_bat/update_scripts.bat` | `<TEMPLATE_DIR>\update_scripts.bat` |
| Hash helper (REQUIRED) | `03_Helper_Libraries/compare_hash_ps1/compare_hash.ps1` | `<TEMPLATE_DIR>\..\..\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1` (resolved by `%~dp0\..\..\...`) |
| 8 managed source files (read via explicit list) | see table below | -- |

**Files this script reads from the template (per the script's own `%FILE_*_SRC%` variables)**

| Template source path (resolved from `update_scripts.bat`'s folder) |
|---|
| `..\..\01_Build_Automation\build_bat\build.bat` |
| `..\..\01_Build_Automation\fix_build_bat\fix_build.bat` |
| `..\..\03_Helper_Libraries\common_bat\common.bat` |
| `..\daily_report_bat\daily_report.bat` |
| `..\weekly_report_bat\weekly_report.bat` |
| `..\weekly_report_bat\weekly_report.ps1` |
| `..\monthly_report_bat\monthly_report.bat` |
| `..\monthly_report_bat\monthly_report.ps1` |

**External tool dependencies**

| Tool | Version / how to verify | Used for |
|---|---|---|
| PowerShell | 5.1+ on Windows | Drives `compare_hash.ps1` |
| `cmd.exe` | Windows default | Script host, `copy /Y`, `dir /b /od /a-d` |

**Transplant command (cmd, from the machine that will own the shared template)**

```bat
REM The entry script and its hash helper are the only files you need;
REM the managed source files are read via relative paths, so they MUST
REM stay in their repository folders (do NOT flatten them into a single dir).
mkdir D:\my-template
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\update_scripts_bat\update_scripts.bat" D:\my-template\update_scripts.bat
REM The hash helper MUST sit at the relative path the script expects:
mkdir D:\my-template\03_Helper_Libraries\compare_hash_ps1
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1" D:\my-template\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1
```

If you mirror the full repo (`Copy-Item -Recurse`) instead, all relative paths
resolve automatically -- this is the **preferred** transplant.

## Transplant checklist

```bat
REM 1. Both files present at the expected relative positions
dir <TEMPLATE_DIR>\update_scripts.bat
dir <TEMPLATE_DIR>\..\..\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1

REM 2. Run a dry-run against a scratch project
mkdir C:\sync-smoke
cd C:\sync-smoke
mkdir .scripts
"<TEMPLATE_DIR>\update_scripts.bat"                  REM dry-run; expect SAME/DIFF/NEW per file
"<TEMPLATE_DIR>\update_scripts.bat" --apply          REM copy into .scripts\
dir .scripts                                          REM build.bat, fix_build.bat, etc. present
dir .scripts\lib                                       REM common.bat present
```

See also: `compare_hash.ps1` (helper called via `powershell`), `update.bat`
(thin wrapper that points at this script), `new_project.bat` (uses the same
managed file list).