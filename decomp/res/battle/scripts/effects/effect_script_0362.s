#include "macros/btlcmd.inc"

// Sovereign (item 11): Court Change, subscript_sovereign_court_change.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_SOVEREIGN_COURT_CHANGE
    End 
