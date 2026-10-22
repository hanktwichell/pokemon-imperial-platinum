#!/usr/bin/env python3
"""Update Platinum's species (#1-493 and their forms) to Gen IX data (milestone E5).

For each decomp/res/pokemon/<species>[/forms/<form>]/data.json:
* base stats and types: Gen IX (includes the Gen VI Fairy retypes);
* level-up learnset and egg moves: from the newest games that have the species, in order Scarlet/Violet (+ DLC),
  Sword/Shield (+ DLC), Brilliant Diamond/Shining Pearl, Ultra Sun/Ultra Moon. Legends: Arceus and later spin-offs are
  skipped (different move systems). Moves learned on evolution (level 0) are placed at level 1;
* TM/HM and move-tutor compatibility: Platinum's compatibility plus every TM/tutor move the species can learn in those
  games, so nothing Platinum allowed is removed.
* abilities: Gen IX ability 1, ability 2 and hidden ability (milestones E2/E4).
Base EXP, EV yields, catch rate, growth rate and egg groups are left alone.
Writes docs/SpeciesGen9Changes.md.

Usage: python3 tools/engine/gen_species_gen9.py /path/to/pokeapi/data/v2/csv
"""
import csv
import glob
import json
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
POKEMON = os.path.join(DECOMP, "res", "pokemon")
MAX_LEVEL_ENTRIES = 48  # MAX_LEARNSET_ENTRIES in include/struct_defs/species.h
# Version-group families, newest first; within a family the base game is tried before its DLC.
FAMILIES = [("Scarlet/Violet", [25, 26, 27]), ("Sword/Shield", [20, 21, 22]), ("BDSP", [23]), ("USUM", [18]), ("SM", [17])]
FORMS = {("rotom", "wash"): "rotom-wash", ("rotom", "frost"): "rotom-frost", ("rotom", "fan"): "rotom-fan",
         ("rotom", "heat"): "rotom-heat", ("rotom", "mow"): "rotom-mow", ("giratina", "origin"): "giratina-origin",
         ("deoxys", "attack"): "deoxys-attack", ("deoxys", "defense"): "deoxys-defense",
         ("deoxys", "speed"): "deoxys-speed", ("wormadam", "sandy"): "wormadam-sandy",
         ("wormadam", "trash"): "wormadam-trash", ("shaymin", "sky"): "shaymin-sky"}
STATS = {"1": "hp", "2": "attack", "3": "defense", "4": "special_attack", "5": "special_defense", "6": "speed"}


def rd(api, name):
    with open(os.path.join(api, name), newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def _block(text, key):
    """(start, end) of a top-level `"key": {...}` block (indent 4), end just past its closing brace."""
    start = text.index(f'\n    "{key}": {{') + 1
    end = text.index("\n    }", start) + len("\n    }")
    return start, end


def write_sections(path, d):
    """Rewrite only base_stats, types and learnset in the decomp's own layout; the rest of the file is untouched."""
    text = open(path, encoding="utf-8").read()
    bs = d["base_stats"]
    stats = ",\n".join(f'        "{k}": {bs[k]}' for k in bs)
    s, e = _block(text, "base_stats")
    text = text[:s] + '    "base_stats": {\n' + stats + "\n    }" + text[e:]
    text = re.sub(r'"types": \[[^\]]*\]', '"types": [ ' + ", ".join(f'"{t}"' for t in d["types"]) + " ]", text, count=1)
    text = re.sub(r'"abilities": \[[^\]]*\]', '"abilities": [ ' + ", ".join(f'"{a}"' for a in d["abilities"]) + " ]", text, count=1)
    ls = d["learnset"]
    parts = ['        "by_level": [\n' + ",\n".join(f'            [ {lvl}, "{mv}" ]' for lvl, mv in ls["by_level"]) + "\n        ]"]
    for key in ("by_tm", "by_tutor", "egg_moves"):
        if key in ls:
            items = ls[key]
            body = ("\n" + ",\n".join(f'            "{x}"' for x in items) + "\n        ") if items else "  "
            if len(items) == 1:
                body = f' "{items[0]}" '
            parts.append(f'        "{key}": [{body}]')
    s, e = _block(text, "learnset")
    text = text[:s] + '    "learnset": {\n' + ",\n".join(parts) + "\n    }" + text[e:]
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


def load_context(api):
    """PokeAPI tables and decomp lists shared by the species generators (also used by gen_new_species.py)."""
    ctx = {}
    move_consts = [l.strip() for l in open(os.path.join(DECOMP, "generated", "moves.txt")) if l.strip().startswith("MOVE_")]
    ctx["move_ok"] = {i: c for i, c in enumerate(move_consts) if i and not c.startswith("MOVE_UNUSED_")}
    ctx["poke"] = {r["identifier"]: r for r in rd(api, "pokemon.csv")}
    types = {r["id"]: "TYPE_" + r["identifier"].upper() for r in rd(api, "types.csv")}
    stats, ptypes = defaultdict(dict), defaultdict(dict)
    for r in rd(api, "pokemon_stats.csv"):
        if r["stat_id"] in STATS:
            stats[r["pokemon_id"]][STATS[r["stat_id"]]] = int(r["base_stat"])
    for r in rd(api, "pokemon_types.csv"):
        ptypes[r["pokemon_id"]][int(r["slot"])] = types[r["type_id"]]
    ctx["stats"], ctx["ptypes"] = stats, ptypes
    learn = defaultdict(lambda: defaultdict(list))  # pokemon_id -> vg -> [(method, level, order, move)]
    for r in rd(api, "pokemon_moves.csv"):
        learn[r["pokemon_id"]][int(r["version_group_id"])].append(
            (r["pokemon_move_method_id"], int(r["level"] or 0), int(r["order"] or 0), int(r["move_id"])))
    ctx["learn"] = learn
    ctx["evolves_from"] = {r["id"]: r["evolves_from_species_id"] for r in rd(api, "pokemon_species.csv")}
    ability_consts = [l.strip() for l in open(os.path.join(DECOMP, "generated", "abilities.txt")) if l.strip()]
    pabilities = defaultdict(dict)
    for r in rd(api, "pokemon_abilities.csv"):
        pabilities[r["pokemon_id"]][int(r["slot"])] = ability_consts[int(r["ability_id"])]
    ctx["pabilities"] = pabilities
    tm_moves = {}
    for kind, n in (("TM", 92), ("HM", 8)):
        for i in range(1, n + 1):
            d = json.load(open(os.path.join(DECOMP, "res", "items", "data", f"{kind.lower()}{i:02d}.json")))
            tm_moves[f"{kind}{i:02d}"] = d["teachesMove"]
    ctx["tm_moves"] = tm_moves
    ctx["tutor_moves"] = [t["move"] for t in json.load(open(os.path.join(POKEMON, "move_tutors.json")))]
    return ctx


def build_learnset(ctx, pid, old_tm=(), old_tutor=(), want_eggs=True):
    """Gen IX learnset for PokeAPI pokemon id `pid`. Returns (family name, level-up list, TMs, tutor moves, egg moves).
    TM/tutor compatibility keeps whatever is in old_tm/old_tutor (Platinum's) and adds what the newest games allow."""
    learn, move_ok = ctx["learn"], ctx["move_ok"]
    fam_name, groups = next(((n, g) for n, g in FAMILIES if any(learn[pid][v] for v in g)), (None, []))
    lv_group = next((v for v in groups if any(m == "1" for m, *_ in learn[pid][v])), None)
    level, seen = [], set()
    for m, lvl, order, mv in sorted((x for x in learn[pid].get(lv_group, []) if x[0] == "1"), key=lambda x: (x[1], x[2])):
        if mv in move_ok and mv not in seen:
            seen.add(mv)
            level.append([max(1, lvl), move_ok[mv]])
    level = level[:MAX_LEVEL_ENTRIES]
    learnable = {move_ok[mv] for v in groups for (m, _, _, mv) in learn[pid][v] if mv in move_ok}
    tms = sorted(set(old_tm) | {tm for tm, mv in ctx["tm_moves"].items() if mv in learnable},
                 key=lambda x: (x[:2] == "HM", int(x[2:])))
    tutor = [m for m in ctx["tutor_moves"] if m in set(old_tutor) or m in learnable]
    eggs = []
    if want_eggs:
        for v in groups:
            for m, _, _, mv in learn[pid][v]:
                if m == "2" and mv in move_ok and move_ok[mv] not in eggs:
                    eggs.append(move_ok[mv])
    return fam_name, level, tms, tutor, eggs


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    api = sys.argv[1]
    ctx = load_context(api)
    species_consts = [l.strip() for l in open(os.path.join(DECOMP, "generated", "species.txt")) if l.strip().startswith("SPECIES_")]
    poke, stats, ptypes, pabilities, evolves_from = ctx["poke"], ctx["stats"], ctx["ptypes"], ctx["pabilities"], ctx["evolves_from"]

    targets = []
    for dex in range(1, 494):
        folder = species_consts[dex][8:].lower()
        targets.append((dex, folder, None, str(dex)))
    for path in sorted(glob.glob(os.path.join(POKEMON, "*", "forms", "*", "data.json"))):
        sp, _, form = path[len(POKEMON) + 1:].split(os.sep)[:3]
        if (sp, form) in FORMS:
            targets.append((None, sp, form, poke[FORMS[(sp, form)]]["id"]))

    report, max_entries, sources = [], 0, defaultdict(int)
    for dex, folder, form, pid in targets:
        path = os.path.join(POKEMON, folder, *(["forms", form] if form else []), "data.json")
        d = json.load(open(path, encoding="utf-8"))
        before = (dict(d["base_stats"]), list(d["types"]))
        d["base_stats"] = {k: stats[pid][k] for k in ("hp", "attack", "defense", "speed", "special_attack", "special_defense")}
        t = ptypes[pid]
        d["types"] = [t[1], t.get(2, t[1])]
        old_abilities = list(d["abilities"])
        a = pabilities[pid]
        d["abilities"] = [a[1], a.get(2, "ABILITY_NONE"), a.get(3, "ABILITY_NONE")]

        ls = d["learnset"]
        old_level = [m for _, m in ls["by_level"]]
        old_tm = set(ls.get("by_tm", []))
        fam_name, level, tms, tutor, eggs = build_learnset(
            ctx, pid, old_tm, ls.get("by_tutor", []), want_eggs=not form and not evolves_from.get(str(dex)))
        sources[fam_name] += 1
        max_entries = max(max_entries, len(level))
        ls["by_level"] = level if level else ls["by_level"]
        ls["by_tm"] = tms
        ls["by_tutor"] = tutor
        if eggs:
            ls["egg_moves"] = eggs
        write_sections(path, d)
        name = folder + (f" ({form})" if form else "")
        changes = []
        if before[0] != d["base_stats"]:
            changes.append("stats " + ", ".join(f"{k} {before[0][k]}→{d['base_stats'][k]}" for k in d["base_stats"] if before[0][k] != d["base_stats"][k]))
        if before[1] != d["types"]:
            changes.append(f"types {'/'.join(x[5:].title() for x in before[1])}→{'/'.join(x[5:].title() for x in d['types'])}")
        if old_abilities[:2] != d["abilities"][:2]:
            changes.append("abilities " + "/".join(x[8:].title() for x in old_abilities[:2] if x != "ABILITY_NONE") + "→" + "/".join(x[8:].title() for x in d["abilities"][:2] if x != "ABILITY_NONE"))
        if d["abilities"][2] != "ABILITY_NONE":
            changes.append("hidden ability " + d["abilities"][2][8:].title())
        new_moves = [m for _, m in level if m not in old_level]
        report.append((dex or "", name, fam_name or "—", len(level), len(new_moves), len(ls["by_tm"]) - len(old_tm), "; ".join(changes)))

    L = ["# Sovereign Platinum — Gen IX species data (#1–493)", "",
         "> Generated by `tools/engine/gen_species_gen9.py` from PokeAPI. Edit the generator, not this file.", "",
         "Base stats and types are Gen IX. Level-up moves come from the newest game that has the species (column "
         "*Learnset from*); egg moves likewise; TM/HM and tutor compatibility is Platinum's plus everything learnable "
         "in those games. Abilities are Gen IX: ability 1 / ability 2 / hidden ability.", "",
         "| # | Species | Learnset from | Level-up moves | New level-up moves | TMs/HMs added | Stat / type changes |",
         "|---|---|---|---|---|---|---|"]
    L += ["| " + " | ".join(str(x) for x in row) + " |" for row in report]
    with open(os.path.join(ROOT, "docs", "SpeciesGen9Changes.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    print(f"species updated: {len(report)}; learnset sources: {dict(sources)}; longest level-up learnset: {max_entries}")


if __name__ == "__main__":
    main()
