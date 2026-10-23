#!/usr/bin/env python3
"""Draw the battle move menu's MEGA EVOLUTION button (milestone E8): decomp/res/graphics/battle/interface/mega_button.png.

Three 64x32 frames stacked vertically (the art uses the top 24 rows), one 16-colour palette:
  frame 0  off: a grey pill with a dark socket and grey lettering
  frame 1  on:  a pink-violet-blue pill with a glowing socket and white lettering
  frame 2  on, pulse: the same with a gold outline (mega_button_anim.json alternates frames 1 and 2)
The held Mega Stone's own item icon is drawn over the socket as a second sprite (battle_subscreen.c). The socket is
centred on the stone, at (13.5, 11.5) here, and leaves a one-pixel ring around a 14x14 stone.

Usage: python3 tools/sprites/make_mega_button.py
"""
import os

from PIL import Image

OUT = os.path.join(os.path.dirname(__file__), "..", "..", "decomp", "res", "graphics", "battle", "interface",
                   "mega_button.png")

PALETTE = [
    (255, 0, 255),    # 0 transparent
    (32, 32, 40),     # 1 off outline
    (200, 200, 212),  # 2 off body top
    (160, 160, 176),  # 3 off body middle
    (112, 112, 128),  # 4 off body bottom
    (80, 80, 96),     # 5 off lettering
    (248, 248, 248),  # 6 white
    (58, 24, 88),     # 7 on outline
    (255, 122, 216),  # 8 on body top (pink)
    (180, 92, 240),   # 9 on body middle (violet)
    (74, 140, 255),   # 10 on body bottom (blue)
    (255, 224, 112),  # 11 gold
    (216, 160, 32),   # 12 gold shade
    (48, 48, 60),     # 13 off socket
    (255, 246, 192),  # 14 on socket glow
    (40, 16, 60),     # 15 on lettering outline
]

# "MEGA", 2-pixel strokes, 7 rows.
GLYPHS = {
    "M": ["X.....X", "XX...XX", "XXX.XXX", "XX.X.XX", "XX...XX", "XX...XX", "XX...XX"],
    "E": ["XXXXX", "XX...", "XX...", "XXXX.", "XX...", "XX...", "XXXXX"],
    "G": [".XXXX.", "XX..XX", "XX....", "XX.XXX", "XX..XX", "XX..XX", ".XXXX."],
    "A": ["..XX..", ".XXXX.", "XX..XX", "XX..XX", "XXXXXX", "XX..XX", "XX..XX"],
}

W, H, ART_H = 64, 32, 24
PILL_X0, PILL_X1, PILL_Y0, PILL_Y1 = 2, 61, 1, 22  # inclusive
SOCKET_CX, SOCKET_CY, SOCKET_R = 13.5, 11.5, 9


def in_pill(x, y):
    r = (PILL_Y1 - PILL_Y0 + 1) / 2
    cy = (PILL_Y0 + PILL_Y1) / 2
    if y < PILL_Y0 or y > PILL_Y1:
        return False
    left_cx, right_cx = PILL_X0 + r - 0.5, PILL_X1 - r + 0.5
    if x < left_cx:
        return (x - left_cx) ** 2 + (y - cy) ** 2 <= r * r
    if x > right_cx:
        return (x - right_cx) ** 2 + (y - cy) ** 2 <= r * r
    return True


def draw_frame(img, top, state):
    on, pulse = state >= 1, state == 2
    outline = 11 if pulse else 7 if on else 1
    body = (8, 9, 10) if on else (2, 3, 4)
    for y in range(ART_H):
        for x in range(W):
            if not in_pill(x, y):
                continue
            edge = not all(in_pill(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            if edge:
                c = outline
            elif not in_pill(x, y - 2):
                c = 6  # top highlight
            else:
                third = (y - PILL_Y0) * 3 // (PILL_Y1 - PILL_Y0 + 1)
                c = body[min(third, 2)]
            img.putpixel((x, top + y), c)

    # The socket for the Mega Stone icon.
    for y in range(ART_H):
        for x in range(W):
            d = ((x - SOCKET_CX) ** 2 + (y - SOCKET_CY) ** 2) ** 0.5
            if d <= SOCKET_R:
                rim = d > SOCKET_R - 1
                c = (12 if on else 1) if rim else (14 if on else 13)
                img.putpixel((x, top + y), c)

    # Lettering, centred in the pill right of the socket.
    word = "MEGA"
    width = sum(len(GLYPHS[ch][0]) for ch in word) + len(word) - 1
    x0 = (int(SOCKET_CX + SOCKET_R) + 1 + PILL_X1) // 2 - width // 2 + 1
    y0 = 8
    pixels = []
    cx = x0
    for ch in word:
        for gy, row in enumerate(GLYPHS[ch]):
            for gx, bit in enumerate(row):
                if bit == "X":
                    pixels.append((cx + gx, y0 + gy))
        cx += len(GLYPHS[ch][0]) + 1
    if on:  # a 1-pixel dark outline so the white lettering reads on the gradient
        for px, py in pixels:
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    if (px + dx, py + dy) not in pixels:
                        img.putpixel((px + dx, top + py + dy), 15)
    for px, py in pixels:
        img.putpixel((px, top + py), 6 if on else 5)


def main():
    img = Image.new("P", (W, H * 3), 0)
    img.putpalette([c for rgb in PALETTE for c in rgb])
    for state in range(3):
        draw_frame(img, state * H, state)
    img.save(OUT, bits=4)
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
