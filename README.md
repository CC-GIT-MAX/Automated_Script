# Automated Script Summary

Centralized, version-controlled home for the Codex-automation scripts used
across embedded (IAR) and other projects.

## Quick links

- **[AGENTS.md](AGENTS.md)** -- master rulebook (read first)
- **[_REPOSITORY_STRUCTURE.md](_REPOSITORY_STRUCTURE.md)** -- how the repo is organized, how to add new scripts
- **[_tracking/TODO.md](_tracking/TODO.md)** -- pending tasks
- **[_tracking/IMPROVEMENTS.md](_tracking/IMPROVEMENTS.md)** -- future ideas
- **[_tracking/CHANGELOG.md](_tracking/CHANGELOG.md)** -- history
- **[MANIFEST.md](MANIFEST.md)** -- file index

## What''s in here

```
Automated_Script_Summary/
|-- AGENTS.md                       (master rulebook)
|-- README.md                       (this file)
|-- MANIFEST.md                     (file index)
|-- _REPOSITORY_STRUCTURE.md        (how the repo is organized)
|
|-- 01_Build_Automation/            (build.bat, fix_build.bat)
|-- 02_Template_Management/         (new_project.bat, update_scripts.bat, update.bat)
|-- 03_Helper_Libraries/            (common.bat, compare_hash.ps1)
|-- 04_File_Watcher/                (auto_build_watcher.ps1)
|-- 05_Documentation/               (AGENTS.md template, README, prompt library)
|-- 06_Project_Examples/            (YTM32B1MD1 FlexCAN reference)
|
`-- _tracking/                      (TODO, IMPROVEMENTS, CHANGELOG)
```

Numbered folders (`01_` to `06_`) are **script categories**. Underscore-prefixed
folders (`_tracking`, `_REPOSITORY_STRUCTURE`) are **meta**. See
[_REPOSITORY_STRUCTURE.md](_REPOSITORY_STRUCTURE.md) for the full naming scheme.

Every subdirectory has its own `AGENTS.md` with script-specific rules.

## How this repo is used

This is a **summary, governance, and distribution** repo, not a runtime one.
The actual scripts get deployed into other projects'' `.scripts\` folders by
running `new_project.bat` or `update.bat`.

If you''re setting up automation in a new project, see the
[05_Documentation/README_md/README.md](05_Documentation/README_md/README.md)
for a step-by-step guide.

## Adding new scripts

See [_REPOSITORY_STRUCTURE.md](_REPOSITORY_STRUCTURE.md). TL;DR:

1. Pick the right category (01-06, or create 07+ for a new one)
2. Put the script in `<category>/<script_name>_<ext>/`
3. Add `AGENTS.md` in the same folder
4. Update `_tracking/CHANGELOG.md`
5. If the script is part of the bootstrap flow, update `new_project.bat` and
   `update_scripts.bat`

## Git workflow

```bash
git status                    # see what changed
git add -A                    # stage everything
git commit -m "Describe change"
git push origin main
```

Before pushing, check:
- [ ] `_tracking/CHANGELOG.md` has a row for today''s change
- [ ] `_tracking/TODO.md` items you completed are moved to CHANGELOG.md
- [ ] Any per-script AGENTS.md updates match the script changes
- [ ] Per-script AGENTS.md follows the 6-section convention

## Repository details

- **Remote**: `git@github.com-personal:CC-GIT-MAX/Automated_Script.git`
- **Local path**: `D:\working_file\WorkSpace\scripts\Automated_Script_Summary`
- **Created**: 2026-07-13