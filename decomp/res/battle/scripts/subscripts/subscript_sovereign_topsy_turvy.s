#include "macros/btlcmd.inc"

// Sovereign (item 11): Topsy-Turvy inverts the target's stat stages (fails when they're all neutral).

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CheckSubstitute BTLSCR_DEFENDER, _fail
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_TOPSY_TURVY_DEFENDER, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // All stat changes on {0} were inverted!
    PrintMessage BattleStrings_Text_SovereignStatChangesInverted_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
