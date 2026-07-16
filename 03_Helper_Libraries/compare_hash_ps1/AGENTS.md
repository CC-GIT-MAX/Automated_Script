# AGENTS.md -- compare_hash.ps1

## What it does

PowerShell helper that compares two files by SHA256 hash. Returns `SAME` or
`DIFF` (or `MISSING_SRC` / `MISSING_DST` on error) to stdout.

Used by `update_scripts.bat` for reliable file diffing without using `fc` (which
has errorlevel-propagation issues inside `for` loops in cmd).

## How to call it

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File compare_hash.ps1 <file1> <file2>
```

## Inputs

- `$File1` (mandatory) -- first file path
- `$File2` (mandatory) -- second file path

## Outputs

- `SAME` -- files have identical SHA256 hashes
- `DIFF` -- files differ
- `MISSING_SRC` -- first file does not exist (exit code 1)
- `MISSING_DST` -- second file does not exist (exit code 1)

## Why not use `Get-FileHash`?

`Get-FileHash` is not available in all PowerShell 5.1 environments. We use the
.NET `[System.Security.Cryptography.SHA256]` class directly, which has been
in the .NET Framework since 2.0.

## Dependencies

- PowerShell 2.0 or later (uses `[System.Security.Cryptography.SHA256]`)
- Both input files must exist (else returns MISSING_*)

## Known issues

- Hashing very large files (>100MB) loads them entirely into memory. For huge
  files, consider switching to a streaming hash.
- Does not handle symbolic links specially; hashes the target file.

## Future work

- Add a `-Algorithm` parameter to support MD5, SHA1, SHA512
- Return the actual hashes for logging
## Dependency manifest (transplant this script by copying)

`compare_hash.ps1` is the smallest possible helper: a single .NET SHA256
call, no other repo file required. Useful both standalone and as a building
block.

| Slot | Source in this repo | Runtime path (caller decides) |
|---|---|---|
| Helper script | `03_Helper_Libraries/compare_hash_ps1/compare_hash.ps1` | wherever the caller invokes it; in this repo, `update_scripts.bat` calls it via `<TEMPLATE_DIR>\..\..\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1` |

**External tool dependencies**

| Tool | Version / how to verify | Used for |
|---|---|---|
| PowerShell | 2.0+ (uses `[System.Security.Cryptography.SHA256]`) | Hashes the two input files |
| .NET Framework | `System.Security.Cryptography.SHA256` -- present in all supported versions | Hash computation |

**Transplant command (PowerShell)**

```powershell
# Standalone: keep it next to your script
Copy-Item "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1" `
          -Destination "<TEMPLATE_DIR>\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1" -Force
```

If you transplant only `update_scripts.bat`, place this helper at the
relative path the script computes via `%~dp0\..\..\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1`
or update that constant in `update_scripts.bat`.

## Transplant checklist

```powershell
# 1. File exists where expected
Test-Path "compare_hash.ps1"

# 2. Standalone invocation returns SAME / DIFF
powershell -NoProfile -ExecutionPolicy Bypass -File compare_hash.ps1 fileA fileB

# 3. MISSING_* error paths
powershell -NoProfile -ExecutionPolicy Bypass -File compare_hash.ps1 missingA fileB
# expect MISSING_SRC on stdout and exit code 1
```

See also: `update_scripts.bat` (the only in-repo caller).