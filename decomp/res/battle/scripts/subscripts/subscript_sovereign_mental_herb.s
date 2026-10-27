#include "macros/btlcmd.inc"

// Sovereign: the Mental Herb (BTLSCR_MSG_TEMP) cures infatuation, Torment, Disable, Heal Block, Encore and Taunt all
// at once (Gen V+), one message for each, in the later games' order. Platinum's Mental Herb only cured infatuation.

_000:
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_HELD_ITEM
    Wait
    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_MSG_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_ATTRACT, _torment
    // {0} cured its {2} status using its {1}!
    PrintMessage BattleStrings_Text_PokemonCuredItsStatusUsingItsItem_Ally, TAG_NICKNAME_ITEM_STATUS, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30
    UpdateMonData OPCODE_FLAG_OFF, BTLSCR_MSG_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_ATTRACT

_torment:
    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_MSG_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_TORMENT, _disable
    UpdateMonData OPCODE_FLAG_OFF, BTLSCR_MSG_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_TORMENT
    // {0} is no longer tormented!
    PrintMessage BattleStrings_Text_SovereignNoLongerTormented_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30

_disable:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_MSG_TEMP, BATTLEMON_DISABLED_MOVE, MOVE_NONE, _heal_block
    UpdateMonData OPCODE_SET, BTLSCR_MSG_TEMP, BATTLEMON_DISABLED_MOVE, MOVE_NONE
    UpdateMonData OPCODE_SET, BTLSCR_MSG_TEMP, BATTLEMON_DISABLED_TURNS, 0
    // {0} is no longer disabled!
    PrintMessage BattleStrings_Text_PokemonIsNoLongerDisabled_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30

_heal_block:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_MSG_TEMP, BATTLEMON_HEAL_BLOCK_TURNS, 0, _encore
    UpdateMonData OPCODE_SET, BTLSCR_MSG_TEMP, BATTLEMON_HEAL_BLOCK_TURNS, 0
    UpdateMonData OPCODE_FLAG_OFF, BTLSCR_MSG_TEMP, BATTLEMON_MOVE_EFFECTS_MASK, MOVE_EFFECT_HEAL_BLOCK
    UpdateVar OPCODE_SET, BTLVAR_MSG_MOVE_TEMP, MOVE_HEAL_BLOCK
    // {0}’s {1} wore off!
    PrintMessage BattleStrings_Text_PokemonsMoveWoreOff_Ally, TAG_NICKNAME_MOVE, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30

_encore:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_MSG_TEMP, BATTLEMON_ENCORED_MOVE, MOVE_NONE, _taunt
    UpdateMonData OPCODE_SET, BTLSCR_MSG_TEMP, BATTLEMON_ENCORED_MOVE, MOVE_NONE
    UpdateMonData OPCODE_SET, BTLSCR_MSG_TEMP, BATTLEMON_ENCORED_TURNS, 0
    // {0}’s encore ended!
    PrintMessage BattleStrings_Text_PokemonsEncoreEnded_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30

_taunt:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_MSG_TEMP, BATTLEMON_TAUNTED_TURNS, 0, _end
    UpdateMonData OPCODE_SET, BTLSCR_MSG_TEMP, BATTLEMON_TAUNTED_TURNS, 0
    UpdateVar OPCODE_SET, BTLVAR_MSG_MOVE_TEMP, MOVE_TAUNT
    // {0}’s {1} wore off!
    PrintMessage BattleStrings_Text_PokemonsTauntWoreOff_Ally, TAG_NICKNAME_MOVE, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30

_end:
    Call BATTLE_SUBSCRIPT_PLUCK_CHECK
    End
