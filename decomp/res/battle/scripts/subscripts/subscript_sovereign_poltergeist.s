#include "macros/btlcmd.inc"

// Sovereign (item 11): Poltergeist. Before the hit (as Brick Break's barrier message), "{0} is about to be attacked by
// its {1}!". A target holding no item makes it fail (BattleControllerPlayer_CheckMoveHitOverrides).

_000:
    PrintAttackMessage 
    Wait 
    // {0} is about to be attacked by its {1}!
    PrintMessage BattleStrings_Text_SovereignAttackedByItsItem_Ally, TAG_NICKNAME_ITEM, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    PlayMoveAnimation BTLSCR_ATTACKER
    Wait 
    End 
