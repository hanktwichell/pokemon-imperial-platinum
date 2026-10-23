#!/usr/bin/env python3
"""Generate Sovereign Platinum's Gen IX move data for the decomp (milestone E3).

Move ID = official move number (1-919). For every move it writes decomp/res/moves/<stem>/{data.json,anim.s,script.s}
and rewrites decomp/generated/moves.txt; it also writes docs/MoveChecklist.md, which records how faithfully each new
move's behaviour is reproduced.

* #1-467 (Platinum's moves) keep their battle effect, flags and animation. Power, accuracy, PP, type and priority are
  updated to Gen IX (variable-power and never-miss moves keep the engine's 1 / 0 markers).
* #468-919: data from PokeAPI. Each new move is mapped onto one of Platinum's 277 battle effects:
    - "exact":       PokeAPI's effect is one Platinum already has (effect_id - 1 = BATTLE_EFFECT index), or the move's
                     metadata matches an existing effect completely;
    - "approximate": the closest existing effect (the move's extra behaviour is missing or simplified);
    - "placeholder": nothing close exists yet (damaging moves just hit; status moves do nothing).
  Animations are borrowed from an existing move of the same type and category.
* Z-Moves, Max Moves and G-Max moves are not in the game (owner decision). Their numbers stay as empty, unobtainable
  slots (0 PP, no name) so the IDs keep matching the official numbers.

Usage: python3 tools/engine/gen_moves.py /path/to/pokeapi/data/v2/csv
Then run tools/engine/apply_champions_moves.py, which applies Pokémon Champions' changes on top (and turns Snowscape
into the Snow effect; its checklist row is edited by hand to match).
"""
import csv
import json
import os
import re
import shutil
import sys
import textwrap
from collections import defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
MOVES_DIR = os.path.join(DECOMP, "res", "moves")
LAST_VANILLA = 467
LAST_MOVE = 919
EN = "9"

# Names longer than the 15 characters a move-name buffer holds, shortened Gen V-style.
SHORT_NAMES = {
    "Parabolic Charge": "ParabolcCharge", "Electric Terrain": "ElectrcTerrain", "Precipice Blades": "PrecipiceBlade",
    "First Impression": "FirstImpressn", "Revelation Dance": "RevelatnDance", "Stomping Tantrum": "StompngTantrum",
    "Nature’s Madness": "Nature’sMadness", "Double Iron Bash": "DoubleIronBash", "Burning Jealousy": "BurnJealousy",
    "Springtide Storm": "SpringtideStrm", "Revival Blessing": "RevivlBlessing", "Collision Course": "CollisionCours",
    "Chilly Reception": "ChillyReceptn",
}

TYPES = {"normal": "TYPE_NORMAL", "fighting": "TYPE_FIGHTING", "flying": "TYPE_FLYING", "poison": "TYPE_POISON",
         "ground": "TYPE_GROUND", "rock": "TYPE_ROCK", "bug": "TYPE_BUG", "ghost": "TYPE_GHOST", "steel": "TYPE_STEEL",
         "fairy": "TYPE_FAIRY", "fire": "TYPE_FIRE", "water": "TYPE_WATER", "grass": "TYPE_GRASS",
         "electric": "TYPE_ELECTRIC", "psychic": "TYPE_PSYCHIC", "ice": "TYPE_ICE", "dragon": "TYPE_DRAGON",
         "dark": "TYPE_DARK"}
CLASSES = {"1": "CLASS_STATUS", "2": "CLASS_PHYSICAL", "3": "CLASS_SPECIAL"}
RANGES = {"specific-move": "RANGE_SINGLE_TARGET_SPECIAL", "selected-pokemon-me-first": "RANGE_SINGLE_TARGET_ME_FIRST",
          "ally": "RANGE_ALLY", "users-field": "RANGE_USER_SIDE", "user-or-ally": "RANGE_USER_OR_ALLY",
          "opponents-field": "RANGE_OPPONENT_SIDE", "user": "RANGE_USER", "random-opponent": "RANGE_RANDOM_OPPONENT",
          "all-other-pokemon": "RANGE_ALL_ADJACENT", "selected-pokemon": "RANGE_SINGLE_TARGET",
          "all-opponents": "RANGE_ADJACENT_OPPONENTS", "entire-field": "RANGE_FIELD", "user-and-allies": "RANGE_USER_SIDE",
          "all-pokemon": "RANGE_ALL", "all-allies": "RANGE_USER_SIDE", "fainting-pokemon": "RANGE_USER"}
CONTEST_TYPES = {"1": "CONTEST_TYPE_COOL", "2": "CONTEST_TYPE_BEAUTY", "3": "CONTEST_TYPE_CUTE",
                 "4": "CONTEST_TYPE_SMART", "5": "CONTEST_TYPE_TOUGH"}

# Existing moves whose animation a new move borrows: (type, class) -> stem, plus spread-move and status variants.
ANIM_PHYSICAL = {"normal": "body_slam", "fighting": "brick_break", "flying": "aerial_ace", "poison": "poison_jab",
                 "ground": "bone_club", "rock": "stone_edge", "bug": "x_scissor", "ghost": "shadow_claw",
                 "steel": "iron_head", "fairy": "sweet_kiss", "fire": "fire_punch", "water": "waterfall",
                 "grass": "leaf_blade", "electric": "thunder_punch", "psychic": "zen_headbutt", "ice": "ice_punch",
                 "dragon": "dragon_claw", "dark": "crunch"}
ANIM_SPECIAL = {"normal": "hyper_voice", "fighting": "aura_sphere", "flying": "air_slash", "poison": "sludge_bomb",
                "ground": "earth_power", "rock": "power_gem", "bug": "bug_buzz", "ghost": "shadow_ball",
                "steel": "flash_cannon", "fairy": "sweet_kiss", "fire": "flamethrower", "water": "water_pulse",
                "grass": "energy_ball", "electric": "thunderbolt", "psychic": "psychic", "ice": "ice_beam",
                "dragon": "dragon_pulse", "dark": "dark_pulse"}
ANIM_SPREAD = {"fire": "heat_wave", "water": "surf", "ground": "earthquake", "rock": "rock_slide", "ice": "blizzard",
               "normal": "hyper_voice", "electric": "discharge", "bug": "bug_buzz", "poison": "sludge_bomb"}
STAT_NAMES = {1: "hp", 2: "atk", 3: "def", 4: "spa", 5: "spd", 6: "spe", 7: "acc", 8: "eva"}
STAT_BOOST_ANIM = {"atk": "swords_dance", "def": "iron_defense", "spa": "nasty_plot", "spd": "amnesia",
                   "spe": "agility", "acc": "sharpen", "eva": "double_team"}

E = lambda name: "BATTLE_EFFECT_" + name

# Battle effects Sovereign adds for a move's exact Gen IX behaviour (item 11), after Platinum's 277: identifier ->
# (effect, chance, note). These win over the PokeAPI mapping below.
SOVEREIGN_EFFECTS = {
    "hex": ("HIT", 0, "Sovereign effect: target has a status condition: power doubles"),
    "venoshock": ("HIT", 0, "Sovereign effect: target is poisoned: power doubles"),
    "acrobatics": ("HIT", 0, "Sovereign effect: user holds no item: power doubles"),
    "electro-ball": ("HIT", 0, "Sovereign effect: power from the user/target Speed ratio (40-150)"),
    "heavy-slam": ("HIT", 0, "Sovereign effect: power from the user/target weight ratio (40-120)"),
    "heat-crash": ("HIT", 0, "Sovereign effect: power from the user/target weight ratio (40-120)"),
    "stored-power": ("HIT", 0, "Sovereign effect: power 20 + 20 per positive stat stage on the user"),
    "power-trip": ("HIT", 0, "Sovereign effect: power 20 + 20 per positive stat stage on the user"),
    "psyshock": ("HIT", 0, "Sovereign effect: special damage against the target's Defense"),
    "psystrike": ("HIT", 0, "Sovereign effect: special damage against the target's Defense"),
    "secret-sword": ("HIT", 0, "Sovereign effect: special damage against the target's Defense"),
    "foul-play": ("HIT", 0, "Sovereign effect: damage uses the target's Attack and Attack stage"),
    "tearful-look": ("SOVEREIGN_TEARFUL_LOOK", 0, "Sovereign effect: target Attack -1, target Sp. Atk -1"),
    "noble-roar": ("SOVEREIGN_NOBLE_ROAR", 0, "Sovereign effect: target Attack -1, target Sp. Atk -1"),
    "victory-dance": ("SOVEREIGN_VICTORY_DANCE", 0, "Sovereign effect: user Attack +1, user Defense +1, user Speed +1"),
    "shift-gear": ("SOVEREIGN_SHIFT_GEAR", 0, "Sovereign effect: user Attack +1, user Speed +2"),
    "cotton-guard": ("SOVEREIGN_COTTON_GUARD", 0, "Sovereign effect: user Defense +3"),
    "shell-smash": ("SOVEREIGN_SHELL_SMASH", 0, "Sovereign effect: user Defense -1, user Sp. Def -1, user Attack +2, user Sp. Atk +2, user Speed +2"),
    "quiver-dance": ("SOVEREIGN_QUIVER_DANCE", 0, "Sovereign effect: user Sp. Atk +1, user Sp. Def +1, user Speed +1"),
    "coil": ("SOVEREIGN_COIL", 0, "Sovereign effect: user Attack +1, user Defense +1, user accuracy +1"),
    "work-up": ("SOVEREIGN_WORK_UP", 0, "Sovereign effect: user Attack +1, user Sp. Atk +1"),
    "hone-claws": ("SOVEREIGN_HONE_CLAWS", 0, "Sovereign effect: user Attack +1, user accuracy +1"),
    "electro-shot": ("ELECTRO_SHOT", 100, "Sovereign effect: charge turn raises Sp. Atk; no charge turn in rain"),
    "body-press": ("BODY_PRESS", 0, "Sovereign effect: damage uses the user's Defense and Defense stage"),
    "hurricane": ("HURRICANE", 30, "Sovereign effect: Thunder's weather accuracy and hits Pokémon in the air, 30% confusion"),
}
# Moves whose script.s (battle message) and anim.s (two-part charge/attack animation) are written by hand; the
# generator leaves both files alone.
HANDWRITTEN_SCRIPTS = {"electro_shot"}

# Status stat-drop effects -> the damaging "lower X on hit" effect, for damaging moves PokeAPI files under the former.
STATUS_TO_HIT = {E("ATK_DOWN"): "LOWER_ATTACK_HIT", E("DEF_DOWN"): "LOWER_DEFENSE_HIT", E("SPEED_DOWN"): "LOWER_SPEED_HIT",
                 E("SP_ATK_DOWN"): "LOWER_SP_ATK_HIT", E("SP_DEF_DOWN"): "LOWER_SP_DEF_HIT",
                 E("ACC_DOWN"): "LOWER_ACCURACY_HIT", E("EVA_DOWN"): "LOWER_EVASION_HIT",
                 E("SP_DEF_DOWN_2"): "LOWER_SP_DEF_2_HIT", E("STATUS_PARALYZE"): "PARALYZE_HIT",
                 E("STATUS_BURN"): "BURN_HIT", E("STATUS_POISON"): "POISON_HIT", E("STATUS_CONFUSE"): "CONFUSE_HIT",
                 E("STATUS_BADLY_POISON"): "BADLY_POISON_HIT"}


def rd(pokeapi, name):
    with open(os.path.join(pokeapi, name), newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def is_z_or_max(r):
    return r["identifier"].startswith(("max-", "g-max-")) or (r["generation_id"] == "7" and r["pp"] == "1")


def stem_of(ident):
    return re.sub(r"[^a-z0-9]+", "_", ident.lower()).strip("_")


def clean_text(t):
    t = re.sub(r"\s+", " ", t).strip()
    # Platinum's charmap has curly quotes, … and × but no straight double quote.
    for a, b in (("—", "-"), ("–", "-"), ("‘", "’"), ("'", "’")):
        t = t.replace(a, b)
    parts = t.split('"')
    return "".join(p + ("“" if i % 2 == 0 else "”") if i < len(parts) - 1 else p for i, p in enumerate(parts))


def wrap_description(texts, width=21, lines=5):
    """Newest flavor text that fits; else its first sentence; else trimmed at a word boundary."""
    for t in texts:
        for cand in (t, re.split(r"(?<=[.!?]) ", t)[0]):
            w = textwrap.wrap(cand, width)
            if len(w) <= lines:
                return w
    w = textwrap.wrap(re.split(r"(?<=[.!?]) ", texts[0])[0], width)[:lines]
    if not w[-1].endswith("."):
        w[-1] = w[-1].rstrip(",;:") + "."
    return w


def description_json(lines):
    return [l + "\n" for l in lines[:-1]] + [lines[-1]] if lines else [""]


def map_effect(m, meta, stats, effects, ident):
    """Return (effect, chance, fidelity, note) for a move with no direct Platinum effect."""
    damaging = m["damage_class_id"] in ("2", "3")
    cat = meta.get("meta_category_id", "13")
    ail = meta.get("meta_ailment_id", "0")
    chance = int(meta.get("ailment_chance") or 0) or int(meta.get("stat_chance") or 0) or int(meta.get("flinch_chance") or 0)
    drain = int(meta.get("drain") or 0)
    heal = int(meta.get("healing") or 0)
    lo, hi = meta.get("min_hits") or "", meta.get("max_hits") or ""
    crit = int(meta.get("crit_rate") or 0)
    flinch = int(meta.get("flinch_chance") or 0)
    changes = sorted(stats)  # [(stat, change)]
    approx = lambda eff, note, ch=0: (E(eff), ch, "approximate", note)
    exact = lambda eff, ch=0: (E(eff), ch, "exact", "")

    if ident in ("spiky-shield", "kings-shield", "baneful-bunker", "obstruct", "silk-trap", "burning-bulwark"):
        return approx("PROTECT", "protects like Protect; the contact penalty is missing")
    if cat == "9":
        return exact("ONE_HIT_KO")
    if cat == "3":
        return (E("RESTORE_HALF_HP"), 0, "exact" if heal == 50 else "approximate",
                "" if heal == 50 else f"heals 50% instead of {heal}%")
    if cat == "8" or (damaging and drain > 0):
        return (E("RECOVER_HALF_DAMAGE_DEALT"), 0, "exact" if drain == 50 else "approximate",
                "" if drain == 50 else f"drains 50% instead of {drain}%")
    if damaging and drain < 0:
        eff = {-25: "RECOIL_QUARTER", -33: "RECOIL_THIRD", -50: "RECOIL_HALF"}.get(drain)
        return (E(eff), 0, "exact", "") if eff else approx("RECOIL_HALF", f"recoil {-drain}% shown as 50%")
    if damaging and lo and hi:
        if lo == hi == "2":
            return exact("HIT_TWICE")
        if lo == "2" and hi == "5":
            return exact("MULTI_HIT")
        return approx("MULTI_HIT", f"hits {lo}-{hi} times in the original")
    if cat == "4" and damaging:
        eff = {"1": "PARALYZE_HIT", "3": "FREEZE_HIT", "4": "BURN_HIT", "5": "POISON_HIT", "6": "CONFUSE_HIT",
               "8": "BIND_HIT"}.get(ail)
        if eff:
            return (E(eff), chance, "exact", "")
        return approx("HIT", f"secondary ailment {ail} not reproduced")
    if cat == "6" and damaging and changes:
        one = {("atk", -1): "LOWER_ATTACK_HIT", ("def", -1): "LOWER_DEFENSE_HIT", ("spe", -1): "LOWER_SPEED_HIT",
               ("spa", -1): "LOWER_SP_ATK_HIT", ("spd", -1): "LOWER_SP_DEF_HIT", ("acc", -1): "LOWER_ACCURACY_HIT",
               ("eva", -1): "LOWER_EVASION_HIT", ("spd", -2): "LOWER_SP_DEF_2_HIT"}
        eff = one.get(changes[0]) if len(changes) == 1 else None
        if eff:
            return (E(eff), chance, "exact", "")
        first = one.get((changes[0][0], -1))
        return approx(first or "HIT", f"lowers {changes} in the original", chance)
    if cat == "7" and damaging and changes:
        if all(c < 0 for _, c in changes):
            key = tuple(changes)
            eff = {(("spa", -2),): "USER_SP_ATK_DOWN_2", (("atk", -1), ("def", -1)): "LOWER_OWN_ATK_AND_DEF",
                   (("def", -1), ("spd", -1)): "DEF_SPD_DOWN_HIT", (("spe", -1),): "SPEED_DOWN_HIT"}.get(key)
            if eff:
                return exact(eff)
            return approx("USER_SP_ATK_DOWN_2" if any(s == "spa" for s, _ in changes) else "LOWER_OWN_ATK_AND_DEF",
                          f"user's stats change by {changes} in the original")
        key = tuple(changes)
        eff = {(("atk", 1),): "RAISE_ATTACK_HIT", (("def", 1),): "RAISE_DEF_HIT", (("spa", 1),): "RAISE_SP_ATK_HIT"}.get(key)
        if eff:
            return (E(eff), chance, "exact", "")
        if len(changes) == 5:
            return (E("RAISE_ALL_STATS_HIT"), chance, "exact", "")
        return approx("HIT", f"user's stats change by {changes} in the original")
    if cat == "2" and changes and not damaging:
        up = all(c > 0 for _, c in changes)
        down = all(c < 0 for _, c in changes)
        names = {"atk": "ATK", "def": "DEF", "spe": "SPEED", "spa": "SP_ATK", "spd": "SP_DEF", "acc": "ACC", "eva": "EVA"}
        if len(changes) == 1 and (up or down):
            s, c = changes[0]
            if s in names and abs(c) in (1, 2):
                eff = names[s] + ("_UP" if up else "_DOWN") + ("_2" if abs(c) == 2 else "")
                if E(eff) in effects:
                    return exact(eff)
            return approx(names.get(s, "ATK") + ("_UP_2" if up else "_DOWN_2"), f"{changes} in the original")
        pair = {(("atk", 1), ("def", 1)): "ATK_DEF_UP", (("def", 1), ("spd", 1)): "DEF_SPD_UP",
                (("spa", 1), ("spd", 1)): "SP_ATK_SP_DEF_UP", (("atk", 1), ("spe", 1)): "ATK_SPD_UP",
                (("atk", -1), ("def", -1)): "ATK_DEF_DOWN"}.get(tuple(changes))
        if pair:
            return exact(pair)
        if up:
            stats_up = {s for s, _ in changes}
            if {"spa", "spd"} <= stats_up:
                return approx("SP_ATK_SP_DEF_UP", f"raises {changes} in the original")
            if {"atk", "spe"} <= stats_up:
                return approx("ATK_SPD_UP", f"raises {changes} in the original")
            if {"atk", "def"} <= stats_up:
                return approx("ATK_DEF_UP", f"raises {changes} in the original")
            if "atk" in stats_up:
                return approx("ATK_UP_2", f"raises {changes} in the original")
            if "spa" in stats_up:
                return approx("SP_ATK_UP_2", f"raises {changes} in the original")
            return approx("DEF_UP_2", f"raises {changes} in the original")
        return approx("ATK_DEF_DOWN" if down else "DO_NOTHING", f"stat changes {changes} in the original")
    if cat in ("1", "5") and not damaging:
        eff = {"1": "STATUS_PARALYZE", "2": "STATUS_SLEEP", "4": "STATUS_BURN", "5": "STATUS_POISON",
               "6": "STATUS_CONFUSE", "7": "INFATUATE", "14": "STATUS_SLEEP_NEXT_TURN", "13": "DISABLE",
               "12": "TORMENT", "15": "PREVENT_HEALING", "18": "STATUS_LEECH_SEED", "19": "PREVENT_ITEM_USE",
               "20": "ALL_FAINT_3_TURNS", "8": "PREVENT_ESCAPE"}.get(ail)
        if eff:
            return exact(eff) if not changes else approx(eff, f"also changes stats {changes} in the original")
    if damaging:
        if crit >= 1:
            return (E("HIGH_CRITICAL"), 0, "exact" if cat == "0" else "approximate",
                    "" if cat == "0" else "extra effect not reproduced")
        if flinch:
            return (E("FLINCH_HIT"), flinch, "exact" if cat == "0" else "approximate", "")
        if int(m["priority"] or 0) > 0:
            return (E("PRIORITY_1"), 0, "exact" if cat == "0" else "approximate",
                    "" if cat == "0" else "extra effect not reproduced")
        return (E("HIT"), 0, "exact" if cat == "0" else "placeholder",
                "" if cat == "0" else "special behaviour not reproduced yet; plain hit")
    return (E("DO_NOTHING"), 0, "placeholder", "status effect not reproduced yet; does nothing")


def anim_template(m, type_ident, effect, stats, rng):
    cls = m["damage_class_id"]
    if effect == E("PROTECT"):
        return "protect"
    if cls == "1":
        if effect in (E("RESTORE_HALF_HP"),):
            return "recover"
        if effect in (E("STATUS_SLEEP"), E("STATUS_SLEEP_NEXT_TURN")):
            return "hypnosis"
        if effect == E("STATUS_PARALYZE"):
            return "thunder_wave"
        if effect == E("STATUS_BURN"):
            return "will_o_wisp"
        if effect in (E("STATUS_POISON"), E("STATUS_BADLY_POISON")):
            return "toxic"
        if effect == E("STATUS_CONFUSE"):
            return "confuse_ray"
        ups = [s for s, c in stats if c > 0]
        downs = [s for s, c in stats if c < 0]
        if ups:
            return STAT_BOOST_ANIM.get(ups[0], "growth")
        if downs:
            return "growl" if "atk" in downs else "screech"
        return "growth" if rng in ("RANGE_USER", "RANGE_USER_SIDE") else "growl"
    if rng in ("RANGE_ADJACENT_OPPONENTS", "RANGE_ALL_ADJACENT") and type_ident in ANIM_SPREAD:
        return ANIM_SPREAD[type_ident]
    return (ANIM_PHYSICAL if cls == "2" else ANIM_SPECIAL)[type_ident]


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    api = sys.argv[1]
    effects = [l.strip() for l in open(os.path.join(DECOMP, "generated", "move_battle_effects.txt")) if l.strip()]
    moves = {int(r["id"]): r for r in rd(api, "moves.csv") if int(r["id"]) <= LAST_MOVE}
    names = {int(r["move_id"]): r["name"] for r in rd(api, "move_names.csv") if r["local_language_id"] == EN}
    types = {r["id"]: r["identifier"] for r in rd(api, "types.csv")}
    targets = {r["id"]: r["identifier"] for r in rd(api, "move_targets.csv")}
    meta = {int(r["move_id"]): r for r in rd(api, "move_meta.csv")}
    stat_changes = defaultdict(list)
    for r in rd(api, "move_meta_stat_changes.csv"):
        stat_changes[int(r["move_id"])].append((STAT_NAMES[int(r["stat_id"])], int(r["change"])))
    flags = defaultdict(set)
    flag_names = {r["id"]: r["identifier"] for r in rd(api, "move_flags.csv")}
    for r in rd(api, "move_flag_map.csv"):
        flags[int(r["move_id"])].add(flag_names[r["move_flag_id"]])
    flavor = defaultdict(dict)
    for r in rd(api, "move_flavor_text.csv"):
        if r["language_id"] == EN:
            flavor[int(r["move_id"])][int(r["version_group_id"])] = clean_text(r["flavor_text"])

    vanilla = [l.strip() for l in open(os.path.join(DECOMP, "generated", "moves.txt"))
               if l.strip().startswith("MOVE_")][:LAST_VANILLA + 1]
    out_consts = list(vanilla)
    changed, rows = [], []

    # 1. Platinum's moves: Gen IX numbers, same effect.
    for mid in range(1, LAST_VANILLA + 1):
        stem = vanilla[mid][5:].lower()
        p = os.path.join(MOVES_DIR, stem, "data.json")
        d = json.load(open(p, encoding="utf-8"))
        r = moves[mid]
        new = dict(d)
        new["type"] = TYPES[types[r["type_id"]]]
        new["pp"] = int(r["pp"])
        new["priority"] = int(r["priority"])
        if r["power"] and d["power"] > 1:
            new["power"] = int(r["power"])
        if r["accuracy"] and d["accuracy"] > 0:
            new["accuracy"] = int(r["accuracy"])
        diff = [k for k in ("type", "power", "accuracy", "pp", "priority") if new[k] != d[k]]
        if diff:
            changed.append((mid, d["name"], ", ".join(f"{k} {d[k]}→{new[k]}" for k in diff)))
            with open(p, "w", encoding="utf-8") as f:
                json.dump(new, f, indent=4, ensure_ascii=False)
                f.write("\n")

    # Which effects Platinum's own moves use on damaging vs. status moves: a new move only reuses an effect directly
    # if Platinum uses it for the same kind of move (e.g. "lower Speed" exists as a status effect and as a hit effect).
    damaging_effects, status_effects = set(), set()
    for mid in range(1, LAST_VANILLA + 1):
        d = json.load(open(os.path.join(MOVES_DIR, vanilla[mid][5:].lower(), "data.json"), encoding="utf-8"))
        (status_effects if d["class"] == "CLASS_STATUS" else damaging_effects).add(d["effect"]["type"])

    # 2. New moves and empty Z/Max slots.
    script_src = os.path.join(MOVES_DIR, "pound", "script.s")
    for mid in range(LAST_VANILLA + 1, LAST_MOVE + 1):
        r = moves[mid]
        if is_z_or_max(r):
            stem = f"unused_{mid:04d}"
            data = {"name": "-", "description": ["-"], "class": "CLASS_STATUS", "type": "TYPE_NORMAL", "power": 0,
                    "accuracy": 0, "pp": 0, "effect": {"type": E("DO_NOTHING"), "chance": 0}, "range": "RANGE_USER",
                    "priority": 0, "flags": [], "contest": {"effect": "CONTEST_EFFECT_BASIC", "type": "CONTEST_TYPE_COOL"}}
            anim = "splash"
            rows.append((mid, f"({r['identifier']})", "—", "—", "removed", "Z-Move / Max Move: empty slot, unobtainable"))
        else:
            stem = stem_of(r["identifier"])
            type_ident = types[r["type_id"]]
            eid = int(r["effect_id"]) if r["effect_id"] else None
            stats = sorted(stat_changes[mid])
            damaging = r["damage_class_id"] in ("2", "3")
            direct = effects[eid - 1] if eid and eid <= 277 else None
            if direct and direct in (damaging_effects if damaging else status_effects):
                eff, chance, fid, note = direct, int(r["effect_chance"] or 0), "exact", ""
            else:
                eff, chance, fid, note = map_effect(r, meta.get(mid, {}), stats, effects, r["identifier"])
                if direct and damaging and direct in STATUS_TO_HIT:
                    eff, chance, fid, note = E(STATUS_TO_HIT[direct]), int(r["effect_chance"] or 100), "exact", ""
                elif eid and eid > 277 and fid == "exact":
                    # PokeAPI gives this move its own effect, so something beyond the mapped effect is missing.
                    fid = "placeholder" if eff == E("HIT") else "approximate"
                    note = note or "has its own mechanic in Gen IX; " + ("plain hit" if eff == E("HIT") else "closest effect")
            if r["identifier"] in SOVEREIGN_EFFECTS:
                own, own_chance, own_note = SOVEREIGN_EFFECTS[r["identifier"]]
                eff, chance, fid, note = E(own), own_chance, "exact", own_note
            rng = RANGES[targets[r["target_id"]]]
            fl = []
            f = flags[mid]
            damaging = r["damage_class_id"] in ("2", "3")
            if "contact" in f:
                fl.append("MOVE_FLAG_MAKES_CONTACT")
            if "protect" in f:
                fl.append("MOVE_FLAG_CAN_PROTECT")
            if "reflectable" in f:
                fl.append("MOVE_FLAG_CAN_MAGIC_COAT")
            if "snatch" in f:
                fl.append("MOVE_FLAG_CAN_SNATCH")
            if "mirror" in f:
                fl.append("MOVE_FLAG_CAN_MIRROR_MOVE")
            if damaging and eff in (E("HIT"), E("HIGH_CRITICAL"), E("PRIORITY_1"), E("MULTI_HIT"), E("HIT_TWICE"),
                                    E("RECOIL_QUARTER"), E("RECOIL_THIRD"), E("RECOIL_HALF")):
                fl.append("MOVE_FLAG_TRIGGERS_KINGS_ROCK")
            anim = anim_template(r, type_ident, eff, stats, rng)
            tmpl = json.load(open(os.path.join(MOVES_DIR, anim, "data.json"), encoding="utf-8"))
            fl += [x for x in tmpl["flags"] if x in ("MOVE_FLAG_HIDES_HP_GAUGES", "MOVE_FLAG_HIDES_SHADOWS")]
            name = names[mid]
            name = SHORT_NAMES.get(name, name)
            assert len(name) <= 15, name
            texts = [flavor[mid][g] for g in sorted(flavor[mid], reverse=True)] or [name + "."]
            data = {
                "name": name,
                "description": description_json(wrap_description(texts)),
                "class": CLASSES[r["damage_class_id"]],
                "type": TYPES[type_ident],
                "power": int(r["power"]) if r["power"] else (1 if damaging else 0),
                "accuracy": int(r["accuracy"]) if r["accuracy"] else 0,
                "pp": int(r["pp"]),
                "effect": {"type": eff, "chance": chance},
                "range": rng,
                "priority": int(r["priority"]),
                "flags": fl,
                "contest": {"effect": "CONTEST_EFFECT_BASIC",
                            "type": CONTEST_TYPES.get(r["contest_type_id"], "CONTEST_TYPE_COOL")},
            }
            rows.append((mid, name, type_ident.capitalize(), eff[len("BATTLE_EFFECT_"):], fid, note))
        d = os.path.join(MOVES_DIR, stem)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, "data.json"), "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
            f.write("\n")
        if stem not in HANDWRITTEN_SCRIPTS:
            shutil.copyfile(script_src, os.path.join(d, "script.s"))
            shutil.copyfile(os.path.join(MOVES_DIR, anim, "anim.s"), os.path.join(d, "anim.s"))
        out_consts.append("MOVE_" + stem.upper())

    assert len(out_consts) == LAST_MOVE + 1 and len(set(out_consts)) == len(out_consts)
    with open(os.path.join(DECOMP, "generated", "moves.txt"), "w") as f:
        f.write("\n".join(out_consts + ["MAX_MOVES"]) + "\n")

    # 3. Checklist.
    count = defaultdict(int)
    for row in rows:
        count[row[4]] += 1
    L = ["# Sovereign Platinum — Move Checklist", "",
         "> Generated by `tools/engine/gen_moves.py` from PokeAPI. Edit the generator, not this file.", "",
         "Move ID = official move number. **exact**: the move behaves as in Gen IX (within Platinum's engine). "
         "**approximate**: uses the closest existing effect (the note says what's missing). **placeholder**: no effect "
         "yet (damaging moves just hit; status moves do nothing). **removed**: Z-Moves and Max Moves, which aren't in "
         "Sovereign (empty, unobtainable slots).", "",
         "| | Count |", "|---|---|"]
    L += [f"| {k} | {count[k]} |" for k in ("exact", "approximate", "placeholder", "removed")]
    L += ["", "## New moves (#468–919)", "", "| # | Move | Type | Effect used | Fidelity | Note |", "|---|---|---|---|---|---|"]
    L += [f"| {a} | {b} | {c} | `{d}` | {e} | {g} |" for a, b, c, d, e, g in rows]
    L += ["", "## Platinum's moves updated to Gen IX numbers", "",
          "Battle effects are unchanged; only these values changed.", "", "| # | Move | Changes |", "|---|---|---|"]
    L += [f"| {a} | {b} | {c} |" for a, b, c in changed]
    with open(os.path.join(ROOT, "docs", "MoveChecklist.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    print(f"moves: {LAST_MOVE}; new {len(rows)} ({dict(count)}); Platinum moves updated: {len(changed)}")


if __name__ == "__main__":
    main()
