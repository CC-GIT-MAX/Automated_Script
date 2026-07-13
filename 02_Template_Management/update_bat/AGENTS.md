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