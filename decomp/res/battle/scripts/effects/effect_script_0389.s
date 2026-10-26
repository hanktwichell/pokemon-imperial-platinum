#include "macros/btlcmd.inc"

// Sovereign (item 11): Autotomize, subscript_sovereign_autotomize.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_AUTOTOMIZE
    End
