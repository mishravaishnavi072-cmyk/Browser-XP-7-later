<#
.SYNOPSIS
  Checks out the pinned Supermium ref. Run from a machine with depot_tools.

.DESCRIPTION
  This script does not replace a full gclient workflow. It verifies VERSION,
  prints the exact commands to run, and optionally checks out SUPERMIUM_REF
  when -ChromiumSrc already exists.
#>
[CmdletBinding()]
param(
    [string] $HorizonRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,

    [string] $ChromiumSrc,

    [switch] $CheckoutOnly,

    [switch] $PrintOnly
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Version.ps1")

$ver = Read-HorizonVersion -RepoRoot $HorizonRoot
$repo = $ver["SUPERMIUM_REPO"]
$ref = $ver["SUPERMIUM_REF"]
$label = $ver["CHROMIUM_VERSION_LABEL"]

Write-Host "Horizon pin"
Write-Host "  PRODUCT_VERSION=$($ver['PRODUCT_VERSION'])"
Write-Host "  SUPERMIUM_REPO=$repo"
Write-Host "  SUPERMIUM_REF=$ref"
Write-Host "  CHROMIUM_VERSION_LABEL=$label"
Write-Host ""
Write-Host "Recommended commands (short path, e.g. C:\src\horizon-build):"
Write-Host "  gclient config --name=src $repo"
Write-Host "  cd src && git fetch --tags && git checkout $ref"
Write-Host "  cd .. && gclient sync -D --with_branch_heads --with_tags"
Write-Host "  REM If Supermium docs for this tag require merge sync, use their flagged gclient sync."
Write-Host "  gclient runhooks"
Write-Host "  powershell -ExecutionPolicy Bypass -File $HorizonRoot\scripts\apply-patches.ps1 -ChromiumSrc <src>"

if ($PrintOnly) { return }

if (-not $ChromiumSrc) {
    Write-Host ""
    Write-Host "No -ChromiumSrc supplied; printed sync instructions only."
    return
}

if (-not (Test-Path (Join-Path $ChromiumSrc ".git"))) {
    throw "ChromiumSrc does not look like a git checkout: $ChromiumSrc"
}

Push-Location $ChromiumSrc
try {
    & git fetch --tags $repo
    & git checkout $ref
    if ($LASTEXITCODE -ne 0) { throw "Failed to checkout $ref" }
    Write-Host "Checked out $ref"
    if (-not $CheckoutOnly) {
        Write-Host "Run gclient sync from the .gclient root when ready."
    }
}
finally {
    Pop-Location
}
