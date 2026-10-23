#include "macros/btlcmd.inc"

// Sovereign (item 11): Final Gambit. Deals damage equal to the user's HP; if it hits, the user faints
// (subscript_sovereign_final_gambit). Type immunities still apply.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_FINAL_GAMBIT
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_IGNORE_TYPE_CHECKS
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, BTLVAR_DAMAGE
    UpdateVar OPCODE_MUL, BTLVAR_DAMAGE, -1
    End 
