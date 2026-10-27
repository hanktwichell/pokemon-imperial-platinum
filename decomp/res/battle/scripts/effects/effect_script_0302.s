#include "macros/btlcmd.inc"

// Sovereign (item 11): damage, then the target is grounded (Smack Down), unless it fainted or a substitute took the hit.
// It reaches a Pokemon in the air (Fly, Bounce, Sky Drop).

_000:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_HIT_DURING_FLY
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_CHECK_HP_AND_SUBSTITUTE|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_SMACK_DOWN
    CalcCrit 
    CalcDamage 
    End 
