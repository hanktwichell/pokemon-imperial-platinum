#include "macros/btlcmd.inc"

// Sovereign (item 11): Matcha Gotcha. Damage, then subscript_sovereign_matcha_gotcha (drain, burn chance).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_MATCHA_GOTCHA
    CalcCrit 
    CalcDamage 
    End 
