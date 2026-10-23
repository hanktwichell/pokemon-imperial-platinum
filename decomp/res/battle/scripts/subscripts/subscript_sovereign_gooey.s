#include "macros/btlcmd.inc"

// Sovereign (item 11): Gooey and Tangling Hair. A contact move lowers the attacker's Speed 1 stage
// (BattleSystem_TriggerAbilityOnHit).

_000:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_SPEED_STAGE, 0, _end
    PlayBattleAnimation BTLSCR_ATTACKER, BATTLE_ANIMATION_STAT_DROP
    Wait 
    UpdateMonData OPCODE_SUB, BTLSCR_ATTACKER, BATTLEMON_SPEED_STAGE, 1
    UpdateVar OPCODE_SET, BTLVAR_MSG_TEMP, 3
    // {0}’s {1} cuts {2}’s {3}!
    PrintMessage BattleStrings_Text_PokemonsAbilityCutsPokemonsStat_AllyAlly, TAG_NICKNAME_ABILITY_NICKNAME_STAT, BTLSCR_DEFENDER, BTLSCR_DEFENDER, BTLSCR_ATTACKER, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30

_end:
    End 
