#!/usr/bin/env python3
"""Platinum's own items under the later games' rules: the item data (item 11).

Writes, in place, in decomp/res/items/data/<stem>.json:
* naturalGiftPower: every Berry's Natural Gift power from Gen VI on (20 more than Gen IV's). PokeAPI keeps Gen IV's.
* effectParam of Figy, Wiki, Mago, Aguav and Iapapa Berries: 3, so they restore 1/3 of the max HP (Gen VIII+; Gen IV
  restored 1/8). The battle code eats them at 1/4 HP (Sovereign_PinchBerryHP in src/battle/battle_lib.c).

Usage: python3 tools/engine/platinum_item_updates.py
It is idempotent; running it twice changes nothing.
"""
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DATA_DIR = os.path.join(ROOT, "decomp", "res", "items", "data")

# Natural Gift power by Berry (Gen VI+; Bulbapedia, Showdown's data/items.ts).
NATURAL_GIFT = {
    80: ["aguav", "aspear", "babiri", "charti", "cheri", "chesto", "chilan", "chople", "coba", "colbur", "figy",
         "haban", "iapapa", "kasib", "kebia", "leppa", "lum", "mago", "occa", "oran", "passho", "payapa", "pecha",
         "persim", "rawst", "razz", "rindo", "shuca", "sitrus", "tanga", "wacan", "wiki", "yache"],
    90: ["bluk", "cornn", "grepa", "hondew", "kelpsy", "magost", "nanab", "nomel", "pamtre", "pinap", "pomeg",
         "qualot", "rabuta", "spelon", "tamato", "wepear"],
    100: ["apicot", "belue", "custap", "durin", "enigma", "ganlon", "jaboca", "lansat", "liechi", "micle", "petaya",
          "rowap", "salac", "starf", "watmel"],
}
# The Berries that restore 1/effectParam of the max HP and confuse a Pokémon that dislikes their flavour.
PINCH_BERRIES = ["figy", "wiki", "mago", "aguav", "iapapa"]
PINCH_BERRY_DIVISOR = 3


def update(stem, **fields):
    path = os.path.join(DATA_DIR, stem + "_berry.json")
    with open(path, encoding="utf-8") as f:
        raw = f.read()
    data = json.loads(raw)
    data.update(fields)
    out = json.dumps(data, indent=2, ensure_ascii=False) + ("\n" if raw.endswith("\n") else "")
    if out != raw:
        with open(path, "w", encoding="utf-8") as f:
            f.write(out)
        return True
    return False


def main():
    changed = 0
    for power, stems in NATURAL_GIFT.items():
        for stem in stems:
            changed += update(stem, naturalGiftPower=power)
    for stem in PINCH_BERRIES:
        changed += update(stem, effectParam=PINCH_BERRY_DIVISOR)
    print(f"items changed: {changed}")


if __name__ == "__main__":
    main()
