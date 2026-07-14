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

## Maintenance Rule

When a new pitfall is found:

1. Record it here before closing the task.
2. Add a prevention rule to the relevant script directory's `AGENTS.md` if the
   issue is script-specific.
3. Add a dated summary to `CHANGELOG.md`.
4. Add follow-up work to `TODO.md` if the prevention is not yet automated.
