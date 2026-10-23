#include "macros/btlcmd.inc"

// Sovereign (item 11): a Surge ability (or Hadron Engine) has set its terrain (BattleSystem_TriggerSwitchInAbility).

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_TERRAIN_ELECTRIC, _electric
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_TERRAIN_GRASSY, _grassy
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_TERRAIN_MISTY, _misty
    // The battlefield got weird!
    PrintMessage BattleStrings_Text_SovereignPsychicTerrainStart, TAG_NONE
    GoTo _done

_electric:
    // An electric current ran across the battlefield!
    PrintMessage BattleStrings_Text_SovereignElectricTerrainStart, TAG_NONE
    GoTo _done

_grassy:
    // Grass grew to cover the battlefield!
    PrintMessage BattleStrings_Text_SovereignGrassyTerrainStart, TAG_NONE
    GoTo _done

_misty:
    // Mist swirled around the battlefield!
    PrintMessage BattleStrings_Text_SovereignMistyTerrainStart, TAG_NONE

_done:
    Wait 
    WaitButtonABTime 30
    End 
