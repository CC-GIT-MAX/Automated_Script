# AGENTS.md -- daily_report.bat

## What it does

Generates a single daily work report at `.scripts\reports\daily\YYYY-MM-DD.md`
for the current project. Pre-fills date, project name, MCU family, author,
and a template with section headers (Done / In Progress / Blocked / Tomorrow /
Notes). The user then edits the file to fill in the content.

This is the **source of truth** that `weekly_report.bat` and
`monthly_report.bat` synthesize from.

## How to call it

```bat
.scripts\daily_report                       REM create today's report
.scripts\daily_report 2026-07-13            REM create a report for a specific date
.scripts\daily_report --regen               REM overwrite today's report from scratch
.scripts\daily_report --append "fixed UART"  REM append a line to today's report
```

After running, the file is opened in the default editor (Notepad) so the
user can edit it immediately.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | success |
| 3 | reports dir not writable |
| 99 | common.bat loader failed |

## Inputs

- `.scripts\project.env.bat` -- project identity (`PROJECT_NAME`, `MCU_FAMILY`)
- optional date argument `YYYY-MM-DD`
- optional `--regen` / `--append "<text>"` flags

## Outputs

- `.scripts\reports\daily\YYYY-MM-DD.md` -- the daily report file
- stdout instructions / status

## Dependencies

- `lib\common.bat` (project env loader)
- `powershell` on PATH (for date formatting)
- NOTEPAD or default text editor (for `start ""` after creation)

## Known issues

- The script does NOT auto-detect git commits (a previous version did, but
  the parser was too fragile). Add commits manually with `--append`.
- The script does NOT commit anything; review and commit manually.
- `--append` does not write a newline before the bullet if the file does not
  end with one. Append a blank line yourself if needed.

## Customizing the template

Open `daily_report.bat` and find the `:WRITE_FILE` block near
the end. Edit the section headings and placeholders as needed. Keep the
section names stable -- `weekly_report.bat` and `monthly_report.bat`
look for `## Done`, `## In Progress`, `## Blocked / Risks`,
`## Tomorrow's Plan` patterns in the raw daily entries when synthesizing.

## Future work

- Auto-populate from J-Link RTT / serial logs (read the most recent log)
- Auto-populate from PR list (`gh pr list --author @me`)
- Hook into the `auto_build_watcher.ps1` to stamp the report when a build
  passes / fails
- Add `--interactive` mode that prompts for each section