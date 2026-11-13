"""Frames the screens rendered by test/store/store_screenshots_test.dart into
the Play Store visuals: docs/play/screenshots/*.png (1080 x 1920) and
docs/play/feature-graphic.png (1024 x 500).

usage: python3 tool/store_screenshots.py   (run by tool/store_screenshots.sh)
needs Pillow: pip install pillow
"""
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

RAW = Path("build/store_screenshots/raw")
OUT = Path("docs/play/screenshots")
FEATURE = Path("docs/play/feature-graphic.png")
FONTS = Path("assets/fonts")

# App palette (lib/core/constants/app_colors.dart): face, 3D shadow.
ORANGE = ("#FFA726", "#E69500")
PINK = ("#FF7B9C", "#E66384")
BLUE = ("#42A5F5", "#2889D9")
MAGENTA = ("#E040FB", "#C626E0")
CORAL = ("#FF8A65", "#E5704D")
PURPLE = ("#7E57C2", "#6440A8")
INK = "#2D3142"  # textPrimary, also the anthracite of the app's buttons

SHOTS = [
    ("01-home", ORANGE, "Les mots de dictée,\nen jouant !",
     "La liste de la semaine toujours en tête"),
    ("02-newlist", PINK, "La liste ajoutée\nen un instant",
     "Chaque mot est lu et épelé pour vérifier"),
    ("03-games", BLUE, "7 jeux pour retenir\nl'orthographe",
     "L'enfant choisit son jeu, autant qu'il veut"),
    ("04-qcm", MAGENTA, "Le bon mot",
     "Retrouver la bonne orthographe\nparmi les pièges"),
    ("05-spelling", PURPLE, "Écoute et épelle",
     "Le mot est épelé lettre par lettre"),
    ("06-writing", CORAL, "Écrire le mot\nen entier",
     "Un clavier adapté, avec les accents"),
    ("07-wordsearch", ORANGE, "Mots mêlés",
     "Des mots cachés dans tous les sens,\nmême en diagonale"),
    ("08-crossword", BLUE, "Mots croisés",
     "Chaque mot est lu à voix haute"),
]

W, H = 1080, 1920
SCREEN_SCALE = 1.0
BEZEL = 20
SCREEN_RADIUS = 52
STATUS_BAR = 49  # top inset of the rendered screen, in pixels


def font(weight, size):
    return ImageFont.truetype(str(FONTS / f"Fredoka-{weight}.ttf"), size)


def rgba(hex_color, alpha=255):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4)) + (alpha,)


def rounded_square(size, radius, color, angle):
    """A rotated rounded square, like the app's floating shapes."""
    pad = size // 2
    tile = Image.new("RGBA", (size + 2 * pad,) * 2, (0, 0, 0, 0))
    ImageDraw.Draw(tile).rounded_rectangle(
        (pad, pad, pad + size, pad + size), radius, fill=color)
    return tile.rotate(angle, resample=Image.BICUBIC)


def background(width, height, colors, seed, count):
    face, shadow = colors
    image = Image.new("RGBA", (width, height), rgba(face))
    # Soft vertical light, top slightly brighter.
    light = Image.linear_gradient("L").resize((width, height))
    white = Image.new("RGBA", (width, height), (255, 255, 255, 0))
    white.putalpha(light.point(lambda v: int((255 - v) * 0.16)))
    image = Image.alpha_composite(image, white)
    rng = random.Random(seed)
    for _ in range(count):
        size = rng.randint(width // 12, width // 4)
        shape = rounded_square(
            size, size // 5,
            (255, 255, 255, rng.randint(28, 60)) if rng.random() < 0.6
            else rgba(shadow, rng.randint(50, 90)),
            rng.uniform(-35, 35))
        image.alpha_composite(
            shape,
            (rng.randint(-size, width), rng.randint(-size, height)))
    return image


def draw_text_3d(draw, xy, text, fnt, shadow, anchor="ma", spacing=12,
                 depth=6, align="center"):
    """White text with the app's 3D offset shadow."""
    x, y = xy
    draw.multiline_text((x, y + depth), text, font=fnt, fill=rgba(shadow),
                        anchor=anchor, spacing=spacing, align=align)
    draw.multiline_text((x, y), text, font=fnt, fill="white",
                        anchor=anchor, spacing=spacing, align=align)


def status_bar(screen):
    """Android-like status bar in the empty top inset of the screen."""
    draw = ImageDraw.Draw(screen)
    w = screen.width
    cy = STATUS_BAR // 2 + 4
    draw.text((44, cy), "9:41", font=font("SemiBold", 25), fill=INK,
              anchor="lm")
    # Battery
    bx = w - 44
    draw.rounded_rectangle((bx - 34, cy - 10, bx, cy + 10), 4, outline=INK,
                           width=3)
    draw.rectangle((bx - 30, cy - 6, bx - 9, cy + 6), fill=INK)
    # Signal bars
    sx = bx - 78
    for i in range(4):
        h = 6 + i * 5
        draw.rectangle((sx + i * 7, cy + 10 - h, sx + i * 7 + 4, cy + 10),
                       fill=INK)
    # Wi-Fi (three arcs and a dot)
    wx, wy = sx - 26, cy + 9
    for r in (8, 15, 22):
        draw.arc((wx - r, wy - r, wx + r, wy + r), 225, 315, fill=INK,
                 width=4)


def gesture_bar(screen):
    draw = ImageDraw.Draw(screen)
    w, h = screen.size
    draw.rounded_rectangle((w / 2 - 70, h - 14, w / 2 + 70, h - 6), 4,
                           fill=INK)


def phone(screen_path):
    screen = Image.open(screen_path).convert("RGBA")
    status_bar(screen)
    gesture_bar(screen)
    screen = screen.resize(
        (round(screen.width * SCREEN_SCALE), round(screen.height * SCREEN_SCALE)),
        Image.LANCZOS)
    sw, sh = screen.size
    mask = Image.new("L", screen.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, sw - 1, sh - 1),
                                           SCREEN_RADIUS, fill=255)
    pw, ph = sw + 2 * BEZEL, sh + 2 * BEZEL
    body = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    ImageDraw.Draw(body).rounded_rectangle(
        (0, 0, pw - 1, ph - 1), SCREEN_RADIUS + BEZEL, fill=rgba(INK))
    body.paste(screen, (BEZEL, BEZEL), mask)
    # Front camera
    ImageDraw.Draw(body).ellipse(
        (pw / 2 - 11, BEZEL + 14, pw / 2 + 11, BEZEL + 36), fill=rgba(INK))
    return body


def screenshot(name, colors, title, subtitle, index):
    image = background(W, H, colors, seed=index, count=10)
    draw = ImageDraw.Draw(image)
    lines = title.count("\n") + 1
    title_font = font("Bold", 84 if lines > 1 else 96)
    y = 90 if lines > 1 else 120
    draw_text_3d(draw, (W / 2, y), title, title_font, colors[1], spacing=8)
    top = draw.multiline_textbbox((W / 2, y), title, font=title_font,
                                  anchor="ma", spacing=8)[3]
    sub_font = font("SemiBold", 44)
    draw_text_3d(draw, (W / 2, top + 34), subtitle, sub_font, colors[1],
                 depth=3, spacing=10)
    text_bottom = draw.multiline_textbbox((W / 2, top + 34), subtitle,
                                          font=sub_font, anchor="ma",
                                          spacing=10)[3]

    device = phone(RAW / f"{name}.png")
    x = (W - device.width) // 2
    # Right under the text; the phone bottom may run off the edge.
    y = max(text_bottom + 60, H - device.height - 24)
    # 3D shadow of the phone, offset without blur, like the app's cards.
    shadow = Image.new("RGBA", device.size, rgba(colors[1]))
    shadow.putalpha(device.getchannel("A"))
    image.alpha_composite(shadow, (x, y + 18))
    image.alpha_composite(device, (x, y))
    image.convert("RGB").save(OUT / f"{name}.png", optimize=True)


def logo_tile(letter, colors, size, angle):
    face, shadow = colors
    depth = size // 9
    tile = Image.new("RGBA", (size, size + depth), (0, 0, 0, 0))
    draw = ImageDraw.Draw(tile)
    radius = size // 5
    draw.rounded_rectangle((0, depth, size - 1, size + depth - 1), radius,
                           fill=rgba(shadow))
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius, fill=rgba(face))
    draw.text((size / 2, size / 2 + size * 0.03), letter,
              font=font("Bold", int(size * 0.6)), fill="white", anchor="mm")
    pad = size // 3
    canvas = Image.new("RGBA", (size + 2 * pad, size + depth + 2 * pad),
                       (0, 0, 0, 0))
    canvas.alpha_composite(tile, (pad, pad))
    return canvas.rotate(angle, resample=Image.BICUBIC)


def feature_graphic():
    """White, like the app, with the MES / MOTS tiles of the home screen."""
    fw, fh = 1024, 500
    image = Image.new("RGBA", (fw, fh), (255, 255, 255, 255))
    rng = random.Random(7)
    palette = [ORANGE, PINK, BLUE, MAGENTA, CORAL]
    # Floating shapes around the text, away from the logo.
    for i, (x, y) in enumerate([(470, -40), (900, 30), (960, 330), (780, 440),
                                (520, 420), (-30, 400), (20, -50)]):
        size = rng.randint(70, 120)
        face = palette[i % len(palette)][0]
        shape = rounded_square(size, size // 5, rgba(face, 34),
                               rng.uniform(-30, 30))
        image.alpha_composite(shape, (x - size // 2, y - size // 2))

    rows = [("MES", [ORANGE, PINK, BLUE], [-6, 4, -3]),
            ("MOTS", [MAGENTA, CORAL, ORANGE, PINK], [3, -5, 6, -2])]
    size = 108
    for r, (word, colors, angles) in enumerate(rows):
        x0 = 60
        y0 = 90 + r * 165
        for i, letter in enumerate(word):
            tile = logo_tile(letter, colors[i], size, angles[i])
            image.alpha_composite(tile, (x0 + i * 120 - size // 3,
                                         y0 - size // 3 + (10 if i % 2 else 0)))

    draw = ImageDraw.Draw(image)
    draw.multiline_text((560, 120), "Les mots\nde dictée,\nen jouant !",
                        font=font("Bold", 64), fill=INK, spacing=4)
    draw.text((562, 388), "7 jeux · mots lus à voix haute",
              font=font("SemiBold", 30), fill=rgba("#7A7F94"))
    image.convert("RGB").save(FEATURE, optimize=True)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for index, (name, colors, title, subtitle) in enumerate(SHOTS):
        screenshot(name, colors, title, subtitle, index)
        print(f"✓ {OUT / name}.png")
    feature_graphic()
    print(f"✓ {FEATURE}")


if __name__ == "__main__":
    main()
