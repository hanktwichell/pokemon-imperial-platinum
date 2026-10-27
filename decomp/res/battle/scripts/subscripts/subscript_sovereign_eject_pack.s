#include "macros/btlcmd.inc"

// Sovereign (item 11): Eject Pack. The holder (BTLSCR_SWITCHED_MON) had a stat lowered; after the move, the switch-in
// effects or the end of the turn (Sovereign_EjectPackHolder) it switches out to a Pokémon its trainer picks, as with an
// Eject Button. Nothing happens, and it keeps the pack, if it has no Pokémon to switch to.

_000:
    TryReplaceFaintedMon BTLSCR_SWITCHED_MON, TRUE, _end
    PlayBattleAnimation BTLSCR_SWITCHED_MON, BATTLE_ANIMATION_HELD_ITEM
    Wait 
    // {0} is switched out with the Eject Pack!
    PrintMessage BattleStrings_Text_SovereignSwitchedOutWithEjectPack_Ally, TAG_NICKNAME, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30
    RemoveItem BTLSCR_SWITCHED_MON
    TryRestoreStatusOnSwitch BTLSCR_SWITCHED_MON, _switch
    UpdateMonData OPCODE_SET, BTLSCR_SWITCHED_MON, BATTLEMON_STATUS, MON_CONDITION_NONE

_switch:
    DeletePokemon BTLSCR_SWITCHED_MON
    Wait 
    HealthBoxSlideOut BTLSCR_SWITCHED_MON
    Wait 
    GoToSubscript BATTLE_SUBSCRIPT_SHOW_PARTY_LIST

_end:
    End 
