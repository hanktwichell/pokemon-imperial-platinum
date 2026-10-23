#include "macros/btlcmd.inc"

// Sovereign (item 11): Incinerate. After the hit, the target's Berry is burnt up.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SIDE_EFFECT_MON_HOLDS_BERRY, 0, _end
    // {0}’s {1} was burnt up!
    PrintMessage BattleStrings_Text_SovereignItemBurntUp_Ally, TAG_NICKNAME_ITEM, BTLSCR_SIDE_EFFECT_MON, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    RemoveItem BTLSCR_SIDE_EFFECT_MON

_end:
    End 
