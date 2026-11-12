"""Generates the app sound effects into assets/sounds/ with ffmpeg.

Soft, short chimes for children: no download, no license question.
Run from the project root: python3 tool/sounds/generate_sounds.py
"""
import subprocess

# (start s, frequency Hz, duration s, volume)
C5, E5, G5, C6, E6, G6, B6, D7 = 523.25, 659.25, 783.99, 1046.5, 1318.5, 1568.0, 1975.5, 2349.3
A3, E4, C4 = 220.0, 329.63, 261.63

SOUNDS = {
    # Light pop for UI taps
    'tap': ([(0, 1200, 0.06, 0.5)], 60),
    # Two rising notes: "yes!"
    'success': ([(0, E6, 0.18, 0.6), (0.09, G6, 0.3, 0.6)], 18),
    # Two soft descending low notes, never harsh
    'error': ([(0, E4, 0.16, 0.5), (0.12, C4, 0.3, 0.5)], 14),
    # Sparkle when a star lights up
    'star': ([(0, G6, 0.2, 0.4), (0.06, B6, 0.2, 0.4), (0.12, D7, 0.35, 0.4)], 14),
    # Word found twice: happy arpeggio
    'word_complete': ([(0, C5, 0.25, 0.5), (0.08, E5, 0.25, 0.5), (0.16, G5, 0.25, 0.5), (0.24, C6, 0.5, 0.55)], 9),
    # End of game fanfare, ending on a chord
    'level_complete': ([
        (0, C5, 0.18, 0.5), (0.15, E5, 0.18, 0.5), (0.3, G5, 0.18, 0.5),
        (0.45, C6, 0.9, 0.45), (0.45, G5, 0.9, 0.35), (0.45, E5, 0.9, 0.35),
    ], 4.5),
}


def note(t0, f, d, vol, decay):
    t = f'(t-{t0})'
    # Sine + a soft octave, quick fade-in (no click), exponential decay.
    tone = f'(sin(2*PI*{f}*{t})+0.25*sin(4*PI*{f}*{t}))'
    env = f'min(1,{t}*400)*exp(-{decay}*{t})*{vol}'
    return f'if(between(t,{t0},{t0 + d}),{tone}*{env},0)'


for name, (notes, decay) in SOUNDS.items():
    length = max(t0 + d for t0, _, d, _ in notes) + 0.05
    expr = '+'.join(note(t0, f, d, v, decay) for t0, f, d, v in notes)
    subprocess.run([
        'ffmpeg', '-y', '-loglevel', 'error',
        '-f', 'lavfi', '-i', f"aevalsrc='0.6*({expr})':s=44100:d={length:.2f}",
        '-ac', '1', '-c:a', 'libmp3lame', '-b:a', '96k',
        f'assets/sounds/{name}.mp3',
    ], check=True)
    print(f'{name}.mp3')
