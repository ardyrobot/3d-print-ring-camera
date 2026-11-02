// Print file: option 4 (pivot with roof), the base with roof.
// build.ps1 exports ../stl/base.stl from this file. Print orientation: Roof down.
//
// To change this one print: uncomment a setting below (or add any value from
// ../option4_pivot.scad), then in OpenSCAD press F6 and use File > Export > STL.
// The last value set wins, so a setting here only affects this print.
//   - Fixed measurements (mount_common.scad) can't be changed here: the build fails.
//   - Print tolerances that two parts share must match, so change those in
//     ../option4_pivot.scad instead. The build warns if one is set here.

include <../option4_pivot.scad>

part = "base";

// Settings for this print:
// foot_chamfer = 0.5;   // first-layer edge chamfer on the roof
