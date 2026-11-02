// Pivot mount (option 4): base with a roof, shell that slides up under it and
// pivots on a screw. Secondary print option; the solid block stays the primary part.
// Edit values here, then run build.ps1.
//
// How it works
//   - The BASE screws to the mounting surface first, with nothing in the way:
//     two #8 flat-head screws through the width, heads at the shallow side.
//     Its top is a ROOF (water cap) that overhangs the shell at every angle.
//   - The SHELL carries the Ring. It slides up from below at the install angle
//     (Ring bosses pass up a channel in the base) until it sits under the roof.
//   - An M5 stainless socket-head screw from below (the PIVOT SCREW) goes
//     through the shell's bottom plate into a thread in the base, on the hinge
//     axis. (A thumb screw head would hit the mounting surface: the axis is
//     only 6.5 mm from it. Adjusting never touches this screw.)
//   - A second M5 thumb screw (the LOCK SCREW) goes up through a printed toothed
//     WASHER and a curved slot in the bottom plate into a second thread in the
//     base. Tightening it pulls the washer's teeth into teeth on the plate's
//     underside: one tooth = 3 degrees, 3..15 degrees. The screw holds the
//     angle in shear, so clamp friction is not what holds it.
//   - To adjust: loosen the lock screw about 2 turns (washer drops off the
//     teeth but stays in its track), turn the shell, tighten. The shell
//     does not drop and the pivot screw stays snug.
//   - Threads are modelled in the print (right-hand M5 x 0.8).
//
// Source tags: [written] sketch value, [scaled] measured off sketch, [chosen] design decision.
//
// Coordinate frame (mm), same as the other options:
//   X = width,  0 = deep side (mounting surface), 55 = shallow side
//   Y = depth,  0 = back face (cable entry, assumed against a wall)
//   Z = height, 0 = bottom
// The shell is modelled in its own frame: origin on the hinge axis, +X along the
// camera face toward the shallow side, +Y out of the face. on_shell(a) places it.

// Fixed measurements shared by all options: width, height, Ring holes, pocket,
// cable hole, mounting screws. Edit them in mount_common.scad, not here.
include <mount_common.scad>

/* [Render] */
part           = "assembly";  // [assembly, base, shell, washer, fit_test, clash, install]
assembly_angle = 9;           // [3:3:15] shell angle for assembly / clash
install_drop   = 50;          // [0:110] how far below its seat the shell is, for part="install"

/* [Print tolerances] */
// Starting values for a 0.4 mm nozzle. Print part="fit_test" first and tune
// these to your printer before printing the full parts.
gap          = 0.4;   // sliding gap: skirt over base, bottom plate under base
roof_clr     = 0.8;   // shell top to roof underside (0.4 left once the screws pull the plate up)
tooth_clr    = 0.25;  // washer teeth clearance (tips and roots)
track_clr    = 0.5;   // washer to track walls, each side
thread_clr   = 0.3;   // added to the M5 thread diameters in the base
screw_clr_d  = 5.5;   // M5 clearance hole / slot width in the shell and washer
swing_clr    = 1.0;   // camera plate and Ring bosses to base, through the swing
foot_chamfer = 0.5;   // first-layer edge chamfer (elephant's foot)

/* [Angle range] */
angle_min     = 3;   // [chosen]
angle_max     = 15;  // [chosen]
angle_step    = 3;   // [chosen] one tooth
install_angle = 9;   // [chosen] angle the shell slides up at (boss channel)

/* [Shell] */
wall         = 4;    // [chosen] skirt thickness
plate_t      = 6;    // [chosen] bottom plate thickness
face_t       = 5;    // [chosen] camera plate thickness
face_back    = 10;   // [chosen] hinge axis to back of camera plate
face_chamfer = 1.5;  // [chosen] matches the solid block
skirt_end    = -15;  // [chosen] trailing edge angle of the skirt, shell frame (4.6 mm off the wall at 15)
boss_d       = 8;    // [chosen] bosses behind the Ring holes
drain_d      = 3.5;  // [chosen] drain hole in the bottom plate

/* [Base and roof] */
roof_t        = 4;     // [chosen]
hinge_x       = 6.5;   // [chosen] pivot axis distance from the mounting surface
hinge_y       = 30;    // [chosen] pivot axis distance from the back face
screw_y       = 19.5;  // [scaled] distance from back face (position not fixed; size is shared)
screw_z       = [25, 88]; // [chosen] heights; 25 (not 22) keeps 4 mm of plastic above the lock thread
screw_seat_x  = 49;    // [chosen] screw head seat; screw length = this + embedment (~75 mm, 3 in)
screw_cbore_d = 9.4;   // [chosen] counterbore so heads sit under the skirt

/* [Lock] */
lock_r      = 35;   // [chosen] lock screw distance from the pivot axis
lock_a      = -10;  // [chosen] lock screw direction from the pivot, base frame
tooth_h     = 0.9;  // [chosen] 3 deg pitch is 1.83 mm at lock_r
track_d     = 2;    // [chosen] washer track recessed into the plate underside
washer_half = 6;    // [chosen] washer half-width, degrees (4 teeth)
washer_band = 6;    // [chosen] washer half-width, radial
washer_t    = 4;    // [chosen] washer body thickness below the teeth

/* [Threads] */
thread_p       = 0.8;  // [chosen] M5 coarse pitch
pivot_thread_l = 15;   // [chosen] thread depth into the base (M5 x 20 screw engages ~13.6)
lock_thread_l  = 12;   // [chosen] thread depth into the base (M5 x 20 screw engages ~10.4)
pivot_head_d   = 8.5;  // [chosen] M5 socket-head cap screw (ISO 4762)
lock_head_d    = 16;   // [chosen] M5 knurled thumb screw head, typical (check the one you buy)

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
base_z0 = plate_t + gap;
roof_z  = height - roof_t;                     // roof underside
shell_top = roof_z - roof_clr;
base_front = face_back - swing_clr;            // base front, shell frame
ring_x  = (face_x0 + face_x1) / 2;
ring_z  = [(height - ring_hole_spacing) / 2, (height + ring_hole_spacing) / 2];
angles  = [for (a = [angle_min : angle_step : angle_max]) a];
track_a = [lock_a + angle_min - washer_half - track_clr / lock_r * 180 / PI - 1,
           lock_a + angle_max + washer_half + track_clr / lock_r * 180 / PI + 1];
washer_z0 = track_d - tooth_h - tooth_clr;     // washer roots (top face), shell frame z

function arc(r, a0, a1, n = 48) =
    [for (i = [0 : n]) r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];

module sector(r0, r1, a0, a1, n = 48) { polygon(concat(arc(r1, a0, a1, n), arc(r0, a1, a0, n))); }

module on_shell(a) { translate([hinge_x, hinge_y, 0]) rotate([0, 0, -a]) children(); }
module on_shell_2d(a) { translate([hinge_x, hinge_y]) rotate(-a) children(); }

// Face-tooth strip: radial ridges every angle_step degrees between radii r0 and
// r1, angles a0..a1. Surface zigzags between z_flat and z_tip (tips at angles
// a_tip + k * angle_step); the solid fills from the zigzag to z_back.
module tooth_strip(r0, r1, a0, a1, a_tip, z_flat, z_tip, z_back) {
    half = angle_step / 2;
    g0 = a_tip + half * ceil((a0 - a_tip) / half - 1e-6);    // snap the ends to the tooth grid
    n = round((a_tip + half * floor((a1 - a_tip) / half + 1e-6) - g0) / half);
    function ang(i) = g0 + i * half;
    function zz(i) = abs((ang(i) - a_tip) / angle_step - round((ang(i) - a_tip) / angle_step)) < 0.25
                     ? z_tip : z_flat;
    function p(r, i, z) = [r * cos(ang(i)), r * sin(ang(i)), z];
    // vertex blocks: inner zigzag, outer zigzag, inner back, outer back
    pts = concat([for (i = [0 : n]) p(r0, i, zz(i))], [for (i = [0 : n]) p(r1, i, zz(i))],
                 [for (i = [0 : n]) p(r0, i, z_back)], [for (i = [0 : n]) p(r1, i, z_back)]);
    I = 0; O = n + 1; IB = 2 * (n + 1); OB = 3 * (n + 1);
    up = z_back > z_flat;   // solid above the zigzag (shell) or below it (washer)
    function f(t) = up ? t : [t[0], t[2], t[1]];
    faces = concat(
        [for (i = [0 : n - 1]) each [f([I + i, O + i, O + i + 1]), f([I + i, O + i + 1, I + i + 1])]],
        [for (i = [0 : n - 1]) each [f([IB + i, IB + i + 1, OB + i + 1]), f([IB + i, OB + i + 1, OB + i])]],
        [for (i = [0 : n - 1]) each [f([I + i, I + i + 1, IB + i + 1]), f([I + i, IB + i + 1, IB + i])]],
        [for (i = [0 : n - 1]) each [f([O + i, OB + i, OB + i + 1]), f([O + i, OB + i + 1, O + i + 1])]],
        [f([I, IB, OB]), f([I, OB, O]), f([I + n, O + n, OB + n]), f([I + n, OB + n, IB + n])]);
    polyhedron(pts, faces);
}

// Right-hand internal M5 thread void, length l, starting at z = 0 going up.
// Cross-section at z = 0 is the ISO profile wrapped once round the axis; a
// negative twist turns it counter-clockwise going up (checked: right-hand).
module thread_void(l) {
    rmin = (5 - 1.0825 * thread_p + thread_clr) / 2;   // nut minor diameter
    rmaj = (5 + thread_clr) / 2 + 0.05;                 // nut major + root relief
    function prof(u) = let (t = abs(u - floor(u) - 0.5) * 2)   // 0 mid-groove, 1 at crest
        rmaj - (rmaj - rmin) * min(1, max(0, (t - 0.125) / 0.625));
    pts = [for (i = [0 : 71]) let (a = i * 5) prof(-a / 360) * [cos(a), sin(a)]];
    linear_extrude(l, twist = -360 * l / thread_p, slices = ceil(l / thread_p * 24), convexity = 4)
        polygon(pts);
    translate([0, 0, -1]) cylinder(r1 = rmaj + 1, r2 = rmin, h = rmaj + 1 - rmin + 1);   // lead-in
}

// ================= SHELL (shell frame) =================

module plate_2d() {
    hull() {
        circle(r = hinge_x - 0.5);
        polygon(concat([[face_x0, face_front]], arc(R_out, skirt_start, skirt_end)));
    }
}

module shell_body() {
    // camera plate
    translate([face_x0, face_back, 0]) cube([face_x1 - face_x0, face_t, shell_top]);
    // curved skirt
    linear_extrude(shell_top) sector(R_in, R_out, skirt_end, skirt_start);
    // bottom plate (the only hinge leaf; the roof covers the top)
    linear_extrude(plate_t) plate_2d();
    // bosses behind the Ring holes
    for (z = ring_z) translate([ring_x, face_back + eps, z]) rotate([90, 0, 0])
        cylinder(d = boss_d, h = face_back - (face_front - ring_hole_depth) + eps);
}

module face_chamfers() {
    s = face_chamfer * sqrt(2);
    if (face_chamfer > 0) {
        for (x = [face_x0, face_x1]) translate([x, face_front, height / 2])
            rotate([0, 0, 45]) cube([s, s, height + 2], center = true);
        for (z = [0, shell_top]) translate([(face_x0 + face_x1) / 2, face_front, z])
            rotate([45, 0, 0]) cube([face_x1 - face_x0 + 2, s, s], center = true);
    }
}

// lock screw position in the shell frame at angle a
function lock_local(a) = lock_r * [cos(lock_a + a), sin(lock_a + a)];

module shell_local() {
    difference() {
        union() {
            difference() {
                shell_body();
                // washer track in the plate underside. Odd segment count: the
                // track is centred on a tooth ridge, and an arc vertex on a
                // ridge pinched the mesh.
                translate([0, 0, -eps]) linear_extrude(track_d + eps)
                    sector(lock_r - washer_band - track_clr, lock_r + washer_band + track_clr,
                           track_a[0], track_a[1], 47);
            }
            // teeth hang from the track ceiling; tips line up with the washer's
            // roots whenever the angle is a whole number of teeth. The strip runs
            // 0.3 mm into the track walls so it fuses with the plate.
            tooth_strip(lock_r - washer_band - track_clr - 0.3, lock_r + washer_band + track_clr + 0.3,
                        track_a[0], track_a[1], lock_a,
                        track_d, track_d - tooth_h, track_d + 0.5);
        }
        // curved slot: the lock screw's path from angle_min to angle_max
        // (ends 0.25 deg long and half-degree steps keep slot vertices off the
        // tooth ridges, which sit on whole teeth; on a ridge the mesh pinched)
        slot_a = concat([angle_min - 0.25], [for (a = [angle_min + 0.5 : 1 : angle_max]) a], [angle_max + 0.25]);
        for (i = [0 : len(slot_a) - 2]) hull() {
            translate(concat(lock_local(slot_a[i]), [-1])) cylinder(d = screw_clr_d, h = plate_t + 2);
            translate(concat(lock_local(slot_a[i + 1]), [-1])) cylinder(d = screw_clr_d, h = plate_t + 2);
        }
        // pivot screw hole
        translate([0, 0, -1]) cylinder(d = screw_clr_d, h = plate_t + 2);
        // Ring holes
        for (z = ring_z) translate([ring_x, face_front + eps, z]) rotate([90, 0, 0])
            cylinder(d = ring_hole_d, h = ring_hole_depth + eps);
        // wire window: Ring wiring passes from the base pocket to the camera,
        // same footprint as the solid block's pocket; the Ring backplate covers it
        translate([pocket_deep_inset - hinge_x, face_back - 1, pocket_z_min])
            cube([pocket_width, face_t + 2, pocket_z_max - pocket_z_min]);
        // drain at the low point of the cavity
        translate([ring_x + 18, face_back - 2, -1]) cylinder(d = drain_d, h = plate_t + 2);
        face_chamfers();
    }
}

// ================= WASHER (base frame) =================

// Sector washer in the track: it cannot spin on the screw, even loosened,
// because its curved sides stay between the track walls.
module washer_world() {
    translate([hinge_x, hinge_y, 0]) difference() {
        // body and teeth in one piece; roots at lock_a + k * step, tips half a tooth between
        tooth_strip(lock_r - washer_band, lock_r + washer_band,
                    lock_a - washer_half, lock_a + washer_half, lock_a + angle_step / 2,
                    washer_z0, washer_z0 + tooth_h, washer_z0 - washer_t);
        translate(concat(lock_r * [cos(lock_a), sin(lock_a)], [washer_z0 - washer_t - 1]))
            cylinder(d = screw_clr_d, h = washer_t + tooth_h + 2);
    }
}

// Flat face down on the bed, near the origin
module washer_print() {
    translate([-hinge_x - lock_r * cos(lock_a), -hinge_y - lock_r * sin(lock_a), washer_t - washer_z0])
        washer_world();
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

// Roof: covers the shell at every angle, never in front of the camera face.
module shell_2d() {
    hull() {
        plate_2d();
        translate([face_x0, face_back]) square([face_x1 - face_x0, face_t]);
    }
}

module roof_2d() {
    intersection() {
        square([width + 20, 200]);
        hull() {
            base_2d();
            on_shell_2d(angle_min) shell_2d();
            on_shell_2d(install_angle) shell_2d();
            on_shell_2d(angle_max) shell_2d();
        }
        // written out, not a for() (see base_2d)
        on_shell_2d(angle_min) translate([-200, -400]) square([400, 400 + face_front]);
        on_shell_2d(6) translate([-200, -400]) square([400, 400 + face_front]);
        on_shell_2d(install_angle) translate([-200, -400]) square([400, 400 + face_front]);
        on_shell_2d(12) translate([-200, -400]) square([400, 400 + face_front]);
        on_shell_2d(angle_max) translate([-200, -400]) square([400, 400 + face_front]);
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

// z0/z1 let the fit test cut a slice. The roof edge is the print-bed side
// (the base prints roof-down), so that is where the foot chamfer goes.
module base(z0 = base_z0, z1 = height) {
    difference() {
        union() {
            translate([0, 0, z0]) linear_extrude(min(z1, roof_z) - z0) base_2d();
            if (z1 > roof_z) hull() {
                translate([0, 0, roof_z]) linear_extrude(roof_t - foot_chamfer) roof_2d();
                translate([0, 0, height - eps]) linear_extrude(eps) offset(delta = -foot_chamfer) roof_2d();
            }
        }

        // wiring pocket, 15 mm behind the camera plate at the steepest angle
        on_shell(angle_max) translate([pocket_deep_inset - hinge_x, face_back - pocket_depth, pocket_z_min])
            cube([pocket_width, pocket_depth + 10, pocket_z_max - pocket_z_min]);

        // Ring bosses: swing clearance at their heights, plus a channel up from
        // the bottom at the install angle so the shell can slide on
        for (z = ring_z) hull() for (a = [angle_min, (angle_min + angle_max) / 2, angle_max])
            on_shell(a) translate([ring_x, face_back + swing_clr, z]) rotate([90, 0, 0])
                cylinder(d = boss_d + 2 * swing_clr,
                         h = face_back + 2 * swing_clr - (face_front - ring_hole_depth));
        on_shell(install_angle) hull() for (z = [-1, max(ring_z)])
            translate([ring_x, face_back + swing_clr, z]) rotate([90, 0, 0])
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

        // pivot and lock threads, up from the base bottom
        translate([hinge_x, hinge_y, base_z0]) thread_void(pivot_thread_l);
        translate([hinge_x, hinge_y, base_z0]) translate(lock_r * [cos(lock_a), sin(lock_a), 0])
            thread_void(lock_thread_l);

        scale_marks();
    }
}

// Screws (not printed): assembly view, and the heads count in the clash check.
// The pivot is a socket-head cap screw: the axis is only hinge_x from the
// mounting surface, too close for a thumb screw head, and adjusting never
// touches it. The lock is a thumb screw.
module screw_heads(shank = false) {
    for (s = [[[0, 0], 0, pivot_head_d], [lock_r * [cos(lock_a), sin(lock_a)], washer_z0 - washer_t, lock_head_d]])
        translate([hinge_x + s[0][0], hinge_y + s[0][1], s[1]]) {
            translate([0, 0, -5]) cylinder(d = s[2], h = 5);
            if (shank) cylinder(d = 5, h = 20 - 0.01);
        }
}

// ================= OUTPUT =================

if (part == "assembly") {
    base();
    on_shell(assembly_angle) shell_local();
    washer_world();
    color("silver") screw_heads(shank = true);
} else if (part == "base") {
    translate([0, 0, height]) rotate([180, 0, 0]) base();      // prints roof-down
} else if (part == "shell") {
    translate([0, 0, face_front]) rotate([-90, 0, 0]) shell_local();  // camera face down
} else if (part == "washer") {
    washer_print();
} else if (part == "fit_test") {
    // Bottom slice through the pivot and lock: base slice with both threads,
    // shell bottom with plate, teeth and slot, and a washer. Each piece in the
    // same print orientation as the full part. Assemble with the two thumb
    // screws: check the threads, the slide and the tooth mesh.
    band = [base_z0, base_z0 + 16];
    translate([0, 0, band[1]]) rotate([180, 0, 0]) base(band[0], band[1]);
    translate([0, 10, face_front]) rotate([-90, 0, 0]) intersection() {
        shell_local();
        translate([-100, -100, -1]) cube([200, 200, band[1] + 1]);
    }
    translate([70, 0, 0]) washer_print();
} else if (part == "clash") {
    // Must render EMPTY: any solid here is a collision at assembly_angle.
    // The wall (y < 0) and mounting surface (x < 0) count as solids.
    intersection() { base(); on_shell(assembly_angle) shell_local(); }
    intersection() { base(); washer_world(); }
    intersection() { on_shell(assembly_angle) shell_local(); washer_world(); }
    intersection() {
        union() { on_shell(assembly_angle) shell_local(); washer_world(); screw_heads(); }
        union() {
            translate([-100, -100, -50]) cube([300, 100, 300]);
            translate([-100, -100, -50]) cube([100, 300, 300]);
        }
    }
} else if (part == "install") {
    // Must render EMPTY: the shell sliding up onto the base at the install angle,
    // install_drop below its seat.
    intersection() { base(); translate([0, 0, -install_drop]) on_shell(install_angle) shell_local(); }
}
