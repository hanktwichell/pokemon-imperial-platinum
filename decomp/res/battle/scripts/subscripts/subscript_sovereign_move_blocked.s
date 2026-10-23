#include "macros/btlcmd.inc"

// Sovereign (item 11): the attacker's move is blocked by another move (BTLVAR_MSG_MOVE_TEMP), e.g. Throat Chop.

_000:
    // {0} can’t use {2} because of {1}!
    PrintMessage BattleStrings_Text_PokemonCantUseMoveBecauseOfMove_Ally, TAG_NICKNAME_MOVE_MOVE, BTLSCR_ATTACKER, BTLSCR_MSG_TEMP, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 
