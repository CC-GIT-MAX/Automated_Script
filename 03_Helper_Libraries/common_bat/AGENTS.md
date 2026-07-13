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