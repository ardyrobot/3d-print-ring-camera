# Video storyboard: four ways to angle a Ring camera

Status: **v2, colour version.** v1 (grey, 3:10) was approved by Cat and
recorded on 2026-11-01. v2 adds colour, exploded views with labelled parts,
glow on the part being described, and a cutaway; Cat approved the direction
on 2026-11-01. This table is the single source of the narration:
`tools/make_narration.py` reads the "Narration" column.

- **Length:** 3 min 50 s, 16:9, 1920 × 1080, narrated (Windows "Zira" voice).
- **Look:** studio stage from `demo.html`, real STLs from `stl/`, soft shadows,
  captions in the lower left. The backdrop takes each option's accent colour.
- **Colour code (same in every option):** base = deep blue, camera shell =
  coral, lock parts (washer, pin, teeth) = teal, hardware = steel. Option
  accents: 1 amber, 2 blue, 3 green, 4 purple.

| # | Time | Visual | Narration (script) | On-screen caption |
|---|---|---|---|---|
| 1 | 0:00–0:12 | The hand sketch on the desk; the block rises out of it. | "It started with a sketch: a Ring camera that has to sit on the side of a wall and look a few degrees away from it." | From a sketch |
| 2 | 0:12–0:26 | The sketch fades; dimension lines draw on: 55, 110, 91.5. | "Every option shares the same fixed measurements: a 55 by 110 face, Ring holes 91.5 millimetres apart, and the cable hole and wiring pocket exactly where the sketch put them." | One set of fixed measurements |
| 3 | 0:26–0:54 | **Option 1, amber.** X-ray cut through the pocket and cable path. Exploded: block and two screws, labelled. They snap together with a flash. Camera on, view cone at 8°. | "Option one is the solid block: one printed part and two screws, fixed at 8 degrees. The screws go in through the side, the cable comes in from the back, and the wiring sits in a pocket behind the camera." | Option 1 · Solid block · 8° |
| 4 | 0:54–1:34 | **Option 2, blue.** Exploded: base, shell, washer and three M4 bolts, labelled, then snap together. The shell clicks 3° to 15°; the washer glows at each click. | "Option two makes the angle adjustable. Three printed parts: a base, a camera shell, and a toothed washer. The shell pivots on two M4 bolts, and the washer locks it from 3 to 15 degrees in 2-degree clicks, so the teeth carry the load, not friction." | Option 2 · Adjustable hinge · 3–15° in 2° steps |
| 5 | 1:34–2:14 | **Option 3, green.** Exploded: base, shell, pin, labelled. Underneath, the pin drops; the shell slides along its rails to 15° and back to 9°; the pin glows as it goes back in. | "Option three has no metal hardware at all, apart from the two wall screws. Three printed parts: the shell slides on curved dovetail rails, and a printed pin pushes up into the hole marked with the angle you want. Only one hole lines up at each angle." | Option 3 · Dovetail slide · all printed |
| 6 | 2:14–3:04 | **Option 4, purple.** Exploded: base with roof, shell, washer, pivot screw, thumb screw, wood screws, labelled. Then the install: base on the wall (roof glows), screws, shell rises from below, pivot screw spins in, underneath the washer and thumb screw lock (teeth glow). A cutaway shows the thread and teeth. Camera on. | "Option four puts installation first. The base screws on with nothing in the way, and its roof keeps the rain off. The shell slides up underneath and pivots on a stainless screw. To lock it, a toothed washer and one thumb screw grip teeth on the underside: 3 to 15 degrees in 3-degree clicks. The threads are printed right into the base." | Option 4 · Pivot with roof · 3–15° in 3° steps |
| 7 | 3:04–3:20 | Underneath: the thumb screw loosens two turns, the washer drops, the shell swings to 15°, the screw tightens. | "Changing the angle takes two turns of the thumb screw. The washer drops out of the teeth, but it stays in its track, so nothing falls off a ladder." | Two turns to adjust |
| 8 | 3:20–3:38 | All four in a row; each lights up in its accent colour as it is named. | "Four options, one set of measurements. Pick the one that suits the wall, the weather and how often you'll adjust it." | Side by side |
| 9 | 3:38–3:50 | Pull back; end card with "Built from code" and the GitHub URL. | "Every part is generated from code and checked for collisions at every angle before it's printed. It's all in the repo." | github.com/ardyrobot/3d-print-ring-camera |

## Comparison card (scene 8)

| | Option 1 | Option 2 | Option 3 | Option 4 |
|---|---|---|---|---|
| Angle | 8° fixed | 3–15°, 2° steps | 3–15°, 2° steps | 3–15°, 3° steps |
| Printed parts | 1 | 3 | 3 | 3 |
| Hardware | 2 wood screws | + 3 M4 bolts, 3 nuts | none extra | + 2 M5 screws |
| Adjust | reprint | loosen clamp bolt | pull pin | 2 turns of thumb screw |

## How it gets made (no installs)

1. **Animation:** `demo.html` plays the scenes above from the real STLs.
2. **Narration:** `tools/make_narration.py` speaks each line with Windows'
   built-in text-to-speech into `docs/video/narration/`.
3. **Recording:** `tools/video_server.py`, then `demo.html?record`. The
   browser renders every frame, encodes H.264 + AAC (WebCodecs), and the
   server saves `docs/video/ring-mount-options.mp4`. The recorder stops if a
   narration line is longer than its scene.

Decided: voice Zira (default; any installed voice works), no music, MP4 kept
in the repo (about 50–60 MB at 2 Mbit/s; GitHub's limit is 100 MB).
