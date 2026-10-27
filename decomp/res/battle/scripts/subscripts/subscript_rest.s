#include "macros/btlcmd.inc"


_000:
    PrintAttackMessage 
    Wait 
    // Sovereign (FM, item 11): a Meteor Minior (Shields Down) or Purifying Salt can't fall asleep, so Rest fails.
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_ATTACKER
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_STATUS_IMMUNE_EFFECT_MON, TRUE, _sovereignShieldsUp
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_INSOMNIA, _098
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_VITAL_SPIRIT, _098
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_SWEET_VEIL, _098 // Sovereign (item 11)
    // Sovereign (item 11): its partner's Sweet Veil keeps it awake too.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SWEET_VEIL_EFFECT_MON, TRUE, _sovereign_sweet_veil
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_ATTACKER, BATTLEMON_STATUS, MON_CONDITION_SLEEP, _107
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_SOUNDPROOF, _027
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_UPROAR, _115

_027:
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    CompareMonDataToVar OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, BTLVAR_HP_CALC_TEMP, _137
    // Sovereign: Leaf Guard in harsh sunlight (Gen V+), and Electric or Misty Terrain under a grounded user, keep it
    // awake, as they keep any other sleep off.
    CheckIgnoreWeather _sovereign_terrain
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_SOVEREIGN_SIDE_EFFECT_MON_WEATHER, FIELD_CONDITION_SUNNY, _sovereign_terrain
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_LEAF_GUARD, _sovereignShieldsUp

_sovereign_terrain:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SOVEREIGN_TERRAIN_EFFECT_MON, FIELD_CONDITION_TERRAIN_ELECTRIC, _sovereign_electric
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SOVEREIGN_TERRAIN_EFFECT_MON, FIELD_CONDITION_TERRAIN_MISTY, _sovereign_misty
    PlayMoveAnimation BTLSCR_ATTACKER
    Wait 
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_ATTACKER, BATTLEMON_STATUS, MON_CONDITION_NOT_SLEEP, _053
    // {0} went to sleep!
    PrintMessage BattleStrings_Text_PokemonWentToSleep_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    GoTo _065

_053:
    SetHealthBoxStatusIcon BTLSCR_ATTACKER, BATTLE_ANIMATION_NONE
    UpdateMonData OPCODE_FLAG_OFF, BTLSCR_ATTACKER, BATTLEMON_STATUS, MON_CONDITION_NOT_SLEEP
    // {0} slept and became healthy!
    PrintMessage BattleStrings_Text_PokemonSleptAndBecameHealthy_Ally, TAG_NICKNAME, BTLSCR_ATTACKER

_065:
    Wait 
    WaitButtonABTime 30
    UpdateMonData OPCODE_FLAG_ON, BTLSCR_ATTACKER, BATTLEMON_STATUS, MON_CONDITION_SLEEP_0|MON_CONDITION_SLEEP_1
    SetHealthBoxStatusIcon BTLSCR_ATTACKER, BATTLE_ANIMATION_ASLEEP
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_ATTACKER, BATTLEMON_STATUS, MON_CONDITION_NOT_SLEEP, _053
    // {0} regained health!
    PrintMessage BattleStrings_Text_PokemonRegainedHealth_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    GoTo _147

_098:
    WaitButtonABTime 30
    // {0} stayed awake because of its {1}!
    PrintMessage BattleStrings_Text_PokemonStayedAwakeBecauseOfItsAbility_Ally, TAG_NICKNAME_ABILITY, BTLSCR_ATTACKER, BTLSCR_ATTACKER
    GoTo _143

_sovereign_sweet_veil:
    WaitButtonABTime 30
    // {0} can’t fall asleep due to a veil of sweetness!
    PrintMessage BattleStrings_Text_SovereignVeilOfSweetness_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    GoTo _143

_107:
    WaitButtonABTime 30
    // {0} is already asleep!
    PrintMessage BattleStrings_Text_PokemonIsAlreadyAsleep_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    GoTo _143

_115:
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_ATTACKER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_UPROAR, _129
    WaitButtonABTime 30
    // But the uproar kept {0} awake!
    PrintMessage BattleStrings_Text_ButTheUproarKeptPokemonAwake_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    GoTo _143

_129:
    WaitButtonABTime 30
    // But {0} can’t sleep in an uproar!
    PrintMessage BattleStrings_Text_ButPokemonCantSleepInAnUproar_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    GoTo _143

_137:
    WaitButtonABTime 30
    // {0}’s HP is full!
    PrintMessage BattleStrings_Text_PokemonsHPIsFull_Ally, TAG_NICKNAME, BTLSCR_ATTACKER

_143:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK

_147:
    Wait 
    WaitButtonABTime 30
    End 

_sovereignShieldsUp:
    WaitButtonABTime 30
    Call BATTLE_SUBSCRIPT_BUT_IT_FAILED
    GoTo _143

_sovereign_electric:
    WaitButtonABTime 30
    // Sovereign (item 11): {0} surrounds itself with electrified terrain!
    PrintMessage BattleStrings_Text_SovereignProtectedByElectricTerrain_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    GoTo _143

_sovereign_misty:
    WaitButtonABTime 30
    // Sovereign (item 11): {0} surrounds itself with a protective mist!
    PrintMessage BattleStrings_Text_SovereignProtectedByMistyTerrain_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    GoTo _143
