#include "macros/btlcmd.inc"

// Sovereign (item 11): Doodle. The user and its ally take the target's Ability, by Role Play's rules. Reading
// BTLVAR_SOVEREIGN_DOODLE gives it to them and says who took it: 1 the user, 2 its ally, 4 an Ability Shield kept one's
// own (BTLVAR_MSG_BATTLER_TEMP); 0 when it fails.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    UpdateVarFromVar OPCODE_SET, BTLVAR_SCRIPT_TEMP, BTLVAR_SOVEREIGN_DOODLE
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 0, _fail
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 4, _shield_only
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_SCRIPT_TEMP, 1, _ally
    // {0} copied {1}’s {2}!
    PrintMessage BattleStrings_Text_PokemonCopiedPokemonsAbility_AllyAlly, TAG_NICKNAME_NICKNAME_ABILITY, BTLSCR_ATTACKER, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    Wait
    WaitButtonABTime 30

_ally:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_SCRIPT_TEMP, 2, _shield
    // {0} copied {1}’s {2}!
    PrintMessage BattleStrings_Text_PokemonCopiedPokemonsAbility_AllyAlly, TAG_NICKNAME_NICKNAME_ABILITY, BTLSCR_ATTACKER_PARTNER, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    Wait
    WaitButtonABTime 30

_shield:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_SCRIPT_TEMP, 4, _end
    // {0}’s Ability Shield protects its Ability!
    PrintMessage BattleStrings_Text_SovereignAbilityShieldProtects_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30

_end:
    End

_shield_only:
    Call BATTLE_SUBSCRIPT_SOVEREIGN_ABILITY_SHIELD
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
