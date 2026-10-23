#!/usr/bin/env python3
"""Gen IX move data that PokeAPI doesn't carry, written by hand (item 11).

PokeAPI has no flags and no secondary effects for the Legends: Arceus and Scarlet/Violet moves (#827-919), and files a
few older moves under effects Platinum reproduces exactly without saying so. This tool fixes both, in place:

* FLAGS: contact / Protect / Mirror Move / Magic Coat / Snatch for moves #827-919.
* HIT_EFFECTS: new "damage, then a stat change on the user" battle effects (copies of Metal Claw's script with another
  stat subscript); appended to the effect list, the effects meson.build and an effect_script_NNNN.s each.
* MOVES: the battle effect, effect chance and checklist note of each move this tool makes exact.

Run it after tools/engine/gen_moves.py (which would otherwise reset these moves):
    python3 tools/engine/gen9_move_fixes.py
It is idempotent; running it twice changes nothing.
"""
import json
import os
import re

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
DECOMP = os.path.join(ROOT, "decomp")
MOVES_DIR = os.path.join(DECOMP, "res", "moves")
EFFECTS_TXT = os.path.join(DECOMP, "generated", "move_battle_effects.txt")
EFFECTS_DIR = os.path.join(DECOMP, "res", "battle", "scripts", "effects")
CHECKLIST = os.path.join(ROOT, "docs", "MoveChecklist.md")

C, P, M, MC, SN = ("MOVE_FLAG_MAKES_CONTACT", "MOVE_FLAG_CAN_PROTECT", "MOVE_FLAG_CAN_MIRROR_MOVE",
                   "MOVE_FLAG_CAN_MAGIC_COAT", "MOVE_FLAG_CAN_SNATCH")
HIT = (P, M)
CONTACT = (C, P, M)

# Gen IX flags for moves #827-919 (Bulbapedia). Flags not listed here (King's Rock, the animation flags) are kept.
FLAGS = {
    "dire_claw": CONTACT, "psyshield_bash": CONTACT, "power_shift": (SN,), "stone_axe": CONTACT,
    "springtide_storm": HIT, "mystical_power": HIT, "raging_fury": HIT, "wave_crash": CONTACT, "chloroblast": HIT,
    "mountain_gale": HIT, "victory_dance": (SN,), "headlong_rush": CONTACT, "barb_barrage": HIT, "esper_wing": HIT,
    "bitter_malice": HIT, "shelter": (SN,), "triple_arrows": HIT, "infernal_parade": HIT,
    "ceaseless_edge": CONTACT, "bleakwind_storm": HIT, "wildbolt_storm": HIT, "sandsear_storm": HIT,
    "lunar_blessing": (SN,), "take_heart": (SN,), "tera_blast": HIT, "axe_kick": CONTACT, "last_respects": HIT,
    "lumina_crash": HIT, "order_up": HIT, "jet_punch": CONTACT, "spicy_extract": (P, MC, M), "spin_out": CONTACT,
    "population_bomb": CONTACT, "ice_spinner": CONTACT, "glaive_rush": CONTACT, "salt_cure": HIT,
    "triple_dive": CONTACT, "mortal_spin": CONTACT, "fillet_away": (SN,), "kowtow_cleave": CONTACT,
    "flower_trick": HIT, "torch_song": HIT, "aqua_step": CONTACT, "raging_bull": CONTACT, "make_it_rain": HIT,
    "psyblade": CONTACT, "hydro_steam": HIT, "ruination": HIT, "collision_course": CONTACT,
    "electro_drift": CONTACT, "tidy_up": (SN,), "pounce": CONTACT, "trailblaze": CONTACT, "chilling_water": HIT,
    "hyper_drill": (C, M), "twin_beam": HIT, "rage_fist": CONTACT, "armor_cannon": HIT, "bitter_blade": CONTACT,
    "double_shock": CONTACT, "gigaton_hammer": HIT, "comeuppance": CONTACT, "aqua_cutter": HIT,
    "blazing_torque": HIT, "wicked_torque": HIT, "noxious_torque": HIT, "combat_torque": HIT,
    "magical_torque": HIT, "blood_moon": HIT, "matcha_gotcha": HIT, "syrup_bomb": HIT, "ivy_cudgel": HIT,
    "tera_starstorm": HIT, "fickle_beam": HIT, "thunderclap": HIT, "mighty_cleave": (C, M), "tachyon_cutter": HIT,
    "hard_press": CONTACT, "alluring_voice": HIT, "temper_flare": CONTACT, "supercell_slam": CONTACT,
    "psychic_noise": HIT, "upper_hand": CONTACT, "malignant_chain": HIT,
}
OWN_FLAGS = (C, P, M, MC, SN)

# New battle effects: damage, then (effect chance) a stat change on the user.
HIT_EFFECTS = {
    "SOVEREIGN_RAISE_SPEED_HIT": ("MOVE_SUBSCRIPT_PTR_SPEED_UP_1_STAGE", "user Speed +1"),
    "SOVEREIGN_RAISE_DEF_2_HIT": ("MOVE_SUBSCRIPT_PTR_DEFENSE_UP_2_STAGES", "user Defense +2"),
    "SOVEREIGN_LOWER_OWN_DEF_HIT": ("MOVE_SUBSCRIPT_PTR_DEFENSE_DOWN_1_STAGE", "user Defense -1"),
    "SOVEREIGN_LOWER_OWN_SP_ATK_HIT": ("MOVE_SUBSCRIPT_PTR_SP_ATTACK_DOWN_1_STAGE", "user Sp. Atk -1"),
    "SOVEREIGN_LOWER_OWN_SPEED_2_HIT": ("MOVE_SUBSCRIPT_PTR_SPEED_DOWN_2_STAGES", "user Speed -2"),
}

# move: (battle effect without the BATTLE_EFFECT_ prefix, effect chance, checklist note[, checklist status]). None keeps the
# current effect; the status defaults to exact.
MOVES = {
    # Already Gen IX: the existing effect and chance match; only the checklist was wrong.
    "lunge": (None, None, "target Attack -1 (100%)"),
    "fire_lash": (None, None, "target Defense -1 (100%)"),
    "trop_kick": (None, None, "target Attack -1 (100%)"),
    "nuzzle": (None, None, "paralyzes (100%)"),
    "acid_spray": (None, None, "target Sp. Def -2 (100%)"),
    "power_up_punch": (None, None, "user Attack +1 (100%)"),
    "glaciate": (None, None, "foes' Speed -1 (100%)"),
    "skitter_smack": (None, None, "target Sp. Atk -1 (100%)"),
    "apple_acid": (None, None, "target Sp. Def -1 (100%)"),
    "breaking_swipe": (None, None, "foes' Attack -1 (100%)"),
    "thunderous_kick": (None, None, "target Defense -1 (100%)"),
    "baby_doll_eyes": (None, None, "+1 priority, target Attack -1"),
    "play_nice": (None, None, "never misses, ignores Protect, target Attack -1"),
    "petal_blizzard": (None, None, "hits all adjacent Pokémon"),
    "brutal_swing": (None, None, "hits all adjacent Pokémon"),
    "boomburst": (None, None, "hits all adjacent Pokémon"),
    "disarming_voice": (None, None, "never misses, hits both foes"),
    "jet_punch": (None, None, "+1 priority punch"),
    "hyperspace_hole": (None, None, "never misses, ignores Protect"),
    "kowtow_cleave": (None, None, "never misses"),
    "hyper_drill": (None, None, "ignores Protect"),
    "mighty_cleave": (None, None, "ignores Protect"),
    "tera_blast": (None, None, "plain hit (no Terastallization in Sovereign)"),
    "tera_starstorm": (None, None, "plain hit (no Terastallization in Sovereign)"),
    "dynamax_cannon": (None, None, "plain hit (no Dynamax in Sovereign)"),
    "behemoth_blade": (None, None, "plain hit (no Dynamax in Sovereign)"),
    "behemoth_bash": (None, None, "plain hit (no Dynamax in Sovereign)"),
    # Existing effects.
    "mountain_gale": ("FLINCH_HIT", 30, "30% flinch"),
    "bitter_malice": ("LOWER_ATTACK_HIT", 100, "target Attack -1 (100%)"),
    "springtide_storm": ("LOWER_ATTACK_HIT", 30, "foes' Attack -1 (30%)"),
    "lumina_crash": ("LOWER_SP_DEF_2_HIT", 100, "target Sp. Def -2 (100%)"),
    "pounce": ("LOWER_SPEED_HIT", 100, "target Speed -1 (100%)"),
    "chilling_water": ("LOWER_ATTACK_HIT", 100, "target Attack -1 (100%)"),
    "wave_crash": ("RECOIL_THIRD", 0, "1/3 recoil"),
    "headlong_rush": ("DEF_SPD_DOWN_HIT", 0, "user Defense and Sp. Def -1"),
    "armor_cannon": ("DEF_SPD_DOWN_HIT", 0, "user Defense and Sp. Def -1"),
    "bitter_blade": ("RECOVER_HALF_DAMAGE_DEALT", 0, "drains half the damage dealt"),
    "aqua_cutter": ("HIGH_CRITICAL", 0, "high critical-hit ratio"),
    "twin_beam": ("HIT_TWICE", 0, "hits twice"),
    "tachyon_cutter": ("HIT_TWICE", 0, "hits twice, never misses"),
    "ruination": ("HALVE_HP", 0, "halves the target's HP"),
    "comeuppance": ("METAL_BURST", 0, "returns 1.5x the damage taken"),
    "malignant_chain": ("BADLY_POISON_HIT", 50, "badly poisons (50%)"),
    "blazing_torque": ("BURN_HIT", 30, "30% burn"),
    "noxious_torque": ("POISON_HIT", 30, "30% poison"),
    "combat_torque": ("PARALYZE_HIT", 30, "30% paralysis"),
    "magical_torque": ("CONFUSE_HIT", 30, "30% confusion"),
    "raging_fury": ("CONTINUE_AND_CONFUSE_SELF", 0, "rampages 2-3 turns, then confuses the user"),
    "torch_song": ("RAISE_SP_ATK_HIT", 100, "user Sp. Atk +1 (100%)"),
    "mystical_power": ("RAISE_SP_ATK_HIT", 100, "user Sp. Atk +1 (100%)"),
    # Battle-dependent power or accuracy in the engine (battle_lib.c / battle_controller_player.c) plus an effect.
    "infernal_parade": ("BURN_HIT", 30, "30% burn; power doubles if the target has a status condition"),
    "barb_barrage": ("POISON_HIT", 50, "50% poison; power doubles if the target is poisoned"),
    "bleakwind_storm": ("LOWER_SPEED_HIT", 30, "foes' Speed -1 (30%); never misses in rain"),
    "wildbolt_storm": ("PARALYZE_HIT", 20, "20% paralysis; never misses in rain"),
    "sandsear_storm": ("BURN_HIT", 20, "20% burn; never misses in rain"),
    "fishious_rend": (None, None, "power doubles if the target hasn't moved yet"),
    "bolt_beak": (None, None, "power doubles if the target hasn't moved yet"),
    "hard_press": (None, None, "power 1-100 from the target's remaining HP"),
    "fickle_beam": (None, None, "30% chance of double power"),
    "grav_apple": (None, None, "target Defense -1 (100%); 1.5x power under Gravity"),
    "hydro_steam": (None, None, "boosted, not weakened, in harsh sunlight"),
    "storm_throw": ("HIT", 0, "always a critical hit"),
    "frost_breath": ("HIT", 0, "always a critical hit"),
    "wicked_blow": ("HIT", 0, "always a critical hit"),
    "flower_trick": ("HIT", 0, "always a critical hit, never misses"),
    # New effects (HIT_EFFECTS).
    "flame_charge": ("SOVEREIGN_RAISE_SPEED_HIT", 100, "user Speed +1 (100%)"),
    "trailblaze": ("SOVEREIGN_RAISE_SPEED_HIT", 100, "user Speed +1 (100%)"),
    "aqua_step": ("SOVEREIGN_RAISE_SPEED_HIT", 100, "user Speed +1 (100%)"),
    "esper_wing": ("SOVEREIGN_RAISE_SPEED_HIT", 100, "user Speed +1 (100%); high critical-hit ratio"),
    "diamond_storm": ("SOVEREIGN_RAISE_DEF_2_HIT", 50, "user Defense +2 (50%)"),
    "clanging_scales": ("SOVEREIGN_LOWER_OWN_DEF_HIT", 100, "user Defense -1"),
    "hyperspace_fury": ("SOVEREIGN_LOWER_OWN_DEF_HIT", 100, "user Defense -1, ignores Protect"),
    "make_it_rain": ("SOVEREIGN_LOWER_OWN_SP_ATK_HIT", 100, "user Sp. Atk -1"),
    "spin_out": ("SOVEREIGN_LOWER_OWN_SPEED_2_HIT", 100, "user Speed -2"),
    # Engine rules (battle_lib.c, battle_script.c, battle_controller_player.c, the drain subscript).
    "sacred_sword": (None, None, "ignores the target's stat changes"),
    "chip_away": (None, None, "ignores the target's stat changes"),
    "darkest_lariat": (None, None, "ignores the target's stat changes"),
    "stomping_tantrum": (None, None, "power doubles if the user's last move failed"),
    "temper_flare": (None, None, "power doubles if the user's last move failed"),
    "lash_out": (None, None, "power doubles if the user's stats were lowered this turn"),
    "burning_jealousy": ("BURN_HIT", 100, "burns a target whose stats rose this turn"),
    "alluring_voice": ("CONFUSE_HIT", 100, "confuses a target whose stats rose this turn"),
    "draining_kiss": (None, None, "drains 3/4 of the damage dealt"),
    "oblivion_wing": (None, None, "drains 3/4 of the damage dealt"),
    "round": (None, None, "power doubles after its ally's Round this turn (the ally doesn't move up in turn order)",
              "approximate"),
    # Terrains (5 turns, 8 with a Terrain Extender; the Seeds aren't reproduced yet).
    "electric_terrain": ("SOVEREIGN_ELECTRIC_TERRAIN", 0, "Electric Terrain: grounded Electric moves x1.3, grounded Pokémon can't fall asleep"),
    "grassy_terrain": ("SOVEREIGN_GRASSY_TERRAIN", 0, "Grassy Terrain: grounded Grass moves x1.3, heals 1/16 each turn, halves Earthquake"),
    "misty_terrain": ("SOVEREIGN_MISTY_TERRAIN", 0, "Misty Terrain: halves Dragon moves, grounded Pokémon can't be statused or confused"),
    "psychic_terrain": ("SOVEREIGN_PSYCHIC_TERRAIN", 0, "Psychic Terrain: grounded Psychic moves x1.3, blocks priority moves"),
    "rising_voltage": (None, None, "power doubles in Electric Terrain against a grounded target"),
    "expanding_force": (None, None, "1.5x in Psychic Terrain (doesn't spread to both foes yet)", "approximate"),
    "misty_explosion": ("HALVE_DEFENSE", 0, "user faints; 1.5x in Misty Terrain (uses Explosion's effect)", "approximate"),
    "psyblade": (None, None, "1.5x in Electric Terrain"),
    "terrain_pulse": (None, None, "type follows the terrain, double power in one"),
    "grassy_glide": (None, None, "+1 priority in Grassy Terrain"),
    "steel_roller": (None, None, "fails without a terrain, then removes it (no message yet)", "approximate"),
    "ice_spinner": (None, None, "removes the terrain (no message yet)", "approximate"),
    "laser_focus": ("SOVEREIGN_LASER_FOCUS", 0, "the user's moves always crit this turn and the next"),
    "throat_chop": ("SOVEREIGN_THROAT_CHOP", 100, "the target can't use sound moves for two turns"),
    "dragon_tail": ("SOVEREIGN_DRAG_OUT_HIT", 0, "drags the target out after the hit"),
    "circle_throw": ("SOVEREIGN_DRAG_OUT_HIT", 0, "drags the target out after the hit"),
    "smack_down": ("SOVEREIGN_SMACK_DOWN", 0, "grounds the target until it switches out"),
    "soak": ("SOVEREIGN_SOAK", 0, "the target becomes pure Water-type"),
    "wide_guard": ("SOVEREIGN_WIDE_GUARD", 0, "protects the user's side from spread moves this turn"),
    "quick_guard": ("SOVEREIGN_QUICK_GUARD", 0, "protects the user's side from foes' priority moves this turn"),
    "poltergeist": (None, None, "fails against a target holding no item (no item message yet)", "approximate"),
    "retaliate": (None, None, "power doubles if a Pokémon on the user's side fainted last turn"),
    # Stat moves from tools/engine/gen_stat_moves.py whose extra rule isn't reproduced yet.
    "no_retreat": (None, None, "all stats +1 (the user isn't trapped yet)", "approximate"),
    "clangorous_soul": (None, None, "all stats +1 (doesn't cost 1/3 of the user's HP yet)", "approximate"),
    "shelter": ("DEF_UP_2", 0, "user Defense +2"),
}


def update_effects():
    effects = [l.strip() for l in open(EFFECTS_TXT) if l.strip()]
    meson = os.path.join(EFFECTS_DIR, "meson.build")
    mtext = open(meson).read()
    for name, (ptr, desc) in HIT_EFFECTS.items():
        full = "BATTLE_EFFECT_" + name
        if full not in effects:
            effects.append(full)
        idx = effects.index(full)
        script = f"effect_script_{idx:04d}.s"
        with open(os.path.join(EFFECTS_DIR, script), "w") as f:
            f.write("#include \"macros/btlcmd.inc\"\n\n"
                    f"// Sovereign (item 11): damage, then {desc}. Generated by tools/engine/gen9_move_fixes.py.\n\n"
                    "_000:\n"
                    f"    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_ATTACKER|{ptr}\n"
                    "    CalcCrit \n"
                    "    CalcDamage \n"
                    "    End \n")
        if f"'{script}'" not in mtext:
            mtext = re.sub(r"('effect_script_\d{4}\.s')\n\)", rf"\1,\n    '{script}'\n)", mtext, count=1)
    with open(EFFECTS_TXT, "w") as f:
        f.write("\n".join(effects) + "\n")
    with open(meson, "w") as f:
        f.write(mtext)


def update_moves():
    for move in sorted(set(FLAGS) | set(MOVES)):
        path = os.path.join(MOVES_DIR, move, "data.json")
        data = json.load(open(path, encoding="utf-8"))
        if move in FLAGS:
            keep = [f for f in data["flags"] if f not in OWN_FLAGS]
            data["flags"] = [f for f in OWN_FLAGS if f in FLAGS[move]] + keep
        if move in MOVES and MOVES[move][0] is not None:
            data["effect"] = {"type": "BATTLE_EFFECT_" + MOVES[move][0], "chance": MOVES[move][1]}
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
            f.write("\n")


def update_checklist():
    text = open(CHECKLIST, encoding="utf-8").read()
    for move, (_, _, note, *rest) in MOVES.items():
        status = rest[0] if rest else "exact"
        data = json.load(open(os.path.join(MOVES_DIR, move, "data.json"), encoding="utf-8"))
        eff = data["effect"]["type"][len("BATTLE_EFFECT_"):]
        pat = re.compile(r"^(\| \d+ \| " + re.escape(data["name"]) + r" \| [^|]+ \| )`[^`]*` \| \w+ \| [^|]*\|$", re.M)
        text, n = pat.subn(lambda m: f"{m.group(1)}`{eff}` | {status} | Sovereign effect: {note} |", text)
        assert n == 1, (move, data["name"], n)
    rows = re.findall(r"^\| \d+ \| .* \| (exact|approximate|placeholder|removed) \| .*\|$", text, re.M)
    for status in ("exact", "approximate", "placeholder", "removed"):
        text = re.sub(rf"^\| {status} \| \d+ \|$", f"| {status} | {rows.count(status)} |", text, count=1, flags=re.M)
    with open(CHECKLIST, "w", encoding="utf-8") as f:
        f.write(text)


if __name__ == "__main__":
    update_effects()
    update_moves()
    update_checklist()
    print(f"{len(FLAGS)} moves' flags, {len(MOVES)} moves exact, {len(HIT_EFFECTS)} hit effects")
