// Adjustable Ring camera mount: a camera shell nested over a hinged base.
// Secondary print option; the solid block (option 1, option1-solid/option1_solid.scad) stays the primary part.
// Edit values here, then run build.ps1.
//
// How it works
//   - The BASE screws to the mounting surface exactly like the solid block
//     (deep side against the surface, two screws through the width, cable in
//     through the back). Its screw heads end up hidden under the shell.
//   - The SHELL carries the Ring. It pivots on two M4 bolts (top and bottom)
//     about a vertical axis near the deep side, and wraps over the base so the
//     part looks like one block at every angle.
//   - The shallow end of the base is a cylinder centred on the hinge axis, so
//     the shell's curved skirt slides over it with a constant gap.
//   - A toothed WASHER under one M4 clamp bolt locks into teeth on the skirt:
//     one tooth = 2 degrees, 3..15 degrees. The bolt carries the angle in shear,
//     so clamp friction is not what holds it (resists plastic creep outdoors).
//   - The skirt's trailing edge is the pointer: read the angle on the scale
//     engraved on the base, at the edge of the shell.
//
// Source tags: [written] sketch value, [scaled] measured off sketch, [chosen] design decision.
//
// Coordinate frame (mm), same as option 1:
//   X = width,  0 = deep side (mounting surface), 55 = shallow side
//   Y = depth,  0 = back face (cable entry)
//   Z = height, 0 = bottom
// The shell is modelled in its own frame: origin on the hinge axis, +X along the
// camera face toward the shallow side, +Y out of the face. on_shell(a) places it.

// Fixed measurements shared by all options: width, height, Ring holes, pocket,
// cable hole, mounting screws. Edit them in mount_common.scad, not here.
include <../mount_common.scad>

/* [Render] */
part           = "assembly";  // [assembly, base, shell, washer, fit_test, clash]
assembly_angle = 9;           // [3:2:15] shell angle for assembly / clash

/* [Print tolerances] */
// Starting values for a 0.4 mm nozzle. Print part="fit_test" first and tune
// these to your printer before printing the full parts.
gap          = 0.4;   // sliding gap: skirt over base, top/bottom plates over base
tooth_clr    = 0.25;  // washer teeth clearance (tips and roots)
bolt_d       = 4.5;   // M4 clearance hole
nut_af       = 7.4;   // M4 nut across flats (7.0) + clearance
nut_t        = 3.6;   // M4 nut thickness (3.2) + clearance
washer_side  = 0.3;   // washer to track walls, each side
swing_clr    = 1.0;   // camera plate and Ring bosses to base, through the swing
foot_chamfer = 0.5;   // base bottom edge, absorbs first-layer squash (elephant's foot)

/* [Angle range] */
angle_min  = 3;   // [chosen]
angle_max  = 15;  // [chosen]
angle_step = 2;   // [chosen] one tooth

/* [Shell] */
wall         = 4;    // [chosen] skirt and top/bottom plate thickness
face_t      = 5;    // [chosen] camera plate thickness
face_back    = 10;   // [chosen] hinge axis to back of camera plate
face_chamfer = 1.5;  // [chosen] matches the solid block
skirt_end    = -20;  // [chosen] trailing edge angle of the skirt, shell frame
boss_d       = 8;    // [chosen] bosses behind the Ring holes
drain_d      = 3.5;  // [chosen] drain hole in the bottom plate

/* [Hinge] */
hinge_x      = 6.5;  // [chosen] axis distance from the mounting surface
hinge_y      = 30;   // [chosen] axis distance from the back face
hinge_nut_in = 8;    // [chosen] nut depth below base top/bottom

/* [Clamp and teeth] */
clamp_angle  = -10;  // [chosen] clamp bolt direction, base frame
clamp_z      = 70;   // [chosen]
clamp_nut_r  = 38;   // [chosen] nut distance from hinge axis
track_depth  = 1.5;  // [chosen] recess in the skirt for the washer
tooth_h      = 0.9;  // [chosen] 2 deg pitch is ~1.7 mm at this radius
washer_half  = 7;    // [chosen] washer half-width, degrees (odd)
washer_h     = 14;   // [chosen]
washer_t     = 3;    // [chosen] washer thickness beyond the skirt surface

/* [Base] */
// pocket_depth (shared) is measured from the back of the camera plate at angle_max
screw_y           = 19.5;  // [scaled] distance from back face (position not fixed; size is shared)
screw_z           = [22, 88]; // [scaled] heights
screw_cbore_d     = 9.4;   // [chosen] counterbore so heads sit under the skirt (#8 head 8.43 mm + clearance)
screw_seat_x      = 40;    // [chosen] screw head seat; screw length = this + embedment

/* [Scale] */
label_angles = [3, 9, 15]; // [chosen] numbered ticks
text_size    = 3.2;   // [chosen] label height
engrave      = 0.6;   // [chosen] engraving depth

$fn = 64;

// ---- derived ----
eps     = 0.01;
face_x0 = -hinge_x;
face_x1 = width - hinge_x;
face_front = face_back + face_t;
R_out   = norm([face_x1, face_front]);        // skirt outer radius
R_in    = R_out - wall;
R_base  = R_in - gap;                          // base cylinder radius
skirt_start = atan2(face_front, face_x1);     // where the skirt meets the face
base_z0 = wall + gap;
base_z1 = height - wall - gap;
base_front = face_back - swing_clr;            // base front, shell frame
ring_x  = (face_x0 + face_x1) / 2;
ring_z  = [(height - ring_hole_spacing) / 2, (height + ring_hole_spacing) / 2];
r_floor = R_out - track_depth;                 // track floor = tooth roots
angles  = [for (a = [angle_min : angle_step : angle_max]) a];

function arc(r, a0, a1, n = 48) =
    [for (i = [0 : n]) r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];

module sector(r0, r1, a0, a1) { polygon(concat(arc(r1, a0, a1), arc(r0, a1, a0))); }

module on_shell(a) { translate([hinge_x, hinge_y, 0]) rotate([0, 0, -a]) children(); }
module on_shell_2d(a) { translate([hinge_x, hinge_y]) rotate(-a) children(); }

// Radial cylinder at angle a (about the hinge axis, in whatever frame is current)
module radial(a, r0, len, d, z) {
    rotate([0, 0, a]) translate([r0, 0, z]) rotate([0, 90, 0]) cylinder(d = d, h = len);
}

// Sawtooth on a circle: valleys at r where (a - a_valley) is a multiple of the
// pitch, peaks tooth_h higher in between. 1 degree steps = half a 2 degree pitch.
function teeth_pts(r, a0, a1, a_valley, rise) =
    [for (a = [a0 : 1 : a1]) (abs(a - a_valley) % 2 == 0 ? r : r + rise) * [cos(a), sin(a)]];

// ================= SHELL (shell frame) =================

module plate_2d() {
    hull() {
        circle(r = hinge_x - 0.5);
        polygon(concat([[face_x0, face_front]], arc(R_out, skirt_start, skirt_end)));
    }
}

module shell_teeth() {
    a0 = clamp_angle + angle_min - washer_half;
    a1 = clamp_angle + angle_max + washer_half;
    translate([0, 0, clamp_z - washer_h / 2 - washer_side])
        linear_extrude(washer_h + 2 * washer_side)
            polygon(concat(teeth_pts(r_floor, a0, a1, clamp_angle + angle_min, tooth_h),
                           arc(r_floor - 0.5, a1, a0)));
}

module shell_body() {
    // camera plate
    translate([face_x0, face_back, 0]) cube([face_x1 - face_x0, face_t, height]);
    // curved skirt
    linear_extrude(height) sector(R_in, R_out, skirt_end, skirt_start);
    // top and bottom plates (the hinge leaves)
    for (z = [0, height - wall]) translate([0, 0, z]) linear_extrude(wall) plate_2d();
    // bosses behind the Ring holes
    for (z = ring_z) translate([ring_x, face_back + eps, z]) rotate([90, 0, 0])
        cylinder(d = boss_d, h = face_back - (face_front - ring_hole_depth) + eps);
}

module face_chamfers() {
    s = face_chamfer * sqrt(2);
    if (face_chamfer > 0) {
        for (x = [face_x0, face_x1]) translate([x, face_front, height / 2])
            rotate([0, 0, 45]) cube([s, s, height + 2], center = true);
        for (z = [0, height]) translate([(face_x0 + face_x1) / 2, face_front, z])
            rotate([45, 0, 0]) cube([face_x1 - face_x0 + 2, s, s], center = true);
    }
}

module shell_local() {
    difference() {
        union() {
            difference() {
                shell_body();
                // recessed track for the washer; floor sits just above the tooth
                // roots so teeth fuse into the skirt instead of touching it
                translate([0, 0, clamp_z - washer_h / 2 - washer_side])
                    linear_extrude(washer_h + 2 * washer_side)
                        sector(r_floor + 0.05, R_out + 1,
                               clamp_angle + angle_min - washer_half - 0.5,
                               clamp_angle + angle_max + washer_half + 0.5);
            }
            intersection() {   // keep teeth inside the skirt envelope
                shell_teeth();
                cylinder(r = R_out, h = height);
            }
        }
        // curved slot: the clamp bolt's path from angle_min to angle_max.
        // Steps sit between whole degrees so slot vertices never land exactly
        // on tooth ridges (that produced degenerate mesh edges).
        slot_a = concat([angle_min], [for (a = [angle_min + 0.5 : 1 : angle_max]) a], [angle_max]);
        for (i = [0 : len(slot_a) - 2]) hull() {
            radial(clamp_angle + slot_a[i],     R_in - 2, wall + 4, bolt_d + 0.1, clamp_z);
            radial(clamp_angle + slot_a[i + 1], R_in - 2, wall + 4, bolt_d + 0.1, clamp_z);
        }
        // Ring holes
        for (z = ring_z) translate([ring_x, face_front + eps, z]) rotate([90, 0, 0])
            cylinder(d = ring_hole_d, h = ring_hole_depth + eps);
        // wire window: Ring wiring passes from the base pocket to the camera,
        // same footprint as the solid block's pocket; the Ring backplate covers it
        translate([pocket_deep_inset - hinge_x, face_back - 1, pocket_z_min])
            cube([pocket_width, face_t + 2, pocket_z_max - pocket_z_min]);
        // hinge bolt holes
        translate([0, 0, -1]) cylinder(d = bolt_d, h = height + 2);
        // drain at the low point of the cavity
        translate([ring_x + 18, face_back - 2, -1]) cylinder(d = drain_d, h = wall + 2);
        face_chamfers();
    }
}

// ================= WASHER (bolt frame: bolt along +X) =================

module washer_boltframe() {
    pts = concat(
        [for (a = [-washer_half : 1 : washer_half])
            (abs(a) % 2 == 0 ? r_floor + tooth_clr : r_floor + tooth_h + tooth_clr) * [cos(a), sin(a)]],
        [[R_out + washer_t, (R_out + washer_t) * tan(washer_half)],
         [R_out + washer_t, -(R_out + washer_t) * tan(washer_half)]]);
    difference() {
        translate([0, 0, clamp_z - washer_h / 2]) linear_extrude(washer_h)
            intersection() {
                polygon(pts);
                translate([0, -50]) square([R_out + washer_t, 100]);  // flat bolt face
            }
        radial(0, r_floor - 2, washer_t + track_depth + 4, bolt_d, clamp_z);
    }
}

// Flat bolt face down on the bed, near the origin
module washer_print() {
    // rotate([0,90,0]) maps z -> x, so the washer's clamp_z height lands at x = clamp_z
    translate([-clamp_z, 0, R_out + washer_t]) rotate([0, 90, 0]) washer_boltframe();
}

module washer_world() {
    translate([hinge_x, hinge_y, 0]) rotate([0, 0, clamp_angle]) washer_boltframe();
}

// ================= BASE (world frame) =================

module base_2d() {
    intersection() {
        square([width, 200]);
        translate([hinge_x, hinge_y]) circle(r = R_base, $fn = 256);
        // stay behind the camera plate at both ends of the range. Written out
        // twice on purpose: a for() inside intersection() would union them.
        on_shell_2d(angle_min) translate([-200, -400]) square([400, 400 + base_front]);
        on_shell_2d(angle_max) translate([-200, -400]) square([400, 400 + base_front]);
    }
}

module scale_marks() {
    for (t = angles) {
        a = skirt_end - t;               // where the skirt edge sits at angle t
        long = len(search(t, label_angles)) > 0;
        translate([hinge_x, hinge_y, 0]) rotate([0, 0, a]) {
            translate([R_base - engrave, -0.3, 40]) cube([1, 0.6, long ? 10 : 6]);
            if (long) translate([R_base - engrave, 0, 55]) rotate([0, 90, 0]) rotate([0, 0, 90])
                linear_extrude(1) text(str(t), size = text_size, halign = "center", valign = "center");
        }
    }
}

// z0/z1 let the fit test cut a slice; the bottom edge (print bed side) is
// chamfered by foot_chamfer. base_2d is convex, so a hull makes the chamfer.
module base(z0 = base_z0, z1 = base_z1) {
    difference() {
        hull() {
            translate([0, 0, z0]) linear_extrude(eps) offset(delta = -foot_chamfer) base_2d();
            translate([0, 0, z0 + foot_chamfer]) linear_extrude(z1 - z0 - foot_chamfer) base_2d();
        }

        // wiring pocket, 15 mm behind the camera plate at the steepest angle
        on_shell(angle_max) translate([pocket_deep_inset - hinge_x, face_back - pocket_depth, pocket_z_min])
            cube([pocket_width, pocket_depth + 10, pocket_z_max - pocket_z_min]);

        // clearance for the Ring bosses through the whole swing
        for (z = ring_z) hull() for (a = [angle_min, (angle_min + angle_max) / 2, angle_max])
            on_shell(a) translate([ring_x, face_back + swing_clr, z]) rotate([90, 0, 0])
                cylinder(d = boss_d + 2 * swing_clr,
                         h = face_back + 2 * swing_clr - (face_front - ring_hole_depth));

        // cable from the back face into the pocket
        translate([cable_deep_inset, -eps, cable_z]) rotate([-90, 0, 0])
            cylinder(d = cable_d, h = hinge_y);

        // mounting screws through the width, heads hidden under the skirt
        // (flat-head screws: an 82 degree countersink at the bottom of the counterbore)
        sink = (screw_head_d - screw_d) / 2 / tan(screw_sink_angle / 2);
        for (z = screw_z) translate([0, screw_y, z]) rotate([0, 90, 0]) {
            translate([0, 0, -eps]) cylinder(d = screw_d, h = width);
            translate([0, 0, screw_seat_x - sink]) cylinder(d1 = screw_d, d2 = screw_head_d, h = sink + eps);
            translate([0, 0, screw_seat_x]) cylinder(d = screw_cbore_d, h = width);
        }

        // hinge bolts and captive nuts (nuts slide in from the mounting face)
        for (top = [true, false]) {
            zb = top ? base_z1 - 14 : base_z0 - 1;
            zn = top ? base_z1 - hinge_nut_in : base_z0 + hinge_nut_in;
            translate([hinge_x, hinge_y, zb]) cylinder(d = bolt_d, h = 15);
            translate([-eps, hinge_y - nut_af / 2, zn - nut_t / 2]) cube([hinge_x + 4.2, nut_af, nut_t]);
        }

        // clamp bolt and captive nut (nut slides in from the back face)
        translate([hinge_x, hinge_y, 0]) rotate([0, 0, clamp_angle]) {
            radial(0, clamp_nut_r - 7, R_base, bolt_d, clamp_z);
            translate([clamp_nut_r - nut_t / 2, -40, clamp_z - nut_af / 2])
                cube([nut_t, 40 + 4.2, nut_af]);
        }

        scale_marks();
    }
}

// ================= OUTPUT =================

if (part == "assembly") {
    base();
    on_shell(assembly_angle) shell_local();
    washer_world();
} else if (part == "base") {
    base();                                            // prints standing on its bottom
} else if (part == "shell") {
    translate([0, 0, face_front]) rotate([-90, 0, 0]) shell_local();  // camera face down
} else if (part == "washer") {
    washer_print();
} else if (part == "fit_test") {
    // 16 mm slice through the clamp: base puck, skirt with teeth and slot, washer.
    // Each piece in the same print orientation as the full part, so the fit
    // matches. Assemble with the clamp bolt and nut, check slide and tooth mesh.
    band = [clamp_z - 8, clamp_z + 8];
    translate([0, 0, -band[0]]) base(band[0], band[1]);
    translate([0, 0, face_front]) rotate([-90, 0, 0]) intersection() {
        shell_local();
        translate([-100, -100, band[0]]) cube([200, 200, band[1] - band[0]]);
    }
    translate([65, 10, 0]) washer_print();
} else if (part == "clash") {
    // Must render EMPTY: any solid here is a collision at assembly_angle
    intersection() { base(); on_shell(assembly_angle) shell_local(); }
    intersection() { base(); washer_world(); }
    intersection() { on_shell(assembly_angle) shell_local(); washer_world(); }
}
