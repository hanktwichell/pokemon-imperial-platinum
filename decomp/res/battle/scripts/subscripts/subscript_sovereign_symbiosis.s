#include "macros/btlcmd.inc"

// Sovereign (item 11): Symbiosis passed its holder's item to the ally that used up its own (BtlCmd_RemoveItem; or the
// switch-in check, when the script stack was full).

_000:
    // {0} shared its {1} with {2}!
    PrintMessage BattleStrings_Text_SovereignSymbiosis_AllyAlly, TAG_NICKNAME_ITEM_NICKNAME, BTLSCR_SOVEREIGN_SYMBIOSIS_GIVER, BTLSCR_SOVEREIGN_SYMBIOSIS_RECEIVER, BTLSCR_SOVEREIGN_SYMBIOSIS_RECEIVER
    Wait
    WaitButtonABTime 30
    End
