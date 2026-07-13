# Codex IAR Automation Template

Portable build + compile-fix automation for IAR Embedded Workbench projects, integrated with OpenAI Codex CLI.

---

## Table of Contents

1. [What this template provides](#1-what-this-template-provides)
2. [Start a new project (5-minute setup)](#2-start-a-new-project-5-minute-setup)
3. [Daily usage](#3-daily-usage)
4. [Update an existing project when the template improves](#4-update-an-existing-project-when-the-template-improves)
5. [Add a new automation script to the template](#5-add-a-new-automation-script-to-the-template)
6. [Reference](#6-reference)

---

## 1. What this template provides

**Files you get in every project after bootstrap:**

| File / Folder | Purpose |
|---|---|
| `.scripts/build.bat` | Wraps `iarbuild`, captures logs to `build_logs/` |
| `.scripts/fix_build.bat` | Compile-fix auto loop, calls Codex on failure |
| `.scripts/lib/common.bat` | Shared helpers (loads `project.env.bat`) |
| `.scripts/lib/compare_hash.ps1` | SHA256 file hash helper (used by updater) |
| `.scripts/project.env.bat` | **Per-project config** (gitignored, you edit this) |
| `.scripts/update.bat` | Project-local wrapper for pulling template updates |
| `AGENTS.md` | Team collaboration rules for Codex |
| `build_logs/` | Auto-created, gitignored |

**Files that stay in the template directory (not copied to projects):**

| File | Purpose |
|---|---|
| `new_project.bat` | One-command bootstrap for new projects |
| `update_scripts.bat` | The actual update logic (called by `.scripts\update.bat`) |
| `project.env.bat.example` | Reference when filling in `project.env.bat` |
| `AGENTS.md` | Source of truth; copied to new projects |
| `README.md` | This file |

---

## 2. Start a new project (5-minute setup)

### Prerequisites

Before you begin, confirm:

- [ ] **IAR Embedded Workbench** is installed (any 8.x or 9.x version)
- [ ] Your project has an IAR `.ewp` file (e.g. `EWARM/MyProject.ewp`)
- [ ] You know the IAR **Build Configuration name** (visible in IAR''s project dropdown: `Debug` / `Release` / `FLASH` / etc.)
- [ ] **Codex CLI** is installed and `codex` is on your `PATH` (run `where codex` to verify)

### Step 1: Locate the template

The template lives somewhere on your machine, for example:

```
C:\Users\25237\Documents\Codex\2026-07-13\codex-cli\outputs\template\
```

You only need this path for the bootstrap. The project itself will not depend on it after setup.

### Step 2: Open a terminal in your project root

```bat
cd D:\path\to\my-new-project
```

Verify you''re in the right place by listing the IAR project:

```bat
dir EWARM\MyProject.ewp
```

### Step 3: Run the bootstrap

```bat
C:\path\to\template\new_project.bat
```

You''ll see:

```
============================================================
 Bootstrap Codex automation into:
 D:\path\to\my-new-project
============================================================
Copying scripts...
[OK] Created .scripts\project.env.bat
[OK] Appended entries to .gitignore
```

The script will:
- Create `.scripts\` directory
- Copy `build.bat`, `fix_build.bat`, `lib\`
- Create `.scripts\project.env.bat` from the example
- Update `.gitignore` to ignore `project.env.bat` and `build_logs\`
- Copy `AGENTS.md` to your project root

If `.scripts\` already exists, you''ll be asked `Continue? [Y,N]`. Choose `Y` to overwrite, `N` to abort.

### Step 4: Configure `project.env.bat`

Open the file:

```bat
notepad .scripts\project.env.bat
```

Fill in these 5 fields (the rest have sensible defaults):

```bat
set "PROJECT_NAME=My New Project"             REM (1) Display name
set "MCU_FAMILY=STM32F407"                    REM (2) For Codex prompts
set "BOARD_NAME=CustomBoard-v1"               REM (3) For Codex prompts

set "IAR_BIN=D:\IAR\common\bin\iarbuild.exe"  REM (4) Full path to iarbuild

set "IAR_PROJECT_SUBPATH=EWARM"               REM (5a) Folder containing .ewp
set "IAR_PROJECT_FILE=MyProject.ewp"          REM (5b) Filename

set "IAR_CONFIG=Debug"                        REM (6) Case-sensitive!
```

**How to find each value:**

- **(4) `IAR_BIN`**: In IAR, `Tools > Configure Tools` shows the install path. Or in Windows, search for `iarbuild.exe`.
- **(5a/b) `IAR_PROJECT_SUBPATH` / `IAR_PROJECT_FILE`**: Look at your project structure. Most STM32 / NXP projects use `EWARM/ProjectName.ewp`.
- **(6) `IAR_CONFIG`**: Open `.ewp` in IAR; the dropdown next to the build button shows the exact name (case-sensitive). Common values: `Debug`, `Release`, `FLASH`, `RAM`.

### Step 5: Edit `update.bat` to point at the template

The `.scripts\update.bat` needs to know where the template lives on **your** machine. Open it and edit one line:

```bat
notepad .scripts\update.bat
```

Change this line near the top:

```bat
set "TEMPLATE_DIR=C:\Users\25237\Documents\Codex\2026-07-13\codex-cli\outputs\template"
```

(Use whatever path you used in Step 3.)

> **Why edit it per-project?** The template is a personal/shared folder; its location is a per-machine setting, not a per-project setting.

### Step 6: Fill in `AGENTS.md`

Open it and replace every `[FILL ...]` placeholder with real values:

```bat
notepad AGENTS.md
```

The file has prompts like:
- `[FILL: e.g. STM32F407 / NXP RT1064]`  → your MCU
- `[FILL: e.g. FLASH / Debug / Release]` → your IAR config
- `[FILL: copy from IAR Project > Options > C/C++ Compiler > Preprocessor]` → list of macros
- etc.

You can grep to find all placeholders at once:

```bat
findstr "FILL" AGENTS.md
```

### Step 7: Test the build

```bat
.scripts\build.bat build
```

**Expected output:**

```
============================================================
 IAR Build Script
 Project : My New Project (STM32F407 / CustomBoard-v1)
 File    : D:\path\to\my-new-project\EWARM\MyProject.ewp
 Config  : Debug
 Mode    : build
 Log     : D:\path\to\my-new-project\build_logs\build_20260713_173000.log
============================================================
[OK]  Build succeeded.
```

**If you get `[FAIL] Build failed`**, the build log at the path shown has the full error output. Open it in any text editor to see what went wrong.

### Step 8: (Optional) Commit to git

```bat
git add .scripts AGENTS.md
git commit -m "Add Codex automation scripts"
```

Note: `.gitignore` already excludes `.scripts/project.env.bat` and `build_logs/`.

### You''re done!

Your project now has the full Codex automation. Skip to section 3 for daily usage.

---

## 3. Daily usage

### Compile only (no Codex)

```bat
.scripts\build.bat build         REM build with FLASH config
.scripts\build.bat clean         REM clean intermediate files
.scripts\build.bat rebuild       REM clean + rebuild
```

### Compile + auto-fix loop

When you have a compile error and want Codex to try fixing it:

```bat
.scripts\fix_build.bat 5         REM up to 5 fix attempts
```

Codex will read `build_logs/latest.log`, propose a one-file-at-a-time fix, verify by rebuilding, and stop when the build passes (or after 5 attempts).

### Auto-build on file save (recommended)

In a separate PowerShell window, run:

```powershell
.\.scripts\auto_build_watcher.ps1
```

It watches `app/`, `board/`, `platform/`, `middleware/`, `rtos/` for `.c`/`.h` changes. On save it auto-runs `build.bat`. On failure, it asks whether to invoke Codex.

### PowerShell shortcuts (one-time setup)

Add to `~/.powershell_profile.ps1`:

```powershell
function fix { & cmd /c ".scripts\fix_build.bat $args" }
function build { & cmd /c ".scripts\build.bat $args" }
```

Then from any project root:

```powershell
fix 5
build
```

---

## 4. Update an existing project when the template improves

When you (or someone on your team) adds a new feature to the template, every project can pull it in.

### Step 1: Make sure the template is updated

Edit files in your template directory. For example, you might:
- Add a new script like `weekly_report.bat`
- Fix a bug in `lib/common.bat`
- Add new prompts to `AGENTS.md`

### Step 2: Run a dry-run from the project

```bat
cd D:\path\to\my-project
.scripts\update
```

This prints what would change without touching anything:

```
============================================================
 Update project scripts from template
 Template : C:\Users\...\template
 Project  : D:\path\to\my-project
============================================================
Scanning for differences...
  [SAME]  build.bat - no change
  [DIFF]  fix_build.bat - will be updated
  [DIFF]  lib\common.bat - will be updated

Summary: 2 to update, 0 to add.
```

If only `[SAME]` is shown, you''re already up to date.

### Step 3: Apply the update

```bat
.scripts\update --apply
```

This will:
1. Back up current scripts to `.scripts\backup\YYYYMMDD_HHMMSS\`
2. Copy new versions from the template
3. Preserve `.scripts\project.env.bat` (your per-project config)
4. Preserve any project-specific files not in the template

### Step 4: Verify

```bat
.scripts\build.bat build
```

### Flags

| Flag | Effect |
|---|---|
| (none) | Dry-run, prints what would change |
| `--apply` | Apply the changes (skips y/N prompt) |
| `--no-backup` | Skip the backup step (e.g. in CI) |

### Rollback if something goes wrong

Your previous scripts are in `.scripts\backup\<timestamp>\`. To restore:

```bat
xcopy /Y /E /I .scripts\backup\20260713_172332\lib .scripts\lib
copy /Y .scripts\backup\20260713_172332\build.bat .scripts\build.bat
copy /Y .scripts\backup\20260713_172332\fix_build.bat .scripts\fix_build.bat
```

### How `update.bat` knows the template path

The project''s `.scripts\update.bat` has `TEMPLATE_DIR=` at the top. If you move the template on your machine, edit that one line in each project.

---

## 5. Add a new automation script to the template

When you find a new task worth automating, you can add it to the template so all projects get it.

### Step 1: Create the script

Create the new script in the template directory, e.g. `template/weekly_report.bat`. It should follow the conventions in section 6.

### Step 2: Update `update_scripts.bat`

Open `template/update_scripts.bat` and add the new file to **three places**:

1. Define the file variables near the top:
   ```bat
   set "FILE_WEEKLY_SRC=%TEMPLATE_DIR%\weekly_report.bat"
   set "FILE_WEEKLY_DST=%SCRIPTS_DIR%\weekly_report.bat"
   ```

2. Add to the scan phase:
   ```bat
   call :CHECK_ONE "%FILE_WEEKLY_SRC%" "%FILE_WEEKLY_DST%" "weekly_report.bat"
   ```

3. Add to the apply phase:
   ```bat
   call :APPLY_ONE "%FILE_WEEKLY_SRC%" "%FILE_WEEKLY_DST%" "weekly_report.bat"
   ```

4. If the script is in a subdirectory (like `lib/`), also add backup line:
   ```bat
   if exist "%FILE_WEEKLY_DST%" copy /Y "%FILE_WEEKLY_DST%" "!BACKUP_DIR!\weekly_report.bat" > nul
   ```

### Step 3: Update `new_project.bat`

Open `template/new_project.bat` and add a line in the "Copying scripts" section to copy your new file.

### Step 4: Update the README

Add a row to section 1 describing the new file. If the script has its own usage section, add it to section 3 (Daily usage).

### Step 5: Test the sync

On an existing project, run `update.bat --apply` to verify the new file is copied. On a fresh test project, run `new_project.bat` to verify it''s included from the start.

---

## 6. Reference

### Why .env.bat and not .env?

cmd does NOT execute `set` statements in files with non-standard extensions. A `call project.env` silently does nothing because cmd treats `.env` as data. The `.bat` suffix is the conventional solution.

If you really want the file to be called `project.env` for tooling reasons (editors that highlight `.env` specially), see the "advanced" section at the end of this file.

### File layout

**Template directory** (where this README lives):

```
template/
|-- build.bat                 # Portable build script
|-- fix_build.bat             # Portable auto-fix loop
|-- lib/
|   |-- common.bat            # Shared helpers (loads project.env.bat)
|   `-- compare_hash.ps1      # File hash helper for update_scripts
|-- project.env.bat.example   # Template for project.env.bat
|-- new_project.bat           # Bootstrap script
|-- update_scripts.bat        # Template-to-project sync (lives in template/)
|-- update.bat                # Project-local wrapper for the above
|-- AGENTS.md                 # Collaboration rules template
`-- README.md                 # This file
```

**Per-project layout** (after `new_project.bat`):

```
new-project/
|-- .scripts/
|   |-- build.bat             # Copied from template
|   |-- fix_build.bat         # Copied from template
|   |-- lib/
|   |   |-- common.bat        # Copied from template
|   |   `-- compare_hash.ps1  # Copied from template
|   |-- project.env.bat       # YOU edit this per project (gitignored)
|   `-- update.bat            # Project-local wrapper
|-- AGENTS.md                 # Copied from template, you fill placeholders
|-- build_logs/               # Auto-created, gitignored
`-- .gitignore                # Updated to ignore project.env.bat and build_logs/
```

### Script authoring rules

All scripts in the template must follow these rules to ensure reliability:

1. `chcp 65001 > nul` at the very top (UTF-8 output, prevents encoding issues)
2. ASCII-only output -- Chinese / Unicode goes in `AGENTS.md`, not scripts
3. Use `goto` + a single `exit /b` at the end (avoid `exit /b` inside `if () (...)` blocks)
4. Read config from `project.env.bat` via `call "%~dp0lib\common.bat"`
5. When using PowerShell, prefer `[System.Security.Cryptography.SHA256]` over `Get-FileHash` (compatibility)
6. When capturing PowerShell output, use a temp file rather than `for /f "usebackq"` (PATH not inherited)

### Customizing for non-IAR projects

Edit `.scripts/build.bat`:
- Replace the `IAR_BIN` invocation with your toolchain (GCC ARM, Keil, etc.)
- Keep the `project.env.bat` pattern (read configuration from file)
- Keep the log capture pattern (write to `build_logs/MODE_TIMESTAMP.log`)

### Why an explicit file list in update_scripts.bat?

The updater uses a hard-coded list of files rather than scanning the template directory. This is because:

- `for %%F in (...)` with `%%~pF` (path-only expansion) strips the drive letter, breaking any `if` comparisons.
- Reading sub-paths via `for /r` and pattern matching is fragile.
- A hard-coded list is auditable -- you can see at a glance what gets updated.

If you add a new file to the template that should be synced to projects, see section 5.

### Adding more automation scripts (suggested)

Recommended additions you can build on top of this template:
- `weekly_report.bat` -- generate Feishu/Lark weekly report from git log
- `pre_commit_review.bat` -- Codex code review before commit
- `analyze_log.bat` -- analyze debug logs with Codex
- `flash_and_test.bat` -- flash firmware and capture test logs

Each should follow the authoring rules above.

---

**Last updated**: 2026-07-13
