// Print file: option 2 (adjustable hinge), the base.
// build.ps1 exports ../stl/base.stl from this file. Print orientation: Standing on its bottom face.
//
// To change this one print: uncomment a setting below (or add any value from
// ../option2_hinge.scad), then in OpenSCAD press F6 and use File > Export > STL.
// The last value set wins, so a setting here only affects this print.
//   - Fixed measurements (mount_common.scad) can't be changed here: the build fails.
//   - Print tolerances that two parts share must match, so change those in
//     ../option2_hinge.scad instead. The build warns if one is set here.

include <../option2_hinge.scad>

part = "base";

// Settings for this print:
// foot_chamfer = 0.5;   // first-layer edge chamfer (elephant's foot)
