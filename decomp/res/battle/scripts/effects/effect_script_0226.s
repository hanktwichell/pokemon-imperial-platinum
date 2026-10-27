#include "macros/btlcmd.inc"


_000:
    // Sovereign: a substitute stops it only on an ally; the user's own doesn't (Gen V+).
    CompareVarToVar OPCODE_EQU, BTLVAR_ATTACKER, BTLVAR_DEFENDER, _boost
    CheckSubstitute BTLSCR_DEFENDER, _005

_boost:
    BoostRandomStatBy2 _005
    End 

_005:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
