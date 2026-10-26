#include "macros/btlcmd.inc"

// Sovereign (item 11): Flower Shield raises the Defense of every Grass-type Pokemon on the field by 1 stage, in speed
// order. It fails when there is none.

_000:
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, 0
    UpdateVar OPCODE_SET, BTLVAR_BATTLER_SPEED_TEMP, 0

_loop:
    GetMonBySpeedOrder BTLVAR_SIDE_EFFECT_MON
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _next
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_1, TYPE_GRASS, _raise
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_2, TYPE_GRASS, _next

_raise:
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, 1
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_DEFENSE_UP_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE

_next:
    UpdateVar OPCODE_ADD, BTLVAR_BATTLER_SPEED_TEMP, 1
    GoToIfValidMon BTLVAR_BATTLER_SPEED_TEMP, _loop
    CompareVarToValue OPCODE_NEQ, BTLVAR_CALC_TEMP, 0, _end
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED

_end:
    End 
