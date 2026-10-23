#include "macros/btlcmd.inc"

// Sovereign (item 11): a terrain Seed raises its holder's Defense or Sp. Def (BattleSystem_TriggerEffectOnSwitch has set
// up the stat change) and is used up.

_000:
    PlayBattleAnimation BTLSCR_MSG_BATTLER_TEMP, BATTLE_ANIMATION_HELD_ITEM
    Wait 
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    RemoveItem BTLSCR_MSG_BATTLER_TEMP
    End 
