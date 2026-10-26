#include "macros/btlcmd.inc"

// Sovereign (item 11): Spirit Shackle, Anchor Shot and Thousand Waves. After the hit, the target can't escape (as Mean
// Look) while the user is in battle. Not through a Substitute.

_000:
    CheckSubstitute BTLSCR_SIDE_EFFECT_MON, _end
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _end
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_MEAN_LOOK, _end
    UpdateMonData OPCODE_FLAG_ON, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_MEAN_LOOK
    UpdateMonDataFromVar OPCODE_FLAG_ON, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_MEAN_LOOK_TARGET, BTLVAR_ATTACKER
    // {0} can no longer escape!
    PrintMessage BattleStrings_Text_PokemonCanNoLongerEscape_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30

_end:
    End 
