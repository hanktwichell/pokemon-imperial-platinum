#include "macros/btlcmd.inc"

// Sovereign (item 11): Spectral Thief steals the target's stat rises before it hits (subscript_sovereign_spectral_thief).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_SPECTRAL_THIEF
    CalcCrit
    CalcDamage
    End
