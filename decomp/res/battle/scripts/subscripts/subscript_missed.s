#include "macros/btlcmd.inc"


_000:
    PrintAttackMessage 
    Wait 
    WaitButtonABTime 30
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_LOST_FOCUS, _011
    PrintBufferedMessage 
    GoTo _179

_011:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_SEMI_INVULNERABLE, _018
    GoTo _157

_018:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_PROTECTED, _069
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_SNORE, _058
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_NIGHTMARE, _058
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_FLING, _058
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_LAST_RESORT, _058
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_PSYCHO_SHIFT, _058
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_FAKE_OUT, _058
    CompareVarToValue OPCODE_NEQ, BTLVAR_CURRENT_MOVE, MOVE_NATURAL_GIFT, _063

_058:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED, _097

_063:
    // Sovereign (item 11): a side guard names itself.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_GUARD_BLOCK, MOVE_NONE, _sovereign_protected
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_GUARD_BLOCK, MOVE_MAT_BLOCK, _sovereign_mat_block
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_MOVE_TEMP, BTLVAR_SOVEREIGN_GUARD_BLOCK
    // {1} protected {0}!
    PrintMessage BattleStrings_Text_SovereignGuardProtectedPokemon_Ally, TAG_NICKNAME_MOVE, BTLSCR_DEFENDER, BTLSCR_MSG_TEMP
    GoTo _179

_sovereign_mat_block:
    // {0} was blocked by the kicked-up mat!
    PrintMessage BattleStrings_Text_SovereignBlockedByMat, TAG_MOVE, BTLSCR_ATTACKER
    GoTo _179

_sovereign_protected:
    // {0} protected itself!
    PrintMessage BattleStrings_Text_PokemonProtectedItself_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    GoTo _179

_069:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_LEVITATED, _081
    // {0} makes Ground moves miss by using {1}!
    PrintMessage BattleStrings_Text_PokemonMakesGroundMovesMissByUsingAbility_Ally, TAG_NICKNAME_ABILITY, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    GoTo _179

_081:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MAGNET_RISE, _097
    UpdateVar OPCODE_SET, BTLVAR_MSG_MOVE_TEMP, MOVE_MAGNET_RISE
    // {0} evades Ground moves with {1}!
    PrintMessage BattleStrings_Text_PokemonEvadesGroundMovesWithAbility_Ally, TAG_NICKNAME_MOVE, BTLSCR_DEFENDER, BTLSCR_MSG_TEMP
    GoTo _179

_097:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED, _107
    // But it failed!
    PrintMessage BattleStrings_Text_ButItFailed, TAG_NONE
    GoTo _179

_107:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_WONDER_GUARD, _119
    // {0} avoided damage by using {1}!
    PrintMessage BattleStrings_Text_PokemonAvoidedDamageByUsingAbility_Ally, TAG_NICKNAME_ABILITY, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    GoTo _179

_119:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_INEFFECTIVE, _134
    // Sovereign (item 11): Aroma Veil names itself.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_AROMA_VEIL_DEFENDER, TRUE, _sovereign_aroma_veil
    IncrementGameRecord BTLSCR_ATTACKER, BATTLER_TYPE_SOLO_PLAYER, RECORD_USED_INEFFECTIVE_MOVE
    // It doesn’t affect {0}...
    PrintMessage BattleStrings_Text_ItDoesntAffectPokemon_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    GoTo _179

_sovereign_aroma_veil:
    // {0} is protected by an aromatic veil!
    PrintMessage BattleStrings_Text_SovereignAromaticVeil_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    GoTo _179

_134:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_STURDY, _146
    // {0} was protected by {1}!
    PrintMessage BattleStrings_Text_PokemonWasProtectedByAbility_Ally, TAG_NICKNAME_ABILITY, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    GoTo _179

_146:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_ONE_HIT_KO_FAILED, _157
    // {0} is unaffected!
    PrintMessage BattleStrings_Text_PokemonIsUnaffected_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    GoTo _179

_157:
    GetCurrentMoveData MOVEATTRIBUTE_RANGE
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000004, _175
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000008, _175
    // {0}’s attack missed!
    PrintMessage BattleStrings_Text_PokemonsAttackMissed_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    GoTo _179

_175:
    // {0} avoided the attack!
    PrintMessage BattleStrings_Text_PokemonAvoidedTheAttack_Ally, TAG_NICKNAME, BTLSCR_DEFENDER

_179:
    Wait 
    WaitButtonABTime 30
    // Sovereign (item 11): King's Shield, Spiky Shield and the like punish the contact move they blocked.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_NONE, _sovereign_no_shield
    Call BATTLE_SUBSCRIPT_SOVEREIGN_SHIELD_CONTACT

_sovereign_no_shield:
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_MESSAGE_AFTER_MISS, _189
    Call BATTLE_SUBSCRIPT_SHOW_PREPARED_MESSAGE

_189:
    UnlockMoveChoice BTLSCR_ATTACKER
    Call BATTLE_SUBSCRIPT_CRASH_ON_MISS
    // Sovereign (item 11): Steel Beam, Mind Blown and Chloroblast cost half the user's HP even when they miss.
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_STEEL_BEAM, _sovereign_half_hp
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_MIND_BLOWN, _sovereign_half_hp
    CompareVarToValue OPCODE_NEQ, BTLVAR_CURRENT_MOVE, MOVE_CHLOROBLAST, _sovereign_end

_sovereign_half_hp:
    Call BATTLE_SUBSCRIPT_SOVEREIGN_HALF_HP_COST

_sovereign_end:
    End 
