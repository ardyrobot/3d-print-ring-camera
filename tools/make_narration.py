"""Speak the video narration from docs/video/storyboard.md into WAV files.

Usage: python tools/make_narration.py [voice]
Default voice: "Microsoft Zira Desktop". List the installed voices with:
  powershell -c "Add-Type -A System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices().VoiceInfo.Name"

The storyboard's table is the single owner of the narration text: this script
reads the "Narration (script)" column, speaks each line with Windows' built-in
text-to-speech (System.Speech, no installs), and writes
docs/video/narration/scene-N.wav plus timing.json (seconds per line), which
demo.html uses to time its scenes when recording. Standard library only.
"""
import json
import os
import re
import subprocess
import sys
import wave

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BOARD = os.path.join(ROOT, "docs", "video", "storyboard.md")
OUT = os.path.join(ROOT, "docs", "video", "narration")

PS = r"""
Add-Type -AssemblyName System.Speech
$s = New-Object System.Speech.Synthesis.SpeechSynthesizer
$s.SelectVoice($env:VOICE)
$fmt = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(48000, 'Sixteen', 'Mono')
$s.SetOutputToWaveFile($env:WAV, $fmt)
$s.Speak($env:LINE)
$s.Dispose()
"""


def narration_lines():
    """Rows of the storyboard table: (scene number, narration text)."""
    rows = []
    with open(BOARD, encoding="utf-8") as f:
        for line in f:
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if len(cells) >= 5 and cells[0].isdigit():
                text = re.sub(r'^"|"$', "", cells[3])
                rows.append((int(cells[0]), text))
    if not rows:
        sys.exit(f"no narration rows found in {BOARD}")
    return rows


def main():
    voice = sys.argv[1] if len(sys.argv) > 1 else "Microsoft Zira Desktop"
    os.makedirs(OUT, exist_ok=True)
    timing = {"voice": voice, "scenes": []}
    for n, text in narration_lines():
        wav = os.path.join(OUT, f"scene-{n}.wav")
        env = dict(os.environ, VOICE=voice, WAV=wav, LINE=text)
        subprocess.run(["powershell", "-NoProfile", "-Command", PS], env=env, check=True)
        with wave.open(wav) as w:
            secs = w.getnframes() / w.getframerate()
        timing["scenes"].append({"scene": n, "file": f"scene-{n}.wav", "seconds": round(secs, 2)})
        print(f"scene {n}: {secs:5.2f} s")
    with open(os.path.join(OUT, "timing.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump(timing, f, indent=2)
    print(f"total speech {sum(s['seconds'] for s in timing['scenes']):.1f} s")


if __name__ == "__main__":
    main()
