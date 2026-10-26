#include "macros/btlcmd.inc"


_000:
    CheckSubstitute BTLSCR_DEFENDER, _022
    // Sovereign (item 11): double power against a Comatose target too; there's no sleep to heal.
    CheckAbility CHECK_HAVE, BTLSCR_DEFENDER, ABILITY_COMATOSE, _sovereign_double
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_DEFENDER, BATTLEMON_STATUS, MON_CONDITION_SLEEP, _014
    UpdateVar OPCODE_SET, BTLVAR_POWER_MULTI, 10
    GoTo _022

_014:
    UpdateVar OPCODE_SET, BTLVAR_POWER_MULTI, 20
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_HEAL_TARGET_SLEEP

_sovereign_double:
    UpdateVar OPCODE_SET, BTLVAR_POWER_MULTI, 20

_022:
    CalcCrit 
    CalcDamage 
    End 
