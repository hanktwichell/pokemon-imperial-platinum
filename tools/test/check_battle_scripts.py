#!/usr/bin/env python3
"""Check that every built battle script fits in BattleContext.battleScript (BATTLE_SCRIPT_SIZE_MAX u32s).

A script loads whole into that buffer, and the game doesn't stop one that is too long: it overwrites the battlers
after the buffer (Toxic's subscript did, and the player's Pokémon lost its moves). Run it after a build.

First it checks that the subscripts' NARC order (subscripts/sub_seq.order) lists every subscript in meson.build, in the
order of generated/battle_subscripts.txt. A subscript missing from the order still builds, at the NARC's end, so a
script's Call BATTLE_SUBSCRIPT_... of it can run a different subscript (Wind Power's charge ran Cotton Down).

Usage: python3 tools/test/check_battle_scripts.py decomp [build dir, default decomp/build]
"""
import os
import re
import sys


def check_subscript_order(decomp):
    subscripts = os.path.join(decomp, "res", "battle", "scripts", "subscripts")
    order = open(os.path.join(subscripts, "sub_seq.order"), encoding="utf-8").read().split()
    consts = open(os.path.join(decomp, "generated", "battle_subscripts.txt"), encoding="utf-8").read().split()
    files = re.findall(r"'(\w+)\.s'", open(os.path.join(subscripts, "meson.build"), encoding="utf-8").read())
    errors = [f"sub_seq.order line {i + 1} is {name}, but BATTLE_SUBSCRIPT number {i} is {const}"
              for i, (name, const) in enumerate(zip(order, consts)) if "BATTLE_" + name.upper() != const]
    if len(order) != len(consts):
        errors.append(f"sub_seq.order lists {len(order)} subscripts, generated/battle_subscripts.txt {len(consts)}")
    errors += [f"{name}.s is in meson.build but not in sub_seq.order" for name in files if name not in order]
    errors += [f"{name} is in sub_seq.order but not in meson.build" for name in order if name not in files]
    for error in errors:
        print(error)
    if errors:
        sys.exit(1)


def main():
    if len(sys.argv) not in (2, 3):
        sys.exit(__doc__)
    decomp = sys.argv[1]
    check_subscript_order(decomp)
    build = sys.argv[2] if len(sys.argv) == 3 else os.path.join(decomp, "build")
    header = open(os.path.join(decomp, "include", "constants", "battle.h"), encoding="utf-8").read()
    limit = int(re.search(r"#define BATTLE_SCRIPT_SIZE_MAX\s+(\d+)", header).group(1)) * 4
    scripts = os.path.join(build, "res", "battle", "scripts")
    sizes = []
    for narc in ("be_seq", "sub_seq", "waza_seq"):
        root = os.path.join(scripts, f"{narc}.narc.p")
        if not os.path.isdir(root):
            sys.exit(f"no {root}: build the ROM first")
        for dirpath, _, files in os.walk(root):
            for name in files:
                path = os.path.join(dirpath, name)
                sizes.append((os.path.getsize(path), os.path.relpath(path, scripts)))
    sizes.sort(reverse=True)
    too_big = [(size, path) for size, path in sizes if size >= limit]
    for size, path in too_big:
        print(f"{path}: {size} bytes, the buffer holds {limit} (BATTLE_SCRIPT_SIZE_MAX in include/constants/battle.h)")
    if too_big:
        sys.exit(1)
    print(f"{len(sizes)} battle scripts fit in {limit} bytes; the largest is {sizes[0][1]} ({sizes[0][0]} bytes)")


if __name__ == "__main__":
    main()
