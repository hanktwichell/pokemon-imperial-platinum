#include "macros/btlcmd.inc"

// Sovereign (item 11): Electrify. The target's moves are Electric for the rest of the turn (BTLVAR_SOVEREIGN_ELECTRIFY:
// it fails if the target has already acted this turn, or is already electrified).

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_ELECTRIFY, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // {0}’s moves have been electrified!
    PrintMessage BattleStrings_Text_SovereignElectrified_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait
    WaitButtonABTime 30
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
