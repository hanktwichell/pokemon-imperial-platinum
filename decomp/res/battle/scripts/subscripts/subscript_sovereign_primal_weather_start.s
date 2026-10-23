#include "macros/btlcmd.inc"

// Sovereign (item 11): Primordial Sea, Desolate Land or Delta Stream has set its primal weather
// (BattleSystem_TriggerSwitchInAbility sets the field condition first).

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_RAINING, _rain
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_SUNNY, _sun
    // Mysterious strong winds are protecting Flying-type Pokémon!
    PrintMessage BattleStrings_Text_SovereignStrongWindsStart, TAG_NONE
    GoTo _done

_rain:
    PlayBattleAnimation BTLSCR_PLAYER, BATTLE_ANIMATION_WEATHER_RAIN
    Wait 
    // A heavy rain began to fall!
    PrintMessage BattleStrings_Text_SovereignHeavyRainStart, TAG_NONE
    GoTo _done

_sun:
    PlayBattleAnimation BTLSCR_PLAYER, BATTLE_ANIMATION_WEATHER_SUN
    Wait 
    // The sunlight turned extremely harsh!
    PrintMessage BattleStrings_Text_SovereignHarshSunStart, TAG_NONE

_done:
    Wait 
    WaitButtonABTime 30
    End 
