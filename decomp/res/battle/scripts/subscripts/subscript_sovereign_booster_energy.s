#include "macros/btlcmd.inc"

// Sovereign (item 11): a Protosynthesis or Quark Drive Pokemon uses its Booster Energy on switch-in
// (BattleSystem_TriggerSwitchInAbility has set its sovereignBoosterEnergy flag).

_000:
    PlayBattleAnimation BTLSCR_MSG_BATTLER_TEMP, BATTLE_ANIMATION_HELD_ITEM
    Wait 
    // {0} used its {1}!
    PrintMessage BattleStrings_Text_SovereignUsedItsItem_Ally, TAG_NICKNAME_ITEM, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_MSG_BATTLER_TEMP
    Wait 
    WaitButtonABTime 30
    RemoveItem BTLSCR_MSG_BATTLER_TEMP
    End 
