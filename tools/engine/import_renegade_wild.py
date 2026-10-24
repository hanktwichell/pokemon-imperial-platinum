#!/usr/bin/env python3
"""Import Renegade Platinum's wild encounter tables into the decomp (E10).

Renegade is a binary hack, so its tables come from a patched ROM: build vanilla Platinum from the
first decomp import (it matches the retail ROM), apply Renegade with
`tools/build/apply_renegade_patch.sh`, then run

    python3 tools/engine/import_renegade_wild.py RenegadePlatinum.nds

This rewrites every `decomp/res/field/encounters/encounters_*.json` from the ROM's
`fielddata/encountdata/pl_enc_data.narc`: levels, rates, swarm, time-of-day, Poké Radar and
fishing slots, all exactly as Renegade has them. The Pal Park file is skipped (it is the Regional
Forms Park now, decision 22), and each file keeps its `map_category`.

It's a one-off step (the ROM isn't in the repository). The Sovereign encounter plan
(`data/encounters_sovereign.json`) is then laid over these tables by `gen_wild_encounters.py`,
which keeps Renegade's levels. Needs `pip install ndspy`.
"""
import json
import os
import struct
import sys

import ndspy.narc
import ndspy.rom

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ENC = os.path.join(ROOT, "decomp", "res", "field", "encounters")
SPECIES = os.path.join(ROOT, "decomp", "generated", "species.txt")
SKIP = {"encounters_pal_park"}
FILE_SIZE = 424  # Renegade's Route 217 file is 44 bytes short (no fishing data); the missing bytes read as zeros


def main():
    rom = ndspy.rom.NintendoDSRom.fromFile(sys.argv[1])
    narc = ndspy.narc.NARC(rom.getFileByName("fielddata/encountdata/pl_enc_data.narc"))
    order = [l.strip() for l in open(os.path.join(ENC, "encounters.order")) if l.strip()]
    species = [l.strip() for l in open(SPECIES) if l.strip()]
    # Sovereign appended Pal Park's own table (the Regional Forms Park) after Platinum's 183.
    assert order[len(narc.files):] == ["encounters_pal_park"], (len(order), len(narc.files))

    changed = 0
    for name, raw in zip(order, narc.files):
        if name in SKIP:
            continue
        f = bytes(raw) + bytes(max(0, FILE_SIZE - len(raw)))
        pos = 0

        def u32():
            nonlocal pos
            v = struct.unpack_from("<I", f, pos)[0]
            pos += 4
            return v

        def sp():
            return species[u32()]

        def water():
            nonlocal pos
            out = []
            for _ in range(5):
                lmax, lmin = f[pos], f[pos + 1]
                pos += 4
                out.append({"level_max": lmax, "level_min": lmin, "species": sp()})
            return out

        d = {"land_rate": u32()}
        d["land_encounters"] = [{"level": u32(), "species": sp()} for _ in range(12)]
        for key in ("swarms", "day", "night"):
            d[key] = [sp(), sp()]
        d["radar"] = [sp() for _ in range(4)]
        for key in ("rate_form0", "rate_form1", "rate_form2", "rate_form3", "rate_form4", "unown_table"):
            d[key] = u32()
        for key in ("ruby", "sapphire", "emerald", "firered", "leafgreen"):
            d[key] = [sp(), sp()]
        d["surf_rate"] = u32()
        d["surf_encounters"] = water()
        pos += 44
        for rod in ("old", "good", "super"):
            d[f"{rod}_rod_rate"] = u32()
            d[f"{rod}_rod_encounters"] = water()

        path = os.path.join(ENC, name + ".json")
        old = json.load(open(path, encoding="utf-8"))
        new = {k: d.get(k, v) for k, v in old.items()}
        if new != old:
            changed += 1
            with open(path, "w", encoding="utf-8") as out:
                json.dump(new, out, indent=4, ensure_ascii=False)
    print(f"{changed} encounter files changed")


if __name__ == "__main__":
    main()
