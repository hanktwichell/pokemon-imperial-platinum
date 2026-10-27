#include "macros/btlcmd.inc"


_000:
    // Sovereign (item 11): Healing Wish and Lunar Dance heal the Pokémon that comes into their slot first, before the
    // entry hazards (Gen V+), if it needs it (BTLVAR_SOVEREIGN_HEALING_WISH_SWITCHED_MON). Lunar Dance restores its PP
    // too. Inline, not through subscript_wish_heal: after a U-turn this subscript already runs 2 calls deep.
    UpdateVarFromVar OPCODE_SET, BTLVAR_CALC_TEMP, BTLVAR_SOVEREIGN_HEALING_WISH_SWITCHED_MON
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0, _sovereign_no_wish
    UpdateMonData OPCODE_SET, BTLSCR_SWITCHED_MON, BATTLEMON_STATUS, MON_CONDITION_NONE
    SetHealthBoxStatusIcon BTLSCR_SWITCHED_MON, BATTLE_ANIMATION_NONE
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, SOVEREIGN_WISH_LUNAR_DANCE, _sovereign_lunar_dance
    // The healing wish came true!
    PrintMessage BattleStrings_Text_TheHealingWishCameTrue, TAG_NONE
    GoTo _sovereign_wish_heal

_sovereign_lunar_dance:
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_SWITCHED_MON, BATTLEMON_MAX_PP_1, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_SWITCHED_MON, BATTLEMON_CUR_PP_1, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_SWITCHED_MON, BATTLEMON_MAX_PP_2, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_SWITCHED_MON, BATTLEMON_CUR_PP_2, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_SWITCHED_MON, BATTLEMON_MAX_PP_3, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_SWITCHED_MON, BATTLEMON_CUR_PP_3, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_SWITCHED_MON, BATTLEMON_MAX_PP_4, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_SWITCHED_MON, BATTLEMON_CUR_PP_4, BTLVAR_CALC_TEMP
    // It became cloaked in mystical moonlight!
    PrintMessage BattleStrings_Text_ItBecameCloakedInAMysticalMoonlight, TAG_NONE

_sovereign_wish_heal:
    Wait 
    WaitButtonABTime 30
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_SWITCHED_MON, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    CompareMonDataToVar OPCODE_EQU, BTLSCR_SWITCHED_MON, BATTLEMON_CUR_HP, BTLVAR_HP_CALC_TEMP, _sovereign_no_wish
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_SWITCHED_MON
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    PlayBattleAnimation BTLSCR_SWITCHED_MON, BATTLE_ANIMATION_RESTORE_HP
    Wait 
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} regained health!
    PrintMessage BattleStrings_Text_PokemonRegainedHealth_Ally, TAG_NICKNAME, BTLSCR_SWITCHED_MON
    Wait 
    WaitButtonABTime 30

_sovereign_no_wish:
    // Sovereign (item 11): Infiltrator doesn't get past Safeguard or Mist for entry hazards (Sovereign_Infiltrates).
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_IN_HAZARDS, TRUE
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
    // Sovereign (item 11): Sovereign_IsGrounded, Platinum's checks (Gravity, Iron Ball, Levitate, Flying type, Magnet
    // Rise) plus the Air Balloon, Telekinesis and Smack Down
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SWITCHED_MON_GROUNDED, 0, _085

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
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_IN_HAZARDS, FALSE
    End 
