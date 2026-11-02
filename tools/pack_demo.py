"""Pack the demo's STLs into one JavaScript file for publishing demo.html.

Usage: python tools/pack_demo.py <out.js>
The artifact host does not serve .stl files, so the published demo loads its
models from this file instead (window.DEMO_MODELS, base64 per path). Locally,
demo.html fetches the real STLs and never needs it. Output is a build product:
regenerate it from the current STLs before each publish; don't commit it.
"""
import base64
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STLS = ["stl/ring_mount.stl",
        "stl/adjustable_base.stl", "stl/adjustable_shell.stl", "stl/adjustable_washer.stl",
        "stl/slide_base.stl", "stl/slide_shell.stl",
        "stl/pivot_base.stl", "stl/pivot_shell.stl", "stl/pivot_washer.stl"]


def main(out):
    data = {}
    for rel in STLS:
        with open(os.path.join(ROOT, rel), "rb") as f:
            data[rel] = base64.b64encode(f.read()).decode("ascii")
    with open(out, "w", encoding="ascii", newline="\n") as f:
        f.write("window.DEMO_MODELS = " + json.dumps(data) + ";\n")
    print(f"wrote {out} ({os.path.getsize(out) // 1024} KB)")


if __name__ == "__main__":
    main(sys.argv[1])
