#include "macros/btlcmd.inc"

// Sovereign (FM): a confused Mimikyu hurt itself, and its disguise took the hit (subscript_hurt_self_in_confusion,
// with the disguise in place of the damage). The C side has busted the disguise and set HP_CALC_TEMP.

_000:
    // {0} is confused!
    PrintMessage BattleStrings_Text_PokemonIsConfused_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    PlayBattleAnimation BTLSCR_ATTACKER, BATTLE_ANIMATION_CONFUSED
    Wait 
    // It hurt itself in its confusion!
    PrintMessage BattleStrings_Text_ItHurtItselfInItsConfusion, TAG_NONE
    Wait 
    WaitButtonABTime 30
    UnlockMoveChoice BTLSCR_ATTACKER
    Call BATTLE_SUBSCRIPT_SOVEREIGN_DISGUISE
    End 
