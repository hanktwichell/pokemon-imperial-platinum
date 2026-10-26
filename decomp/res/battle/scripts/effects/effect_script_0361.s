#include "macros/btlcmd.inc"

// Sovereign (item 11): Sparkling Aria. Damage, then (effect chance, 100%) the target's burn is healed.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_SPARKLING_ARIA
    CalcCrit 
    CalcDamage 
    End 
