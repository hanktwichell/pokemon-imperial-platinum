#include "macros/btlcmd.inc"

// Sovereign (item 11): Stuff Cheeks. The user's Defense +2, then it eats its Berry (subscript_sovereign_stuff_cheeks).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_STUFF_CHEEKS
    End 
