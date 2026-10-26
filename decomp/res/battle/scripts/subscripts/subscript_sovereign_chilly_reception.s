#include "macros/btlcmd.inc"

// Sovereign (item 11): Chilly Reception. After its joke, the user starts snow (5 turns, 8 with an Icy Rock) and switches
// out as after U-turn. When it can't start snow (it's already snowing, or a primal weather holds) it only switches out;
// it fails when it can do neither.

_000:
    // {0} is preparing to tell a chillingly bad joke!
    PrintMessage BattleStrings_Text_SovereignChillingJoke_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait
    WaitButtonABTime 30
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_SOVEREIGN_PRIMAL, _no_snow
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_HAILING, _no_snow
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_WEATHER
    UpdateVar OPCODE_FLAG_ON, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_HAILING_TEMP
    UpdateVar OPCODE_SET, BTLVAR_WEATHER_TURNS, 5
    CheckItemHoldEffect CHECK_NOT_HAVE, BTLSCR_ATTACKER, HOLD_EFFECT_EXTEND_HAIL, _snow
    GetItemEffectParam BTLSCR_ATTACKER, BTLVAR_CALC_TEMP
    UpdateVarFromVar OPCODE_ADD, BTLVAR_WEATHER_TURNS, BTLVAR_CALC_TEMP

_snow:
    // It started to snow!
    PrintMessage BattleStrings_Text_ItStartedToHail, TAG_NONE
    Wait
    WaitButtonABTime 30
    GoToSubscript BATTLE_SUBSCRIPT_ATTACK_THEN_SWITCH_OUT

_no_snow:
    TryReplaceFaintedMon BTLSCR_ATTACKER, FALSE, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    GoToSubscript BATTLE_SUBSCRIPT_ATTACK_THEN_SWITCH_OUT

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
