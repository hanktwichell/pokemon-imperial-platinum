#!/usr/bin/env python3
"""Render docs/EvolutionChanges_Sovereign.md from data/evolution_changes.yaml and data/species.csv.

Fails if any added species flagged gen4_engine_compatible=0 has no entry.
Usage: python3 tools/design/gen_evolution_doc.py
"""
import csv
import os
import sys

import yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def main():
    rows = list(csv.DictReader(open(os.path.join(ROOT, "data", "species.csv"), encoding="utf-8")))
    by = {r["name"]: r for r in rows}
    data = yaml.safe_load(open(os.path.join(ROOT, "data", "evolution_changes.yaml"), encoding="utf-8"))
    entries = data["changes"] + data.get("extra", [])
    covered = {e["species"] for e in entries}
    need = [r["name"] for r in rows if r["in_renegade"] == "0" and r["gen4_engine_compatible"] == "0"]
    missing = [n for n in need if n not in covered]
    unknown = [e["species"] for e in entries if e["species"] not in by]

    L = ["# Sovereign Platinum — Evolution Changes (added species)\n",
         "> Generated from `data/evolution_changes.yaml` by `tools/design/gen_evolution_doc.py`.\n",
         "Renegade Platinum's own evolution changes (`RenegadePlatinumV130/Documentation/EvolutionChanges.txt`) are unchanged. "
         "This document covers only species added in Sovereign Platinum whose official evolution method can't run on the "
         "Gen IV engine (trades, Gen V+ triggers, regional-form requirements, and so on). Every other added species evolves "
         "exactly as in its home game — see the `evolution_method` column of `data/species.csv`.\n",
         "| # | Species | Evolves from | Official method | Sovereign method | Why |",
         "|---|---|---|---|---|---|"]
    items = {}
    for e in entries:
        r = by.get(e["species"], {})
        L.append(f"| {r.get('dex', '?')} | {e['species']} | {e['from']} | {r.get('evolution_method', '')} | "
                 f"**{e['method']}** | {e['why']} |")
        for it in e.get("new_items", []):
            items[it] = e.get("where", "Snowpoint City evolution-item seller ($10,000)")
    L.append("")
    L.append("## New evolution items\n")
    L.append("These must be added to the item table (alongside the Mega Stones). All have a \"Use\" option like an "
             "evolution stone.\n")
    L.append("| Item | Where to get it |")
    L.append("|---|---|")
    for it, where in items.items():
        L.append(f"| {it} | {where} |")
    L.append("")
    with open(os.path.join(ROOT, "docs", "EvolutionChanges_Sovereign.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(L))
    for n in missing:
        print("MISSING", n)
    for n in unknown:
        print("UNKNOWN", n)
    print(f"{len(entries)} entries, {len(missing)} missing, {len(items)} new items")
    sys.exit(1 if missing or unknown else 0)


if __name__ == "__main__":
    main()
