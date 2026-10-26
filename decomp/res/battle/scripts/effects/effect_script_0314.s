#include "macros/btlcmd.inc"

// Sovereign (item 11): Steel Beam, Mind Blown and Chloroblast. Damage, then the user loses half its max HP (on a miss
// too: subscript_missed). Damp stops Mind Blown, as it stops Explosion.

_000:
    CompareVarToValue OPCODE_NEQ, BTLVAR_CURRENT_MOVE, MOVE_MIND_BLOWN, _hit
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_ALL_BATTLERS, ABILITY_DAMP, _damp

_hit:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SIDE_EFFECT_TO_ATTACKER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_HALF_HP_COST
    CalcCrit 
    CalcDamage 
    End 

_damp:
    PrintAttackMessage 
    Wait 
    WaitButtonABTime 30
    // {0}’s {1} prevents {2} from using {3}!
    PrintMessage BattleStrings_Text_PokemonsAbilityPreventsPokemonFromUsingMove_AllyAlly, TAG_NICKNAME_ABILITY_NICKNAME_MOVE, BTLSCR_ABILITY_MON, BTLSCR_ABILITY_MON, BTLSCR_ATTACKER, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_CHECK_LOOP_ONLY_ONCE
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK
    End 
