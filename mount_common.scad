// Fixed measurements shared by every mount option.
// Single owner: these come from the hand sketch (or were fixed by Cat) and must
// be identical in all three models. Change a value here, rebuild, and every
// option follows. Never redefine these in a model file.
//
// Source tags: [written] on the sketch, [scaled] measured off the sketch,
// [fixed] decided by Cat (not on the sketch).

/* [Envelope] */
width  = 55;   // [written] block width / camera face width
height = 110;  // [written]

/* [Ring mounting holes] */
ring_hole_d       = 2.25;  // [written] pilot for the Ring bracket screws
ring_hole_spacing = 91.5;  // [written] centre to centre, vertically centred
ring_hole_depth   = 12;    // [chosen]  measured into the camera face

/* [Wiring pocket] */
pocket_z_min      = 30;    // [written] bottom of pocket above block bottom
pocket_z_max      = 60;    // [written] top of pocket above block bottom
pocket_deep_inset = 9;     // [scaled]  pocket edge to deep side, front view
pocket_width      = 34.3;  // [scaled]  front-view width
pocket_depth      = 15;    // [fixed]   behind the camera plate

/* [Cable hole] */
cable_d          = 8;      // [written]
cable_z          = 35;     // [scaled] centre height
cable_deep_inset = 17;     // [scaled] centre to deep side (where the wire leaves the wall)

/* [Mounting screws] (through the width, into the mounting surface) */
// Size is shared so every option takes the same screws. Their POSITIONS are not
// fixed (Cat, 2026-11-01): each model sets its own screw_y / screw_z.
screw_d      = 3.5;        // [written?] shank clearance; sketch text hard to read
screw_head_d = 8;          // [written] head / countersink diameter
