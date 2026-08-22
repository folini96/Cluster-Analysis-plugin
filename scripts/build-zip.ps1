# Builds a QGIS-installable plugin zip from the release-relevant source files.
# Run from anywhere; usage: powershell -File scripts\build-zip.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PluginName = "cluster_analysis"
# Must match the folder name registered for this plugin on plugins.qgis.org
# (set by the original submission's zip). Changing it would break the
# plugin's identity in the repository, so keep it in sync with that name
# rather than $PluginName.
$PackageFolderName = "Cluster-Analysis-plugin-main"
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
    "icon.png",
    "LICENSE"
)

if (Test-Path $OutputZip) { Remove-Item $OutputZip -Force }

# Compress-Archive on Windows PowerShell writes backslash path separators for
# some entries, which violates the ZIP spec and QGIS's Python zipfile-based
# loader rejects it. Build the archive manually so entry names always use
# forward slashes.
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::Open($OutputZip, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($f in $Files) {
        $src = Join-Path $RepoRoot $f
        if (-not (Test-Path $src)) {
            throw "Required file missing: $f"
        }
        $entryName = "$PackageFolderName/$f"
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $src, $entryName, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
}
finally {
    $zip.Dispose()
}

Write-Host "Created $OutputZip"
