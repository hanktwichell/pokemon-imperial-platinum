#include "macros/btlcmd.inc"

// Sovereign (item 11): Tidy Up, subscript_sovereign_tidy_up.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_SOVEREIGN_TIDY_UP
    End 
