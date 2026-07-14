# TODO.md -- Pending tasks

> Tasks that need to be done. **When you start a task, add `[WIP]` next to it.**
> When you finish, remove it from this file and add a row to `CHANGELOG.md`.

## P0 -- Critical (do these first)

- [ ] **Test the full new-project workflow on a second real project.**
  Currently only tested on YTM32B1MD1 FlexCAN. Need to verify it works on
  a project with a different layout (e.g. STM32CubeMX-generated, or Keil MDK).
  -- Owner: TBD, est. 2 hours

- [ ] **Wire up `auto_build_watcher.ps1` to a real editing session.**
  Open the watcher in a real PowerShell window, edit some code in IAR or
  VSCode, verify the build fires automatically. Watch for missing dependencies.
  -- Owner: TBD, est. 2 hours

- [ ] **Add `weekly_report.ps1` / `monthly_report.ps1` to `_REPOSITORY_STRUCTURE.md`**
  and the root `MANIFEST.md` so the repo topology reflects the current state.
  The `.ps1` companions are part of the reports suite and should be listed.
  -- Owner: TBD, est. 30 min

- [ ] **Verify operation guides on a second real IAR project.**
  Follow the new-project, configuration, build, and report guides without using
  the FlexCAN reference project; record any unclear step in `PITFALLS.md`.
  -- Owner: TBD, est. 1 hour
## P1 -- Important

- [ ] **End-to-end test of the reports suite with real Codex synthesis.**
  Current tests use `--no-codex` (manual template). Verify the Codex path
  actually produces a synthesized report from daily entries, and that the
  fallback to manual template works when Codex is unavailable.
  -- Owner: TBD, est. 1 hour

- [ ] **Add git-detection / commit auto-population to `daily_report.bat`.**
  A previous version of daily_report tried to read `git log` and pre-fill the
  "Today's Commits" section. The implementation was removed because of parser
  fragility. Re-implement in the PowerShell style used by weekly/monthly.
  -- Owner: TBD, est. 1 hour

- [ ] **Add `--feishu` mode to `weekly_report.ps1`.**
  When given a Feishu webhook URL, post the synthesized report to the group
  bot instead of (or in addition to) writing to `.scripts\reports\weekly\`.
  -- Owner: TBD, est. 2 hours

- [ ] **Decide whether to remove the existing `update_bat/update.bat` wrapper.**
  The project-local wrapper points to `C:\Users\25237\Documents\Codex\...`
  -- that path is machine-specific. Either make it auto-detect via a
  discovery mechanism, or document the per-project edit step.
  -- Owner: TBD, est. 30 min

- [ ] **Centralize the `--no-codex` flag translation.**
  Currently duplicated in `weekly_report.bat` and `monthly_report.bat`.
  Move to a shared `lib\translate_args.bat` (or just to `lib\common.bat`).
  -- Owner: TBD, est. 1 hour

- [ ] **Automate PITFALLS checks for batch scripts.**
  Add a smoke-test/lint script that detects duplicate labels, BOM bytes, missing
  companion PowerShell files, and `exit /b` inside parenthesized blocks.
  -- Owner: TBD, est. 2 hours

## P2 -- Nice to have

- [ ] **Color-coded output in scripts.**
  Use ANSI escape codes (chcp 65001 already enables them) to show green
  `[OK]`, red `[FAIL]`, yellow `[WARN]`. Less critical now that the
  PowerShell companions produce clean output.
  -- Owner: TBD, est. 1 hour

- [ ] **GCC ARM toolchain support in `build.bat`.**
  Replace `IAR_BIN` invocation with a configurable toolchain command.
  Read `TOOLCHAIN=iar|gcc|keil` from `project.env.bat`.
  -- Owner: TBD, est. 3 hours

- [ ] **CI workflow (.github/workflows/test.yml).**
  On every push, run a smoke test: copy template to a temp dir, run
  `new_project.bat` against a fake project, run `update.bat` and verify
  the diff is empty.
  -- Owner: TBD, est. 4 hours

- [ ] **Convert `new_project.bat` to also generate a starter AGENTS.md
  customized for the project (auto-fill MCU_FAMILY, project name).**
  -- Owner: TBD, est. 1 hour

- [ ] **Auto-generate trend charts from monthly report statistics.**
  -- Owner: TBD, est. 3 hours

- [ ] **Multi-project monthly roll-up.**
  Generate a single monthly report that aggregates from multiple projects.
  -- Owner: TBD, est. 4 hours

## P3 -- Future ideas

See `IMPROVEMENTS.md` for the full list. Some highlights:

- Web UI for browsing the build logs across multiple projects
- Slack/Feishu bot that triggers `fix_build.bat` from a chat command
- VSCode extension that runs the watcher in the background
- Static analysis on whole project (weekly batch job)

## Important: read these before touching code

Before working on any batch script, **read `_tracking/PITFALLS.md`** first.
It documents the gotchas we hit during development so we don't repeat them.
The most important rules (also in root `AGENTS.md`):

- Use `goto :LABEL` + single `exit /b`, **never** `exit /b` inside `if () (...)`
- `findstr /R` regex has serious limitations -- use PowerShell for any
  non-trivial pattern matching
- Don't nest `if` inside `for` inside `>` redirect block without testing
  in isolation first
- For complex logic (date math, file filtering, file iteration), **use
  PowerShell** -- the batch wrapper is just glue
