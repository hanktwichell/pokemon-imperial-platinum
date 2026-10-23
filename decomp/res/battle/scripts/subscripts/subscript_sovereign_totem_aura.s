#include "macros/btlcmd.inc"

// Sovereign (decision 18): a Totem's aura at the start of its trial. BattleSystem_SovereignApplyTotemAura has raised the
// Totem's stats (BTLSCR_MSG_TEMP) and buffered the stat message.

_000:
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_STAT_BOOST
    Wait 
    // Totem {0}’s aura flared to life!
    PrintGlobalMessage BattleStrings_Text_SovereignTotemAura, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    PrintBufferedMessage 
    Wait 
    WaitButtonABTime 30
    End 
