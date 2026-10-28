#include "macros/btlcmd.inc"

// Sovereign (item 11): Burn Up and Double Shock. Damage, then subscript_sovereign_burn_out (the user loses the Fire or
// Electric type). They fail unless the user has that type (battle_controller_player.c).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_BURN_OUT
    CalcCrit 
    CalcDamage 
    End 
