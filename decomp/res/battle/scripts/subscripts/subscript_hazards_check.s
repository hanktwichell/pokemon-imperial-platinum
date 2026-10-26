#include "macros/btlcmd.inc"


_000:
    // Sovereign (item 11): Sticky Web (Magic Guard doesn't stop it).
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_STICKY_WEB_SWITCHED_MON, 0, _sovereign_no_web
    // {0} was caught in a sticky web!
    PrintMessage BattleStrings_Text_SovereignCaughtInStickyWeb_Ally, TAG_NICKNAME, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30
    // Mirror Armor keeps the web's drop off (it would go back to the web's setter, which isn't tracked)
    CheckAbility CHECK_NOT_HAVE, BTLSCR_SWITCHED_MON, ABILITY_MIRROR_ARMOR, _sovereign_web_drop
    // {0}’s {1} prevents stat loss!
    PrintMessage BattleStrings_Text_PokemonsAbilityPreventsStatLoss_Ally, TAG_NICKNAME_ABILITY, BTLSCR_SWITCHED_MON, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30
    GoTo _sovereign_no_web

_sovereign_web_drop:
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_SWITCHED_MON
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SPEED_DOWN_1_STAGE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE

_sovereign_no_web:
    CheckAbility CHECK_HAVE, BTLSCR_SWITCHED_MON, ABILITY_MAGIC_GUARD, _105
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_GRAVITY, _037
    CheckItemHoldEffect CHECK_HAVE, BTLSCR_SWITCHED_MON, HOLD_EFFECT_SPEED_DOWN_GROUNDED, _037
    CheckAbility CHECK_HAVE, BTLSCR_SWITCHED_MON, ABILITY_LEVITATE, _085
    CheckAbility CHECK_HAVE, BTLSCR_SWITCHED_MON, ABILITY_EELEVATE, _085 // Sovereign (item 11)
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SWITCHED_MON, BATTLEMON_TYPE_1, TYPE_FLYING, _085
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SWITCHED_MON, BATTLEMON_TYPE_2, TYPE_FLYING, _085
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_SWITCHED_MON, BATTLEMON_MOVE_EFFECTS_MASK, MOVE_EFFECT_MAGNET_RISE, _085

_037:
    CheckToxicSpikes BTLSCR_SWITCHED_MON, _065
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000002, _063
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000001, _059
    // The poison spikes disappeared from around your team’s feet!
    PrintMessage BattleStrings_Text_ThePoisonSpikesDisappearedFromAroundYourTeamsFeet, TAG_NONE_SIDE_CONSCIOUS, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30
    GoTo _065

_059:
    Call BATTLE_SUBSCRIPT_POISON
    GoTo _065

_063:
    Call BATTLE_SUBSCRIPT_BADLY_POISON

_065:
    CheckSpikes BTLSCR_SWITCHED_MON, _085
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_SWITCHED_MON
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} is hurt by the spikes!
    PrintMessage BattleStrings_Text_PokemonIsHurtByTheSpikes_Ally, TAG_NICKNAME, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30

_085:
    CheckStealthRock BTLSCR_SWITCHED_MON, _105
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_SWITCHED_MON
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // Pointed stones dug into {0}!
    PrintMessage BattleStrings_Text_PointedStonesDugIntoPokemon_Ally, TAG_NICKNAME, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30

_105:
    End 
