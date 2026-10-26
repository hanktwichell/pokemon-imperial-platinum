#!/usr/bin/env python3
"""Put the Gen 5-9 battle sprites (#494-1025) into the game, replacing the Unown placeholders.

Reads a dex-folder pack (NNNN-Name/{front,back,shiny_front,shiny_back}.png) and, for each species, writes
decomp/res/pokemon/<species>/{male,female}_{front,back}.png, normal.pal, shiny.pal and the y offsets in
sprite_data.json. Species #1-493 (Renegade Platinum's sprites) are never touched.

DS rules: each frame is 80x80; front and back share one palette of 15 colours plus transparency (index 0); the
shiny sprite is the same pixels with a second palette, so each shiny colour is the one the shiny sprite has
where the normal sprite uses that index. Art bigger than 80x80 is scaled down (nearest neighbour) and reported.
The PNG holds two 80x80 frames side by side; both get the same picture.

Writes docs/BattleSpriteImport.md: what was scaled, how many colours each species had, and shinies that
didn't line up.

Usage: python3 -I tools/sprites/convert_battle_sprites.py assets/sprites/packs/gen5_9_part1
"""
import csv
import json
import os
import sys
from collections import Counter, defaultdict

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
POKEMON = os.path.join(ROOT, "decomp", "res", "pokemon")
FIRST_NEW = 494


def species_dirs():
    names = [l.strip() for l in open(os.path.join(ROOT, "decomp", "generated", "species.txt")) if l.strip()]
    return {i: n[len("SPECIES_"):].lower() for i, n in enumerate(names) if FIRST_NEW <= i <= 1025}


def floats(dex, species_rows):
    """Flying types and Levitate users hover; everything else stands on the ground."""
    row = species_rows.get(dex, {})
    return "Flying" in row.get("types", "") or "Levitate" in row.get("abilities", "")


def window(im):
    """The 80x80 box to cut from a sprite: centred on the art, keeping the source's space under the feet."""
    w, h = im.size
    bb = im.getchannel("A").getbbox()
    if not bb:
        return (0, 0, 80, 80), 1.0
    bw, bh = bb[2] - bb[0], bb[3] - bb[1]
    scale = min(1.0, 80 / bw, 80 / bh)
    if scale < 1.0:
        return bb, scale
    # Horizontally: centre the art. Vertically: keep the source's bottom edge (the space under the feet),
    # moving up only when that would cut off the top of the art.
    left = (bb[0] + bb[2]) // 2 - 40
    top = min(h - 80, bb[1])
    return (left, top, left + 80, top + 80), 1.0


def cut(im, box, scale):
    """Cut the 80x80 frame; art too big for 80x80 is scaled down and placed bottom-centre."""
    if scale == 1.0:
        out = Image.new("RGBA", (80, 80), (0, 0, 0, 0))
        out.paste(im.crop(box), (0, 0))
        return out
    art = im.crop(box)
    art = art.resize((max(1, round(art.width * scale)), max(1, round(art.height * scale))), Image.NEAREST)
    out = Image.new("RGBA", (80, 80), (0, 0, 0, 0))
    out.paste(art, ((80 - art.width) // 2, 80 - art.height))
    return out


def opaque(im):
    return [p[:3] for p in im.get_flattened_data() if p[3] >= 128]


def build_palette(images):
    """15 colours for the opaque pixels of every image (front and back share the palette)."""
    px = []
    for im in images:
        px += opaque(im)
    colours = Counter(px)
    if len(colours) <= 15:
        pal = [c for c, _ in colours.most_common()]
    else:
        strip = Image.new("RGB", (len(px), 1))
        strip.putdata(px)
        q = strip.quantize(15, method=Image.Quantize.MEDIANCUT)
        flat = q.getpalette()[:45]
        pal = [tuple(flat[i:i + 3]) for i in range(0, 45, 3)]
    pal = [(r & 0xF8, g & 0xF8, b & 0xF8) for r, g, b in pal]  # the DS stores 5 bits per channel
    while len(pal) < 15:
        pal.append((0, 0, 0))
    return pal, len(colours)


def nearest(c, pal, cache):
    if c not in cache:
        cache[c] = 1 + min(range(15), key=lambda i: sum((a - b) ** 2 for a, b in zip(c, pal[i])))
    return cache[c]


def index_image(im, pal):
    cache = {}
    out = Image.new("P", (80, 80), 0)
    out.putdata([0 if p[3] < 128 else nearest(p[:3], pal, cache) for p in im.get_flattened_data()])
    return out


def shiny_palette(indexed, shinies, pal):
    """Each index's shiny colour: what the shiny sprite most often has where the normal sprite uses it."""
    votes = defaultdict(Counter)
    for idx_im, sh in zip(indexed, shinies):
        for i, p in zip(idx_im.get_flattened_data(), sh.get_flattened_data()):
            if i and p[3] >= 128:
                votes[i][(p[0] & 0xF8, p[1] & 0xF8, p[2] & 0xF8)] += 1
    return [votes[i].most_common(1)[0][0] if votes[i] else pal[i - 1] for i in range(1, 16)]


def write_pal(path, transparent, pal):
    with open(path, "w", newline="\r\n") as f:
        f.write("JASC-PAL\n0100\n16\n")
        for r, g, b in [transparent] + pal:
            f.write(f"{r} {g} {b}\n")


def two_frames(indexed, pal):
    out = Image.new("P", (160, 80), 0)
    out.paste(indexed, (0, 0))
    out.paste(indexed, (80, 0))
    out.putpalette([0, 0, 0] + [v for c in pal for v in c])
    return out


def bottom_blank(indexed):
    bb = indexed.getbbox()
    return 80 - bb[3] if bb else 0


def main():
    pack = sys.argv[1]
    dirs = species_dirs()
    rows = {int(r["dex"]): r for r in csv.DictReader(open(os.path.join(ROOT, "data", "species.csv"), encoding="utf-8"))}
    folders = {int(d[:4]): os.path.join(pack, d) for d in os.listdir(pack) if d[:4].isdigit()}
    report = []
    for dex in sorted(folders):
        if dex < FIRST_NEW or dex not in dirs:
            continue  # never touch Renegade Platinum's sprites
        src = folders[dex]
        dst = os.path.join(POKEMON, dirs[dex])
        ims = {k: Image.open(os.path.join(src, f"{k}.png")).convert("RGBA")
               for k in ("front", "back", "shiny_front", "shiny_back") if os.path.exists(os.path.join(src, f"{k}.png"))}
        if "front" not in ims or "back" not in ims:
            report.append((dex, rows[dex]["name"], "skipped: no front or back", "", "", ""))
            continue
        frames, notes = {}, []
        for face in ("front", "back"):
            box, scale = window(ims[face])
            frames[face] = cut(ims[face], box, scale)
            sh = ims.get(f"shiny_{face}")
            if sh is not None and sh.size == ims[face].size:
                frames[f"shiny_{face}"] = cut(sh, box, scale)
            if scale < 1.0:
                notes.append(f"{face} scaled to {round(scale * 100)}%")
        pal, ncol = build_palette([frames["front"], frames["back"]])
        indexed = {face: index_image(frames[face], pal) for face in ("front", "back")}
        shinies = [(indexed[f], frames[f"shiny_{f}"]) for f in ("front", "back") if f"shiny_{f}" in frames]
        spal = shiny_palette([a for a, _ in shinies], [b for _, b in shinies], pal) if shinies else list(pal)
        if not shinies:
            notes.append("no shiny")
        # Shiny sprites whose shape doesn't match the normal one (a different pose or crop).
        for face in ("front", "back"):
            sh = frames.get(f"shiny_{face}")
            if sh is None:
                continue
            a = [p[3] >= 128 for p in frames[face].get_flattened_data()]
            b = [p[3] >= 128 for p in sh.get_flattened_data()]
            off = sum(x != y for x, y in zip(a, b)) / max(1, sum(a))
            if off > 0.05:
                notes.append(f"shiny {face} doesn't line up ({round(off * 100)}% of pixels)")
        for face in ("front", "back"):
            img = two_frames(indexed[face], pal)
            for gender in ("male", "female"):
                img.save(os.path.join(dst, f"{gender}_{face}.png"))
        write_pal(os.path.join(dst, "normal.pal"), (0, 0, 0), pal)
        write_pal(os.path.join(dst, "shiny.pal"), (0, 0, 0), spal)
        sd_path = os.path.join(dst, "sprite_data.json")
        sd = json.load(open(sd_path, encoding="utf-8"))
        for face in ("front", "back"):
            off = bottom_blank(indexed[face])
            sd[face]["y_offset"] = {"female": off, "male": off}
        sd["front"]["addl_y_offset"] = 16 if floats(dex, rows) else 0
        width = indexed["front"].getbbox()
        width = (width[2] - width[0]) if width else 0
        sd["shadow"]["size"] = "SHADOW_SIZE_SMALL" if width < 40 else "SHADOW_SIZE_MEDIUM" if width < 64 else "SHADOW_SIZE_LARGE"
        with open(sd_path, "w", encoding="utf-8") as f:
            json.dump(sd, f, indent=4, ensure_ascii=False)
            f.write("\n")
        report.append((dex, rows[dex]["name"], "converted", ncol, "yes" if shinies else "no", "; ".join(notes)))

    with open(os.path.join(ROOT, "docs", "BattleSpriteImport.md"), "w", encoding="utf-8") as f:
        f.write("# Battle sprite import (#494–1025)\n\n"
                "Written by `tools/sprites/convert_battle_sprites.py` from `" + os.path.relpath(pack, ROOT) + "`. "
                "Each species' front and back now share one 15-colour palette; **Colours** is how many the source "
                "had (more than 15 were reduced). Notes list art scaled down to fit 80×80 and shinies that didn't "
                "line up. These are the sprites to look at first in game.\n\n"
                "| Dex | Pokémon | Result | Colours | Shiny | Notes |\n|---|---|---|---|---|---|\n")
        for r in report:
            f.write("| " + " | ".join(str(x) for x in r) + " |\n")
    done = sum(1 for r in report if r[2] == "converted")
    print(f"converted {done}, scaled {sum(1 for r in report if 'scaled' in r[5])}, "
          f"reduced colours {sum(1 for r in report if isinstance(r[3], int) and r[3] > 15)}")


if __name__ == "__main__":
    main()
