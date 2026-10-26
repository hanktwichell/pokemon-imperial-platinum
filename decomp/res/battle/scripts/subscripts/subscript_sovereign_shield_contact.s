#include "macros/btlcmd.inc"

// Sovereign (item 11): the penalty a shield puts on the Pokemon whose contact move it blocked
// (BTLVAR_SOVEREIGN_SHIELD_CONTACT, subscript_missed):
// - King's Shield: Attack -1. Obstruct: Defense -2. Silk Trap: Speed -1.
// - Spiky Shield: 1/8 of the Pokemon's max HP.
// - Baneful Bunker: poison. Burning Bulwark: a burn.
// For the stat drops and status conditions, the shield's user is the attacker meanwhile: it causes them, as for Clear
// Body, Mirror Armor, Corrosion and Synchronize. They aren't a chance effect, but fail silently as one does; neither
// Shield Dust nor a Substitute keeps them off (BTLVAR_SOVEREIGN_SHIELD_CONTACT is set meanwhile).

_000:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0, _end
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_SPIKY_SHIELD, _spiky_shield
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SWAP_SHIELD_ROLES, 0, _end
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_DEFENDER
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_BANEFUL_BUNKER, _poison
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_BURNING_BULWARK, _burn
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_ATTACK_DOWN_1_STAGE
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_OBSTRUCT, _silk_trap
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_DEFENSE_DOWN_2_STAGES

_silk_trap:
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_SILK_TRAP, _stat
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SPEED_DOWN_1_STAGE

_stat:
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    GoTo _swap_back

_poison:
    Call BATTLE_SUBSCRIPT_POISON
    GoTo _swap_back

_burn:
    Call BATTLE_SUBSCRIPT_BURN

_swap_back:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SWAP_SHIELD_ROLES, 0, _end
    GoTo _end

_spiky_shield:
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_MAGIC_GUARD, _end
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 8
    UpdateVar OPCODE_MUL, BTLVAR_HP_CALC_TEMP, -1
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} was hurt!
    PrintMessage BattleStrings_Text_SovereignPokemonWasHurt_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30

_end:
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_NONE
    End 
