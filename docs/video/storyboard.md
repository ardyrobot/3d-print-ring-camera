# Video storyboard: four ways to angle a Ring camera

Status: **v4.** v3 (6:12) is recorded; v4 adds Cat's notes on v3 (2026-11-01):
an overhead angle view for option 1, that every value is a variable in the
script, the washer tracks and slots in options 2 and 4 with the walls
see-through while they're shown, and the male voice (Microsoft David).

- v1 (grey, 3:10) and v2 (colour, 3:50) are recorded.
- Cat's notes on v2 (2026-11-01):
  - It's hard to see the design and how the angles work.
  - Show off the sketch that started it.
  - Introduce the camera body only after the parts are installed.
  - Show how all the parts work, stay in and function.
- v3 answers those notes. This table is the single source of the narration:
  `tools/make_narration.py` reads the "Narration" column.

**Length:** about 6 min 30 s, 16:9, 1920 × 1080, narrated (Windows "David" voice).

**Colour code (same in every option):**
- base: deep blue
- camera shell: coral
- lock parts (washer, pin, teeth): teal
- hardware: steel
- option accents (backdrop, titles, readout): 1 amber, 2 blue, 3 green, 4 purple

**Rules for every option:**

1. **Order: parts → install → angles → how it holds → camera.** The camera
   body only comes in once everything is installed and explained. It seats
   on the face solid, not see-through, and then the view cone shows where it
   looks.
2. **The angle view.** For each adjustable option, the camera goes
   straight overhead. Drawn on top:
   - the wall and the mounting surface;
   - a dashed "straight out" line;
   - a green arrow for where the camera looks, with an angle arc and its
     number between the two;
   - faint outlines of the shell at 3° and 15°;
   - the pivot: option 2's hinge bolt, option 3's virtual pivot behind the
     wall (a dot with a dashed arc), or option 4's pivot screw and slot.

   Each angle holds for about a second. Option 1 gets the same view, fixed
   at 8°, with a card showing the script line that sets it.
4. **The building wall and the mounting surface are always see-through**
   (Cat, 2026-11-01). They show where the mount sits, but never hide a slot,
   a track, a cutaway or anything else being described.
3. **"How it holds" beats.** Close-ups and cutaways, each with a labelled
   callout, show what keeps every part in place and what each fastener
   does. Every number in them comes from the model files and is
   calculated, not tested.

| # | Time | Visual | Narration (script) | On-screen caption |
|---|---|---|---|---|
| 1 | 0:00–0:22 | The hand sketch fills the screen, flat and readable. The camera zooms slowly onto each callout as it is named: 55 × 110, the holes 91.5 apart, the pocket, the cable hole, the angle marked with a question mark. | "It started with this sketch: a block, 55 by 110 millimetres, that holds a Ring camera on the side of a wall. Two holes 91.5 millimetres apart, a pocket for the wiring, a cable hole in the back, and one open question: what angle?" | From a sketch |
| 2 | 0:22–0:38 | The sketch shrinks to an inset in the corner. The 3D block rises in its place, and the dimension lines draw on as their numbers light up in the inset. | "Every option shares those fixed measurements, held in one file, so the face, the holes, the pocket and the cable hole match the sketch exactly in all four designs." | One set of fixed measurements |
| 3 | 0:38–1:12 | **Option 1, amber.** X-ray cut through the pocket and cable path. Exploded: the block and two screws, labelled, snap together. Overhead angle view at 8°, with a script card: `face_angle = 8;` from `option1-solid/option1_solid.scad`. The block screws into the corner. | "Option one is the solid block: one printed part and two screws, fixed at 8 degrees. The screws go in through the side, the cable comes in from the back, and the wiring sits in a pocket behind the camera. From above you can see the angle. It is one number in the script, face angle: change it and rebuild for a different angle. Every value in every option is a named variable at the top of its script, so any of them can be changed the same way." | Option 1 · Solid block · 8° |
| 4 | 1:12–1:34 | **How option 1 holds.** Section through the side: a screw head seats in its countersink. Close-up of the face's two pilot holes. Then the camera body seats; view cone at 8°. | "What holds it: two number-8 flat-head screws sit in 82-degree countersinks and pull the block tight against the surface. The camera's own screws bite into 12-millimetre pilot holes in the face." | How it holds · option 1 |
| 5 | 1:34–2:20 | **Option 2, blue.** Exploded and labelled: base, shell, washer, M4 bolts, nuts. Assembly. Angle view: the shell swings on the hinge bolt from 3° to 15° in 2° clicks, and the washer glows at each click. | "Option two makes the angle adjustable. Three printed parts: a base, a camera shell, and a toothed washer. The shell swings on a hinge bolt at the corner, and the washer locks it from 3 to 15 degrees in 2-degree clicks, so the teeth carry the load, not friction." | Option 2 · Adjustable hinge · 3–15° in 2° steps |
| 6 | 2:20–2:52 | **How option 2 holds.** The hinge nuts slide into their slots; the clamp nut into its slot from the back. The washer lifts out to show the recessed track and the curved slot in the shell's skirt, then goes back; the clamp bolt tightens and the teeth glow. Then the camera body seats; view cone. | "What holds it: each M4 bolt threads into a nut trapped in a slot in the base. Once the base is against the surface and the wall, the nuts can't escape. The washer sits in a recessed track on the shell, around a curved slot. The clamp bolt passes through that slot, so tightening it presses the washer's teeth into the shell's teeth." | How it holds · option 2 |
| 7 | 2:52–3:40 | **Option 3, green.** Exploded and labelled: base, shell, pin. Underneath, the pin drops. Angle view: the virtual pivot behind the wall appears as a dot with a dashed arc, and the shell slides along it to 15° and back to 9°. The pin glows as it goes back in. | "Option three has no metal hardware at all, apart from the two wall screws. The shell slides on curved dovetail rails, so the whole camera swings around a point behind the wall. A printed pin pushes up into the hole marked with the angle you want, and only one hole lines up at each angle." | Option 3 · Dovetail slide · all printed |
| 8 | 3:40–4:08 | **How option 3 holds.** Section across a rail: the dovetail's angled sides trap the groove. The shell tries to lift and pull away and can't. Close-up of the closed groove end meeting the rail at 15°. Close-up of the pin's grip at the bottom of its hole. Then the camera body seats; view cone. | "What holds it: the dovetails trap the shell in every direction except along the curve, so it can't lift off or pull away. The closed end of each groove stops it just past 15 degrees, and the mounting surface stops it at the other end. The pin is a tenth of a millimetre tight at the bottom of its hole, so it stays in but still pulls out by hand." | How it holds · option 3 |
| 9 | 4:08–5:04 | **Option 4, purple.** Exploded and labelled: base with roof, shell, washer, pivot screw, thumb screw, wood screws. Install: base on the wall (roof glows), screws, shell rises from below, pivot screw spins in, washer and thumb screw lock underneath (teeth glow). Angle view: the pivot screw and the slot, the shell clicking 3° to 15°. | "Option four puts installation first. The base screws on with nothing in the way, and its roof keeps the rain off. The shell slides up underneath and turns on a stainless pivot screw. A toothed washer and one thumb screw grip teeth on the underside: 3 to 15 degrees in 3-degree clicks." | Option 4 · Pivot with roof · 3–15° in 3° steps |
| 10 | 5:04–5:38 | **How option 4 holds.** Cutaway through both screws: the printed threads, with thread length marked; the roof just above the shell. Underneath: the washer and thumb screw drop away to show the curved slot and the toothed track, then go back. Nylon patch callout. Then the camera body seats; view cone. | "What holds it: both screws thread into the base itself. The pivot screw has about 14 millimetres of thread and pulls the shell up against the base, so it can't drop, and the roof stops it going any higher. Underneath, the lock screw passes through a curved slot, with the washer in a recessed track around it, shaped so it can't spin or fall off. Both screws carry a nylon locking patch, so vibration can't back them out." | How it holds · option 4 |
| 11 | 5:38–5:56 | Underneath, then overhead: the thumb screw loosens two turns, the washer drops, the shell swings to 15° in the angle view, the screw tightens. | "Changing the angle takes two turns of the thumb screw. The washer drops out of the teeth, but the screw still has nearly 9 millimetres of thread and the washer stays in its track, so nothing falls off a ladder." | Two turns to adjust |
| 12 | 5:56–6:16 | All four in a row with their cameras. Each lights up in its accent colour as it is named, with a small sketch inset in the corner. | "Four options, one sketch, one set of measurements. Pick the one that suits the wall, the weather and how often you'll adjust it." | Side by side |
| 13 | 6:16–6:30 | The sketch returns full screen beside the four finished mounts; end card with "Built from code" and the GitHub URL. | "Every part is generated from code and checked for collisions at every angle before it's printed. It's all in the repo." | github.com/ardyrobot/3d-print-ring-camera |

## Comparison card (scene 12)

| | Option 1 | Option 2 | Option 3 | Option 4 |
|---|---|---|---|---|
| Angle | 8° fixed | 3–15°, 2° steps | 3–15°, 2° steps | 3–15°, 3° steps |
| Printed parts | 1 | 3 | 3 | 3 |
| Hardware | 2 wood screws | + 3 M4 bolts, 3 nuts | none extra | + 2 M5 screws |
| Adjust | reprint | loosen clamp bolt | pull pin | 2 turns of thumb screw |

## Sources for the "how it holds" facts

All calculated from the models, not tested on a print.

| Claim | Where it comes from |
|---|---|
| 82° countersinks, #8 flat head | `mount_common.scad`: `screw_sink_angle`, `screw_head_d` |
| 12 mm pilot holes | `mount_common.scad`: `ring_hole_depth` |
| Option 2 nuts trapped by the surface and the wall | `option2-hinge/option2_hinge.scad`: hinge nuts slide in from the mounting face, the clamp nut from the back face |
| Option 3 stops at 15° and at the surface | `option3-dovetail/option3_dovetail.scad`: groove closed at `angle_max + 0.5`. README open item: the frame stops it at about 2°. |
| Option 3 pin 0.1 mm tight | `option3-dovetail/option3_dovetail.scad`: `pin_snug = -0.1` |
| Option 4 thread lengths: 13.6, 10.4, and 8.8 mm when loosened | `option4-pivot/option4_pivot.scad`: M5 × 20 screws, `plate_t`, `gap`, washer thickness |
| Option 4 roof just above the shell | `option4-pivot/option4_pivot.scad`: `roof_clr` (0.8 mm, 0.4 mm once tightened) |
| Option 4 nylon locking patch | README hardware list (chosen by Cat). Purchased screws, not modelled. |

## How it gets made (no installs)

1. **Animation:** `demo.html` plays the scenes above from the real STLs.
2. **Narration:** `tools/make_narration.py` speaks each line with Windows'
   built-in text-to-speech into `docs/video/narration/`.
3. **Recording:** run `tools/video_server.py`, then open
   `demo.html?record`.
   - The browser renders every frame and encodes H.264 + AAC (WebCodecs).
   - The server saves `docs/video/ring-mount-options.mp4`.
   - The recorder stops if a narration line is longer than its scene.

**Decided:**
- Voice: David (male, chosen by Cat for v4; any installed voice works).
- No music.
- The MP4 stays in the repo: about 80 MB at 1.6 Mbit/s, under GitHub's 100 MB limit.
