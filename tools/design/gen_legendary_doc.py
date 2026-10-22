#!/usr/bin/env python3
"""Render docs/PostgameLegendaries.md from data/postgame_legendaries.yaml.

Fails unless every added Legendary/Mythical/Ultra Beast/Paradox species is covered exactly once.
Usage: python3 tools/design/gen_legendary_doc.py
"""
import csv
import os
import sys
from collections import Counter

import yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def main():
    rows = list(csv.DictReader(open(os.path.join(ROOT, "data", "species.csv"), encoding="utf-8")))
    by = {r["name"]: r for r in rows}
    data = yaml.safe_load(open(os.path.join(ROOT, "data", "postgame_legendaries.yaml"), encoding="utf-8"))
    need = {r["name"] for r in rows if r["in_renegade"] == "0" and r["category"] != "regular"}
    seen = Counter(sp for q in data["quests"] for sp in q["species"])
    errors = [f"missing: {n}" for n in sorted(need - set(seen))]
    errors += [f"listed {c} times: {n}" for n, c in seen.items() if c > 1]
    errors += [f"not an added special species: {n}" for n in seen if n not in need]

    hub = data["hub"]
    L = ["# Imperial Platinum — Post-game Legendaries, Mythicals, Ultra Beasts & Paradox Pokémon\n",
         "> Generated from `data/postgame_legendaries.yaml` by `tools/design/gen_legendary_doc.py`.\n",
         "Renegade Platinum's own legendary events (Gen I–IV) are unchanged; see `RenegadePlatinumV130/Documentation/SpecialEvents.txt`.\n",
         "## How it works\n",
         f"- Everything below unlocks after becoming **Champion**.",
         f"- Quests are given by the **{hub['npc']}**. Chapters: {', '.join(hub['chapters'])}.",
         f"- {hub['note']}",
         "- Static encounters can be retried after fainting or fleeing, and have the normal shiny odds (Renegade behaviour).",
         "- New maps or rooms are marked _(new)_ and need map work in DSPRE.\n",
         f"Covers **{len(seen)}** species.\n"]
    chapter = None
    for q in data["quests"]:
        if q["chapter"] != chapter:
            chapter = q["chapter"]
            L.append(f"## {chapter}\n")
        nums = ", ".join(f"#{by[s]['dex']} {s}" for s in q["species"] if s in by)
        L.append(f"### {q['name']}")
        L.append(f"- **Pokémon:** {nums}")
        L.append(f"- **Level:** {q['level']}")
        L.append(f"- **Location:** {q['location']}")
        L.append(f"- **How:** {q['steps']}\n")
    with open(os.path.join(ROOT, "docs", "PostgameLegendaries.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(L))
    for e in errors:
        print("ERROR", e)
    print(f"{len(seen)} species covered, {len(errors)} errors")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
