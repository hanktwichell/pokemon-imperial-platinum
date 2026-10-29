#!/usr/bin/env python3
"""Fit a tall 96x96 front on the battle screen (owner, 2026-10-29: "shrink the big sprites that get cut. maybe move
them down too so we don't have to shrink em as much").

A foe's sprite has its centre at y 50, or y 42 for the second foe of a double battle (gEncounterCoords). Its y offset
moves it down, so its feet stand on the platform, and a floating Pokemon's elevation (sprite_data.json's
addl_y_offset) lifts it. A 96x96 box starts 48 rows above its centre, so tall art could start above the screen and
lose its top rows (Celesteela lost 22 in a single battle). fit() makes a front fit at y 42, so it is never cut:
- first it moves down: up to MOVE_DOWN pixels, so a standing front's feet stay above the player's HP box (y 94), and a
  floating one also up to half its elevation, so it still floats;
- what is left, it shrinks. It removes rows, and columns in proportion, choosing the ones most like their neighbour
  so outlines stay whole, and keeps the palette indices so the shiny palette still fits. The feet stay where they
  were.

convert_fronts96.py, convert_battle_sprites.py and convert_form_sprites.py call it on each 96x96 front they write.
"""
from PIL import Image

TOP_CENTRE_Y = 42  # the highest a foe's sprite centre sits: the second foe of a double battle
MOVE_DOWN = 4


def overflow(indexed, offset, elevation):
    """The rows of art above the top of the screen at y TOP_CENTRE_Y (0 or fewer: it fits)."""
    bb = indexed.getbbox()
    return -(TOP_CENTRE_Y - indexed.height // 2 + offset - elevation + bb[1]) if bb else 0


def fit(indexed, offset, elevation):
    """(the front, the pixels to add to its y offset) for a 96x96 indexed front whose y offset is `offset`."""
    need = overflow(indexed, offset, elevation)
    if need <= 0:
        return indexed, 0
    down = min(need, MOVE_DOWN + elevation // 2)
    if need > down:
        indexed = shrink(indexed, need - down)
    return indexed, down


def drop_lines(lines, n, keep_last):
    """Remove n lines (rows of pixel indices), each time the one most like the line before it, never two side by
    side while others are left, and never the first (or, with keep_last, the last)."""
    index = list(range(len(lines)))
    removed = set()
    for _ in range(n):
        best = None
        for k in range(1, len(lines) - (1 if keep_last else 0)):
            beside = index[k] - 1 in removed or index[k] + 1 in removed
            cost = sum(a != b for a, b in zip(lines[k], lines[k - 1]))
            key = (beside, cost)
            if best is None or key < best[0]:
                best = (key, k)
        k = best[1]
        removed.add(index[k])
        del lines[k]
        del index[k]
    return lines


def shrink(indexed, rows):
    """The front with `rows` rows taken out of its art, and as many columns in proportion; its bottom row stays
    where it was, and so does its middle."""
    left, top, right, bottom = indexed.getbbox()
    width, height = right - left, bottom - top
    px = indexed.load()
    art = [[px[x, y] for x in range(left, right)] for y in range(top, bottom)]
    art = drop_lines(art, rows, keep_last=True)
    cols = [list(c) for c in zip(*art)]
    cols = drop_lines(cols, round(width * rows / height), keep_last=False)
    art = [list(r) for r in zip(*cols)]
    out = Image.new("P", indexed.size, 0)
    out.putpalette(indexed.getpalette())
    x0, y0 = left + (width - len(art[0])) // 2, bottom - len(art)
    op = out.load()
    for y, row in enumerate(art):
        for x, v in enumerate(row):
            op[x0 + x, y0 + y] = v
    return out
