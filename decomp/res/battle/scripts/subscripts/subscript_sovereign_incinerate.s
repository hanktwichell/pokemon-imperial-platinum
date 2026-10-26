#include "macros/btlcmd.inc"

// Sovereign (item 11): Incinerate. After the hit, the target's Berry is burnt up.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SIDE_EFFECT_MON_HOLDS_BERRY, 0, _end
    // {0}’s {1} was burnt up!
    PrintMessage BattleStrings_Text_SovereignItemBurntUp_Ally, TAG_NICKNAME_ITEM, BTLSCR_SIDE_EFFECT_MON, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    // Not RemoveItem: nobody ate it, and Recycle can't bring it back.
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_HELD_ITEM, ITEM_NONE

_end:
    End 
