#include "macros/btlcmd.inc"

// Sovereign (item 11): Throat Chop. The target can't use sound moves this turn and the next.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_THROAT_CHOP_SIDE_EFFECT_MON, 2
    End 
