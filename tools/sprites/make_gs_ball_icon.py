#!/usr/bin/env python3
"""Draw the GS Ball's bag icon (E10, Renegade's Celebi event): decomp/res/items/icons/gs_ball.png + .pal.

PokeAPI has no GS Ball sprite, so this recolours Platinum's own Poké Ball icon: the top half gold, the bottom half
silver. It keeps the icon format (32x32, 4-bit, index 0 transparent, the art in the top-left 24x24 area).
A placeholder until the owner's icon arrives (docs/SpriteChecklist.xlsx, sheet Item Icons); data/items_sovereign.yaml
lists it as `icon: drawn`.

Usage: python3 tools/sprites/make_gs_ball_icon.py
"""
import os

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ICON_DIR = os.path.join(ROOT, "decomp", "res", "items", "icons")

# Poké Ball palette index -> GS Ball colour. 7-11 are the red top's shades, 4 and 5 the white bottom's.
RECOLOUR = {
    7: (120, 80, 16),
    8: (168, 120, 24),
    9: (208, 160, 32),
    10: (240, 200, 56),
    11: (255, 240, 160),
    4: (152, 160, 176),
    5: (200, 208, 216),
}


def main():
    src = Image.open(os.path.join(ICON_DIR, "poke_ball.png"))
    with open(os.path.join(ICON_DIR, "poke_ball.pal")) as f:
        lines = f.read().split()
    values = [int(v) for v in lines[3:]]
    colours = [tuple(values[i:i + 3]) for i in range(0, len(values), 3)]
    for i, c in RECOLOUR.items():
        colours[i] = c
    out = src.copy()
    out.putpalette([v for c in colours[:16] for v in c])
    out.save(os.path.join(ICON_DIR, "gs_ball.png"), bits=4)
    with open(os.path.join(ICON_DIR, "gs_ball.pal"), "w", newline="\r\n") as f:
        f.write("JASC-PAL\n0100\n256\n")
        for r, g, b in colours:
            f.write(f"{r} {g} {b}\n")
    print("wrote gs_ball.png and gs_ball.pal")


if __name__ == "__main__":
    main()
