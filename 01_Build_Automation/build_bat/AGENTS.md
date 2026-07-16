# AGENTS.md -- build.bat

## What it does

Wraps `iarbuild` to compile an IAR project. Captures stdout+stderr to a
timestamped log file under `build_logs/`. Returns IAR's exit code.

## How to call it

From any project that has `.scripts\build.bat`:

```bat
.scripts\build.bat                  REM build with default mode (FLASH/Debug config)
.scripts\build.bat build            REM explicit build
.scripts\build.bat clean            REM clean intermediate files
.scripts\build.bat rebuild          REM clean + build
.scripts\build.bat make             REM incremental make
```

## Inputs

Reads `.scripts\project.env.bat` for:
- `IAR_BIN` -- full path to iarbuild.exe
- `IAR_PROJECT_SUBPATH` -- folder containing `.ewp`
- `IAR_PROJECT_FILE` -- `.ewp` filename
- `IAR_CONFIG` -- build configuration name (case-sensitive)
- `LOG_DIR` -- where to write logs (default: `build_logs`)

## Outputs

- `build_logs/<MODE>_<TIMESTAMP>.log` -- full IAR output
- exit code = IAR's exit code (0 = success, non-zero = failure)

## Dependencies

- `.scripts\project.env.bat` (config)
- `.scripts\lib\common.bat` (loads env, normalizes paths)
- IAR command-line build utility (`iarbuild.exe`)
- PowerShell (for timestamp)

## Known issues

- **IAR 9.x does not support `--log` flag** -- we use stdout/stderr redirect instead.
- **wmic is deprecated on Win10 22H2+** -- timestamp uses PowerShell `(Get-Date)`.
- Long paths (>260 chars) can fail on Win10 1709 and earlier.

## Future work

- Add GCC ARM toolchain support (replace `iarbuild` invocation, keep env pattern).
- Add a `--quiet` flag to suppress the script banner.
- Add colored output (green=OK, red=FAIL) via ANSI escape codes.
## Dependency manifest (transplant this script by copying)

To use `build.bat` in a new project, reproduce this on-disk layout and copy the
files below. After copying, run the **Transplant checklist** at the bottom.

| Slot | Source in this repo | Runtime path in target project |
|---|---|---|
| Entry script | `01_Build_Automation/build_bat/build.bat` | `<PROJECT_ROOT>\.scripts\build.bat` |
| Env loader (REQUIRED) | `03_Helper_Libraries/common_bat/common.bat` | `<PROJECT_ROOT>\.scripts\lib\common.bat` |
| Project config (per-project, gitignored) | `06_Project_Examples/YTM32B1MD1_FlexCAN/project.env.bat` (template only) | `<PROJECT_ROOT>\.scripts\project.env.bat` |

**External tool dependencies**

| Tool | Version / how to verify | Used for |
|---|---|---|
| `iarbuild.exe` | Path set in `IAR_BIN` of `project.env.bat` | Compile the IAR project |
| PowerShell | `powershell.exe` 5.1+ on Windows (default) | ASCII timestamp generation |
| `cmd.exe` | Windows default | Script host |

**Transplant command (cmd, run from the new project root)**

```bat
mkdir .scripts\lib 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\01_Build_Automation\build_bat\build.bat"        .scripts\build.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\common_bat\common.bat"      .scripts\lib\common.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat" .scripts\project.env.bat
```

Then edit `.scripts\project.env.bat` to fill in `IAR_BIN`, `IAR_PROJECT_SUBPATH`,
`IAR_PROJECT_FILE`, `IAR_CONFIG`, `PROJECT_NAME`, `MCU_FAMILY`.

## Transplant checklist

```bat
test -f .scripts\build.bat          REM entry script exists
test -f .scripts\lib\common.bat     REM helper exists
test -f .scripts\project.env.bat    REM config exists
type .scripts\project.env.bat       REM confirm IAR_BIN points to a real iarbuild.exe
.scripts\build.bat build            REM exit code MUST be 0
.scripts\build.bat clean            REM exit code MUST be 0
dir .scripts\build_logs             REM log dir was created
```

See also: `fix_build.bat` (calls this script), `common.bat` (helper loaded by this script).