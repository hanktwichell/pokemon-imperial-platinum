#include "macros/btlcmd.inc"

// Sovereign (item 11): Lunar Blessing and Jungle Healing restore 1/4 of the max HP of the user and its ally, and heal
// their status conditions.

_000:
    PrintAttackMessage 
    Wait 
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 4
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    Call BATTLE_SUBSCRIPT_RECOVER_HP
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    CompareMonDataToValue OPCODE_EQU, BTLSCR_MSG_TEMP, BATTLEMON_STATUS, MON_CONDITION_NONE, _ally
    UpdateMonData OPCODE_SET, BTLSCR_MSG_TEMP, BATTLEMON_STATUS, MON_CONDITION_NONE
    // {0}’s status returned to normal!
    PrintMessage BattleStrings_Text_PokemonsStatusReturnedToNormal_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    SetHealthBoxStatusIcon BTLSCR_MSG_TEMP, BATTLE_ANIMATION_NONE
    WaitButtonABTime 30

_ally:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_DOUBLES, _end
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    UpdateVar OPCODE_BITWISE_XOR, BTLVAR_MSG_BATTLER_TEMP, 2
    CompareMonDataToValue OPCODE_EQU, BTLSCR_MSG_TEMP, BATTLEMON_CUR_HP, 0, _end
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_MSG_TEMP, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 4
    Call BATTLE_SUBSCRIPT_RECOVER_HP
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    UpdateVar OPCODE_BITWISE_XOR, BTLVAR_MSG_BATTLER_TEMP, 2
    CompareMonDataToValue OPCODE_EQU, BTLSCR_MSG_TEMP, BATTLEMON_STATUS, MON_CONDITION_NONE, _end
    UpdateMonData OPCODE_SET, BTLSCR_MSG_TEMP, BATTLEMON_STATUS, MON_CONDITION_NONE
    // {0}’s status returned to normal!
    PrintMessage BattleStrings_Text_PokemonsStatusReturnedToNormal_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    SetHealthBoxStatusIcon BTLSCR_MSG_TEMP, BATTLE_ANIMATION_NONE
    WaitButtonABTime 30

_end:
    End 
