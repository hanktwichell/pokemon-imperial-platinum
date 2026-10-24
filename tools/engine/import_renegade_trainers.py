#!/usr/bin/env python3
"""Renegade Platinum's trainer teams (E10).

Renegade keeps Platinum's trainer format, so its teams are read straight from its ROM (`trdata.narc`, `trpoke.narc`)
and written into Sovereign's trainer files (`decomp/res/trainers/data/<trainer>.json`): each trainer's class, items,
AI flags, single or double battle, and party (species and form, level, held items, moves, IV scale, Ball Capsule).
Names and messages are left alone. It's a one-off step, like `import_renegade_wild.py`:

    python3 tools/engine/import_renegade_trainers.py RenegadePlatinum.nds [--dry-run]

(the patched ROM; `tools/build/apply_renegade_patch.sh` makes it). Needs `pip install ndspy`.

What it skips, and prints:
* trainers Renegade gave to someone else: the slot's name changed (Renegade put Steven in trainer 5, for one). Those
  come with the event that uses them, as do Renegade's 138 trainers past Platinum's 928.
* trainers whose party Renegade emptied (unused rival slots), and those listed in `SKIP` below.
Renegade renamed some moves and items in place (Horn Drill is Drill Run, the Seal Bag is the GS Ball...): those are
matched by their Renegade name to Sovereign's own move or item. `data/trainers_sovereign.yaml` (the owner's boss
teams) goes on top of this later (milestone T1).
"""
import json
import os
import re
import struct
import subprocess
import sys

import ndspy.narc
import ndspy.rom

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
DATA = os.path.join(DECOMP, "res", "trainers", "data")
VANILLA_TRAINERS = 928
FORM_SHIFT = 10  # Platinum's trpoke keeps the form in the species' top 6 bits
SKIP = set()  # trainer constants to leave as they are
SAME = {"TRAINER_TWINS_EMMA_AND_LIL"}  # Renegade only respelled the name ("Ema & Lil")
# Renegade empties Barry's first Survival Area teams (fewer than 20 League wins) and fills only the second ones; both
# get the second team here, so the battle isn't against Platinum's weaker one.
TEAM_FROM = {"TRAINER_RIVAL_SURVIVAL_AREA_1_PIPLUP": "TRAINER_RIVAL_SURVIVAL_AREA_2_PIPLUP",
             "TRAINER_RIVAL_SURVIVAL_AREA_1_TURTWIG": "TRAINER_RIVAL_SURVIVAL_AREA_2_TURTWIG",
             "TRAINER_RIVAL_SURVIVAL_AREA_1_CHIMCHAR": "TRAINER_RIVAL_SURVIVAL_AREA_2_CHIMCHAR"}


def lines(path):
    return [l.strip() for l in open(os.path.join(DECOMP, "generated", path)) if l.strip()]


def norm(name):
    return re.sub(r"[^a-z0-9]", "", name.lower().replace("é", "e"))


def text_bank(rom_path, bank):
    out = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "design", "renegade_rom.py"), rom_path, "text", bank],
                         capture_output=True, text=True, check=True).stdout
    return {int(m.group(1)): m.group(2) for m in re.finditer(r"^(\d+): (.*)$", out, re.M)}


def renamed(rom_path, bank, consts):
    """Renegade's IDs whose name isn't Platinum's: ID -> Sovereign constant with Renegade's name (or None)."""
    rene = text_bank(rom_path, "TEXT_BANK_" + bank.upper())
    by_name = {norm(c.split("_", 1)[1]): c for c in consts}
    out = {}
    for i, name in rene.items():
        if i >= len(consts):
            continue
        if norm(name) != norm(consts[i].split("_", 1)[1]) and norm(name) in by_name:
            out[i] = by_name[norm(name)]
    return out


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    rom_path, dry = sys.argv[1], "--dry-run" in sys.argv
    rom = ndspy.rom.NintendoDSRom.fromFile(rom_path)
    td_all = ndspy.narc.NARC(rom.getFileByName("poketool/trainer/trdata.narc")).files
    tp_all = ndspy.narc.NARC(rom.getFileByName("poketool/trainer/trpoke.narc")).files

    trainers = lines("trainers.txt")
    species = lines("species.txt")
    moves = lines("moves.txt")
    items = lines("items.txt")
    classes = lines("trainer_classes.txt")
    ai_flags = [f for f in lines("ai_flags.txt") if f != "AI_FLAG_NONE" and f != "AI_FLAG_ALL"]
    move_map = renamed(rom_path, "move_names", moves)
    item_map = renamed(rom_path, "item_names", items)

    rene_names = text_bank(rom_path, "TEXT_BANK_NPC_TRAINER_NAMES")

    def move(i):
        return move_map.get(i, moves[i])

    def item(i):
        return None if i == 0 else item_map.get(i, items[i])

    changed, skipped = 0, []
    for n in range(1, VANILLA_TRAINERS):
        const = trainers[n]
        path = os.path.join(DATA, const[len("TRAINER_"):].lower() + ".json")
        if const in SKIP or not os.path.exists(path):
            skipped.append((const, "skipped" if const in SKIP else "no file"))
            continue
        with open(path, encoding="utf-8") as f:
            raw = f.read()
        data = json.loads(raw)
        rene_name = rene_names.get(n, "").replace("{TRNAME}", "")
        if const not in SAME and norm(rene_name.replace("＆", "&").replace(" nd ", " & ")) != norm(data["name"]):
            skipped.append((const, f"Renegade's {rene_name!r}"))
            continue
        src = trainers.index(TEAM_FROM[const]) if const in TEAM_FROM else n
        td, tp = bytes(td_all[src]), bytes(tp_all[src])
        kind, cls, count = td[0], td[1], td[3]
        if count == 0:  # Renegade emptied a few unused slots; a party needs a Pokémon
            skipped.append((const, "Renegade's party is empty"))
            continue
        has_moves, has_items = kind in (1, 3), kind in (2, 3)
        size = {0: 8, 1: 16, 2: 10, 3: 18}[kind]
        party = []
        for o in range(0, count * size, size):
            v = struct.unpack_from("<%dH" % (size // 2), tp, o)
            mon = {"species": species[v[2] & ((1 << FORM_SHIFT) - 1)], "form": v[2] >> FORM_SHIFT, "level": v[1]}
            rest = list(v[3:])
            mon["item"] = item(rest.pop(0)) if has_items else None
            mon["moves"] = [move(m) for m in rest[:4]] if has_moves else None
            mon["iv_scale"] = v[0]
            mon["ball_seal"] = rest[-1]
            party.append(mon)
        ai_mask = struct.unpack_from("<I", td, 12)[0]
        new = dict(data)
        new["class"] = classes[cls]
        new["items"] = [it for it in (item(i) for i in struct.unpack_from("<4H", td, 4)) if it]
        new["ai_flags"] = [f for b, f in enumerate(ai_flags) if ai_mask & (1 << b)]
        new["double_battle"] = struct.unpack_from("<I", td, 16)[0] != 0
        new["party"] = party
        if new != data:
            changed += 1
            if not dry:
                indent = 4 if raw.startswith("{\n    ") else 2
                end = raw[len(raw.rstrip("\n")):]  # keep the file's own ending
                with open(path, "w", encoding="utf-8") as f:
                    f.write(json.dumps(new, indent=indent, ensure_ascii=False) + end)
    print(f"{changed} trainers changed; {len(skipped)} skipped:")
    for const, why in skipped:
        print(f"  {const}: {why}")


if __name__ == "__main__":
    main()
