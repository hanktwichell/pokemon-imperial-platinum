#include "macros/btlcmd.inc"

// Sovereign (item 11): Opportunist copies the stat rises its holder's foes just got, as a Mirror Herb does
// (Sovereign_SetupMirrorHerb: the holder is BTLVAR_MSG_BATTLER_TEMP), every time.

_next:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_MIRROR_HERB_NEXT, 0, _end
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_MSG_BATTLER_TEMP
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    GoTo _next

_end:
    End 
