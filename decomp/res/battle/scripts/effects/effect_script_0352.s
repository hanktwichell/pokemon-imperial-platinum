#include "macros/btlcmd.inc"

// Sovereign (item 11): Toxic Thread, subscript_sovereign_toxic_thread.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_TOXIC_THREAD
    End 
