#include "macros/btlcmd.inc"

// Sovereign: Teleport switches the user out to a Pokémon its trainer picks (Gen VIII+), in a trainer battle or when
// the player's Pokémon uses it. It fails with no Pokémon to switch to. A wild Pokémon still flees (subscript_teleport;
// effect_script_0153).

_000:
    TryReplaceFaintedMon BTLSCR_ATTACKER, TRUE, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVarFromVar OPCODE_SET, BTLVAR_SWITCHED_MON, BTLVAR_ATTACKER
    // {0} went back to {1}!
    PrintMessage BattleStrings_Text_PokemonWentBackToTrainer_Ally, TAG_NICKNAME_TRNAME, BTLSCR_SWITCHED_MON, BTLSCR_SWITCHED_MON
    Wait
    WaitButtonABTime 30
    TryRestoreStatusOnSwitch BTLSCR_ATTACKER, _switch
    UpdateMonData OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_STATUS, MON_CONDITION_NONE

_switch:
    DeletePokemon BTLSCR_ATTACKER
    Wait
    HealthBoxSlideOut BTLSCR_ATTACKER
    Wait
    GoToSubscript BATTLE_SUBSCRIPT_SHOW_PARTY_LIST

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
