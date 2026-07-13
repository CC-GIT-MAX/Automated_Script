# CHANGELOG.md -- History of changes to this repository

> Newest entries first. Each entry should be a dated summary with bullet points
> for what changed and why.

## 2026-07-13 -- Initial commit and reorganization

**Context**: This is the first commit of the `Automated_Script_Summary`
repository. The automation scripts were developed incrementally during
2026-07-13 in a working session. The full git history of the development
can be reconstructed from the conversation log.

**What changed**:
- Created repository structure under `D:\working_file\WorkSpace\scripts\Automated_Script_Summary`
- Categorized scripts into 7 top-level folders (01-07) by purpose
- Wrote root `AGENTS.md` (the master rulebook)
- Wrote 8 per-script `AGENTS.md` files documenting each script
- Wrote 3 category-level `AGENTS.md` files for the major folders
- Created `07_Tracking/TODO.md` with priority-ordered pending tasks
- Created `07_Tracking/IMPROVEMENTS.md` with future ideas
- Created this `CHANGELOG.md`

**Scripts included**:
- `01_Build_Automation/build_bat/build.bat` -- wrap iarbuild
- `01_Build_Automation/fix_build_bat/fix_build.bat` -- compile-fix auto loop
- `02_Template_Management/new_project_bat/new_project.bat` -- bootstrap new projects
- `02_Template_Management/update_scripts_bat/update_scripts.bat` -- template-to-project sync
- `02_Template_Management/update_bat/update.bat` -- project-local wrapper
- `03_Helper_Libraries/common_bat/common.bat` -- env loader
- `03_Helper_Libraries/compare_hash_ps1/compare_hash.ps1` -- file hash helper
- `04_File_Watcher/auto_build_watcher_ps1/auto_build_watcher.ps1` -- file save -> build

**Lessons baked into the scripts (do not reintroduce these anti-patterns)**:
1. `.bat` files must be ASCII, no BOM, no Chinese in output
2. Use `chcp 65001 > nul` at the top of every batch script
3. Use `goto :LABEL` + single `exit /b`, never `exit /b` inside `if () (...)`
4. Use explicit file lists in `update_scripts.bat` (no `%%~pF` path matching)
5. Use PowerShell hash helpers, not `fc` (errorlevel issue in for loops)
6. Use `codex exec` (not top-level `codex`) for non-interactive mode
7. Use `-C <PROJECT_ROOT> -s workspace-write` to let Codex edit project files
8. Always back up before overwriting
9. Never overwrite `project.env.bat` (per-project config)

**Known issues** (to be addressed in future commits):
- See `TODO.md` P0/P1 items
- See per-script AGENTS.md "Known issues" sections

**Next steps** (from `TODO.md`):
1. Test the new-project workflow on a second real project (P0)
2. Validate the git push to `git@github.com:CC-GIT-MAX/Automated_Script.git` (P0)
3. Wire up `auto_build_watcher.ps1` in a real editing session (P0)
4. Write `weekly_report.bat`, `analyze_log.bat`, `pre_commit_review.bat` (P1)