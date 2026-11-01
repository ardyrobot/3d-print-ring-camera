"""Sanity-check a binary STL: bounding box, volume, and whether the mesh is closed.

Usage: python tools/check_stl.py stl/ring_mount.stl
Standard library only, so it runs without a virtual environment.
Exits non-zero if the mesh is not watertight.
"""
import struct
import sys
from collections import Counter


def main(path):
    with open(path, "rb") as f:
        data = f.read()
    if data[:5] == b"solid" and b"facet" in data[:400]:
        sys.exit("ASCII STL not supported; build.ps1 exports binary STL")
    (count,) = struct.unpack_from("<I", data, 80)

    lo = [float("inf")] * 3
    hi = [float("-inf")] * 3
    volume = 0.0
    edges = Counter()
    for i in range(count):
        vals = struct.unpack_from("<12f", data, 84 + i * 50)
        tri = [vals[3:6], vals[6:9], vals[9:12]]
        for v in tri:
            for k in range(3):
                lo[k] = min(lo[k], v[k])
                hi[k] = max(hi[k], v[k])
        a, b, c = tri
        # Signed volume of the tetrahedron (origin, a, b, c)
        volume += (a[0] * (b[1] * c[2] - b[2] * c[1])
                   - a[1] * (b[0] * c[2] - b[2] * c[0])
                   + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6.0
        for p, q in ((a, b), (b, c), (c, a)):
            edges[tuple(sorted((p, q)))] += 1

    size = [h - l for h, l in zip(hi, lo)]
    open_edges = sum(1 for n in edges.values() if n != 2)
    print(f"triangles : {count}")
    print(f"bbox min  : {lo[0]:.2f}, {lo[1]:.2f}, {lo[2]:.2f}")
    print(f"size X/Y/Z: {size[0]:.2f} x {size[1]:.2f} x {size[2]:.2f} mm")
    print(f"volume    : {abs(volume) / 1000:.2f} cm3")
    print(f"watertight: {'yes' if open_edges == 0 else f'NO ({open_edges} bad edges)'}")
    return 0 if open_edges == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
