# Automated Script Summary

Centralized, version-controlled home for the Codex-automation scripts used
across embedded (IAR) projects.

## Quick links

- **[AGENTS.md](AGENTS.md)** -- master rulebook (read first)
- **[07_Tracking/TODO.md](07_Tracking/TODO.md)** -- pending tasks
- **[07_Tracking/IMPROVEMENTS.md](07_Tracking/IMPROVEMENTS.md)** -- future ideas
- **[07_Tracking/CHANGELOG.md](07_Tracking/CHANGELOG.md)** -- history

## What's in here

```
Automated_Script_Summary/
|-- AGENTS.md                 (master rulebook)
|-- README.md                 (this file)
|-- 01_Build_Automation/      (build.bat, fix_build.bat)
|-- 02_Template_Management/   (new_project.bat, update_scripts.bat, update.bat)
|-- 03_Helper_Libraries/      (common.bat, compare_hash.ps1)
|-- 04_File_Watcher/          (auto_build_watcher.ps1)
|-- 05_Documentation/         (AGENTS.md template, README, prompt library)
|-- 06_Project_Examples/      (YTM32B1MD1 FlexCAN reference)
`-- 07_Tracking/              (TODO, IMPROVEMENTS, CHANGELOG)
```

Every subdirectory has its own `AGENTS.md` with script-specific rules.

## How this repo is used

This is a **summary, governance, and distribution** repo, not a runtime one.
The actual scripts get deployed into other projects'' `.scripts\` folders by
running `new_project.bat` or `update.bat`.

If you''re setting up automation in a new project, see the
[05_Documentation/README_md/README.md](05_Documentation/README_md/README.md)
for a step-by-step guide.

## Git workflow

```bash
git status                    # see what changed
git add -A                    # stage everything
git commit -m "Describe change"
git push origin main
```

Before pushing, check:
- [ ] `07_Tracking/CHANGELOG.md` has a row for today''s change
- [ ] `07_Tracking/TODO.md` items you completed are moved to CHANGELOG.md
- [ ] Any per-script AGENTS.md updates match the script changes

## Repository details

- **Remote**: `git@github.com:CC-GIT-MAX/Automated_Script.git`
- **Local path**: `D:\working_file\WorkSpace\scripts\Automated_Script_Summary`
- **Created**: 2026-07-13