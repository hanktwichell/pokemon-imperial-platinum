#include "macros/btlcmd.inc"

// Sovereign (item 11): Quash: the target moves last. The reorder happens after the move (BattleControllerPlayer_UpdateMoveBuffers).

_000:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // {0}’s move was postponed!
    PrintMessage BattleStrings_Text_SovereignMoveWasPostponed_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    End 
