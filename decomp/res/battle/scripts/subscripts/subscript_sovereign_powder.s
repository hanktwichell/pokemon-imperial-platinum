#include "macros/btlcmd.inc"

// Sovereign (item 11): Powder. The target is covered in powder for the rest of the turn: its Fire moves explode
// (subscript_sovereign_powder_explode). It fails on a target already covered.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_POWDER, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // {0} is covered in powder!
    PrintMessage BattleStrings_Text_SovereignCoveredInPowder_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait
    WaitButtonABTime 30
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
