#!/usr/bin/env python3
"""Check that every battle sprite the game builds from res/pokemon/ can be shown.

Each species' {male,female}_{front,back}.png, each form's front.png in res/pokemon/sovereign_form_sprites/ and back.png
in res/pokemon/sovereign_form_backs/, must be an indexed 160x80 image (two 80x80 frames) with palette indices 0-15. Its first four pixels must be clear
(index 0): the game unscrambles a sprite with a key it takes from them (PokemonSprite_DecryptPt), so a sprite whose
art reaches the top-left corner comes out as noise in battle (Talonflame's back did, and Samurott's PokeAPI front).
tools/sprites/convert_battle_sprites.py, convert_form_sprites.py and convert_form_backs.py clear them.

Each form folder's order.txt (the order make_pl_pokegra.py packs them in, one folder a line) must list every folder
there once, each with its image and both palettes: the game finds a form's sprite by its place in that order.

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
    for folder, image in (("sovereign_form_sprites", "front.png"), ("sovereign_form_backs", "back.png")):
        forms = os.path.join(root, folder)
        if os.path.isdir(forms):
            for form in sorted(os.listdir(forms)):
                if os.path.isdir(os.path.join(forms, form)):
                    yield os.path.join(forms, form, image)


def order_problems(root):
    """Each form folder's order.txt against the folders there."""
    out = []
    for folder, image in (("sovereign_form_sprites", "front.png"), ("sovereign_form_backs", "back.png")):
        forms = os.path.join(root, folder)
        if not os.path.isdir(forms):
            continue
        order = open(os.path.join(forms, "order.txt"), encoding="utf-8").read().splitlines()
        dirs = sorted(d for d in os.listdir(forms) if os.path.isdir(os.path.join(forms, d)))
        if sorted(order) != dirs or len(set(order)) != len(order):
            out.append(f"{folder}/order.txt doesn't list each folder there once")
        for form in order:
            for name in (image, "normal.pal", "shiny.pal"):
                if not os.path.exists(os.path.join(forms, form, name)):
                    out.append(f"{folder}/{form}: no {name}")
    return out


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
    for p in order_problems(root):
        print(p)
        bad += 1
    print(f"{checked} battle sprites checked, {bad} problems")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
