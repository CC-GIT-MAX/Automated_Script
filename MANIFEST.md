# MANIFEST.md -- Complete file index

> Auto-generated index of every file in this repo. Use it as a quick reference
> when you need to find a specific file.

## Root files

| File | Purpose |
|---|---|
| `AGENTS.md` | Master rulebook (universal rules, contribution guide) |
| `README.md` | Top-level intro and quick links |
| `_REPOSITORY_STRUCTURE.md` | How the repo is organized, how to add new scripts |
| `MANIFEST.md` | This file |
| `.gitignore` | Files to exclude from git |

## 01_Build_Automation/

| File | Purpose |
|---|---|
| `build_bat/build.bat` | Wrap iarbuild, capture log |
| `build_bat/AGENTS.md` | build.bat manual |
| `fix_build_bat/fix_build.bat` | Compile-fix auto loop |
| `fix_build_bat/AGENTS.md` | fix_build.bat manual |

## 02_Template_Management/

| File | Purpose |
|---|---|
| `new_project_bat/new_project.bat` | Bootstrap new projects |
| `new_project_bat/AGENTS.md` | new_project.bat manual |
| `update_scripts_bat/update_scripts.bat` | Template-to-project sync (core) |
| `update_scripts_bat/AGENTS.md` | update_scripts.bat manual |
| `update_bat/update.bat` | Project-local wrapper for update_scripts.bat |
| `update_bat/AGENTS.md` | update.bat manual |

## 03_Helper_Libraries/

| File | Purpose |
|---|---|
| `common_bat/common.bat` | Load project.env.bat, normalize paths |
| `common_bat/AGENTS.md` | common.bat manual |
| `compare_hash_ps1/compare_hash.ps1` | SHA256 file comparison |
| `compare_hash_ps1/AGENTS.md` | compare_hash.ps1 manual |

## 04_File_Watcher/

| File | Purpose |
|---|---|
| `auto_build_watcher_ps1/auto_build_watcher.ps1` | Auto-build on file save |
| `auto_build_watcher_ps1/AGENTS.md` | Watcher manual |

## 05_Documentation/

| File | Purpose |
|---|---|
| `AGENTS.md` | Overview of the docs folder |
| `AGENTS_md/AGENTS.md` | The per-project AGENTS.md template |
| `README_md/README.md` | User-facing quick start |
| `codex_prompt_library/codex_prompt_library.md` | All Codex prompts |
| `fill_in_checklist/AGENTS_FILL_IN_CHECKLIST.md` | New-project setup checklist |

## 06_Project_Examples/

| File | Purpose |
|---|---|
| `AGENTS.md` | Overview of the examples folder |
| `YTM32B1MD1_FlexCAN/build.bat` | Example project''s build.bat |
| `YTM32B1MD1_FlexCAN/fix_build.bat` | Example project''s fix_build.bat |
| `YTM32B1MD1_FlexCAN/project.env.bat` | Example project''s env config |
| `YTM32B1MD1_FlexCAN/lib/common.bat` | Example project''s common.bat |

## _tracking/ (was 07_Tracking)

| File | Purpose |
|---|---|
| `AGENTS.md` | Overview of tracking files |
| `TODO.md` | Pending tasks (priority-ordered) |
| `IMPROVEMENTS.md` | Future ideas |
| `CHANGELOG.md` | Dated change log |

> **Note**: `07_Tracking/` was renamed to `_tracking/` on 2026-07-13 to follow the
> convention that meta files (not scripts) are prefixed with underscore.

## Total file counts

- Scripts: 8 (across build/template/helper/watcher)
- AGENTS.md files: 13 (1 root + 8 per-script + 3 category + 1 doc)
- Documentation: 4 (README, AGENTS template, prompt library, fill-in checklist)
- Tracking: 3 (TODO, IMPROVEMENTS, CHANGELOG)
## Operation Guides

| File | Purpose |
|---|---|
| `05_Documentation/operation_guides/README.md` | Chinese user entry point and recommended workflow |
| `05_Documentation/operation_guides/01-new-project.md` | Bootstrap a new project |
| `05_Documentation/operation_guides/02-project-config.md` | Configure `project.env.bat` |
| `05_Documentation/operation_guides/03-build.md` | Run IAR builds |
| `05_Documentation/operation_guides/04-fix-build.md` | Run the Codex compile-fix loop |
| `05_Documentation/operation_guides/05-daily-report.md` | Create daily reports |
| `05_Documentation/operation_guides/06-weekly-report.md` | Generate weekly reports |
| `05_Documentation/operation_guides/07-monthly-report.md` | Generate monthly reports |
| `05_Documentation/operation_guides/08-update-scripts.md` | Preview, apply, and roll back script updates |
| `05_Documentation/operation_guides/09-auto-build-watcher.md` | Start save-triggered builds |
| `05_Documentation/operation_guides/10-helper-scripts.md` | Understand internal helpers and companion scripts |
