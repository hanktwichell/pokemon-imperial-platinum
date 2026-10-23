#include "macros/btlcmd.inc"

// Sovereign (item 11): the primal weather ended because no Pokémon with its ability is left in battle. BTLVAR_MSG_TEMP
// says which: 0 heavy rain, 1 extremely harsh sunlight, 2 strong winds (Sovereign_EndPrimalWeather).

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 0, _rain
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 1, _sun
    // The mysterious strong winds have dissipated!
    PrintMessage BattleStrings_Text_SovereignStrongWindsEnd, TAG_NONE
    GoTo _done

_rain:
    // The heavy rain has lifted!
    PrintMessage BattleStrings_Text_SovereignHeavyRainEnd, TAG_NONE
    GoTo _done

_sun:
    // The extremely harsh sunlight faded!
    PrintMessage BattleStrings_Text_SovereignHarshSunEnd, TAG_NONE

_done:
    Wait 
    WaitButtonABTime 30
    End 
