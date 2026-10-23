#!/usr/bin/env python3
"""Draw the symbols that flash over a Pokemon as it Mega Evolves or Primal Reverts (milestone E8, docs/MegaEvolution.md):
decomp/res/graphics/battle/moves/sovereign_{mega,alpha,omega}_symbol.png, with their _cell.json and _anim.json.

Each PNG is three 32x32 frames stacked vertically: the symbol, a white flash of it, and a blank frame. The animation
flashes it (white, symbol, blank, symbol, blank, symbol) and ends; sovereign_*_revealed.s shows it with
SPRITE_FUNC_OFFSET_AND_ANIMATE, centred on the Pokemon.
  mega   a rainbow ring around a white disc split by an S-curve, after the Mega Evolution symbol
  alpha  Kyogre's alpha in a ring of blues
  omega  Groudon's omega in a ring of reds

Usage: python3 tools/sprites/make_mega_symbols.py
"""
import json
import math
import os

from PIL import Image

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "decomp", "res", "graphics", "battle", "moves")
SIZE = 32
C = 15.5  # centre
RING_OUTER, RING_INNER = 14.2, 10.4

TRANSPARENT, OUTLINE, WHITE, GLYPH, DISC = 0, 1, 2, 3, 12
RING = range(4, 12)  # 8 colours around the ring

SYMBOLS = {
    "mega": {
        "outline": (40, 24, 64), "glyph": (96, 48, 160), "disc": (248, 248, 248),
        "ring": [(232, 64, 184), (240, 72, 72), (248, 152, 48), (248, 224, 64),
                 (96, 208, 96), (64, 200, 232), (64, 112, 232), (152, 88, 232)],
    },
    "alpha": {
        "outline": (16, 24, 64), "glyph": (24, 40, 120), "disc": (208, 236, 255),
        "ring": [(24, 64, 168), (32, 88, 192), (40, 112, 216), (56, 140, 232),
                 (72, 168, 240), (96, 192, 248), (72, 168, 240), (40, 112, 216)],
    },
    "omega": {
        "outline": (64, 16, 8), "glyph": (128, 24, 16), "disc": (255, 236, 208),
        "ring": [(168, 32, 24), (192, 48, 24), (216, 72, 32), (232, 104, 40),
                 (240, 136, 48), (248, 176, 64), (232, 104, 40), (192, 48, 24)],
    },
}


def palette(sym):
    p = [(255, 0, 255), sym["outline"], (248, 248, 248), sym["glyph"]] + sym["ring"] + [sym["disc"]]
    p += [(0, 0, 0)] * (16 - len(p))
    return [c for rgb in p for c in rgb]


def glyph_mega(x, y):
    # An S-curve from top to bottom, like the Mega Evolution symbol's swirl.
    cx = C + 3.6 * math.sin((y - C) / RING_INNER * math.pi)
    return abs(x - cx) < 1.3


def glyph_alpha(x, y):
    loop = abs(math.hypot(x - 13.5, y - 16.5) - 4.0) < 1.0
    stroke = 19.0 <= x <= 20.6 and 10.5 <= y <= 22.5 and not (x > 20 and y < 12)
    tail = 20.0 <= x <= 22.6 and 21.0 <= y <= 22.6
    return loop or stroke or tail


def glyph_omega(x, y):
    d = math.hypot(x - C, y - 14.5)
    arc = abs(d - 5.0) < 1.0 and y < 19.5
    feet = 19.5 <= y <= 21.0 and (9.5 <= x <= 13.5 or 17.5 <= x <= 21.5)
    return arc or feet


GLYPHS = {"mega": glyph_mega, "alpha": glyph_alpha, "omega": glyph_omega}


def draw(img, top, name, white):
    glyph = GLYPHS[name]
    for y in range(SIZE):
        for x in range(SIZE):
            d = math.hypot(x - C, y - C)
            if d > RING_OUTER + 1.2:
                continue
            if d > RING_OUTER:
                c = OUTLINE
            elif RING_INNER - 1.0 < d <= RING_INNER:
                c = WHITE if white else OUTLINE
            elif d > RING_INNER:
                band = int((math.degrees(math.atan2(y - C, x - C)) + 360 + 22.5) % 360 // 45)
                c = WHITE if white else RING[band]
            elif glyph(x, y):
                c = WHITE if white else GLYPH
            else:
                c = WHITE if white else DISC
            img.putpixel((x, top + y), c)


def cell(char_name):
    return {
        "cellAttrs": {"hFlip": False, "vFlip": False, "hvFlip": False, "boundingRect": True,
                      "boundingSphereRadius": 16},
        "maxX": 16, "maxY": 16, "minX": -16, "minY": -16,
        "oamCount": 1,
        "OAM": [{
            "Attr0": {"YCoordinate": -16, "Rotation": False, "SizeDisable": False, "Mode": 0, "Mosaic": False,
                      "Colours": 16, "Shape": 0},
            "Attr1": {"XCoordinate": -16, "RotationScaling": 0, "Size": 2},
            "Attr2": {"CharName": char_name, "Priority": 0, "Palette": 0},
        }],
    }


# (cell, frames): 0 symbol, 1 white flash, 2 blank
FLASH = [(1, 2), (0, 5), (2, 2), (0, 5), (2, 2), (0, 16)]


def main():
    for name, sym in SYMBOLS.items():
        img = Image.new("P", (SIZE, SIZE * 3), TRANSPARENT)
        img.putpalette(palette(sym))
        draw(img, 0, name, False)
        draw(img, SIZE, name, True)
        base = os.path.join(OUT_DIR, f"sovereign_{name}_symbol")
        img.save(base + ".png", bits=4)

        cells = {
            "labelEnabled": True, "dontPadKbec": True, "extended": True, "vramTransferEnabled": False,
            "cellCount": 3, "mappingType": 1,
            "cells": [cell(0), cell(8), cell(16)],  # CharName counts 64-byte blocks: a 32x32 frame is 8
            "labels": ["CellAnime0", "CellAnime1", "CellAnime2"], "labelCount": 3,
        }
        anim = {
            "labelEnabled": True, "sequenceCount": 1, "frameCount": len(FLASH),
            "sequences": [{
                "frameCount": len(FLASH), "loopStartFrame": 0, "animationElement": 0, "animationType": 1,
                "playbackMode": 1,
                "frameData": [{"frameDelay": frames, "resultId": result} for result, frames in FLASH],
            }],
            "animationResults": [{"resultType": 0, "index": i} for i in range(3)],
            "resultCount": 3, "labels": ["CellAnime0"], "labelCount": 1,
        }
        with open(base + "_cell.json", "w") as f:
            json.dump(cells, f, indent="\t")
        with open(base + "_anim.json", "w") as f:
            json.dump(anim, f, indent="\t")
        print(f"wrote {base}.png and its cell/anim JSON")


if __name__ == "__main__":
    main()
