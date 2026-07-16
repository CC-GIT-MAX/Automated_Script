# PITFALLS.md -- Automation Development Lessons

This file records repeatable failures found while developing the automation suite.
Read it before changing any `.bat` or `.ps1` file. Add a new entry whenever a
problem takes significant debugging time or could recur in another script.

## Entry Format

Every entry should contain:

- **Symptom**: what the user or command displayed
- **Root cause**: the actual technical reason
- **Prevention**: the rule that prevents recurrence
- **Safe pattern**: a minimal example when useful

## 11. PowerShell `Set-Content -Encoding utf8` Does Not Add BOM on Windows PowerShell 5.1

- **Symptom**: an editor (Windows Notepad, certain Markdown renderers, anything
  that does not auto-sniff UTF-8) renders a freshly written Chinese `.md` file
  as mojibake (e.g. `鏂伴』鐩` instead of `新项`), even though the same file
  looks fine in VSCode.
- **Root cause**: Windows PowerShell 5.1's `Set-Content -Encoding utf8` writes
  **UTF-8 without BOM**. On Windows the default code page is GBK / 936
  (Asia/Shanghai locale). When the editor does not see a BOM and does not run
  an explicit UTF-8 sniffer, it falls back to the system code page and decodes
  the UTF-8 bytes as GBK, producing mojibake. A secondary contributor is that
  the same `Set-Content` call uses LF line endings, which can break tools that
  default to CRLF and confuses Git (`core.autocrlf=input` plus mixed endings
  shows `CRLF will be replaced by LF` warnings).
- **Prevention**:
  - For any Chinese `.md` file in this repo, **always** use the BOM-emitting
    UTF-8 encoding:

    ```powershell
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($path, $text, $utf8Bom)
    ```

  - Normalize line endings to LF on every write (LF is the repo convention --
    `git config core.autocrlf=input`).
  - This rule applies to `.md` only. The root `AGENTS.md` rule that forbids
    BOM is for `.bat` scripts (where BOM breaks `cmd` parsing), not for `.md`.
  - When in doubt, run this verification from PowerShell before declaring
    the file done:

    ```powershell
    $b = [System.IO.File]::ReadAllBytes($path)
    "BOM=$($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF)"
    [System.Text.Encoding]::UTF8.GetString($b).Substring(0, 80)
    ```
- **Safe pattern** (writing a Chinese Markdown file from PowerShell on
  Windows):

  ```powershell
  $utf8Bom = New-Object System.Text.UTF8Encoding($true)   # emit BOM
  $text = ($content -replace "`r`n", "`n") -replace "`r", "`n"   # normalize to LF
  [System.IO.File]::WriteAllText($path, $text, $utf8Bom)
  ```

- **Verification**: the file starts with bytes `EF BB BF` (BOM) followed by
  `23 20 ...` (the `#` of Markdown). Any tool that respects BOM decodes it as
  UTF-8; tools that ignore BOM still get a correct UTF-8 byte sequence
  because LF-only line endings do not corrupt the multi-byte CJK sequences.
- **Files in this repo that must keep UTF-8 BOM** (any `.md` containing CJK
  characters): all entries under `05_Documentation/operation_guides/*.md`
  plus `AGENTS.md`, `05_Documentation/README_md/README.md`,
  `05_Documentation/codex_prompt_library/codex_prompt_library.md`,
  `05_Documentation/fill_in_checklist/AGENTS_FILL_IN_CHECKLIST.md`,
  `_tracking/CHANGELOG.md`, and `_tracking/IMPROVEMENTS.md`.
- **Files that must stay ASCII / no BOM** (per existing repo rule, because the
  content is English-only): all `.bat`, `.ps1`, and the per-script `AGENTS.md`
  files under `01_Build_Automation`, `02_Template_Management`,
  `03_Helper_Libraries`, `04_File_Watcher`, plus
  `05_Documentation/AGENTS.md`, `05_Documentation/operation_guides/AGENTS.md`,
  `06_Project_Examples/AGENTS.md`, and root `MANIFEST.md`, `README.md`,
  `_REPOSITORY_STRUCTURE.md`, and `_tracking/AGENTS.md`, `PITFALLS.md`,
  `TODO.md`.

## 1. Cache `%~dp0` Before Argument Parsing

- **Symptom**: a wrapper reports that its neighboring `.ps1` file does not exist,
  while the file is visibly present in `.scripts\`.
- **Root cause**: after a label-based `shift` / `goto` argument loop, `%~dp0` can
  expand from the changed argument context instead of the original script path.
- **Prevention**: copy `%~dp0` into a variable before entering any parsing loop.
- **Safe pattern**:

```bat
@echo off
chcp 65001 > nul
set "_SCRIPT_DIR=%~dp0"
setlocal
:PARSE
if "%~1"=="" goto :DONE
shift
goto :PARSE
:DONE
powershell -File "%_SCRIPT_DIR%worker.ps1"
```

## 2. Keep Complex Logic Out of Batch

- **Symptom**: errors such as `> was unexpected at this time.`,
  `( was unexpected at this time.`, or unrelated fragments being interpreted as
  commands.
- **Root cause**: cmd parses parenthesized blocks before execution. Nested
  `for`/`if`, redirection, pipes, escaping, delayed expansion, and generated text
  interact in fragile ways.
- **Prevention**: use `.bat` only as a thin launcher. Put date calculations, file
  collection, filtering, report synthesis, JSON, and multiline output in `.ps1`.

## 3. Do Not Use `exit /b` Inside Parenthesized Blocks

- **Symptom**: a script exits from an unexpected context or cmd reports a parser
  error near a closing parenthesis.
- **Root cause**: `exit /b` inside nested `if (...)` / `for (...)` blocks is hard
  to reason about with cmd's parse-time expansion.
- **Prevention**: set an exit code, jump to one `:DONE` label, then exit once.

```bat
if not exist "%REQUIRED_FILE%" (
    echo [ERROR] Required file is missing.
    set "EXIT_CODE=1"
    goto :DONE
)

:DONE
endlocal & exit /b %EXIT_CODE%
```

## 4. Avoid `findstr /R` for Non-Trivial Patterns

- **Symptom**: a regular expression works in another engine but misses valid
  lines or matches unexpected text in `findstr`.
- **Root cause**: `findstr /R` supports only a small, non-standard regex subset;
  quoting and escaping differ from PowerShell/.NET regex.
- **Prevention**: use `Select-String` or `[regex]` in PowerShell for anything
  beyond a simple literal search.

## 5. Avoid Nested Blocks Inside Redirected Output Blocks

- **Symptom**: generating a Markdown file with `( ... ) > output.md` fails when a
  nested `for` or `if` is added.
- **Root cause**: cmd parses the complete redirected block first, so special
  characters and nested control structures can alter the outer command.
- **Prevention**: write report files with PowerShell `Set-Content` /
  `Add-Content`, or redirect individual simple `echo` commands only.

## 6. Translate CLI Flags for PowerShell

- **Symptom**: calling `powershell -File worker.ps1 --no-codex` causes an unknown
  parameter error or consumes values incorrectly.
- **Root cause**: PowerShell parameter binding expects declared parameter names
  such as `-NoCodex`, not GNU-style kebab-case flags.
- **Prevention**: let the `.bat` wrapper translate public CLI flags to PowerShell
  parameter names before launching the worker.

## 7. Resolve Paths From the Actual Repository Layout

- **Symptom**: `Template incomplete. Missing build.bat.` even though the file is
  present elsewhere in the repository.
- **Root cause**: a script assumed all template files were flat beside itself,
  while the repository stores them under category and script directories.
- **Prevention**: define every source path from the current script directory and
  documented repository tree. Define path variables before checking them.

```bat
set "FILE_BUILD_SRC=%TEMPLATE_DIR%\..\..\01_Build_Automation\build_bat\build.bat"
set "COMPARE_SCRIPT=%TEMPLATE_DIR%\..\..\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1"
```

## 8. Detect Accidental Duplicate Script Blocks

- **Symptom**: headers, `setlocal`, argument parsing, or initialization appear
  twice; fixing one section does not affect the executed section.
- **Root cause**: a text-based rewrite inserted a replacement block without
  removing the original block.
- **Prevention**: after scripted edits, inspect `git diff` and search for unique
  labels such as `:PARSE_ARGS`, `:DONE`, and `setlocal`. Each top-level label or
  initialization block should normally appear once.

## 9. Preserve Batch Encoding and Line Endings

- **Symptom**: fragments such as `'t' is not recognized`, corrupted Chinese
  output, or invisible characters before `@echo off`.
- **Root cause**: UTF-8 BOM, mixed code pages, or incompatible line endings were
  written into a batch file.
- **Prevention**: keep batch source and output ASCII-only, write `.bat` files as
  ASCII without BOM, and use CRLF line endings. Put Chinese documentation in
  Markdown instead of command output.

## 10. Treat Exit Code `0` as Insufficient Evidence

- **Symptom**: a wrapper returns success although redirection failed or the real
  build command never ran.
- **Root cause**: the final harmless command overwrote the failing command's
  `%ERRORLEVEL%`, or logging failed before the build started.
- **Prevention**: capture the build command's exit code immediately, validate
  that the expected log exists, and verify that the log contains an IAR build
  result before reporting success.

## 12. PowerShell `Set-Content -Encoding ascii` Silently Drops Non-ASCII Bytes

- **Symptom**: a file you appended via `Set-Content -Encoding ascii` shows `?`
  placeholders where Chinese / em-dash / smart-quote characters used to be.
  The file otherwise reads correctly. UTF-8 / UTF-16 re-encoding does not help
  because the bytes are already gone.
- **Root cause**: `Encoding ascii` (= `[System.Text.ASCIIEncoding]`) cannot
  represent any code point above `0x7F`. When PowerShell writes a string that
  contains such characters, every un-representable character is replaced with
  `?` (ASCII 0x3F). There is no warning, no exception, no `[?]` marker.
- **Prevention**: **never** use `-Encoding ascii` for files that may contain
  non-ASCII bytes. For Markdown files in this repo the rule is:

  | Content of the file | Encoding to use |
  |---|---|
  | Pure ASCII only | `utf8NoBom = New-Object System.Text.UTF8Encoding($false)` |
  | Any CJK / extended Latin / em-dash / smart-quote / box-drawing chars | `utf8Bom = New-Object System.Text.UTF8Encoding($true)` (also adds the BOM that fixes Notepad-on-Windows-Chinese mojibake) |
  | `.bat` files (per repo root `AGENTS.md`) | **never** use UTF-8 BOM -- `cmd` will choke. Stay ASCII-only. |

  ```powershell
  # WRONG (silently corrupts non-ASCII):
  $content | Set-Content -LiteralPath $path -Encoding ascii -NoNewline

  # RIGHT for an ASCII Markdown file:
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)

  # RIGHT for a Markdown file with CJK content:
  $utf8Bom = New-Object System.Text.UTF8Encoding($true)
  [System.IO.File]::WriteAllText($path, $content, $utf8Bom)
  ```

- **Verification** (run after every write that could have non-ASCII content):

  ```powershell
  $b = [System.IO.File]::ReadAllBytes($path)
  $t = [System.Text.Encoding]::UTF8.GetString($b)
  ($t.ToCharArray() | Where-Object { [int]$_ -gt 0x7F }).Count   # should equal what you wrote
  if ($t -match '\?\?+') { Write-Warning 'Suspicious ??? sequence -- non-ASCII may have been stripped' }
  ```

- **Real bug it caused in this repo (2026-07-15 session)**: `README.md`,
  `MANIFEST.md`, `_REPOSITORY_STRUCTURE.md`, and
  `05_Documentation/operation_guides/AGENTS.md` were each appended via
  `Set-Content -Encoding ascii -NoNewline`. The `依赖文件清单与移植` Chinese
  fragment in those appends, plus the original `[操作手册]` / `每个脚本的详细步骤、参数和排错方法`
  link label in `README.md` HEAD, were silently replaced with `?`. A 6-file
  byte-by-byte audit caught it: HEAD CJK count > WORK CJK count for `README.md`
  by 21 characters. Fix: read the file as UTF-8, do `Replace('????...', '依赖...')`,
  rewrite with `UTF8Encoding($true)`.

## Maintenance Rule

When a new pitfall is found:

1. Record it here before closing the task.
2. Add a prevention rule to the relevant script directory's `AGENTS.md` if the
   issue is script-specific.
3. Add a dated summary to `CHANGELOG.md`.
4. Add follow-up work to `TODO.md` if the prevention is not yet automated.
