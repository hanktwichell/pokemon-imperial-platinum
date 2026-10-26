#include "macros/btlcmd.inc"

// Sovereign (item 11): Axe Kick. Hi Jump Kick's crash damage on a miss (and its Reckless boost), and (effect chance)
// confuses the target.

_000:
    CheckAbility CHECK_NOT_HAVE, BTLSCR_ATTACKER, ABILITY_RECKLESS, _008
    UpdateVar OPCODE_SET, BTLVAR_POWER_MULTI, 12

_008:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_CRASH_DAMAGE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_CONFUSE
    CalcCrit 
    CalcDamage 
    End 
