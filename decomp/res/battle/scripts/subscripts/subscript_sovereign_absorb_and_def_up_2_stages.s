#include "macros/btlcmd.inc"

// Sovereign (item 11): Well-Baked Body. The holder absorbs the move and its Defense rises 2 stages
// (BattleSystem_TriggerImmunityAbility); like Motor Drive's subscript_absorb_and_speed_up_1_stage.

_000:
    PrintAttackMessage 
    Wait 
    WaitButtonABTime 15
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_DEFENSE_STAGE, 12, _useless
    PlayBattleAnimation BTLSCR_DEFENDER, BATTLE_ANIMATION_STAT_BOOST
    Wait 
    UpdateMonData OPCODE_ADD, BTLSCR_DEFENDER, BATTLEMON_DEFENSE_STAGE, 2
    CompareMonDataToValue OPCODE_LTE, BTLSCR_DEFENDER, BATTLEMON_DEFENSE_STAGE, 12, _message
    UpdateMonData OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_DEFENSE_STAGE, 12

_message:
    UpdateVar OPCODE_SET, BTLVAR_MSG_TEMP, 2
    // {0}’s {1} raised its {2}!
    PrintMessage BattleStrings_Text_PokemonsAbilityRaisedItsStat_Ally, TAG_NICKNAME_ABILITY_STAT, BTLSCR_DEFENDER, BTLSCR_DEFENDER, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    End 

_useless:
    // {0}’s {1} made {2} useless!
    PrintMessage BattleStrings_Text_PokemonsAbilityMadeMoveUseless_Ally, TAG_NICKNAME_ABILITY_MOVE, BTLSCR_DEFENDER, BTLSCR_DEFENDER, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 
