#include "macros/btlcmd.inc"

// Sovereign (item 11): Psychic Noise. Damage, then the target can't heal for two turns.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_PSYCHIC_NOISE
    CalcCrit 
    CalcDamage 
    End 
