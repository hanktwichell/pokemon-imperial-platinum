#include "macros/btlcmd.inc"

// Sovereign (item 11): Wide Guard protects the user's side from spread moves this turn.

_000:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVar OPCODE_FLAG_ON, BTLVAR_SOVEREIGN_SIDE_GUARDS_ATTACKER, 1
    // Wide Guard protected {0}’s team!
    PrintMessage BattleStrings_Text_SovereignWideGuardProtectedTeam_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 
