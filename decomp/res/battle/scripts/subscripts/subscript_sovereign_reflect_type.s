#include "macros/btlcmd.inc"

// Sovereign (item 11): Reflect Type gives the user the target's types (not Arceus or Silvally).

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_SPECIES, SPECIES_ARCEUS, _fail
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_SPECIES, SPECIES_SILVALLY, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_DEFENDER, BATTLEMON_TYPE_1, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_1, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_DEFENDER, BATTLEMON_TYPE_2, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, BTLVAR_CALC_TEMP
    // {0}’s type changed to match the target’s!
    PrintMessage BattleStrings_Text_SovereignTypeChangedToMatchTarget_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
