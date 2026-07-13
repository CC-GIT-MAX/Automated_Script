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