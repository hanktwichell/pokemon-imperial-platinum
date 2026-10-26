#include "macros/btlcmd.inc"

// Sovereign (item 11): Rototiller raises the Attack and Sp. Atk of every grounded Grass-type Pokemon on the field by 1
// stage, in speed order. It doesn't affect a Pokemon off the ground. It fails when there is neither.

_000:
    // First pass: is there anything to do?
    UpdateVar OPCODE_SET, BTLVAR_BATTLER_SPEED_TEMP, 0

_check:
    GetMonBySpeedOrder BTLVAR_SIDE_EFFECT_MON
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _check_next
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SIDE_EFFECT_MON_GROUNDED, 0, _works
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_1, TYPE_GRASS, _works
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_2, TYPE_GRASS, _works

_check_next:
    UpdateVar OPCODE_ADD, BTLVAR_BATTLER_SPEED_TEMP, 1
    GoToIfValidMon BTLVAR_BATTLER_SPEED_TEMP, _check
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 

_works:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_ATTACK_MESSAGE|SYSCTL_PLAYED_MOVE_ANIMATION
    UpdateVar OPCODE_SET, BTLVAR_BATTLER_SPEED_TEMP, 0

_loop:
    GetMonBySpeedOrder BTLVAR_SIDE_EFFECT_MON
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _next
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SIDE_EFFECT_MON_GROUNDED, 0, _airborne
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_1, TYPE_GRASS, _raise
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_2, TYPE_GRASS, _next

_raise:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SP_ATTACK_UP_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    GoTo _next

_airborne:
    // It doesn’t affect {0}...
    PrintMessage BattleStrings_Text_ItDoesntAffectPokemon_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30

_next:
    UpdateVar OPCODE_ADD, BTLVAR_BATTLER_SPEED_TEMP, 1
    GoToIfValidMon BTLVAR_BATTLER_SPEED_TEMP, _loop
    End 
