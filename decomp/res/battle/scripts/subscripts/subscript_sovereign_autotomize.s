#include "macros/btlcmd.inc"

// Sovereign (item 11): Autotomize. User Speed +2, then it gets 100 kg lighter, down to 0.1 kg (BTLVAR_SOVEREIGN_
// AUTOTOMIZE), for Low Kick, Grass Knot, Heavy Slam and Heat Crash. At +6 Speed it only says so.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SPEED_UP_2_STAGES
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_SPEED_STAGE, 12, _no_change
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED, _end
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_AUTOTOMIZE, 0, _end
    // {0} became nimble!
    PrintMessage BattleStrings_Text_SovereignBecameNimble_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait
    WaitButtonABTime 30

_end:
    End

_no_change:
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    End
