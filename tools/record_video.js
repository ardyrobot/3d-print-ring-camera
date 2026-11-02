// Records demo.html to an MP4 with narration. Loaded by demo.html?record
// (served by tools/video_server.py, which saves the upload).
//
// Frame by frame, not real time: each frame is rendered at t = frame / FPS,
// composited with the captions onto a 2D canvas and handed to the browser's
// built-in H.264 encoder (WebCodecs). A slow or hidden browser can't drop
// frames or drift from the audio. The narration WAVs (tools/make_narration.py)
// are mixed at each scene's start and encoded as AAC (Opus if AAC isn't
// available). mp4-muxer writes the MP4 container.
(async () => {
  const W = 1920, H = 1080, FPS = 30, SR = 48000, SPEECH_DELAY = 0.6;
  const S = W / 1100;                                   // overlay scale vs the page's ~1100 px stage
  const box = document.createElement('div');
  box.style.cssText = 'position:fixed;top:8px;left:8px;z-index:9;background:#1f2428;color:#fff;font:14px monospace;padding:6px 10px;border-radius:6px';
  document.body.appendChild(box);
  const status = (m) => { box.textContent = m; document.title = m; console.log(m); };
  const fail = (e) => { status('FAILED: ' + (e && e.message || e)); throw e; };

  try {
    await new Promise((ok, no) => {
      const s = document.createElement('script');
      s.src = 'https://cdn.jsdelivr.net/npm/mp4-muxer@5.1.3/build/mp4-muxer.js';
      s.onload = ok; s.onerror = () => no(new Error('mp4-muxer did not load')); document.head.appendChild(s);
    });
    const { renderer, cam, DURATION, render } = window.DEMO;
    renderer.setSize(W, H, false); cam.aspect = W / H; cam.updateProjectionMatrix();

    // demo.html?record&snap=12.5 : show one composited frame instead of recording
    const snap = new URLSearchParams(location.search).get('snap');
    if (snap !== null) {
      const comp = document.createElement('canvas'); comp.width = W; comp.height = H;
      const ctx = comp.getContext('2d'), t = parseFloat(snap), st = render(t);
      backdrop(ctx, st); ctx.drawImage(renderer.domElement, 0, 0, W, H);
      window.DEMO.drawSketch(ctx, W, H, st.sketch); overlay(ctx, st, t);
      comp.style.cssText = 'position:fixed;inset:0;width:100vw;height:auto;z-index:8';
      document.body.appendChild(comp);
      status(`snap t=${t}`);
      return;
    }

    // ---- narration, mixed onto one track ----
    status('mixing narration');
    const timing = await (await fetch('docs/video/narration/timing.json')).json();
    const ac = new OfflineAudioContext(1, Math.ceil(DURATION * SR), SR);
    for (const sc of timing.scenes) {
      const scene = window.DEMO.S[sc.scene - 1];
      if (sc.seconds + SPEECH_DELAY > scene.t1 - scene.t0) throw new Error(`scene ${sc.scene} narration is longer than the scene`);
      const buf = await ac.decodeAudioData(await (await fetch('docs/video/narration/' + sc.file)).arrayBuffer());
      const src = ac.createBufferSource(); src.buffer = buf; src.connect(ac.destination);
      src.start(scene.t0 + SPEECH_DELAY);
    }
    const pcm = (await ac.startRendering()).getChannelData(0);

    // ---- encoders ----
    const aac = { codec: 'mp4a.40.2', sampleRate: SR, numberOfChannels: 1, bitrate: 128000 };
    const opus = { ...aac, codec: 'opus' };
    const acfg = (await AudioEncoder.isConfigSupported(aac)).supported ? aac : opus;
    let vcfg = null;
    for (const codec of ['avc1.640028', 'avc1.4d0028', 'avc1.42002a']) {
      // 1.6 Mbit/s keeps the 6-minute file near 75 MB (GitHub rejects files over
      // 100 MB); the scenes are mostly still surfaces, so it stays sharp
      const c = { codec, width: W, height: H, bitrate: 1.6e6, framerate: FPS };
      if ((await VideoEncoder.isConfigSupported(c)).supported) { vcfg = c; break; }
    }
    if (!vcfg) throw new Error('no H.264 encoder in this browser');
    const muxer = new Mp4Muxer.Muxer({
      target: new Mp4Muxer.ArrayBufferTarget(),
      video: { codec: 'avc', width: W, height: H, frameRate: FPS },
      audio: { codec: acfg === aac ? 'aac' : 'opus', numberOfChannels: 1, sampleRate: SR },
      fastStart: 'in-memory',
    });
    const ve = new VideoEncoder({ output: (c, m) => muxer.addVideoChunk(c, m), error: fail });
    ve.configure(vcfg);
    const ae = new AudioEncoder({ output: (c, m) => muxer.addAudioChunk(c, m), error: fail });
    ae.configure(acfg);
    for (let i = 0; i < pcm.length; i += 4800) {
      const n = Math.min(4800, pcm.length - i);
      ae.encode(new AudioData({ format: 'f32', sampleRate: SR, numberOfFrames: n, numberOfChannels: 1,
                                timestamp: Math.round(i / SR * 1e6), data: pcm.slice(i, i + n) }));
    }

    // ---- frames ----
    const comp = document.createElement('canvas'); comp.width = W; comp.height = H;
    const ctx = comp.getContext('2d');
    const N = Math.round(DURATION * FPS);
    const t0 = performance.now();
    for (let f = 0; f < N; f++) {
      const t = f / FPS;
      const st = render(t);
      backdrop(ctx, st);
      ctx.drawImage(renderer.domElement, 0, 0, W, H);
      window.DEMO.drawSketch(ctx, W, H, st.sketch);
      overlay(ctx, st, t);
      const vf = new VideoFrame(comp, { timestamp: Math.round(f * 1e6 / FPS), duration: Math.round(1e6 / FPS) });
      ve.encode(vf, { keyFrame: f % (FPS * 2) === 0 });
      vf.close();
      while (ve.encodeQueueSize > 6) await new Promise((r) => setTimeout(r, 1));
      if (f % FPS === 0) {
        const el = (performance.now() - t0) / 1000;
        status(`frame ${f}/${N} · ${Math.round(el)} s elapsed · ~${Math.round(el / (f + 1) * (N - f))} s left`);
      }
    }
    await ve.flush(); await ae.flush();
    muxer.finalize();
    const buf = muxer.target.buffer;
    status(`uploading ${(buf.byteLength / 1e6).toFixed(1)} MB`);
    const res = await fetch('/upload', { method: 'POST', body: buf });
    if (!res.ok) throw new Error('upload failed: ' + res.status);
    status(`DONE · ${(buf.byteLength / 1e6).toFixed(1)} MB · ${vcfg.codec} + ${acfg.codec} · ${Math.round((performance.now() - t0) / 1000)} s`);
  } catch (e) { fail(e); }

  // ---- drawing helpers (match demo.html's CSS) ----
  function backdrop(c, st) {                            // tinted with the scene's accent, like the page
    const g = c.createRadialGradient(W * 0.5, H * 0.2, 0, W * 0.5, H * 0.2, W * 0.75);
    g.addColorStop(0, st.sweepTop); g.addColorStop(1, st.sweepBottom);
    c.fillStyle = g; c.fillRect(0, 0, W, H);
  }
  function rrect(c, x, y, w, h, r) {
    c.beginPath(); c.moveTo(x + r, y); c.arcTo(x + w, y, x + w, y + h, r); c.arcTo(x + w, y + h, x, y + h, r);
    c.arcTo(x, y + h, x, y, r); c.arcTo(x, y, x + w, y, r); c.closePath();
  }
  function wrap(c, text, maxW) {
    const out = []; let line = '';
    for (const w of text.split(' ')) {
      const test = line ? line + ' ' + w : w;
      if (c.measureText(test).width > maxW && line) { out.push(line); line = w; } else line = test;
    }
    if (line) out.push(line);
    return out;
  }
  function overlay(c, st, t) {
    const scene = window.DEMO.S.find((s) => s.id === st.id);
    const fade = Math.min(1, (t - scene.t0) / 0.4);
    // caption, lower left
    const a = st.capShow * fade;
    if (a > 0.01) {
      c.save(); c.globalAlpha = a;
      const pad = 16 * S, maxW = 500 * S;
      c.font = `400 ${14 * S}px "IBM Plex Sans", "Segoe UI", sans-serif`;
      const body = wrap(c, st.cap.b || '', maxW);
      c.font = `600 ${24 * S}px "Familjen Grotesk", Arial, sans-serif`;
      const title = wrap(c, st.cap.t, maxW);
      const h = pad * 2 + 16 * S + title.length * 28 * S + body.length * 21 * S + 4 * S;
      const w = maxW + pad * 2, x = 0.03 * W, y = H - 0.05 * H - h;
      c.fillStyle = 'rgba(255,255,255,0.82)'; rrect(c, x, y, w, h, 8 * S); c.fill();
      let yy = y + pad + 11 * S;
      c.fillStyle = st.accent; c.font = `500 ${11 * S}px "IBM Plex Mono", Consolas, monospace`;
      c.fillText(st.cap.k.toUpperCase().split('').join(String.fromCharCode(8202)), x + pad, yy);
      c.fillStyle = '#1f2428'; c.font = `600 ${24 * S}px "Familjen Grotesk", Arial, sans-serif`;
      for (const l of title) { yy += 28 * S; c.fillText(l, x + pad, yy); }
      c.fillStyle = '#5a656d'; c.font = `400 ${14 * S}px "IBM Plex Sans", "Segoe UI", sans-serif`;
      yy += 4 * S;
      for (const l of body) { yy += 21 * S; c.fillText(l, x + pad, yy); }
      c.restore();
    }
    // angle readout, upper right
    if (st.readout > 0.01) {
      c.save(); c.globalAlpha = st.readout; c.textAlign = 'right';
      const xr = W * 0.96, yt = H * 0.06;
      c.fillStyle = '#1f2428'; c.font = `500 ${68 * S}px "IBM Plex Mono", Consolas, monospace`;
      c.fillText(st.deg + '°', xr, yt + 58 * S);
      c.fillStyle = '#5a656d'; c.font = `400 ${11 * S}px "IBM Plex Mono", Consolas, monospace`;
      c.fillText('CAMERA ANGLE', xr, yt + 80 * S);
      st.list.forEach((v, i) => {
        c.fillStyle = v <= st.deg ? st.accent : '#d5d9dc';
        rrect(c, xr - (st.list.length - i) * 14 * S + 4 * S, yt + 90 * S, 10 * S, 4 * S, 2 * S); c.fill();
      });
      c.restore();
    }
    // end card, right of the sketch (which sits on the left)
    if (st.endCard > 0.01) {
      const cx = W * 0.69;
      c.save(); c.globalAlpha = st.endCard; c.textAlign = 'center';
      c.fillStyle = 'rgba(243,244,245,0.6)'; rrect(c, W * 0.42, H * 0.24, W * 0.54, H * 0.5, 16 * S); c.fill();
      c.font = `500 ${12 * S}px "IBM Plex Mono", Consolas, monospace`;
      const pill = 'Built from code · OpenSCAD + Python', pw = c.measureText(pill).width + 20 * S;
      c.fillStyle = '#d8ecee'; rrect(c, cx - pw / 2, H * 0.32, pw, 24 * S, 12 * S); c.fill();
      c.fillStyle = '#1f6f78'; c.fillText(pill, cx, H * 0.32 + 16.5 * S);
      c.fillStyle = '#1f2428'; c.font = `700 ${56 * S}px "Familjen Grotesk", Arial, sans-serif`;
      c.fillText('One drawing.', cx, H * 0.32 + 90 * S); c.fillText('Four mounts.', cx, H * 0.32 + 148 * S);
      c.fillStyle = '#5a656d'; c.font = `400 ${17 * S}px "IBM Plex Sans", "Segoe UI", sans-serif`;
      c.fillText('github.com/ardyrobot/3d-print-ring-camera', cx, H * 0.32 + 185 * S);
      c.restore();
    }
  }
})();
