#include "macros/btlcmd.inc"


_000:
    RapidSpin 
    // Sovereign (item 11): since Gen VIII, Rapid Spin also raises the user's Speed 1 stage
    CompareVarToValue OPCODE_NEQ, BTLVAR_CURRENT_MOVE, MOVE_RAPID_SPIN, _end
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0, _end
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_ATTACKER
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SPEED_UP_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE

_end:
    End 
