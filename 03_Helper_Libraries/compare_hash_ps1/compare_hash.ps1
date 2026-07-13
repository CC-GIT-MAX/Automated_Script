# ============================================================
#  compare_hash.ps1 -- compare two files by SHA256 hash
#  Uses .NET SHA256 directly to avoid Get-FileHash issues
# ============================================================

param(
    [Parameter(Mandatory=$true)][string]$File1,
    [Parameter(Mandatory=$true)][string]$File2
)

if (-not (Test-Path $File1)) { Write-Output "MISSING_SRC"; exit 1 }
if (-not (Test-Path $File2)) { Write-Output "MISSING_DST"; exit 1 }

$sha = [System.Security.Cryptography.SHA256]::Create()
$bytes1 = [System.IO.File]::ReadAllBytes($File1)
$bytes2 = [System.IO.File]::ReadAllBytes($File2)
$hash1 = $sha.ComputeHash($bytes1)
$hash2 = $sha.ComputeHash($bytes2)
$sha.Dispose()

$hex1 = -join ($hash1 | ForEach-Object { $_.ToString('x2') })
$hex2 = -join ($hash2 | ForEach-Object { $_.ToString('x2') })

if ($hex1 -eq $hex2) { Write-Output "SAME" } else { Write-Output "DIFF" }
