#include "macros/btlcmd.inc"

// Sovereign (item 11): Jaw Lock. Damage, then neither the user nor the target can escape.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_JAW_LOCK
    CalcCrit 
    CalcDamage 
    End 
