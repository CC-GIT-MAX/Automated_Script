# Script Operation Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repair new-project bootstrap for the categorized repository and document detailed operating procedures for every automation script.

**Architecture:** `new_project.bat` resolves sources from the numbered repository categories and deploys a stable `.scripts` runtime layout. A documentation index links one focused guide per user-facing script, while companion/helper scripts are documented as internal dependencies. Root indexes and tracking files expose and version the guides.

**Tech Stack:** Windows batch, PowerShell 5+, Markdown, Git, IAR `iarbuild`, Codex CLI.

---

### Task 1: Repair bootstrap paths

**Files:**
- Modify: `02_Template_Management/new_project_bat/new_project.bat`
- Modify: `02_Template_Management/new_project_bat/AGENTS.md`

- [ ] Define categorized repository source paths before validation.
- [ ] Copy build, fix, report, helper, updater, configuration, and AGENTS template files into a temporary target project.
- [ ] Preserve an existing `project.env.bat` during re-bootstrap.
- [ ] Verify all deployed files exist and `.gitignore` contains runtime exclusions.

### Task 2: Create operation guide set

**Files:**
- Create: `05_Documentation/operation_guides/README.md`
- Create: `05_Documentation/operation_guides/01-new-project.md`
- Create: `05_Documentation/operation_guides/02-project-config.md`
- Create: `05_Documentation/operation_guides/03-build.md`
- Create: `05_Documentation/operation_guides/04-fix-build.md`
- Create: `05_Documentation/operation_guides/05-daily-report.md`
- Create: `05_Documentation/operation_guides/06-weekly-report.md`
- Create: `05_Documentation/operation_guides/07-monthly-report.md`
- Create: `05_Documentation/operation_guides/08-update-scripts.md`
- Create: `05_Documentation/operation_guides/09-auto-build-watcher.md`
- Create: `05_Documentation/operation_guides/10-helper-scripts.md`
- Create: `05_Documentation/operation_guides/AGENTS.md`

- [ ] Document prerequisites, syntax, parameters, outputs, success criteria, failure handling, rollback, and examples for each user-facing script.
- [ ] Document companion `.ps1` and helper scripts as internal dependencies.
- [ ] Link the recommended daily workflow from the guide index.

### Task 3: Update repository indexes

**Files:**
- Modify: `README.md`
- Modify: `MANIFEST.md`
- Modify: `05_Documentation/AGENTS.md`
- Modify: `_tracking/CHANGELOG.md`
- Modify: `_tracking/TODO.md`

- [ ] Add operation-guide entry points and file inventory.
- [ ] Record bootstrap repair and documentation delivery in CHANGELOG.
- [ ] Remove or update completed documentation/bootstrap TODO items.

### Task 4: Verify and publish

- [ ] Run bootstrap against a fresh temporary project and inspect deployed files.
- [ ] Re-run bootstrap with a sentinel `project.env.bat` and verify preservation.
- [ ] Run update dry-run against the existing FlexCAN project.
- [ ] Validate Markdown links, duplicate batch labels, BOM status, and `git diff --check`.
- [ ] Commit all intended changes and push `main` to `origin`.
