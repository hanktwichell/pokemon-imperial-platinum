#!/usr/bin/env python3
"""Check that every battle sprite the game builds from res/pokemon/ can be shown.

Each species' {male,female}_{front,back}.png, and each form's front.png in res/pokemon/sovereign_form_sprites/, must
be an indexed 160x80 image (two 80x80 frames) with palette indices 0-15. Its first four pixels must be clear
(index 0): the game unscrambles a sprite with a key it takes from them (PokemonSprite_DecryptPt), so a sprite whose
art reaches the top-left corner comes out as noise in battle (Talonflame's back did, and Samurott's PokeAPI front).
tools/sprites/convert_battle_sprites.py and convert_form_sprites.py clear them.

Usage: python3 tools/test/check_battle_sprites.py DECOMP_DIR
"""
import os
import sys

from PIL import Image


def problems(path):
    im = Image.open(path)
    if im.mode != "P":
        return [f"mode {im.mode}, not indexed"]
    if im.size != (160, 80):
        return [f"size {im.size}, not 160x80"]
    out = []
    if max(im.get_flattened_data()) > 15:
        out.append("palette index over 15")
    corner = [im.getpixel((x, 0)) for x in range(4)]
    if any(corner):
        out.append(f"first four pixels not clear {corner}: the sprite is scrambled in battle")
    return out


def sprites(root):
    for species in sorted(os.listdir(root)):
        for face in ("front", "back"):
            for gender in ("male", "female"):
                yield os.path.join(root, species, f"{gender}_{face}.png")
    forms = os.path.join(root, "sovereign_form_sprites")
    if os.path.isdir(forms):
        for form in sorted(os.listdir(forms)):
            yield os.path.join(forms, form, "front.png")


def main():
    root = os.path.join(sys.argv[1], "res", "pokemon")
    bad = checked = 0
    for path in sprites(root):
        if not os.path.exists(path):
            continue
        checked += 1
        for p in problems(path):
            print(f"{os.path.relpath(path, root)}: {p}")
            bad += 1
    print(f"{checked} battle sprites checked, {bad} problems")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
