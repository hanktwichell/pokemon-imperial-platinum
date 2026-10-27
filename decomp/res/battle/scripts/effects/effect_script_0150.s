#include "macros/btlcmd.inc"


_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_FLINCH
    // Sovereign: the double damage against a Minimized target is in Sovereign_MovePower, with the other moves that have
    // it (Gen VI+).
    UpdateVar OPCODE_SET, BTLVAR_POWER_MULTI, 10
    CalcCrit 
    CalcDamage 
    End 
