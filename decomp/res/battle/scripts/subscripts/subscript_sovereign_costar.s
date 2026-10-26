#include "macros/btlcmd.inc"

// Sovereign (item 11): Costar. As the holder (BTLVAR_MSG_ATTACKER) enters, it has copied its partner's
// (BTLVAR_MSG_BATTLER_TEMP) stat stages (BattleSystem_TriggerEffectOnSwitch).

_000:
    // {0} copied {1}’s stat changes!
    PrintMessage BattleStrings_Text_SovereignCopiedStatChanges_AllyAlly, TAG_NICKNAME_NICKNAME, BTLSCR_MSG_ATTACKER, BTLSCR_MSG_BATTLER_TEMP
    Wait 
    WaitButtonABTime 30
    End 
