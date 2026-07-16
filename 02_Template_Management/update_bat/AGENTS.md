# AGENTS.md -- update.bat (project-local wrapper)

## What it does

A project-local wrapper that knows where the template lives and calls
`update_scripts.bat` with the project''s CWD. This avoids requiring users to
type the template''s full path every time.

## How to call it

From the project root:

```bat
.scripts\update                  REM dry-run
.scripts\update --apply          REM apply changes
.scripts\update --no-backup      REM skip backup
```

## Inputs

None directly -- all config is at the top of the file:

```bat
set "TEMPLATE_DIR=C:\path\to\template"
```

You **must edit this line once** after running `new_project.bat`, so the
wrapper points at your local template.

## Outputs

Same as `update_scripts.bat` (it just forwards the call).

## Dependencies

- `update_scripts.bat` at `%TEMPLATE_DIR%\update_scripts.bat`
- `project.env.bat` indirectly (the project must be set up already)

## Known issues

- The `TEMPLATE_DIR` is a **per-machine** setting, not a per-project one.
  If you share the project via git, the `update.bat` file might have someone
  else''s path. Re-edit it on each machine.
- The wrapper does no validation of `TEMPLATE_DIR`. If the path is wrong,
  the user gets a generic `[ERROR] Template not found`.

## Future work

- Add a `[FILL: path to template]` placeholder that''s easier to grep for
- Use a project-level config file instead of hard-coding in the script
## Dependency manifest (transplant this script by copying)

`update.bat` is a tiny per-project wrapper whose only job is to point at
`update_scripts.bat` on a specific machine. It is the simplest bundle in the
repository.

| Slot | Source in this repo | Runtime path in target project |
|---|---|---|
| Entry script | `02_Template_Management/update_bat/update.bat` | `<PROJECT_ROOT>\.scripts\update.bat` |
| Target it calls (REQUIRED) | `02_Template_Management/update_scripts_bat/update_scripts.bat` | `<TEMPLATE_DIR>\update_scripts.bat` (anywhere on disk; path is hard-coded in `update.bat`) |

**External tool dependencies**

| Tool | Version / how to verify | Used for |
|---|---|---|
| `cmd.exe` | Windows default | Script host, `call`, `%*` argument forwarding |

**Transplant command (cmd, run from the new project root)**

```bat
REM 1. Copy the wrapper
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\update_bat\update.bat" .scripts\update.bat

REM 2. Edit TEMPLATE_DIR inside the file so it matches your machine
notepad .scripts\update.bat
```

Editing step is mandatory: the line `set "TEMPLATE_DIR=..."` inside the wrapper
contains a per-machine path.

## Transplant checklist

```bat
REM 1. Wrapper exists in the project
test -f .scripts\update.bat

REM 2. TEMPLATE_DIR was edited to a real folder
findstr /C:"TEMPLATE_DIR=" .scripts\update.bat          REM shows the path

REM 3. The pointed-at template file is reachable
if not exist "<TEMPLATE_DIR>\update_scripts.bat" (
    echo [ERROR] Template not found - re-edit TEMPLATE_DIR
)

REM 4. Dry-run forwarding works
.scripts\update                                       REM forwards to update_scripts.bat dry-run
.scripts\update --apply                               REM apply changes
```

See also: `update_scripts.bat` (the script this wrapper calls). Whenever you
move the shared template to a new path on this machine, edit `update.bat`'s
`TEMPLATE_DIR` line.