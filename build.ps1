# Rebuild every STL and preview image, then sanity-check the results.
# Usage (from the repo folder):  powershell -ExecutionPolicy Bypass -File .\build.ps1
# Requires OpenSCAD Nightly (winget install --id OpenSCAD.OpenSCAD.Nightly --exact)
# and Python 3 (standard library only). Takes a few minutes.
#
# Layout: one folder per option. In each, <option>.scad is the model,
# prints/<part>.scad is the print file for one STL, and stl/ and docs/ hold
# what this script generates.

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# winget does not put OpenSCAD on PATH, so call it by full path.
# openscad.com is the console build; openscad.exe is the GUI.
$openscad = 'C:\Program Files\OpenSCAD (Nightly)\openscad.com'
if (-not (Test-Path $openscad)) { throw "OpenSCAD not found at $openscad" }

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
function Preview($stl, $outdir, $prefix, $views) {
    python tools/render_stl.py $stl $outdir $prefix @views
    if ($LASTEXITCODE) { throw "$stl preview failed" }
}

# Printable parts come from the option's print files: what you open and tweak in
# OpenSCAD is exactly what gets exported.
function ExportPrints($opt) {
    New-Item -ItemType Directory -Force "$opt/stl", "$opt/docs" | Out-Null
    foreach ($pf in Get-ChildItem "$opt/prints/*.scad") {
        $stl = "$opt/stl/$($pf.BaseName).stl"
        Export $pf.FullName $stl @{}
        Check $stl
    }
}

# Collision check: the intersection must render empty ("top level object is empty")
$tmp = Join-Path $env:TEMP 'ring_mount_clash.stl'
function Clash($model, $defines) {
    $d = foreach ($k in $defines.Keys) { '-D'; "$k=$($defines[$k])" }
    $out = & $openscad --backend=manifold --export-format=binstl $d -o $tmp $model 2>&1 | Out-String
    return $out -match 'top level object is empty'
}

# Print files must not change fixed measurements or pick the wrong part
python tools/check_prints.py
if ($LASTEXITCODE) { throw 'A print file breaks the rules (see above)' }

# ---- Option 1: solid block ----
ExportPrints 'option1-solid'
Preview option1-solid/stl/block.stl option1-solid/docs block @()
# The pocket and the cable funnel must stay min_screw_wall clear of both screw
# holes; then a 9 mm requirement (more than the ~7 mm there) must fail.
$model = 'option1-solid/option1_solid.scad'
if (-not (Clash $model @{ part = '\"clash\"' })) { throw 'Option 1 pocket or cable funnel is too close to a screw' }
Write-Host 'option 1 screw-wall check: clear'
if (Clash $model @{ part = '\"clash\"'; min_screw_wall = 9 }) { throw 'Option 1 screw-wall check cannot fail' }
Write-Host 'option 1 screw-wall must-fail test: blocked'
# A funnel trimmed 2 mm below the floor must cut into it and be caught
if (Clash $model @{ part = '\"clash\"'; cable_flare_floor = 28 }) { throw 'Option 1 pocket-floor check cannot fail' }
Write-Host 'option 1 pocket-floor must-fail test: blocked'

# ---- Option 2: adjustable hinge ----
$opt = 'option2-hinge'; $model = "$opt/option2_hinge.scad"
ExportPrints $opt
Preview "$opt/stl/fit_test.stl" "$opt/docs" fit-test @('3d')
# Assemblies at both ends of the range, for viewing only (not for printing)
foreach ($a in 3, 15) {
    Export $model "$opt/stl/assembly_$a.stl" @{ part = '\"assembly\"'; assembly_angle = $a }
    Preview "$opt/stl/assembly_$a.stl" "$opt/docs" "assembly-$a" @('3d', 'top', 'side')
}
foreach ($a in 3, 5, 7, 9, 11, 13, 15) {
    if (-not (Clash $model @{ part = '\"clash\"'; assembly_angle = $a })) { throw "Option 2 parts collide at $a degrees" }
    Write-Host "option 2 clash check $a deg: clear"
}

# ---- Option 3: dovetail slide ----
$opt = 'option3-dovetail'; $model = "$opt/option3_dovetail.scad"
ExportPrints $opt
Preview "$opt/stl/fit_test.stl" "$opt/docs" fit-test @('3d')
foreach ($a in 3, 15) {
    Export $model "$opt/stl/assembly_$a.stl" @{ part = '\"assembly\"'; assembly_angle = $a }
    Preview "$opt/stl/assembly_$a.stl" "$opt/docs" "assembly-$a" @('3d', 'top', 'under')
}
# Every angle (pin in its own hole must fit), then a wrong hole that must be
# blocked, proving the check can fail.
foreach ($a in 3, 5, 7, 9, 11, 13, 15) {
    if (-not (Clash $model @{ part = '\"clash\"'; assembly_angle = $a })) { throw "Option 3 parts collide at $a degrees" }
    Write-Host "option 3 clash check $a deg: clear"
}
if (Clash $model @{ part = '\"clash\"'; assembly_angle = 5; pin_label = 3 }) { throw 'Option 3 lock accepted a wrong hole' }
Write-Host 'option 3 wrong-hole test: blocked'

# ---- Option 4: pivot with roof ----
$opt = 'option4-pivot'; $model = "$opt/option4_pivot.scad"
ExportPrints $opt
Preview "$opt/stl/fit_test.stl" "$opt/docs" fit-test @('3d')
foreach ($a in 3, 15) {
    Export $model "$opt/stl/assembly_$a.stl" @{ part = '\"assembly\"'; assembly_angle = $a }
    Preview "$opt/stl/assembly_$a.stl" "$opt/docs" "assembly-$a" @('3d', 'top', 'under')
}
# Every tooth (wall, mounting surface and screw heads count as solids), then a
# half-tooth angle that must collide, proving the check can fail.
foreach ($a in 3, 6, 9, 12, 15) {
    if (-not (Clash $model @{ part = '\"clash\"'; assembly_angle = $a })) { throw "Option 4 parts collide at $a degrees" }
    Write-Host "option 4 clash check $a deg: clear"
}
if (Clash $model @{ part = '\"clash\"'; assembly_angle = 4.5 }) { throw 'Option 4 lock accepted a half-tooth angle' }
Write-Host 'option 4 half-tooth test: blocked'
# The roof must be whole: a groove cut up through it must be caught
if (Clash $model @{ part = '\"clash\"'; deep_lip_groove_top = 111 }) { throw 'Option 4 roof check cannot fail' }
Write-Host 'option 4 roof-hole test: blocked'
# The shell must slide up onto the base at the install angle, from any height
foreach ($d in 2, 10, 30, 60, 95) {
    if (-not (Clash $model @{ part = '\"install\"'; install_drop = $d })) { throw "Option 4 shell jams $d mm below its seat" }
    Write-Host "option 4 install check $d mm: clear"
}

# Measurements table, generated from the .scad parameters and the STLs above
python tools/param_table.py
if ($LASTEXITCODE) { throw 'Measurements table failed' }

Write-Host '== done'
