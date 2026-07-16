# AGENTS.md -- common.bat

## What it does

Shared helper loaded by `build.bat` and `fix_build.bat`. Reads
`project.env.bat` (which must end in `.bat`, not `.env` -- see Known issues),
sets defaults for missing variables, and normalizes the `PROJECT_ROOT` path
so it does not contain `\..\` segments.

## How to call it

From any `.bat` script that needs the project config:

```bat
call "%~dp0lib\common.bat"
if errorlevel 1 exit /b 99
```

After this call, the following variables are available:

| Variable | Source | Default |
|---|---|---|
| `PROJECT_ROOT` | normalized absolute path | required |
| `IAR_BIN` | required | -- |
| `IAR_PROJECT_FILE` | required | -- |
| `IAR_CONFIG` | required | -- |
| `IAR_PROJECT_SUBPATH` | optional | none |
| `IAR_PROJECT_PATH` | computed: `PROJECT_ROOT\IAR_PROJECT_SUBPATH\IAR_PROJECT_FILE` | -- |
| `PROJECT_NAME` | optional | filename without `.ewp` |
| `MCU_FAMILY` | optional | `UNSPECIFIED` |
| `BOARD_NAME` | optional | `UNSPECIFIED` |
| `LOG_DIR` | optional | `build_logs` |
| `LOG_DIR_ABS` | computed: `PROJECT_ROOT\LOG_DIR` | -- |

## Inputs

- `project.env.bat` at `<PROJECT_ROOT>\.scripts\project.env.bat`

## Outputs

- Environment variables (see table above)
- Exit code 99 if `project.env.bat` is missing or has required vars unset
- Exit code 0 on success (and the second+ call is a no-op, setting
  `PROJECT_ENV_LOADED=1`)

## Dependencies

None (standalone .bat helper).

## Known issues

- **Why `.env.bat` and not `.env`?** cmd does NOT execute `set` statements in
  files with non-standard extensions. A `call project.env` silently does
  nothing because cmd treats `.env` as data. The `.bat` suffix is required.
- The `pushd` / `popd` for path normalization relies on the current drive.
  On UNC paths (\\server\share) this may not work.

## Future work

- Cache the parsed env in a temp file to avoid re-parsing on every script call
- Support multiple env files (e.g. `project.env.bat` + `local.env.bat` for
  developer-specific overrides)
## Dependency manifest (transplant this script by copying)

`common.bat` is a leaf helper -- it depends on **no other repo file**, but
every other script depends on it.

| Slot | Source in this repo | Runtime path in target project |
|---|---|---|
| Helper script | `03_Helper_Libraries/common_bat/common.bat` | `<PROJECT_ROOT>\.scripts\lib\common.bat` |
| Project config (REQUIRED at runtime) | `06_Project_Examples/YTM32B1MD1_FlexCAN/project.env.bat` (template) | `<PROJECT_ROOT>\.scripts\project.env.bat` (per-project) |

**External tool dependencies**

| Tool | Version / how to verify | Used for |
|---|---|---|
| `cmd.exe` | Windows default | `pushd` / `popd` for path normalization; `call` to load env |

**Transplant command (cmd, run from the new project root)**

```bat
REM common.bat lives at .scripts\lib\common.bat relative to PROJECT_ROOT.
REM Any caller that does `call "%~dp0lib\common.bat"` expects this exact path.
mkdir .scripts\lib 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\common_bat\common.bat" .scripts\lib\common.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat" .scripts\project.env.bat
```

`common.bat` alone is not directly callable -- it is only useful when **some
other** script does `call "%~dp0lib\common.bat"`. Transplant it together with
at least one caller (e.g. `build.bat`).

## Transplant checklist

```bat
REM 1. Helper exists at the path callers expect
test -f .scripts\lib\common.bat

REM 2. Config file present
test -f .scripts\project.env.bat

REM 3. Sample caller works
.scripts\build.bat build                              REM exit 0 if common.bat is wired correctly

REM 4. Required env vars are set
type .scripts\project.env.bat | findstr /C:"IAR_BIN"   REM at least the required fields are present
```

See also: `build.bat`, `fix_build.bat`, `daily_report.bat`, `weekly_report.bat`,
`monthly_report.bat` -- every one of them loads `common.bat` as its first step.