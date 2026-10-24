#!/usr/bin/env python3
"""Write the Sovereign encounter plan into the decomp's wild encounter tables (E10/E11).

`data/encounters_sovereign.json` (from `tools/design/gen_encounters.py`) gives each area's species
slot by slot. The decomp's `res/field/encounters/encounters_*.json` hold Renegade Platinum's tables
(`import_renegade_wild.py`). This script sets each slot's species from the plan and leaves
everything else as Renegade has it: levels, rates, swarm and Poké Radar slots, Unown and Shellos
data. Areas the plan doesn't list (Solaceon Ruins, Turnback Cave's pillar rooms, the Lake Verity
of the opening, Ruin Maniac's cave) keep Renegade's tables, which are Platinum's there.

Grass slots 2 and 3 have morning (the base table), day and night variants; the other slots must be
the same at every time of day. Re-running is a no-op.

It also writes `decomp/include/data/sovereign_honey_trees.h`: each of the 21 Honey Trees gets its
area's own species, percentages and level, as in Renegade (which scripts them per route; Platinum
shares one table between every tree).

Usage: python3 tools/engine/gen_wild_encounters.py
"""
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PLAN = os.path.join(ROOT, "data", "encounters_sovereign.json")
ENC = os.path.join(ROOT, "decomp", "res", "field", "encounters")
SPECIES = os.path.join(ROOT, "decomp", "generated", "species.txt")
HONEY_OUT = os.path.join(ROOT, "decomp", "include", "data", "sovereign_honey_trees.h")

# Plan area (Renegade's WildPokemon.txt name) -> decomp encounter files (without "encounters_").
# Matched by comparing each file's species and levels in the patched Renegade ROM with the doc.
AREA_FILES = {
    "Twinleaf Town": ["twinleaf_town"],
    "Route 201": ["route_201"],
    "Lake Verity": ["lake_verity_low_water"],  # "lake_verity" is the opening's (Platinum's, unchanged)
    "Route 202": ["route_202"],
    "Route 204 ~ South": ["route_204_south"],
    "Ravaged Path": ["ravaged_path"],
    "Route 203": ["route_203"],
    "Oreburgh Gate ~ 1F": ["oreburgh_gate_1f"],
    "Oreburgh Gate ~ B1F": ["oreburgh_gate_b1f"],
    "Route 207": ["route_207"],
    "Oreburgh Mine ~ 1F": ["oreburgh_mine_b1f"],
    "Oreburgh Mine ~ B1F": ["oreburgh_mine_b2f"],
    "Route 204 ~ North": ["route_204_north"],
    "Valley Windworks": ["valley_windworks_outside"],
    "Route 205 ~ South": ["route_205_south"],
    "Eterna Forest": ["eterna_forest"],
    "Old Chateau (All Rooms)": ["old_chateau", "old_chateau_dining_area", "old_chateau_side_rooms",
                                "old_chateau_corridor", "old_chateau_back_west_room",
                                "old_chateau_back_middle_west_room", "old_chateau_back_middle_room",
                                "old_chateau_back_middle_east_room", "old_chateau_back_east_room"],
    "Route 205 ~ North": ["route_205_north"],
    "Eterna City": ["eterna_city"],
    "Route 211 ~ West": ["route_211_west"],
    "Mt. Coronet ~ Route 211 Entrance": ["mt_coronet_1f_north_room_1"],
    "Route 211 ~ East": ["route_211_east"],
    "Mt. Coronet ~ Tunnel to Route 211 Entrance": ["mt_coronet_1f_tunnel_room"],
    "Mt. Coronet ~ B1F": ["mt_coronet_b1f"],
    "Mt. Coronet ~ Route 216 Entrance": ["mt_coronet_1f_north_room_2"],
    "Route 216": ["route_216"],
    "Route 206": ["route_206"],
    "Wayward Cave (Both)": ["wayward_cave_1f", "wayward_cave_b1f"],
    "Mt. Coronet ~ Route 207 Entrance": ["mt_coronet_1f_south"],
    "Route 208": ["route_208"],
    "Route 212 ~ North": ["route_212_north"],
    "Trophy Garden": ["trophy_garden"],
    "Route 209": ["route_209"],
    "Lost Tower": ["route_209_lost_tower_1f", "route_209_lost_tower_2f", "route_209_lost_tower_3f",
                   "route_209_lost_tower_4f", "route_209_lost_tower_5f"],
    "Solaceon Ruins": [],  # Unown only: Platinum's rooms keep their tables (each room's Unown letters)
    "Route 210 ~ South": ["route_210_south"],
    "Route 215": ["route_215"],
    "Route 214": ["route_214"],
    "Maniac Tunnel": ["maniac_tunnel"],
    "Valor Lakefront": ["valor_lakefront"],
    "Route 213": ["route_213"],
    "Pastoria City": ["pastoria_city"],
    "Great Marsh ~ Area 1/2": ["great_marsh_1", "great_marsh_2"],
    "Great Marsh ~ Area 3/4": ["great_marsh_3", "great_marsh_4"],
    "Great Marsh ~ Area 5/6": ["great_marsh_5", "great_marsh_6"],
    "Route 212 ~ South": ["route_212_south"],
    "Route 210 ~ North": ["route_210_north"],
    "Celestic Town": ["celestic_town"],
    "Route 219": ["route_219"],
    "Route 220": ["route_220"],
    "Route 221": ["route_221"],
    "Fuego Ironworks": ["fuego_ironworks_outside"],
    "Route 218": ["route_218"],
    "Canalave City": ["canalave_city"],
    "Iron Island ~ Outside": ["iron_island"],
    "Iron Island ~ Inside ~ 1F, B1F": ["iron_island_1f", "iron_island_b1f_left_room", "iron_island_b1f_right_room"],
    "Iron Island ~ Inside ~ B2F, B3F": ["iron_island_b2f_left_room", "iron_island_b2f_right_room", "iron_island_b3f"],
    "Route 217": ["route_217"],
    "Acuity Lakefront": ["acuity_lakefront"],
    "Snowpoint Temple": ["snowpoint_temple_1f", "snowpoint_temple_b1f", "snowpoint_temple_b2f",
                         "snowpoint_temple_b3f", "snowpoint_temple_b4f", "snowpoint_temple_b5f"],
    "Lake Acuity": ["lake_acuity"],
    "Mt. Coronet ~ 2F": ["mt_coronet_2f"],
    "Mt. Coronet ~ 3F": ["mt_coronet_3f"],
    "Mt. Coronet ~ Snow Area": ["mt_coronet_outside_south"],
    "Mt. Coronet ~ 4F": ["mt_coronet_4f_rooms_1_and_2"],
    "Mt. Coronet ~ Summit": ["mt_coronet_outside_north"],
    "Mt. Coronet ~ 5F": ["mt_coronet_5f"],
    "Mt. Coronet ~ 6F": ["mt_coronet_6f"],
    "Mt. Coronet ~ 7F": ["mt_coronet_4f_room_3"],
    "Sendoff Spring": ["sendoff_spring"],
    "Lake Valor": ["lake_valor"],
    "Route 222": ["route_222"],
    "Sunyshore City": ["sunyshore_city"],
    "Route 223": ["route_223"],
    "Pokémon League": ["pokemon_league"],
    "Victory Road ~ 1F": ["victory_road_1f"],
    "Victory Road ~ 2F": ["victory_road_2f"],
    "Victory Road ~ B1F": ["victory_road_b1f"],
    "Victory Road ~ 1F Back 1": ["victory_road_1f_room_1"],
    "Victory Road ~ 1F Back 2": ["victory_road_1f_room_2"],
    "Victory Road ~ 1F Back 3": ["victory_road_1f_room_3"],
    "Route 224": ["route_224"],
    "Turnback Cave": ["turnback_cave_entrance", "turnback_cave_pillar_room"],
    "Route 225": ["route_225"],
    "Route 226": ["route_226"],
    "Route 227": ["route_227"],
    "Route 228": ["route_228"],
    "Route 229": ["route_229"],
    "Resort Area": ["resort_area"],
    "Route 230": ["route_230"],
    "Stark Mountain (Outside)": ["stark_mountain_outside"],
    "Stark Mountain (Entrance)": ["stark_mountain_room_1"],
    "Stark Mountain (Interior)": ["stark_mountain_room_2"],
}
# Honey Tree areas only (no encounter file of their own).
HONEY_ONLY = {"Floaroma Meadow", "Eterna Forest (Outside)"}

# The Honey Trees in Platinum's order (sHoneyTreeMapHeaderIDs, src/overlay005/honey_tree.c) -> plan area.
HONEY_TREES = [
    ("MAP_HEADER_ROUTE_205_SOUTH", "Route 205 ~ South"), ("MAP_HEADER_ROUTE_205_NORTH", "Route 205 ~ North"),
    ("MAP_HEADER_ROUTE_206", "Route 206"), ("MAP_HEADER_ROUTE_207", "Route 207"), ("MAP_HEADER_ROUTE_208", "Route 208"),
    ("MAP_HEADER_ROUTE_209", "Route 209"), ("MAP_HEADER_ROUTE_210_SOUTH", "Route 210 ~ South"),
    ("MAP_HEADER_ROUTE_210_NORTH", "Route 210 ~ North"), ("MAP_HEADER_ROUTE_211_EAST", "Route 211 ~ East"),
    ("MAP_HEADER_ROUTE_212_NORTH", "Route 212 ~ North"), ("MAP_HEADER_ROUTE_212_SOUTH", "Route 212 ~ South"),
    ("MAP_HEADER_ROUTE_213", "Route 213"), ("MAP_HEADER_ROUTE_214", "Route 214"), ("MAP_HEADER_ROUTE_215", "Route 215"),
    ("MAP_HEADER_ROUTE_218", "Route 218"), ("MAP_HEADER_ROUTE_221", "Route 221"), ("MAP_HEADER_ROUTE_222", "Route 222"),
    ("MAP_HEADER_VALLEY_WINDWORKS_OUTSIDE", "Valley Windworks"),
    ("MAP_HEADER_ETERNA_FOREST_OUTSIDE", "Eterna Forest (Outside)"),
    ("MAP_HEADER_FUEGO_IRONWORKS_OUTSIDE", "Fuego Ironworks"), ("MAP_HEADER_FLOAROMA_MEADOW", "Floaroma Meadow"),
]
HONEY_SLOTS = 8

WATER_KEYS = {"Surf": "surf_encounters", "Old Rod": "old_rod_encounters",
              "Good Rod": "good_rod_encounters", "Super Rod": "super_rod_encounters"}


def species_constant(name, known):
    c = name.upper().replace("♂", "_M").replace("♀", "_F").replace("É", "E")
    c = re.sub(r"[.'’:]", "", c)
    c = "SPECIES_" + re.sub(r"_+", "_", re.sub(r"[ \-]", "_", c)).strip("_")
    if c not in known:
        sys.exit(f"unknown species {name!r} ({c})")
    return c


def main():
    plan = json.load(open(PLAN, encoding="utf-8"))
    known = {l.strip() for l in open(SPECIES) if l.strip()}
    names = {a["name"] for a in plan["areas"]}
    missing = names - set(AREA_FILES) - HONEY_ONLY
    if missing or set(AREA_FILES) - names:
        sys.exit(f"area map out of date: unmapped {sorted(missing)}, stale {sorted(set(AREA_FILES) - names)}")

    changed = 0
    for area in plan["areas"]:
        for stem in AREA_FILES.get(area["name"], []):
            path = os.path.join(ENC, f"encounters_{stem}.json")
            old = json.load(open(path, encoding="utf-8"))
            d = json.loads(json.dumps(old))
            if area["grass"]:
                for i, slot in enumerate(area["grass"]):
                    sp = {t: species_constant(slot[t], known) for t in ("morning", "day", "night")}
                    d["land_encounters"][i]["species"] = sp["morning"]
                    if i in (2, 3):
                        d["day"][i - 2] = sp["day"]
                        d["night"][i - 2] = sp["night"]
                    elif len(set(sp.values())) != 1:
                        sys.exit(f"{area['name']} grass slot {i} varies by time of day: {slot}")
                    if d["land_encounters"][i]["level"] == 0:
                        sys.exit(f"{stem}: grass slot {i} has no level in Renegade's table")
            for kind, slots in area["water"].items():
                enc = d[WATER_KEYS[kind]]
                for i, name in enumerate(slots):
                    enc[i]["species"] = species_constant(name, known)
                    if enc[i]["level_max"] == 0:
                        sys.exit(f"{stem}: {kind} slot {i} has no level in Renegade's table")
            if d != old:
                changed += 1
                with open(path, "w", encoding="utf-8") as f:
                    json.dump(d, f, indent=4, ensure_ascii=False)
    print(f"wrote the encounter plan: {changed} encounter files changed")
    write_honey(plan, known)


def honey_level(levels):
    m = re.search(r"(\d+) \(Honey Tree\)|Honey Tree \((\d+)\)", levels)
    if not m:
        sys.exit(f"no Honey Tree level in {levels!r}")
    return int(m.group(1) or m.group(2))


def write_honey(plan, known):
    by_name = {a["name"]: a for a in plan["areas"]}
    rows = []
    for header, name in HONEY_TREES:
        area = by_name[name]
        slots = area["honey"]
        if not slots or len(slots) > HONEY_SLOTS or sum(p for _, p in slots) != 100:
            sys.exit(f"{name}: bad Honey Tree table {slots}")
        entries = ", ".join(f"{{ {species_constant(sp, known)}, {p} }}" for sp, p in slots)
        rows.append(f"    {{ {honey_level(area['levels'])}, {len(slots)}, {{ {entries} }} }}, // {header} ({name})")
    text = "\n".join([
        "// Generated by tools/engine/gen_wild_encounters.py from data/encounters_sovereign.json. Do not edit.",
        "#ifndef POKEPLATINUM_DATA_SOVEREIGN_HONEY_TREES_H",
        "#define POKEPLATINUM_DATA_SOVEREIGN_HONEY_TREES_H",
        "",
        '#include "generated/species.h"',
        "",
        "typedef struct SovereignHoneyTreeSlot {",
        "    u16 species;",
        "    u8 percent;",
        "} SovereignHoneyTreeSlot;",
        "",
        "// Indexed like sHoneyTreeMapHeaderIDs.",
        "static const struct {",
        "    u8 level;",
        "    u8 count;",
        f"    SovereignHoneyTreeSlot slots[{HONEY_SLOTS}];",
        "} sSovereignHoneyTrees[] = {",
        *rows,
        "};",
        "",
        "#endif // POKEPLATINUM_DATA_SOVEREIGN_HONEY_TREES_H",
        "",
    ])
    with open(HONEY_OUT, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"wrote {HONEY_OUT}: {len(rows)} Honey Trees")


if __name__ == "__main__":
    main()
