#include "macros/btlcmd.inc"

// Sovereign (item 11): Magic Room (BTLVAR_MSG_TEMP 0) or Wonder Room (1) wore off (BattleControllerPlayer_CheckFieldConditions).
// Sovereign: also Mud Sport (2) and Water Sport (3), field effects since Gen VI.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 1, _wonder
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 2, _mud
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 3, _water
    // Magic Room wore off, and held items’ effects returned to normal!
    PrintMessage BattleStrings_Text_SovereignMagicRoomEnd, TAG_NONE
    GoTo _done

_wonder:
    // Wonder Room wore off, and Defense and Sp. Def stats returned to normal!
    PrintMessage BattleStrings_Text_SovereignWonderRoomEnd, TAG_NONE
    GoTo _done

_mud:
    // The effects of Mud Sport have faded.
    PrintMessage BattleStrings_Text_SovereignMudSportEnd, TAG_NONE
    GoTo _done

_water:
    // The effects of Water Sport have faded.
    PrintMessage BattleStrings_Text_SovereignWaterSportEnd, TAG_NONE

_done:
    Wait 
    WaitButtonABTime 30
    End 
