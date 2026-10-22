#include "macros/btlcmd.inc"


_000:
    PlayBattleAnimation BTLSCR_PLAYER, BATTLE_ANIMATION_WEATHER_RAIN
    Wait 
    // {0}’s {1} made it rain!
    PrintMessage BattleStrings_Text_PokemonsAbilityMadeItRain_Ally, TAG_NICKNAME_ABILITY, BTLSCR_MSG_TEMP, BTLSCR_MSG_BATTLER_TEMP
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_WEATHER
    // Imperial: Gen VI+ / Champions, weather from an ability lasts 5 turns (8 with its rock), not forever.
    UpdateVar OPCODE_FLAG_ON, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_RAINING_TEMP
    UpdateVar OPCODE_SET, BTLVAR_WEATHER_TURNS, 5
    CheckItemHoldEffect CHECK_NOT_HAVE, BTLSCR_MSG_TEMP, HOLD_EFFECT_EXTEND_RAIN, _WeatherTurnsSet
    GetItemEffectParam BTLSCR_MSG_TEMP, BTLVAR_CALC_TEMP
    UpdateVarFromVar OPCODE_ADD, BTLVAR_WEATHER_TURNS, BTLVAR_CALC_TEMP

_WeatherTurnsSet:
    End 
