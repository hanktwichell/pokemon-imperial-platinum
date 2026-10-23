#include "macros/btlcmd.inc"

// Sovereign (item 11): Mummy or Lingering Aroma has passed itself to the attacker that touched the holder
// (BattleSystem_TriggerAbilityOnHit sets the new ability first).

_000:
    // {0} acquired {1}!
    PrintMessage BattleStrings_Text_PokemonAcquiredAbility_Ally, TAG_NICKNAME_ABILITY, BTLSCR_ATTACKER, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 
