# AGENTS.md -- weekly_report.bat

## What it does

Thin batch wrapper that invokes the companion `weekly_report.ps1` PowerShell
script. Gathers daily reports in a date range and synthesizes a weekly report
(management-friendly: Done / In Progress / Blockers / Plan / Statistics).

This is the **mechanism that replaces the old workflow of writing Feishu
weekly reports by hand**. Run it on Friday afternoon, review the output,
copy-paste to Feishu.

## How to call it

```bat
.scripts\weekly_report                              REM this week (Mon-Sun)
.scripts\weekly_report --from 2026-07-06 --to 2026-07-12   explicit range
.scripts\weekly_report --no-codex                   skip Codex, manual template only
```

Default range is the **current ISO week, Monday to Sunday** (calculated in
PowerShell so the script works regardless of the host locale).

## Files in this directory

| File | Purpose |
|---|---|
| `weekly_report.bat` | Batch wrapper (you call this) |
| `weekly_report.ps1` | PowerShell script (does the real work) |
| `AGENTS.md` | This file |

The PowerShell script does:
- Date math (Monday-of-current-week)
- File filtering (which daily reports fall in the range)
- Codex invocation (if available)
- Report assembly (header + synthesized body + source daily reports)
- File output

## Why a PowerShell companion?

A previous pure-batch version had severe problems with cmd's parser:
- Nested `if / for / goto` inside `>` redirect blocks
- `findstr /R` regex handling of `$` and backslashes
- Delayed-expansion interaction with `if` evaluation

A PowerShell companion makes the script **much more reliable** at the cost
of one extra interpreter hop. The batch wrapper is just glue.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | success |
| 99 | common.bat loader failed |
| 3 | invalid date argument |
| other | error from PowerShell |

## Inputs

- `.scripts\project.env.bat` (via `lib\common.bat`)
- `.scripts\reports\daily\*.md` (the daily reports to summarize)
- `--from YYYY-MM-DD --to YYYY-MM-DD` (optional)
- `--no-codex` (optional, skip Codex synthesis)

## Outputs

- `.scripts\reports\weekly\weekly_<FROM>_to_<TO>.md`

## Dependencies

- `lib\common.bat` (env loader)
- `codex` CLI on PATH (only if `--no-codex` is NOT set)
- PowerShell 5.1+ (built into Windows)

## How Codex is called

```
codex exec --skip-git-repo-check -C <PROJECT_ROOT> -s workspace-write ^
  -c model="gpt-5.1" ^
  "Read the file at <TMP_INPUT> and synthesize a weekly report in Markdown.
   Write ONLY the synthesized report to stdout..."
```

The prompt is constrained to **stdout only**, so the synthesized report
can be redirected cleanly. The `--skip-git-repo-check` flag lets the
script run from a directory without git history.

## Fallback behavior

If `codex` is not on PATH, or Codex returns non-zero, or Codex produces no
output, the script falls back to a **manual template** with placeholders
like `## Done This Week` and `## In Progress`. The user can then fill it
in manually. This means the script is usable even without Codex.

## Known issues

- The default Mon-Sun range assumes ISO weeks. If your company uses a
  different convention (e.g. Sun-Sat in the US), pass `--from` / `--to`
  explicitly.
- Codex sometimes returns 0 exit code but an empty stdout. The script
  handles this by also checking file existence and content.
- The raw daily entries are appended under `## Source:` for auditability,
  which makes the file longer than typical reports. Edit the file
  afterwards to remove the source section if you only want the summary.

## Editing the .ps1

If you need to change the prompt, the section headings, or the
synthesis behavior, edit `weekly_report.ps1`. The batch wrapper does
not need to change.

## Future work

- Add `--feishu` mode that posts directly to a Feishu webhook
- Add `--out file.md` to write to a custom location
- Add statistics: hours per major area (requires time tracking integration)