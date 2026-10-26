#include "macros/btlcmd.inc"

// Sovereign (item 11): Happy Hour, subscript_sovereign_happy_hour.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_SOVEREIGN_HAPPY_HOUR
    End 
