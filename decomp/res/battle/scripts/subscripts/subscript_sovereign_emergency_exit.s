#include "macros/btlcmd.inc"

// Sovereign (item 11): Emergency Exit and Wimp Out. A hit dropped the holder (BTLSCR_DEFENDER) from above half its HP
// to half or less (BattleSystem_TriggerHeldItemOnHit): it switches out to a Pokémon its trainer picks, as with an Eject
// Button, or a wild one flees, as by Teleport. Nothing happens if it can do neither.

_000:
    TryReplaceFaintedMon BTLSCR_DEFENDER, TRUE, _no_switch
    // {0}’s {1} activated!
    PrintMessage BattleStrings_Text_SovereignAbilityActivated_Ally, TAG_NICKNAME_ABILITY, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    UpdateVarFromVar OPCODE_SET, BTLVAR_SWITCHED_MON, BTLVAR_DEFENDER
    // {0} went back to {1}!
    PrintMessage BattleStrings_Text_PokemonWentBackToTrainer_Ally, TAG_NICKNAME_TRNAME, BTLSCR_SWITCHED_MON, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30
    TryRestoreStatusOnSwitch BTLSCR_DEFENDER, _switch
    UpdateMonData OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_STATUS, MON_CONDITION_NONE

_switch:
    DeletePokemon BTLSCR_DEFENDER
    Wait 
    HealthBoxSlideOut BTLSCR_DEFENDER
    Wait 
    GoToSubscript BATTLE_SUBSCRIPT_SHOW_PARTY_LIST

_no_switch:
    // A wild Pokémon (the foe's side in a wild single battle) flees instead.
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_TRAINER, _end
    CompareVarToValue OPCODE_EQU, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_DOUBLES|BATTLE_TYPE_2vs2|BATTLE_TYPE_AI, _end
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_DEFENDER, 1, _end
    // {0}’s {1} activated!
    PrintMessage BattleStrings_Text_SovereignAbilityActivated_Ally, TAG_NICKNAME_ABILITY, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    // {0} fled from battle!
    PrintMessage BattleStrings_Text_PokemonFledFromBattle_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    FadeOutBattle 
    Wait 
    UpdateVar OPCODE_FLAG_ON, BTLVAR_RESULT_MASK, BATTLE_RESULT_PLAYER_FLED
    IncrementGameRecord BTLSCR_DEFENDER, BATTLER_TYPE_SOLO_ENEMY, RECORD_WILD_MON_FLED

_end:
    End 
