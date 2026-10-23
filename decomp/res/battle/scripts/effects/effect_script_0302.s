#include "macros/btlcmd.inc"

// Sovereign (item 11): damage, then the target is grounded (Smack Down).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_SMACK_DOWN
    CalcCrit 
    CalcDamage 
    End 
