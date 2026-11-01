# Rebuild the STL and preview images from ring_mount.scad, then sanity-check the STL.
# Usage (from the repo folder):  powershell -ExecutionPolicy Bypass -File .\build.ps1
# Requires OpenSCAD Nightly (winget install --id OpenSCAD.OpenSCAD.Nightly --exact)
# and Python 3 (standard library only).

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# winget does not put OpenSCAD on PATH, so call it by full path.
# openscad.com is the console build; openscad.exe is the GUI.
$openscad = 'C:\Program Files\OpenSCAD (Nightly)\openscad.com'
if (-not (Test-Path $openscad)) { throw "OpenSCAD not found at $openscad" }

$src = 'ring_mount.scad'
New-Item -ItemType Directory -Force stl, docs | Out-Null

Write-Host '== STL'
& $openscad --backend=manifold --export-format=binstl -o stl/ring_mount.stl $src
if ($LASTEXITCODE) { throw 'STL export failed' }

# Previews are rendered from the STL by a Python script, not by OpenSCAD:
# OpenSCAD's PNG export fails here with "Unable to create FBO" (cause not traced).
Write-Host '== previews'
python tools/render_stl.py stl/ring_mount.stl docs
if ($LASTEXITCODE) { throw 'Preview render failed' }

Write-Host '== check'
python tools/check_stl.py stl/ring_mount.stl
if ($LASTEXITCODE) { throw 'STL check failed' }
