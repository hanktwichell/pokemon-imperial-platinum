#include "macros/btlcmd.inc"

// Sovereign (item 11): a Pokemon that chose Shell Trap sets it before anyone moves (BattleControllerPlayer_
// CheckPreMoveActions). A foe's physical move that hits it springs the trap: it moves right after.

_000:
    // {0} set a shell trap!
    PrintMessage BattleStrings_Text_SovereignSetShellTrap_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30
    End
