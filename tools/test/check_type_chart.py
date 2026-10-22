#!/usr/bin/env python3
"""Check the engine's type charts against the official (Gen VI+) chart from PokeAPI.

Parses sTypeMatchupMultipliers in decomp/src/battle/battle_lib.c and sMoveTesterTypeChart in
decomp/src/applications/poketch/move_tester/main.c, and compares all 18x18 matchups with
PokeAPI's type_efficacy.csv.

Usage: python3 tools/test/check_type_chart.py /path/to/pokeapi/data/v2/csv [decomp_dir]
"""
import csv
import os
import re
import sys

TYPES = ["NORMAL", "FIGHTING", "FLYING", "POISON", "GROUND", "ROCK", "BUG", "GHOST", "STEEL", "FAIRY",
         "FIRE", "WATER", "GRASS", "ELECTRIC", "PSYCHIC", "ICE", "DRAGON", "DARK"]
MULT = {"TYPE_MULTI_SUPER_EFF": 200, "TYPE_MULTI_NOT_VERY_EFF": 50, "TYPE_MULTI_IMMUNE": 0}
TESTER = {"______": 100, "X(2_0)": 200, "X(0_5)": 50, "X(0_0)": 0}


def official(csvdir):
    names = {r["type_id"]: r["name"].upper() for r in csv.DictReader(open(os.path.join(csvdir, "type_names.csv")))
             if r["local_language_id"] == "9"}
    chart = {}
    for r in csv.DictReader(open(os.path.join(csvdir, "type_efficacy.csv"))):
        a, d = names.get(r["damage_type_id"]), names.get(r["target_type_id"])
        if a in TYPES and d in TYPES:
            chart[(a, d)] = int(r["damage_factor"])
    return chart


def engine(decomp):
    src = open(os.path.join(decomp, "src/battle/battle_lib.c")).read()
    body = src[src.index("sTypeMatchupMultipliers[][3] = {"):]
    body = body[:body.index("};")]
    chart = {(a, d): 100 for a in TYPES for d in TYPES}
    for a, d, m in re.findall(r"\{ TYPE_(\w+), TYPE_(\w+), (TYPE_MULTI_\w+) \}", body):
        chart[(a, d)] = MULT[m]
    return chart


def tester(decomp):
    src = open(os.path.join(decomp, "src/applications/poketch/move_tester/main.c")).read()
    chart = {}
    for a, row in re.findall(r"\[TYPE_(\w+)\]\s*= \{ (.*?) \}", src):
        cells = [c.strip() for c in row.split(",")]
        if len(cells) == 18:
            for d, c in zip(TYPES, cells):
                chart[(a, d)] = TESTER[c]
    return chart


def main():
    csvdir = sys.argv[1]
    decomp = sys.argv[2] if len(sys.argv) > 2 else "decomp"
    want = official(csvdir)
    bad = 0
    for label, got in (("battle engine", engine(decomp)), ("Pokétch move tester", tester(decomp))):
        for k, v in sorted(want.items()):
            if got.get(k) != v:
                bad += 1
                print(f"{label}: {k[0]} -> {k[1]} is {got.get(k)}%, official {v}%")
    print("type charts match the official chart" if not bad else f"{bad} mismatches")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
