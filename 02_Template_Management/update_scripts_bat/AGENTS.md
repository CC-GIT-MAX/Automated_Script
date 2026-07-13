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

Open this script and find the three paired sections:
1. Variable definitions: `set "FILE_NEW_SRC=..."` and `set "FILE_NEW_DST=..."`
2. Scan phase: `call :CHECK_ONE "%FILE_NEW_SRC%" "%FILE_NEW_DST%" "new.bat"`
3. Apply phase: `call :APPLY_ONE "%FILE_NEW_SRC%" "%FILE_NEW_DST%" "new.bat"`
4. Backup phase: add an `if exist ... copy /Y ...` line

## Known issues

- Hash comparison uses a PowerShell helper (`lib\compare_hash.ps1`) which adds
  startup latency (~200ms per file). Acceptable for ~3 files.
- The `--no-backup` flag is dangerous in production. Use only in CI.

## Future work

- Support more files via a config file (e.g. `template_files.txt` listing what to sync)
- Add `--diff` mode that prints `git diff`-style output for changes