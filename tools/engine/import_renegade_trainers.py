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
teams) goes on top of this later (milestone T1). Other scripts can import `Renegade` to write Renegade's own trainers
(`Renegade(rom).new_trainer(n)`), as their events are ported.
"""
import ast
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


class Renegade:
    """Renegade's trainers, read from its ROM, in Sovereign's trainer JSON terms."""

    def __init__(self, rom_path):
        rom = ndspy.rom.NintendoDSRom.fromFile(rom_path)
        self.td = ndspy.narc.NARC(rom.getFileByName("poketool/trainer/trdata.narc")).files
        self.tp = ndspy.narc.NARC(rom.getFileByName("poketool/trainer/trpoke.narc")).files
        self.trtbl = bytes(ndspy.narc.NARC(rom.getFileByName("poketool/trmsg/trtbl.narc")).files[0])
        self.rom_path = rom_path
        self.species, self.moves, self.items = lines("species.txt"), lines("moves.txt"), lines("items.txt")
        self.classes = lines("trainer_classes.txt")
        self.ai_flags = [f for f in lines("ai_flags.txt") if f not in ("AI_FLAG_NONE", "AI_FLAG_ALL")]
        self.move_map = renamed(rom_path, "move_names", self.moves)
        self.item_map = renamed(rom_path, "item_names", self.items)
        self.names = text_bank(rom_path, "TEXT_BANK_NPC_TRAINER_NAMES")

    def move(self, i):
        return self.move_map.get(i, self.moves[i])

    def item(self, i):
        return None if i == 0 else self.item_map.get(i, self.items[i])

    def name(self, n):
        return self.names.get(n, "").replace("{TRNAME}", "")

    def fields(self, n):
        """Trainer n's class, items, AI flags, battle type and party; None if Renegade left its party empty."""
        td, tp = bytes(self.td[n]), bytes(self.tp[n])
        kind, cls, count = td[0], td[1], td[3]
        if count == 0:
            return None
        has_moves, has_items = kind in (1, 3), kind in (2, 3)
        size = {0: 8, 1: 16, 2: 10, 3: 18}[kind]
        party = []
        for o in range(0, count * size, size):
            v = struct.unpack_from("<%dH" % (size // 2), tp, o)
            mon = {"species": self.species[v[2] & ((1 << FORM_SHIFT) - 1)], "form": v[2] >> FORM_SHIFT, "level": v[1]}
            rest = list(v[3:])
            mon["item"] = self.item(rest.pop(0)) if has_items else None
            mon["moves"] = [self.move(m) for m in rest[:4]] if has_moves else None
            mon["iv_scale"] = v[0]
            mon["ball_seal"] = rest[-1]
            party.append(mon)
        ai_mask = struct.unpack_from("<I", td, 12)[0]
        return {
            "class": self.classes[cls],
            "items": [it for it in (self.item(i) for i in struct.unpack_from("<4H", td, 4)) if it],
            "ai_flags": [f for b, f in enumerate(self.ai_flags) if ai_mask & (1 << b)],
            "double_battle": struct.unpack_from("<I", td, 16)[0] != 0,
            "party": party,
        }

    def messages(self, n):
        """Trainer n's battle messages (trtbl order), as the JSON's "messages" list."""
        bank = text_bank(self.rom_path, "TEXT_BANK_NPC_TRAINER_MESSAGES")
        types = lines("trainer_message_types.txt")
        out = []
        for i in range(0, len(self.trtbl), 4):
            trainer, kind = struct.unpack_from("<HH", self.trtbl, i)
            if trainer == n and i // 4 in bank:
                text = bank[i // 4]
                out.append({"type": types[kind], "en_US": ast.literal_eval(text) if text.startswith("[") else text})
        return out

    def new_trainer(self, n):
        """A whole trainer JSON for Renegade's trainer n (for Renegade's own trainers, past Platinum's 928)."""
        return {"name": self.name(n), **self.fields(n), "messages": self.messages(n)}


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    rom_path, dry = sys.argv[1], "--dry-run" in sys.argv
    rene = Renegade(rom_path)
    trainers = lines("trainers.txt")

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
        rene_name = rene.name(n)
        if const not in SAME and norm(rene_name.replace("＆", "&").replace(" nd ", " & ")) != norm(data["name"]):
            skipped.append((const, f"Renegade's {rene_name!r}"))
            continue
        fields = rene.fields(trainers.index(TEAM_FROM[const]) if const in TEAM_FROM else n)
        if fields is None:  # Renegade emptied a few unused slots; a party needs a Pokémon
            skipped.append((const, "Renegade's party is empty"))
            continue
        new = {**data, **fields}
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
