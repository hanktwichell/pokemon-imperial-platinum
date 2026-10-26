#include "macros/btlcmd.inc"

// Sovereign (item 11): Sparkling Aria heals the burn of the Pokemon it hits. Shield Dust keeps it off, as a chance
// effect.

_000:
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_SHIELD_DUST, _end
    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_BURN, _end
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_NONE
    // {0}’s burn was healed!
    PrintMessage BattleStrings_Text_SovereignBurnHealed_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    SetHealthBoxStatusIcon BTLSCR_SIDE_EFFECT_MON, BATTLE_ANIMATION_NONE
    WaitButtonABTime 30

_end:
    End 
