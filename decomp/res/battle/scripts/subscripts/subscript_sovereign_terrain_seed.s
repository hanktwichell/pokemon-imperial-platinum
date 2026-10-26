#include "macros/btlcmd.inc"

// Sovereign (item 11): a terrain Seed raises its holder's Defense or Sp. Def, or Room Service lowers its Speed under
// Trick Room (BattleSystem_TriggerEffectOnSwitch has set up the stat change), and the item is used up.

_000:
    PlayBattleAnimation BTLSCR_MSG_BATTLER_TEMP, BATTLE_ANIMATION_HELD_ITEM
    Wait 
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    RemoveItem BTLSCR_MSG_BATTLER_TEMP
    End 
