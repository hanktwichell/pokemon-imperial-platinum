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
    "hard_press": CONTACT, "electro_shot": HIT, "alluring_voice": HIT, "temper_flare": CONTACT, "supercell_slam": CONTACT,
    "psychic_noise": HIT, "upper_hand": CONTACT, "malignant_chain": HIT,
}
OWN_FLAGS = (C, P, M, MC, SN)

# Platinum's own moves whose flags changed in the later games (docs/PlatinumMoveAudit.md; Showdown's data/moves.ts):
# move -> (flags added, flags removed).
FLAG_FIXES = {
    # Magic Coat and Magic Bounce reflect them (Gen V+).
    **{m: ((MC,), ()) for m in ("disable", "spite", "spikes", "foresight", "encore", "torment", "taunt", "odor_sleuth",
                                "miracle_eye", "embargo", "heal_block", "toxic_spikes", "defog", "stealth_rock")},
    # They go through Protect (Gen VI+); Whirlwind and Roar are also reflected (Gen V+).
    "whirlwind": ((MC,), (P,)), "roar": ((MC,), (P,)), "mean_look": ((), (P,)), "block": ((), (P,)),
    "hail": ((), (P,)),
    # Protect blocks them.
    "counter": ((P,), ()), "mirror_coat": ((P,), ()), "metal_burst": ((P,), ()),
    # Snatch steals them (Gen V+), and no longer Psych Up and Acupressure.
    **{m: ((SN,), ()) for m in ("conversion", "wish", "recycle", "imprison", "healing_wish", "power_trick",
                                "lucky_chant", "aqua_ring", "magnet_rise", "lunar_dance")},
    "psych_up": ((), (SN,)), "acupressure": ((), (SN,)),
    # Mirror Move copies them.
    "feint": ((M,), ()), "chatter": ((M,), ()),
}

# New battle effects: damage, then (effect chance) a stat change on the user.
HIT_EFFECTS = {
    "SOVEREIGN_RAISE_SPEED_HIT": ("MOVE_SUBSCRIPT_PTR_SPEED_UP_1_STAGE", "user Speed +1"),
    "SOVEREIGN_RAISE_DEF_2_HIT": ("MOVE_SUBSCRIPT_PTR_DEFENSE_UP_2_STAGES", "user Defense +2"),
    "SOVEREIGN_LOWER_OWN_DEF_HIT": ("MOVE_SUBSCRIPT_PTR_DEFENSE_DOWN_1_STAGE", "user Defense -1"),
    "SOVEREIGN_LOWER_OWN_SP_ATK_2_HIT": ("MOVE_SUBSCRIPT_PTR_SP_ATTACK_DOWN_2_STAGES", "user Sp. Atk -2"),
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
    "wave_crash": ("RECOIL_THIRD", 0, "33/100 recoil"),
    "pika_papow": ("POWER_BASED_ON_FRIENDSHIP", 0, "power from friendship (up to 102), as Return"),
    "veevee_volley": ("POWER_BASED_ON_FRIENDSHIP", 0, "power from friendship (up to 102), as Return"),
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
    "aura_wheel": ("SOVEREIGN_RAISE_SPEED_HIT", 100, "user Speed +1 (100%); Dark-type from a Hangry Morpeko"),
    "diamond_storm": ("SOVEREIGN_RAISE_DEF_2_HIT", 50, "user Defense +2 (50%)"),
    "clanging_scales": ("SOVEREIGN_LOWER_OWN_DEF_HIT", 100, "user Defense -1"),
    "hyperspace_fury": ("SOVEREIGN_LOWER_OWN_DEF_HIT", 100, "user Defense -1, ignores Protect"),
    "make_it_rain": ("SOVEREIGN_LOWER_OWN_SP_ATK_2_HIT", 100, "user Sp. Atk -2 (Champions)"),
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
    "round": (None, None, "the next Pokémon (either side) that chose Round moves right after the user, with double"
              " power"),
    "trick_or_treat": ("SOVEREIGN_ADD_TYPE", 0, "adds the Ghost type to the target as a third type (in place of an added one); fails if it's a Ghost type already"),
    "forests_curse": ("SOVEREIGN_ADD_TYPE", 0, "adds the Grass type to the target as a third type (in place of an added one); fails if it's a Grass type already"),
    "shed_tail": ("SOVEREIGN_SHED_TAIL", 0, "the user pays half its max HP (rounded up) for a substitute and switches out; the Pokémon that comes in gets the substitute and nothing else"),
    "beak_blast": (None, None, "-3 priority; from the start of the turn until it moves, the user burns Pokémon whose contact moves hit it"),
    "shell_trap": (None, None, "-3 priority; sets a trap at the start of the turn: a foe's physical hit springs it and the user moves right after; otherwise it fails"),
    "spectral_thief": ("SOVEREIGN_SPECTRAL_THIEF", 0, "before it hits, the user takes the target's stat rises (the damage uses them)"),
    "powder": ("SOVEREIGN_POWDER", 0, "the target's Fire moves this turn explode: they fail and it loses 1/4 of its max HP (not through Magic Guard; heavy rain fizzles them first)"),
    "dragon_darts": (None, None, "hits twice; in a double battle, once the target and once its ally (both darts at one"
                     " when the other can't be hit)"),
    # Terrains (5 turns, 8 with a Terrain Extender; the Seeds aren't reproduced yet).
    "electric_terrain": ("SOVEREIGN_ELECTRIC_TERRAIN", 0, "Electric Terrain: grounded Electric moves x1.3, grounded Pokémon can't fall asleep"),
    "grassy_terrain": ("SOVEREIGN_GRASSY_TERRAIN", 0, "Grassy Terrain: grounded Grass moves x1.3, heals 1/16 each turn, halves Earthquake"),
    "misty_terrain": ("SOVEREIGN_MISTY_TERRAIN", 0, "Misty Terrain: halves Dragon moves, grounded Pokémon can't be statused or confused"),
    "psychic_terrain": ("SOVEREIGN_PSYCHIC_TERRAIN", 0, "Psychic Terrain: grounded Psychic moves x1.3, blocks priority moves"),
    "rising_voltage": (None, None, "power doubles in Electric Terrain against a grounded target"),
    "expanding_force": (None, None, "from a grounded user in Psychic Terrain: 1.5x and it hits both foes"),
    "misty_explosion": ("HALVE_DEFENSE", 0, "user faints; 1.5x in Misty Terrain; Damp stops it (Explosion's effect, which no"
                        " longer halves Defense)"),
    "psyblade": (None, None, "1.5x in Electric Terrain"),
    "terrain_pulse": (None, None, "type follows the terrain, double power in one"),
    "grassy_glide": (None, None, "+1 priority in Grassy Terrain"),
    "steel_roller": ("SOVEREIGN_FLATTEN_TERRAIN_HIT", 0, "fails without a terrain; after the hit, the terrain ends"),
    "ice_spinner": ("SOVEREIGN_FLATTEN_TERRAIN_HIT", 0, "after the hit, the terrain ends"),
    "laser_focus": ("SOVEREIGN_LASER_FOCUS", 0, "the user's moves always crit this turn and the next"),
    "throat_chop": ("SOVEREIGN_THROAT_CHOP", 100, "the target can't use sound moves for two turns"),
    "dragon_tail": ("SOVEREIGN_DRAG_OUT_HIT", 0, "drags the target out after the hit"),
    "circle_throw": ("SOVEREIGN_DRAG_OUT_HIT", 0, "drags the target out after the hit"),
    "smack_down": ("SOVEREIGN_SMACK_DOWN", 0, "grounds the target until it switches out; reaches a Pokémon in the air and"
                   " stops its Fly or Bounce"),
    "soak": ("SOVEREIGN_SOAK", 0, "the target becomes pure Water-type"),
    "wide_guard": ("SOVEREIGN_WIDE_GUARD", 0, "protects the user's side from spread moves this turn"),
    "quick_guard": ("SOVEREIGN_QUICK_GUARD", 0, "protects the user's side from foes' priority moves this turn"),
    "poltergeist": ("SOVEREIGN_POLTERGEIST", 0, "fails against a target holding no item; \"...is about to be attacked by its"
                    " <item>!\" before the hit"),
    "retaliate": (None, None, "power doubles if a Pokémon on the user's side fainted last turn"),
    # Stat moves from tools/engine/gen_stat_moves.py whose extra rule isn't reproduced yet.
    "no_retreat": (None, None, "all stats +1; the user can't switch out (a Ghost type can); fails while that trap holds"),
    "clangorous_soul": (None, None, "all stats +1; costs 1/3 of the user's max HP"),
    "shelter": ("DEF_UP_2", 0, "user Defense +2"),
    "heal_pulse": ("SOVEREIGN_HEAL_TARGET", 0, "heals the target by 1/2 (3/4 with Mega Launcher)"),
    "floral_healing": ("SOVEREIGN_HEAL_TARGET", 0, "heals the target by 1/2 (2/3 in Grassy Terrain)"),
    "life_dew": ("SOVEREIGN_LIFE_DEW", 0, "heals the user and its ally by 1/4"),
    "meteor_beam": ("ELECTRO_SHOT", 100, "charge turn raises Sp. Atk 1 stage, attacks next turn (Power Herb skips it)"),
    "after_you": ("SOVEREIGN_AFTER_YOU", 0, "the target moves right after the user"),
    "quash": ("SOVEREIGN_QUASH", 0, "the target moves last this turn"),
    "psychic_noise": ("SOVEREIGN_PSYCHIC_NOISE", 100, "the target can't heal for two turns"),
    "steel_beam": ("SOVEREIGN_HALF_HP_COST_HIT", 0, "the user loses half its max HP, hit or miss"),
    "freeze_dry": ("HIT", 0, "super effective against Water; it can't freeze (Champions)"),
    "confide": (None, None, "target Sp. Atk -1; as a sound move it gets past Substitute"),
    "psyshield_bash": ("RAISE_DEF_HIT", 100, "user Defense +1 (100%)"),
    "spirit_shackle": ("SOVEREIGN_TRAP_HIT", 100, "the target can't escape while the user is in battle"),
    "anchor_shot": ("SOVEREIGN_TRAP_HIT", 100, "the target can't escape while the user is in battle"),
    "revelation_dance": (None, None, "takes the user's primary type"),
    "simple_beam": ("SOVEREIGN_SIMPLE_BEAM", 0, "the target's ability becomes Simple"),
    "entrainment": ("SOVEREIGN_ENTRAINMENT", 0, "the target's ability becomes the user's"),
    "guard_split": ("SOVEREIGN_GUARD_SPLIT", 0, "the user and target average their Defense and Sp. Def"),
    "power_split": ("SOVEREIGN_POWER_SPLIT", 0, "the user and target average their Attack and Sp. Atk"),
    "speed_swap": ("SOVEREIGN_SPEED_SWAP", 0, "the user and target swap their Speed stats"),
    "clear_smog": ("SOVEREIGN_CLEAR_SMOG", 0, "resets the target's stat stages"),
    "incinerate": ("SOVEREIGN_INCINERATE", 0, "burns up the target's Berry"),
    "aurora_veil": ("SOVEREIGN_AURORA_VEIL", 0, "in snow: halves damage to the user's side for 5 turns (8 with Light Clay)"),
    "sticky_web": ("SOVEREIGN_STICKY_WEB", 0, "grounded foes switching in lose 1 Speed stage (Rapid Spin clears it)"),
    "echoed_voice": (None, None, "40 more power for each consecutive turn it's used, up to 200"),
    "fell_stinger": (None, None, "user Attack +3 if it knocks out the target"),
    "synchronoise": (None, None, "only affects targets that share a type with the user"),
    "upper_hand": ("FLINCH_HIT", 100, "fails unless the target is about to use a damaging priority move; makes it flinch"),
    "final_gambit": ("SOVEREIGN_FINAL_GAMBIT", 0, "damage equal to the user's HP; the user faints if it hits"),
    "scale_shot": (None, None, "hits 2-5 times, then user Defense -1 and Speed +1"),
    "coaching": ("SOVEREIGN_COACHING", 0, "the user's ally gets Attack and Defense +1 (fails without one)"),
    "dragon_cheer": ("SOVEREIGN_DRAGON_CHEER", 0, "the user's ally gets +1 crit stage, +2 if Dragon type (fails without one)"),
    "bestow": ("SOVEREIGN_BESTOW", 0, "gives the user's held item to a target holding none"),
    "belch": (None, None, "fails unless the user has eaten a Berry this battle (Bug Bite, Pluck, Stuff Cheeks and a flung"
              " Berry count); it can be chosen anyway (Champions)"),
    "stuff_cheeks": ("SOVEREIGN_STUFF_CHEEKS", 0, "user Defense +2, then it eats its Berry (Klutz, Embargo and Magic Room"
                     " don't stop it); fails without one; it can be chosen anyway (Champions)"),
    "magic_room": ("SOVEREIGN_MAGIC_ROOM", 0, "held items have no effect for 5 turns; using it again ends it"),
    "wonder_room": ("SOVEREIGN_WONDER_ROOM", 0, "Defense and Sp. Def are swapped for 5 turns; using it again ends it"),
    "telekinesis": ("SOVEREIGN_TELEKINESIS", 0, "for 3 turns the target is immune to Ground moves and other moves always hit it"),
    "parting_shot": ("SOVEREIGN_PARTING_SHOT", 0, "target Attack and Sp. Atk -1, then the user switches out (stays if no stat fell)"),
    # Moves batch 1 (engine rules in battle_lib.c and battle_controller_player.c).
    "flying_press": (None, None, "Fighting and Flying type at once for its effectiveness"),
    "collision_course": (None, None, "1.33x when super effective"),
    "electro_drift": (None, None, "1.33x when super effective"),
    "last_respects": (None, None, "50 more power for each fainted Pokémon in the user's party"),
    "fusion_flare": (None, None, "double power right after a Fusion Bolt worked this turn"),
    "fusion_bolt": (None, None, "double power right after a Fusion Flare worked this turn"),
    "sunsteel_strike": (None, None, "ignores the target's ability"),
    "moongeist_beam": (None, None, "ignores the target's ability"),
    "photon_geyser": (None, None, "physical when the user's Attack is higher than its Sp. Atk (with their stages); ignores the target's ability"),
    "ivy_cudgel": (None, None, "type follows Ogerpon's mask; high critical-hit ratio"),
    "raging_bull": ("REMOVE_SCREENS", 0, "breaks Reflect, Light Screen and Aurora Veil; type follows a Paldean Tauros's breed"),
    "gigaton_hammer": (None, None, "can't be used twice in a row"),
    "blood_moon": (None, None, "can't be used twice in a row"),
    "supercell_slam": ("CRASH_ON_MISS", 0, "the user loses half its max HP if it misses"),
    "power_shift": ("SWAP_ATK_DEF", 0, "swaps the user's Attack and Defense"),
    "chloroblast": ("SOVEREIGN_HALF_HP_COST_HIT", 0, "the user loses half its max HP, hit or miss"),
    "mind_blown": ("SOVEREIGN_HALF_HP_COST_HIT", 0, "hits all adjacent Pokémon; the user loses half its max HP once, hit or"
                   " miss; Damp stops it"),
    # Moves batch 2 (hand-written subscripts subscript_sovereign_<move>.s).
    "topsy_turvy": ("SOVEREIGN_TOPSY_TURVY", 0, "inverts the target's stat stages (fails if they're all neutral)"),
    "reflect_type": ("SOVEREIGN_REFLECT_TYPE", 0, "the user takes the target's types (not Arceus or Silvally)"),
    "magic_powder": ("SOVEREIGN_MAGIC_POWDER", 0, "the target becomes pure Psychic-type (a powder move)"),
    "purify": ("SOVEREIGN_PURIFY", 0, "heals the target's status condition, then the user regains 1/2 of its max HP"),
    "strength_sap": ("SOVEREIGN_STRENGTH_SAP", 0, "target Attack -1; the user regains HP equal to the target's Attack (with its stage)"),
    "lunar_blessing": ("SOVEREIGN_LUNAR_BLESSING", 0, "the user and its ally regain 1/4 of their max HP and are cured of status conditions"),
    "jungle_healing": ("SOVEREIGN_LUNAR_BLESSING", 0, "the user and its ally regain 1/4 of their max HP and are cured of status conditions"),
    # Moves batch 3 (effect scripts and subscripts by hand; multi-hit rules in BtlCmd_SetMultiHit).
    "relic_song": ("SOVEREIGN_SLEEP_HIT", 10, "10% sleep; Meloetta changes Forme after using it"),
    "wicked_torque": ("SOVEREIGN_SLEEP_HIT", 10, "10% sleep"),
    "dire_claw": ("SOVEREIGN_DIRE_CLAW", 30, "30% chance (Champions) of sleep, poison or paralysis (one of the three, equally likely); high critical-hit ratio"),
    "triple_arrows": ("SOVEREIGN_TRIPLE_ARROWS", 50, "50% target Defense -1, 30% flinch; high critical-hit ratio"),
    "ceaseless_edge": ("SOVEREIGN_HAZARD_HIT", 100, "lays a layer of Spikes on the foes' side; high critical-hit ratio"),
    "stone_axe": ("SOVEREIGN_HAZARD_HIT", 100, "sets Stealth Rock on the foes' side; high critical-hit ratio"),
    "axe_kick": ("SOVEREIGN_AXE_KICK", 30, "30% confusion; the user loses half its max HP if it misses"),
    "mortal_spin": ("SOVEREIGN_MORTAL_SPIN", 0, "poisons the foes, then frees the user from binding, Leech Seed and its side's hazards"),
    "matcha_gotcha": ("SOVEREIGN_MATCHA_GOTCHA", 20, "hits both foes, drains half the damage dealt, 20% burn; thaws the user out"),
    "population_bomb": ("SOVEREIGN_POPULATION_BOMB", 0, "hits up to 10 times, checking accuracy each hit (Skill Link: 10 hits, Loaded Dice: 4-10)"),
    "surging_strikes": (None, None, "always hits 3 times, each a critical hit"),
    "triple_dive": ("MULTI_HIT", 0, "always hits 3 times"),
    "glaive_rush": (None, None, "until the user's next move, moves against it never miss and deal double damage"),
    "salt_cure": ("SOVEREIGN_SALT_CURE", 100, "the target loses 1/16 of its max HP each turn (1/8 if Water or Steel; Champions) until it switches out"),
    "syrup_bomb": ("SOVEREIGN_SYRUP_BOMB", 100, "target Speed -1 at the end of each of the next 3 turns, while the user stays in"),
    "rage_fist": (None, None, "50 more power for each hit the user has taken since it came in (Champions), up to 350"),
    # Moves batch 4.
    "thunderclap": ("HIT_FIRST_IF_TARGET_ATTACKING", 0, "+1 priority; fails unless the target is about to use a damaging move (Sucker Punch's effect)"),
    "toxic_thread": ("SOVEREIGN_TOXIC_THREAD", 0, "target Speed -2 (Champions), then poisons it"),
    "tar_shot": ("SOVEREIGN_TAR_SHOT", 0, "target Speed -1; Fire moves are twice as effective against it until it switches out"),
    "eerie_spell": ("SOVEREIGN_EERIE_SPELL", 100, "the target's last move loses 3 PP"),
    "corrosive_gas": ("SOVEREIGN_CORROSIVE_GAS", 0, "takes away the held items of all adjacent Pokémon"),
    "celebrate": ("SOVEREIGN_CELEBRATE", 0, "no effect in battle; congratulates the player"),
    "happy_hour": ("SOVEREIGN_HAPPY_HOUR", 0, "doubles the prize money (on top of an Amulet Coin)"),
    "hold_hands": ("SOVEREIGN_HOLD_HANDS", 0, "no effect in battle; fails without an ally"),
    # Moves batch 5.
    "jaw_lock": ("SOVEREIGN_JAW_LOCK", 0, "the user and the target can't escape while both stay in"),
    "thousand_waves": ("SOVEREIGN_TRAP_ON_HIT", 0, "hits both foes; they can't escape while the user stays in"),
    "thousand_arrows": ("SOVEREIGN_SMACK_DOWN", 0, "hits both foes, airborne ones too (neutral on a Flying type; up in the air"
                         " by Fly, Bounce or Sky Drop too), and grounds them"),
    "sparkling_aria": ("SOVEREIGN_SPARKLING_ARIA", 100, "hits all adjacent Pokémon and heals their burns"),
    "court_change": ("SOVEREIGN_COURT_CHANGE", 0, "swaps the two sides' screens, Tailwind, Mist, Safeguard, Lucky Chant and hazards"),
    "flower_shield": ("SOVEREIGN_FLOWER_SHIELD", 0, "Defense +1 for every Grass type on the field"),
    "tidy_up": ("SOVEREIGN_TIDY_UP", 0, "clears the hazards on both sides and every Substitute; user Attack and Speed +1"),
    # Moves batch 6: protection moves.
    "kings_shield": (None, 0, "protects like Protect, but not from status moves; a contact move it blocks: Attack -1"),
    "spiky_shield": (None, 0, "protects like Protect; a contact move it blocks costs the attacker 1/8 of its max HP"),
    "baneful_bunker": (None, 0, "protects like Protect; a contact move it blocks poisons the attacker"),
    "obstruct": (None, 0, "protects like Protect, but not from status moves; a contact move it blocks: Defense -2"),
    "silk_trap": (None, 0, "protects like Protect, but not from status moves; a contact move it blocks: Speed -1"),
    "burning_bulwark": (None, 0, "protects like Protect, but not from status moves; a contact move it blocks burns the attacker"),
    "mat_block": ("SOVEREIGN_MAT_BLOCK", 0, "user's first turn only: protects its side from damaging moves this turn"),
    "crafty_shield": ("SOVEREIGN_CRAFTY_SHIELD", 0, "protects the user's side from status moves aimed at it this turn"),
    "first_impression": ("SOVEREIGN_FIRST_IMPRESSION", 0, "fails unless it's the user's first turn in battle; can't be chosen after it"),
    # Moves batch 7.
    "v_create": ("SOVEREIGN_V_CREATE", 0, "user Defense, Sp. Def and Speed -1 after the hit"),
    "rototiller": ("SOVEREIGN_ROTOTILLER", 0, "Attack and Sp. Atk +1 for every grounded Grass type on the field"),
    "gear_up": ("SOVEREIGN_GEAR_UP", 0, "Attack and Sp. Atk +1 for the user and its ally if they have Plus or Minus"),
    "magnetic_flux": ("SOVEREIGN_MAGNETIC_FLUX", 0, "Defense and Sp. Def +1 for the user and its ally if they have Plus or Minus"),
    "aromatic_mist": ("SOVEREIGN_AROMATIC_MIST", 0, "the user's ally's Sp. Def +1; fails without an ally"),
    "shore_up": ("HEAL_HALF_MORE_IN_SUN", 0, "heals 1/2 of the user's max HP, 2/3 in a sandstorm"),
    "snipe_shot": (None, 0, "high critical-hit ratio; ignores Follow Me, Lightning Rod and Storm Drain"),
    "water_shuriken": (None, 0, "hits 2-5 times; Ash-Greninja's hits 3 times at 20 power"),
    # Moves batch 8: charge moves.
    "freeze_shock": ("SOVEREIGN_CHARGE_TURN_HIT", 30, "charges for a turn (a Power Herb skips it), then hits; 30% paralysis"),
    "ice_burn": ("SOVEREIGN_CHARGE_TURN_HIT", 30, "charges for a turn (a Power Herb skips it), then hits; 30% burn"),
    "geomancy": ("SOVEREIGN_GEOMANCY", 0, "charges for a turn (a Power Herb skips it), then user Sp. Atk, Sp. Def and Speed +2"),
    # Moves batch 11.
    "chilly_reception": ("SOVEREIGN_CHILLY_RECEPTION", 0, "starts snow for 5 turns, then the user switches out (it still"
                         " switches when it can't start snow)"),
    "doodle": ("SOVEREIGN_DOODLE", 0, "the user and its ally take the target's ability (Role Play's rules)"),
    "core_enforcer": ("SOVEREIGN_CORE_ENFORCER", 0, "hits both foes; suppresses the ability of a target that has already"
                      " acted this turn"),
    "electrify": ("SOVEREIGN_ELECTRIFY", 0, "the target's moves are Electric this turn (fails if it has already acted)"),
    "ion_deluge": ("SOVEREIGN_ION_DELUGE", 0, "+1 priority; Normal moves are Electric this turn"),
    "plasma_fists": ("SOVEREIGN_PLASMA_FISTS", 0, "after the hit, Normal moves are Electric this turn"),
    "fairy_lock": ("SOVEREIGN_FAIRY_LOCK", 0, "no one can flee or switch out this turn and the next (Ghost types can)"),
    "octolock": ("SOVEREIGN_OCTOLOCK", 0, "the target can't escape while the user stays in, and its Defense and Sp. Def"
                 " fall at the end of each turn"),
    "instruct": ("SOVEREIGN_INSTRUCT", 0, "the target uses its last move again right after, as an extra action (not a move"
                 " that charges, recharges, locks it in or calls another move)"),
    "spotlight": ("SOVEREIGN_SPOTLIGHT", 0, "+3 priority; the target's foes aim at it this turn (fails in a single battle)"),
    "teatime": ("SOVEREIGN_TEATIME", 0, "every Pokémon on the field eats its Berry (fails if none holds one)"),
    # Moves batch 12.
    "shell_side_arm": ("POISON_HIT", 20, "20% poison; physical (and contact) when that would do more damage (with the stat"
                       " stages)"),
    "autotomize": ("SOVEREIGN_AUTOTOMIZE", 0, "user Speed +2, and it gets 100 kg lighter"),
    "flame_burst": ("SOVEREIGN_FLAME_BURST", 0, "the target's ally takes 1/16 of its max HP"),
    "pollen_puff": ("SOVEREIGN_POLLEN_PUFF", 0, "damages a foe; restores half an ally's max HP instead"),
    "parabolic_charge": ("RECOVER_HALF_DAMAGE_DEALT", 0, "hits all adjacent Pokémon (its ally too); drains half the"
                         " damage dealt"),
    "sky_drop": ("SOVEREIGN_SKY_DROP", 0, "carries the target up for a turn (out of reach, can't move or switch), then"
                 " drops it; fails on 200 kg or more, no damage to Flying types"),
    # The owner (2026-10-28): the main games' typeless state, a battle-only type of its own (TYPE_SOVEREIGN_TYPELESS).
    "burn_up": ("SOVEREIGN_BURN_OUT_HIT", 0, "fails unless the user is Fire-type; after the hit, the user loses the Fire"
                " type (typeless if it had no other; until it switches out); thaws the user"),
    "double_shock": ("SOVEREIGN_BURN_OUT_HIT", 0, "fails unless the user is Electric-type; after the hit, the user loses"
                     " the Electric type (typeless if it had no other; until it switches out)"),
    # Commander.
    "order_up": (None, 0, "with a Tatsugiri in the user's mouth (Commander), the user's Attack (Curly Form), Defense"
                 " (Droopy) or Speed (Stretchy) +1 after the hit"),
}

# Gen IX values the move data got wrong (not the Champions changes in tools/engine/apply_champions_moves.py).
VALUE_FIXES = {
    "matcha_gotcha": {"range": "RANGE_ADJACENT_OPPONENTS"},
    "cotton_spore": {"range": "RANGE_ADJACENT_OPPONENTS"},
    "poison_gas": {"range": "RANGE_ADJACENT_OPPONENTS"},
    "take_heart": {"pp": 15},
    "roar": {"accuracy": 0},
    "whirlwind": {"accuracy": 0},
    # The engine has no "every Pokemon" range; Flower Shield runs once, as a field move, and finds the Grass types itself.
    "flower_shield": {"range": "RANGE_FIELD"},
    "rototiller": {"range": "RANGE_FIELD"},
    "teatime": {"range": "RANGE_FIELD"},
    # Platinum's own moves under the later games' rules (docs/PlatinumMoveAudit.md): String Shot -2 Speed (Gen VI+),
    # Poison Fang 50% (Gen VI+).
    "string_shot": {"effect": {"type": "BATTLE_EFFECT_SPEED_DOWN_2", "chance": 0}},
    "poison_fang": {"effect": {"type": "BATTLE_EFFECT_BADLY_POISON_HIT", "chance": 50}},
    # Their texts, for the later games' turn counts (Tailwind 4, Taunt and Encore 3) and Teleport's switch (Gen VIII+).
    "tailwind": {"description": ["The user whips up a\n", "turbulent whirlwind\n", "that ups the Speed\n",
                                 "of all party Pokémon\n", "for four turns."]},
    "taunt": {"description": ["The foe is taunted\n", "into a rage that\n", "allows it to use only\n",
                              "attack moves for\n", "three turns."]},
    "encore": {"description": ["The user compels the\n", "foe to keep using\n", "only the move it last\n",
                               "used for three\n", "turns."]},
    "teleport": {"description": ["The user switches\n", "out. A wild Pokémon\n", "flees. It also warps\n",
                                 "to the last Poké\n", "Center visited."]},
    # Batch E: Sweet Scent -2 evasion (Gen VI+), Chatter's sure confusion (Gen VI+), Conversion 2 aimed at the foe's
    # last move (Gen V+), and the texts for them, Tail Glow +3 (Gen V+, effect from gen_stat_moves.py), Conversion's
    # first slot (Gen VI+), Uproar's three turns (Gen V+) and Dark Void for Darkrai only (Gen VII+).
    "sweet_scent": {"effect": {"type": "BATTLE_EFFECT_EVA_DOWN_2", "chance": 0},
                    "description": ["A sweet scent that\n", "harshly lowers the\n", "foe’s evasiveness. It\n",
                                    "also lures wild\n", "Pokémon in grass."]},
    "chatter": {"effect": {"type": "BATTLE_EFFECT_CHATTER", "chance": 100},
                "description": ["The user attacks\n", "using a sound wave\n", "based on words it has\n",
                                "learned. It also\n", "confuses the foe."]},
    "conversion_2": {"range": "RANGE_SINGLE_TARGET",
                     "description": ["The user changes its\n", "type to make itself\n", "resistant to the type\n",
                                     "of the move the foe\n", "used last."]},
    "tail_glow": {"description": ["The user stares at\n", "flashing lights to\n", "focus its mind,\n",
                                  "drastically raising\n", "its Sp. Atk stat."]},
    "conversion": {"description": ["The user changes its\n", "type to become the\n", "same type as the move\n",
                                   "in its first move\n", "slot."]},
    "uproar": {"description": ["The user attacks in\n", "an uproar for three\n", "turns. Over that\n",
                               "time, no one can fall\n", "asleep."]},
    "dark_void": {"description": ["The foes are dragged\n", "into total darkness\n", "that puts them to\n",
                                  "sleep. Only Darkrai\n", "can use it."]},
    # Batch F: a variable-power move has power 1 in the data, as Platinum's have (Taunt, Me First and the trainer AI take
    # a move with power 0 for a status move); Sovereign_MovePower works out Hard Press's.
    "hard_press": {"power": 1},
    # Mirror Move is aimed at a foe and copies that foe's last move (Gen V+).
    "mirror_move": {"range": "RANGE_SINGLE_TARGET"},
    # Batch H: Mud Sport and Water Sport are 5-turn field effects (Gen VI+), and Howl raises the ally's Attack too
    # (Gen VIII+).
    "mud_sport": {"description": ["The user kicks up\n", "mud on the field.\n", "This weakens\n",
                                  "Electric-type moves\n", "for five turns."]},
    "water_sport": {"description": ["The user soaks the\n", "field with water.\n", "This weakens\n",
                                    "Fire-type moves for\n", "five turns."]},
    "howl": {"description": ["The user howls to\n", "raise its spirit\n", "and its ally’s,\n",
                             "boosting their\n", "Attack stats."]},
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
    for move in sorted(set(FLAGS) | set(FLAG_FIXES) | set(MOVES) | set(VALUE_FIXES)):
        path = os.path.join(MOVES_DIR, move, "data.json")
        data = json.load(open(path, encoding="utf-8"))
        if move in FLAGS:
            keep = [f for f in data["flags"] if f not in OWN_FLAGS]
            data["flags"] = [f for f in OWN_FLAGS if f in FLAGS[move]] + keep
        if move in FLAG_FIXES:
            add, remove = FLAG_FIXES[move]
            flags = [f for f in data["flags"] if f not in remove] + [f for f in add if f not in data["flags"]]
            data["flags"] = [f for f in OWN_FLAGS if f in flags] + [f for f in flags if f not in OWN_FLAGS]
        if move in MOVES and MOVES[move][0] is not None:
            data["effect"] = {"type": "BATTLE_EFFECT_" + MOVES[move][0], "chance": MOVES[move][1]}
        data.update(VALUE_FIXES.get(move, {}))
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
