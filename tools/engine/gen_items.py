#!/usr/bin/env python3
"""Add Sovereign's new items to the decomp (milestone E7).

Reads data/items_sovereign.yaml (which items) and data/megas.csv (the Mega Stones), takes names, prices, fling power
and descriptions from PokeAPI, and writes for each new item:
  decomp/res/items/data/<stem>.json   item data in Platinum's format (see res/items/data/choice_band.json)
and appends the item constants to decomp/generated/items.txt (after ITEM_SECRET_KEY, before MAX_ITEMS).

First pass (E7 step 1): every new item uses the placeholder "none" icon, has no hold effect (HOLD_EFFECT_NONE) and,
apart from evolution items (ITEM_USE_FUNC_EVO_STONE), no field use. Battle effects, Mint/Ability Capsule use
functions, icons and shops come in later steps.

Running it again rewrites the generated files; the item list in items.txt is only extended once.

Usage: python3 tools/engine/gen_items.py /path/to/pokeapi/data/v2/csv
"""
import csv
import json
import os
import re
import sys
import textwrap

import yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
ITEMS_TXT = os.path.join(DECOMP, "generated", "items.txt")
DATA_DIR = os.path.join(DECOMP, "res", "items", "data")

NAME_LEN = 16       # the bag's name buffer holds 18 characters; what fits on screen is checked in game
DESC_WIDTH = 40     # Platinum's longest description line
DESC_LINES = 3
# Names over NAME_LEN characters, shortened (the owner can change these).
SHORT_NAMES = {
    "Unremarkable Teacup": "Unremark. Teacup",
    "Masterpiece Teacup": "Masterpc. Teacup",
    "Scroll of Darkness": "Darkness Scroll",
}
# Descriptions for items PokeAPI has no English text for.
DESCRIPTIONS = {
    "Booster Energy": "An item to be held by a Pokémon. It powers up the Protosynthesis or Quark Drive ability once.",
    "Ability Shield": "An item to be held by a Pokémon. It protects the holder's Ability from being changed or nullified.",
    "Clear Amulet": "An item to be held by a Pokémon. It stops other Pokémon from lowering the holder's stats.",
    "Mirror Herb": "An item to be held by a Pokémon. It copies one round of stat boosts an opponent gets.",
    "Punching Glove": "An item to be held by a Pokémon. It powers up punches and keeps them from making contact.",
    "Covert Cloak": "An item to be held by a Pokémon. It protects the holder from the added effects of moves.",
    "Loaded Dice": "An item to be held by a Pokémon. Its multistrike moves are more likely to hit many times.",
    "Fairy Feather": "An item to be held by a Pokémon. This feather boosts the power of Fairy-type moves.",
    "Teal Mask": "A mask worn by Ogerpon. When Ogerpon holds it, it takes on the Teal Mask form.",
    "Wellspring Mask": "A mask worn by Ogerpon. When Ogerpon holds it, it takes on the Wellspring Mask form.",
    "Hearthflame Mask": "A mask worn by Ogerpon. When Ogerpon holds it, it takes on the Hearthflame Mask form.",
    "Cornerstone Mask": "A mask worn by Ogerpon. When Ogerpon holds it, it takes on the Cornerstone Mask form.",
    "Adamant Crystal": "A large, glowing gem. When held by Dialga, it changes into its Origin Forme.",
    "Lustrous Globe": "A large, glowing orb. When held by Palkia, it changes into its Origin Forme.",
    "Griseous Core": "A large, glowing gem. When held by Giratina, it changes into its Origin Forme.",
    "Masterpiece Teacup": "A peculiar teacup that makes certain species of Pokémon evolve. A rare, genuine piece.",
    "Syrupy Apple": "A peculiar apple that makes certain species of Pokémon evolve. It is coated in sticky syrup.",
    "Unremarkable Teacup": "A peculiar teacup that makes certain species of Pokémon evolve. It looks like any other.",
    "Black Augurite": "A glassy black stone that makes certain species of Pokémon evolve.",
    "Peat Block": "A block of peat from deep in the earth. It makes certain species of Pokémon evolve.",
    "Auspicious Armor": "Armor that carries the wish for a child's happy growth. It makes certain Pokémon evolve.",
    "Malicious Armor": "Armor steeped in a grudge. It makes certain species of Pokémon evolve.",
    "Leader’s Crest": "A shard of a blade worn by a pack leader. It makes certain species of Pokémon evolve.",
    "Metal Alloy": "A peculiar metal of several layers. It makes certain species of Pokémon evolve.",
    "Scroll of Darkness": "An old scroll on the art of the dark. Kubfu that reads it evolves into Single Strike Urshifu.",
    "Scroll of Waters": "An old scroll on the art of water. Kubfu that reads it evolves into Rapid Strike Urshifu.",
}
PLURALS = {"Heavy-Duty Boots": "Heavy-Duty Boots", "Protective Pads": "Protective Pads", "Loaded Dice": "Loaded Dice",
           "Punching Glove": "Punching Gloves", "Utility Umbrella": "Utility Umbrellas", "Peat Block": "Peat Blocks",
           "DNA Splicers": "DNA Splicers", "Reins of Unity": "Reins of Unity"}


def rd(api, name):
    return list(csv.DictReader(open(os.path.join(api, name), encoding="utf-8")))


def stem_of(name):
    s = name.lower().replace("’", "").replace("'", "").replace("é", "e").replace(".", "")
    return re.sub(r"[^a-z0-9]+", "_", s).strip("_")


def wrap(text):
    # Platinum's character map has ’ but no ASCII apostrophe.
    text = " ".join(text.replace("\u00ad", "").replace("'", "’").split())
    for cut in range(len(text), 0, -1):
        part = text[:cut]
        if cut < len(text) and not part.endswith("."):
            continue
        lines = textwrap.wrap(part, DESC_WIDTH)
        if len(lines) <= DESC_LINES:
            return [l + "\n" for l in lines[:-1]] + [lines[-1]]
    return [text[:DESC_WIDTH]]


def item_lists(spec):
    def flat(o):
        if isinstance(o, list):
            for x in o:
                yield from flat(x)
        elif isinstance(o, dict):
            for v in o.values():
                yield from flat(v)
        elif isinstance(o, str):
            yield o
    groups = {
        "key": list(flat(spec["key_items"])) + ["Scroll of Darkness", "Scroll of Waters"],
        "evolution": [n for n in flat(spec["evolution_items"]) if not n.startswith("Scroll")] + ["Strawberry Sweet"],
    }
    order = []
    for k in ("held_items", "gems", "form_items", "evolution_items", "training", "key_items"):
        for n in flat(spec[k]):
            if n not in order:
                order.append(n)
    return order, groups


def main():
    api = sys.argv[1]
    spec = yaml.safe_load(open(os.path.join(ROOT, "data", "items_sovereign.yaml"), encoding="utf-8"))
    order, groups = item_lists(spec)
    megas = []
    for r in csv.DictReader(open(os.path.join(ROOT, "data", "megas.csv"), encoding="utf-8")):
        t = r["trigger_item"]
        if t not in ("Blue Orb", "Red Orb") and "move" not in t and t not in megas:
            megas.append(t)

    names = {r["item_id"]: r["name"] for r in rd(api, "item_names.csv") if r["local_language_id"] == "9"}
    by_name = {v: k for k, v in names.items()}
    items = {r["id"]: r for r in rd(api, "items.csv")}
    flavor = {}
    for r in rd(api, "item_flavor_text.csv"):
        if r["language_id"] == "9":
            flavor.setdefault(r["item_id"], {})[int(r["version_group_id"])] = r["flavor_text"]

    consts = [l.strip() for l in open(ITEMS_TXT) if l.strip()]
    existing = set(consts[:consts.index("ITEM_SECRET_KEY") + 1])  # Platinum's own items
    new_consts = []
    missing = []
    for name in order + megas:
        display = SHORT_NAMES.get(name, name).replace("'", "’")
        if len(display) > NAME_LEN:
            raise SystemExit(f"{name}: name over {NAME_LEN} characters, add it to SHORT_NAMES")
        stem = stem_of(name)
        const = "ITEM_" + stem.upper()
        if const in existing:
            raise SystemExit(f"{const} already exists in items.txt")
        iid = by_name.get(name)
        row = items.get(iid, {})
        texts = flavor.get(iid, {})
        if texts:
            desc = wrap(texts[max(texts)])
        elif name in megas:
            desc = wrap("One of a variety of mysterious Mega Stones. It lets its holder Mega Evolve in battle.")
        elif name in DESCRIPTIONS:
            desc = wrap(DESCRIPTIONS[name])
        else:
            missing.append(name)
            desc = ["?"]
        is_key = name in groups["key"]
        evo = name in groups["evolution"] or name.startswith("Scroll")
        data = {
            "name": display,
            "plural": PLURALS.get(name, display if display.endswith("s") else display + "s"),
            "article": "an" if display[0] in "AEIOU" else "a",
            "description": desc,
            "icon": {"sprite": "none_NCGR", "palette": "none_NCLR"},
            "gbaID": "GBA_ITEM_NONE",
            "price": int(row.get("cost") or 0),
            "effectParam": 0,
            "holdEffect": "HOLD_EFFECT_NONE",
            "pluckEffect": "PLUCK_EFFECT_NONE",
            "flingEffect": "FLING_EFFECT_NONE",
            "flingPower": int(row.get("fling_power") or 0),
            "naturalGiftPower": 0,
            "naturalGiftType": None,
            "preventToss": is_key,
            "canRegister": False,
            "fieldPocket": "POCKET_KEY_ITEMS" if is_key else "POCKET_ITEMS",
            "battlePocket": "BATTLE_POCKET_MASK_NONE",
            "fieldUseFunc": "ITEM_USE_FUNC_EVO_STONE" if evo else "ITEM_USE_FUNC_NONE",
            "battleUseCategory": "BATTLE_USE_CATEGORY_NONE",
            "itemUseParams": {} if evo else None,
        }
        with open(os.path.join(DATA_DIR, stem + ".json"), "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.write("\n")
        new_consts.append(const)

    if missing:
        raise SystemExit(f"no description in PokeAPI (add to DESCRIPTIONS): {missing}")
    if new_consts[0] not in consts:
        i = consts.index("MAX_ITEMS")
        consts = consts[:i] + new_consts + consts[i:]
        with open(ITEMS_TXT, "w") as f:
            f.write("\n".join(consts) + "\n")
    print(f"items written: {len(new_consts)} (last item ID {consts.index(new_consts[-1])})")


if __name__ == "__main__":
    main()
