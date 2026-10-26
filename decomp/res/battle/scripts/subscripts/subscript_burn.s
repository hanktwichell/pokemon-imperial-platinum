#include "macros/btlcmd.inc"


_000:
    CompareVarToValue OPCODE_NEQ, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_HELD_ITEM, _052
    CheckAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_WATER_VEIL, _211
    // Sovereign (item 11): Water Bubble and Thermal Exchange keep burns off too.
    CheckAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_WATER_BUBBLE, _211
    CheckAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_THERMAL_EXCHANGE, _211
    // Sovereign (FM, item 11): Shields Down (a Meteor Minior) and Purifying Salt keep every status condition off.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_STATUS_IMMUNE_EFFECT_MON, TRUE, _211
    // Sovereign (item 11): Flower Veil, its own or its partner's (for a Grass type).
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_FLOWER_VEIL_EFFECT_MON, TRUE, _sovereign_flower_veil
    CheckIgnoreWeather _021
    // Sovereign (item 11): sunlight as it acts on the target (not on a Utility Umbrella holder)
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_SOVEREIGN_SIDE_EFFECT_MON_WEATHER, FIELD_CONDITION_SUNNY, _021
    CheckAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_LEAF_GUARD, _211

_021:
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_BURN, _211
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_1, TYPE_FIRE, _211
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_2, TYPE_FIRE, _211
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_NONE, _211
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SIDE_CONDITIONS_EFFECT_MON, SIDE_CONDITION_SAFEGUARD, _211
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SOVEREIGN_TERRAIN_EFFECT_MON, FIELD_CONDITION_TERRAIN_MISTY, _211 // Sovereign (item 11)
    GoTo _141

_052:
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_WATER_VEIL, _264
    // Sovereign (item 11): Water Bubble and Thermal Exchange keep burns off too.
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_WATER_BUBBLE, _264
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_THERMAL_EXCHANGE, _264
    // Sovereign (FM, item 11): Shields Down (a Meteor Minior) and Purifying Salt keep every status condition off.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_STATUS_IMMUNE_EFFECT_MON, TRUE, _264
    // Sovereign (item 11): Flower Veil, its own or its partner's (for a Grass type).
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_FLOWER_VEIL_EFFECT_MON, TRUE, _sovereign_flower_veil
    CheckIgnoreWeather _069
    // Sovereign (item 11): sunlight as it acts on the target (not on a Utility Umbrella holder)
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_SOVEREIGN_SIDE_EFFECT_MON_WEATHER, FIELD_CONDITION_SUNNY, _069
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_LEAF_GUARD, _264

_069:
    CompareVarToValue OPCODE_NEQ, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT, _079
    // Sovereign (item 11): Burning Bulwark's burn isn't a chance effect (subscript_sovereign_shield_contact)
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_NONE, _079
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_SHIELD_DUST, _212

_079:
    CompareVarToValue OPCODE_NEQ, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_DIRECT, _086
    PrintAttackMessage 
    Wait 

_086:
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY, _094
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_NONE, _094 // Sovereign (item 11): Burning Bulwark
    CheckSubstitute BTLSCR_SIDE_EFFECT_MON, _212

_094:
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_BURN, _228
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_1, TYPE_FIRE, _246
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_TYPE_2, TYPE_FIRE, _246
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_NONE, _212
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY, _141
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _212
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SIDE_CONDITIONS_EFFECT_MON, SIDE_CONDITION_SAFEGUARD, _294
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SOVEREIGN_TERRAIN_EFFECT_MON, FIELD_CONDITION_TERRAIN_MISTY, _sovereign_misty_2
    CompareVarToValue OPCODE_NEQ, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_DIRECT, _141
    PlayMoveAnimation BTLSCR_ATTACKER
    Wait 

_141:
    CompareVarToValue OPCODE_NEQ, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_HELD_ITEM, _152
    PlayBattleAnimation BTLSCR_SIDE_EFFECT_MON, BATTLE_ANIMATION_HELD_ITEM
    Wait 
    WaitButtonABTime 15

_152:
    PlayBattleAnimation BTLSCR_SIDE_EFFECT_MON, BATTLE_ANIMATION_BURNED
    Wait 
    UpdateMonData OPCODE_FLAG_ON, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_BURN
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY, _177
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_HELD_ITEM, _185
    // {0} was burned!
    PrintMessage BattleStrings_Text_PokemonWasBurned_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    GoTo _190

_177:
    // {0}’s {1} burned {2}!
    PrintMessage BattleStrings_Text_PokemonsAbilityBurnedPokemon_AllyAlly, TAG_NICKNAME_ABILITY_NICKNAME, BTLSCR_MSG_TEMP, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_SIDE_EFFECT_MON
    GoTo _190

_185:
    // {0} got a burn from the {1}!
    PrintMessage BattleStrings_Text_PokemonGotABurnFromTheItem_Ally, TAG_NICKNAME_ITEM, BTLSCR_SIDE_EFFECT_MON, BTLSCR_MSG_TEMP

_190:
    Wait 
    SetHealthBoxStatusIcon BTLSCR_SIDE_EFFECT_MON, BATTLE_ANIMATION_BURNED
    WaitButtonABTime 30
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_TRY_SYNCHRONIZE_STATUS, _207
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_TRY_SYNCHRONIZE_STATUS
    GoTo _211

_207:
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_TRY_SYNCHRONIZE_STATUS

_211:
    End 

_212:
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT, _312
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY, _312
    WaitButtonABTime 30
    Call BATTLE_SUBSCRIPT_BUT_IT_FAILED
    GoTo _312

_228:
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT, _312
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY, _312
    WaitButtonABTime 30
    // {0} already has a burn.
    PrintMessage BattleStrings_Text_PokemonAlreadyHasABurn_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    GoTo _305

_246:
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT, _312
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY, _312
    WaitButtonABTime 30
    // It doesn’t affect {0}...
    PrintMessage BattleStrings_Text_ItDoesntAffectPokemon_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    GoTo _305

_264:
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT, _312
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY, _312
    PrintAttackMessage 
    Wait 
    WaitButtonABTime 30
    // {0}’s {1} prevents burns!
    PrintMessage BattleStrings_Text_PokemonsAbilityPreventsBurns_Ally, TAG_NICKNAME_ABILITY, BTLSCR_SIDE_EFFECT_MON, BTLSCR_SIDE_EFFECT_MON
    GoTo _305
    // {0}’s {1} suppressed {2}’s {3}!
    PrintMessage BattleStrings_Text_PokemonsAbilitySuppressedPokemonsAbility_AllyAlly, TAG_NICKNAME_ABILITY_NICKNAME_ABILITY, BTLSCR_SIDE_EFFECT_MON, BTLSCR_SIDE_EFFECT_MON, BTLSCR_MSG_TEMP, BTLSCR_MSG_BATTLER_TEMP
    GoTo _305

_294:
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT, _312
    WaitButtonABTime 30
    // {0} is protected by Safeguard!
    PrintMessage BattleStrings_Text_PokemonIsProtectedBySafeguard_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON

_305:
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK

_312:
    End 

_sovereign_misty_2:
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT, _312
    WaitButtonABTime 30
    // Sovereign (item 11): {0} surrounds itself with ...
    PrintMessage BattleStrings_Text_SovereignProtectedByMistyTerrain_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    GoTo _305

_sovereign_flower_veil:
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, ABILITY_FLOWER_VEIL
    Call BATTLE_SUBSCRIPT_SOVEREIGN_VEIL
    End 
