#!/usr/bin/env python3
"""Build Sovereign Platinum's species and Mega Evolution reference tables.

Source data: PokeAPI's CSV dump (https://github.com/PokeAPI/pokeapi, data/v2/csv,
BSD-3-Clause). Pass the path to that csv directory as the first argument.

Outputs (relative to the repository root):
  data/species.csv  - all 1025 species with types, base stats, family and evolution info
  data/megas.csv    - every Mega Evolution / Primal Reversion with stats, types, ability, stone
  data/forms.csv    - every other alternate form with its own data (milestone FM), with its category

Usage:
  python3 tools/design/build_species_data.py /path/to/pokeapi/data/v2/csv
"""
import csv
import os
import sys
from collections import defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
EN = "9"
MAX_DEX = 1025
RENEGADE_MAX = 493

# Not flagged legendary/mythical by PokeAPI but treated as "special" (post-game) in Sovereign.
ULTRA_BEASTS = set(range(793, 800)) | {803, 804, 805, 806}
PARADOX = set(range(984, 996)) | {1005, 1006, 1009, 1010, 1020, 1021, 1022, 1023}

STAT_KEYS = ["hp", "atk", "def", "spa", "spd", "spe"]

# Gen 4 / Renegade Platinum evolution items that already exist in the engine.
GEN4_EVO_ITEMS = {
    "Fire Stone", "Water Stone", "Thunder Stone", "Leaf Stone", "Moon Stone", "Sun Stone",
    "Shiny Stone", "Dusk Stone", "Dawn Stone", "Oval Stone", "King's Rock", "Metal Coat",
    "Dragon Scale", "Up-Grade", "Dubious Disc", "Protector", "Electirizer", "Magmarizer",
    "Reaper Cloth", "Razor Claw", "Razor Fang", "Deep Sea Tooth", "Deep Sea Scale", "Prism Scale",
    "Ice Stone",  # added to Renegade Platinum
}
# Moves removed by Renegade Platinum (replaced by later-gen moves).
RENEGADE_REMOVED_MOVES = {"Barrage", "Brine", "Constrict", "Horn Drill", "Lunar Dance", "Luster Purge",
                          "Mist Ball", "Sand Tomb", "Submission", "Twister", "Volt Tackle"}
RENEGADE_ADDED_MOVES = {"Draining Kiss", "Scald", "Icicle Crash", "Drill Run", "Moonblast",
                        "Dazzling Gleam", "Disarming Voice", "Bulldoze", "Play Rough", "Hurricane",
                        "Wild Charge"}
GEN4_MAX_MOVE = 467
GEN4_MAX_ABILITY = 123


def read(csvdir, name):
    with open(os.path.join(csvdir, name), newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def names_by_id(rows, id_key):
    out = {}
    for r in rows:
        if r["local_language_id"] == EN:
            out[r[id_key]] = r["name"]
    return out


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    d = sys.argv[1]

    species = {r["id"]: r for r in read(d, "pokemon_species.csv") if int(r["id"]) <= MAX_DEX}
    sp_names = names_by_id(read(d, "pokemon_species_names.csv"), "pokemon_species_id")
    type_names = names_by_id(read(d, "type_names.csv"), "type_id")
    ability_names = names_by_id(read(d, "ability_names.csv"), "ability_id")
    item_names = names_by_id(read(d, "item_names.csv"), "item_id")
    move_names = names_by_id(read(d, "move_names.csv"), "move_id")
    triggers = {r["id"]: r["identifier"] for r in read(d, "evolution_triggers.csv")}
    loc_names = names_by_id(read(d, "location_names.csv"), "location_id")
    form_ident = {r["id"]: r["identifier"] for r in read(d, "pokemon_forms.csv")}

    def is_regional(form_id):
        """Cosmetic forms (Deerling seasons, Vivillon patterns, ...) don't matter; regional forms do."""
        return bool(form_id) and any(t in form_ident.get(form_id, "") for t in ("alola", "galar", "hisui", "paldea"))

    pokemon = read(d, "pokemon.csv")
    default_form = {p["species_id"]: p["id"] for p in pokemon if p["is_default"] == "1"}

    ptypes = defaultdict(list)
    for r in read(d, "pokemon_types.csv"):
        ptypes[r["pokemon_id"]].append((int(r["slot"]), type_names[r["type_id"]]))
    pstats = defaultdict(dict)
    for r in read(d, "pokemon_stats.csv"):
        sid = int(r["stat_id"])
        if 1 <= sid <= 6:
            pstats[r["pokemon_id"]][STAT_KEYS[sid - 1]] = int(r["base_stat"])
    pabil = defaultdict(list)
    for r in read(d, "pokemon_abilities.csv"):
        pabil[r["pokemon_id"]].append((int(r["slot"]), r["is_hidden"] == "1", ability_names.get(r["ability_id"], "?"),
                                       int(r["ability_id"])))

    evo_rows = defaultdict(list)
    for r in read(d, "pokemon_evolution.csv"):
        evo_rows[r["evolved_species_id"]].append(r)

    def types_of(pid):
        return "/".join(t for _, t in sorted(ptypes[pid]))

    def describe_evo(r):
        trig = triggers.get(r["evolution_trigger_id"], "?")
        parts = []
        if trig == "level-up":
            if r["minimum_level"]:
                parts.append(f"Level {r['minimum_level']}")
            else:
                parts.append("Level up")
        elif trig == "use-item":
            parts.append("Use " + item_names.get(r["trigger_item_id"], "item"))
        elif trig == "trade":
            parts.append("Trade")
        else:
            parts.append(trig.replace("-", " ").capitalize())
        if r["held_item_id"]:
            parts.append("holding " + item_names.get(r["held_item_id"], "?"))
        if r["minimum_happiness"]:
            parts.append("with high friendship")
        if r["minimum_affection"]:
            parts.append("with high affection")
        if r["time_of_day"]:
            parts.append("at " + r["time_of_day"])
        if r["known_move_id"]:
            parts.append("knowing " + move_names.get(r["known_move_id"], "?"))
        if r["known_move_type_id"]:
            parts.append("knowing a " + type_names.get(r["known_move_type_id"], "?") + "-type move")
        if r["gender_id"]:
            parts.append("(female)" if r["gender_id"] == "1" else "(male)")
        if r["location_id"]:
            parts.append("at " + loc_names.get(r["location_id"], "special location"))
        if r["party_species_id"]:
            parts.append("with " + sp_names.get(r["party_species_id"], "?") + " in party")
        if r["party_type_id"]:
            parts.append("with a " + type_names.get(r["party_type_id"], "?") + "-type in party")
        if r["trade_species_id"]:
            parts.append("for " + sp_names.get(r["trade_species_id"], "?"))
        if r["needs_overworld_rain"] == "1":
            parts.append("in rain")
        if r["turn_upside_down"] == "1":
            parts.append("with the console upside down")
        if r["relative_physical_stats"]:
            parts.append({"1": "(Atk > Def)", "-1": "(Atk < Def)", "0": "(Atk = Def)"}[r["relative_physical_stats"]])
        if r["used_move_id"]:
            parts.append("after using " + move_names.get(r["used_move_id"], "?"))
        if r["minimum_steps"]:
            parts.append(f"after walking {r['minimum_steps']} steps (Let's Go)")
        if r["needs_multiplayer"] == "1":
            parts.append("in a Union Circle (multiplayer)")
        if is_regional(r["required_pokemon_form_id"]):
            parts.append("from the " + form_ident.get(r["required_pokemon_form_id"], "?") + " form")
        return " ".join(parts)

    def gen4_compatible(r):
        """Can this evolution method run unmodified on the Platinum engine (with Renegade's item changes)?"""
        trig = triggers.get(r["evolution_trigger_id"])
        if trig not in ("level-up", "use-item"):
            return False
        if trig == "use-item" and item_names.get(r["trigger_item_id"]) not in GEN4_EVO_ITEMS:
            return False
        if r["held_item_id"] and item_names.get(r["held_item_id"]) not in GEN4_EVO_ITEMS:
            return False
        if r["known_move_id"]:
            mv = move_names.get(r["known_move_id"], "")
            ok = (int(r["known_move_id"]) <= GEN4_MAX_MOVE and mv not in RENEGADE_REMOVED_MOVES) or mv in RENEGADE_ADDED_MOVES
            if not ok:
                return False
        for k in ("known_move_type_id", "party_type_id", "minimum_affection", "used_move_id", "trade_species_id"):
            if r[k]:
                return False
        if r["needs_overworld_rain"] == "1" or r["turn_upside_down"] == "1":
            return False
        if r["location_id"]:
            return False
        if r["nature_bitmask"] or r["condition_expression"]:
            return False
        if r["minimum_steps"] or r["needs_multiplayer"] == "1" or is_regional(r["required_pokemon_form_id"]):
            return False
        # Gen IV only combines time of day with friendship or a held item.
        if r["time_of_day"] and not (r["minimum_happiness"] or r["held_item_id"]):
            return False
        return True

    # Stage within family (1 = base).
    def stage(sid):
        n = 1
        cur = species[sid]
        while cur["evolves_from_species_id"]:
            n += 1
            cur = species[cur["evolves_from_species_id"]]
        return n

    def category(sid):
        i = int(sid)
        s = species[sid]
        if s["is_mythical"] == "1":
            return "mythical"
        if s["is_legendary"] == "1":
            return "legendary"
        if i in ULTRA_BEASTS:
            return "ultra_beast"
        if i in PARADOX:
            return "paradox"
        return "regular"

    has_child = defaultdict(list)
    for sid, s in species.items():
        if s["evolves_from_species_id"]:
            has_child[s["evolves_from_species_id"]].append(sid)

    os.makedirs(os.path.join(ROOT, "data"), exist_ok=True)
    out_path = os.path.join(ROOT, "data", "species.csv")
    fields = ["dex", "name", "generation", "in_renegade", "category", "types", "bst"] + STAT_KEYS + [
        "family_id", "stage", "is_final", "is_baby", "evolves_from", "evolution_method", "gen4_engine_compatible",
        "abilities", "capture_rate"]
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for sid in sorted(species, key=int):
            s = species[sid]
            pid = default_form[sid]
            st = pstats[pid]
            evos = [r for r in evo_rows.get(sid, [])]
            # PokeAPI lists one row per method/version group; keep distinct descriptions.
            descs, compat = [], []
            for r in evos:
                ds = describe_evo(r)
                if ds not in descs:
                    descs.append(ds)
                    compat.append(gen4_compatible(r))
            ab = [n + (" (H)" if hid else "") for _, hid, n, _ in sorted(pabil[pid])]
            w.writerow({
                "dex": int(sid), "name": sp_names[sid], "generation": s["generation_id"],
                "in_renegade": int(int(sid) <= RENEGADE_MAX), "category": category(sid),
                "types": types_of(pid), "bst": sum(st.values()), **st,
                "family_id": s["evolution_chain_id"], "stage": stage(sid),
                "is_final": int(sid not in has_child), "is_baby": s["is_baby"],
                "evolves_from": sp_names.get(s["evolves_from_species_id"], ""),
                "evolution_method": " OR ".join(descs),
                "gen4_engine_compatible": "" if not descs else int(any(compat)),
                "abilities": "; ".join(ab), "capture_rate": s["capture_rate"],
            })
    print("wrote", out_path)

    # Megas / primals.
    stone_for = {}
    for iid, n in item_names.items():
        stone_for[n] = iid
    mega_path = os.path.join(ROOT, "data", "megas.csv")
    with open(mega_path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["form_id", "form", "base_species", "dex", "trigger_item", "types", "ability", "bst"] + STAT_KEYS + [
            "base_types", "base_bst", "source_game", "ability_in_gen4_engine"])
        for p in pokemon:
            ident = p["identifier"]
            if not ("-mega" in ident or ident.endswith("-primal")):
                continue
            sid = p["species_id"]
            base = sp_names[sid]
            pid = p["id"]
            st = pstats[pid]
            if ident.endswith("-primal"):
                item = "Red Orb" if "groudon" in ident else "Blue Orb"
                label = "Primal " + base
            else:
                suffix = ident.split("-mega", 1)[1].strip("-").upper()
                label = "Mega " + base + (" " + suffix if suffix in ("X", "Y", "Z") else "")
                if ident.startswith("meowstic"):
                    label = "Mega Meowstic (" + ("Female" if "female" in ident else "Male") + ")"
                if ident.startswith("tatsugiri"):
                    label = "Mega Tatsugiri (" + ident.split("-")[1].capitalize() + " Form)"
                if ident.startswith("magearna"):
                    label = "Mega Magearna" + (" (Original Color)" if "original" in ident else "")
                item = mega_stone_name(base, suffix, item_names)
            ab = [n for _, hid, n, _ in sorted(pabil[pid])]
            ab_gen4 = all(aid <= GEN4_MAX_ABILITY for *_, aid in pabil[pid]) if pabil[pid] else ""
            base_pid = default_form[sid]
            fid = int(pid)
            src = "XY" if fid <= 10060 else ("ORAS" if fid <= 10090 else ("Legends: Z-A" if fid <= 10303 else "Legends: Z-A (Mega Dimension)"))
            if ident in ("charizard-mega-x", "charizard-mega-y", "mewtwo-mega-x", "mewtwo-mega-y"):
                src = "XY"
            w.writerow([pid, label, base, int(sid), item, types_of(pid), "/".join(ab), sum(st.values())] +
                       [st[k] for k in STAT_KEYS] + [types_of(base_pid), sum(pstats[base_pid].values()), src,
                                                       "" if ab_gen4 == "" else int(ab_gen4)])
    print("wrote", mega_path)

    write_forms(d, pokemon, sp_names, pstats, pabil, types_of, default_form)


# Milestone FM (decision 16): every form is in the game except Dynamax/Gigantamax and unplayable forms. Each alternate
# form with its own data gets a category; "vanilla" forms are already in Platinum, "excluded" ones never will be.
FORM_CATEGORIES = {
    "vanilla": ["deoxys-", "wormadam-", "shaymin-sky", "giratina-origin", "rotom-", "castform-"],
    "excluded": ["eternatus-eternamax", "koraidon-", "miraidon-", "terapagos-stellar"],
    "item": ["zacian-crowned", "zamazenta-crowned", "ogerpon-", "dialga-origin", "palkia-origin"],
    "battle": ["darmanitan-zen", "meloetta-pirouette", "aegislash-blade", "greninja-ash", "zygarde-complete",
               "wishiwashi-school", "minior-red", "minior-orange", "minior-yellow", "minior-green", "minior-blue",
               "minior-indigo", "minior-violet", "mimikyu-busted", "cramorant-", "eiscue-noice", "morpeko-hangry",
               "necrozma-ultra", "palafin-hero", "terapagos-terastal"],
    "fusion": ["kyurem-black", "kyurem-white", "necrozma-dusk", "necrozma-dawn", "calyrex-ice", "calyrex-shadow"],
}


def form_category(ident):
    if "-gmax" in ident:
        return "excluded"
    if "totem" in ident:
        return "totem"
    for category, prefixes in FORM_CATEGORIES.items():
        if any(ident == p or (p.endswith("-") and ident.startswith(p)) or ident.startswith(p + "-") for p in prefixes):
            if category == "battle" and ident.endswith("-meteor"):
                break
            return category
    if any(t in ident for t in ("alola", "galar", "hisui", "paldea")):
        return "regional"
    return "other"


def write_forms(d, pokemon, sp_names, pstats, pabil, types_of, default_form):
    forms = {r["pokemon_id"]: r for r in read(d, "pokemon_forms.csv") if r["is_default"] == "1"}
    form_names = {r["pokemon_form_id"]: r for r in read(d, "pokemon_form_names.csv") if r["local_language_id"] == EN}
    path = os.path.join(ROOT, "data", "forms.csv")
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["form_id", "identifier", "form", "base_species", "dex", "category", "types", "abilities", "bst"]
                   + STAT_KEYS + ["base_types", "ability_in_gen4_engine"])
        for p in pokemon:
            ident = p["identifier"]
            if p["is_default"] == "1" or "-mega" in ident or ident.endswith("-primal"):
                continue
            sid, pid = p["species_id"], p["id"]
            base = sp_names[sid]
            names = form_names.get(forms.get(pid, {}).get("id", ""), {})
            label = names.get("pokemon_name") or f"{base} ({names.get('form_name') or ident})"
            st = pstats[pid]
            ab = [n + (" (H)" if hid else "") for _, hid, n, _ in sorted(pabil[pid])]
            ab_gen4 = all(aid <= GEN4_MAX_ABILITY for *_, aid in pabil[pid]) if pabil[pid] else ""
            w.writerow([pid, ident, label, base, int(sid), form_category(ident), types_of(pid), "; ".join(ab),
                        sum(st.values())] + [st[k] for k in STAT_KEYS]
                       + [types_of(default_form[sid]), "" if ab_gen4 == "" else int(ab_gen4)])
    print("wrote", path)


def mega_stone_name(base, suffix, item_names):
    """Best-effort match of a Mega form to its stone using PokeAPI item names."""
    special = {
        ("Rayquaza", ""): "Dragon Ascent (move; no stone)",
        ("Charizard", "X"): "Charizardite X", ("Charizard", "Y"): "Charizardite Y",
        ("Mewtwo", "X"): "Mewtwonite X", ("Mewtwo", "Y"): "Mewtwonite Y",
        ("Raichu", "X"): "Raichunite X", ("Raichu", "Y"): "Raichunite Y",
        ("Absol", "Z"): "Absolite Z", ("Garchomp", "Z"): "Garchompite Z", ("Lucario", "Z"): "Lucarionite Z",
        ("Kangaskhan", ""): "Kangaskhanite", ("Heracross", ""): "Heracronite", ("Houndoom", ""): "Houndoominite",
        ("Abomasnow", ""): "Abomasite", ("Blastoise", ""): "Blastoisinite", ("Alakazam", ""): "Alakazite",
        ("Manectric", ""): "Manectite", ("Sableye", ""): "Sablenite", ("Sharpedo", ""): "Sharpedonite",
        ("Altaria", ""): "Altarianite", ("Glalie", ""): "Glalitite", ("Diancie", ""): "Diancite",
        ("Feraligatr", ""): "Feraligite", ("Scolipede", ""): "Scolipite", ("Scrafty", ""): "Scraftinite",
        ("Excadrill", ""): "Excadrite", ("Starmie", ""): "Starminite", ("Dragonite", ""): "Dragoninite",
        ("Barbaracle", ""): "Barbaracite", ("Dragalge", ""): "Dragalgite", ("Hawlucha", ""): "Hawluchanite",
        ("Drampa", ""): "Drampanite", ("Darkrai", ""): "Darkranite", ("Staraptor", ""): "Staraptite",
        ("Crabominable", ""): "Crabominite", ("Golisopod", ""): "Golisopite", ("Baxcalibur", ""): "Baxcalibrite",
        ("Tatsugiri", ""): "Tatsugirinite", ("Glimmora", ""): "Glimmoranite", ("Meowstic", ""): "Meowsticite",
        ("Lucario", ""): "Lucarionite", ("Garchomp", ""): "Garchompite", ("Absol", ""): "Absolite",
    }
    key = (base, suffix if suffix in ("X", "Y", "Z") else "")
    if key in special:
        return special[key]
    known = set(item_names.values())
    for cand in (base + "ite", base[:-1] + "ite", base + "nite", base[:-2] + "ite"):
        if cand in known:
            return cand
    return base + "ite (verify name)"


if __name__ == "__main__":
    main()
