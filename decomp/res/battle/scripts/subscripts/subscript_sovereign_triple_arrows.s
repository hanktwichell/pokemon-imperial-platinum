#include "macros/btlcmd.inc"

// Sovereign (item 11): Triple Arrows. The move's chance (50%) of target Defense -1, then a 30% chance of a flinch
// (BTLVAR_SOVEREIGN_SECOND_EFFECT).

_000:
    CheckEffectActivation _flinch
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_DEFENSE_DOWN_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE

_flinch:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SECOND_EFFECT, 0, _end
    Call BATTLE_SUBSCRIPT_FLINCH_MON

_end:
    End 
