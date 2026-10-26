#include "macros/btlcmd.inc"

// Sovereign (item 11): a Pokemon that chose Beak Blast heats up its beak before anyone moves
// (BattleControllerPlayer_CheckPreMoveActions). Until it uses Beak Blast, it burns the Pokemon that touch it.

_000:
    // {0} started heating up its beak!
    PrintMessage BattleStrings_Text_SovereignHeatingUpBeak_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30
    End
