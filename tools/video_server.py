"""Serve the repo on 127.0.0.1 and receive the recorded video.

Usage: python tools/video_server.py   (then open http://localhost:8765/demo.html?record)
Like `python -m http.server`, plus one upload endpoint: the recorder in
tools/record_video.js POSTs the finished MP4 to /upload, and it is saved as
docs/video/ring-mount-options.mp4. Bound to localhost only. Standard library only.
"""
import http.server
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "docs", "video", "ring-mount-options.mp4")
MAX_BYTES = 500 * 1024 * 1024


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kw):
        super().__init__(*args, directory=ROOT, **kw)

    def do_POST(self):
        n = int(self.headers.get("Content-Length", 0))
        if self.path != "/upload" or not 0 < n <= MAX_BYTES:
            self.send_error(400)
            return
        data = self.rfile.read(n)
        with open(OUT, "wb") as f:
            f.write(data)
        print(f"saved {os.path.relpath(OUT, ROOT)} ({n / 1e6:.1f} MB)", flush=True)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"saved")

    def log_message(self, fmt, *args):   # keep the log to uploads and errors
        if not str(args[1]).startswith(("2", "3")):
            super().log_message(fmt, *args)


if __name__ == "__main__":
    print("serving http://localhost:8765/ (Ctrl+C to stop)", flush=True)
    http.server.ThreadingHTTPServer(("127.0.0.1", 8765), Handler).serve_forever()
