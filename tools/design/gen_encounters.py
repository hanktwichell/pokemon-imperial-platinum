#!/usr/bin/env python3
"""Generate Imperial Platinum's wild encounter plan.

Reads Renegade Platinum's WildPokemon.txt and data/species.csv, then re-slots every
encounter table so that each added (Gen V-IX) non-legendary species can be caught.

Constraints honoured:
  * Gen IV slot structure. Grass: 12 slots (20,20,10,10,10,10,5,5,4,4,1,1); slots 2-3
    have morning/day/night variants. Surf and each rod: 5 slots (60,30,5,4,1).
  * Every species catchable in Renegade Platinum stays catchable somewhere (a Renegade
    species is only removed from an area while it still appears in another area).
  * Poke Radar and Honey Tree tables are left exactly as Renegade has them.
  * Added species are only placed where the area's level band fits their evolution
    stage, and stronger species are given rarer slots.

Outputs:
  data/encounters_imperial.json
  docs/WildPokemon_Imperial.md

Usage: python3 tools/design/gen_encounters.py
"""
import csv
import json
import os
import re
from collections import defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
RENEGADE_WILD = os.path.join(ROOT, "RenegadePlatinumV130", "Documentation", "WildPokemon.txt")

GRASS_RATES = [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
WATER_RATES = [60, 30, 5, 4, 1]
ROD_LEVEL = {"Old Rod": 10, "Good Rod": 25, "Super Rod": 50}

# Habitat tags per area (prefix match on area name). Drives type affinity.
AREA_TAGS = [
    ("Twinleaf Town", "lake"), ("Route 201", "field"), ("Lake Verity", "lake"), ("Route 202", "field"),
    ("Route 204", "field forest"), ("Ravaged Path", "cave"), ("Route 203", "field"),
    ("Oreburgh Gate", "cave"), ("Route 207", "mountain"), ("Oreburgh Mine", "cave mine"),
    ("Valley Windworks", "electric field"), ("Floaroma Meadow", "flower"), ("Route 205 ~ South", "field river"),
    ("Eterna Forest", "forest"), ("Old Chateau", "ghost"), ("Route 205 ~ North", "forest river"),
    ("Eterna City", "city"), ("Route 211", "mountain"), ("Mt. Coronet ~ Route 211", "cave"),
    ("Mt. Coronet ~ Tunnel", "cave"), ("Mt. Coronet ~ B1F", "cave dragon"), ("Mt. Coronet ~ Route 216", "cave snow"),
    ("Route 216", "snow"), ("Route 206", "mountain city"), ("Wayward Cave", "cave dragon"),
    ("Mt. Coronet ~ Route 207", "cave"), ("Route 208", "field mountain"), ("Route 212 ~ North", "field rain"),
    ("Trophy Garden", "flower city"), ("Route 209", "field ghost"), ("Lost Tower", "ghost"),
    ("Solaceon Ruins", "ruins"), ("Route 210 ~ South", "field flower"), ("Route 215", "rain mountain"),
    ("Route 214", "mountain desert"), ("Maniac Tunnel", "cave ruins"), ("Valor Lakefront", "lake field"),
    ("Route 213", "sea beach"), ("Pastoria City", "marsh"), ("Great Marsh", "marsh"), ("Route 212 ~ South", "marsh rain"),
    ("Route 210 ~ North", "fog dragon"), ("Celestic Town", "ruins"), ("Route 221", "sea forest"),
    ("Fuego Ironworks", "electric fire"), ("Route 218", "sea"), ("Canalave City", "sea city"),
    ("Iron Island ~ Outside", "sea steel"), ("Iron Island", "cave steel"), ("Route 217", "snow"),
    ("Acuity Lakefront", "snow"), ("Snowpoint Temple", "snow ruins"), ("Lake Acuity", "snow lake"),
    ("Mt. Coronet ~ 2F", "cave"), ("Mt. Coronet ~ 3F", "cave"), ("Mt. Coronet ~ Snow Area", "snow mountain"),
    ("Mt. Coronet ~ 4F", "cave dragon"), ("Mt. Coronet ~ Summit", "peak dragon"), ("Mt. Coronet ~ 5F", "cave"),
    ("Mt. Coronet ~ 6F", "cave"), ("Mt. Coronet ~ 7F", "cave dragon"), ("Sendoff Spring", "ruins lake ghost"),
    ("Lake Valor", "lake"), ("Route 222", "beach electric"), ("Sunyshore City", "sea electric city"),
    ("Route 223", "sea"), ("Pokémon League", "sea city"), ("Victory Road", "cave dragon"), ("Route 224", "field flower sea"),
    ("Turnback Cave", "ghost cave"), ("Route 225", "mountain fighting"), ("Route 226", "sea mountain"),
    ("Route 227", "volcano"), ("Route 228", "desert"), ("Route 229", "forest"), ("Resort Area", "sea"),
    ("Route 230", "sea"), ("Stark Mountain", "volcano cave"),
]

# Type weights per habitat tag.
TAG_TYPES = {
    "field": {"Normal": 3, "Flying": 2, "Bug": 1, "Grass": 1, "Fighting": 1, "Electric": 1},
    "forest": {"Bug": 3, "Grass": 3, "Poison": 1, "Fairy": 1, "Normal": 1, "Dark": 1},
    "flower": {"Grass": 3, "Fairy": 3, "Bug": 2, "Normal": 1},
    "lake": {"Water": 3, "Psychic": 1, "Bug": 1, "Fairy": 1},
    "river": {"Water": 2, "Bug": 1, "Grass": 1},
    "cave": {"Rock": 3, "Ground": 3, "Steel": 1, "Dark": 1, "Poison": 1, "Fighting": 1, "Ghost": 1},
    "mine": {"Rock": 3, "Steel": 3, "Ground": 2},
    "mountain": {"Rock": 3, "Ground": 2, "Fighting": 2, "Flying": 1, "Fire": 1, "Steel": 1},
    "electric": {"Electric": 4, "Steel": 2},
    "ghost": {"Ghost": 4, "Dark": 2, "Psychic": 1},
    "city": {"Normal": 2, "Poison": 2, "Steel": 1, "Psychic": 1, "Dark": 1, "Electric": 1},
    "snow": {"Ice": 5, "Water": 1, "Steel": 1},
    "rain": {"Water": 2, "Grass": 2, "Bug": 1, "Poison": 1},
    "ruins": {"Psychic": 3, "Ghost": 2, "Rock": 1, "Steel": 1, "Fairy": 1},
    "desert": {"Ground": 4, "Rock": 2, "Fire": 1, "Dark": 1, "Bug": 1},
    "sea": {"Water": 4, "Flying": 2, "Ice": 1},
    "beach": {"Water": 3, "Ground": 1, "Rock": 1, "Flying": 1},
    "marsh": {"Water": 2, "Poison": 3, "Grass": 2, "Bug": 1, "Ground": 1},
    "fog": {"Dragon": 3, "Flying": 2, "Psychic": 1, "Ghost": 1, "Normal": 1},
    "dragon": {"Dragon": 3},
    "peak": {"Dragon": 3, "Flying": 3, "Psychic": 1, "Rock": 1},
    "steel": {"Steel": 4, "Fighting": 1, "Rock": 1},
    "fire": {"Fire": 4},
    "volcano": {"Fire": 4, "Rock": 2, "Ground": 2, "Dragon": 1},
    "fighting": {"Fighting": 3},
}

# Hand-tuned: species that should be fishing encounters rather than surfing/grass.
FISH = {"Basculin", "Alomomola", "Frillish", "Jellicent", "Finizen", "Palafin", "Wishiwashi", "Bruxish",
        "Arrokuda", "Barraskewda", "Dhelmise", "Dondozo", "Tatsugiri", "Veluza", "Clauncher",
        "Clawitzer", "Skrelp", "Dragalge", "Chewtle", "Drednaw", "Tynamo", "Eelektrik", "Eelektross",
        "Mareanie", "Toxapex", "Pyukumuku"}
# Water-types that should also be allowed in grass when the habitat fits.
AMPHIBIOUS_OK = {"Ground", "Grass", "Bug", "Fighting", "Rock", "Normal", "Electric", "Poison", "Dark", "Steel", "Fairy"}


def area_tags(name):
    best = ""
    for prefix, tags in AREA_TAGS:
        if name.startswith(prefix) and len(prefix) > len(best):
            best = prefix
            chosen = tags
    return chosen.split() if best else ["field"]


def parse_renegade(path):
    areas, cur = [], None
    lines = open(path, encoding="utf-8-sig").read().splitlines()
    for i, line in enumerate(lines):
        if line.startswith("Level") and i > 0 and lines[i - 1].strip():
            cur = {"name": lines[i - 1].strip(), "levels_line": line.strip(), "tables": {}}
            areas.append(cur)
            continue
        if cur is None:
            continue
        m = re.match(r"^(Morning|Day|Night|Poké Radar|Surf|Old Rod|Good Rod|Super Rod|Honey Tree)\s+(.*)$", line)
        if m:
            kind, rest = m.group(1), m.group(2).strip()
            entries = []
            if rest and rest != "-":
                for part in rest.split(", "):
                    mm = re.match(r"^(.*) \((\d+)%\)$", part.strip())
                    if mm:
                        entries.append((mm.group(1), int(mm.group(2))))
            cur["tables"][kind] = entries
    for a in areas:
        a["walk_levels"] = parse_levels(a["levels_line"], "Walking")
        a["surf_levels"] = parse_levels(a["levels_line"], "Surf")
    return areas


def parse_levels(line, kind):
    for seg in re.split(r",\s*", line.split(":", 1)[1]):
        if kind in seg:
            nums = [int(x) for x in re.findall(r"\d+", seg)]
            if nums:
                return (nums[0], nums[-1])
    return None


def load_species():
    rows = list(csv.DictReader(open(os.path.join(ROOT, "data", "species.csv"), encoding="utf-8")))
    by_name = {r["name"]: r for r in rows}
    return rows, by_name


def first_level(method):
    m = re.match(r"Level (\d+)", method or "")
    return int(m.group(1)) if m else None


def build_level_gates(rows, by_name):
    """Minimum sensible wild level for each species (based on how it evolves)."""
    gate = {}
    for r in sorted(rows, key=lambda r: int(r["stage"])):
        if int(r["stage"]) == 1:
            bst = int(r["bst"])
            if r["name"] in PSEUDO_BASES:
                gate[r["name"]] = 15
            elif bst >= 500:
                gate[r["name"]] = 35
            elif bst >= 450:
                gate[r["name"]] = 20
            else:
                gate[r["name"]] = 2
            continue
        parent_gate = gate.get(r["evolves_from"], 2)
        lvl = first_level(r["evolution_method"].split(" OR ")[0])
        if lvl:
            gate[r["name"]] = max(lvl, parent_gate)
        else:
            # Stone / friendship / special evolutions: mid-game for stage 2, late for stage 3.
            gate[r["name"]] = max(parent_gate + 8, 30 if int(r["stage"]) == 2 else 45)
    return gate


def rarity(r):
    """0 = common, 1 = uncommon, 2 = rare."""
    bst = int(r["bst"])
    if r["name"] in PSEUDO_BASES or r["name"] in PSEUDO_MIDS:
        return 2
    if r["is_final"] == "1" and r["stage"] == "1" and bst >= 500:
        return 1
    if bst >= 520:
        return 1
    return 0


# Gen V-IX starter lines are Pokémon Center gifts (as Renegade does for Kanto/Johto/Hoenn), not wild.
STARTER_BASES = {"Snivy", "Tepig", "Oshawott", "Chespin", "Fennekin", "Froakie", "Rowlet", "Litten", "Popplio",
                 "Grookey", "Scorbunny", "Sobble", "Sprigatito", "Fuecoco", "Quaxly"}

PSEUDO_BASES = {"Deino", "Axew", "Goomy", "Jangmo-o", "Dreepy", "Frigibax", "Larvesta", "Riolu"}
PSEUDO_MIDS = {"Zweilous", "Fraxure", "Sliggoo", "Hakamo-o", "Drakloak", "Arctibax"}


def main():
    rows, by_name = load_species()
    areas = parse_renegade(RENEGADE_WILD)
    gate = build_level_gates(rows, by_name)

    # Occurrence counts of Renegade species across all tables (radar/honey included, never edited).
    # Morning/Day/Night count as one grass table.
    occ = defaultdict(int)
    for a in areas:
        groups = defaultdict(set)
        for kind, entries in a["tables"].items():
            g = "grass" if kind in ("Morning", "Day", "Night") else kind
            groups[g].update(sp for sp, _ in entries)
        for sps in groups.values():
            for sp in sps:
                occ[sp] += 1

    plan = []
    grass_free, water_free = [], []  # (area_idx, table, slot, rarity_class)

    for ai, a in enumerate(areas):
        t = a["tables"]
        out = {"name": a["name"], "levels": a["levels_line"], "tags": area_tags(a["name"]), "grass": None,
               "water": {}, "radar": t.get("Poké Radar", []), "honey": t.get("Honey Tree", [])}
        if "Day" in t:
            out["grass"] = reslot_grass(t, occ)
            for si, slot in enumerate(out["grass"]):
                for var, times in FREE_VARIANTS[si].items():
                    if all(slot[k] is None for k in times):
                        grass_free.append((ai, "grass", si, var))
        for kind in ("Surf", "Old Rod", "Good Rod", "Super Rod"):
            if kind in t:
                out["water"][kind] = reslot_water(t[kind], occ)
                for si, sp in enumerate(out["water"][kind]):
                    if sp is None:
                        water_free.append((ai, kind, si, None))
        plan.append(out)

    # Species to place: every added regular species (legendaries etc. are post-game events).
    starter_families = {by_name[n]["family_id"] for n in STARTER_BASES}
    todo = [r for r in rows if r["in_renegade"] == "0" and r["category"] == "regular"
            and r["family_id"] not in starter_families]
    # Babies are hatched, not caught, in Renegade style - but still place them if a slot is spare.
    todo.sort(key=lambda r: (r["is_baby"] == "1", -rarity(r), int(r["stage"]), int(r["dex"])))

    def lvl_of(ai, table):
        a = areas[ai]
        if table == "grass":
            return a["walk_levels"]
        if table == "Surf":
            return a["surf_levels"]
        return (ROD_LEVEL[table], ROD_LEVEL[table])

    def score(r, ai, table, si):
        lv = lvl_of(ai, table)
        if not lv:
            return None
        g = gate[r["name"]]
        if lv[0] < g:
            return None
        # Don't place unevolved species far past their evolution level, except in water tables.
        types = r["types"].split("/")
        tags = plan[ai]["tags"]
        is_water = "Water" in types
        if table == "grass":
            if is_water and not (set(types) & AMPHIBIOUS_OK) and not set(tags) & {"marsh", "beach", "lake", "rain", "river"}:
                return None
            if r["name"] in FISH:
                return None
        elif r["name"] in FISH:
            if table == "Surf":
                return None
        else:
            if not is_water:
                return None
            if table != "Surf" and "Water" != types[0]:
                return None
        s = 0.0
        for tag in tags:
            for ty in types:
                s += TAG_TYPES.get(tag, {}).get(ty, 0)
        if table == "grass" and s == 0:
            return None
        if table != "grass" and r["name"] in FISH:
            s += 3
        # Level fit: prefer the earliest area that is legal (keeps progression natural).
        s -= (lv[0] - g) / 15.0
        # Rarity fit.
        want = rarity(r)
        rate = GRASS_RATES[si] if table == "grass" else WATER_RATES[si]
        have = 0 if rate >= 10 else (1 if rate >= 4 else 2)
        s -= abs(want - have) * 1.5
        return s

    placed = {}
    free = [("g",) + x for x in grass_free] + [("w",) + x for x in water_free]
    used = set()
    area_new_count = defaultdict(int)
    for r in todo:
        best, best_s = None, None
        for f in free:
            if f in used:
                continue
            _, ai, table, si, var = f
            sc = score(r, ai, table, si)
            if sc is None:
                continue
            sc -= area_new_count[ai] * 0.6  # spread species across areas
            if best_s is None or sc > best_s:
                best, best_s = f, sc
        if best is None:
            continue
        used.add(best)
        _, ai, table, si, var = best
        area_new_count[ai] += 1
        if table == "grass":
            slot = plan[ai]["grass"][si]
            for k in FREE_VARIANTS[si][var]:
                slot[k] = r["name"]
        else:
            plan[ai]["water"][table][si] = r["name"]
        placed[r["name"]] = plan[ai]["name"] + " (" + table + ")"

    # Fill any slot nothing could legally use with the area's most common Renegade species.
    for p_area in plan:
        if p_area["grass"]:
            common = p_area["grass"][0]["day"]
            for slot in p_area["grass"]:
                for k in TIMES:
                    if slot[k] is None:
                        slot[k] = common
        for kind, tbl in p_area["water"].items():
            for i, sp in enumerate(tbl):
                if sp is None:
                    tbl[i] = tbl[0]

    unplaced = [r["name"] for r in todo if r["name"] not in placed]
    with open(os.path.join(ROOT, "data", "encounters_imperial.json"), "w", encoding="utf-8") as f:
        json.dump({"grass_rates": GRASS_RATES, "water_rates": WATER_RATES, "areas": plan,
                   "placed": placed, "unplaced_regular_species": unplaced}, f, indent=1, ensure_ascii=False)
    write_markdown(plan, placed, unplaced, rows)
    print(f"placed {len(placed)} added species; {len(unplaced)} not directly placed")


TIMES = ("morning", "day", "night")
# Which time-variants of each grass slot can be filled independently with an added species.
FREE_VARIANTS = [{"all": TIMES}] * 3 + [{"daytime": ("morning", "day"), "night": ("night",)}] + [{"all": TIMES}] * 8


def reslot_grass(t, occ):
    """Return 12 slots ({morning, day, night} -> species or None for 'free').

    Renegade species keep slots 0,1,2,4,6,8,10 (slot 2 holds Renegade's time-of-day species when it
    has any); slots 3,5,7,9,11 are freed for added species when the Renegade species that used to be
    there is still catchable somewhere else.
    """
    times = {k: [sp for sp, _ in sorted(t.get(k.capitalize(), []), key=lambda x: -x[1])] for k in TIMES}
    always = [sp for sp in times["day"] if all(sp in times[k] for k in TIMES)]
    timed = {k: [sp for sp in times[k] if sp not in always] for k in TIMES}
    slots = [{k: None for k in TIMES} for _ in GRASS_RATES]
    renegade_slots = [0, 1, 2, 4, 6, 8, 10]
    new_slots = [3, 5, 7, 9, 11]
    queue = list(always)
    if any(timed.values()):
        # Slot 2 keeps Renegade's time-specific species; fall back to the next common species.
        fill = queue[2] if len(queue) > 2 else (queue[0] if queue else None)
        for k in TIMES:
            slots[2][k] = timed[k][0] if timed[k] else fill
        renegade_slots.remove(2)
        extra = {k: timed[k][1:] for k in TIMES}
        if any(extra.values()):
            for k in TIMES:
                slots[3][k] = extra[k][0] if extra[k] else fill
            new_slots.remove(3)
    for si in renegade_slots:
        if queue:
            sp = queue.pop(0)
            for k in TIMES:
                slots[si][k] = sp
    # Renegade species that no longer fit: drop only if still catchable elsewhere.
    placed = {slot[k] for slot in slots for k in TIMES}
    for sp in dict.fromkeys(sp for k in TIMES for sp in times[k]):
        if sp in placed:
            continue
        if occ[sp] > 1:
            occ[sp] -= 1
            continue
        si = new_slots.pop()
        for k in TIMES:
            slots[si][k] = sp
        placed.add(sp)
    return slots


def reslot_water(entries, occ):
    ordered = [sp for sp, _ in sorted(entries, key=lambda x: -x[1])]
    slots = [None] * 5
    keep = ordered[:3]
    for i, sp in enumerate(keep):
        slots[i] = sp
    for sp in ordered[3:]:
        if occ[sp] > 1:
            occ[sp] -= 1
        else:
            slots[4] = sp
    # Slots 3 and 4 (4% and 1%) are free for added species; if fewer than 3 Renegade species, slot 2 too.
    return slots


def agg(names_rates):
    tot = defaultdict(int)
    order = []
    for n, r in names_rates:
        if n is None:
            continue
        if n not in tot:
            order.append(n)
        tot[n] += r
    return sorted(((n, tot[n]) for n in order), key=lambda x: -x[1])


def write_markdown(plan, placed, unplaced, rows):
    new_names = {r["name"] for r in rows if r["in_renegade"] == "0"}
    star = lambda n: f"**{n}**★" if n in new_names else n
    L = []
    L.append("# Imperial Platinum — Wild Pokémon\n")
    L.append("> Generated by `tools/design/gen_encounters.py` from Renegade Platinum v1.3.0's `WildPokemon.txt` "
             "and `data/species.csv`. Do not hand-edit; change the generator (or add overrides) and re-run.\n")
    L.append("## General notes\n")
    L.append("- Species marked **★** are new to Imperial Platinum (Gen V–IX). Everything else is a Renegade Platinum encounter.")
    L.append("- Levels are unchanged from Renegade Platinum. Fishing levels: Old Rod Lv. 10, Good Rod Lv. 25, Super Rod Lv. 50.")
    L.append("- Grass tables use the Gen IV slot rates 20/20/10/10/10/10/5/5/4/4/1/1. Slots 3 and 4 (the two 10% slots used by time of day) "
             "may change at Morning/Day/Night.")
    L.append("- Surf and each rod use the Gen IV slot rates 60/30/5/4/1.")
    L.append("- Poké Radar and Honey Tree encounters are unchanged from Renegade Platinum.")
    L.append("- Legendary, Mythical, Ultra Beast and Paradox Pokémon are not wild encounters; see `PostgameLegendaries.md`.")
    L.append("- Gen V–IX starters are Pokémon Center gifts, not wild encounters; see `GiftPokemon_Imperial.md`.")
    L.append("- This is a **design draft**: the placements come from a type/habitat/level heuristic and should be playtested and hand-tuned.\n")
    L.append(f"Added regular species placed directly in the wild: **{len(placed)}**. "
             f"Not directly placed (obtain by evolution / breeding / events): **{len(unplaced)}** — listed at the bottom.\n")
    for a in plan:
        L.append(f"### {a['name']}")
        L.append(f"_{a['levels']}_  ·  habitat: {', '.join(a['tags'])}\n")
        L.append("| Table | Encounters |")
        L.append("|---|---|")
        if a["grass"]:
            for tod in TIMES:
                pairs = [(slot[tod], GRASS_RATES[si]) for si, slot in enumerate(a["grass"])]
                L.append(f"| {tod.capitalize()} | " + ", ".join(f"{star(n)} ({p}%)" for n, p in agg(pairs)) + " |")
        if a["radar"]:
            L.append("| Poké Radar | " + ", ".join(f"{n} ({p}%)" for n, p in a["radar"]) + " |")
        if a["honey"]:
            L.append("| Honey Tree | " + ", ".join(f"{n} ({p}%)" for n, p in a["honey"]) + " |")
        for kind, slots in a["water"].items():
            pairs = list(zip(slots, WATER_RATES))
            L.append(f"| {kind} | " + ", ".join(f"{star(n)} ({p}%)" for n, p in agg(pairs)) + " |")
        L.append("")
    L.append("## Added species not placed directly in the wild\n")
    L.append("These are obtainable by evolving a wild-caught pre-evolution (or by breeding, for babies). "
             "If the team wants every species directly catchable, add them to Poké Radar or post-game tables.\n")
    by = {r["name"]: r for r in rows}
    L.append("| # | Species | Obtain via |")
    L.append("|---|---|---|")
    for n in unplaced:
        r = by[n]
        how = f"Evolve {r['evolves_from']} ({r['evolution_method']})" if r["evolves_from"] else "Breeding / special event (TBD)"
        if r["is_baby"] == "1":
            how = "Breed its evolved form"
        L.append(f"| {r['dex']} | {n} | {how} |")
    L.append("")
    with open(os.path.join(ROOT, "docs", "WildPokemon_Imperial.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(L))


if __name__ == "__main__":
    main()
