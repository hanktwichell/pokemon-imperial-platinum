#!/usr/bin/env python3
"""Give Mega and Primal forms back sprites of their own, from the "DPPt Style Gen VI and Beyond" pack.

The pack (assets/sprites/packs/dppt_gen6_and_beyond, credits in its Credits.txt) has backs and shiny backs drawn in
the Diamond/Pearl/Platinum style; tools/sprites/import_sprite_pack.py maps each file to its form in
data/sprite_index.csv. For each Mega or Primal form of sSovereignForms with a back there, this:
- halves the art back to 80x80 (the pack draws DS sprites at twice size; each 2x2 block becomes its most common
  colour, so the few not drawn as exact 2x2 blocks keep their main colour);
- gives it 15 colours of its own, with the shiny back's paired pixel by pixel (convert_battle_sprites.py's
  paired_palettes; art with more colours is reduced);
- keeps the art where the pack draws it in the frame; its own back y offset (the clear rows under the art, the way
  sprite_data.json's are) goes in sSovereignFormBackYOffset, which LoadPokemonSpriteYOffset uses for the form.

Writes:
  decomp/res/pokemon/sovereign_form_backs/<k>-<stem>-<dir>/{back.png, back.png.key, normal.pal, shiny.pal}
  decomp/res/pokemon/sovereign_form_backs/order.txt      one folder per line; make_pl_pokegra.py packs them in order
  decomp/res/pokemon/sovereign_form_backs/meson.build    the files, so pl_pokegra.narc rebuilds when they change
  decomp/include/data/sovereign_form_backs.h             sSovereignFormBack[i]: back number + 1, or 0 for none;
                                                          sSovereignFormBackYOffset[i]: its y offset

Usage: python3 -I tools/sprites/convert_form_backs.py
"""
import csv
import os
import shutil
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from convert_battle_sprites import paired_palettes, two_frames, write_pal  # noqa: E402
from convert_form_sprites import KEY, forms  # noqa: E402

from PIL import Image  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
PACK = os.path.join(ROOT, "assets", "sprites", "packs", "dppt_gen6_and_beyond")
OUT = os.path.join(DECOMP, "res", "pokemon", "sovereign_form_backs")
HEADER = os.path.join(DECOMP, "include", "data", "sovereign_form_backs.h")
KINDS = ("SOVEREIGN_FORM_MEGA", "SOVEREIGN_FORM_PRIMAL", "SOVEREIGN_FORM_MEGA_BY_MOVE")


def pack_backs():
    """{(species stem, form dir): (back file, shiny back file)} for the pack's Mega and Primal backs."""
    rows = list(csv.DictReader(open(os.path.join(ROOT, "data", "sprite_index.csv"), encoding="utf-8")))
    files = {}
    for r in rows:
        if r["category"] != "mega" or r["kind"] not in ("back", "back_shiny"):
            continue
        species = r["species"].lower()
        rest = r["form"].split(" ", 1)[0].lower()  # "Mega" or "Primal"
        suffix = r["form"].split(r["species"], 1)[1].strip().lower()  # "x", "y" or ""
        key = (species, rest + ("_" + suffix if suffix else ""))
        files.setdefault(key, {})[r["kind"]] = os.path.join(PACK, r["file"])
    return {k: (v["back"], v.get("back_shiny")) for k, v in files.items() if "back" in v}


def halve(im):
    """A 160x160 drawing of a DS sprite back to 80x80: each 2x2 block's most common colour (clear if mostly clear)."""
    out = Image.new("RGBA", (im.width // 2, im.height // 2), (0, 0, 0, 0))
    px = im.load()
    for y in range(out.height):
        for x in range(out.width):
            block = [px[2 * x + dx, 2 * y + dy] for dy in (0, 1) for dx in (0, 1)]
            block = [p if p[3] >= 128 else (0, 0, 0, 0) for p in block]
            out.putpixel((x, y), Counter(block).most_common(1)[0][0])
    return out


def main():
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    os.makedirs(OUT)
    backs = pack_backs()
    table, offsets, order, report, used = {}, {}, [], [], set()
    for i, stem, d, kind, name in forms():
        if kind not in KINDS or (stem, d) not in backs:
            continue
        used.add((stem, d))
        back_png, shiny_png = backs[(stem, d)]
        back = halve(Image.open(back_png).convert("RGBA"))
        if back.size != (80, 80):
            report.append(f"{name}: drawn bigger than a DS sprite ({back.width}x{back.height} once halved); keeps "
                          f"its base form's back")
            continue
        shiny = halve(Image.open(shiny_png).convert("RGBA")) if shiny_png else None
        if shiny is not None and shiny.getchannel("A").getbbox() != back.getchannel("A").getbbox():
            report.append(f"{name}: the shiny back's shape differs from the normal one's (the shiny palette pairs "
                          f"what overlaps)")
        pal, spal, (indexed,), ncol = paired_palettes([(back, shiny)])
        folder = f"{len(order):03}-{stem}-{d}"
        out = os.path.join(OUT, folder)
        os.makedirs(out)
        two_frames(indexed, pal).save(os.path.join(out, "back.png"))
        shutil.copyfile(KEY, os.path.join(out, "back.png.key"))
        write_pal(os.path.join(out, "normal.pal"), (0, 0, 0), pal)
        write_pal(os.path.join(out, "shiny.pal"), (0, 0, 0), spal)
        order.append(folder)
        table[i] = len(order)
        offsets[i] = 80 - indexed.getbbox()[3]
        if ncol > 15:
            report.append(f"{name}: {ncol} colours, reduced to 15")
    for key in sorted(set(backs) - used):
        report.append(f"{key[0]} {key[1]}: in the pack, but no such form in the game")

    with open(os.path.join(OUT, "order.txt"), "w") as f:
        f.write("\n".join(order) + "\n")
    with open(os.path.join(OUT, "meson.build"), "w") as f:
        f.write("# Generated by tools/sprites/convert_form_backs.py. Do not edit.\n")
        for folder in order:
            for name in ("back.png", "normal.pal", "shiny.pal"):
                f.write(f"pokegra_files += files('{folder}/{name}')\n")
    with open(HEADER, "w") as f:
        f.write("// Generated by tools/sprites/convert_form_backs.py. Do not edit.\n"
                "#ifndef POKEPLATINUM_DATA_SOVEREIGN_FORM_BACKS_H\n#define POKEPLATINUM_DATA_SOVEREIGN_FORM_BACKS_H\n\n"
                '#include "constants/sovereign_forms.h"\n\n'
                "// For each sSovereignForms entry: its back sprite's number in pl_pokegra's form backs, plus 1; 0 when\n"
                "// the form uses its base species' back.\n"
                "static const u16 sSovereignFormBack[SOVEREIGN_FORM_COUNT] = {\n")
        for i in sorted(table):
            f.write(f"    [{i}] = {table[i]},\n")
        f.write("};\n\n// Its back's y offset (the clear rows under the art), for LoadPokemonSpriteYOffset.\n"
                "static const s8 sSovereignFormBackYOffset[SOVEREIGN_FORM_COUNT] = {\n")
        for i in sorted(offsets):
            f.write(f"    [{i}] = {offsets[i]},\n")
        f.write("};\n\n#endif\n")
    print(f"{len(order)} form backs")
    print("\n".join(report))


if __name__ == "__main__":
    main()
