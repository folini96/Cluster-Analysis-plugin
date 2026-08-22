# Builds a QGIS-installable plugin zip from the release-relevant source files.
# Run from anywhere; usage: powershell -File scripts\build-zip.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PluginName = "cluster_analysis"
$StageRoot = Join-Path $env:TEMP $PluginName
$OutputZip = Join-Path $RepoRoot "$PluginName.zip"

# Runtime files only - excludes tests, Makefile/pb_tool.cfg, plugin_upload.py, dev/build
# scripts, docs, and the Experiments/ working folder.
$Files = @(
    "__init__.py",
    "cluster_analysis.py",
    "cluster_analysis_dialog.py",
    "cluster_analysis_dialog_base.ui",
    "resources.py",
    "Configuration.json",
    "metadata.txt",
    "icon.png"
)

if (Test-Path $StageRoot) { Remove-Item $StageRoot -Recurse -Force }
New-Item -ItemType Directory -Path $StageRoot | Out-Null

foreach ($f in $Files) {
    $src = Join-Path $RepoRoot $f
    if (-not (Test-Path $src)) {
        throw "Required file missing: $f"
    }
    Copy-Item $src -Destination $StageRoot
}

if (Test-Path $OutputZip) { Remove-Item $OutputZip -Force }
Compress-Archive -Path $StageRoot -DestinationPath $OutputZip

Remove-Item $StageRoot -Recurse -Force

Write-Host "Created $OutputZip"
