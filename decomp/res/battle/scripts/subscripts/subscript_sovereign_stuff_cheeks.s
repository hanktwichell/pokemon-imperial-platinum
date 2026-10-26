#include "macros/btlcmd.inc"

// Sovereign (item 11): Stuff Cheeks (Showdown's order). The user's Defense +2, then it eats its Berry, whose effect
// works even with Klutz, Embargo or Magic Room. It fails without a Berry, or at +6 Defense, keeping the Berry. It can be
// chosen without a Berry (Champions).

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SIDE_EFFECT_MON_HOLDS_BERRY, 0, _failed
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_DEFENSE_STAGE, 12, _no_change
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_TURN_OFF_MESSAGES
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_ATTACK_MESSAGE|SYSCTL_PLAYED_MOVE_ANIMATION
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_STAT_STAGE_CHANGE_SHOWN
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_DEFENSE_UP_2_STAGES
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_UPDATE_STAT_STAGES
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_STAT_STAGE_CHANGE_SHOWN
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_TURN_OFF_MESSAGES
    SovereignEatOwnBerry _end
    // {0} ate its {1}!
    PrintMessage BattleStrings_Text_SovereignPokemonAteItsItem_Ally, TAG_NICKNAME_ITEM, BTLSCR_ATTACKER, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    RemoveItem BTLSCR_ATTACKER
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 0, _no_effect
    // The Berry's subscript ends with subscript_pluck_check (Cheek Pouch).
    CallFromVar BTLVAR_SCRIPT_TEMP
    End 

_no_effect:
    Call BATTLE_SUBSCRIPT_PLUCK_CHECK

_end:
    End 

_failed:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 

_no_change:
    // As Iron Defense: "{0}’s Defense won’t go higher!"
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_DEFENSE_UP_2_STAGES
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    End 
