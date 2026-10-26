#include "macros/btlcmd.inc"

// Sovereign (item 11): an Air Balloon pops when a damaging move hits its holder (BTLVAR_MSG_BATTLER_TEMP;
// BattleSystem_TriggerHeldItemOnHit).

_000:
    // {0}’s Air Balloon popped!
    PrintMessage BattleStrings_Text_SovereignAirBalloonPopped_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    RemoveItem BTLSCR_MSG_TEMP
    End 
