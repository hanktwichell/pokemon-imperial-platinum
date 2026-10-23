#include "macros/btlcmd.inc"

// Sovereign (item 11): Hurricane. Like Thunder (BATTLE_EFFECT_THUNDER): hits a Pokemon in the air (Fly, Bounce),
// never misses in rain and has 50% accuracy in harsh sunlight (battle_controller_player.c), with a chance to confuse
// instead of paralyze.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_CONFUSE
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_HIT_DURING_FLY
    CalcCrit 
    CalcDamage 
    End 
