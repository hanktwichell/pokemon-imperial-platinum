#include "macros/btlcmd.inc"

// Sovereign (item 11): Simple Beam. The target's ability becomes Simple.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CheckSubstitute BTLSCR_DEFENDER, _fail
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_ABILITY, ABILITY_SIMPLE, _fail
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_ABILITY, ABILITY_TRUANT, _fail
    // Gen IX's list of abilities that can't be overwritten
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_CANT_SUPPRESS_DEFENDER, 0, _fail
    // Sovereign (item 11): an Ability Shield keeps its holder's Ability
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_ABILITY_SHIELD_DEFENDER, 0, _sovereign_ability_shield
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateMonData OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_ABILITY, ABILITY_SIMPLE
    // {0} acquired {1}!
    PrintMessage BattleStrings_Text_PokemonAcquiredAbility_Ally, TAG_NICKNAME_ABILITY, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 

_sovereign_ability_shield:
    Call BATTLE_SUBSCRIPT_SOVEREIGN_ABILITY_SHIELD
    End 
