<#
.SYNOPSIS
  Applies patches listed in patches/horizon/SERIES to a Chromium src tree.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $ChromiumSrc,

    [string] $HorizonRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,

    [switch] $DryRun,

    [switch] $SkipTemplates
)

$ErrorActionPreference = "Stop"

$series = Join-Path $HorizonRoot "patches\horizon\SERIES"
$patchDir = Join-Path $HorizonRoot "patches\horizon"
if (-not (Test-Path $series)) { throw "Missing SERIES at $series" }
if (-not (Test-Path $ChromiumSrc)) { throw "ChromiumSrc not found: $ChromiumSrc" }

$allowTemplates = $env:HORIZON_ALLOW_TEMPLATE_PATCHES
if ([string]::IsNullOrEmpty($allowTemplates)) { $allowTemplates = "1" }

function Test-IsTemplatePatch([string] $text) {
    return $text -match "Intentionally empty hunk body"
}

Push-Location $ChromiumSrc
try {
    Get-Content $series | ForEach-Object {
        $name = $_.Trim()
        if (-not $name -or $name.StartsWith("#")) { return }

        $path = Join-Path $patchDir $name
        if (-not (Test-Path $path)) { throw "Patch listed in SERIES not found: $path" }

        $raw = Get-Content $path -Raw
        if (Test-IsTemplatePatch $raw) {
            if ($SkipTemplates -or $allowTemplates -eq "1") {
                Write-Host "soft-skip template patch: $name (regenerate after first sync; use apply-branding.ps1)"
                return
            }
            throw "Template patch not allowed: $name"
        }

        if ($DryRun) {
            Write-Host "dry-run apply: $name"
            & git apply --check --whitespace=nowarn $path
            if ($LASTEXITCODE -ne 0) { throw "git apply --check failed for $name" }
        }
        else {
            Write-Host "apply: $name"
            & git apply --whitespace=nowarn $path
            if ($LASTEXITCODE -ne 0) { throw "git apply failed for $name" }
        }
    }

    Write-Host "Running branding helper..."
    if (-not $DryRun) {
        & powershell -ExecutionPolicy Bypass -File (Join-Path $HorizonRoot "scripts\apply-branding.ps1") -ChromiumSrc $ChromiumSrc -HorizonRoot $HorizonRoot
    }
    else {
        Write-Host "dry-run: skipped apply-branding.ps1"
    }
}
finally {
    Pop-Location
}

Write-Host "Patch pass finished."
