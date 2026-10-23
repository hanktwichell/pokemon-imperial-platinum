#include "macros/btlcmd.inc"

// Sovereign (item 11): damage, then the target is dragged out (Dragon Tail, Circle Throw).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_SOVEREIGN_DRAG_OUT
    CalcCrit 
    CalcDamage 
    End 
