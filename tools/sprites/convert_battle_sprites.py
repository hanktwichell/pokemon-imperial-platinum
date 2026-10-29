#!/usr/bin/env python3
"""Put the Gen 5-9 battle sprites (#494-1025) into the game, replacing the Unown placeholders.

Reads a dex-folder pack (NNNN-Name/{front,back,shiny_front,shiny_back}.png) and, for each species, writes
decomp/res/pokemon/<species>/{male,female}_{front,back}.png, normal.pal, shiny.pal and the y offsets in
sprite_data.json. Species #1-493 (Renegade Platinum's sprites) are never touched.

DS rules: a back is 80x80 and a front 96x96 (PokeAPI's fronts at full size; a front from the pack is cut to 80x80);
front and back each have a palette of 15 colours plus transparency (index 0); the shiny sprite is the same pixels
with a second palette, so each shiny colour is the one the shiny sprite has where the normal sprite uses that index.
Back art bigger than 80x80 is scaled down (nearest neighbour) and reported. The PNG holds two frames side by side;
both get the same picture. A 96x96 front's y offset counts the clear rows under the art in the 80x80 box centred in
it (negative when the art reaches below that box). A front that would reach above the top of the battle screen is
moved down and, if that isn't enough, shrunk (fit_front96.py).

Writes docs/BattleSpriteImport.md: what was scaled, how many colours each species had, and shinies that
didn't line up.

With --fronts DIR, front.png and shiny_front.png come from DIR (same NNNN-Name layout) instead.

Usage: python3 -I tools/sprites/convert_battle_sprites.py assets/sprites/packs/gen5_9_part1 \
           [--fronts assets/sprites/packs/pokeapi_fronts]
"""
import csv
import json
import os
import sys
from collections import Counter, defaultdict

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fit_front96 import fit  # noqa: E402

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


def paired_palettes(pairs):
    """One 15-colour palette and its shiny for a set of (normal, shiny or None) frames, chosen from the colour pairs.

    Each opaque pixel is a pair (its normal colour, its shiny colour), so two places that share a normal colour but
    differ in the shiny (Alolan Meowth's eyes and body) get colour slots of their own. With more than 15 pairs, they
    are grouped by k-means. Returns (palette, shiny palette, indexed frames, number of normal colours).
    """
    def five(p):
        return (p[0] & 0xF8, p[1] & 0xF8, p[2] & 0xF8)

    keyed, counts = [], Counter()
    for normal, shiny in pairs:
        sh = shiny.get_flattened_data() if shiny is not None else None
        keys = []
        for j, p in enumerate(normal.get_flattened_data()):
            if p[3] < 128:
                keys.append(None)
                continue
            n = five(p)
            s = five(sh[j]) if sh is not None and sh[j][3] >= 128 else n
            keys.append(n + s)
            counts[n + s] += 1
        keyed.append(keys)
    ncol = len({k[:3] for k in counts})

    def dist(a, b):
        return 2 * sum((x - y) ** 2 for x, y in zip(a[:3], b[:3])) + sum((x - y) ** 2 for x, y in zip(a[3:], b[3:]))

    centers = [k for k, _ in counts.most_common(15)]
    if len(counts) > 15:
        for _ in range(12):
            groups = defaultdict(list)
            for k, c in counts.items():
                groups[min(range(len(centers)), key=lambda i: dist(k, centers[i]))].append((k, c))
            for i, members in groups.items():
                w = sum(c for _, c in members)
                centers[i] = tuple(round(sum(k[d] * c for k, c in members) / w) for d in range(6))
        centers = [tuple(v & 0xF8 for v in c) for c in centers]
    slot = {k: 1 + min(range(len(centers)), key=lambda i: dist(k, centers[i])) for k in counts}
    indexed = []
    for (normal, _), keys in zip(pairs, keyed):
        out = Image.new("P", normal.size, 0)
        out.putdata([0 if k is None else slot[k] for k in keys])
        indexed.append(out)
    pal = [c[:3] for c in centers] + [(0, 0, 0)] * (15 - len(centers))
    spal = [c[3:] for c in centers] + [(0, 0, 0)] * (15 - len(centers))
    return pal, spal, indexed, ncol


def write_pal(path, transparent, pal):
    with open(path, "w", newline="\r\n") as f:
        f.write("JASC-PAL\n0100\n16\n")
        for r, g, b in [transparent] + pal:
            f.write(f"{r} {g} {b}\n")


def two_frames(indexed, pal):
    """The sprite's two frames (the same picture twice) side by side: 160x80, or 192x96 for a 96x96 front."""
    out = Image.new("P", (indexed.width * 2, indexed.height), 0)
    out.paste(indexed, (0, 0))
    out.paste(indexed, (indexed.width, 0))
    # The game unscrambles a battle sprite with a key read from its first four pixels (PokemonSprite_DecryptPt), so
    # they must stay transparent or the sprite comes out as noise (Samurott's horn tip, Talonflame's wing tip).
    for x in range(4):
        out.putpixel((x, 0), 0)
    out.putpalette([0, 0, 0] + [v for c in pal for v in c])
    return out


def bottom_blank(indexed):
    """The clear rows under the art in the 80x80 box (centred in a 96x96 front; negative below that box)."""
    bb = indexed.getbbox()
    return (80 + (indexed.height - 80) // 2) - bb[3] if bb else 0


def main():
    args = sys.argv[1:]
    fronts = None
    if "--fronts" in args:
        i = args.index("--fronts")
        fronts = args[i + 1]
        del args[i:i + 2]
    pack = args[0]
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
        if fronts:
            fsrc = os.path.join(fronts, os.path.basename(src))
            for k in ("front", "shiny_front", "female_front", "female_shiny_front"):
                if os.path.exists(os.path.join(fsrc, f"{k}.png")):
                    ims[k] = Image.open(os.path.join(fsrc, f"{k}.png")).convert("RGBA")
        if "front" not in ims or "back" not in ims:
            report.append((dex, rows[dex]["name"], "skipped: no front or back", "", "", ""))
            continue
        frames, notes = {}, []
        for face in ("front", "back"):
            if face == "front" and ims[face].size == (96, 96):
                frames[face] = ims[face]
                sh = ims.get("shiny_front")
                if sh is not None and sh.size == ims[face].size:
                    frames["shiny_front"] = sh
                continue
            box, scale = window(ims[face])
            frames[face] = cut(ims[face], box, scale)
            sh = ims.get(f"shiny_{face}")
            if sh is not None and sh.size == ims[face].size:
                frames[f"shiny_{face}"] = cut(sh, box, scale)
            if scale < 1.0:
                notes.append(f"{face} scaled to {round(scale * 100)}%")
        # A female front of its own (a visible gender difference) shares the front palette with the male one.
        if "female_front" in ims:
            if ims["female_front"].size == frames["front"].size:
                frames["female_front"] = ims["female_front"]
                sh = ims.get("female_shiny_front")
                if sh is not None and sh.size == ims["female_front"].size:
                    frames["female_shiny_front"] = sh
            else:
                box, scale = window(ims["female_front"])
                frames["female_front"] = cut(ims["female_front"], box, scale)
                sh = ims.get("female_shiny_front")
                if sh is not None and sh.size == ims["female_front"].size:
                    frames["female_shiny_front"] = cut(sh, box, scale)
        # Front and back each get their own 15 colours (back_*.pal; make_pl_pokegra.py packs them separately).
        pals, spals, indexed, ncol = {}, {}, {}, {}
        for face in ("front", "back"):
            group = [face] + (["female_front"] if face == "front" and "female_front" in frames else [])
            shiny_of = {face: f"shiny_{face}", "female_front": "female_shiny_front"}
            pals[face], spals[face], images, ncol[face] = paired_palettes(
                [(frames[g], frames.get(shiny_of[g])) for g in group])
            indexed.update(zip(group, images))
            if f"shiny_{face}" not in frames:
                notes.append(f"no shiny {face}")
        # A 96x96 front that would reach above the top of the battle screen moves down and, if need be, shrinks
        # (fit_front96.py); its y offset gets the move.
        elevation = 16 if floats(dex, rows) else 0
        down = {}
        for g in ("front", "female_front"):
            if g in indexed and indexed[g].height == 96:
                before = indexed[g].getbbox()
                indexed[g], down[g] = fit(indexed[g], bottom_blank(indexed[g]), elevation)
                after = indexed[g].getbbox()
                if down[g]:
                    height, was = after[3] - after[1], before[3] - before[1]
                    shrunk = f", shrunk to {round(100 * height / was)}%" if height < was else ""
                    notes.append(f"{g.replace('_', ' ')} moved down {down[g]}{shrunk} to fit the battle screen")
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
            img = two_frames(indexed[face], pals[face])
            img.save(os.path.join(dst, f"male_{face}.png"))
            if face == "front" and "female_front" in indexed:
                two_frames(indexed["female_front"], pals[face]).save(os.path.join(dst, "female_front.png"))
            else:
                img.save(os.path.join(dst, f"female_{face}.png"))
        write_pal(os.path.join(dst, "normal.pal"), (0, 0, 0), pals["front"])
        write_pal(os.path.join(dst, "shiny.pal"), (0, 0, 0), spals["front"])
        write_pal(os.path.join(dst, "back_normal.pal"), (0, 0, 0), pals["back"])
        write_pal(os.path.join(dst, "back_shiny.pal"), (0, 0, 0), spals["back"])
        sd_path = os.path.join(dst, "sprite_data.json")
        sd = json.load(open(sd_path, encoding="utf-8"))
        for face in ("front", "back"):
            off = bottom_blank(indexed[face]) + down.get(face, 0)
            female = off
            if face == "front" and "female_front" in indexed:
                female = bottom_blank(indexed["female_front"]) + down.get("female_front", 0)
            sd[face]["y_offset"] = {"female": female, "male": off}
        sd["front"]["addl_y_offset"] = elevation
        width = indexed["front"].getbbox()
        width = (width[2] - width[0]) if width else 0
        sd["shadow"]["size"] = "SHADOW_SIZE_SMALL" if width < 40 else "SHADOW_SIZE_MEDIUM" if width < 64 else "SHADOW_SIZE_LARGE"
        with open(sd_path, "w", encoding="utf-8") as f:
            json.dump(sd, f, indent=4, ensure_ascii=False)
            f.write("\n")
        has_shiny = "shiny_front" in frames and "shiny_back" in frames
        report.append((dex, rows[dex]["name"], "converted", f"{ncol['front']} / {ncol['back']}",
                       "yes" if has_shiny else "partly" if ("shiny_front" in frames or "shiny_back" in frames) else "no",
                       "; ".join(notes)))

    with open(os.path.join(ROOT, "docs", "BattleSpriteImport.md"), "w", encoding="utf-8") as f:
        f.write("# Battle sprite import (#494–1025)\n\n"
                "Written by `tools/sprites/convert_battle_sprites.py` from `" + os.path.relpath(pack, ROOT) + "`" +
                ((", with fronts from `" + os.path.relpath(fronts, ROOT) + "`") if fronts else "") + ". "
                "Each species' front and back have palettes of their own, 15 colours each (`normal.pal`/`shiny.pal` "
                "for the front, `back_normal.pal`/`back_shiny.pal` for the back); **Colours** is how many the "
                "source front / back had (more than 15 were reduced). Notes list art scaled down to fit 80×80 and "
                "shinies that didn't line up. These are the sprites to look at first in game.\n\n"
                "| Dex | Pokémon | Result | Colours | Shiny | Notes |\n|---|---|---|---|---|---|\n")
        for r in report:
            f.write("| " + " | ".join(str(x) for x in r) + " |\n")
    done = sum(1 for r in report if r[2] == "converted")
    print(f"converted {done}, scaled {sum(1 for r in report if 'scaled' in r[5])}, "
          f"reduced colours {sum(1 for r in report if r[3] and max(int(n) for n in r[3].split(' / ')) > 15)}")


if __name__ == "__main__":
    main()
