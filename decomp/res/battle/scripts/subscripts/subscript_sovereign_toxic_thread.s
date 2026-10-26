#include "macros/btlcmd.inc"

// Sovereign (item 11): Toxic Thread lowers the target's Speed 2 stages, then poisons it (as Swagger raises Attack, then
// confuses). A Substitute blocks it.

_000:
    CheckSubstitute BTLSCR_DEFENDER, _fail
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SPEED_DOWN_2_STAGES
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    Call BATTLE_SUBSCRIPT_POISON
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
