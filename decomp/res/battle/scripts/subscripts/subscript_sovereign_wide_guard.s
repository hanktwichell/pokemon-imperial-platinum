#include "macros/btlcmd.inc"

// Sovereign (item 11): Wide Guard protects the user's side from spread moves this turn. It fails when the user moves
// last.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_WAITING_BATTLERS, 1, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVar OPCODE_FLAG_ON, BTLVAR_SOVEREIGN_SIDE_GUARDS_ATTACKER, 1
    // Wide Guard protected {0}’s team!
    PrintMessage BattleStrings_Text_SovereignWideGuardProtectedTeam_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
