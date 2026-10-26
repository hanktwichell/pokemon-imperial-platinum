#include "macros/btlcmd.inc"

// Sovereign (item 11): Cotton Down. A damaging move that hits the holder lowers the Speed of every other Pokémon on the
// field 1 stage, its ally's too, even as the holder faints (BattleSystem_TriggerAbilityOnHit). The holder is
// BTLVAR_MSG_BATTLER_TEMP; it stands in as the attacker, as for Intimidate.

_000:
    UpdateVar OPCODE_SET, BTLVAR_BATTLER_SPEED_TEMP, 0
    UpdateVarFromVar OPCODE_SET, BTLVAR_LAST_BATTLER_ID, BTLVAR_ATTACKER
    UpdateVarFromVar OPCODE_SET, BTLVAR_ATTACKER, BTLVAR_MSG_BATTLER_TEMP

_loop:
    GetMonBySpeedOrder BTLVAR_SIDE_EFFECT_MON
    CompareVarToVar OPCODE_EQU, BTLVAR_SIDE_EFFECT_MON, BTLVAR_ATTACKER, _next
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _next
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SPEED_DOWN_1_STAGE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE

_next:
    UpdateVar OPCODE_ADD, BTLVAR_BATTLER_SPEED_TEMP, 1
    GoToIfValidMon BTLVAR_BATTLER_SPEED_TEMP, _loop
    UpdateVarFromVar OPCODE_SET, BTLVAR_ATTACKER, BTLVAR_LAST_BATTLER_ID
    End 
