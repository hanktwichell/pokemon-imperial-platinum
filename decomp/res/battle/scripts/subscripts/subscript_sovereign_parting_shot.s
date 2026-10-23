#include "macros/btlcmd.inc"

// Sovereign (item 11): Parting Shot lowers the target's Attack and Sp. Atk by 1 stage, then the user switches out as
// after U-turn. If the stats can't be lowered, the user stays in (Gen VII+).

_000:
    Call BATTLE_SUBSCRIPT_SOVEREIGN_STATS_NOBLE_ROAR
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED|MOVE_STATUS_NO_MORE_WORK, _end
    GoToSubscript BATTLE_SUBSCRIPT_ATTACK_THEN_SWITCH_OUT

_end:
    End 
