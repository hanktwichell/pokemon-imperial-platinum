#include "macros/btlcmd.inc"

// Sovereign (item 11): a damaging Fire move in heavy rain, or Water move in extremely harsh sunlight, fails after its
// user's attack message. BTLVAR_MSG_TEMP is 0 for heavy rain, 1 for harsh sunlight (BattleControllerPlayer_BeforeMove).

_000:
    PrintAttackMessage 
    Wait 
    WaitButtonABTime 15
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 1, _sun
    // The Fire-type attack fizzled out in the heavy rain!
    PrintMessage BattleStrings_Text_SovereignFizzledInHeavyRain, TAG_NONE
    GoTo _done

_sun:
    // The Water-type attack evaporated in the extremely harsh sunlight!
    PrintMessage BattleStrings_Text_SovereignEvaporatedInHarshSun, TAG_NONE

_done:
    Wait 
    WaitButtonABTime 30
    End 
