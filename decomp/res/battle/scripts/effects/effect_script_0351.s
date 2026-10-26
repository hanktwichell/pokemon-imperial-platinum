#include "macros/btlcmd.inc"

// Sovereign (item 11): Syrup Bomb. Damage, then (effect chance, 100%) subscript_sovereign_syrup_bomb on the target.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_SYRUP_BOMB
    CalcCrit 
    CalcDamage 
    End 
