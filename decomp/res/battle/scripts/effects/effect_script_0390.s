#include "macros/btlcmd.inc"

// Sovereign (item 11): Flame Burst. Damage, then subscript_sovereign_flame_burst.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_FLAME_BURST
    CalcCrit
    CalcDamage
    End
