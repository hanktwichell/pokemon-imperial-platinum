#include "macros/btlcmd.inc"

// Sovereign (item 11): Instruct. The target uses its last move again as soon as this move is over, as an extra action
// (BattleControllerPlayer_MoveEnd). It fails when that move can't be used again now (Sovereign_CanInstruct).

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_INSTRUCT, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // {0} followed {1}’s instructions!
    PrintMessage BattleStrings_Text_SovereignFollowedInstructions_AllyAlly, TAG_NICKNAME_NICKNAME, BTLSCR_DEFENDER, BTLSCR_ATTACKER
    Wait
    WaitButtonABTime 30
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
