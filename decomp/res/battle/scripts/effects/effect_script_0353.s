#include "macros/btlcmd.inc"

// Sovereign (item 11): Tar Shot, subscript_sovereign_tar_shot.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_TAR_SHOT
    End 
