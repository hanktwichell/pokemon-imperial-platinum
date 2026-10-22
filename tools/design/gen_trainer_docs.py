#!/usr/bin/env python3
"""Render data/trainers_sovereign.yaml to docs/TrainerPokemon_Sovereign.md and validate it.

Validation (needs --pokeapi, the PokeAPI data/v2/csv directory):
  * every move exists in Sovereign Platinum's move table: Gen IV moves (id <= 467) minus the
    moves Renegade Platinum removed, plus the moves Renegade added;
  * every move is learnable by the species in at least one official game (level-up, TM,
    tutor or egg). ROM learnsets can be edited, so this is a sanity check, not a hard rule;
  * every ability belongs to the species, or is a Renegade "(!)" ability listed in its notes;
  * Mega holders carry the right stone, and each trainer has at most one Mega;
  * Cynthia's singles teams never use Protect/Detect (owner requirement).

Usage: python3 tools/design/gen_trainer_docs.py [--pokeapi PATH]
Exit code is 1 when validation finds errors.
"""
import argparse
import csv
import os
import sys
from collections import defaultdict

import yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
EN = "9"
RENEGADE_REMOVED = {"Barrage", "Brine", "Constrict", "Horn Drill", "Lunar Dance", "Luster Purge", "Mist Ball",
                    "Sand Tomb", "Submission", "Twister", "Volt Tackle"}
RENEGADE_ADDED = {"Draining Kiss", "Scald", "Icicle Crash", "Drill Run", "Moonblast", "Dazzling Gleam",
                  "Disarming Voice", "Bulldoze", "Play Rough", "Hurricane", "Wild Charge"}
# Abilities Renegade Platinum gives species that don't normally have them ("(!)" in its docs).
RENEGADE_ABILITIES = {("Sableye", "Magic Guard"), ("Lucario", "Adaptability"), ("Weavile", "Technician"),
                      ("Froslass", "Levitate"), ("Houndoom", "Intimidate"), ("Vespiquen", "Intimidate"),
                      ("Metagross", "Iron Fist"), ("Flygon", "Compound Eyes"), ("Lopunny", "Scrappy"),
                      ("Charizard", "Drought"), ("Magcargo", "Solid Rock"), ("Dragonite", "Marvel Scale"),
                      ("Pidgeot", "No Guard"), ("Cranidos", "Rock Head")}
FORM_POKEMON = {"Rotom-Wash": "rotom-wash", "Rotom-Heat": "rotom-heat"}
RENEGADE_TRAINERS = os.path.join(ROOT, "RenegadePlatinumV130", "Documentation", "TrainerPokemon.txt")


def renegade_pairs():
    """(species, move) and (species, ability) pairs used by Renegade's own documented sets.

    Renegade edited learnsets and abilities; anything its trainers use is legal in its engine.
    Lines look like: "Gengar (Lv. 32) @ Wise Glasses / Naive / Levitate / Shadow Ball, ...".
    """
    moves, abilities = set(), set()
    for line in open(RENEGADE_TRAINERS, encoding="utf-8-sig"):
        if " @ " not in line or "/" not in line:
            continue
        head, _, rest = line.partition(" @ ")
        sp = head.split(" (Lv.")[0].strip()
        parts = [x.strip() for x in rest.split("/")]
        if len(parts) < 4:
            continue
        abilities.add((sp, parts[2].replace("(!)", "").strip()))
        for mv in parts[3].split("(!)")[0].split(","):
            moves.add((sp, mv.strip()))
    return moves, abilities


def load_pokeapi(d):
    def rd(n):
        with open(os.path.join(d, n), newline="", encoding="utf-8") as f:
            return list(csv.DictReader(f))
    move_name = {r["move_id"]: r["name"] for r in rd("move_names.csv") if r["local_language_id"] == EN}
    ab_name = {r["ability_id"]: r["name"] for r in rd("ability_names.csv") if r["local_language_id"] == EN}
    sp_name = {r["pokemon_species_id"]: r["name"] for r in rd("pokemon_species_names.csv") if r["local_language_id"] == EN}
    pokemon = rd("pokemon.csv")
    pid_by_ident = {p["identifier"]: p["id"] for p in pokemon}
    default_pid = {sp_name[p["species_id"]]: p["id"] for p in pokemon if p["is_default"] == "1" and p["species_id"] in sp_name}
    species_of_pid = {p["id"]: p["species_id"] for p in pokemon}
    learn = defaultdict(set)
    for r in rd("pokemon_moves.csv"):
        learn[r["pokemon_id"]].add(move_name.get(r["move_id"], "?"))
    abilities = defaultdict(set)
    for r in rd("pokemon_abilities.csv"):
        abilities[r["pokemon_id"]].add(ab_name.get(r["ability_id"], "?"))
    engine_moves = {n for i, n in move_name.items() if int(i) <= 467 and n not in RENEGADE_REMOVED} | RENEGADE_ADDED
    # Learnsets of pre-evolutions count (egg/level moves carried over).
    pre = {}
    for r in rd("pokemon_species.csv"):
        if r["evolves_from_species_id"]:
            pre[r["id"]] = r["evolves_from_species_id"]
    def learnable(name):
        pid = pid_by_ident.get(FORM_POKEMON.get(name, ""), default_pid.get(name))
        out = set(learn[pid]) | set(learn[default_pid.get(name.split("-")[0], pid)])
        sid = species_of_pid.get(pid)
        while sid in pre:
            sid = pre[sid]
            out |= learn[default_pid.get(sp_name[sid])]
        return out
    def abil(name):
        pid = pid_by_ident.get(FORM_POKEMON.get(name, ""), default_pid.get(name))
        return abilities[pid]
    return engine_moves, learnable, abil


def iter_teams(data):
    for t in data["story"]:
        yield t["trainer"], t.get("location", ""), t.get("format", "singles"), t["team"]
    for t in data["league"]:
        for fmt in ("singles", "doubles"):
            if fmt in t:
                yield f"{t['trainer']} (Round {t['round']})", "Pokémon League", fmt, t[fmt]


def validate(data, megas, pokeapi):
    errors, warnings = [], []
    engine_moves, learnable, abil = load_pokeapi(pokeapi) if pokeapi else (None, None, None)
    stone_of = {m["form"]: m["trigger_item"] for m in megas}
    rg_moves, rg_abilities = renegade_pairs()
    for trainer, loc, fmt, team in iter_teams(data):
        owners = defaultdict(int)
        for mon in team:
            sp = mon["species"]
            tag = f"{trainer} / {loc} / {fmt} / {sp}"
            if len(mon["moves"]) != 4 or len(set(mon["moves"])) != 4:
                errors.append(f"{tag}: needs 4 distinct moves")
            evs = [int(x) for x in str(mon["evs"]).split("/")]
            if len(evs) != 6 or sum(evs) > 510 or max(evs) > 252:
                errors.append(f"{tag}: bad EV spread {mon['evs']}")
            if "mega" in mon:
                owners[mon.get("owner", trainer)] += 1
                if stone_of.get(mon["mega"]) != mon["item"]:
                    errors.append(f"{tag}: {mon['mega']} needs {stone_of.get(mon['mega'])}, holds {mon['item']}")
            if trainer.startswith("Champion Cynthia") and fmt == "singles":
                if {"Protect", "Detect"} & set(mon["moves"]):
                    errors.append(f"{tag}: Cynthia singles must not use Protect")
            if engine_moves:
                for mv in mon["moves"]:
                    if mv not in engine_moves:
                        errors.append(f"{tag}: move '{mv}' does not exist in the Sovereign engine")
                    elif mv not in learnable(sp) and mv not in RENEGADE_ADDED and (sp, mv) not in rg_moves:
                        warnings.append(f"{tag}: '{mv}' not learnable in any official game (needs a learnset edit)")
                if mon["ability"] not in abil(sp) and (sp, mon["ability"]) not in RENEGADE_ABILITIES | rg_abilities:
                    errors.append(f"{tag}: ability '{mon['ability']}' invalid for {sp}")
        for o, n in owners.items():
            if n > 1:
                errors.append(f"{trainer} / {loc}: {o} has {n} Megas (max 1)")
    return errors, warnings


def render(data, megas):
    mega = {m["form"]: m for m in megas}
    L = ["# Sovereign Platinum — Trainer Pokémon (bosses)\n",
         "> Generated from `data/trainers_sovereign.yaml` by `tools/design/gen_trainer_docs.py`. Edit the YAML, not this file.\n",
         "## General changes\n",
         "- Every trainer not listed here keeps its Renegade Platinum v1.3.0 team (`RenegadePlatinumV130/Documentation/TrainerPokemon.txt`).",
         "- No opponent Mega Evolves before **Commander Jupiter** in the Team Galactic Eterna Building. From then on every Gym Leader, "
         "Elite Four member, Galactic Commander/Boss and the Champion has a Mega. (Saturn's first Mega appears once Alakazam joins his team at Lake Valor.)",
         "- The player can Mega Evolve after beating **Fantina** (the Gym after Jupiter), who hands over the **Mega Ring**.",
         "- A trainer can Mega Evolve at most one Pokémon per battle. In multi/tag battles each opposing trainer may Mega Evolve once.",
         "- EVs, exact natures and 31 IVs need the trainer-data engine extension described in `TechnicalDesign.md`. Until that exists, natures/EVs are design intent only.",
         "- Mega abilities that do not exist in the Gen IV engine are flagged **⚙** — see `MegaEvolution.md` for the fallback each uses until the ability is implemented.",
         "- Renegade Platinum used one of four random teams for each Elite Four member and Cynthia in Round 1. Sovereign uses one fixed, "
         "optimised team per format (picked from Renegade's four and re-tuned), so the singles/doubles choice is meaningful.\n"]
    def table(team):
        out = ["| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |", "|---|---|---|---|---|---|---|"]
        for m in team:
            name = m["species"]
            ab = m["ability"]
            if "mega" in m:
                mg = mega[m["mega"]]
                gear = "" if mg["ability_in_gen4_engine"] == "1" else " ⚙"
                name = f"{m['species']} → **{m['mega']}** ({mg['types']})"
                ab = f"{m['ability']} → **{mg['ability']}**{gear}"
            owner = f" _({m['owner']})_" if "owner" in m else ""
            out.append(f"| {name}{owner} | {m['level']} | {m['item']} | {m['nature']} | {ab} | {', '.join(m['moves'])} | {m['evs']} |")
        return out
    L.append("## Story battles\n")
    for t in data["story"]:
        L.append(f"### {t['trainer']} — {t['location']}")
        L.append(f"_Format: {t.get('format', 'singles')}_" + (f" · {t['note']}" if t.get("note") else "") + "\n")
        L += table(t["team"]) + [""]
    L.append("## Pokémon League\n")
    L.append("See `EliteFourFormat.md` for how singles/doubles are chosen.\n")
    for t in data["league"]:
        L.append(f"### {t['trainer']} — Round {t['round']}" + (" (first challenge)" if t["round"] == 1 else " (rematches)"))
        if t.get("note"):
            L.append(f"_{t['note']}_\n")
        for fmt in ("singles", "doubles"):
            if fmt in t:
                L.append(f"**{fmt.capitalize()}**\n")
                L += table(t[fmt]) + [""]
    return "\n".join(L)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pokeapi", help="PokeAPI data/v2/csv directory (enables move/ability validation)")
    args = ap.parse_args()
    data = yaml.safe_load(open(os.path.join(ROOT, "data", "trainers_sovereign.yaml"), encoding="utf-8"))
    megas = list(csv.DictReader(open(os.path.join(ROOT, "data", "megas.csv"), encoding="utf-8")))
    errors, warnings = validate(data, megas, args.pokeapi)
    for w in warnings:
        print("WARN ", w)
    for e in errors:
        print("ERROR", e)
    with open(os.path.join(ROOT, "docs", "TrainerPokemon_Sovereign.md"), "w", encoding="utf-8") as f:
        f.write(render(data, megas))
    print(f"{len(errors)} errors, {len(warnings)} warnings")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
