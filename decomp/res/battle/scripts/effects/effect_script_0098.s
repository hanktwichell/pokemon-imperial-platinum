#include "macros/btlcmd.inc"


_000:
    // Sovereign: it fails when the user's last move was a Destiny Bond still active (Gen VII+).
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_ATTACKER_SELF_TURN_STATUS_FLAGS, SELF_TURN_FLAG_SOVEREIGN_DESTINY_BOND_AGAIN, _sovereign_fail
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_DESTINY_BOND
    End 

_sovereign_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
