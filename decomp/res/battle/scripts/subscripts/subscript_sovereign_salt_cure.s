#include "macros/btlcmd.inc"

// Sovereign (item 11): Salt Cure takes hold of the target (subscript_sovereign_salt_cure_damage hurts it at the end of
// each turn). Shield Dust keeps it off, as a chance effect.

_000:
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_SHIELD_DUST, _end
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SALT_CURE_START, 0, _end
    // {0} is being salt cured!
    PrintMessage BattleStrings_Text_SovereignBeingSaltCured_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30

_end:
    End 
