#!/usr/bin/env python3
"""Put the Mega Stones from data/mega_stones.yaml ("field") into the overworld item balls they replace (milestone E8).

Each entry names a vanilla visible-item script in res/field/scripts/scripts_visible_items.s. The script keeps its
name (the yaml and docs/MegaEvolution.md refer to it); only the item it gives changes, with a comment naming the
item it replaced. Running it again rewrites the same lines.

Usage: python3 tools/engine/place_mega_stones.py
"""
import os
import re
import sys

import yaml

sys.path.insert(0, os.path.dirname(__file__))
from gen_items import DECOMP, ROOT, stem_of  # noqa: E402

SCRIPTS = os.path.join(DECOMP, "res", "field", "scripts", "scripts_visible_items.s")
ITEMS = os.path.join(DECOMP, "generated", "items.txt")


def main():
    field = yaml.safe_load(open(os.path.join(ROOT, "data", "mega_stones.yaml"), encoding="utf-8"))["field"]
    items = set(open(ITEMS, encoding="utf-8").read().split())
    text = open(SCRIPTS, encoding="utf-8").read()

    for entry in field:
        const = "ITEM_" + stem_of(entry["stone"]).upper()
        if const not in items:
            sys.exit(f"{entry['stone']}: {const} isn't in generated/items.txt")

        # The label, then its first "SetVar VAR_0x8008, <item>" line (with any comment this script added before).
        pattern = re.compile(r"(^%s:\n    SetVar VAR_0x8008, )ITEM_\w+( // .*)?$" % re.escape(entry["script"]), re.M)
        if not pattern.search(text):
            sys.exit(f"{entry['script']}: label or item line not found in {SCRIPTS}")

        comment = f" // Sovereign: {entry['stone']} (data/mega_stones.yaml), was {entry['replaces']}"
        text = pattern.sub(lambda m: m.group(1) + const + comment, text, count=1)

    open(SCRIPTS, "w", encoding="utf-8").write(text)
    print(f"{len(field)} Mega Stones placed")


if __name__ == "__main__":
    main()
