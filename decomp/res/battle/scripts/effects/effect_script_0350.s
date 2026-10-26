#include "macros/btlcmd.inc"

// Sovereign (item 11): Salt Cure. Damage, then (effect chance, 100%) subscript_sovereign_salt_cure on the target.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_SALT_CURE
    CalcCrit 
    CalcDamage 
    End 
