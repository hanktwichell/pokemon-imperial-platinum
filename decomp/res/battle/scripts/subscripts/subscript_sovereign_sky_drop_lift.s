#include "macros/btlcmd.inc"

// Sovereign (item 11): Sky Drop's first turn (effect script BATTLE_EFFECT_SOVEREIGN_SKY_DROP). The user carries the target
// up; both vanish, and the user is locked into its second turn.

_000:
    PrintAttackMessage 
    Wait 
    SovereignSkyDropLift _failed, _too_heavy
    PlayMoveAnimation BTLSCR_ATTACKER
    Wait 
    ToggleVanish BTLSCR_ATTACKER, TRUE
    ToggleVanish BTLSCR_DEFENDER, TRUE
    // {0} took {1} into the sky!
    PrintMessage BattleStrings_Text_SovereignTookIntoTheSky_AllyAlly, TAG_NICKNAME_NICKNAME, BTLSCR_ATTACKER, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    LockMoveChoice BTLSCR_ATTACKER
    End 

_too_heavy:
    WaitButtonABTime 30
    // {0} is too heavy to be lifted!
    PrintMessage BattleStrings_Text_SovereignTooHeavyToLift_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    End 

_failed:
    WaitButtonABTime 30
    // But it failed!
    PrintMessage BattleStrings_Text_ButItFailed, TAG_NONE
    Wait 
    WaitButtonABTime 30
    End 
