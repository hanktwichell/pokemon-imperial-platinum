#include "macros/btlcmd.inc"

// Sovereign (item 11): Bestow gives the user's held item to a target holding none. It fails if the user holds nothing,
// the target already holds an item, or the item is the Griseous Orb.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_HELD_ITEM, ITEM_NONE, _fail
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_DEFENDER, BATTLEMON_HELD_ITEM, ITEM_NONE, _fail
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_HELD_ITEM, ITEM_GRISEOUS_ORB, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_HELD_ITEM, BTLVAR_SCRIPT_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_HELD_ITEM, BTLVAR_SCRIPT_TEMP
    UpdateMonData OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_HELD_ITEM, ITEM_NONE
    // {0} obtained one {1}.
    PrintMessage BattleStrings_Text_PokemonObtainedOneItem_Ally, TAG_NICKNAME_ITEM, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
