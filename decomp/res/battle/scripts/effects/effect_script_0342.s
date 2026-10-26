#include "macros/btlcmd.inc"

// Sovereign (item 11): damage, then (effect chance) the target falls asleep. Relic Song, Wicked Torque.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SLEEP
    CalcCrit 
    CalcDamage 
    End 
