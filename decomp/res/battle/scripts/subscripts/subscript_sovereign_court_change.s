#include "macros/btlcmd.inc"

// Sovereign (item 11): Court Change swaps the two sides' field effects (BTLVAR_SOVEREIGN_COURT_CHANGE). It fails when
// neither side has any.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_COURT_CHANGE, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // {0} swapped the battle effects affecting each side of the field!
    PrintMessage BattleStrings_Text_SovereignCourtChange_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
