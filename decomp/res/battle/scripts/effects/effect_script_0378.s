#include "macros/btlcmd.inc"

// Sovereign (item 11): Poltergeist. Its message before the hit (subscript_sovereign_poltergeist), then damage.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_POLTERGEIST
    CalcCrit 
    CalcDamage 
    End 
