#include "macros/btlcmd.inc"

// Sovereign (item 11): Throat Chop. Damage, then the target can't use sound moves for two turns.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_THROAT_CHOP
    CalcCrit 
    CalcDamage 
    End 
