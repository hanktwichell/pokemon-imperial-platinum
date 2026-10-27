#include "macros/btlcmd.inc"

// Sovereign (item 11): the side-effect battler, carried up by Sky Drop, is back on the ground: dropped by the user's
// second turn, or let go (BattleSystem_TriggerEffectOnSwitch).

_000:
    ToggleVanish BTLSCR_SIDE_EFFECT_MON, FALSE
    Wait 
    // {0} was freed from the Sky Drop!
    PrintMessage BattleStrings_Text_SovereignFreedFromSkyDrop_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    End 
