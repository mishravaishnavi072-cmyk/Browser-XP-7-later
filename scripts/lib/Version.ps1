function Read-HorizonVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string] $RepoRoot
    )

    $path = Join-Path $RepoRoot "VERSION"
    if (-not (Test-Path $path)) {
        throw "VERSION file not found at $path"
    }

    $map = @{}
    Get-Content $path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#")) { return }
        $parts = $line.Split("=", 2)
        if ($parts.Count -eq 2) {
            $map[$parts[0].Trim()] = $parts[1].Trim()
        }
    }
    return $map
}
