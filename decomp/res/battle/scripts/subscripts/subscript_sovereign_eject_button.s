#include "macros/btlcmd.inc"

// Sovereign (item 11): Eject Button. The holder (BTLSCR_DEFENDER) switches out after the hit, to a Pokémon its trainer
// picks, as a U-turn user does (subscript_attack_then_switch_out; BattleSystem_TriggerHeldItemOnHit). Nothing happens
// if it has no Pokémon to switch to.

_000:
    TryReplaceFaintedMon BTLSCR_DEFENDER, TRUE, _end
    PlayBattleAnimation BTLSCR_DEFENDER, BATTLE_ANIMATION_HELD_ITEM
    Wait 
    // {0} is switched out with the Eject Button!
    PrintMessage BattleStrings_Text_SovereignSwitchedOutWithEjectButton_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    RemoveItem BTLSCR_DEFENDER
    UpdateVarFromVar OPCODE_SET, BTLVAR_SWITCHED_MON, BTLVAR_DEFENDER
    TryRestoreStatusOnSwitch BTLSCR_DEFENDER, _switch
    UpdateMonData OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_STATUS, MON_CONDITION_NONE

_switch:
    DeletePokemon BTLSCR_DEFENDER
    Wait 
    HealthBoxSlideOut BTLSCR_DEFENDER
    Wait 
    GoToSubscript BATTLE_SUBSCRIPT_SHOW_PARTY_LIST

_end:
    End 
