#include "macros/btlcmd.inc"

// Sovereign (item 11): an Air Balloon is announced as its holder (BTLVAR_MSG_BATTLER_TEMP) enters the battle
// (SWITCH_IN_CHECK_STATE_SOVEREIGN_ENTRY_BOOSTS).

_000:
    // {0} floats in the air with its Air Balloon!
    PrintMessage BattleStrings_Text_SovereignFloatsWithAirBalloon_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    End 
