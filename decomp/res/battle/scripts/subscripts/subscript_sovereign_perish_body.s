#include "macros/btlcmd.inc"

// Sovereign (item 11): Perish Body. A contact move on the holder gives it and the attacker a Perish Song count of 3
// (BattleSystem_TriggerAbilityOnHit sets it first).

_000:
    // Both Pokémon will faint in three turns!
    PrintMessage BattleStrings_Text_SovereignBothPokemonWillFaintInThreeTurns, TAG_NONE
    Wait 
    WaitButtonABTime 30
    End 
