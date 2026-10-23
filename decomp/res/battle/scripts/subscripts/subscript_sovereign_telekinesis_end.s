#include "macros/btlcmd.inc"

// Sovereign (item 11): Telekinesis wore off (BattleControllerPlayer_CheckMonConditions).

_000:
    // {0} was freed from the telekinesis!
    PrintMessage BattleStrings_Text_SovereignFreedFromTelekinesis_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    End 
