#include "macros/btlcmd.inc"

// Sovereign (item 11): Clear Smog.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_CLEAR_SMOG
    CalcCrit 
    CalcDamage 
    End 
