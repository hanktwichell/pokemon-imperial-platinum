#include "macros/btlcmd.inc"

// Sovereign (item 11): After You: the target moves next. The reorder happens after the move (BattleControllerPlayer_UpdateMoveBuffers).

_000:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // {0} took the kind offer!
    PrintMessage BattleStrings_Text_SovereignTookTheKindOffer_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    End 
