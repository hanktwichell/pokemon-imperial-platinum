#include "macros/btlcmd.inc"

// Sovereign (item 11): Salt Cure's damage at the end of the turn (BattleControllerPlayer_CheckMonConditions sets the
// battler and the HP).

_000:
    // {0} is hurt by Salt Cure!
    PrintMessage BattleStrings_Text_SovereignHurtBySaltCure_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    GoToSubscript BATTLE_SUBSCRIPT_UPDATE_HP
