#include "macros/btlcmd.inc"


_000:
    // Sovereign: Dark Void fails unless the user is Darkrai (Gen VII+). A reflected Dark Void (Magic Coat, Magic
    // Bounce) still works.
    CompareVarToValue OPCODE_NEQ, BTLVAR_CURRENT_MOVE, MOVE_DARK_VOID, _sleep
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_REUSE_LAST_MOVE, _sleep
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_SPECIES, SPECIES_DARKRAI, _sleep
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End

_sleep:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SLEEP
    End 
