// Ring camera angled mounting block
// Source of truth for the part. Edit values here, then run build.ps1.
//
// Source tags on each value:
//   [written] = dimension written on the hand sketch (docs/sketch.webp)
//   [scaled]  = measured off the sketch at ~6.7 px/mm (approximate)
//   [chosen]  = decision made during design; see README "Open questions"
//
// Coordinate frame (mm):
//   X = width,  0 = deep side (mounting side), 55 = shallow side (countersink side)
//   Y = depth,  0 = back face (cable entry), +Y points out of the camera face
//   Z = height, 0 = bottom
// Looking at the camera face (sketch "front view"): shallow side on the left,
// deep side on the right. The camera face turns toward the shallow side.

/* [Block] */
width       = 55;     // [written]
height      = 110;    // [written]
depth_deep  = 46;     // [scaled]  depth at the deep (mounting) side
face_angle  = 8;      // [chosen]  degrees the camera face is turned
face_chamfer = 1.5;   // [chosen]  45 degree bevel on the camera-face edges; 0 = none

// Ring hole pattern (ring_hole_d, ring_hole_spacing, ring_hole_depth)
include <ring_common.scad>

/* [Wiring pocket] */
pocket_z_min      = 30;    // [written] bottom of pocket above block bottom
pocket_z_max      = 60;    // [written] top of pocket above block bottom
pocket_deep_inset = 9;     // [scaled]  pocket edge to deep side, front view
pocket_width      = 34.3;  // [scaled]  front-view width
pocket_depth      = 15;    // [chosen]  perpendicular to the camera face

/* [Cable hole] */
cable_d           = 8;     // [written]
cable_z           = 35;    // [scaled]  centre height
cable_deep_inset  = 17;    // [scaled]  centre to deep side

/* [Block mounting screws] (through the width, X axis) */
screw_d           = 3.5;   // [written?] shank clearance; sketch text hard to read
screw_head_d      = 8;     // [written] countersink diameter at the surface
screw_y           = 19.5;  // [scaled]  distance from back face
screw_z           = [22, 88]; // [scaled] heights
screw_head_recess = 0;     // [chosen]  extra counterbore depth to shorten screws

/* [Quality] */
$fn = 64;

// ---- derived ----
eps           = 0.01;
depth_shallow = depth_deep - width * tan(face_angle);
face_x0       = width / 2;
face_y0       = (depth_deep + depth_shallow) / 2;

// X position -> distance along the angled face from its centre
function face_u(x) = (x - face_x0) / cos(face_angle);

module block() {
    linear_extrude(height)
        polygon([[0, 0], [width, 0], [width, depth_shallow], [0, depth_deep]]);
}

// Local frame on the camera face: +X along the face, +Y out of the face, Z up
module on_face() {
    translate([face_x0, face_y0, 0]) rotate([0, 0, -face_angle]) children();
}

// 45 degree bevel around the camera face: a square bar turned 45 degrees about each edge.
// Top and bottom edges meet square faces, so their bevel is exact; the side faces
// meet the camera face at 90 +/- face_angle, so the side bevels are slightly uneven.
module face_chamfers() {
    face_len = width / cos(face_angle);
    s = face_chamfer * sqrt(2);
    if (face_chamfer > 0) on_face() {
        for (u = [-face_len / 2, face_len / 2])
            translate([u, 0, height / 2]) rotate([0, 0, 45])
                cube([s, s, height + 2], center = true);
        for (z = [0, height])
            translate([0, 0, z]) rotate([45, 0, 0])
                cube([face_len + 2, s, s], center = true);
    }
}

module ring_holes() {
    for (z = [(height - ring_hole_spacing) / 2, (height + ring_hole_spacing) / 2])
        on_face() translate([0, eps, z]) rotate([90, 0, 0])
            cylinder(d = ring_hole_d, h = ring_hole_depth + eps);
}

module pocket() {
    u0 = face_u(pocket_deep_inset);
    u1 = face_u(pocket_deep_inset + pocket_width);
    // Extra +Y so the cut clears the face completely
    on_face() translate([u0, -pocket_depth, pocket_z_min])
        cube([u1 - u0, pocket_depth + 5, pocket_z_max - pocket_z_min]);
}

module cable_hole() {
    // From the back face into the pocket; stops inside the pocket void
    translate([cable_deep_inset, -eps, cable_z]) rotate([-90, 0, 0])
        cylinder(d = cable_d, h = depth_shallow);
}

module screw_holes() {
    sink = (screw_head_d - screw_d) / 2;  // 90 degree countersink
    // Local +Z runs from the shallow side face toward the deep side
    for (z = screw_z) translate([width, screw_y, z]) rotate([0, -90, 0]) {
        translate([0, 0, -eps]) cylinder(d = screw_d, h = width + 2 * eps);
        translate([0, 0, -eps]) cylinder(d = screw_head_d, h = screw_head_recess + eps);
        translate([0, 0, screw_head_recess - eps])
            cylinder(d1 = screw_head_d, d2 = screw_d, h = sink + eps);
    }
}

difference() {
    block();
    face_chamfers();
    ring_holes();
    pocket();
    cable_hole();
    screw_holes();
}
