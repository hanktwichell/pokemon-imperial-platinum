#!/usr/bin/env python3
"""Give Sovereign's forms front sprites of their own (PokeAPI's front and shiny front).

Reads assets/sprites/packs/pokeapi_fronts/forms/<stem>-<form dir>/{front,shiny_front}.png for every entry of
sSovereignForms that has one (Megas, Primals, regional, battle, item, Totem, cosmetic and female forms) (include/data/sovereign_forms.h, with the folder names from
tools/dataproc/src/sovereign_forms.inc, in the same order), converts each to DS format the way
convert_battle_sprites.py does (80x80, its own 15-colour palette, the shiny palette taken pixel by pixel), and writes:

  decomp/res/pokemon/sovereign_form_sprites/<k>-<stem>-<dir>/{front.png, front.png.key, normal.pal, shiny.pal}
  decomp/res/pokemon/sovereign_form_sprites/order.txt      one folder per line; make_pl_pokegra.py packs them in order
  decomp/res/pokemon/sovereign_form_sprites/meson.build    the pngs, so pl_pokegra.narc rebuilds when they change
  decomp/include/data/sovereign_form_sprites.h             sSovereignFormSprite[i]: sprite number + 1, or 0 for none

The back sprite stays the base species' (no back art for these forms yet).

Some of PokeAPI's shiny fronts are drawn apart from the normal front (Florges, Vivillon, the Furfrou trims...), so a
palette swap of the normal front can't show them. Where more than 10% of the pixels don't follow one normal-to-shiny
colour mapping, the shiny front is converted as a sprite of its own (both its palettes are the shiny colours), for
species (pokeapi_fronts/NNNN-Name) and for forms alike:

  sSpeciesShinyFront[]                 {species, female (0 male, 1 female, 2 either), sprite number + 1}
  sSovereignFormShinySprite[i], sSovereignFormFemaleShinySprite[i]

Usage: python3 -I tools/sprites/convert_form_sprites.py
"""
import os
import re
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from convert_battle_sprites import cut, paired_palettes, two_frames, window, write_pal  # noqa: E402
from collections import Counter  # noqa: E402

from PIL import Image  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
FRONTS = os.path.join(ROOT, "assets", "sprites", "packs", "pokeapi_fronts")
SRC = os.path.join(FRONTS, "forms")
OUT = os.path.join(DECOMP, "res", "pokemon", "sovereign_form_sprites")
KEY = os.path.join(DECOMP, "res", "pokemon", "venusaur", "male_front.png.key")  # any key file works (a scramble seed)


def forms():
    """[(index, stem, dir, kind, name)] in sSovereignForms order."""
    inc = open(os.path.join(DECOMP, "tools", "dataproc", "src", "sovereign_forms.inc"), encoding="utf-8").read()
    dirs = re.findall(r'\{ "([^"/]+)/forms/([^"]+)", NULL.*?// (.*)', inc)
    hdr = open(os.path.join(DECOMP, "include", "data", "sovereign_forms.h"), encoding="utf-8").read()
    kinds = re.findall(r"\{ SPECIES_\w+, \d+, (SOVEREIGN_FORM_\w+), \w+ \}", hdr)
    assert len(dirs) == len(kinds), (len(dirs), len(kinds))
    return [(i, stem, d, kinds[i], name) for i, ((stem, d, name), _) in enumerate(zip(dirs, kinds))]


def misaligned(front_png, shiny_png):
    """The share of the front's pixels that don't follow one normal-to-shiny colour mapping (0: a palette swap)."""
    a, b = Image.open(front_png).convert("RGBA"), Image.open(shiny_png).convert("RGBA")
    if a.size != b.size:
        return 1.0
    pairs, off, total = Counter(), 0, 0
    for p, q in zip(a.get_flattened_data(), b.get_flattened_data()):
        if (p[3] > 0) != (q[3] > 0):
            off += 1
        elif p[3]:
            pairs[(p[:3], q[:3])] += 1
            total += 1
    best = Counter()
    for (n, _), c in pairs.items():
        best[n] = max(best[n], c)
    return (off + total - sum(best.values())) / max(total, 1)


def main():
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    os.makedirs(OUT)
    table, female, shiny_of, female_shiny, species_shiny, order, report = {}, {}, {}, {}, [], [], []

    def convert(front_png, shiny_png, folder, name):
        """Convert one front (and its shiny) into sovereign_form_sprites/<number>-<folder>; its number + 1.

        With shiny_png None, the front is a shiny drawn on its own and both palettes are its colours."""
        im = Image.open(front_png).convert("RGBA")
        box, scale = window(im)
        front = cut(im, box, scale)
        shiny = None
        if shiny_png and os.path.exists(shiny_png):
            sh = Image.open(shiny_png).convert("RGBA")
            if sh.size == im.size:
                shiny = cut(sh, box, scale)
        pal, spal, (indexed,), ncol = paired_palettes([(front, shiny)])
        folder = f"{len(order):03}-{folder}"
        out = os.path.join(OUT, folder)
        os.makedirs(out)
        two_frames(indexed, pal).save(os.path.join(out, "front.png"))
        shutil.copyfile(KEY, os.path.join(out, "front.png.key"))
        write_pal(os.path.join(out, "normal.pal"), (0, 0, 0), pal)
        write_pal(os.path.join(out, "shiny.pal"), (0, 0, 0), spal)
        order.append(folder)
        notes = [f"{ncol} colours" if ncol > 15 else "", f"scaled to {round(scale * 100)}%" if scale < 1 else ""]
        if any(notes):
            report.append(f"{name}: " + ", ".join(n for n in notes if n))
        return len(order)

    def own_shiny(front_png, shiny_png, folder, name):
        """The shiny's own sprite number + 1 where it isn't a palette swap of the front, else 0."""
        if not (os.path.exists(front_png) and os.path.exists(shiny_png)) or misaligned(front_png, shiny_png) <= 0.1:
            return 0
        return convert(shiny_png, None, folder + "-shiny", name + " (shiny)")

    for i, stem, d, kind, name in forms():
        src = os.path.join(SRC, f"{stem}-{d}")
        if not os.path.exists(os.path.join(src, "front.png")):
            if kind.startswith("SOVEREIGN_FORM_MEGA"):
                report.append(f"{name}: no PokeAPI front, keeps the base sprite")
            continue
        table[i] = convert(os.path.join(src, "front.png"), os.path.join(src, "shiny_front.png"), f"{stem}-{d}", name)
        # A female front of its own (a visible gender difference in this form, e.g. Hisuian Sneasel).
        if os.path.exists(os.path.join(src, "female_front.png")):
            female[i] = convert(os.path.join(src, "female_front.png"), os.path.join(src, "female_shiny_front.png"),
                                f"{stem}-{d}-female", name + " (female)")
        sh = own_shiny(os.path.join(src, "front.png"), os.path.join(src, "shiny_front.png"), f"{stem}-{d}", name)
        if sh:
            shiny_of[i] = sh
        if os.path.exists(os.path.join(src, "female_front.png")):
            sh = own_shiny(os.path.join(src, "female_front.png"), os.path.join(src, "female_shiny_front.png"),
                           f"{stem}-{d}-female", name + " (female)")
            if sh:
                female_shiny[i] = sh
    for d in sorted(os.listdir(FRONTS)):
        m = re.match(r"(\d{4})-", d)
        if not m:
            continue
        for female_flag, prefix in ((0, ""), (1, "female_")):
            sh = own_shiny(os.path.join(FRONTS, d, f"{prefix}front.png"),
                           os.path.join(FRONTS, d, f"{prefix}shiny_front.png"), d + ("-female" if female_flag else ""), d)
            if sh:
                # 2: either gender (the species has no female front of its own, e.g. Florges, all female).
                both = not female_flag and not os.path.exists(os.path.join(FRONTS, d, "female_front.png"))
                species_shiny.append((int(m.group(1)), 2 if both else female_flag, sh))
    with open(os.path.join(OUT, "order.txt"), "w") as f:
        f.write("".join(o + "\n" for o in order))
    with open(os.path.join(OUT, "meson.build"), "w") as f:
        f.write("# Generated by tools/sprites/convert_form_sprites.py. Do not edit.\n")
        for o in order:
            f.write(f"pokegra_files += files('{o}/front.png')\n")
    n = len(forms())
    with open(os.path.join(DECOMP, "include", "data", "sovereign_form_sprites.h"), "w") as f:
        f.write("// Generated by tools/sprites/convert_form_sprites.py. Do not edit.\n"
                "#ifndef POKEPLATINUM_DATA_SOVEREIGN_FORM_SPRITES_H\n#define POKEPLATINUM_DATA_SOVEREIGN_FORM_SPRITES_H\n\n"
                "#include \"constants/sovereign_forms.h\"\n\n"
                "// For each sSovereignForms entry: its front sprite's number in pl_pokegra's form sprites, plus 1; 0 when\n"
                "// the form uses its base species' sprite.\n"
                "static const u16 sSovereignFormSprite[SOVEREIGN_FORM_COUNT] = {\n")
        for i in range(n):
            if i in table:
                f.write(f"    [{i}] = {table[i]},\n")
        f.write("};\n\n// The same for a female's front, where the form looks different as a female; 0 means the same as the male.\n"
                "static const u16 sSovereignFormFemaleSprite[SOVEREIGN_FORM_COUNT] = {\n")
        for i in range(n):
            if i in female:
                f.write(f"    [{i}] = {female[i]},\n")
        f.write("};\n\n// A form's shiny front where PokeAPI draws it apart from the normal front (not a palette swap); 0 for none.\n"
                "static const u16 sSovereignFormShinySprite[SOVEREIGN_FORM_COUNT] = {\n")
        for i in sorted(shiny_of):
            f.write(f"    [{i}] = {shiny_of[i]},\n")
        f.write("};\n\nstatic const u16 sSovereignFormFemaleShinySprite[SOVEREIGN_FORM_COUNT] = {\n")
        for i in sorted(female_shiny):
            f.write(f"    [{i}] = {female_shiny[i]},\n")
        if not female_shiny:
            f.write("    0,  // (none yet; the compiler wants an initializer)\n")
        f.write("};\n\n// The same for species (their base form): the shiny front's sprite number + 1, for males (female 0), females\n"
                "// (1) or either (2, a species without a female front of its own).\n"
                "static const struct {\n    u16 species;\n    u16 female;\n    u16 sprite;\n} sSpeciesShinyFront[] = {\n")
        for sp, fem, sh in species_shiny:
            f.write(f"    {{ {sp}, {fem}, {sh} }},\n")
        f.write("};\n\n#define SOVEREIGN_FORM_SPRITE_COUNT " + str(len(order)) + "\n\n#endif\n")
    print(f"{len(order)} form sprites")
    for r in report:
        print(" ", r)


if __name__ == "__main__":
    main()
