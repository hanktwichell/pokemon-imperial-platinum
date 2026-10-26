#include "macros/btlcmd.inc"

// Sovereign (item 11): Triple Arrows. Damage, then subscript_sovereign_triple_arrows (Defense drop, flinch).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_TRIPLE_ARROWS
    CalcCrit 
    CalcDamage 
    End 
