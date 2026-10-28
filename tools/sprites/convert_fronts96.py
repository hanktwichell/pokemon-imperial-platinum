#!/usr/bin/env python3
"""Give species #1-493 PokeAPI's 96x96 fronts (Black/White's), kept apart from Platinum's own fronts.

Reads assets/sprites/packs/pokeapi_fronts_bw/NNNN-Name/{front, shiny_front, female_front, female_shiny_front}.png
(tools/sprites/fetch_pokeapi_fronts.py) and writes, for each species:

  decomp/res/pokemon/sovereign_fronts96/NNNN-<species dir>/{male,female}_front.png (+ .png.key), normal.pal, shiny.pal

- each front at full size, 96x96 (two frames side by side, 192x96, the same picture twice), with its own 15 colours;
  the shiny palette is taken pixel by pixel from the shiny front (convert_battle_sprites.py's paired_palettes), and a
  female front of its own shares the palette;
- a gendered species gets female_front.png (PokeAPI's female front, or the male one where they look alike), a
  genderless one only male_front.png, the same files as its Platinum folder has;
- its y offset, the clear rows under the art, counted in the 80x80 box centred in the 96x96 sprite (88 minus the
  art's bottom row), as sprite_data.json's are for 80x80 sprites; art reaching below that box gets a negative one.

Platinum's fronts and palettes in res/pokemon/<species>/ stay as they are: the back keeps using Platinum's palette,
and the meson option platinum_fronts packs Platinum's fronts again (tools/scripts/make_pl_pokegra.py).

Species left on Platinum's fronts: Spinda (its spots are drawn at Platinum's coordinates). The species whose sprites
come from pl_otherpoke.narc (Unown, Castform, Deoxys, Burmy, Wormadam, Cherrim, Shellos, Gastrodon, Rotom, Giratina,
Shaymin, Arceus) get a 96x96 front for each form, from pokeapi_fronts_bw/forms/<SPECIES>-<form>/
(fetch_pokeapi_fronts.py's FORMS):

  decomp/res/pokemon/sovereign_fronts96/forms/<k>-<species>-<form>/{front.png (+ .key), normal.pal, shiny.pal}
  decomp/res/pokemon/sovereign_fronts96/forms/order.txt   one folder a line, the order make_pl_pokegra.py packs them in

Also writes:
  decomp/res/pokemon/sovereign_fronts96/meson.build   the files, so pl_pokegra.narc rebuilds when they change
  decomp/include/data/sovereign_fronts96.h            sFront96YOffset[species]: {male, female} y offsets, or
                                                      FRONT96_NONE for a species on Platinum's front;
                                                      sGen4FormFront96[k]: those forms' species, form and y offset

Usage: python3 -I tools/sprites/convert_fronts96.py
"""
import os
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from convert_battle_sprites import paired_palettes, two_frames, write_pal  # noqa: E402
from fetch_pokeapi_fronts import FORMS  # noqa: E402

from PIL import Image  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
POKEMON = os.path.join(DECOMP, "res", "pokemon")
PACK = os.path.join(ROOT, "assets", "sprites", "packs", "pokeapi_fronts_bw")
OUT = os.path.join(POKEMON, "sovereign_fronts96")
HEADER = os.path.join(DECOMP, "include", "data", "sovereign_fronts96.h")
LAST = 493
# Spinda, and the species whose sprites all come from pl_otherpoke.narc (BuildPokemonSpriteTemplate's switch).
KEEP = {"SPINDA", "UNOWN", "CASTFORM", "DEOXYS", "BURMY", "WORMADAM", "CHERRIM", "SHELLOS", "GASTRODON", "ROTOM",
        "GIRATINA", "SHAYMIN", "ARCEUS"}


def species_dirs():
    names = [l.strip() for l in open(os.path.join(DECOMP, "generated", "species.txt")) if l.strip()]
    return {i: n[len("SPECIES_"):] for i, n in enumerate(names) if 1 <= i <= LAST}


def load(path):
    return Image.open(path).convert("RGBA") if os.path.exists(path) else None


def y_offset(indexed):
    """The clear rows under the art in the 80x80 box centred in the 96x96 sprite (negative below that box)."""
    bb = indexed.getbbox()
    return 88 - bb[3] if bb else 0


def main():
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    os.makedirs(OUT)
    packs = {int(d[:4]): os.path.join(PACK, d) for d in os.listdir(PACK) if d[:4].isdigit()}
    offsets, folders, report = {}, [], []
    for dex, const in sorted(species_dirs().items()):
        name = const.lower()
        src = os.path.join(POKEMON, name)
        if const in KEEP and const != "SPINDA":
            continue  # their fronts come by form (FORMS, below)
        if const in KEEP or dex not in packs or not os.path.isdir(src):
            report.append(f"{const}: keeps Platinum's front")
            continue
        pack = packs[dex]
        front, shiny = load(os.path.join(pack, "front.png")), load(os.path.join(pack, "shiny_front.png"))
        if front is None or front.size != (96, 96):
            report.append(f"{const}: no 96x96 front, keeps Platinum's front")
            continue
        female, female_shiny = load(os.path.join(pack, "female_front.png")), load(os.path.join(pack, "female_shiny_front.png"))
        gendered = os.path.exists(os.path.join(src, "female_front.png"))
        group = [(front, shiny)] + ([(female, female_shiny)] if gendered and female is not None else [])
        pal, spal, images, ncol = paired_palettes(group)
        if ncol > 15:
            report.append(f"{const}: {ncol} colours, reduced to 15")
        if shiny is None:
            report.append(f"{const}: no shiny front (its shiny palette is the normal one)")
        folder = f"{dex:04}-{name}"
        out = os.path.join(OUT, folder)
        os.makedirs(out)
        male_png = two_frames(images[0], pal)
        files = {}
        if os.path.exists(os.path.join(src, "male_front.png")):
            files["male_front.png"] = male_png
        if gendered:
            files["female_front.png"] = two_frames(images[1], pal) if len(images) > 1 else male_png
        for fname, img in files.items():
            img.save(os.path.join(out, fname))
            shutil.copyfile(os.path.join(src, fname + ".key"), os.path.join(out, fname + ".key"))
        write_pal(os.path.join(out, "normal.pal"), (0, 0, 0), pal)
        write_pal(os.path.join(out, "shiny.pal"), (0, 0, 0), spal)
        male = y_offset(images[0])
        offsets[dex] = (male, y_offset(images[1]) if len(images) > 1 else male)
        folders.append((folder, sorted(files)))

    # The forms kept in pl_otherpoke.narc: a 96x96 front for each, packed after the other form sprites.
    key = os.path.join(POKEMON, "venusaur", "male_front.png.key")  # any key file works (a scramble seed)
    os.makedirs(os.path.join(OUT, "forms"))
    gen4, gen4_order = [], []
    for const, stems in FORMS.items():
        for form in range(len(stems)):
            pack = os.path.join(PACK, "forms", f"{const}-{form}")
            front, shiny = load(os.path.join(pack, "front.png")), load(os.path.join(pack, "shiny_front.png"))
            assert front is not None and front.size == (96, 96), pack
            pal, spal, (indexed,), ncol = paired_palettes([(front, shiny)])
            if ncol > 15:
                report.append(f"{const} form {form}: {ncol} colours, reduced to 15")
            folder = f"{len(gen4_order):03}-{const.lower()}-{form}"
            out = os.path.join(OUT, "forms", folder)
            os.makedirs(out)
            two_frames(indexed, pal).save(os.path.join(out, "front.png"))
            shutil.copyfile(key, os.path.join(out, "front.png.key"))
            write_pal(os.path.join(out, "normal.pal"), (0, 0, 0), pal)
            write_pal(os.path.join(out, "shiny.pal"), (0, 0, 0), spal)
            gen4_order.append(folder)
            gen4.append((const, form, y_offset(indexed)))
    with open(os.path.join(OUT, "forms", "order.txt"), "w") as f:
        f.write("".join(o + "\n" for o in gen4_order))

    with open(os.path.join(OUT, "meson.build"), "w") as f:
        f.write("# Generated by tools/sprites/convert_fronts96.py. Do not edit.\n")
        for folder, names in folders:
            for fname in names + ["normal.pal", "shiny.pal"]:
                f.write(f"pokegra_files += files('{folder}/{fname}')\n")
        for folder in gen4_order:
            for fname in ("front.png", "normal.pal", "shiny.pal"):
                f.write(f"pokegra_files += files('forms/{folder}/{fname}')\n")
    with open(HEADER, "w") as f:
        f.write("// Generated by tools/sprites/convert_fronts96.py. Do not edit.\n"
                "#ifndef POKEPLATINUM_DATA_SOVEREIGN_FRONTS96_H\n#define POKEPLATINUM_DATA_SOVEREIGN_FRONTS96_H\n\n"
                "#include \"constants/species.h\"\n\n"
                "#define FRONT96_NONE 127\n\n"
                "// For species #1-493: the y offset of its 96x96 front {male, female} (the clear rows under the art in the\n"
                "// 80x80 box centred in the sprite, negative when the art reaches below that box), or FRONT96_NONE for a\n"
                "// species that keeps Platinum's front.\n"
                "static const s8 sFront96YOffset[SPECIES_ARCEUS + 1][2] = {\n")
        for dex in range(LAST + 1):
            m, fe = offsets.get(dex, ("FRONT96_NONE", "FRONT96_NONE"))
            f.write(f"    {{ {m}, {fe} }},\n")
        f.write("};\n\n// The forms Platinum keeps in pl_otherpoke.narc, in the order their 96x96 fronts are packed after the\n"
                "// other form sprites (make_pl_pokegra.py), with each one's y offset.\n"
                "static const struct {\n    u16 species;\n    u8 form;\n    s8 yOffset;\n} sGen4FormFront96[] = {\n")
        for const, form, off in gen4:
            f.write(f"    {{ SPECIES_{const}, {form}, {off} }},\n")
        f.write("};\n\n#endif\n")
    print(f"{len(folders)} fronts, {len(gen4)} form fronts")
    print("\n".join(report))


if __name__ == "__main__":
    main()
