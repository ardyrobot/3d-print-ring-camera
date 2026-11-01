"""Render orthographic PNG previews of a binary STL (flat shading, z-buffer, edge lines).

Usage: python tools/render_stl.py stl/ring_mount.stl docs
Standard library only. Exists because OpenSCAD's own PNG export fails on this
laptop ("Unable to create FBO"); rendering the exported STL also means the
previews show exactly the file that gets printed.
"""
import math
import struct
import sys
import zlib

SIZE = 800        # output pixels (square)
SS = 2            # supersampling factor for smoother edges
BG = (250, 250, 250)
BASE = (70, 130, 180)
LINE = (25, 35, 45)
DEPTH_EDGE = 0.4               # mm jump in depth that counts as an edge
CREASE = math.cos(math.radians(25))  # normals further apart than this draw an edge

FACE = math.radians(8)  # display only: camera face angle for the "front" view
VIEWS = {
    # name: (camera direction from the part, screen-up vector)
    # Model frame: X=0 deep side, X=55 shallow (countersink) side, +Y out of the camera face
    "preview-3d":    ((0.75, 1.0, 0.6), (0, 0, 1)),
    "preview-front": ((math.sin(FACE), math.cos(FACE), 0), (0, 0, 1)),
    "preview-back":  ((0, -1, 0), (0, 0, 1)),
    "preview-side":  ((1, 0, 0), (0, 0, 1)),
    "preview-top":   ((0, 0, 1), (0, 1, 0)),
}


def norm(v):
    n = math.sqrt(sum(c * c for c in v))
    return tuple(c / n for c in v)


def cross(a, b):
    return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])


def dot(a, b):
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def load(path):
    with open(path, "rb") as f:
        data = f.read()
    (count,) = struct.unpack_from("<I", data, 80)
    tris = []
    for i in range(count):
        v = struct.unpack_from("<12f", data, 84 + i * 50)
        tris.append((v[3:6], v[6:9], v[9:12]))
    return tris


def render(tris, cam, up):
    back = norm(cam)                      # points from part toward the viewer
    right = norm(cross(up, back))
    upv = cross(back, right)
    light = norm((back[0] + 0.3 * right[0] + 0.4 * upv[0],
                  back[1] + 0.3 * right[1] + 0.4 * upv[1],
                  back[2] + 0.3 * right[2] + 0.4 * upv[2]))

    proj = [[(dot(p, right), dot(p, upv), dot(p, back)) for p in t] for t in tris]
    xs = [p[0] for t in proj for p in t]
    ys = [p[1] for t in proj for p in t]
    n = SIZE * SS
    span = max(max(xs) - min(xs), max(ys) - min(ys))
    scale = n * 0.85 / span
    cx, cy = (max(xs) + min(xs)) / 2, (max(ys) + min(ys)) / 2

    zbuf = [-math.inf] * (n * n)
    img = [BG] * (n * n)
    nbuf = [None] * (n * n)
    for t, p in zip(tris, proj):
        normal = cross([t[1][k] - t[0][k] for k in range(3)], [t[2][k] - t[0][k] for k in range(3)])
        if not any(normal):
            continue
        normal = norm(normal)
        shade = 0.35 + 0.65 * abs(dot(normal, light))
        col = tuple(min(255, int(c * shade)) for c in BASE)
        pts = [((x - cx) * scale + n / 2, n / 2 - (y - cy) * scale, z) for x, y, z in p]
        (x0, y0, z0), (x1, y1, z1), (x2, y2, z2) = pts
        area = (x1 - x0) * (y2 - y0) - (x2 - x0) * (y1 - y0)
        if abs(area) < 1e-9:
            continue
        for py in range(max(0, int(min(y0, y1, y2))), min(n - 1, int(max(y0, y1, y2))) + 1):
            for px in range(max(0, int(min(x0, x1, x2))), min(n - 1, int(max(x0, x1, x2))) + 1):
                sx, sy = px + 0.5, py + 0.5
                w0 = ((x1 - sx) * (y2 - sy) - (x2 - sx) * (y1 - sy)) / area
                w1 = ((x2 - sx) * (y0 - sy) - (x0 - sx) * (y2 - sy)) / area
                w2 = 1 - w0 - w1
                if w0 < 0 or w1 < 0 or w2 < 0:
                    continue
                z = w0 * z0 + w1 * z1 + w2 * z2
                i = py * n + px
                if z > zbuf[i]:
                    zbuf[i] = z
                    img[i] = col
                    nbuf[i] = normal
    draw_edges(img, zbuf, nbuf, n, scale)
    return downsample(img, n)


def draw_edges(img, zbuf, nbuf, n, scale):
    """Darken pixels where depth jumps or the surface normal changes sharply.

    Flat shading alone hides faces parallel to the view (pocket floor, hole
    bottoms), so outlines are what make those features visible.
    """
    edge = []
    for y in range(n - 1):
        row = y * n
        for x in range(n - 1):
            i = row + x
            for j in (i + 1, i + n):
                a, b = nbuf[i], nbuf[j]
                if a is None and b is None:
                    continue
                if a is None or b is None or abs(zbuf[i] - zbuf[j]) > DEPTH_EDGE or dot(a, b) < CREASE:
                    edge.append(i)
                    edge.append(j)
    for i in edge:
        img[i] = LINE


def downsample(img, n):
    out = []
    for y in range(SIZE):
        row = []
        for x in range(SIZE):
            acc = [0, 0, 0]
            for dy in range(SS):
                base = (y * SS + dy) * n + x * SS
                for dx in range(SS):
                    c = img[base + dx]
                    acc[0] += c[0]; acc[1] += c[1]; acc[2] += c[2]
            row.append(tuple(a // (SS * SS) for a in acc))
        out.append(row)
    return out


def write_png(path, rows):
    raw = b"".join(b"\x00" + bytes(c for px in row for c in px) for row in rows)

    def chunk(tag, body):
        return struct.pack(">I", len(body)) + tag + body + struct.pack(">I", zlib.crc32(tag + body))

    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(chunk(b"IHDR", struct.pack(">IIBBBBB", len(rows[0]), len(rows), 8, 2, 0, 0, 0)))
        f.write(chunk(b"IDAT", zlib.compress(raw, 9)))
        f.write(chunk(b"IEND", b""))


def main(stl, outdir):
    tris = load(stl)
    for name, (cam, up) in VIEWS.items():
        write_png(f"{outdir}/{name}.png", render(tris, cam, up))
        print(f"wrote {outdir}/{name}.png")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
