<#
.SYNOPSIS
  Runs Supermium progwrp_patcher over a directory of PE files.

.DESCRIPTION
  Obtain progwrp_patcher.exe and wrapper DLLs from the Supermium release that
  matches SUPERMIUM_REF. This script only orchestrates the patcher.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $BinaryDir,

    [Parameter(Mandatory = $true)]
    [string] $PatcherExe,

    [string] $WrapperDllSource
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $BinaryDir)) { throw "BinaryDir not found: $BinaryDir" }
if (-not (Test-Path $PatcherExe)) { throw "PatcherExe not found: $PatcherExe" }

if ($WrapperDllSource) {
    if (-not (Test-Path $WrapperDllSource)) { throw "WrapperDllSource not found: $WrapperDllSource" }
    Write-Host "Copying wrapper DLLs from $WrapperDllSource"
    Copy-Item -Path (Join-Path $WrapperDllSource "*.dll") -Destination $BinaryDir -Force
}

$files = @()
$files += Get-ChildItem -Path $BinaryDir -Filter *.exe -File
$files += Get-ChildItem -Path $BinaryDir -Filter *.dll -File

if ($files.Count -eq 0) { throw "No .exe/.dll files in $BinaryDir" }

foreach ($f in $files) {
    Write-Host "patching $($f.FullName)"
    & $PatcherExe $f.FullName
    if ($LASTEXITCODE -ne 0) {
        throw "progwrp_patcher failed on $($f.Name) with exit $LASTEXITCODE"
    }
}

Write-Host "Patched $($files.Count) files. Verify launch on Windows 7 SP1 before release."
