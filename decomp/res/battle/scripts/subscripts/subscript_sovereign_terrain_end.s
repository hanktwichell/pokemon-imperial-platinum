#include "macros/btlcmd.inc"

// Sovereign (item 11): the terrain's turns ran out (BattleControllerPlayer_CheckFieldConditions).

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_TERRAIN_ELECTRIC, _electric
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_TERRAIN_GRASSY, _grassy
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_TERRAIN_MISTY, _misty
    // The weirdness disappeared from the battlefield.
    PrintMessage BattleStrings_Text_SovereignPsychicTerrainEnd, TAG_NONE
    GoTo _done

_electric:
    // The electricity disappeared from the battlefield.
    PrintMessage BattleStrings_Text_SovereignElectricTerrainEnd, TAG_NONE
    GoTo _done

_grassy:
    // The grass disappeared from the battlefield.
    PrintMessage BattleStrings_Text_SovereignGrassyTerrainEnd, TAG_NONE
    GoTo _done

_misty:
    // The mist disappeared from the battlefield.
    PrintMessage BattleStrings_Text_SovereignMistyTerrainEnd, TAG_NONE

_done:
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_TERRAIN|FIELD_CONDITION_TERRAIN_TURNS
    End 
