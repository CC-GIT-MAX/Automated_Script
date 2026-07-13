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
  -- Owner: TBD, est. 1 hour

- [ ] **Validate the full git push to `git@github.com:CC-GIT-MAX/Automated_Script.git`.**
  This is part of the current PR but the push itself has not been verified.
  -- Owner: TBD, est. 30 min

## P1 -- Important

- [ ] **Write `weekly_report.bat` (飞书周报自动生成).**
  See `05_Documentation/codex_prompt_library/codex_prompt_library.md` section 5
  for the prompt template. Script should read `git log` for the past 7 days
  and call Codex to format as Feishu weekly report.
  -- Owner: TBD, est. 3 hours

- [ ] **Write `analyze_log.bat` (调试日志分析).**
  Accept a serial/J-Link RTT log file path, call Codex to identify anomalies
  and suggest root cause. See prompt library section 2.
  -- Owner: TBD, est. 2 hours

- [ ] **Write `pre_commit_review.bat` (Code Review 预审).**
  Before `git commit`, run Codex to review staged changes per AGENTS.md.
  -- Owner: TBD, est. 2 hours

- [ ] **Add the new automation scripts to `new_project.bat` and
  `update_scripts.bat` once they are written.**
  -- Owner: TBD, est. 1 hour (per new script)

- [ ] **PowerShell profile function cleanup.**
  The `fix` and `build` functions in the user''s PowerShell profile were added
  during early development but are not part of the formal automation. Either
  add them to this repo as a `setup.ps1` or document them in README.
  -- Owner: TBD, est. 30 min

## P2 -- Nice to have

- [ ] **Color-coded output in scripts.**
  Use ANSI escape codes (chcp 65001 already enables them) to show green
  `[OK]`, red `[FAIL]`, yellow `[WARN]`.
  -- Owner: TBD, est. 2 hours

- [ ] **GCC ARM toolchain support in `build.bat`.**
  Replace `IAR_BIN` invocation with a configurable toolchain command.
  Read `TOOLCHAIN=iar|gcc|keil` from `project.env.bat`.
  -- Owner: TBD, est. 3 hours

- [ ] **Add CI workflow (.github/workflows/test.yml).**
  On every push, run a smoke test: copy template to a temp dir, run
  `new_project.bat` against a fake project, run `update.bat` and verify
  the diff is empty.
  -- Owner: TBD, est. 4 hours

- [ ] **Convert `new_project.bat` to also generate a starter AGENTS.md
  customized for the project (auto-fill MCU_FAMILY, project name).**
  -- Owner: TBD, est. 1 hour

## P3 -- Future ideas

See `IMPROVEMENTS.md` for the full list. Some highlights:

- Web UI for browsing the build logs across multiple projects
- Slack/Feishu bot that triggers `fix_build.bat` from a chat command
- VSCode extension that runs the watcher in the background