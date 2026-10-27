#include "macros/btlcmd.inc"

// Sovereign: Pickup (Gen V+). At the end of a turn the holder picked up an item another Pokémon used up this turn
// (BattleSystem_TriggerTurnEndAbility). The holder is BTLSCR_MSG_TEMP; the item is the message's item.

_000:
    // {0} found one {1}!
    PrintMessage BattleStrings_Text_SovereignFoundOneItem_Ally, TAG_NICKNAME_ITEM, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30
    End
