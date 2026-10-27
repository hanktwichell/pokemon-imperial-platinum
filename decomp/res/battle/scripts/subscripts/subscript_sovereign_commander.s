#include "macros/btlcmd.inc"

// Sovereign (item 11): Commander. Sovereign_StartCommander has put the Tatsugiri (MSG_BATTLER_TEMP) into its ally
// Dondozo's mouth and raised the Dondozo's (SIDE_EFFECT_MON) stats by 2.

_000:
    // {0} was swallowed by {1} and became {1}'s commander!
    PrintMessage BattleStrings_Text_SovereignCommander_AllyAlly, TAG_NICKNAME_NICKNAME, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    ToggleVanish BTLSCR_MSG_BATTLER_TEMP, TRUE
    Wait 
    PlayBattleAnimation BTLSCR_SIDE_EFFECT_MON, BATTLE_ANIMATION_STAT_BOOST
    Wait 
    // {0}'s stats sharply rose!
    PrintMessage BattleStrings_Text_SovereignStatsSharplyRose_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    End 
