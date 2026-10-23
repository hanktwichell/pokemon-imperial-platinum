#include "macros/btlcmd.inc"

// Sovereign (item 11): Smack Down grounds the target until it switches out.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_SMACKED_DOWN_SIDE_EFFECT_MON, 1
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_MAGNET_RISE_TURNS, 0, _fell
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_1, TYPE_FLYING, _fell
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_2, TYPE_FLYING, _fell
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_ABILITY, ABILITY_LEVITATE, _fell
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_ABILITY, ABILITY_EELEVATE, _fell // Sovereign (item 11)
    End 

_fell:
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_MAGNET_RISE_TURNS, 0
    // {0} fell straight down!
    PrintMessage BattleStrings_Text_SovereignFellStraightDown_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    End 
