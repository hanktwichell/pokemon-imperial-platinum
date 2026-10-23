#include "macros/btlcmd.inc"

// Sovereign (item 11): Speed Swap. The user and the target swap their Speed stats.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_SPEED, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_DEFENDER, BATTLEMON_SPEED, BTLVAR_HP_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_SPEED, BTLVAR_HP_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_SPEED, BTLVAR_CALC_TEMP
    // {0} switched Speed with its target!
    PrintMessage BattleStrings_Text_SovereignSwitchedSpeed_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
