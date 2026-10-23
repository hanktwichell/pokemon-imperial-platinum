#include "macros/btlcmd.inc"

// Sovereign (item 11): Weak Armor. When a physical move hits the holder, its Defense falls 1 stage and its Speed rises
// 2 stages (Gen VII+). The side-effect battler and type are set by BattleSystem_TriggerAbilityOnHit.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_DEFENSE_DOWN_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SPEED_UP_2_STAGES
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    End 
