# AGENTS.md -- auto_build_watcher.ps1

## What it does

PowerShell script that watches the source tree for `.c` / `.h` / `.cpp` / `.s`
file changes. On save, it automatically invokes `.scripts\build.bat build`.
On failure, it asks the user whether to invoke `.scripts\fix_build.bat` to
let Codex attempt a fix.

Eliminates the manual "save -> switch to terminal -> run build" loop.

## How to call it

From the project root, in a dedicated PowerShell window:

```powershell
.\.scripts\auto_build_watcher.ps1
```

Leave the window open. `Ctrl+C` to stop.

## Inputs

- Working directory must contain `.scripts\build.bat` and `.scripts\fix_build.bat`
- Watches these subdirectories (relative to project root):
  - `app/`, `board/`, `platform/`, `middleware/`, `rtos/`
  - Any missing directory is silently skipped

## Outputs

- Console output showing build status per save
- Same outputs as `build.bat` and `fix_build.bat`

## Behavior

| File event | Action |
|---|---|
| `.c` / `.h` / `.cpp` / `.s` saved | Wait 3s (debounce) -> run `build.bat` |
| Build succeeds | Log `[OK] Build succeeded` |
| Build fails | Prompt: `Invoke codex to fix? (y/N)` -> if Y, run `fix_build.bat 5` |

## Dependencies

- PowerShell 5.0+ (uses `System.IO.FileSystemWatcher`)
- `.scripts\build.bat` (must exist)
- `.scripts\fix_build.bat` (optional, only needed for the fix prompt)

## Known issues

- **Many editors fire multiple save events** (write to temp, rename to target).
  We debounce with 3s, but very fast typists may still get extra builds.
- **File paths with special characters** may confuse the watcher. Test with
  your typical source paths.
- **Large trees** (10000+ files) may slow down the watcher. We use recursive
  watching but only on known subdirectories.
- **Network drives** are unreliable with FileSystemWatcher. Local SSD/NVMe
  recommended.

## Future work

- Add a `--no-fix-prompt` flag that auto-runs `fix_build.bat` on failure
- Add a `--watch=path1,path2` flag for custom watch paths
- Support git status check (only build if there are uncommitted changes)
- Add a status bar / system tray icon