#include "macros/btlcmd.inc"

// Sovereign (item 11): Laser Focus. The user's moves always crit this turn and the next.

_000:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_LASER_FOCUS_SIDE_EFFECT_MON, 2
    // {0} concentrated intensely!
    PrintMessage BattleStrings_Text_SovereignConcentratedIntensely_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    End 
