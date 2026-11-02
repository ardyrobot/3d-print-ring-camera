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
STLS = ["option1-solid/stl/block.stl",
        "option2-hinge/stl/base.stl", "option2-hinge/stl/shell.stl", "option2-hinge/stl/washer.stl",
        "option3-dovetail/stl/base.stl", "option3-dovetail/stl/shell.stl",
        "option4-pivot/stl/base.stl", "option4-pivot/stl/shell.stl", "option4-pivot/stl/washer.stl"]


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
