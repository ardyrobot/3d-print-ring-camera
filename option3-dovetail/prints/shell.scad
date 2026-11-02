// Print file: option 3 (dovetail slide), the camera shell.
// build.ps1 exports ../stl/shell.stl from this file. Print orientation: Camera face down.
//
// To change this one print: uncomment a setting below (or add any value from
// ../option3_dovetail.scad), then in OpenSCAD press F6 and use File > Export > STL.
// The last value set wins, so a setting here only affects this print.
//   - Fixed measurements (mount_common.scad) can't be changed here: the build fails.
//   - Print tolerances that two parts share must match, so change those in
//     ../option3_dovetail.scad instead. The build warns if one is set here.

include <../option3_dovetail.scad>

part = "shell";

// Settings for this print:
// face_chamfer = 1.5;   // bevel on the camera-face edges, 0 = none
// label_size   = 3.5;   // height of the engraved angle labels
