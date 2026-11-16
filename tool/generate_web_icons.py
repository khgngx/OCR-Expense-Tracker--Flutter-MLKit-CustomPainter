#!/usr/bin/env python3
"""Draws the PWA icons (teal tile + receipt glyph) into web/. Requires Pillow."""
from pathlib import Path

from PIL import Image, ImageDraw

WEB = Path(__file__).resolve().parent.parent / "web"
TEAL = (46, 125, 107, 255)
WHITE = (255, 255, 255, 255)


def glyph(d: ImageDraw.ImageDraw, size: int, scale: float) -> None:
    """Receipt with torn bottom edge and text lines, centered, `scale` of the tile."""
    w = size * 0.42 * scale / 0.6
    h = size * 0.56 * scale / 0.6
    x0, y0 = (size - w) / 2, (size - h) / 2
    tooth = w / 8
    pts = [(x0, y0), (x0 + w, y0), (x0 + w, y0 + h - tooth)]
    for i in range(8):
        pts.append((x0 + w - tooth * (i + 0.5), y0 + h))
        pts.append((x0 + w - tooth * (i + 1), y0 + h - tooth))
    d.polygon(pts, fill=WHITE)
    for i, frac in enumerate((0.22, 0.4, 0.58)):
        y = y0 + h * frac
        end = x0 + w * (0.78 if i < 2 else 0.55)
        d.rounded_rectangle([x0 + w * 0.2, y, end, y + h * 0.055], radius=h * 0.03, fill=TEAL)


def tile(size: int, maskable: bool) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if maskable:
        d.rectangle([0, 0, size, size], fill=TEAL)  # full bleed; the OS applies the mask
        glyph(d, size, 0.5)  # stay inside the 80% safe zone
    else:
        d.rounded_rectangle([0, 0, size - 1, size - 1], radius=size * 0.22, fill=TEAL)
        glyph(d, size, 0.6)
    return img


(WEB / "icons").mkdir(exist_ok=True)
for s in (192, 512):
    tile(s, False).save(WEB / "icons" / f"Icon-{s}.png")
    tile(s, True).save(WEB / "icons" / f"Icon-maskable-{s}.png")
tile(64, False).save(WEB / "favicon.png")
print("icons written")
