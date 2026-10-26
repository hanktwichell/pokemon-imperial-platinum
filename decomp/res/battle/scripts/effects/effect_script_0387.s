#include "macros/btlcmd.inc"

// Sovereign (item 11): Spotlight, subscript_sovereign_spotlight.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_CHECK_HP|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_SPOTLIGHT
    End
