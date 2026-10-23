#include "macros/btlcmd.inc"

// Sovereign (item 11): Soak makes the target pure Water-type.

_000:
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_1, TYPE_WATER, _soak
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_2, TYPE_WATER, _soak
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 

_soak:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_1, TYPE_WATER
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_2, TYPE_WATER
    // {0} transformed into the Water type!
    PrintMessage BattleStrings_Text_SovereignTransformedIntoWaterType_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    End 
