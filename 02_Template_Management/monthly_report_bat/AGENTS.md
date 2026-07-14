# AGENTS.md -- monthly_report.bat

## What it does

Thin batch wrapper that invokes the companion `monthly_report.ps1` PowerShell
script. Synthesizes a **monthly** management report by feeding both the daily
and weekly reports in a date range to Codex CLI. Falls back to a manual
template if Codex is unavailable or fails.

## How to call it

```bat
.scripts\monthly_report                          REM this month
.scripts\monthly_report 2026-07                  explicit month (YYYY-MM)
.scripts\monthly_report --from 2026-07-01 --to 2026-07-31   explicit range
.scripts\monthly_report --no-codex               skip Codex, manual template only
```

When given `2026-07`, the script auto-computes `--from 2026-07-01` and
`--to 2026-07-31` (handles 28/29/30/31-day months correctly via
PowerShell `AddMonths(1).AddDays(-1)`).

## Files in this directory

| File | Purpose |
|---|---|
| `monthly_report.bat` | Batch wrapper (you call this) |
| `monthly_report.ps1` | PowerShell script (does the real work) |
| `AGENTS.md` | This file |

## Why a PowerShell companion?

Same reason as `weekly_report.bat`: the pure-batch version had serious
parser issues (nested `if / for / goto` inside `>` redirect blocks).
PowerShell is more reliable for this kind of work.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | success |
| 3 | invalid date argument |
| 99 | common.bat loader failed |
| other | error from PowerShell |

## Inputs

- `.scripts\project.env.bat` (via `lib\common.bat`)
- `.scripts\reports\daily\*.md` (mandatory for content)
- `.scripts\reports\weekly\*.md` (optional, included if available)
- `YYYY-MM` argument, or `--from` / `--to`

## Outputs

- `.scripts\reports\monthly\monthly_YYYY-MM.md`

## Data flow

```
daily/*.md  --+                              +-- output.md (header + body)
              |                              |
weekly/*.md --+--> monthly_report.ps1 --(codex or manual template)--> +-- ## Source: (raw entries appended)
```

## How Codex is called

```
codex exec --skip-git-repo-check -C <PROJECT_ROOT> -s workspace-write ^
  -c model="gpt-5.1" ^
  "Read the file at <TMP_INPUT> and synthesize a monthly report in Markdown.
   Write ONLY the synthesized report to stdout..."
```

The expected headings are: `Executive Summary`, `Major Accomplishments`,
`In-Progress Initiatives`, `Blockers and Risks`, `Statistics`,
`Trends and Observations`, `Plan for Next Month`.

## Fallback behavior

Same as `weekly_report.bat`: if Codex is unavailable, returns non-zero, or
produces no output, the script writes a manual template with placeholders.
The report is still usable -- just not synthesized.

## Known issues

- If neither daily nor weekly reports exist in the range, the manual
  template is generated but is empty. The script does NOT abort.
- The `## Source: Weekly Reports` section may contain entries that overlap
  with the daily entries (since weekly reports include daily content).
  Edit the file to trim before sharing.
- Monthly range is determined by the **server's local timezone**, not the
  project's timezone. If you travel across time zones, pass `--from` /
  `--to` explicitly.

## Editing the .ps1

If you need to change the prompt, the section headings, or the
synthesis behavior, edit `monthly_report.ps1`. The batch wrapper does
not need to change.

## Future work

- Auto-generate trend charts from the Statistics section
- Add `--no-source` flag to skip the raw-entry append for cleaner sharing
- Add a project-comparison mode that generates a multi-project monthly roll-up