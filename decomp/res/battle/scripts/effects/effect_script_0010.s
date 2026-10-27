#include "macros/btlcmd.inc"


_000:
    // Sovereign: Howl raises its user's ally's Attack too (Gen VIII+), in subscript_sovereign_howl.
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_HOWL, _howl
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE
    End 

_howl:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_HOWL
    End 
