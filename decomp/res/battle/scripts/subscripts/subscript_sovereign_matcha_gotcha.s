#include "macros/btlcmd.inc"

// Sovereign (item 11): Matcha Gotcha drains half the damage dealt, then (the move's chance, 20%) burns the target.
// Sheer Force and Covert Cloak stop the burn only (CheckEffectActivation).

_000:
    Call BATTLE_SUBSCRIPT_DRAIN_HALF_DAMAGE_DEALT
    CheckEffectActivation _end
    Call BATTLE_SUBSCRIPT_BURN

_end:
    End 
