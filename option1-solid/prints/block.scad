include <../option1_solid.scad>   // the model; keep this line first (see note at the bottom)

part = "block";                    // leave as is (the model also has a check mode)

// ================== OPTION 1 · SOLID BLOCK · VARIABLES ==================
// To change this print: delete the // at the start of a line, change the
// number, then in OpenSCAD press F6 and File > Export > STL (or run build.ps1,
// which exports ../stl/block.stl from this file).
// The values shown are the current defaults from ../option1_solid.scad; the
// build fails if they ever stop matching, so this list stays true.

// --- Block ---
// face_angle   = 8;     // degrees the camera face is turned (the mount's angle)
// depth_deep   = 50;    // depth at the deep (mounting) side, mm
// face_chamfer = 1.5;   // 45 degree bevel on the camera-face edges, mm; 0 = none

// --- Wiring pocket (option 1 only) ---
// block_pocket_depth = 17;   // pocket depth at its shallowest point, mm (back wall parallel to the block's back, as drawn)
// cable_flare_d      = 15;   // funnel mouth, mm; trimmed flat at the pocket floor, so it never cuts into it
// cable_flare_floor  = pocket_z_min;   // height of that flat trim (the pocket floor, 30)
// cable_mouth_chamfer = 1.5;  // 45 degree chamfer on the funnel's rim at the pocket wall, mm; 0 = none
// cable_flare_len    = 8;    // funnel length along the hole, mm; longer = gentler bend for the wire

// --- Mounting screws (#8 flat head, through the side) ---
// screw_y           = 19.5;      // distance from the back face, mm
// screw_z           = [22, 88];  // heights of the two screws, mm
// screw_head_recess = 0;         // sink the heads deeper (mm) to use shorter screws

// --- Check ---
// min_screw_wall = 4;   // build.ps1 fails if the pocket or funnel comes closer than this (mm)
//                       // to a screw hole; with the values above it's about 5.5 mm

// --- Fixed by the sketch: change these only in ../../mount_common.scad ---
// They are shared by all four options, and the build fails if they're set here:
//   width 55 x height 110 · Ring holes 2.25 mm, 91.5 mm apart, 12 mm deep ·
//   pocket 34.3 wide, 30-60 mm up (its depth is block_pocket_depth above) ·
//   cable hole 8 mm, 35 mm up ·
//   #8 screw size (4.6 mm hole, 8.8 mm head, 82 degree countersink)

// Note: OpenSCAD uses the LAST value set for a variable, so a value set here
// (after the include) wins over the model's default and changes only this print.
// Print orientation: lying on the back face (flat, 55 x 110).
