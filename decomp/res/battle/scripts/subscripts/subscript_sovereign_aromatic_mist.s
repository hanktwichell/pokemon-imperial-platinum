#include "macros/btlcmd.inc"

// Sovereign (item 11): Aromatic Mist raises the Sp. Def of the user's ally by 1 stage. It fails without an ally.

_000:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_DOUBLES, _fail
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_ATTACKER
    UpdateVar OPCODE_BITWISE_XOR, BTLVAR_SIDE_EFFECT_MON, 2
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _fail
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SP_DEFENSE_UP_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
