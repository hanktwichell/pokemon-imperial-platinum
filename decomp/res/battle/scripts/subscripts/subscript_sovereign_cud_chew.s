#include "macros/btlcmd.inc"

// Sovereign (item 11): Cud Chew. The holder (BTLVAR_MSG_BATTLER_TEMP, the attacker too) eats again the Berry it ate
// the turn before (BattleSystem_TriggerTurnEndAbility): the Berry is BTLVAR_MSG_ITEM_TEMP, its effect subscript
// BTLVAR_SCRIPT_TEMP (0 for none), as for Stuff Cheeks.

_000:
    // {0}’s {1} activated!
    PrintMessage BattleStrings_Text_SovereignAbilityActivated_Ally, TAG_NICKNAME_ABILITY, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_MSG_BATTLER_TEMP
    Wait 
    WaitButtonABTime 30
    // {0} ate its {1}!
    PrintMessage BattleStrings_Text_SovereignPokemonAteItsItem_Ally, TAG_NICKNAME_ITEM, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 0, _no_effect
    // The Berry's subscript ends with subscript_pluck_check (Cheek Pouch; no RemoveItem, as the Berry was taken).
    CallFromVar BTLVAR_SCRIPT_TEMP
    End 

_no_effect:
    Call BATTLE_SUBSCRIPT_PLUCK_CHECK
    End 
