#include "macros/btlcmd.inc"

// Sovereign (item 11): Steel Beam. Damage, then the user loses half its max HP.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_HALF_HP_COST
    CalcCrit 
    CalcDamage 
    End 
