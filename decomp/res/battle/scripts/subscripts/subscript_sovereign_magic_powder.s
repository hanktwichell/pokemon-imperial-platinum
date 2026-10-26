#include "macros/btlcmd.inc"

// Sovereign (item 11): Magic Powder makes the target pure Psychic-type.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CheckSubstitute BTLSCR_DEFENDER, _fail
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_DEFENDER, BATTLEMON_TYPE_1, TYPE_PSYCHIC, _powder
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_TYPE_2, TYPE_PSYCHIC, _fail

_powder:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateMonData OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_TYPE_1, TYPE_PSYCHIC
    UpdateMonData OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_TYPE_2, TYPE_PSYCHIC
    // {0} transformed into the Psychic type!
    PrintMessage BattleStrings_Text_SovereignTransformedIntoPsychicType_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
