#include "macros/btlcmd.inc"

// Sovereign (item 11): Emergency Exit and Wimp Out. The holder (BTLSCR_SWITCHED_MON) fell from above half its HP to half
// or less: by a hit (BattleSystem_TriggerHeldItemOnHit), its own move, the end-of-turn damage or the entry hazards. It
// switches out to a Pokémon its trainer picks, as with an Eject Button, or a wild one flees, as by Teleport. Nothing
// happens if it can do neither. The holder is the switched Pokémon, not the defender, so that a check made in the middle
// of a move leaves its defender alone.

_000:
    TryReplaceFaintedMon BTLSCR_SWITCHED_MON, TRUE, _no_switch
    // {0}’s {1} activated!
    PrintMessage BattleStrings_Text_SovereignAbilityActivated_Ally, TAG_NICKNAME_ABILITY, BTLSCR_SWITCHED_MON, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30
    // {0} went back to {1}!
    PrintMessage BattleStrings_Text_PokemonWentBackToTrainer_Ally, TAG_NICKNAME_TRNAME, BTLSCR_SWITCHED_MON, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30
    TryRestoreStatusOnSwitch BTLSCR_SWITCHED_MON, _switch
    UpdateMonData OPCODE_SET, BTLSCR_SWITCHED_MON, BATTLEMON_STATUS, MON_CONDITION_NONE

_switch:
    DeletePokemon BTLSCR_SWITCHED_MON
    Wait 
    HealthBoxSlideOut BTLSCR_SWITCHED_MON
    Wait 
    GoToSubscript BATTLE_SUBSCRIPT_SHOW_PARTY_LIST

_no_switch:
    // A wild Pokémon (the foe's side in a wild single battle) flees instead.
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_TRAINER, _end
    CompareVarToValue OPCODE_EQU, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_DOUBLES|BATTLE_TYPE_2vs2|BATTLE_TYPE_AI, _end
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_SWITCHED_MON, 1, _end
    // {0}’s {1} activated!
    PrintMessage BattleStrings_Text_SovereignAbilityActivated_Ally, TAG_NICKNAME_ABILITY, BTLSCR_SWITCHED_MON, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30
    // {0} fled from battle!
    PrintMessage BattleStrings_Text_PokemonFledFromBattle_Ally, TAG_NICKNAME, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30
    FadeOutBattle 
    Wait 
    UpdateVar OPCODE_FLAG_ON, BTLVAR_RESULT_MASK, BATTLE_RESULT_PLAYER_FLED
    IncrementGameRecord BTLSCR_SWITCHED_MON, BATTLER_TYPE_SOLO_ENEMY, RECORD_WILD_MON_FLED

_end:
    End 
