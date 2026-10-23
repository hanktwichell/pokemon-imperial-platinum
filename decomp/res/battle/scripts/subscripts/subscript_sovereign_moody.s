#include "macros/btlcmd.inc"

// Sovereign (item 11): Moody. At the end of the turn one stat rises 2 stages (sideEffectParam) and another falls
// 1 stage (calcTemp); both are chosen in BattleSystem_TriggerTurnEndAbility.

_000:
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, BTLVAR_CALC_TEMP
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    End 
