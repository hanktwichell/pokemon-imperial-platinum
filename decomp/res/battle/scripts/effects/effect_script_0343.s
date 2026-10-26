#include "macros/btlcmd.inc"

// Sovereign (item 11): Dire Claw. Damage, then (effect chance) the target falls asleep, is poisoned or is paralyzed,
// each as likely (Tri Attack's pattern).

_000:
    Random 2, MOVE_SUBSCRIPT_PTR_SLEEP
    CompareVarToValue OPCODE_NEQ, BTLVAR_CALC_TEMP, MOVE_SUBSCRIPT_PTR_BURN, _set
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, MOVE_SUBSCRIPT_PTR_PARALYZE

_set:
    UpdateVar OPCODE_ADD, BTLVAR_CALC_TEMP, MOVE_SIDE_EFFECT_TO_DEFENDER
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, BTLVAR_CALC_TEMP
    CalcCrit 
    CalcDamage 
    End 
