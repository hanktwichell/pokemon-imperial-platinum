#include "macros/btlcmd.inc"

// Sovereign (item 11): Harvest. At the end of a turn the holder grew back the Berry it had used up
// (BattleSystem_TriggerTurnEndAbility). The holder is BTLSCR_MSG_TEMP; the Berry is the message's item.

_000:
    // {0} harvested one {1}!
    PrintMessage BattleStrings_Text_SovereignHarvestedBerry_Ally, TAG_NICKNAME_ITEM, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    End 
