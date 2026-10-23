#!/usr/bin/env python3
"""Draw the Mega symbol shown by the name of a Mega or Primal in battle (milestone E8, docs/MegaEvolution.md):
decomp/res/graphics/battle/healthbox/sovereign_mega_icon.png, with its _cell.json and _anim.json.

Three 16x16 frames stacked vertically, in the HP bar's own palette (healthbox.c loads no palette for them):
  0  Mega   a rainbow stone split by the white swirl of the Mega Evolution symbol, with a glint
  1  alpha  Primal Kyogre's alpha on a blue stone
  2  omega  Primal Groudon's omega on a red stone
healthbox.c shows the frame (animation 0, 1 or 2) by the name: right of the level on the foe's boxes, left of the name
on the player's, overlapping the box's border.

Usage: python3 tools/sprites/make_mega_icon.py
"""
import json
import os

from PIL import Image

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "decomp", "res", "graphics", "battle", "healthbox")
PALETTE_SOURCE = os.path.join(OUT_DIR, "player_singles.png")  # the HP bar palette (primary.NCLR)
SIZE = 16

# The HP bar palette: 2 outline, 6 green, 8 gold, 9 dark red, 10 red, 11 blue, 12 light blue, 13 magenta, 14 white.
OUTLINE, WHITE = 2, 14

CIRCLE = [
    ".....######.....",
    "...##......##...",
    "..#..........#..",
    ".#............#.",
    ".#............#.",
    "#..............#",
    "#..............#",
    "#..............#",
    "#..............#",
    "#..............#",
    "#..............#",
    ".#............#.",
    ".#............#.",
    "..#..........#..",
    "...##......##...",
    ".....######.....",
]

# The Mega stone's rainbow, by row: magenta, red, gold, green, light blue, blue.
MEGA_BANDS = {1: 13, 2: 13, 3: 10, 4: 10, 5: 10, 6: 8, 7: 8, 8: 6, 9: 6, 10: 12, 11: 12, 12: 12, 13: 11, 14: 11}
# The swirl's top half by row; the bottom half is the same turned half a circle.
MEGA_SWIRL_TOP = {1: [8, 9], 2: [6, 7, 8], 3: [5, 6], 4: [4, 5], 5: [4, 5], 6: [5, 6], 7: [6, 7, 8]}
MEGA_GLINT = [(11, 3), (12, 4)]

ALPHA = [
    "..###...#.",
    ".#...#.#..",
    "#.....#...",
    "#.....#...",
    "#.....#...",
    ".#...#.#..",
    "..###...#.",
]
OMEGA = [
    "..####..",
    ".#....#.",
    "#......#",
    "#......#",
    "#......#",
    ".#....#.",
    "###..###",
]


def inside(x, y):
    row = CIRCLE[y]
    return row.index("#") < x < row.rindex("#") and row[x] == "."


def stone(colour):
    """The outlined stone, its inside coloured by colour(x, y)."""
    frame = [[0] * SIZE for _ in range(SIZE)]
    for y in range(SIZE):
        for x in range(SIZE):
            if CIRCLE[y][x] == "#":
                frame[y][x] = OUTLINE
            elif inside(x, y):
                frame[y][x] = colour(x, y)
    return frame


def mega_frame():
    frame = stone(lambda x, y: MEGA_BANDS[y])
    for y, xs in MEGA_SWIRL_TOP.items():
        for x in xs:
            frame[y][x] = WHITE
            frame[SIZE - 1 - y][SIZE - 1 - x] = WHITE
    for x, y in MEGA_GLINT:
        frame[y][x] = WHITE
    return frame


def glyph_frame(glyph, inner, ring):
    """A stone with an inner colour and a ring of another, and the glyph in white at its centre."""
    frame = stone(lambda x, y: inner if (x - 7.5) ** 2 + (y - 7.5) ** 2 < 5.2 ** 2 else ring)
    x0, y0 = (SIZE - len(glyph[0])) // 2, (SIZE - len(glyph)) // 2 + 1
    for gy, row in enumerate(glyph):
        for gx, c in enumerate(row):
            if c == "#":
                frame[y0 + gy][x0 + gx] = WHITE
    return frame


def write_json(name, data):
    with open(os.path.join(OUT_DIR, name), "w") as f:
        json.dump(data, f, indent="\t")
        f.write("\n")


def cell(char_name):
    oam = {
        "Attr0": {"YCoordinate": -8, "Rotation": False, "SizeDisable": False, "Mode": 0, "Mosaic": False,
                  "Colours": 16, "Shape": 0},
        "Attr1": {"XCoordinate": -8, "RotationScaling": 0, "Size": 1},
        "Attr2": {"CharName": char_name, "Priority": 0, "Palette": 0},
    }
    return {
        "cellAttrs": {"hFlip": False, "vFlip": False, "hvFlip": False, "boundingRect": True,
                      "boundingSphereRadius": 8},
        "maxX": 8, "maxY": 8, "minX": -8, "minY": -8, "oamCount": 1, "OAM": [oam],
    }


def main():
    frames = [mega_frame(), glyph_frame(ALPHA, 11, 12), glyph_frame(OMEGA, 10, 9)]
    img = Image.new("P", (SIZE, SIZE * len(frames)), 0)
    img.putpalette(Image.open(PALETTE_SOURCE).getpalette()[:48])
    for i, frame in enumerate(frames):
        for y, row in enumerate(frame):
            for x, c in enumerate(row):
                img.putpixel((x, i * SIZE + y), c)
    img.save(os.path.join(OUT_DIR, "sovereign_mega_icon.png"), bits=4)

    count = len(frames)
    # 64K character mapping, like the rest of the HP bar: CharName counts pairs of tiles, 4 tiles to a frame.
    write_json("sovereign_mega_icon_cell.json", {
        "labelEnabled": True, "dontPadKbec": False, "extended": True, "vramTransferEnabled": False,
        "ucatEnabled": False, "cellCount": count, "mappingType": 1,
        "cells": [cell(i * 2) for i in range(count)],
        "labels": [f"CellAnime{i}" for i in range(count)], "labelCount": count,
    })
    write_json("sovereign_mega_icon_anim.json", {
        "labelEnabled": True, "uaatEnabled": False, "sequenceCount": count, "frameCount": count,
        "sequences": [{"frameCount": 1, "loopStartFrame": 0, "animationElement": 2, "animationType": 1,
                       "playbackMode": 2, "frameData": [{"frameDelay": 1, "resultId": i}]} for i in range(count)],
        "animationResults": [{"resultType": 2, "index": i, "positionX": 0, "positionY": 0} for i in range(count)],
        "resultCount": count,
        "labels": [f"CellAnime{i}" for i in range(count)], "labelCount": count,
    })
    print(f"wrote {OUT_DIR}/sovereign_mega_icon{{.png,_cell.json,_anim.json}}")


if __name__ == "__main__":
    main()
