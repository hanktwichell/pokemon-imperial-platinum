#include "macros/btlcmd.inc"

// Sovereign (item 11): Smack Down grounds the target until it switches out.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_SMACKED_DOWN_SIDE_EFFECT_MON, 1
    // A Pokemon up in the air by Fly or Bounce comes down, and its move ends (Sovereign_SmackDownFlyer).
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SMACK_DOWN_FLYER, 0, _grounded
    ToggleVanish BTLSCR_SIDE_EFFECT_MON, FALSE
    Wait 
    GoTo _fell

_grounded:
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
