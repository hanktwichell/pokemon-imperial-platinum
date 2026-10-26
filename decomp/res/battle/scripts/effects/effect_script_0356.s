#include "macros/btlcmd.inc"

// Sovereign (item 11): Celebrate, subscript_sovereign_celebrate.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_SOVEREIGN_CELEBRATE
    End 
