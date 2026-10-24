#!/usr/bin/env python3
"""Renegade Platinum's TM changes (E10).

Renegade replaced six TMs' moves: TM55 Brine -> Scald, TM57 Charge Beam -> Wild Charge, TM62 Silver Wind -> Bug Buzz,
TM83 Natural Gift -> Hyper Voice, TM85 Dream Eater -> Dazzling Gleam, TM88 Pluck -> Hurricane
(`RenegadePlatinumV130/Documentation/ItemChanges.txt`). This script changes those TMs' items
(`decomp/res/items/data/tmNN.json`: move, description, disc colour) and which Pokémon can learn them:

* #1-493: the species that can use the TM in Renegade (its ROM's personal data), plus the species that can learn
  the new move in the newest games (the Gen IX learnsets, as for every other TM);
* #494-1025 and the forms: the newest games' learnsets (a form PokeAPI doesn't list follows its species).

The rest of each learnset is left alone. It's a one-off step:

    python3 tools/engine/apply_renegade_tms.py /path/to/pokeapi/data/v2/csv RenegadePlatinum.nds

(the patched ROM as for `import_renegade_wild.py`). Needs `pip install ndspy`.
"""
import glob
import json
import os
import re
import sys

import ndspy.narc
import ndspy.rom

sys.path.insert(0, os.path.dirname(__file__))
import gen_species_gen9 as gen9  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
POKEMON = os.path.join(DECOMP, "res", "pokemon")
ITEMS = os.path.join(DECOMP, "res", "items", "data")

# TM -> (move, bag description, disc palette). Descriptions are written for the bag (3 lines of up to 38 characters,
# like Platinum's TM descriptions). There's no Fairy disc colour; Dazzling Gleam keeps Dream Eater's pink one.
SWAPS = {
    55: ("MOVE_SCALD", ["The user shoots boiling hot water at\n", "its target. It may also leave the\n",
                        "target with a burn."], "tm_water_NCLR"),
    57: ("MOVE_WILD_CHARGE", ["The user shrouds itself in electricity\n", "and smashes into its foe. It also\n",
                              "damages the user a little."], "tm_electric_NCLR"),
    62: ("MOVE_BUG_BUZZ", ["The user vibrates to make a damaging\n", "sound wave. It may also lower the\n",
                           "foe’s Sp. Def stat."], "tm_bug_NCLR"),
    83: ("MOVE_HYPER_VOICE", ["The user lets loose a horribly echoing\n", "shout with the power to inflict\n",
                              "damage."], "tm_normal_NCLR"),
    85: ("MOVE_DAZZLING_GLEAM", ["The user damages opposing Pokémon by\n", "emitting a powerful flash."],
         "tm_psychic_NCLR"),
    88: ("MOVE_HURRICANE", ["The user wraps its foe in a fierce\n", "wind that flies up into the sky. It\n",
                            "may also confuse the foe."], "tm_flying_NCLR"),
}


def learnable(ctx, pid):
    """Every move the Pokémon (PokeAPI id) can learn in the newest games that have it (as gen_species_gen9 uses)."""
    learn, move_ok = ctx["learn"], ctx["move_ok"]
    groups = next((g for _, g in gen9.FAMILIES if any(learn[pid][v] for v in g)), [])
    return {move_ok[mv] for v in groups for (_, _, _, mv) in learn[pid][v] if mv in move_ok}


def renegade_tms(rom_path):
    rom = ndspy.rom.NintendoDSRom.fromFile(rom_path)
    personal = ndspy.narc.NARC(rom.getFileByName("poketool/personal/pl_personal.narc"))
    out = {}
    for dex in range(1, 494):
        bits = personal.files[dex][0x1C:0x2C]
        out[dex] = {tm for tm in SWAPS if (bits[(tm - 1) // 8] >> ((tm - 1) % 8)) & 1}
    return out


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    ctx = gen9.load_context(sys.argv[1])
    renegade = renegade_tms(sys.argv[2])
    species = [l.strip() for l in open(os.path.join(DECOMP, "generated", "species.txt")) if l.strip()]

    for tm, (move, description, palette) in SWAPS.items():
        path = os.path.join(ITEMS, f"tm{tm:02d}.json")
        d = json.load(open(path, encoding="utf-8"))
        d["teachesMove"], d["description"], d["icon"]["palette"] = move, description, palette
        with open(path, "w", encoding="utf-8") as f:
            f.write(json.dumps(d, indent=2, ensure_ascii=False))

    base_tms = {}
    counts = {tm: 0 for tm in SWAPS}
    for dex in range(1, len(species)):
        folder = species[dex][8:].lower()
        path = os.path.join(POKEMON, folder, "data.json")
        if not os.path.exists(path):
            continue
        pid = str(dex)
        moves = learnable(ctx, pid)
        tms = {tm for tm, (move, _, _) in SWAPS.items() if move in moves} | renegade.get(dex, set())
        base_tms[folder] = tms
        set_tms(path, tms, counts)
        for form_path in sorted(glob.glob(os.path.join(POKEMON, folder, "forms", "*", "data.json"))):
            form = form_path.split(os.sep)[-2]
            row = ctx["poke"].get(f"{folder}-{form}".replace("_", "-"))
            form_tms = tms
            if row:
                moves = learnable(ctx, row["id"])
                form_tms = {tm for tm, (move, _, _) in SWAPS.items() if move in moves}
            set_tms(form_path, form_tms, counts)
    print("learners per TM:", {f"TM{tm}": n for tm, n in counts.items()})


def set_tms(path, tms, counts):
    d = json.load(open(path, encoding="utf-8"))
    ls = d["learnset"]
    old = ls.get("by_tm", [])
    keep = [t for t in old if not (t.startswith("TM") and int(t[2:]) in SWAPS)]
    new = sorted(set(keep) | {f"TM{tm:02d}" for tm in tms}, key=lambda x: (x[:2] == "HM", int(x[2:])))
    for tm in tms:
        counts[tm] += 1
    if new == old:
        return
    # Rewrite only the by_tm list, in the file's own layout (gen_forms.py and gen_species_gen9.py lay files out
    # differently).
    text = open(path, encoding="utf-8").read()
    start = text.index('"by_tm": [') + len('"by_tm": [')
    end = text.index("]", start)
    body = text[start:end]
    if "\n" in body:
        indent = re.search(r"\n([ \t]*)\"", body).group(1)
        closing = body[body.rindex("\n"):]
        body = "\n" + ",\n".join(f'{indent}"{t}"' for t in new) + closing
    else:
        body = " " + ", ".join(f'"{t}"' for t in new) + " "
    with open(path, "w", encoding="utf-8") as f:
        f.write(text[:start] + body + text[end:])


if __name__ == "__main__":
    main()
