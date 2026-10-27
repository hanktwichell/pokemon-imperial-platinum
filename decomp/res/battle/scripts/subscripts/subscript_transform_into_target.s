#include "macros/btlcmd.inc"


_000:
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_DEFENDER, BATTLEMON_MOVE_EFFECTS_MASK, MOVE_EFFECT_SEMI_INVULNERABLE, _023
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_DEFENDER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_TRANSFORM, _023
    // Sovereign: it also fails against a substitute, from a Pokemon already transformed, and while either Pokemon's
    // Illusion is up (Gen V+).
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_DEFENDER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_SUBSTITUTE, _023
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_ATTACKER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_TRANSFORM, _023
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_ILLUSION_ACTIVE, 0, _023
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    Transform 
    // {0} transformed into {1}!
    PrintMessage BattleStrings_Text_PokemonTransformedIntoPokemon_AllyAlly, TAG_NICKNAME_POKE, BTLSCR_ATTACKER, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    End 

_023:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
