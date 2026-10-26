#include "macros/btlcmd.inc"

// Sovereign (item 11): a Gem is used up as the damaging move of its type it powered up hits (BTLVAR_MSG_ITEM_TEMP: the
// Gem, BTLVAR_MSG_MOVE_TEMP: the move; BTLVAR_SOVEREIGN_GEM_USED, from subscript_update_hp).

_000:
    PlayBattleAnimation BTLSCR_ATTACKER, BATTLE_ANIMATION_HELD_ITEM
    Wait 
    // The {0} strengthened {1}’s power!
    PrintMessage BattleStrings_Text_SovereignGemStrengthenedMove, TAG_ITEM_MOVE, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    RemoveItem BTLSCR_ATTACKER
    End 
