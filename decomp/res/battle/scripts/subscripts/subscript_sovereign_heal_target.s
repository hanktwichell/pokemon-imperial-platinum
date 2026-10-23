#include "macros/btlcmd.inc"

// Sovereign (item 11): Heal Pulse and Floral Healing restore half the target's max HP (Heal Pulse 3/4 with Mega
// Launcher, Floral Healing 2/3 in Grassy Terrain).

_000:
    PrintAttackMessage 
    Wait 
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_DEFENDER, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    CompareVarToValue OPCODE_NEQ, BTLVAR_CURRENT_MOVE, MOVE_HEAL_PULSE, _floral
    CheckAbility CHECK_NOT_HAVE, BTLSCR_ATTACKER, ABILITY_MEGA_LAUNCHER, _half
    UpdateVar OPCODE_MUL, BTLVAR_HP_CALC_TEMP, 3
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 4
    GoTo _heal

_floral:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_TERRAIN_GRASSY, _half
    UpdateVar OPCODE_MUL, BTLVAR_HP_CALC_TEMP, 2
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 3
    GoTo _heal

_half:
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 2

_heal:
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_DEFENDER
    Call BATTLE_SUBSCRIPT_RECOVER_HP
    End 
