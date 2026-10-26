#include "macros/btlcmd.inc"

// Sovereign (item 11): Syrup Bomb covers the target in syrup (its Speed falls at the end of the next 3 turns,
// subscript_sovereign_syrup_bomb_drop). Shield Dust keeps it off, as a chance effect.

_000:
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_SHIELD_DUST, _end
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SYRUP_BOMB_START, 0, _end
    // {0} got covered in sticky candy syrup!
    PrintMessage BattleStrings_Text_SovereignCoveredInSyrup_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30

_end:
    End 
