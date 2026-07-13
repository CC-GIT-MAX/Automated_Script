# AGENTS.md -- fix_build.bat

## What it does

Compile-fix auto loop. Calls `build.bat`. If the build fails, invokes Codex CLI
to read the latest log and propose a one-file-at-a-time fix. Repeats until the
build passes or `MAX_RETRY` attempts are exhausted.

This is the script that **replaces the old workflow of pasting build errors
into Codex Desktop manually**.

## How to call it

```bat
.scripts\fix_build.bat              REM up to 5 fix attempts (default)
.scripts\fix_build.bat 3            REM up to 3 attempts
.scripts\fix_build.bat 8            REM up to 8 attempts
```

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Build passed (within retry budget) |
| 1 | Max retry exhausted, build still failing |
| 2 | `codex` command not found in PATH |
| 3 | Config error (missing `project.env.bat`, `build.bat`, etc.) |

## Inputs

- `.scripts\build.bat` -- the actual build script
- `.scripts\project.env.bat` -- config (read indirectly via `build.bat`)

## Outputs

- `build_logs/build_*.log` -- build logs (written by `build.bat`)
- Codex's fix output (printed to stdout, may include file diffs)
- Final exit code (see above)

## Dependencies

- `.scripts\build.bat` (must exist)
- `codex` CLI on PATH
- Codex sandbox must be able to write to `<PROJECT_ROOT>` (uses
  `-C <PROJECT_ROOT> -s workspace-write`)

## How Codex is called

```
codex exec --skip-git-repo-check -C "<PROJECT_ROOT>" -s workspace-write ^
  "Read the IAR build log at <LOG_PATH>. Project is <PROJECT_NAME> on MCU <MCU_FAMILY>.
   Fix the compile errors following AGENTS.md rules. Constraints: do not modify
   startup_*.s / startup_*.c; do not modify *.icf / *.sct linker scripts; do not
   modify .ewp / .eww project files; change at most 1 file per cycle; do not commit;
   print final git diff summary."
```

The prompt's hard constraints (no startup/icf/ewp, max 1 file, no commit) are the
**second line of defense** -- the sandbox restricts writes to the workspace, and
the prompt further restricts what Codex can touch.

## Known issues

- Codex may "fix" something you don't want fixed. Review the diff in
  `.scripts\build_logs\` and `git diff` after each successful run.
- If Codex hits rate limits, it will return non-zero. The script continues to
  retry the build (in case the partial fix already worked), which is intentional.
- The prompt is one-size-fits-all. For project-specific constraints, edit the
  prompt in this file (see the "Customizing the Codex prompt" section below).

## Customizing the Codex prompt

Open this script in a text editor and find the `codex exec ... ^` line. The
multi-line string after it is the prompt. You can add project-specific
constraints, e.g.:

```
"Do not modify anything under driver/can/ (CAN stack is being reviewed separately).
 Do not change pin_mux.c (board-specific, hardware-verified)."
```

## Future work

- Add `--dry-run` mode that asks Codex for a fix plan but does not apply it
- Add `--show-diff` that prints the diff even on success
- Add metric logging: how many attempts per fix, success rate over time