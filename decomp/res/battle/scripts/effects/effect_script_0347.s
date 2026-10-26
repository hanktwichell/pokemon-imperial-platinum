#include "macros/btlcmd.inc"

// Sovereign (item 11): Mortal Spin. Damage, then subscript_sovereign_mortal_spin (poison, Rapid Spin's clearing).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_MORTAL_SPIN
    CalcCrit 
    CalcDamage 
    End 
