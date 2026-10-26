#include "macros/btlcmd.inc"


    // Sovereign (item 11): a veil (Sweet Veil, Pastel Veil, Flower Veil: BTLVAR_CALC_TEMP holds which) kept a status
    // condition off the side-effect target, its holder's or its partner's. A status move or Yawn's drowsiness says so;
    // a move's chance effect, an Ability's, an item's or a hazard's is stopped without a word.
_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_MOVE_EFFECT, _message
    CompareVarToValue OPCODE_NEQ, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_DIRECT, _end
    PrintAttackMessage
    Wait

_message:
    WaitButtonABTime 30
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, ABILITY_SWEET_VEIL, _sweet
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, ABILITY_PASTEL_VEIL, _pastel
    // {0} surrounded itself with a veil of petals!
    PrintMessage BattleStrings_Text_SovereignVeilOfPetals_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    GoTo _wait

_sweet:
    // {0} can’t fall asleep due to a veil of sweetness!
    PrintMessage BattleStrings_Text_SovereignVeilOfSweetness_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    GoTo _wait

_pastel:
    // {0} is protected by a pastel veil!
    PrintMessage BattleStrings_Text_SovereignPastelVeil_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON

_wait:
    Wait
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK

_end:
    End 
