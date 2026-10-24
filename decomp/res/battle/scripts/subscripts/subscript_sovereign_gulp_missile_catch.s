#include "macros/btlcmd.inc"

// Sovereign (FM): Gulp Missile. Cramorant caught an Arrokuda or a Pikachu with Surf or Dive (BattleControllerPlayer_
// TryMove has changed its form). It's silent, as in Sword and Shield.

_000:
    PlaySound BTLSCR_MSG_TEMP, 1980
    SetMosaic BTLSCR_MSG_TEMP, 8, 1
    Wait 
    ChangeForm BTLSCR_MSG_TEMP
    PlaySound BTLSCR_MSG_TEMP, 1984
    SetMosaic BTLSCR_MSG_TEMP, 0, 1
    Wait 
    End 
