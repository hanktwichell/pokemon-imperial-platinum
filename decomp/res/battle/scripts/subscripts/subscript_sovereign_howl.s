#include "macros/btlcmd.inc"

// Sovereign: Howl raises the Attack of its user and, in a double battle, of the user's ally (Gen VIII+). It's a sound
// move, so the ally's Soundproof keeps it off. effect_script_0010.s sends Howl here.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_DOUBLES, _end
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_ATTACKER
    UpdateVar OPCODE_BITWISE_XOR, BTLVAR_SIDE_EFFECT_MON, 2
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _end
    // The attack message and animation have played: the ally's change shows only its own.
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT
    CheckAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_SOUNDPROOF, _soundproof
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE

_end:
    End 

_soundproof:
    // {0}’s {1} blocks {2}!
    PrintMessage BattleStrings_Text_PokemonsAbilityBlocksMove_Ally, TAG_NICKNAME_ABILITY_MOVE, BTLSCR_SIDE_EFFECT_MON, BTLSCR_SIDE_EFFECT_MON, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 
