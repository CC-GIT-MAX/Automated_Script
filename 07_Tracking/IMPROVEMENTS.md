# IMPROVEMENTS.md -- Future enhancement ideas

> These are ideas, not commitments. When an idea becomes a real plan, move it
> to `TODO.md` and start working on it.

## Multi-project orchestration

- A single dashboard that lists all projects using these scripts, their
  current build status (last log), and lets you trigger `fix_build.bat` remotely
- Probably needs a shared state file or a small web service

## Smarter Codex integration

- Currently Codex gets a one-shot prompt per attempt. A persistent session
  with `codex exec resume` could give better continuity
- Add a `--mode=plan` flag that asks Codex for a fix plan first, then
  confirms with the user before applying

## Test infrastructure

- The scripts have no automated tests. A `tests/` folder with:
  - `test_common.bat` -- verify `project.env.bat` parsing edge cases
  - `test_compare_hash.ps1` -- verify hash function correctness
  - `test_update_scripts.bat` -- run update against a fake project, verify
    backup/apply behavior
- Would need a mock IAR project (a `.ewp` file that just echoes success/failure)

## Configuration as code

- Currently `project.env.bat` is a hand-edited file. Could be auto-generated
  by scanning the IAR project file (`.ewp` is XML) and extracting:
  - Defined symbols
  - Include paths
  - Config names
- Would make `new_project.bat` one step easier

## Performance

- `compare_hash.ps1` is called per file (~200ms overhead each). For projects
  with many tracked files, cache the hashes in a sidecar `.sha256` file
  and only re-hash when mtime changes

## Cross-platform support

- Currently Windows-only (cmd batch + IAR). A WSL/Linux port would need:
  - Shell scripts instead of `.bat`
  - gcc-arm-none-eabi instead of IAR
  - POSIX `find` instead of PowerShell FileSystemWatcher

## Documentation

- Generate a `MANIFEST.md` listing every file and its purpose
- Auto-generate a script index from per-script AGENTS.md frontmatter
- Add a "Quick reference card" (one-page printable summary)

## User experience

- PowerShell module wrapping all scripts (`Import-Module CodexIAR`)
- Bash/Zsh completion for the script names
- A simple TUI menu to choose which action to run

## Reporting

- Aggregate build stats across projects: success rate, common error types,
  average fix attempts
- Feishu/Lark weekly report (see TODO.md P1)
- Slack/Feishu notification on build success/failure

## Codex-specific

- Auto-update the Codex prompt library when OpenAI ships a new model
  with new capabilities
- Add a `--explain` flag to scripts that prints the Codex prompt they would
  use, without actually calling Codex