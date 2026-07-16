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
## Dependency manifest (transplant this script by copying)

`auto_build_watcher.ps1` runs **inside** the target project (it is not a
shared-repo utility). It calls `.scripts\build.bat` and, on user confirmation,
`.scripts\fix_build.bat`. Transplant the whole automation stack, not just this
file.

| Slot | Source in this repo | Runtime path in target project |
|---|---|---|
| Entry script | `04_File_Watcher/auto_build_watcher_ps1/auto_build_watcher.ps1` | `<PROJECT_ROOT>\.scripts\auto_build_watcher.ps1` |
| Calls `build.bat` (REQUIRED) | `01_Build_Automation/build_bat/build.bat` | `<PROJECT_ROOT>\.scripts\build.bat` |
| Optionally calls `fix_build.bat` (REQUIRED for fix prompt) | `01_Build_Automation/fix_build_bat/fix_build.bat` | `<PROJECT_ROOT>\.scripts\fix_build.bat` |
| Env loader (REQUIRED, transitively) | `03_Helper_Libraries/common_bat/common.bat` | `<PROJECT_ROOT>\.scripts\lib\common.bat` |
| Project config (REQUIRED, transitively) | `06_Project_Examples/YTM32B1MD1_FlexCAN/project.env.bat` | `<PROJECT_ROOT>\.scripts\project.env.bat` |

**External tool dependencies**

| Tool | Version / how to verify | Used for |
|---|---|---|
| PowerShell | 5.0+ (`System.IO.FileSystemWatcher` and event handlers) | The watcher process itself |
| `codex` CLI | `where codex` | Only used if the user accepts the fix prompt |
| IAR toolchain | Same as `build.bat` | Indirect, via `build.bat` |

**Transplant command (cmd, run from the new project root)**

```bat
REM 1. Copy the watcher entry point
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\04_File_Watcher\auto_build_watcher_ps1\auto_build_watcher.ps1" .scripts\auto_build_watcher.ps1

REM 2. Copy the build + fix scripts it will call (each with its OWN dependency chain)
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\01_Build_Automation\build_bat\build.bat"     .scripts\build.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\01_Build_Automation\fix_build_bat\fix_build.bat" .scripts\fix_build.bat
mkdir .scripts\lib
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\common_bat\common.bat"     .scripts\lib\common.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat" .scripts\project.env.bat
```

The recommended path is to use `new_project.bat` (or `update_scripts.bat`)
to install the whole automation stack, then start the watcher on top of it.

## Transplant checklist

```powershell
# 1. Watcher file present
Test-Path .\.scripts\auto_build_watcher.ps1

# 2. Build path the watcher will call works
cmd /c ".\.scripts\build.bat build"                    # exit 0

# 3. At least one default watched directory exists in the project
Test-Path .\app; Test-Path .\board; Test-Path .\platform
Test-Path .\middleware; Test-Path .\rtos               # any of these is enough

# 4. PowerShell version is new enough
$PSVersionTable.PSVersion                              # Major >= 5

# 5. Smoke run the watcher for 30s
powershell -NoProfile -ExecutionPolicy Bypass -File .\.scripts\auto_build_watcher.ps1
# Ctrl+C after 30s; confirm "Auto-build watcher started" banner printed
```

See also: `build.bat` (called on every save), `fix_build.bat` (called on
failure + user Y), `new_project.bat` (recommended installer for the whole stack).