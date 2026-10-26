#include "macros/btlcmd.inc"

// Sovereign (item 11): Supersweet Syrup. The first time the holder enters the battle, each foe's evasiveness drops 1
// stage, as Intimidate does Attack (BattleSystem_TriggerEffectOnSwitch). The holder is BTLVAR_MSG_BATTLER_TEMP.

_000:
    WaitButtonABTime 15
    UpdateVar OPCODE_SET, BTLVAR_BATTLER_SPEED_TEMP, 0
    UpdateVarFromVar OPCODE_SET, BTLVAR_LAST_BATTLER_ID, BTLVAR_ATTACKER
    UpdateVarFromVar OPCODE_SET, BTLVAR_ATTACKER, BTLVAR_MSG_BATTLER_TEMP

_loop:
    GetMonBySpeedOrder BTLVAR_SIDE_EFFECT_MON
    IfSameSide BTLSCR_ATTACKER, BTLSCR_SIDE_EFFECT_MON, _next
    CheckSubstitute BTLSCR_SIDE_EFFECT_MON, _next
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _next
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_EVASION_DOWN_1_STAGE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE

_next:
    UpdateVar OPCODE_ADD, BTLVAR_BATTLER_SPEED_TEMP, 1
    GoToIfValidMon BTLVAR_BATTLER_SPEED_TEMP, _loop
    UpdateVarFromVar OPCODE_SET, BTLVAR_ATTACKER, BTLVAR_LAST_BATTLER_ID
    End 
