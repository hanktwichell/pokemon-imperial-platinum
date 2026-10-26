#include "macros/btlcmd.inc"

// Sovereign (item 11): Electro Shot. Like Skull Bash (BATTLE_EFFECT_CHARGE_TURN_DEF_UP), but the charge turn raises
// Sp. Atk 1 stage, and in rain (or with a Power Herb) it raises Sp. Atk and attacks in the same turn. Meteor Beam uses
// it too, without the rain shortcut.

_000:
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_ATTACKER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_MOVE_LOCKED, _attack
    // Meteor Beam shares this effect but has no rain shortcut.
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_METEOR_BEAM, _check_herb
    CheckIgnoreWeather _check_herb
    // Sovereign (item 11): the weather as it acts on the attacker (not on a Utility Umbrella holder)
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SOVEREIGN_ATTACKER_WEATHER, FIELD_CONDITION_RAINING, _rain

_check_herb:
    CheckItemHoldEffect CHECK_HAVE, BTLSCR_ATTACKER, HOLD_EFFECT_CHARGE_SKIP, _herb
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_VANISH_CHARGE_TURN
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SP_ATTACK_UP_1_STAGE
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_ATTACK_MESSAGE|SYSCTL_CHECK_LOOP_ONLY_ONCE|SYSCTL_FIRST_OF_MULTI_TURN
    End 

_rain:
    Call BATTLE_SUBSCRIPT_SOVEREIGN_ELECTRO_SHOT_RAIN
    GoTo _check_target

_herb:
    Call BATTLE_SUBSCRIPT_SOVEREIGN_POWER_HERB_ELECTRO_SHOT

_check_target:
    CompareVarToValue OPCODE_EQU, BTLVAR_DEFENDER, BATTLER_NONE, _cleanup

_attack:
    CalcCrit 
    CalcDamage 

_cleanup:
    Call BATTLE_SUBSCRIPT_CHARGE_MOVE_CLEANUP
    End 
