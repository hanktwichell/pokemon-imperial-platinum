#include "macros/btlcmd.inc"

// Sovereign (item 11): Wandering Spirit has swapped abilities with the attacker that touched the holder
// (BattleSystem_TriggerAbilityOnHit swaps them first).

_000:
    // {0} acquired {1}!
    PrintMessage BattleStrings_Text_PokemonAcquiredAbility_Ally, TAG_NICKNAME_ABILITY, BTLSCR_ATTACKER, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    // {0} acquired {1}!
    PrintMessage BattleStrings_Text_PokemonAcquiredAbility_Ally, TAG_NICKNAME_ABILITY, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    End 
