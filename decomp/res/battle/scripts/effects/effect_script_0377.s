#include "macros/btlcmd.inc"

// Sovereign (item 11): Steel Roller and Ice Spinner. Damage, then the terrain ends (subscript_sovereign_flatten_terrain).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_FLATTEN_TERRAIN
    CalcCrit 
    CalcDamage 
    End 
