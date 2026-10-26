#include "macros/btlcmd.inc"

// Sovereign (item 11): Curious Medicine. As the holder enters, its partner's (BTLVAR_MSG_BATTLER_TEMP) stat stages
// have been reset (BattleSystem_TriggerEffectOnSwitch).

_000:
    // {0}’s stat changes were removed!
    PrintMessage BattleStrings_Text_SovereignStatChangesRemoved_Ally, TAG_NICKNAME, BTLSCR_MSG_BATTLER_TEMP
    Wait 
    WaitButtonABTime 30
    End 
