#include "macros/btlcmd.inc"

// Sovereign (item 11): Spirit Shackle, Anchor Shot. Damage, then the target can't escape.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_TRAP_TARGET
    CalcCrit 
    CalcDamage 
    End 
