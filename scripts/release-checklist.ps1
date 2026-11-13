<#
.SYNOPSIS
  Prints the Horizon release gate checklist for the current VERSION pin.
#>
[CmdletBinding()]
param(
    [string] $HorizonRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Version.ps1")
$ver = Read-HorizonVersion -RepoRoot $HorizonRoot

Write-Host @"
Horizon release checklist
=========================
Product:          $($ver['PRODUCT_NAME']) $($ver['PRODUCT_VERSION'])
Channel:          $($ver['CHANNEL'])
Supermium ref:    $($ver['SUPERMIUM_REF'])
Chromium label:   $($ver['CHROMIUM_VERSION_LABEL'])

[ ] VERSION pin verified against https://github.com/win32ss/supermium/releases
[ ] gclient sync + runhooks completed on Windows build machine
[ ] scripts/apply-patches.ps1 succeeded (branding applied)
[ ] gn gen + ninja chrome + mini_installer (official, non-component)
[ ] progwrp wrappers copied and scripts/patch-progwrp.ps1 completed
[ ] docs/smoke-test.md passed on Windows 7 SP1 x64
[ ] Release notes list Chromium/Supermium security fixes included
[ ] Update URL / distribution channel ready (policies/recommended.json)
[ ] Artifacts archived: installer, portable zip, VERSION snapshot, GN args

See also: docs/security-updates.md
"@
