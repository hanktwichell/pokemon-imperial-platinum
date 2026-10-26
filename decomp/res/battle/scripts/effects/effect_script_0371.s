#include "macros/btlcmd.inc"

// Sovereign (item 11): Gear Up, subscript_sovereign_gear_up.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_SOVEREIGN_GEAR_UP
    End 
