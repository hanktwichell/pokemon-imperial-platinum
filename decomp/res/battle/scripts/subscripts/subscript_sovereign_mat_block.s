#include "macros/btlcmd.inc"

// Sovereign (item 11): Mat Block protects the user's side from damaging moves this turn. It only works on the user's
// first turn in battle since it came in, and fails when the user moves last.

_000:
    CompareMonDataToVar OPCODE_NEQ, BTLSCR_ATTACKER, BATTLEMON_FAKE_OUT_TURN_NUMBER, BTLVAR_TOTAL_TURNS, _fail
    CompareVarToValue OPCODE_EQU, BTLVAR_WAITING_BATTLERS, 1, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVar OPCODE_FLAG_ON, BTLVAR_SOVEREIGN_SIDE_GUARDS_ATTACKER, 4
    // {0} intends to flip up a mat and block incoming attacks!
    PrintMessage BattleStrings_Text_SovereignMatBlock_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
