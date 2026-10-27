#include "macros/btlcmd.inc"


_000:
    // Sovereign: Feint hits whether the target protects or not (Gen V+). Platinum's failed unless it did.
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_FEINT
    CalcCrit 
    CalcDamage 
    End 
