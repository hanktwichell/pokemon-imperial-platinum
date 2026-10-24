#!/usr/bin/env python3
"""Draw the time portal's overworld sprite (E10, Renegade's Celebi event in Eterna Forest):
decomp/res/graphics/field_sprites/objects/time_portal.png.

Renegade opens red portals around the forest, each holding the memory of a battle. This draws one: a red oval
standing on the ground, ringed from dark crimson to a pale centre, with a swirl. One 32x32 frame, 4-bit, index 0
transparent, like the small legendary sprites (BILLBOARD_MODEL_GENERIC_32x32). A placeholder until the owner's
art arrives (E12).

Usage: python3 tools/sprites/make_time_portal_overworld.py
"""
import math
import os

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "decomp", "res", "graphics", "field_sprites", "objects", "time_portal.png")

SIZE = 32
# Outside in: outline, dark crimson, crimson, red, pink, pale pink, the centre's glow.
RINGS = [(64, 8, 24), (120, 16, 40), (176, 24, 56), (224, 48, 80), (248, 112, 144), (255, 176, 200),
         (255, 232, 240)]
SWIRL = (255, 255, 255)  # the brightest swirl pixels, past the centre's glow
CX, CY = 15.5, 17.5   # the oval's centre: it stands on the bottom of the frame like the legendary sprites
RX, RY = 10.0, 13.0   # half-width and half-height


def main():
    img = Image.new("P", (SIZE, SIZE), 0)
    palette = [(0, 0, 0)] + RINGS + [SWIRL]
    img.putpalette([v for c in palette + [(0, 0, 0)] * (16 - len(palette)) for v in c])
    for y in range(SIZE):
        for x in range(SIZE):
            dx, dy = (x - CX) / RX, (y - CY) / RY
            r = math.hypot(dx, dy)
            if r > 1.0:
                continue
            ring = min(int((1.0 - r) * len(RINGS) * 1.15), len(RINGS) - 1)
            # A two-armed swirl: two rings brighter where the angle and the radius line up.
            angle = math.atan2(dy, dx)
            if 0.2 < r < 0.9 and abs(math.sin(2 * angle + 7 * r)) < 0.4:
                ring = min(ring + 2, len(RINGS))
            img.putpixel((x, y), 1 + ring)
    img.save(OUT, bits=4)
    print("wrote", os.path.relpath(OUT, ROOT))


if __name__ == "__main__":
    main()
