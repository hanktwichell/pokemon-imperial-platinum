#include "macros/btlcmd.inc"

// Sovereign (item 11): Sky Drop. First turn: the user carries the target up (subscript_sovereign_sky_drop_lift). Protect
// and the like block it and a Pokemon already out of reach dodges it, but it never misses otherwise. Second turn:
// BattleControllerPlayer_BeforeMove aims the drop at the carried Pokemon and lets it go; a Flying type takes no damage.

_000:
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_ATTACKER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_MOVE_LOCKED, _drop
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_SKY_DROP_LIFT
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_CHECK_LOOP_ONLY_ONCE|SYSCTL_FIRST_OF_MULTI_TURN
    End 

_drop:
    CompareVarToValue OPCODE_EQU, BTLVAR_DEFENDER, BATTLER_NONE, _cleanup
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_CHECK_HP_AND_SUBSTITUTE|MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_SKY_DROP_FREED
    CalcCrit 
    CalcDamage 

_cleanup:
    UpdateMonData OPCODE_FLAG_OFF, BTLSCR_ATTACKER, BATTLEMON_MOVE_EFFECTS_MASK, MOVE_EFFECT_SEMI_INVULNERABLE
    Call BATTLE_SUBSCRIPT_CHARGE_MOVE_CLEANUP
    End 
