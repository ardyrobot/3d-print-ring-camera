# Rebuild every STL and preview image, then sanity-check the results.
# Usage (from the repo folder):  powershell -ExecutionPolicy Bypass -File .\build.ps1
# Requires OpenSCAD Nightly (winget install --id OpenSCAD.OpenSCAD.Nightly --exact)
# and Python 3 (standard library only). Takes a few minutes.

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# winget does not put OpenSCAD on PATH, so call it by full path.
# openscad.com is the console build; openscad.exe is the GUI.
$openscad = 'C:\Program Files\OpenSCAD (Nightly)\openscad.com'
if (-not (Test-Path $openscad)) { throw "OpenSCAD not found at $openscad" }
New-Item -ItemType Directory -Force stl, docs | Out-Null

# Export one STL. -D overrides a variable in the .scad file. Windows PowerShell 5.1
# drops bare quotes when calling native programs, hence the escaped \" around strings.
function Export($src, $out, $defines) {
    Write-Host "== $out"
    $d = foreach ($k in $defines.Keys) { '-D'; "$k=$($defines[$k])" }
    & $openscad --backend=manifold --export-format=binstl $d -o $out $src
    if ($LASTEXITCODE) { throw "$out export failed" }
}

function Check($stl) {
    python tools/check_stl.py $stl
    if ($LASTEXITCODE) { throw "$stl failed the STL check" }
}

# Previews are rendered from the STLs by a Python script, not by OpenSCAD:
# OpenSCAD's PNG export fails here with "Unable to create FBO" (cause not traced).
function Preview($stl, $prefix, $views) {
    python tools/render_stl.py $stl docs $prefix @views
    if ($LASTEXITCODE) { throw "$stl preview failed" }
}

# ---- Solid block (primary part) ----
Export ring_mount.scad stl/ring_mount.stl @{}
Check stl/ring_mount.stl
Preview stl/ring_mount.stl preview @()

# ---- Adjustable mount (secondary option): printable parts ----
$adj = 'ring_mount_adjustable.scad'
foreach ($p in 'base', 'shell', 'washer', 'fit_test') {
    Export $adj "stl/adjustable_$p.stl" @{ part = "\`"$p\`"" }
    Check "stl/adjustable_$p.stl"
}
Preview stl/adjustable_fit_test.stl adjustable-fit-test @('3d')

# Assemblies at both ends of the range, for viewing only (not for printing)
foreach ($a in 3, 15) {
    Export $adj "stl/adjustable_assembly_$a.stl" @{ part = '\"assembly\"'; assembly_angle = $a }
    Preview "stl/adjustable_assembly_$a.stl" "adjustable-$a" @('3d', 'top', 'side')
}

# Collision check: the base, shell and washer must not overlap at any setting.
# OpenSCAD reports "top level object is empty" when the intersection is empty.
$tmp = Join-Path $env:TEMP 'ring_mount_clash.stl'
foreach ($a in 3, 5, 7, 9, 11, 13, 15) {
    $out = & $openscad --backend=manifold --export-format=binstl -D 'part=\"clash\"' `
        -D "assembly_angle=$a" -o $tmp $adj 2>&1 | Out-String
    if ($out -notmatch 'top level object is empty') { throw "Parts collide at $a degrees" }
    Write-Host "clash check $a deg: clear"
}

# ---- Slide mount (option 3): printable parts ----
$sld = 'ring_mount_slide.scad'
foreach ($p in 'base', 'shell', 'pin', 'fit_test') {
    Export $sld "stl/slide_$p.stl" @{ part = "\`"$p\`"" }
    Check "stl/slide_$p.stl"
}
Preview stl/slide_fit_test.stl slide-fit-test @('3d')
foreach ($a in 3, 15) {
    Export $sld "stl/slide_assembly_$a.stl" @{ part = '\"assembly\"'; assembly_angle = $a }
    Preview "stl/slide_assembly_$a.stl" "slide-$a" @('3d', 'top', 'under')
}

# Slide clash check at every angle (pin in its own hole must fit), then one
# wrong-hole test that must be blocked, proving the check can fail.
foreach ($a in 3, 5, 7, 9, 11, 13, 15) {
    $out = & $openscad --backend=manifold --export-format=binstl -D 'part=\"clash\"' `
        -D "assembly_angle=$a" -o $tmp $sld 2>&1 | Out-String
    if ($out -notmatch 'top level object is empty') { throw "Slide parts collide at $a degrees" }
    Write-Host "slide clash check $a deg: clear"
}
$out = & $openscad --backend=manifold --export-format=binstl -D 'part=\"clash\"' `
    -D 'assembly_angle=5' -D 'pin_label=3' -o $tmp $sld 2>&1 | Out-String
if ($out -match 'top level object is empty') { throw 'Slide lock accepted a wrong hole' }
Write-Host 'slide wrong-hole test: blocked'

# Measurements table, generated from the .scad parameters and the STLs above
python tools/param_table.py
if ($LASTEXITCODE) { throw 'Measurements table failed' }

Write-Host '== done'
