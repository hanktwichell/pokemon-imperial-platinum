#include "macros/btlcmd.inc"

// Sovereign (item 11): Jaw Lock. After the hit, the user and the target are each trapped by the other (as Mean Look),
// until one of them leaves the field. Not through a Substitute.

_000:
    CheckSubstitute BTLSCR_DEFENDER, _end
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_CUR_HP, 0, _end
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0, _end
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, 0
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_DEFENDER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_MEAN_LOOK, _user
    UpdateMonData OPCODE_FLAG_ON, BTLSCR_DEFENDER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_MEAN_LOOK
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_MEAN_LOOK_TARGET, BTLVAR_ATTACKER
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, 1

_user:
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_ATTACKER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_MEAN_LOOK, _message
    UpdateMonData OPCODE_FLAG_ON, BTLSCR_ATTACKER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_MEAN_LOOK
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_MEAN_LOOK_TARGET, BTLVAR_DEFENDER
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, 1

_message:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0, _end
    // Neither Pokémon can run away!
    PrintMessage BattleStrings_Text_SovereignNeitherCanRunAway, TAG_NONE
    Wait 
    WaitButtonABTime 30

_end:
    End 
