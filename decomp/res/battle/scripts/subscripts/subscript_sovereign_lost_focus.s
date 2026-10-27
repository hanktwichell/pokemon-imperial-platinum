#include "macros/btlcmd.inc"

// Sovereign: a Focus Punch user hit by a damaging move this turn loses its focus before it moves, with no attack message
// and no PP spent (Gen V+; BattleControllerPlayer_BeforeMove).

_000:
    // {0} lost its focus and couldn’t move!
    PrintMessage BattleStrings_Text_PokemonLostItsFocusAndCouldntMove_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait
    WaitButtonABTime 30
    End
