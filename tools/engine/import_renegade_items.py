#!/usr/bin/env python3
"""Import Renegade Platinum's overworld item balls into the decomp (E10).

Every visible item in Platinum is a ScriptEntry of `scripts_visible_items.s` that sets VAR_0x8008 (the item) and
VAR_0x8009 (how many). Renegade kept the same 328 entries in the same order and changed 110 of their items, so its
items can be read straight from its ROM (`fielddata/script/scr_seq.narc`, file 404):

    python3 tools/engine/import_renegade_items.py RenegadePlatinum.nds
    python3 tools/engine/place_mega_stones.py      # puts Sovereign's Mega Stones back on top

Renegade reused a few unused Platinum items for its own (ItemChanges.txt, "Replaced Items"): its Contest Pass is the
Ice Stone and its Loot Sack the Prism Scale; they're mapped to Sovereign's real items. TMs give 1 (the bag makes it
99). The ball's script names stay as they are (the Mega Stone yaml and docs use them). One-off step; needs ndspy.
"""
import os
import re
import struct
import sys

import ndspy.narc
import ndspy.rom

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
SCRIPTS = os.path.join(DECOMP, "res", "field", "scripts", "scripts_visible_items.s")
SCRIPT_FILE = 404  # scripts_visible_items in scripts.order (line 405)
RENEGADE_ITEMS = {"ITEM_CONTEST_PASS": "ITEM_ICE_STONE", "ITEM_LOOT_SACK": "ITEM_PRISM_SCALE"}
SET_VAR = 0x0028
# Where else a TM can come from today in the main game: NPC gifts in the map scripts, the marts and the Game Corner
# (not the Battle Frontier's BP shop in scrcmd.c).
OTHER_TM_SOURCES = [os.path.join(DECOMP, "include", "data", "mart_items.h"),
                    os.path.join(DECOMP, "src", "scrcmd_game_corner_prize.c")] + sorted(
    os.path.join(DECOMP, "res", "field", "scripts", f) for f in os.listdir(os.path.join(DECOMP, "res", "field", "scripts"))
    if f.endswith(".s") and f != "scripts_visible_items.s")


def renegade_entries(rom_path):
    rom = ndspy.rom.NintendoDSRom.fromFile(rom_path)
    data = bytes(ndspy.narc.NARC(rom.getFileByName("fielddata/script/scr_seq.narc")).files[SCRIPT_FILE])
    offsets, pos = [], 0
    while struct.unpack_from("<H", data, pos)[0] != 0xFD13:  # the ScriptEntry table ends with 0xFD13
        offsets.append(pos + 4 + struct.unpack_from("<i", data, pos)[0])
        pos += 4
    out = []
    for o in offsets:
        cmd, var, item, cmd2, var2, count = struct.unpack_from("<6H", data, o)
        out.append((item, count) if (cmd, var, cmd2, var2) == (SET_VAR, 0x8008, SET_VAR, 0x8009) else None)
    return out


def main():
    items = [l.strip() for l in open(os.path.join(DECOMP, "generated", "items.txt")) if l.strip()]
    text = open(SCRIPTS, encoding="utf-8").read()
    names = re.findall(r"^    ScriptEntry (\w+)", text, re.M)
    entries = renegade_entries(sys.argv[1])
    assert len(names) == len(entries), (len(names), len(entries))

    # Renegade gives some TMs from NPCs whose scripts aren't ported yet. Until they are, a ball whose Platinum TM would
    # otherwise be lost keeps it (repeated, since a kept ball can lose another TM in turn).
    # Platinum's TM in a ball is in the ball's script name (VisibleItems_Route213_TM40).
    vanilla = {n: "ITEM_" + re.search(r"_((?:TM|HM)\d\d)$", n).group(1) for n in names if re.search(r"_(TM|HM)\d\d$", n)}
    renegade = {n: RENEGADE_ITEMS.get(items[e[0]], items[e[0]]) for n, e in zip(names, entries) if e}
    others = set(re.findall(r"ITEM_((?:TM|HM)\d\d)", "".join(open(f, encoding="utf-8").read() for f in OTHER_TM_SOURCES)))
    keep = set()
    while True:
        have = {vanilla[n] if n in keep else renegade.get(n) for n in names} | {"ITEM_" + t for t in others}
        lost = sorted(set(vanilla.values()) - have)
        if not lost:
            break
        keep |= {n for n in vanilla if vanilla[n] in lost}
    for n in sorted(keep):
        print(f"kept for now: {n} ({vanilla[n]}; Renegade: {renegade.get(n)})")

    changed = 0
    for name, entry in zip(names, entries):
        if entry is None:
            continue
        item, count = items[entry[0]], entry[1]
        item = RENEGADE_ITEMS.get(item, item)
        if name in keep:
            item, count = vanilla[name], 1
        if item.startswith("ITEM_TM"):
            count = 1
        pattern = re.compile(r"^(%s:\n    SetVar VAR_0x8008, )ITEM_\w+(?: // .*)?\n    SetVar VAR_0x8009, \w+$" % re.escape(name), re.M)
        new, n = pattern.subn(lambda m: f"{m.group(1)}{item}\n    SetVar VAR_0x8009, {count}", text, count=1)
        if n != 1:
            sys.exit(f"{name}: item lines not found")
        changed += new != text
        text = new
    open(SCRIPTS, "w", encoding="utf-8").write(text)
    print(f"{changed} item balls changed")


if __name__ == "__main__":
    main()
