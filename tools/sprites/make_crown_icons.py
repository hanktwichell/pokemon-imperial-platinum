#!/usr/bin/env python3
"""Draw the bag icons of the crown pieces, the Crown and the Sovereign Crown (decision 23, docs/Story.md):
decomp/res/items/icons/<item>.png + .pal, in Platinum's icon format (32x32, 4-bit, index 0 transparent, the art in the
top-left 24x24 area like Platinum's own icons). These are placeholders until the owner's icons arrive
(docs/SpriteChecklist.xlsx, sheet Item Icons); data/items_sovereign.yaml lists them as `icon: drawn`.

  gold pieces   Gold Shard, Gold Fragment, Gold Sliver, Gold Flake: broken bits of a gold band
  oval cut      Oval Emerald, Oval Sapphire, Oval Ruby: an oval stone with a flat table and a glint
  rose cut      Rose Emerald, Rose Sapphire, Rose Ruby: a domed stone covered in triangular facets
  Crown Diamond a brilliant-cut diamond seen from the side
  Crown         a gold crown set with the jewels
  Sovereign Crown  the Crown with a purple cap and a cross on top

Usage: python3 tools/sprites/make_crown_icons.py
"""
import math
import os

from PIL import Image, ImageDraw

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ICON_DIR = os.path.join(ROOT, "decomp", "res", "items", "icons")
SIZE, ART = 32, 24
GREY = (180, 180, 180)  # Platinum's icons use this grey for the transparent colour

GOLD = {"outline": (88, 56, 8), "dark": (168, 112, 24), "mid": (224, 168, 40), "light": (248, 216, 96),
        "shine": (255, 248, 200)}
STONES = {
    "emerald": {"outline": (8, 64, 32), "dark": (16, 120, 56), "mid": (40, 176, 88), "light": (120, 224, 152),
                "shine": (224, 255, 232)},
    "sapphire": {"outline": (8, 24, 88), "dark": (24, 56, 168), "mid": (48, 104, 224), "light": (128, 168, 248),
                 "shine": (232, 240, 255)},
    "ruby": {"outline": (72, 8, 24), "dark": (152, 16, 40), "mid": (216, 40, 64), "light": (248, 120, 136),
             "shine": (255, 232, 236)},
    "diamond": {"outline": (56, 72, 104), "dark": (144, 176, 208), "mid": (200, 224, 240), "light": (232, 244, 252),
                "shine": (255, 255, 255)},
}
VELVET = {"outline": (40, 8, 56), "dark": (88, 24, 120), "mid": (136, 48, 168)}


class Icon:
    """A 24x24 drawing in RGB colours, turned into a 16-colour icon at the end."""

    def __init__(self):
        self.img = Image.new("RGB", (ART, ART), GREY)
        self.draw = ImageDraw.Draw(self.img)

    def poly(self, points, fill, outline=None):
        self.draw.polygon(points, fill=fill, outline=outline)

    def px(self, x, y, colour):
        if 0 <= x < ART and 0 <= y < ART:
            self.img.putpixel((x, y), colour)

    def line(self, points, colour):
        self.draw.line(points, fill=colour)

    def outline(self, colour):
        """Outline the drawing: every transparent pixel next to the art turns `colour`."""
        src = self.img.copy()
        for y in range(ART):
            for x in range(ART):
                if src.getpixel((x, y)) != GREY:
                    continue
                if any(0 <= x + dx < ART and 0 <= y + dy < ART and src.getpixel((x + dx, y + dy)) != GREY
                       for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    self.img.putpixel((x, y), colour)

    def save(self, stem):
        data = self.img.get_flattened_data() if hasattr(self.img, "get_flattened_data") else self.img.getdata()
        colours = [GREY] + sorted({c for c in data if c != GREY})
        if len(colours) > 16:
            raise SystemExit(f"{stem}: {len(colours)} colours (max 16)")
        out = Image.new("P", (SIZE, SIZE), 0)
        out.putpalette([v for c in colours + [(0, 0, 0)] * (16 - len(colours)) for v in c])
        index = {c: i for i, c in enumerate(colours)}
        for y in range(ART):
            for x in range(ART):
                out.putpixel((x, y), index[self.img.getpixel((x, y))])
        out.save(os.path.join(ICON_DIR, stem + ".png"), bits=4)
        with open(os.path.join(ICON_DIR, stem + ".pal"), "w", newline="\r\n") as f:
            f.write("JASC-PAL\n0100\n256\n")
            for r, g, b in colours + [(0, 0, 0)] * (256 - len(colours)):
                f.write(f"{r} {g} {b}\n")


def gold_piece(points, shine):
    """A flat gold piece: the polygon, lit from the top left, with a glint."""
    icon = Icon()
    g = GOLD
    icon.poly(points, g["mid"])
    # Light the upper-left edges and shade the lower-right ones.
    n = len(points)
    for i in range(n):
        (x0, y0), (x1, y1) = points[i], points[(i + 1) % n]
        nx, ny = y1 - y0, x0 - x1  # the edge's outward normal for a clockwise polygon
        colour = g["light"] if nx + ny < 0 else g["dark"]
        icon.line([(x0, y0), (x1, y1)], colour)
    for x, y in shine:
        icon.px(x, y, g["shine"])
    icon.outline(g["outline"])
    return icon


def oval(stone):
    c = STONES[stone]
    icon = Icon()
    box = (4, 2, 19, 21)
    icon.draw.ellipse(box, fill=c["dark"])
    icon.draw.ellipse((5, 3, 18, 19), fill=c["mid"])
    icon.draw.ellipse((8, 6, 15, 15), fill=c["light"])  # the table
    icon.draw.ellipse((9, 7, 14, 14), fill=c["mid"])
    for x, y in ((7, 5), (8, 4), (6, 6), (10, 8)):
        icon.px(x, y, c["shine"])
    # Facet lines from the table to the girdle.
    for x0, y0, x1, y1 in ((11, 6, 11, 3), (11, 15, 11, 19), (8, 10, 5, 10), (15, 10, 18, 10)):
        icon.line([(x0, y0), (x1, y1)], c["dark"])
    icon.outline(c["outline"])
    return icon


def rose(stone):
    c = STONES[stone]
    icon = Icon()
    cx, cy, r = 11.5, 12, 10
    ring = [(cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a))) for a in range(-90, 270, 60)]
    inner = [(cx + 5 * math.cos(math.radians(a)), cy + 5 * math.sin(math.radians(a))) for a in range(-60, 300, 60)]
    icon.poly(ring, c["mid"])
    # Outer facets: triangles between the ring and the inner star, light on the upper left, dark on the lower right.
    for i in range(6):
        a, b = ring[i], ring[(i + 1) % 6]
        tip = inner[i]
        angle = -60 + 60 * i
        colour = c["light"] if angle in (-120, -60, 180, 240) else c["dark"] if angle in (60, 0) else c["mid"]
        icon.poly([a, b, tip], colour)
    # Inner facets meet at the top of the dome.
    for i in range(6):
        a, b = inner[i], inner[(i + 1) % 6]
        colour = c["light"] if i in (3, 4) else c["mid"] if i in (2, 5) else c["dark"]
        icon.poly([a, b, (cx, cy)], colour)
    for x, y in ((8, 7), (9, 6), (12, 11)):
        icon.px(x, y, c["shine"])
    icon.outline(c["outline"])
    return icon


def diamond():
    c = STONES["diamond"]
    icon = Icon()
    crown_top = [(7, 4), (16, 4), (21, 9), (2, 9)]
    pavilion = [(2, 9), (21, 9), (11.5, 21)]
    icon.poly(crown_top, c["mid"])
    icon.poly(pavilion, c["mid"])
    # Crown facets.
    icon.poly([(7, 4), (11.5, 4), (9, 9)], c["light"])
    icon.poly([(11.5, 4), (16, 4), (14, 9)], c["mid"])
    icon.poly([(2, 9), (7, 4), (5, 9)], c["light"])
    icon.poly([(16, 4), (21, 9), (18, 9)], c["dark"])
    # Pavilion facets meeting at the culet.
    icon.poly([(2, 9), (9, 9), (11.5, 21)], c["light"])
    icon.poly([(14, 9), (21, 9), (11.5, 21)], c["dark"])
    icon.line([(2, 9), (21, 9)], c["dark"])
    for x, y in ((6, 6), (7, 5), (5, 11), (6, 12)):
        icon.px(x, y, c["shine"])
    icon.outline(c["outline"])
    return icon


def crown(sovereign):
    g = GOLD
    icon = Icon()
    top = 6 if sovereign else 4
    if sovereign:
        # The velvet cap inside the points, and a cross on an orb at the top.
        icon.draw.ellipse((5, 4, 18, 14), fill=VELVET["mid"])
        icon.draw.ellipse((11, 4, 18, 14), fill=VELVET["dark"])
        icon.draw.ellipse((10, 2, 13, 5), fill=g["mid"])
        icon.line([(11, 0), (11, 2)], g["light"])
        icon.line([(10, 1), (12, 1)], g["light"])
    # Five points rising from the band.
    points = [(2, 15), (2, top + 4), (6, 11), (7, top + 2), (11.5, 10), (16, top + 2), (17, 11), (21, top + 4),
              (21, 15)]
    icon.poly(points, g["mid"])
    for x, y in ((2, top + 4), (7, top + 2), (16, top + 2), (21, top + 4)):
        icon.draw.ellipse((x - 1, y - 2, x + 1, y), fill=g["light"])  # pearls on the tips
    # The band, lit along its top.
    icon.poly([(2, 15), (21, 15), (21, 20), (2, 20)], g["mid"])
    icon.line([(2, 15), (21, 15)], g["light"])
    icon.line([(2, 20), (21, 20)], g["dark"])
    icon.line([(21, 15), (21, 20)], g["dark"])
    # Jewels on the band: emerald, sapphire, the diamond in the middle, sapphire, ruby.
    jewels = [(4, "emerald"), (8, "sapphire"), (11, "diamond"), (15, "sapphire"), (19, "ruby")]
    for x, stone in jewels:
        s = STONES[stone]
        w = 2 if stone == "diamond" else 1
        icon.draw.rectangle((x, 16, x + w, 18), fill=s["mid"])
        icon.px(x, 16, s["shine"] if stone == "diamond" else s["light"])
    icon.px(11, 11, STONES["ruby"]["mid"])
    icon.px(12, 11, STONES["ruby"]["mid"])
    for x, y in ((3, 12), (4, 11)):
        icon.px(x, y, g["shine"])
    icon.outline(g["outline"])
    return icon


def main():
    icons = {
        "gold_shard": gold_piece([(6, 19), (10, 3), (17, 9), (14, 20)], [(10, 5), (9, 7)]),
        "oval_emerald": oval("emerald"),
        "gold_fragment": gold_piece([(3, 10), (9, 6), (12, 9), (19, 7), (20, 14), (12, 17), (4, 16)],
                                    [(9, 8), (10, 9), (18, 9)]),
        "oval_sapphire": oval("sapphire"),
        "oval_ruby": oval("ruby"),
        "gold_sliver": gold_piece([(4, 19), (16, 3), (19, 4), (7, 21)], [(15, 5), (14, 6)]),
        "rose_emerald": rose("emerald"),
        "rose_sapphire": rose("sapphire"),
        "rose_ruby": rose("ruby"),
        "gold_flake": gold_piece([(6, 11), (11, 8), (17, 10), (16, 15), (9, 16)], [(10, 10), (11, 10)]),
        "crown_diamond": diamond(),
        "crown": crown(False),
        "sovereign_crown": crown(True),
    }
    for stem, icon in icons.items():
        icon.save(stem)
    print(f"wrote {len(icons)} icons to {ICON_DIR}")


if __name__ == "__main__":
    main()
