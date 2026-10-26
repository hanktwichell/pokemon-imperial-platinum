#include "macros/btlcmd.inc"

// Sovereign (item 11): Eerie Spell takes 3 PP from the target's last move (TrySpite takes 3 for it). Shield Dust keeps it
// off, as a chance effect.

_000:
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_SHIELD_DUST, _end
    TrySpite _end
    // It reduced the PP of {0}’s {1} by {2}!
    PrintMessage BattleStrings_Text_ItReducedThePPOfPokemonsMoveByX_Ally, TAG_NICKNAME_MOVE_NUMBER, BTLSCR_DEFENDER, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30

_end:
    End 
