#include "macros/btlcmd.inc"

// Sovereign (item 11): Ball Fetch. At the end of a turn the holder picked up the first ball thrown in this wild battle
// (BattleSystem_TriggerTurnEndAbility). The holder is BTLSCR_MSG_TEMP; the ball is the message's item.

_000:
    // {0} found a {1}!
    PrintMessage BattleStrings_Text_SovereignBallFetch_Ally, TAG_NICKNAME_ITEM, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30
    End
