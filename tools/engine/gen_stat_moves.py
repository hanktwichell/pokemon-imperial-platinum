#!/usr/bin/env python3
"""Give Gen V+ stat-changing status moves their exact effect (item 11).

Platinum handles a status move that changes several stats (Calm Mind, Dragon Dance, Tickle...) with an effect script
that points at a subscript through a MOVE_SUBSCRIPT_PTR_* side effect; the subscript calls
BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE once per stat. For each move in STAT_MOVES this writes the same pieces:

* subscript_sovereign_stats_<move>.s, registered in the subscripts' meson.build, sub_seq.order and
  generated/battle_subscripts.txt (all three must stay in the same order);
* MOVE_SUBSCRIPT_PTR_SOVEREIGN_<MOVE> in generated/battle_move_subscript_ptrs.txt and its entry in
  include/data/move_side_effect_subscripts.h;
* BATTLE_EFFECT_SOVEREIGN_<MOVE> in generated/move_battle_effects.txt and its effect script;
* the move's data.json effect, gen_moves.py's SOVEREIGN_EFFECTS entry and the docs/MoveChecklist.md row.

Anything already present is left alone, so the script can be re-run after adding a move.

Usage: python3 tools/engine/gen_stat_moves.py
"""
import json
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")

# move stem -> (target, [(stat, stages)]). target "user" or "target". A change of 3 is applied as +2 then +1.
STAT_MOVES = {
    "hone_claws": ("user", [("ATTACK", 1), ("ACCURACY", 1)]),
    "work_up": ("user", [("ATTACK", 1), ("SP_ATTACK", 1)]),
    "coil": ("user", [("ATTACK", 1), ("DEFENSE", 1), ("ACCURACY", 1)]),
    "quiver_dance": ("user", [("SP_ATTACK", 1), ("SP_DEFENSE", 1), ("SPEED", 1)]),
    "shell_smash": ("user", [("DEFENSE", -1), ("SP_DEFENSE", -1), ("ATTACK", 2), ("SP_ATTACK", 2), ("SPEED", 2)]),
    "cotton_guard": ("user", [("DEFENSE", 3)]),
    "shift_gear": ("user", [("ATTACK", 1), ("SPEED", 2)]),
    "victory_dance": ("user", [("ATTACK", 1), ("DEFENSE", 1), ("SPEED", 1)]),
    "noble_roar": ("target", [("ATTACK", -1), ("SP_ATTACK", -1)]),
    "tearful_look": ("target", [("ATTACK", -1), ("SP_ATTACK", -1)]),
    "venom_drench": ("target", [("ATTACK", -1), ("SP_ATTACK", -1), ("SPEED", -1)], "poisoned"),
    "no_retreat": ("user", [("ATTACK", 1), ("DEFENSE", 1), ("SP_ATTACK", 1), ("SP_DEFENSE", 1), ("SPEED", 1)]),
    "clangorous_soul": ("user", [("ATTACK", 1), ("DEFENSE", 1), ("SP_ATTACK", 1), ("SP_DEFENSE", 1), ("SPEED", 1)], "hp_cost_3"),
    "spicy_extract": ("target", [("ATTACK", 2), ("DEFENSE", -2)]),
    "fillet_away": ("user", [("ATTACK", 2), ("SP_ATTACK", 2), ("SPEED", 2)], "hp_cost_2"),
    "take_heart": ("user", [("SP_ATTACK", 1), ("SP_DEFENSE", 1)], "cure"),
}
# Optional further elements: "poisoned" = fails unless the target is poisoned (Venom Drench); "hp_cost_N" = the user
# first loses 1/N of its max HP, and the move fails at 1/N or less (Clangorous Soul, Fillet Away); "cure" = the user's
# status condition is healed after the stat changes (Take Heart).

STAGE_FIELD = {s: f"BATTLEMON_{s}_STAGE" for s in ("ATTACK", "DEFENSE", "SPEED", "SP_ATTACK", "SP_DEFENSE", "ACCURACY", "EVASION")}
STAT_NAME = {"ATTACK": "Attack", "DEFENSE": "Defense", "SPEED": "Speed", "SP_ATTACK": "Sp. Atk", "SP_DEFENSE": "Sp. Def",
             "ACCURACY": "accuracy", "EVASION": "evasion"}


def ptr(stat, stages):
    direction = "UP" if stages > 0 else "DOWN"
    n = abs(stages)
    return f"MOVE_SUBSCRIPT_PTR_{stat}_{direction}_{'1_STAGE' if n == 1 else '2_STAGES'}"


def steps(changes):
    for stat, stages in changes:
        if abs(stages) == 3:
            yield stat, 2 if stages > 0 else -2
            yield stat, 1 if stages > 0 else -1
        else:
            yield stat, stages


def subscript_text(stem, target, changes, opts=()):
    name = stem.replace("_", " ").title()
    calls = "".join(f"    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, {ptr(s, n)}\n    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE\n"
                    for s, n in steps(changes))
    if target == "user":
        raised = [s for s, n in changes if n > 0]
        checks = "".join(f"    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, {STAGE_FIELD[s]}, 12, _change\n" for s in raised[:-1])
        checks += f"    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, {STAGE_FIELD[raised[-1]]}, 12, _no_change\n"
        cost = next((int(o[len("hp_cost_"):]) for o in opts if o.startswith("hp_cost_")), 0)
        pay = fail = cure = ""
        if cost:
            checks = (f"    // The user needs more than 1/{cost} of its max HP.\n"
                      "    UpdateMonDataFromVar OPCODE_GET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP\n"
                      f"    DivideVarByValue BTLVAR_HP_CALC_TEMP, {cost}\n"
                      "    CompareMonDataToVar OPCODE_LTE, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, BTLVAR_HP_CALC_TEMP, _failed\n") + checks
            pay = ("    UpdateMonDataFromVar OPCODE_GET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP\n"
                   f"    DivideVarByValue BTLVAR_HP_CALC_TEMP, {cost}\n"
                   "    UpdateVar OPCODE_MUL, BTLVAR_HP_CALC_TEMP, -1\n"
                   "    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_SIDE_EFFECT_MON\n"
                   "    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK\n"
                   "    Call BATTLE_SUBSCRIPT_UPDATE_HP\n")
            fail = "\n_failed:\n    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED\n    End\n"
        if "cure" in opts:
            cure = ("    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_TURN_OFF_MESSAGES\n"
                    "    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_NONE, _end\n"
                    "    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_NONE\n"
                    "    // {0}’s status returned to normal!\n"
                    "    PrintMessage BattleStrings_Text_PokemonsStatusReturnedToNormal_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON\n"
                    "    Wait\n"
                    "    SetHealthBoxStatusIcon BTLSCR_SIDE_EFFECT_MON, BATTLE_ANIMATION_NONE\n"
                    "    WaitButtonABTime 30\n\n"
                    "_end:\n")
        return f'''#include "macros/btlcmd.inc"

// Sovereign (item 11): {name}. Generated by tools/engine/gen_stat_moves.py.

_000:
{checks}
_change:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
{pay}    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_TURN_OFF_MESSAGES
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_ATTACK_MESSAGE|SYSCTL_PLAYED_MOVE_ANIMATION
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_STAT_STAGE_CHANGE_SHOWN
{calls}    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_UPDATE_STAT_STAGES
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_STAT_STAGE_CHANGE_SHOWN
{cure}    End
{fail}
_no_change:
    PrintAttackMessage
    Wait
    WaitButtonABTime 30
    // {{0}}’s stats won’t go any higher!
    PrintMessage BattleStrings_Text_PokemonsStatsWontGoAnyHigher_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK
    End
'''
    lowered = [s for s, n in changes if n < 0]
    checks = ""
    if "poisoned" in opts:
        checks += "    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_ANY_POISON, _failed\n"
    checks += "".join(f"    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, {STAGE_FIELD[s]}, 0, _change\n" for s in lowered[:-1])
    checks += f"    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, {STAGE_FIELD[lowered[-1]]}, 0, _no_change\n"
    first, rest = calls.split("    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE\n", 1)
    return f'''#include "macros/btlcmd.inc"

// Sovereign (item 11): {name}. Generated by tools/engine/gen_stat_moves.py.

_000:
{checks}
_change:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _failed
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_STAT_STAGE_CHANGE_SHOWN
{first}    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_TURN_OFF_MESSAGES
{rest}    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_UPDATE_STAT_STAGES
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_STAT_STAGE_CHANGE_SHOWN
    End

_failed:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End

_no_change:
    PrintAttackMessage
    Wait
    WaitButtonABTime 30
    // {{0}}’s stats won’t go any lower!
    PrintMessage BattleStrings_Text_PokemonsStatsWontGoAnyLower_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK
    End
'''


def lines(path):
    with open(path) as f:
        return [l.rstrip("\n") for l in f if l.strip()]


def append_line(path, line):
    if line not in lines(path):
        with open(path, "a") as f:
            f.write(line + "\n")


def main():
    subdir = os.path.join(DECOMP, "res", "battle", "scripts", "subscripts")
    effdir = os.path.join(DECOMP, "res", "battle", "scripts", "effects")
    effects_txt = os.path.join(DECOMP, "generated", "move_battle_effects.txt")
    ptrs_txt = os.path.join(DECOMP, "generated", "battle_move_subscript_ptrs.txt")
    table_h = os.path.join(DECOMP, "include", "data", "move_side_effect_subscripts.h")
    checklist = os.path.join(ROOT, "docs", "MoveChecklist.md")
    gen_moves = os.path.join(ROOT, "tools", "engine", "gen_moves.py")

    for stem, (target, changes, *opts) in STAT_MOVES.items():
        sub = f"subscript_sovereign_stats_{stem}"
        p = f"MOVE_SUBSCRIPT_PTR_SOVEREIGN_{stem.upper()}"
        eff = f"BATTLE_EFFECT_SOVEREIGN_{stem.upper()}"

        # Subscript and its three registrations.
        with open(os.path.join(subdir, sub + ".s"), "w") as f:
            f.write(subscript_text(stem, target, changes, opts))
        meson = os.path.join(subdir, "meson.build")
        s = open(meson).read()
        if f"'{sub}.s'" not in s:
            s = s.rstrip().rstrip(")").rstrip() + f"\n    '{sub}.s',\n)\n"
            open(meson, "w").write(s)
        append_line(os.path.join(subdir, "sub_seq.order"), sub)
        append_line(os.path.join(DECOMP, "generated", "battle_subscripts.txt"), "BATTLE_SUBSCRIPT_" + sub[len("subscript_"):].upper())

        # Side-effect pointer and table entry.
        append_line(ptrs_txt, p)
        s = open(table_h).read()
        if f"[{p}]" not in s:
            s = s.replace("};\n// clang-format on", f"    [{p}] = {sub},\n}};\n// clang-format on", 1)
            open(table_h, "w").write(s)

        # Battle effect and its script.
        if eff not in lines(effects_txt):
            append_line(effects_txt, eff)
        index = lines(effects_txt).index(eff)
        flags = "MOVE_SIDE_EFFECT_TO_ATTACKER" if target == "user" else "MOVE_SIDE_EFFECT_CHECK_HP|MOVE_SIDE_EFFECT_TO_DEFENDER"
        with open(os.path.join(effdir, f"effect_script_{index:04d}.s"), "w") as f:
            f.write(f'#include "macros/btlcmd.inc"\n\n// Sovereign (item 11): {stem.replace("_", " ").title()}. Generated by tools/engine/gen_stat_moves.py.\n\n'
                    f"_000:\n    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, {flags}|{p}\n    End \n")
        meson = os.path.join(effdir, "meson.build")
        s = open(meson).read()
        name = f"effect_script_{index:04d}.s"
        if f"'{name}'" not in s:
            last = re.findall(r"'(effect_script_\d+\.s)'", s)[-1]
            s = s.replace(f"    '{last}'\n", f"    '{last}',\n    '{name}'\n", 1)
            open(meson, "w").write(s)

        # Move data, generator and checklist.
        data = os.path.join(DECOMP, "res", "moves", stem, "data.json")
        d = json.load(open(data))
        d["effect"] = {"type": eff, "chance": 0}
        with open(data, "w", encoding="utf-8") as f:
            json.dump(d, f, indent=4, ensure_ascii=False)
            f.write("\n")
        note = "Sovereign effect: " + ", ".join(f"{'user' if target == 'user' else 'target'} {STAT_NAME[s]} {n:+d}" for s, n in changes)
        cost = next((o[len("hp_cost_"):] for o in opts if o.startswith("hp_cost_")), None)
        if cost:
            note += f"; costs 1/{cost} of the user's max HP"
        if "cure" in opts:
            note += "; heals the user's status condition"
        s = open(gen_moves).read()
        ident = stem.replace("_", "-")
        if f'"{ident}":' not in s:
            s = s.replace("SOVEREIGN_EFFECTS = {\n", f'SOVEREIGN_EFFECTS = {{\n    "{ident}": ("SOVEREIGN_{stem.upper()}", 0, "{note}"),\n', 1)
            open(gen_moves, "w").write(s)
        s = open(checklist).read()
        title = d["name"]
        m = re.search(r"\| (\d+) \| %s \| (\w+) \| `[A-Z_0-9]+` \| (approximate|placeholder) \| [^\n]*\|" % re.escape(title), s)
        if m:
            old = m.group(3)
            s = s.replace(m.group(0), f"| {m.group(1)} | {title} | {m.group(2)} | `SOVEREIGN_{stem.upper()}` | exact | {note} |", 1)
            s = re.sub(r"\| exact \| (\d+) \|", lambda x: f"| exact | {int(x.group(1)) + 1} |", s, count=1)
            s = re.sub(r"\| %s \| (\d+) \|" % old, lambda x: f"| {old} | {int(x.group(1)) - 1} |", s, count=1)
            open(checklist, "w").write(s)
        print(f"{stem}: {eff} = {index}")


if __name__ == "__main__":
    main()
