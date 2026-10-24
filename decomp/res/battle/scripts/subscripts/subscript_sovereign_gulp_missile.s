#include "macros/btlcmd.inc"

// Sovereign (FM): Gulp Missile. A Gulping or Gorging Cramorant was hit (BattleSystem_TriggerAbilityOnHit) and spits
// its catch at the attacker. The C side has set Cramorant (the defender) back to its base form, HP_CALC_TEMP to 1/4 of
// the attacker's max HP (0 with Magic Guard) and MSG_TEMP to 0 for an Arrokuda (Defense -1) or 1 for a Pikachu
// (paralysis). It happens even when the hit knocks Cramorant out.

_000:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_CUR_HP, 0, _damage
    PlaySound BTLSCR_DEFENDER, 1980
    SetMosaic BTLSCR_DEFENDER, 8, 1
    Wait 
    ChangeForm BTLSCR_DEFENDER
    PlaySound BTLSCR_DEFENDER, 1984
    SetMosaic BTLSCR_DEFENDER, 0, 1
    Wait 

_damage:
    CompareVarToValue OPCODE_EQU, BTLVAR_HP_CALC_TEMP, 0, _effect
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0}’s {1} hurt {2}!
    PrintMessage BattleStrings_Text_PokemonsAbilityHurtPokemon_AllyAlly, TAG_NICKNAME_ABILITY_NICKNAME, BTLSCR_DEFENDER, BTLSCR_DEFENDER, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30

_effect:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0, _end
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 1, _paralyze
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_DEFENSE_STAGE, 0, _end
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_CLEAR_BODY, _end
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_WHITE_SMOKE, _end
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_FULL_METAL_BODY, _end
    PlayBattleAnimation BTLSCR_ATTACKER, BATTLE_ANIMATION_STAT_DROP
    Wait 
    UpdateMonData OPCODE_SUB, BTLSCR_ATTACKER, BATTLEMON_DEFENSE_STAGE, 1
    UpdateVar OPCODE_SET, BTLVAR_MSG_TEMP, 2
    // {0}’s {1} cuts {2}’s {3}!
    PrintMessage BattleStrings_Text_PokemonsAbilityCutsPokemonsStat_AllyAlly, TAG_NICKNAME_ABILITY_NICKNAME_STAT, BTLSCR_DEFENDER, BTLSCR_DEFENDER, BTLSCR_ATTACKER, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    End 

_paralyze:
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_DEFENDER
    Call BATTLE_SUBSCRIPT_PARALYZE

_end:
    End 
