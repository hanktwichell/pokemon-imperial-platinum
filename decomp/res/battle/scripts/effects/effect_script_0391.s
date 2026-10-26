#include "macros/btlcmd.inc"

// Sovereign (item 11): Pollen Puff. Damage to a foe; on an ally it restores half its max HP instead, through
// subscript_present_heal (Heal Block stops it).

_000:
    IfSameSide BTLSCR_ATTACKER, BTLSCR_DEFENDER, _ally
    CalcCrit
    CalcDamage
    End

_ally:
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_DEFENDER, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 2
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_DEFENDER
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_PRESENT_HEAL
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_IGNORE_IMMUNITIES
    UpdateVar OPCODE_SET, BTLVAR_MOVE_EFFECT_CHANCE, 1
    End
