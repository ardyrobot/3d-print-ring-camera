// Slide mount (option 3): a camera shell that slides on curved dovetail rails.
// All printed: the only metal is the two screws into the mounting surface.
// Edit values here, then run build.ps1.
//
// How it works
//   - The BASE screws to the surface like the other options (deep side against
//     the surface, screws through the width, cable in through the back). Its
//     front is a convex arc around a VIRTUAL PIVOT behind the wall, carrying two
//     curved dovetail rails.
//   - The SHELL has matching dovetail grooves in its concave back. Sliding it
//     along the rails turns it about the virtual pivot, so the camera face
//     turns away from the mounting surface. The dovetails hold it in every
//     other direction: no hinge, no bolts.
//   - A printed PIN pushed up from underneath locks the angle. The shell's
//     bottom has 7 holes, each engraved with its angle; under them the base has
//     7 holes laid out so each pair lines up at only one angle.
//   - Top and bottom hoods on the shell cover the base like a roof; the pin
//     holes face down, so rain can't collect in them.
//
// Source tags: [written] sketch value, [scaled] measured off sketch, [chosen] design decision.
//
// Coordinate frame (mm), same as the other options:
//   X = width,  0 = deep side (mounting surface)
//   Y = depth,  0 = back face (cable entry)
//   Z = height, 0 = bottom
// Angles around the pivot are measured from +Y, positive clockwise seen from
// above (toward +X), which is the direction the camera turns.
// The shell is modelled in its own frame: origin on the pivot, +Y toward the
// camera face. on_shell(a) turns it clockwise by a about the pivot.

include <ring_common.scad>

/* [Render] */
part           = "assembly";  // [assembly, base, shell, pin, fit_test, clash]
assembly_angle = 9;           // [3:2:15]
pin_label      = 0;           // which labelled hole the pin goes in; 0 = the one for assembly_angle (set otherwise to test a wrong hole)

/* [Print tolerances] */
gap          = 0.4;   // shell back to base front
dove_clr     = 0.3;   // dovetail rail in groove, every face
pin_free     = 0.4;   // pin in the shell hole (slides freely)
pin_snug     = -0.1;  // pin in the bottom of the base hole (slight grip)
swing_clr    = 0.5;   // shell and hoods to the frame and wall, at the range ends
foot_chamfer = 0.5;   // base bottom edge

/* [Envelope] */
width  = 55;   // [written] base width; also the shell face width
height = 110;  // [written]

/* [Angle range] */
angle_min  = 3;   // [chosen]
angle_max  = 15;  // [chosen]
angle_step = 2;   // [chosen]

/* [Virtual pivot and arc] */
pivot_x   = 26;   // [chosen] pivot position (behind the wall, so y < 0)
pivot_y   = -20;  // [chosen]
arc_r     = 50;   // [chosen] base front radius around the pivot
rail_half = 22;   // [chosen] rails span arc_mid +/- this many degrees

/* [Shell] */
face_y       = 62.4; // [chosen] camera face, shell frame (12 mm in front of the shell back)
wall         = 4;    // [chosen] hood thickness
face_chamfer = 1.5;  // [chosen] matches the other options
window_half  = 12;   // [chosen] wire window half-width
drain_d      = 3.5;  // [chosen]

/* [Dovetails] */
rail_z     = [18, 92]; // [chosen] rail centre heights
rail_root  = 8;        // [chosen] rail width where it meets the base
rail_h     = 4;        // [chosen] rail height
dove_angle = 30;       // [chosen] flank angle from radial; 30 = prints without supports

/* [Lock pin] */
pin_d      = 4.2;   // [chosen]
pin_len    = 14;    // [chosen] shank length
pin_head_d = 10;    // [chosen]
pin_head_t = 3;     // [chosen]
pin_depth  = 10;    // [chosen] depth into the base
// Two rows (radius around the pivot): outer row 3/7/11/15, inner row 5/9/13.
// Holes in different rows never line up, which leaves room between holes.
pin_rows   = [[44, 20, [3, 7, 11, 15]], [34, 13, [5, 9, 13]]]; // [chosen] [radius, first shell angle, angles]
pin_step   = -14;   // [chosen] shell angle between holes in a row
label_size = 3.5;   // [chosen]
engrave    = 0.6;   // [chosen]

/* [Base] */
pocket_z_min  = 30;   // [written]
pocket_z_max  = 60;   // [written]
pocket_depth  = 15;   // [chosen] behind the shell back
pocket_span   = [-5, 23]; // [chosen] pocket angular span, base frame
cable_d       = 8;    // [written]
cable_x       = 30;   // [chosen] moved from 17 so the cable lands inside the pocket
cable_z       = 35;   // [scaled]
screw_d       = 3.5;  // [written?]
screw_cbore_d = 9;    // [chosen]
screw_seat_x  = 40;   // [chosen] head seat; driven in from the open side
screw_y       = 10;   // [chosen] low enough to stay clear of the shell at 3 deg
screw_z       = [22, 88]; // [scaled]

$fn = 64;

// ---- derived ----
eps       = 0.01;
P         = [pivot_x, pivot_y];
arc_mid   = (angle_min + angle_max) / 2;
half      = width / 2;                 // shell half width
R_shell   = arc_r + gap;               // shell back radius
base_z0   = wall + gap;
base_z1   = height - wall - gap;
ring_z    = [(height - ring_hole_spacing) / 2, (height + ring_hole_spacing) / 2];
rail_tip  = rail_root + 2 * rail_h * tan(dove_angle);
// Grooves are closed at the frame-side end: when the shell turns past angle_max
// that end meets the rails' frame-side end, a hard stop at angle_max + 0.5.
// The other end is open, for sliding the shell on (on the bench, before mounting).
groove_start = arc_mid - rail_half - (angle_max + 0.5);
angles    = [for (a = [angle_min : angle_step : angle_max]) a];
// lock holes: [angle, radius, shell angle]
pin_holes = [for (row = pin_rows) for (k = [0 : len(row[2]) - 1]) [row[2][k], row[0], row[1] + pin_step * k]];

// Polar point around the pivot origin, angle from +Y clockwise
function polar(r, a) = [r * sin(a), r * cos(a)];

module on_shell(a) { translate([pivot_x, pivot_y, 0]) rotate([0, 0, -a]) children(); }
module on_shell_2d(a) { translate(P) rotate(-a) children(); }

// rotate_extrude between two clockwise-from-+Y angles a0 < a1, around the current origin
module arc_extrude(a0, a1) { rotate([0, 0, 90 - a1]) rotate_extrude(angle = a1 - a0, $fn = 360) children(); }

// Dovetail profile in the (radius, z) plane, centred on z = 0. The flanks run
// 1 mm into the base so the rail fuses with it instead of touching its surface
// along an edge (that made non-manifold mesh edges).
module dove_2d(grow = 0) {
    sunk = rail_root / 2 - tan(dove_angle);
    offset(delta = grow) polygon([
        [arc_r - 1, -sunk], [arc_r + rail_h, -rail_tip / 2],
        [arc_r + rail_h, rail_tip / 2], [arc_r - 1, sunk]]);
}

// ================= SHELL (shell frame) =================

// Region the hoods may cover: inside the shell width, behind the face, and
// clear of the wall and the frame at both ends of the range.
module hood_2d() {
    intersection() {
        translate([-half, -100]) square([width, 100 + face_y]);
        // wall: world y >= swing_clr at both range ends (written out: a for()
        // inside intersection() would union them)
        rotate(angle_min) translate([-200, -pivot_y + swing_clr]) square([400, 400]);
        rotate(angle_max) translate([-200, -pivot_y + swing_clr]) square([400, 400]);
        rotate(angle_min) translate([-pivot_x + swing_clr, -200]) square([400, 400]);   // frame: world x >= swing_clr
    }
}

module shell_body() {
    // camera plate: between the concave back and the flat face
    linear_extrude(height) difference() {
        translate([-half, 0]) square([width, face_y]);
        circle(r = R_shell, $fn = 360);
    }
    for (z = [0, height - wall]) translate([0, 0, z]) linear_extrude(wall) hood_2d();
}

module face_chamfers() {
    s = face_chamfer * sqrt(2);
    for (x = [-half, half]) translate([x, face_y, height / 2]) rotate([0, 0, 45]) cube([s, s, height + 2], center = true);
    for (z = [0, height]) translate([0, face_y, z]) rotate([45, 0, 0]) cube([width + 2, s, s], center = true);
}

module pin_labels() {
    for (h = pin_holes) {
        p = polar(h[1] + 4.6, h[2]);
        // engraved into the underside, mirrored so it reads correctly from below
        translate([p[0], p[1], -eps]) mirror([1, 0, 0])
            linear_extrude(engrave + eps) text(str(h[0]), size = label_size, halign = "center", valign = "center");
    }
}

module shell_local() {
    difference() {
        shell_body();
        // dovetail grooves: closed at groove_start (end stop), open past the shell's open side
        for (z = rail_z) translate([0, 0, z]) arc_extrude(groove_start, 60) dove_2d(dove_clr);
        // wire window
        translate([-window_half, R_shell - 5, pocket_z_min + 2]) cube([2 * window_half, face_y, pocket_z_max - pocket_z_min - 4]);
        // Ring holes
        for (z = ring_z) translate([0, face_y + eps, z]) rotate([90, 0, 0]) cylinder(d = ring_hole_d, h = ring_hole_depth + eps);
        // lock holes through the bottom hood, with their angle labels
        for (h = pin_holes) { p = polar(h[1], h[2]); translate([p[0], p[1], -1]) cylinder(d = pin_d + pin_free, h = wall + 2); }
        pin_labels();
        // drain in front of the base
        translate([0, R_shell + 4, -1]) cylinder(d = drain_d, h = wall + 2);
        face_chamfers();
    }
}

// ================= BASE (world frame) =================

module base(z0 = base_z0, z1 = base_z1) {
    difference() {
        union() {
            hull() {   // base_2d is convex, so a hull gives the bottom chamfer
                translate([0, 0, z0]) linear_extrude(eps) offset(delta = -foot_chamfer) base_2d();
                translate([0, 0, z0 + foot_chamfer]) linear_extrude(z1 - z0 - foot_chamfer) base_2d();
            }
            // curved dovetail rails
            for (z = rail_z) if (z > z0 && z < z1)
                translate([pivot_x, pivot_y, z]) arc_extrude(arc_mid - rail_half, arc_mid + rail_half) dove_2d();
        }
        // wiring pocket: a curved slot whose floor is pocket_depth behind the shell back
        translate([pivot_x, pivot_y, pocket_z_min]) linear_extrude(pocket_z_max - pocket_z_min)
            polygon(concat([for (a = [pocket_span[0] : 2 : pocket_span[1]]) polar(R_shell - pocket_depth, a)],
                           [for (a = [pocket_span[1] : -2 : pocket_span[0]]) polar(arc_r + 10, a)]));
        // cable from the back face into the pocket
        translate([cable_x, -eps, cable_z]) rotate([-90, 0, 0]) cylinder(d = cable_d, h = 40);
        // mounting screws through the width, driven from the open side
        for (z = screw_z) translate([0, screw_y, z]) rotate([0, 90, 0]) {
            translate([0, 0, -eps]) cylinder(d = screw_d, h = width + 1);
            translate([0, 0, screw_seat_x]) cylinder(d = screw_cbore_d, h = width);
        }
        // lock holes from below: each lines up with its shell hole at its angle only
        for (h = pin_holes) {
            p = polar(h[1], h[2] + h[0]);
            translate([pivot_x + p[0], pivot_y + p[1], z0 - 1]) {
                cylinder(d = pin_d + pin_free, h = pin_depth - 4 + 1);
                cylinder(d = pin_d + pin_snug, h = pin_depth + 1);
            }
        }
    }
}

module base_2d() {
    intersection() {
        square([width, 200]);
        // turned half a facet so its vertices never coincide with the rails'
        // (both use 1 degree steps; shared vertices made non-manifold edges)
        translate(P) rotate(0.5) circle(r = arc_r, $fn = 360);
    }
}

// ================= PIN =================

module pin(d = pin_d) {   // head at z = 0, shank upward
    cylinder(d = pin_head_d, h = pin_head_t);
    translate([0, 0, pin_head_t - eps]) cylinder(d = d, h = pin_len - 0.6);
    translate([0, 0, pin_head_t + pin_len - 0.6 - eps]) cylinder(d1 = d, d2 = d - 1.2, h = 0.6);
}

module pin_print() {   // lying down on a 0.4 mm flat, so layers run along the pin (strong in shear)
    flat = 0.4;
    translate([0, 0, pin_head_d / 2 - flat]) rotate([0, 90, 0]) difference() {
        pin();
        translate([-50, -pin_head_d / 2 - 50 + flat, -1]) cube([100, 50, 100]);
    }
}

// Pin through the shell hole labelled `label`, with the shell at angle a
module pin_world(a, d = pin_d, drop = 0, label = 0) {
    h = [for (x = pin_holes) if (x[0] == (label == 0 ? a : label)) x][0];
    p = polar(h[1], h[2] + a);
    translate([pivot_x + p[0], pivot_y + p[1], -pin_head_t - drop]) pin(d);
}

// ================= OUTPUT =================

if (part == "assembly") {
    base();
    on_shell(assembly_angle) shell_local();
    pin_world(assembly_angle);
} else if (part == "base") {
    base();
} else if (part == "shell") {
    translate([0, 0, face_y]) rotate([-90, 0, 0]) shell_local();   // camera face down
} else if (part == "pin") {
    pin_print();
} else if (part == "fit_test") {
    // 16 mm slice through the lower rail: base strip, shell strip, pin. Same print
    // orientations as the full parts. Check the dovetail slide and the pin fit.
    band = [0, rail_z[0] + 8];   // bottom hood, lock holes and lower rail
    translate([0, 0, -base_z0]) base(base_z0, band[1]);
    translate([0, 40, face_y]) rotate([-90, 0, 0]) intersection() {
        shell_local();
        translate([-100, -100, band[0]]) cube([200, 200, band[1] - band[0]]);
    }
    translate([70, 0, 0]) pin_print();
} else if (part == "clash") {
    // Must render EMPTY at every angle: base vs shell, and the pin through both.
    // The check pin is just under the snug diameter, so the deliberate grip at
    // the bottom of the base hole doesn't count, but a misaligned hole does.
    // It also sits 0.05 mm low, so the head resting on the hood isn't reported.
    cd = pin_d + pin_snug - 0.05;
    intersection() { base(); on_shell(assembly_angle) shell_local(); }
    intersection() { base(); pin_world(assembly_angle, cd, 0.05, pin_label); }
    intersection() { on_shell(assembly_angle) shell_local(); pin_world(assembly_angle, cd, 0.05, pin_label); }
}
