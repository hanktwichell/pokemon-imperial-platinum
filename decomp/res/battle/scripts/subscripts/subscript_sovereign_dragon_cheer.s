#include "macros/btlcmd.inc"

// Sovereign (item 11): Dragon Cheer raises the critical-hit stage of the user's ally by 1, or 2 for a Dragon type,
// until it leaves battle. It fails without an ally, or if the ally is already cheered.

_000:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_DOUBLES, _fail
    UpdateVar OPCODE_BITWISE_XOR, BTLVAR_SIDE_EFFECT_MON, 2
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _fail
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_DRAGON_CHEER_SIDE_EFFECT_MON, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_DRAGON_CHEER_SIDE_EFFECT_MON, 1
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_1, TYPE_DRAGON, _dragon
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_2, TYPE_DRAGON, _message

_dragon:
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_DRAGON_CHEER_SIDE_EFFECT_MON, 2

_message:
    // {0} is getting pumped!
    PrintMessage BattleStrings_Text_PokemonIsGettingPumped_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
