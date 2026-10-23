#include "macros/btlcmd.inc"

// Sovereign (item 11): Healer. At the end of the turn, a 30% chance to cure the holder's ally of its status condition.
// The ally is BTLSCR_MSG_TEMP, the holder BTLSCR_SIDE_EFFECT_MON (set by the end-of-turn ability check).

_000:
    UpdateMonData OPCODE_SET, BTLSCR_MSG_TEMP, BATTLEMON_STATUS, MON_CONDITION_NONE
    UpdateMonData OPCODE_FLAG_OFF, BTLSCR_MSG_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_NIGHTMARE
    // {2} was cured by {0}’s {1}!
    PrintMessage BattleStrings_Text_SovereignPokemonWasCuredByPokemonsAbility_AllyAlly, TAG_NICKNAME_ABILITY_NICKNAME, BTLSCR_SIDE_EFFECT_MON, BTLSCR_SIDE_EFFECT_MON, BTLSCR_MSG_TEMP
    Wait 
    SetHealthBoxStatusIcon BTLSCR_MSG_TEMP, BATTLE_ANIMATION_NONE
    WaitButtonABTime 30
    End 
