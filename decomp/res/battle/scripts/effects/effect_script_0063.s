#include "macros/btlcmd.inc"


_000:
    // Sovereign: evasion -2, as Sweet Scent does from Gen VI on (Platinum left this effect a plain hit).
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_EVASION_DOWN_2_STAGES
    End
