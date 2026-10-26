#include "macros/btlcmd.inc"

// Sovereign (item 11): Celebrate congratulates the player. It has no effect in battle.

_000:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // Congratulations, {0}!
    PrintMessage BattleStrings_Text_SovereignCongratulations, TAG_TRNAME, BTLSCR_PLAYER
    Wait 
    WaitButtonABTime 30
    End 
