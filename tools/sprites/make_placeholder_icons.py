#!/usr/bin/env python3
"""Build placeholder box/party icons for #494-1025 from PokeAPI's sprite repository.

Source priority per species: Gen VII (USUM) icons -> Sword/Shield icons -> Scarlet/Violet icons
(https://github.com/PokeAPI/sprites, sprites/pokemon/versions/...).

Output matches the decomp's icon format (decomp/res/pokemon/<species>/icon.png):
32x64 indexed PNG = two 32x32 animation frames, using one of the three shared icon palettes in
decomp/res/pokemon/.shared/pl_poke_icon.pal (index 0 = transparent). For each species the palette
that reproduces the art with the least colour error is chosen; frame 2 is frame 1 nudged up a pixel
(the usual "bounce"). These are placeholders until proper DS-style icons are drawn.

Writes assets/sprites/icons_placeholder/NNNN-Name.png and data/icon_placeholders.csv.

Usage: python3 tools/sprites/make_placeholder_icons.py /path/to/PokeAPI/sprites
"""
import csv
import os
import sys

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SOURCES = [
    ("generation-vii/icons", "PokeAPI Gen VII (USUM) icon", True),
    ("generation-viii/sword-shield/icons", "PokeAPI Sword/Shield icon", True),
    ("generation-ix/scarlet-violet/icons", "PokeAPI Scarlet/Violet icon", False),
]
FRAME = 32
MAX_ART = 30  # leave a pixel of headroom for the bounce frame


def load_palettes():
    words = open(os.path.join(ROOT, "decomp/res/pokemon/.shared/pl_poke_icon.pal")).read().split()[3:]
    cols = [tuple(int(x) for x in words[i:i + 3]) for i in range(0, len(words), 3)]
    return [cols[i * 16:(i + 1) * 16] for i in range(3)]


def fit(img, pixel_art):
    img = img.convert("RGBA")
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
    w, h = img.size
    scale = min(1.0, MAX_ART / w, MAX_ART / h)
    if scale < 1.0:
        size = (max(1, round(w * scale)), max(1, round(h * scale)))
        img = img.resize(size, Image.BOX if pixel_art else Image.LANCZOS)
    frame = Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    # Bottom-centre, like the vanilla icons (feet near the bottom edge).
    frame.paste(img, ((FRAME - img.width) // 2, FRAME - 1 - img.height), img)
    return frame


def quantise(frame, palette):
    """Map to palette entries 1..15 (0 is transparent); return (indices, error)."""
    out, err = [], 0
    for r, g, b, a in frame.get_flattened_data():
        if a < 128:
            out.append(0)
            continue
        best, bd = 1, None
        for i in range(1, 16):
            pr, pg, pb = palette[i]
            # weighted RGB distance (rough perceptual weighting)
            d = 2 * (r - pr) ** 2 + 4 * (g - pg) ** 2 + 3 * (b - pb) ** 2
            if bd is None or d < bd:
                best, bd = i, d
        out.append(best)
        err += bd
    return out, err


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    base = os.path.join(sys.argv[1], "sprites/pokemon/versions")
    palettes = load_palettes()
    species = {int(r["dex"]): r["name"] for r in csv.DictReader(open(os.path.join(ROOT, "data/species.csv"), encoding="utf-8"))}
    outdir = os.path.join(ROOT, "assets/sprites/icons_placeholder")
    os.makedirs(outdir, exist_ok=True)
    rows = []
    for dex in range(494, 1026):
        for sub, label, pixel_art in SOURCES:
            src = os.path.join(base, sub, f"{dex}.png")
            if os.path.exists(src):
                break
        else:
            print("no icon for", dex)
            continue
        frame = fit(Image.open(src), pixel_art)
        best = min(range(3), key=lambda k: quantise(frame, palettes[k])[1])
        idx, _ = quantise(frame, palettes[best])
        f1 = Image.new("P", (FRAME, FRAME))
        f1.putdata(idx)
        sheet = Image.new("P", (FRAME, FRAME * 2), 0)
        sheet.paste(f1, (0, 0))
        sheet.paste(f1, (0, FRAME - 1))  # frame 2: one pixel higher
        flat = [c for col in palettes[best] for c in col]
        sheet.putpalette(flat + [0] * (768 - len(flat)))
        name = species[dex]
        fn = f"{dex:04d}-{name}.png"
        sheet.save(os.path.join(outdir, fn), transparency=0)
        rows.append({"dex": dex, "species": name, "file": f"assets/sprites/icons_placeholder/{fn}", "icon_palette": best,
                     "source": label, "source_url": f"https://github.com/PokeAPI/sprites/blob/master/sprites/pokemon/versions/{sub}/{dex}.png"})
    with open(os.path.join(ROOT, "data/icon_placeholders.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {len(rows)} placeholder icons")


if __name__ == "__main__":
    main()
