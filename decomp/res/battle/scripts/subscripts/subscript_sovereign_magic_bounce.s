#include "macros/btlcmd.inc"

// Sovereign (item 11): Magic Bounce reflects a status move back at its user (BattleControllerPlayer_MoveStolen).

_000:
    PrintAttackMessage 
    Wait 
    WaitButtonABTime 15
    // {0}’s {1} was bounced back by Magic Bounce!
    PrintMessage BattleStrings_Text_SovereignBouncedBackByMagicBounce_Ally, TAG_NICKNAME_MOVE, BTLSCR_ATTACKER, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    MagicCoat 
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_PLAYED_MOVE_ANIMATION
    End 
