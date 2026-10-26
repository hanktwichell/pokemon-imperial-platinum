#include "macros/btlcmd.inc"

// Sovereign (item 11): V-create. Damage, then the user's Defense, Sp. Def and Speed -1 (not a chance effect).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_V_CREATE
    CalcCrit 
    CalcDamage 
    End 
