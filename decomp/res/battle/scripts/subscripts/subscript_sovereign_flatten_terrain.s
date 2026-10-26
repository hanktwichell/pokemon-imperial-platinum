#include "macros/btlcmd.inc"

// Sovereign (item 11): Steel Roller and Ice Spinner. After the hit, the terrain ends, with its message, if the user
// is still standing.

_000:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_TERRAIN, _end
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0, _end
    Call BATTLE_SUBSCRIPT_SOVEREIGN_TERRAIN_END

_end:
    End 
