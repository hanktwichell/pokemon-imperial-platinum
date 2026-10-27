#include "macros/btlcmd.inc"

// Sovereign: a Future Sight or Doom Desire hit (Gen V+: typed when it hits) on a Pokemon immune to its type, such as a
// Dark type and Future Sight (BattleControllerPlayer_CheckSideConditions).

_000:
    PrintBufferedMessage 
    Wait 
    WaitButtonABTime 30
    // It doesn’t affect {0}…
    PrintMessage BattleStrings_Text_ItDoesntAffectPokemon_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    End 
