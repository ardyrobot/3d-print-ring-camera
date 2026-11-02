// Print file: option 2 (adjustable hinge), the fit test (print this first).
// build.ps1 exports ../stl/fit_test.stl from this file. Print orientation: As laid out; each piece in its full-part orientation.
//
// To change this one print: uncomment a setting below (or add any value from
// ../option2_hinge.scad), then in OpenSCAD press F6 and use File > Export > STL.
// The last value set wins, so a setting here only affects this print.
//   - Fixed measurements (mount_common.scad) can't be changed here: the build fails.
//   - Print tolerances that two parts share must match, so change those in
//     ../option2_hinge.scad instead. The build warns if one is set here.

include <../option2_hinge.scad>

part = "fit_test";

// Settings for this print:
// (none specific to this part)
