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
## Dependency manifest (transplant this script by copying)

`weekly_report.bat` is a thin wrapper; the real work is done by the companion
`weekly_report.ps1` in the **same folder**. Both files must travel together,
along with the env loader and project config.

| Slot | Source in this repo | Runtime path in target project |
|---|---|---|
| Entry script | `02_Template_Management/weekly_report_bat/weekly_report.bat` | `<PROJECT_ROOT>\.scripts\weekly_report.bat` |
| Companion worker (REQUIRED) | `02_Template_Management/weekly_report_bat/weekly_report.ps1` | `<PROJECT_ROOT>\.scripts\weekly_report.ps1` |
| Env loader (REQUIRED) | `03_Helper_Libraries/common_bat/common.bat` | `<PROJECT_ROOT>\.scripts\lib\common.bat` |
| Project config (REQUIRED) | `06_Project_Examples/YTM32B1MD1_FlexCAN/project.env.bat` | `<PROJECT_ROOT>\.scripts\project.env.bat` |
| Input data | `.scripts\reports\daily\YYYY-MM-DD.md` | (produced by `daily_report.bat`) |

**External tool dependencies**

| Tool | Version / how to verify | Used for |
|---|---|---|
| PowerShell | 5.1+ on Windows (`$PSVersionTable.PSVersion`) | Runs the companion `.ps1` |
| `codex` CLI | Optional; needed unless `--no-codex` is passed | Synthesizes the weekly summary |
| `cmd.exe` | Windows default | Script host |

**Transplant command (cmd, run from the new project root)**

```bat
mkdir .scripts\lib 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\weekly_report_bat\weekly_report.bat" .scripts\weekly_report.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\weekly_report_bat\weekly_report.ps1" .scripts\weekly_report.ps1
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\common_bat\common.bat"                .scripts\lib\common.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat"  .scripts\project.env.bat
```

## Transplant checklist

```bat
test -f .scripts\weekly_report.bat   REM wrapper exists
test -f .scripts\weekly_report.ps1   REM companion exists; same folder as wrapper
test -f .scripts\lib\common.bat      REM env loader exists
test -f .scripts\project.env.bat     REM project identity set
.scripts\daily_report 2026-07-13     REM create at least one daily entry first
.scripts\weekly_report --no-codex --from 2026-07-13 --to 2026-07-13   REM template path works
.scripts\weekly_report --no-codex   REM default range (Mon-Sun) works
dir .scripts\reports\weekly          REM output markdown was written
```

See also: `daily_report.bat` (produces the input), `common.bat` (env loader),
`monthly_report.bat` + `monthly_report.ps1` (next-step aggregation).