#include "macros/btlcmd.inc"

// Sovereign (item 11): Shell Trap fails, with no attack message, when no foe's physical move hit its user this turn.

_000:
    // {0}’s shell trap didn’t work!
    PrintMessage BattleStrings_Text_SovereignShellTrapFailed_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait
    WaitButtonABTime 30
    End
