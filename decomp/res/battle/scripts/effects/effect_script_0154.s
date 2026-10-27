#include "macros/btlcmd.inc"


_000:
    // Sovereign: Beat Up is Dark-typed (Gen V+), so the type chart applies; Platinum's ignored it.
    CalcCrit 
    BeatUp 
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_FUTURE_SIGHT_START
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_MULTI_HIT_SKIP_MESSAGE
    End 
