# AGENTS.md -- new_project.bat

## What it does

Bootstraps a new project with the Codex automation scripts. Copies the core
scripts (build, fix_build, lib/) into a `.scripts\` folder in the target
project, creates a starter `project.env.bat` from the example, copies
`AGENTS.md`, and updates `.gitignore`.

## How to call it

From the root of the **new** project you want to set up:

```bat
C:\path\to\template\new_project.bat
```

If `.scripts\` already exists, you will be prompted:
```
[WARN] .scripts\ already exists. Files will be overwritten.
Continue? [Y,N]
```
Choose `Y` to overwrite, `N` to abort.

## Inputs

- The current working directory (the new project's root)
- The template directory (where this script lives)

## Outputs

In the new project:
- `.scripts\build.bat` -- copied from template
- `.scripts\fix_build.bat` -- copied from template
- `.scripts\lib\common.bat` -- copied from template
- `.scripts\lib\compare_hash.ps1` -- copied from template
- `.scripts\project.env.bat` -- created from `project.env.bat.example` (if not present)
- `.scripts\update.bat` -- copied from template
- `AGENTS.md` -- copied from template
- `.gitignore` -- updated to ignore `project.env.bat` and `build_logs\`

## Dependencies

- `template\build.bat`, `fix_build.bat`, `lib\`, `update.bat`, `AGENTS.md`
- `template\project.env.bat.example`

## What it does NOT do

- **Does not** edit `project.env.bat` for you. You must fill in paths
  (IAR_BIN, IAR_PROJECT_FILE, etc.) yourself.
- **Does not** fill in `AGENTS.md` `[FILL ...]` placeholders. See
  `05_Documentation/fill_in_checklist/AGENTS_FILL_IN_CHECKLIST.md`.
- **Does not** commit anything. You review and `git add` manually.

## Known issues

- If the target project uses a different `.gitignore` style (e.g. no trailing
  backslash on `build_logs\`), the append may look inconsistent. Edit the
  resulting `.gitignore` manually.
- The script uses Windows `xcopy` to copy `lib\` recursively, which may not
  be available on non-Windows shells. (We don't currently support bootstrapping
  from WSL or Git Bash; do it from cmd or PowerShell.)

## Future work

- Make idempotent: if `.scripts\project.env.bat` already exists, never overwrite
  (currently respects existing -- but other files are always overwritten).
- Add a `--dry-run` flag to show what would be copied.
- Add a `--no-gitignore` flag for projects without git.