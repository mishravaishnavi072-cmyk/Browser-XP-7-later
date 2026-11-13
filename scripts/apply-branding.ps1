<#
.SYNOPSIS
  Applies Horizon branding string replacements to a Chromium/Supermium src tree.

.DESCRIPTION
  Reads branding/product.json and performs conservative text replacements in
  common Chromium branding files when present. Safe to re-run. Does not
  replace binary icons — copy those manually per branding/README.md.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $ChromiumSrc,

    [string] $HorizonRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$productPath = Join-Path $HorizonRoot "branding\product.json"
if (-not (Test-Path $productPath)) { throw "Missing $productPath" }
if (-not (Test-Path $ChromiumSrc)) { throw "ChromiumSrc not found: $ChromiumSrc" }

$product = Get-Content $productPath -Raw | ConvertFrom-Json
$year = (Get-Date).ToString("yyyy")
$copyright = $product.copyright.Replace('$YEAR', $year)

$replacements = @(
    @{ From = "Chromium"; To = [string]$product.productName },
    @{ From = "Chrome"; To = [string]$product.productName }
)

# Prefer explicit branding files; avoid rewriting the entire tree.
$candidateFiles = @(
    "chrome\app\theme\chromium\BRANDING",
    "chrome\app\theme\google_chrome\BRANDING",
    "chrome\app\chromium_strings.grd",
    "chrome\app\google_chrome_strings.grd"
)

$touched = 0
foreach ($rel in $candidateFiles) {
    $full = Join-Path $ChromiumSrc $rel
    if (-not (Test-Path $full)) {
        Write-Host "skip (missing): $rel"
        continue
    }

    $original = Get-Content $full -Raw -ErrorAction Stop
    $updated = $original

    # BRANDING files are key=value — set known keys when present.
    if ($rel -like "*\BRANDING") {
        $lines = Get-Content $full
        $out = foreach ($line in $lines) {
            if ($line -match '^(COMPANY_FULLNAME)\s*=') {
                "${Matches[1]}=$($product.companyName)"
            }
            elseif ($line -match '^(COMPANY_SHORTNAME)\s*=') {
                "${Matches[1]}=$($product.companyName)"
            }
            elseif ($line -match '^(PRODUCT_FULLNAME)\s*=') {
                "${Matches[1]}=$($product.productName)"
            }
            elseif ($line -match '^(PRODUCT_SHORTNAME)\s*=') {
                "${Matches[1]}=$($product.shortName)"
            }
            elseif ($line -match '^(COPYRIGHT)\s*=') {
                "${Matches[1]}=$copyright"
            }
            else {
                $line
            }
        }
        $updated = ($out -join "`n") + "`n"
    }
    else {
        # Strings GRD: only replace product-facing Chromium label occurrences carefully.
        $updated = $updated.Replace("Chromium", [string]$product.productName)
    }

    if ($updated -ne $original) {
        Set-Content -Path $full -Value $updated -NoNewline
        Write-Host "updated: $rel"
        $touched++
    }
    else {
        Write-Host "unchanged: $rel"
    }
}

Write-Host "Branding pass complete. Files updated: $touched"
Write-Host "Default search name/url from product.json should be wired via policy or a regenerated patch:"
Write-Host "  $($product.defaultSearchName) -> $($product.defaultSearchUrl)"
