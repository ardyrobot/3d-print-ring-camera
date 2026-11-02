"""Check the per-STL print files (option*/prints/*.scad) before the build exports them.

Usage: python tools/check_prints.py     (run by build.ps1)
Each print file includes its option's model and may override values for that one
print (the last assignment wins in OpenSCAD). Rules:
  - error:   overriding a fixed measurement from mount_common.scad
  - error:   `part = "..."` doesn't match the file name (the STL would be the wrong part)
  - error:   a commented `// name = value;` line (the list of defaults) no longer
             matches the model's value, so the list would mislead
  - warning: overriding a print tolerance two parts share (the mating part would no
             longer match); change those in the model file instead
Standard library only.
"""
import glob
import os
import re
import sys

from param_table import parse

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSIGN = re.compile(r"^\s*([A-Za-z_]\w*)\s*=\s*(.+?);")
# tolerances that only shape one part, so a print file may change them
SINGLE_PART = {"foot_chamfer"}


def main():
    fixed = {name for _, name, *_ in parse(os.path.join(ROOT, "mount_common.scad"))}
    errors, warnings = [], []
    for pf in sorted(glob.glob(os.path.join(ROOT, "option*", "prints", "*.scad"))):
        rel = os.path.relpath(pf, ROOT).replace("\\", "/")
        model = glob.glob(os.path.join(os.path.dirname(os.path.dirname(pf)), "option*.scad"))[0]
        shared = {name for section, name, *_ in parse(model)
                  if section == "Print tolerances" and name not in SINGLE_PART}
        has_part = any(section == "Render" and name == "part" for section, name, *_ in
                       parse_all(model))
        defaults = {name: value for _, name, value, *_ in parse(model)}
        names = {}
        with open(pf, encoding="utf-8") as f:
            for line in f:
                m = ASSIGN.match(line.split("//")[0])
                if m:
                    names[m.group(1)] = m.group(2).strip()
                    continue
                # a commented "// name = value;" documents the model's default: it must match
                m = re.match(r"^\s*//\s*([A-Za-z_]\w*)\s*=\s*(.+?);", line)
                if m and m.group(1) in defaults and \
                        m.group(2).replace(" ", "") != defaults[m.group(1)].replace(" ", ""):
                    errors.append(f"{rel}: listed default {m.group(1)} = {m.group(2)} but the model has "
                                  f"{defaults[m.group(1)]}; update the list")
        for n in names:
            if n in fixed:
                errors.append(f"{rel}: '{n}' is a fixed measurement; change it in mount_common.scad")
            elif n in shared:
                warnings.append(f"{rel}: '{n}' is a shared print tolerance; set it in {os.path.basename(model)} so the mating part matches")
        want = os.path.splitext(os.path.basename(pf))[0]
        if has_part and names.get("part", "").strip('"') != want:
            errors.append(f"{rel}: part = {names.get('part', 'missing')}, expected \"{want}\"")
    for w in warnings:
        print("warning:", w)
    for e in errors:
        print("ERROR:", e)
    print(f"print files checked: {len(glob.glob(os.path.join(ROOT, 'option*', 'prints', '*.scad')))}")
    return 1 if errors else 0


def parse_all(path):
    """Like param_table.parse, but keeps the Render section (parse skips it)."""
    section = "General"
    with open(path, encoding="utf-8") as f:
        for line in f:
            if line.startswith("// ---- derived"):
                return
            m = re.search(r"/\*\s*\[([^\]]+)\]", line)
            if m:
                section = m.group(1).strip()
                continue
            m = ASSIGN.match(line)
            if m:
                yield section, m.group(1)


if __name__ == "__main__":
    sys.exit(main())
