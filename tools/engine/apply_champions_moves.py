#!/usr/bin/env python3
"""Apply Pokémon Champions' move changes on top of the Gen IX move data (roadmap item 10b).

Run after tools/engine/gen_moves.py (which writes the Gen IX values). Each entry below sets absolute values, so running
this twice changes nothing. Sources: Pokémon Showdown's Champions mod (data/mods/champions/moves.ts, checked
2026-10-22), Serebii's "Updated Attacks" page and Bulbapedia's list of modified moves; see docs/BattleMechanics.md.

Only changes Platinum's data format can hold are applied here (type, power, accuracy, effect chance). Behaviour
changes (e.g. Make It Rain's -2 Sp. Atk, Salt Cure's damage) are listed in docs/BattleMechanics.md for roadmap item 11.

Usage: python3 tools/engine/apply_champions_moves.py
"""
import filecmp
import json
import os
import shutil

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
MOVES_DIR = os.path.join(ROOT, "decomp", "res", "moves")

SNOW_DESCRIPTION = ["The user summons a\n", "snowstorm lasting\n", "five turns. This\n", "boosts the Defense\n",
                    "stats of Ice types."]

# stem -> values to set. "chance" sets the secondary-effect chance; "effect" replaces the battle effect.
CHAMPIONS = {
    # Power and accuracy
    "anchor_shot": {"power": 90},
    "apple_acid": {"power": 90},
    "grav_apple": {"power": 90},
    "fire_lash": {"power": 90},
    "spirit_shackle": {"power": 90},
    "psyshield_bash": {"power": 90},
    "bolt_beak": {"power": 80},
    "fishious_rend": {"power": 80},
    "bone_rush": {"power": 30},
    "slash": {"power": 80},
    "beak_blast": {"power": 120},
    "dragon_hammer": {"power": 100},
    "revelation_dance": {"power": 100},
    "night_daze": {"power": 90},
    "snipe_shot": {"power": 85},
    "trop_kick": {"power": 85},
    "infernal_parade": {"power": 65},
    "triple_dive": {"power": 35},
    "gear_grind": {"power": 60, "accuracy": 90},
    "crabhammer": {"accuracy": 95},
    "syrup_bomb": {"accuracy": 90},
    "meteor_assault": {"power": 170},
    "first_impression": {"power": 100},
    "make_it_rain": {"accuracy": 95},
    # Secondary effects
    "iron_head": {"chance": 20},
    "moonblast": {"chance": 10},
    "freeze_dry": {"effect": "BATTLE_EFFECT_HIT", "chance": 0},  # can no longer freeze
    # Types
    "snap_trap": {"type": "TYPE_STEEL"},
    "growth": {"type": "TYPE_GRASS"},
    # Snow replaces Hail (Gen IX / Champions; the battle code change is in battle_script.c and battle_lib.c).
    # Hail now summons snow, and Snowscape uses the same effect.
    "hail": {"description": SNOW_DESCRIPTION},
    "snowscape": {"effect": "BATTLE_EFFECT_WEATHER_HAIL", "chance": 0},
}
# stem -> move whose animation it uses instead of the one gen_moves.py borrowed.
ANIMATIONS = {"snowscape": "hail"}


def main():
    changed = 0
    for stem, src in ANIMATIONS.items():
        dst, src = os.path.join(MOVES_DIR, stem, "anim.s"), os.path.join(MOVES_DIR, src, "anim.s")
        if not filecmp.cmp(src, dst, shallow=False):
            shutil.copyfile(src, dst)
            changed += 1
    for stem, values in CHAMPIONS.items():
        path = os.path.join(MOVES_DIR, stem, "data.json")
        d = json.load(open(path, encoding="utf-8"))
        new = json.loads(json.dumps(d))
        for key, value in values.items():
            if key == "chance":
                new["effect"]["chance"] = value
            elif key == "effect":
                new["effect"]["type"] = value
            else:
                new[key] = value
        if new != d:
            changed += 1
            with open(path, "w", encoding="utf-8") as f:
                json.dump(new, f, indent=4, ensure_ascii=False)
                f.write("\n")
    print(f"Champions move changes: {len(CHAMPIONS)} moves, {changed} files updated")


if __name__ == "__main__":
    main()
