#include "macros/btlcmd.inc"

// Sovereign (item 11): Plasma Fists. Damage, then subscript_sovereign_plasma_fists.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_PLASMA_FISTS
    CalcCrit
    CalcDamage
    End
