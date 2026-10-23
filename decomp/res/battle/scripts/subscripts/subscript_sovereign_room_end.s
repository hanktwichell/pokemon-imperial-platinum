#include "macros/btlcmd.inc"

// Sovereign (item 11): Magic Room (BTLVAR_MSG_TEMP 0) or Wonder Room (1) wore off (BattleControllerPlayer_CheckFieldConditions).

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 1, _wonder
    // Magic Room wore off, and held items’ effects returned to normal!
    PrintMessage BattleStrings_Text_SovereignMagicRoomEnd, TAG_NONE
    GoTo _done

_wonder:
    // Wonder Room wore off, and Defense and Sp. Def stats returned to normal!
    PrintMessage BattleStrings_Text_SovereignWonderRoomEnd, TAG_NONE

_done:
    Wait 
    WaitButtonABTime 30
    End 
