#include "macros/btlcmd.inc"

// Sovereign (item 11): Aurora Veil. Only in snow: halves physical and special damage to the user's side for 5 turns
// (8 with Light Clay); doesn't stack with Reflect and Light Screen.

_000:
    CheckIgnoreWeather _fail
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_HAILING, _fail
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SIDE_CONDITIONS_ATTACKER, SIDE_CONDITION_SOVEREIGN_AURORA_VEIL, _fail
    UpdateVar OPCODE_FLAG_ON, BTLVAR_SIDE_CONDITIONS_ATTACKER, SIDE_CONDITION_SOVEREIGN_AURORA_VEIL
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_AURORA_VEIL_TURNS_ATTACKER, 5
    CheckItemHoldEffect CHECK_NOT_HAVE, BTLSCR_ATTACKER, HOLD_EFFECT_EXTEND_SCREENS, _message
    GetItemEffectParam BTLSCR_ATTACKER, BTLVAR_CALC_TEMP
    UpdateVarFromVar OPCODE_ADD, BTLVAR_SOVEREIGN_AURORA_VEIL_TURNS_ATTACKER, BTLVAR_CALC_TEMP

_message:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // Aurora Veil made your team stronger against attacks!
    PrintMessage BattleStrings_Text_SovereignAuroraVeilYourTeam, TAG_NONE_SIDE_CONSCIOUS, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
