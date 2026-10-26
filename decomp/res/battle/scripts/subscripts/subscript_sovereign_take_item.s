#include "macros/btlcmd.inc"

// Sovereign (item 11): Magician and Pickpocket. The thief (BTLVAR_MSG_BATTLER_TEMP) takes the held item of the other
// Pokémon (BTLVAR_SIDE_EFFECT_MON), by Thief's rules (Sovereign_CanTakeItem). The item is the message's item.

_000:
    // {0} stole {1}’s {2}!
    PrintMessage BattleStrings_Text_PokemonStolePokemonsItem_AllyAlly, TAG_NICKNAME_NICKNAME_ITEM, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_SIDE_EFFECT_MON, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_HELD_ITEM, BTLVAR_SCRIPT_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_MSG_BATTLER_TEMP, BATTLEMON_HELD_ITEM, BTLVAR_SCRIPT_TEMP
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_HELD_ITEM, ITEM_NONE
    End 
