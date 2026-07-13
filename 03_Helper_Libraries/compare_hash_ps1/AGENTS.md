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