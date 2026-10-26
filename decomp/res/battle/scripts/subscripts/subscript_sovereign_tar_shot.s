#include "macros/btlcmd.inc"

// Sovereign (item 11): Tar Shot lowers the target's Speed 1 stage and makes it weaker to Fire until it switches out
// (BTLVAR_SOVEREIGN_TAR_SHOT_START; the type chart doubles Fire moves once more). A Substitute blocks it.

_000:
    CheckSubstitute BTLSCR_DEFENDER, _fail
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SPEED_DOWN_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_TAR_SHOT_START, 0, _end
    // {0} became weaker to fire!
    PrintMessage BattleStrings_Text_SovereignWeakerToFire_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30

_end:
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
