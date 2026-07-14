# CHANGELOG.md -- History of changes to this repository

> Newest entries first. Each entry should be a dated summary with bullet points
> for what changed and why.

## 2026-07-14 -- Reports suite complete + PowerShell companion pattern

- Added `05_Documentation/operation_guides/` with one detailed Chinese guide per user workflow: bootstrap, configuration, build, compile-fix, daily/weekly/monthly reports, update/rollback, watcher, and helpers.
- Repaired `new_project.bat` for the categorized repository layout and added deployment of report companions, watcher, update wrapper, project AGENTS template, and runtime `.gitignore` entries.
- Verified bootstrap in a fresh temporary project and confirmed repeated bootstrap preserves `project.env.bat` and project `AGENTS.md`.
**Context**: Reports suite (daily / weekly / monthly) was added in the
previous commit but only the `daily_report.bat` worked end-to-end. The
weekly and monthly scripts kept failing inside cmd's parser with opaque
errors like `> was unexpected at this time.` and `( was unexpected at
this time.`. The root causes are documented in
`_tracking/PITFALLS.md` (new file in this commit).

**Resolution**: Rewrote weekly and monthly as **`.bat` wrapper +
`PowerShell` companion** pairs. The batch file now does only:
1. Load `lib\common.bat` (project env)
2. Translate CLI flags (`--no-codex`, `--from`, `--to`, `YYYY-MM`) to
   PowerShell-native parameter names (`-NoCodex`, `-From`, `-To`, `-Month`)
3. Invoke the companion `.ps1` with `powershell -NoProfile -ExecutionPolicy Bypass -File`

The PowerShell script does all the real work (date math, file filtering,
Codex invocation, report assembly, file output). This pattern is much
more reliable than the original pure-batch attempt.

**What changed**:
- `02_Template_Management/weekly_report_bat/weekly_report.bat` rewritten as
  a thin wrapper (1181 bytes; was ~8 KB)
- `02_Template_Management/weekly_report_bat/weekly_report.ps1` added
  (6377 bytes) -- the actual implementation
- `02_Template_Management/monthly_report_bat/monthly_report.bat` rewritten
  as a thin wrapper (1571 bytes; was ~10 KB)
- `02_Template_Management/monthly_report_bat/monthly_report.ps1` added
  (8064 bytes) -- the actual implementation
- `02_Template_Management/daily_report_bat/daily_report.bat` simplified
  (3259 bytes; was 4325). The git auto-detection was removed because the
  parser was too fragile. A future commit can re-add it in the PowerShell
  companion style.
- All 3 per-script `AGENTS.md` files updated to reflect the new
  architecture and explain the wrapper+companion pattern.
- `02_Template_Management/new_project_bat/new_project.bat` updated to copy
  the 2 new `.ps1` files.
- `02_Template_Management/update_scripts_bat/update_scripts.bat` updated to
  sync the 2 new `.ps1` files (added `FILE_*_PS1_SRC` / `FILE_*_PS1_DST`
  variables, 2 `CHECK_ONE` calls, 2 `APPLY_ONE` calls, 2 backup lines).
- `02_Template_Management/update_scripts_bat/AGENTS.md` updated to list
  the 8 managed files (was 6).
- `_tracking/TODO.md` updated to reflect the new state.
- `_tracking/PITFALLS.md` **created** -- the new gotcha reference.

**Verified**:
- `daily_report.bat --regen 2026-07-13` produces a valid
  `.scripts\reports\daily\2026-07-13.md` (~330 bytes)
- `weekly_report.bat --no-codex --from 2026-07-13 --to 2026-07-15`
  produces `weekly_2026-07-13_to_2026-07-15.md` (1938 bytes) with all
  3 source dailies appended
- `monthly_report.bat --no-codex 2026-07` produces
  `monthly_2026-07.md` with 3 dailies and 1 weekly aggregated

**Not yet verified** (these are P1 in TODO):
- The actual Codex synthesis path (current tests use `--no-codex` to
  avoid consuming Codex tokens during testing)

## 2026-07-13 -- Reports suite initial attempt

**Context**: User requested daily/weekly/monthly report scripts.

**What was added**:
- `02_Template_Management/daily_report_bat/{daily_report.bat, AGENTS.md}`
- `02_Template_Management/weekly_report_bat/{weekly_report.bat, AGENTS.md}`
- `02_Template_Management/monthly_report_bat/{monthly_report.bat, AGENTS.md}`

**Outcome**: `daily_report.bat` worked. Weekly and monthly kept failing
inside cmd's parser. The next day's commit (2026-07-14 entry above)
replaced them with the PowerShell-companion pattern.

## 2026-07-13 -- Initial commit and reorganization

**Context**: First commit of the `Automated_Script_Summary` repository.

**What was included**:
- `01_Build_Automation/build_bat/build.bat` -- wrap iarbuild
- `01_Build_Automation/fix_build_bat/fix_build.bat` -- compile-fix auto loop
- `02_Template_Management/new_project_bat/new_project.bat` -- bootstrap new projects
- `02_Template_Management/update_scripts_bat/update_scripts.bat` -- template-to-project sync
- `02_Template_Management/update_bat/update.bat` -- project-local wrapper
- `03_Helper_Libraries/common_bat/common.bat` -- env loader
- `03_Helper_Libraries/compare_hash_ps1/compare_hash.ps1` -- file hash helper
- `04_File_Watcher/auto_build_watcher_ps1/auto_build_watcher.ps1` -- file save -> build

**Categories**: 7 top-level folders (01-07) by purpose.

**Lessons baked in** (these turned out to be incomplete -- see
`_tracking/PITFALLS.md` for the full set):
1. `.bat` files must be ASCII, no BOM, no Chinese in output
2. Use `chcp 65001 > nul` at the top of every batch script
3. Use `goto :LABEL` + single `exit /b`, never `exit /b` inside `if () (...)`
4. Use explicit file lists in `update_scripts.bat` (no `%%~pF` path matching)
5. Use PowerShell hash helpers, not `fc` (errorlevel issue in for loops)
6. Use `codex exec` (not top-level `codex`) for non-interactive mode
7. Use `-C <PROJECT_ROOT> -s workspace-write` to let Codex edit project files
8. Always back up before overwriting
9. Never overwrite `project.env.bat` (per-project config)
