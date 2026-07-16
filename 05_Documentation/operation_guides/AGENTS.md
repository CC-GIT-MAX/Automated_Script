# AGENTS.md -- Operation Guides

## Purpose

This directory contains user-facing Chinese operating procedures for every
script in the automation suite.

## Rules

- Commands, paths, flags, environment variables, and console output stay in English.
- Each user-facing script guide must include purpose, prerequisites, syntax,
  steps, parameters, outputs, success criteria, common failures, and rollback.
- Companion `.ps1` files and shared helpers are documented as internal
  dependencies; users should normally run the `.bat` entry point.
- Verify commands against the current script before updating a guide.
- When script behavior changes, update its guide and `_tracking/CHANGELOG.md`
  in the same commit.

## Dependency manifest rule

Each user-facing guide in this directory **must** contain a section titled
`## 依赖文件清单与移植`. It must list:

- Every repo source file the script reads/calls, with both the repo path and
  the deployed runtime path.
- Every project-local file the script consumes (e.g. `project.env.bat`,
  generated daily reports).
- Every external tool the script invokes (IAR, PowerShell, Codex CLI).
- A `依赖文件清单与移植` block with the verbatim `copy` / `xcopy` / PowerShell
  `Copy-Item` commands that produce the bundle on a new machine.
- A `移植后验证` block with 3-6 concrete commands that confirm the bundle
  works.

The rule is defined in the root `AGENTS.md` section
`### 6. Dependency Packaging (self-contained script bundles)`. When that rule
changes, audit every guide here.
