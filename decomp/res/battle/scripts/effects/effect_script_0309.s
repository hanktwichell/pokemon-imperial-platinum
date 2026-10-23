#include "macros/btlcmd.inc"

// Sovereign (item 11): Heal Pulse, Floral Healing.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_SOVEREIGN_HEAL_TARGET
    End 
