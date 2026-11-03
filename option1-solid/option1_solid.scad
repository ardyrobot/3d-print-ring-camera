// Ring camera angled mounting block
// Source of truth for the part. Edit values here, then run build.ps1.
//
// Source tags on each value:
//   [written] = dimension written on the hand sketch (docs/sketch.webp)
//   [scaled]  = measured off the sketch at ~6.7 px/mm (approximate)
//   [chosen]  = decision made during design; see README "Open questions"
//
// Pocket depth is measured perpendicular to the camera face.
//
// Coordinate frame (mm):
//   X = width,  0 = deep side (mounting side), 55 = shallow side (countersink side)
//   Y = depth,  0 = back face (cable entry), +Y points out of the camera face
//   Z = height, 0 = bottom
// Looking at the camera face (sketch "front view"): shallow side on the left,
// deep side on the right. The camera face turns toward the shallow side.

// Fixed measurements shared by all options: width, height, Ring holes, pocket,
// cable hole, mounting screws. Edit them in mount_common.scad, not here.
include <../mount_common.scad>

/* [Block] */
depth_deep  = 50;     // [chosen]  depth at the deep (mounting) side (46 scaled off the sketch; Cat 2026-11-02: 50, more room behind the pocket)
face_angle  = 8;      // [chosen]  degrees the camera face is turned
face_chamfer = 1.5;   // [chosen]  45 degree bevel on the camera-face edges; 0 = none

/* [Render] */
part = "block";   // [block, clash] clash = screw-wall check, must render empty

/* [Pocket] */
// Option 1 only (Cat, 2026-11-02): deeper than the shared pocket_depth (15 mm,
// still used by options 2-4) for room for the wires. The pocket's back wall is
// parallel to the block's back wall, as the sketch drew it (options 2-4 keep
// theirs parallel to the face), so the depth grows toward the deep side; this
// is the depth at its shallowest point, square to the face, at the pocket's
// shallow-side edge.
block_pocket_depth = 17;   // [chosen] shallowest depth behind the camera face

/* [Cable hole flare] */
// A funnel where the cable hole opens into the pocket, so the wire bends gently
// instead of turning a sharp 90 degree edge (Cat, 2026-11-02). It must stay
// min_screw_wall clear of the screw holes, and must not cut into the pocket floor
// (Cat, 2026-11-02); build.ps1 checks both. The funnel is trimmed flat at the
// pocket floor, so it flares on the top and sides and stops at the floor.
cable_flare_d   = 15;  // [chosen] mouth diameter at the pocket's back wall
cable_flare_floor = pocket_z_min;  // [chosen] height the funnel is trimmed flat at (the pocket floor)
cable_mouth_chamfer = 1.5;         // [chosen] 45 degree chamfer on the funnel's rim at the pocket wall, so no sharp edge; 0 = none
cable_flare_len = 8;   // [chosen] length of the funnel along the hole; longer = gentler bend

/* [Checks] */
min_screw_wall = 4;    // [chosen] plastic required between a screw hole and the pocket or flare

/* [Block mounting screws] */
screw_y           = 19.5;     // [scaled] distance from back face. The sketch centred it on the shallow side (19.1 at the old 46 depth); kept at 19.5 when the block went to 50 (Cat 2026-11-02) for ~7 mm of plastic below the pocket
screw_z           = [22, 88]; // [scaled] heights (kept, Cat 2026-11-02: lower would put the head bevel near the edge)
screw_head_recess = 0;        // [chosen] extra counterbore depth to shorten screws

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

// Pocket back wall: a plane parallel to the block's back (constant Y), placed so
// the pocket's shallow-side corner is block_pocket_depth behind the face
function pocket_wall_y() = let (u1 = face_u(pocket_deep_inset + pocket_width))
    face_y0 - u1 * sin(face_angle) - block_pocket_depth * cos(face_angle);

module pocket() {
    u0 = face_u(pocket_deep_inset);
    u1 = face_u(pocket_deep_inset + pocket_width);
    // sides square to the face (as before), back cut flat at pocket_wall_y();
    // extra +Y so the cut clears the face completely
    intersection() {
        on_face() translate([u0, -depth_deep, pocket_z_min])
            cube([u1 - u0, depth_deep + 5, pocket_z_max - pocket_z_min]);
        translate([-1, pocket_wall_y(), pocket_z_min - 1]) cube([width + 2, depth_deep, pocket_z_max - pocket_z_min + 2]);
    }
}

module cable_hole() {
    // From the back face into the pocket; stops inside the pocket void
    translate([cable_deep_inset, -eps, cable_z]) rotate([-90, 0, 0])
        cylinder(d = cable_d, h = depth_shallow);
}

// Funnel from the cable hole into the pocket. The pocket's back wall is square to
// the hole (both run along Y), so the funnel is a plain round blend (hull) from
// the hole's circle, cable_flare_len back, to the mouth circle on the wall,
// centred on the hole.
module disc(d) linear_extrude(0.01) circle(d = d);       // thin circle facing +Z

module cable_flare() {
    c = cable_mouth_chamfer;
    grow = (cable_flare_d - cable_d) / 2 / cable_flare_len;   // funnel radius gained per mm
    module at(y) translate([cable_deep_inset, y, cable_z]) rotate([-90, 0, 0]) children();
    w = pocket_wall_y();
    intersection() {
        union() {
            hull() { at(w - cable_flare_len) disc(cable_d); at(w) disc(cable_flare_d); }      // the funnel
            if (c > 0) hull() { at(w - c) disc(cable_flare_d - 2 * grow * c); at(w) disc(cable_flare_d + 2 * c); }   // 45 degree rim chamfer
            at(w - eps) cylinder(d = cable_flare_d + 2 * c, h = 3);                            // on into the open pocket
        }
        // trimmed flat at the pocket floor: flares up and sideways, never down into the floor
        translate([-1, -1, cable_flare_floor]) cube([width + 2, depth_deep + 2, height]);
    }
}

// Everything below the pocket floor: the funnel must not reach into it
module below_floor() {
    translate([-1, -1, -1]) cube([width + 2, depth_deep + 2, pocket_z_min - 0.05 + 1]);
}

// Keep-out around each screw hole: every cut must stay min_screw_wall away
module screw_keepout() {
    for (z = screw_z) translate([-1, screw_y, z]) rotate([0, 90, 0])
        cylinder(d = screw_d + 2 * min_screw_wall, h = width + 2);
}

module screw_holes() {
    sink = (screw_head_d - screw_d) / 2 / tan(screw_sink_angle / 2);  // countersink depth
    // Local +Z runs from the shallow side face toward the deep side
    for (z = screw_z) translate([width, screw_y, z]) rotate([0, -90, 0]) {
        translate([0, 0, -eps]) cylinder(d = screw_d, h = width + 2 * eps);
        translate([0, 0, -eps]) cylinder(d = screw_head_d, h = screw_head_recess + eps);
        translate([0, 0, screw_head_recess - eps])
            cylinder(d1 = screw_head_d, d2 = screw_d, h = sink + eps);
    }
}

if (part == "block") {
    difference() {
        block();
        face_chamfers();
        ring_holes();
        pocket();
        cable_hole();
        cable_flare();
        screw_holes();
    }
} else if (part == "clash") {
    // Must render EMPTY: the pocket or flare within min_screw_wall of a screw hole
    intersection() { union() { pocket(); cable_flare(); } screw_keepout(); }
    // ... and the funnel cutting into the pocket floor
    intersection() { cable_flare(); below_floor(); }
}
