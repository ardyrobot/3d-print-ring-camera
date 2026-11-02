// Print file: option 1 (solid block), the block.
// build.ps1 exports ../stl/block.stl from this file. Print orientation: Lying on the back face (flat, 55 x 110).
//
// To change this one print: uncomment a setting below (or add any value from
// ../option1_solid.scad), then in OpenSCAD press F6 and use File > Export > STL.
// The last value set wins, so a setting here only affects this print.
//   - Fixed measurements (mount_common.scad) can't be changed here: the build fails.
//   - Print tolerances that two parts share must match, so change those in
//     ../option1_solid.scad instead. The build warns if one is set here.

include <../option1_solid.scad>

// Settings for this print:
// face_angle   = 8;     // camera face angle, degrees
// face_chamfer = 1.5;   // bevel on the camera-face edges, 0 = none
// screw_head_recess = 0; // sink the screw heads deeper to use shorter screws
