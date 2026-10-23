#include "macros/btlcmd.inc"

// Sovereign (item 11): Protean and Libero. The user becomes the type of the move it is about to use, once per
// switch-in. The new type is in BTLVAR_MSG_TEMP (set by BattleControllerPlayer_TryMove).

_000:
    // {0}’s {1} made it the {2} type!
    PrintMessage BattleStrings_Text_PokemonsAbilityMadeItType_Ally, TAG_NICKNAME_ABILITY_TYPE, BTLSCR_ATTACKER, BTLSCR_ATTACKER, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_1, BTLVAR_MSG_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, BTLVAR_MSG_TEMP
    End 
