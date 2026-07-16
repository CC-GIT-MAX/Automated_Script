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

- Categorized repository sources under `01_Build_Automation`, `02_Template_Management`, `03_Helper_Libraries`, `04_File_Watcher`, and `05_Documentation`
- `06_Project_Examples/YTM32B1MD1_FlexCAN/project.env.bat` as the starter configuration

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

## Dependency manifest (transplant this script by copying)

`new_project.bat` is a **distribution bootstrapper** -- by definition it reads
the entire repository. There is no "small bundle" for this script: copying it
alone makes no sense. Instead, the script IS the bundle.

To transplant this script into a different shared-template location (for
example, to mirror it into another machine's `D:\templates\`), copy the whole
`Automated_Script_Summary/` tree. The bootstrap is intentionally driven by
the on-disk layout of this repo.

| Slot | Source in this repo | Notes |
|---|---|---|
| Entry script | `02_Template_Management/new_project_bat/new_project.bat` | Resolves all other paths via `%~dp0` and `..\..` |
| Required template sources (verified at run-time) | see list below | Missing files cause `[ERROR] Required template file missing` and exit 1 |

**Files this script reads from the template (per the script's own constants)**

| Template source path (relative to repo root) | Deployed destination in target project |
|---|---|
| `01_Build_Automation/build_bat/build.bat` | `.scripts\build.bat` |
| `01_Build_Automation/fix_build_bat/fix_build.bat` | `.scripts\fix_build.bat` |
| `03_Helper_Libraries/common_bat/common.bat` | `.scripts\lib\common.bat` |
| `02_Template_Management/daily_report_bat/daily_report.bat` | `.scripts\daily_report.bat` |
| `02_Template_Management/weekly_report_bat/weekly_report.bat` | `.scripts\weekly_report.bat` |
| `02_Template_Management/weekly_report_bat/weekly_report.ps1` | `.scripts\weekly_report.ps1` |
| `02_Template_Management/monthly_report_bat/monthly_report.bat` | `.scripts\monthly_report.bat` |
| `02_Template_Management/monthly_report_bat/monthly_report.ps1` | `.scripts\monthly_report.ps1` |
| `04_File_Watcher/auto_build_watcher_ps1/auto_build_watcher.ps1` | `.scripts\auto_build_watcher.ps1` |
| `02_Template_Management/update_bat/update.bat` | `.scripts\update.bat` |
| `06_Project_Examples/YTM32B1MD1_FlexCAN/project.env.bat` | `.scripts\project.env.bat` (only if not already present) |
| `05_Documentation/AGENTS_md/AGENTS.md` | project-root `AGENTS.md` (only if not already present) |

**External tool dependencies**

| Tool | Version / how to verify | Used for |
|---|---|---|
| `cmd.exe` | Windows default | Script host, `xcopy`, `choice`, `findstr` |

**Transplant command (PowerShell, run from the new shared-template root)**

```powershell
# Mirror the whole repo to a new location
Copy-Item -Path "D:\working_file\WorkSpace\scripts\Automated_Script_Summary" `
          -Destination "D:\new-template-location\" -Recurse -Force
```

The bootstrap target (the new project) is not part of the "bundle" -- it is
created by running this script against the target.

## Transplant checklist

```bat
REM 1. Verify all 12 template sources exist in the shared repo
for %%F in (
    "01_Build_Automation\build_bat\build.bat"
    "01_Build_Automation\fix_build_bat\fix_build.bat"
    "03_Helper_Libraries\common_bat\common.bat"
    "02_Template_Management\daily_report_bat\daily_report.bat"
    "02_Template_Management\weekly_report_bat\weekly_report.bat"
    "02_Template_Management\weekly_report_bat\weekly_report.ps1"
    "02_Template_Management\monthly_report_bat\monthly_report.bat"
    "02_Template_Management\monthly_report_bat\monthly_report.ps1"
    "04_File_Watcher\auto_build_watcher_ps1\auto_build_watcher.ps1"
    "02_Template_Management\update_bat\update.bat"
    "06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat"
    "05_Documentation\AGENTS_md\AGENTS.md"
) do (
    if not exist "%%~F" echo MISSING %%~F
)

REM 2. Smoke-test the bootstrap on a scratch project
mkdir C:\bootstrap-smoke
cd C:\bootstrap-smoke
"D:\path\to\repo\02_Template_Management\new_project_bat\new_project.bat"
dir .scripts                                  REM entry, helper, env present
type .gitignore | findstr "project.env.bat"    REM gitignore line present
```

See also: `update_scripts.bat` (re-applies the same file list to existing
projects), every entry in `01_Build_Automation/` and `02_Template_Management/`
(they are the files this script distributes).