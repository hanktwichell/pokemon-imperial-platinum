#include "macros/btlcmd.inc"

// Sovereign (item 11): Stamina. The defender's Defense rises 1 stage each time a damaging move hits it
// (BattleSystem_TriggerAbilityOnHit).

_000:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_DEFENSE_STAGE, 12, _end
    PlayBattleAnimation BTLSCR_DEFENDER, BATTLE_ANIMATION_STAT_BOOST
    Wait 
    UpdateMonData OPCODE_ADD, BTLSCR_DEFENDER, BATTLEMON_DEFENSE_STAGE, 1
    UpdateVar OPCODE_SET, BTLVAR_MSG_TEMP, 2
    // {0}’s {1} raised its {2}!
    PrintMessage BattleStrings_Text_PokemonsAbilityRaisedItsStat_Ally, TAG_NICKNAME_ABILITY_STAT, BTLSCR_DEFENDER, BTLSCR_DEFENDER, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30

_end:
    End 
