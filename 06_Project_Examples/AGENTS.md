# AGENTS.md -- 06_Project_Examples

This folder shows what a **fully set up** project looks like after running
`new_project.bat` and filling in the configuration.

## Subfolders

- `YTM32B1MD1_FlexCAN/` -- Yuntu Microelectronics YTM32B1MD1, FlexCAN Wakeup
  Demo. The reference project used to develop and test all scripts.

## How to use these examples

- Compare your project to this one to see if all files are in place
- Use as a sanity check: does the layout match? Are the env variables set?
- When reporting a bug, mention which example project reproduces it

## Files in the example

```
YTM32B1MD1_FlexCAN/
|-- build.bat              # copy of template
|-- fix_build.bat          # copy of template
|-- project.env.bat        # actual config (YTM32 paths)
`-- lib/
    `-- common.bat         # copy of template
```

This is the **minimum** set. A real project also has `AGENTS.md` and
`build_logs/` (created on first build).