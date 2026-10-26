#include "macros/btlcmd.inc"

// Sovereign (item 11): Tidy Up clears the entry hazards from both sides (BTLVAR_SOVEREIGN_TIDY_UP_HAZARDS) and every
// Substitute, then raises the user's Attack and Speed by 1 stage.

_000:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_ATTACK_MESSAGE|SYSCTL_PLAYED_MOVE_ANIMATION
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, 0
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_TIDY_UP_HAZARDS, 0, _substitutes
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, 1

_substitutes:
    UpdateVar OPCODE_SET, BTLVAR_BATTLER_SPEED_TEMP, 0

_loop:
    GetMonBySpeedOrder BTLVAR_MSG_BATTLER_TEMP
    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_MSG_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_SUBSTITUTE, _next
    UpdateMonData OPCODE_FLAG_OFF, BTLSCR_MSG_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_SUBSTITUTE
    UpdateMonData OPCODE_SET, BTLSCR_MSG_TEMP, BATTLEMON_SUBSTITUTE_HP, 0
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SUBSTITUTE_OUT
    Wait 
    RestoreSprite BTLSCR_MSG_TEMP
    Wait 
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SUB_IN
    Wait 
    // {0}’s substitute faded!
    PrintMessage BattleStrings_Text_PokemonsSubstituteFaded_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, 1

_next:
    UpdateVar OPCODE_ADD, BTLVAR_BATTLER_SPEED_TEMP, 1
    GoToIfValidMon BTLVAR_BATTLER_SPEED_TEMP, _loop
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0, _boost
    // Tidying up complete!
    PrintMessage BattleStrings_Text_SovereignTidyingUpComplete, TAG_NONE
    Wait 
    WaitButtonABTime 30

_boost:
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_ATTACKER
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SPEED_UP_1_STAGE
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    End 
