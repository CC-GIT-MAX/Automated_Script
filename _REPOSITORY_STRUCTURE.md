# Repository Structure -- How to organize scripts

> This file defines **how the repository is organized** and **how to add new scripts** in a way that is consistent with everything that already exists.
> Read this BEFORE creating a new script. Read `AGENTS.md` (root) for the rules every script must follow.

## 1. Top-level layout

```
Automated_Script_Summary/
|-- AGENTS.md                       (master rulebook)
|-- README.md                       (repo entry point)
|-- MANIFEST.md                     (file index)
|-- _REPOSITORY_STRUCTURE.md        (this file)
|-- _tracking/                      (TODO, IMPROVEMENTS, CHANGELOG)
|
|-- 01_Build_Automation/            (scripts that wrap compilation)
|-- 02_Template_Management/         (scripts that bootstrap or sync projects)
|-- 03_Helper_Libraries/            (shared helpers, .bat and .ps1)
|-- 04_File_Watcher/                (file save -> action)
|-- 05_Documentation/               (per-project templates and prompt libraries)
|-- 06_Project_Examples/            (worked examples)
|
|-- (future) 08_*, 09_*, 10_* ...   (new categories when they appear)
`-- (future) NN_<ToolChain>_*       (new toolchains, see section 3)
```

### Folder naming convention

- **Numbered prefixes** (`01_`, `02_`, ...) for **script categories** (cross-toolchain)
- **Underscore-prefixed** (`_tracking`, `_REPOSITORY_STRUCTURE`) for **meta files** (not scripts)
- Folder names use **PascalCase_with_underscores** between words
- Always 2-digit zero-padded numbers (so they sort correctly)

## 2. Current categories (01-07)

| # | Folder | Contains | Examples |
|---|---|---|---|
| 01 | `01_Build_Automation/` | Scripts that wrap a build tool | `build.bat`, `fix_build.bat` |
| 02 | `02_Template_Management/` | Bootstrap and sync scripts | `new_project.bat`, `update_scripts.bat` |
| 03 | `03_Helper_Libraries/` | Shared helpers used by other scripts | `common.bat`, `compare_hash.ps1` |
| 04 | `04_File_Watcher/` | File-system event handlers | `auto_build_watcher.ps1` |
| 05 | `05_Documentation/` | Templates, prompt libraries, checklists | `AGENTS.md`, `README.md`, prompt library |
| 06 | `06_Project_Examples/` | Worked examples of full setups | `YTM32B1MD1_FlexCAN/` |
| 07 | `07_Tracking/` | TODO, IMPROVEMENTS, CHANGELOG | (see `_tracking/` section below) |

**Note**: We have both `07_Tracking/` and `_tracking/`. The `07_` prefix keeps it in numerical order with the other categories. The underscore prefix signals that it is meta, not a script. Pick one style and stick with it. **Going forward we use `_tracking/`** for new tracking files.

## 3. Adding a new script

### Step 1: Determine its category

Ask: "What is this script''s primary job?"

| Job | Put in |
|---|---|
| Wraps a build tool, captures logs | `01_Build_Automation/` |
| Bootstraps a new project or syncs templates | `02_Template_Management/` |
| Shared helper used by other scripts | `03_Helper_Libraries/` |
| Reacts to file system events | `04_File_Watcher/` |
| Per-project template (AGENTS.md, README, prompt lib) | `05_Documentation/` |
| Worked example of a full setup | `06_Project_Examples/` |

**If none of the above fit**, see section 5 for creating a new category.

### Step 2: Choose a folder name

The folder name is **the script''s filename without extension**:

- `weekly_report.bat` lives in `01_Build_Automation/weekly_report_bat/weekly_report.bat` (snake_case from CamelCase)

This is a deliberate convention:
- Folder name is sortable in file managers
- Folder name is searchable with `find`
- Folder name matches the script inside it (one script per folder by default)

### Step 3: Put the right files in the folder

Every script folder MUST contain:

| File | Required? | Purpose |
|---|---|---|
| `<script>.bat` (or `.ps1`) | **Yes** | The script itself |
| `AGENTS.md` | **Yes** | Per-script manual (see AGENTS.md root for what to include) |
| `README.md` | Optional | Only if the script needs extensive docs (usually AGENTS.md is enough) |
| `tests/` | Optional | Automated tests for the script |
| `examples/` | Optional | Example invocations and expected output |

### Step 4: Update the tracking files

- Add a row to `_tracking/CHANGELOG.md` (dated)
- If the task was in `TODO.md`, remove it
- If the script changes the bootstrap flow (new file copied by `new_project.bat`):
  - Update `02_Template_Management/new_project_bat/new_project.bat` to copy it
  - Update `02_Template_Management/update_scripts_bat/update_scripts.bat` to sync it

### Step 5: Commit and push

```bash
git status
git add -A
git commit -m "Add <script_name>: <one-line summary>"
git push
```

## 4. Adding a new category (08, 09, ...)

Create a new top-level folder when:

- You have **3 or more scripts** that share a new purpose
- The existing 01-06 categories don''t fit (or would become too crowded)

**Naming**: `NN_<CategoryName>/` where `NN` is the next available number.

**Convention for category AGENTS.md**: every category folder should have a top-level `AGENTS.md` explaining what goes in it. See `05_Documentation/AGENTS.md` for an example.

## 5. Adding a new toolchain or domain

If you add scripts for a **different toolchain** (e.g. GCC ARM, Keil MDK, ESP-IDF), the convention is:

```
<NN>_<ToolChainName>/
    build/
        <script_name>/
    fix/
        <script_name>/
    helper/
        <script_name>/
    docs/
        ...
    examples/
        ...
```

**Example**: GCC ARM toolchain

```
08_GCC_ARM/
    build/
        arm_make_bat/         (arm-none-eabi-make wrapper)
    fix/
        arm_fix_bat/          (compile-fix loop)
    helper/
        arm_common_bat/       (gcc-specific env loader)
    docs/
        AGENTS_md/            (gcc-specific rules)
    examples/
        stm32cube_project/    (worked example)
```

**Important**: do NOT mix toolchains. If a script works for both IAR and GCC ARM, put it in `_shared/` (see below) or duplicate it under each toolchain with toolchain-specific tweaks.

## 6. `_shared/` -- cross-toolchain scripts

Scripts that work for **all toolchains** (not IAR-specific or GCC-specific):

```
_shared/
    prompt_libraries/         (universal Codex prompts)
    output_formatters/        (universal pretty-printer)
    ...
```

When in doubt: if the script does NOT contain toolchain-specific paths or commands, it goes in `_shared/`. If it does, it goes under a specific toolchain folder.

## 7. Naming conventions summary

| Item | Convention | Example |
|---|---|---|
| Top-level folders | `NN_Name/` (PascalCase) | `01_Build_Automation/` |
| Meta folders | `_Name/` (underscore prefix) | `_tracking/` |
| Script folders | `<script_name>_<ext>/` | `build_bat/`, `fix_build_bat/` |
| Script filenames | Original case | `build.bat`, `auto_build_watcher.ps1` |
| AGENTS.md | Always capitalized | `AGENTS.md` |
| README.md | Always capitalized | `README.md` |
| Backups folder (per-project) | `backup/` (lowercase) | `06_Project_Examples/.../backup/` |

## 8. The "one script per folder" rule

**Default**: each script lives in its own folder.

**Exception**: a group of closely related scripts can share a folder if:
- They are always used together
- They are variants of the same tool (e.g. `build.bat` and `build.ps1` for the same task in different shells)
- The folder is named for the **concept**, not the script

Example: `01_Build_Automation/iarbuild_wrappers/` could contain `build.bat`, `build_verbose.bat`, `build_quiet.bat` if they are all variants of the same wrapper.

## 9. Versioning

We do not currently version individual scripts. The git log + CHANGELOG.md is the source of truth.

**If you need to ship a stable version** (e.g. v1.0.0):
- Add a `VERSION` file at the repo root
- Tag the commit: `git tag v1.0.0`
- Document the version in `CHANGELOG.md`

**Backward compatibility**:
- Renaming a script = breaking change (anyone using it will break)
- Moving a script between folders = breaking change
- Adding a new optional flag = non-breaking
- Fixing a bug in a script = non-breaking (but should be in CHANGELOG)

## 10. Quick decision tree

```
I want to add a new automation script. Where does it go?

  Is it toolchain-specific (IAR / GCC / Keil)?
    YES -> Does it fit an existing category (01-06)?
             YES -> <that category>/<script_name>_<ext>/
             NO  -> Create 08_<NewToolChain>/ and follow section 5.
    NO  -> Is it a shared helper used by other scripts?
             YES -> _shared/<script_name>_<ext>/
             NO  -> Create a new top-level category.
```

```
I want to add documentation (AGENTS.md, README, etc.). Where does it go?

  Is it for a single script?
    YES -> <script_folder>/ (next to the script)
  Is it for a category (e.g. all of 03_Helper_Libraries)?
    YES -> <category>/AGENTS.md (one level above scripts)
  Is it a per-project template (what gets copied into projects)?
    YES -> 05_Documentation/ (so new_project.bat can copy it)
  Is it repo-wide (rules, conventions)?
    YES -> repo root (AGENTS.md, README.md, MANIFEST.md, this file)
```

## 11. Anti-patterns to avoid

- **DON''T** put multiple unrelated scripts in one folder
- **DON''T** mix toolchains in the same script folder
- **DON''T** use spaces or special chars in folder names
- **DON''T** skip writing the per-script `AGENTS.md` -- the future you will forget what the script does
- **DON''T** add files at the repo root unless they apply to the whole repo
- **DON''T** rename or move existing scripts without a CHANGELOG entry (breaks downstream users)

---

**Last updated**: 2026-07-13
## 12. Per-script dependency bundles

Every script folder's `AGENTS.md` MUST include a **Dependency manifest**
section and end with a **Transplant checklist**. The matching Chinese guide
under `05_Documentation/operation_guides/` MUST include a **依赖文件清单与移植**
section with copy commands and verification steps.

Full rule: see root `AGENTS.md`, section
`### 6. Dependency Packaging (self-contained script bundles)`.

When you add a new script:

- Derive the dependency list from the script source (`call`,
  `powershell -File`, `copy`, `%FILE_*_SRC%` references). No hypotheticals.
- The manifest must list the **runtime on-disk layout**, not the source-tree
  layout. Example: a `.bat` + `.ps1` companion pair live side-by-side at
  runtime, even though they sit in the same folder here.
- If `new_project.bat` or `update_scripts.bat` does not copy a file the
  manifest lists, that is a **bug** in those scripts -- fix the bug, do not
  drop the entry from the manifest.
