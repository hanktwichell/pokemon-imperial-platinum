#!/usr/bin/env python3
"""Move the non-species sound banks and wave archives out of the way of species #494-1025 (milestone E6).

A cry's bank and wave archive ID equal the species ID, so in Platinum's sound archive slots 1-493 are cries, 494 is
Shaymin-Sky's cry and 700-770 are the BASIC/BGM/SE banks. Imperial needs slots 1-1025 for cries, so this moves:
  * Shaymin-Sky's cry  494      -> 1050 (still above every species ID; code finds it by its generated symbol)
  * BASIC/BGM/SE banks 700-770  -> 1100-1170
The code refers to all of these by the symbols generated from the archive (pl_sound_data.naix), so nothing else
changes. Running it again changes nothing.

Usage: python3 tools/audio/relayout_sound_banks.py
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import cjson_format  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PATH = os.path.join(ROOT, "decomp", "res", "sound", "pl_sound_data.json")
SKY_OLD, SKY_NEW = 494, 1050
SHIFT_FROM, SHIFT_BY = 700, 400


def relayout(entries):
    if len(entries) > SKY_NEW and entries[SKY_NEW].get("name", "").endswith("_SKY"):
        return entries, False
    out = [{"name": ""} for _ in range(len(entries) + SHIFT_BY)]
    for i, e in enumerate(entries):
        if not e.get("name"):
            continue
        if i == SKY_OLD:
            j = SKY_NEW
        elif i >= SHIFT_FROM:
            j = i + SHIFT_BY
        elif i < SKY_OLD:
            j = i
        else:
            raise SystemExit(f"unexpected entry at {i}: {e['name']}")
        out[j] = e
    return out, True


def main():
    text = open(PATH, encoding="utf-8").read()
    d = json.loads(text)
    changed = False
    for key in ("bankInfo", "wavarcInfo"):
        d[key], c = relayout(d[key])
        changed |= c
    if changed:
        with open(PATH, "w", encoding="utf-8") as f:
            f.write(cjson_format.dumps(d))
    print("relaid out" if changed else "already relaid out", "-", len(d["bankInfo"]), "banks")


if __name__ == "__main__":
    main()
