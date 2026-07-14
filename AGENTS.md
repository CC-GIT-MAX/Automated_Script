# AGENTS.md -- Automated Script Summary (ROOT)

> This file is the **master** set of rules for all scripts in this repository.
> Each script subdirectory has its **own** `AGENTS.md` with rules specific to that script.
> When in doubt: root AGENTS.md is the baseline; per-script AGENTS.md adds specifics.

## Repository Purpose

This repository is the **summary, version control, and governance** point for all the
Codex-automation scripts used across embedded (IAR) and other projects. The scripts
themselves are organized into the following top-level folders:

| Folder | Purpose |
|---|---|
| `01_Build_Automation/` | Per-project build + compile-fix scripts (deployed to `.scripts\` in each project) |
| `02_Template_Management/` | Bootstrap new projects, sync updates from this template |
| `03_Helper_Libraries/` | Shared `.bat` and `.ps1` helpers used by the above |
| `04_File_Watcher/` | PowerShell scripts that auto-build on file save |
| `05_Documentation/` | `AGENTS.md` templates, prompt library, fill-in checklist |
| `06_Project_Examples/` | A working example showing all scripts in action (YTM32B1MD1 FlexCAN) |
| `_tracking/` | `TODO.md`, `IMPROVEMENTS.md`, `CHANGELOG.md` (the underscore prefix marks it as meta, not a script) |

> **For how the repository is organized and how to add new scripts/categories, see
> [`_REPOSITORY_STRUCTURE.md`](_REPOSITORY_STRUCTURE.md).** That file is the source of
> truth for "where do I put this new script?" questions.

## Tracking (read this first)

- **`_tracking/TODO.md`** -- pending tasks, ordered by priority
- **`_tracking/IMPROVEMENTS.md`** -- ideas for future enhancements
- **`_tracking/CHANGELOG.md`** -- dated log of what changed in this repo
- **`_tracking/PITFALLS.md`** -- known failures and mandatory prevention rules

Before adding a new script, **check TODO.md and IMPROVEMENTS.md** to see if it''s already
planned. When you finish a task, **move it from TODO.md to CHANGELOG.md**.

## Universal Script Rules (apply to ALL scripts in this repo)

These rules are non-negotiable. They were learned from real bugs during development
(see CHANGELOG.md for the full list of "lessons learned").

### 1. Encoding & Output

- First line of every `.bat` script MUST be `chcp 65001 > nul` (UTF-8 output)
- Use **ASCII-only** output in scripts (English). Non-ASCII / Chinese goes in
  `AGENTS.md` and `README.md`, never in script output. Reason: cmd code page
  mismatches garble non-ASCII bytes.
- File encoding MUST be **ASCII (no BOM)**. If using PowerShell to write `.bat`
  files, use `-Encoding ascii` (not `-Encoding utf8` which adds BOM and breaks
  cmd parsing).

### 2. Script Architecture

- Use `goto :LABEL` + a **single** `exit /b` at the end. Do NOT use `exit /b`
  inside `if () (...)` blocks. Reason: chcp 65001 + nested `if` + `exit` causes
  parser errors like `''. was unexpected at this time.''`.
- All scripts that read configuration MUST load it from `project.env.bat` via
  `call "%~dp0lib\common.bat"`. Reason: `call project.env` (without `.bat`) silently
  does nothing because cmd only executes files with `.bat`/`.cmd` extensions.
- Project-specific configuration (paths, MCU family, project name) lives in
  `project.env.bat`. This file is **gitignored** in any project that uses these
  scripts, because it may contain absolute paths and project secrets.

### 3. Shell Tooling Quirks

These are cmd / PowerShell quirks we hit during development. The fixes are baked
into the scripts already -- don''t reintroduce the old patterns.

- **Never** use `for %%F in (...)` with `%%~pF` (path-only expansion). It strips
  the drive letter, breaking any `if` path comparisons. Use **explicit file lists**
  with variables (see `update_scripts.bat` for the pattern).
- **Never** use `fc /B ... >nul 2>&1` followed by `if errorlevel 1` inside a
  `for (...)` block. The errorlevel doesn''t propagate reliably. Use a PowerShell
  helper (`compare_hash.ps1`) and capture output via a temp file.
- **Never** use `for /f "usebackq"` with `powershell` inside the backticks. The
  sub-cmd shell does not inherit PATH and produces
  `The system cannot find the file powershell.` errors. Use a plain
  `powershell ... > tmp.txt` invocation and read the temp file with `set /p`.
- **Never** use `wmic` to get timestamps. Win10 22H2+ deprecated it and it
  intermittently returns empty strings. Use `powershell -Command "(Get-Date).ToString(''...'')"` instead.
- **Never** use `Get-FileHash` directly in scripts. It''s missing in some
  PowerShell 5.1 environments. Use the .NET
  `[System.Security.Cryptography.SHA256]` class directly.
- **Never** use `sub-routine :label` (`call :label`) inside a `for (...)` block.
  cmd''s parser can''t find the label. Inline the logic instead.

### 4. Codex Integration

- Codex CLI invocation MUST be `codex exec --skip-git-repo-check -C "<PROJECT_ROOT>" -s workspace-write ...`
  - `exec` -- non-interactive mode (interactive mode requires a TTY)
  - `--skip-git-repo-check` -- allows running outside a git repo
  - `-C` -- sets the working root (so the sandbox covers the full project)
  - `-s workspace-write` -- lets Codex edit source files
- Codex prompt for compile-fix must include hard constraints:
  - "Do not modify startup_*.s / startup_*.c"
  - "Do not modify *.icf / *.sct linker scripts"
  - "Do not modify .ewp / .eww project files"
  - "Change at most 1 file per cycle"
  - "Do not commit"
- Never use the top-level `codex` command in automation -- it needs a TTY.

### 5. Safety Guarantees (must hold for any "modifies files" script)

- **Never** overwrite `project.env.bat` automatically (per-project config).
- **Always** back up files before overwriting in `.scripts\backup\<timestamp>\`.
- **Always** have a dry-run mode (default) and an `--apply` flag.
- **Never** delete files that exist in the project but not in the template.

## Per-script AGENTS.md convention

Each script directory MUST contain its own `AGENTS.md` with:
1. **What it does** -- 1-2 sentence summary
2. **How to call it** -- exact command syntax, with examples
3. **Inputs / outputs** -- what files it reads/writes
4. **Dependencies** -- which other scripts/helpers it calls
5. **Known issues** -- what doesn''t work yet, and workarounds
6. **Future work** -- what''s planned but not done

The root `AGENTS.md` (this file) is the rulebook. Per-script `AGENTS.md` is the
manual page. Read both.

## How to add a new script (summary)

For full details, see [`_REPOSITORY_STRUCTURE.md`](_REPOSITORY_STRUCTURE.md).

1. **Plan it**: open an issue in GitHub, or add an entry to `_tracking/TODO.md`
2. **Decide category**: which top-level folder does it belong in? (See table above.)
3. **Write the script** following all the rules in this file
4. **Add `AGENTS.md`** in the script''s directory following the convention above
5. **Add a row** to `_tracking/CHANGELOG.md` (dated)
6. **If it changes the bootstrap** (new file copied by `new_project.bat`):
   - Update `02_Template_Management/new_project_bat/new_project.bat`
   - Update `02_Template_Management/update_scripts_bat/update_scripts.bat` to
     add the new file to the explicit sync list
7. **Commit + push** to the remote

## Git workflow

```bash
git add -A
git commit -m "Add <script_name>: <one-line summary>"
git push origin main
```

Before committing, ALWAYS:
- Run a smoke test if the change touches any per-project script
- Check `git diff` to verify only intended files changed
- Update `_tracking/CHANGELOG.md`

## Pointers

- **`_REPOSITORY_STRUCTURE.md`** -- how the repo is organized, how to add new scripts
- **`README.md`** -- user-facing quick start
- **`MANIFEST.md`** -- file index
- **`05_Documentation/05_Documentation_AGENTS.md`** -- docs folder overview
- **`05_Documentation/README_md/README.md`** -- the canonical README for the template
- **`05_Documentation/AGENTS_md/AGENTS.md`** -- the per-project AGENTS.md template
- **`05_Documentation/codex_prompt_library/codex_prompt_library.md`** -- all Codex
  prompts we use
- **`05_Documentation/fill_in_checklist/AGENTS_FILL_IN_CHECKLIST.md`** -- checklist
  for filling in `project.env.bat` and `AGENTS.md` placeholders
- **`_tracking/TODO.md`** -- pending tasks
- **`_tracking/IMPROVEMENTS.md`** -- future enhancements
- **`_tracking/CHANGELOG.md`** -- change history
- **`_tracking/PITFALLS.md`** -- mandatory lessons learned before script changes

---

**Last updated**: 2026-07-14
**Maintainer**: see git log
