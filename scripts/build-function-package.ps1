
$ErrorActionPreference = "Stop"

# Resolve paths relative to the script, not the terminal.
$repoRoot = Split-Path -Parent $PSScriptRoot

$appDir = Join-Path $repoRoot "infra/stacks/30-workload/app"
$artifactDir = Join-Path $repoRoot "artifacts"
$packagePath = Join-Path $artifactDir "functionapp-source.zip"

# Build from the three authoritative application files.
$requiredFiles = @(
    "function_app.py",
    "host.json",
    "requirements.txt"
)

foreach ($file in $requiredFiles) {
    $source = Join-Path $appDir $file

    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Required application file is missing: $source"
    }
}

# Prepare an isolated staging directory.
$stagingDir = Join-Path ([System.IO.Path]::GetTempPath()) (
    "azure-function-package-" + [guid]::NewGuid().ToString("N")
)

New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

try {
    foreach ($file in $requiredFiles) {
        Copy-Item `
            -LiteralPath (Join-Path $appDir $file) `
            -Destination $stagingDir
    }

    New-Item -ItemType Directory -Path $artifactDir -Force |
        Out-Null

    if (Test-Path -LiteralPath $packagePath) {
        Remove-Item -LiteralPath $packagePath -Force
    }

    Compress-Archive `
        -Path (Join-Path $stagingDir "*") `
        -DestinationPath $packagePath

    Write-Host "Created deployment package:"
    Write-Host $packagePath
}
finally {
    if (Test-Path -LiteralPath $stagingDir) {
        Remove-Item -LiteralPath $stagingDir -Recurse -Force
    }
}
