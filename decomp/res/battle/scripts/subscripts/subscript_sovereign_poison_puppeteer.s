#include "macros/btlcmd.inc"

// Sovereign (item 11): Poison Puppeteer (Pecharunt). A Pokémon its move poisons or badly poisons becomes confused too,
// as subscript_confuse does it (subscript_poison, subscript_badly_poison). Not when an ability or an item poisoned it.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_DIRECT, _move
    CompareVarToValue OPCODE_NEQ, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_INDIRECT, _end

_move:
    CheckAbility CHECK_NOT_HAVE, BTLSCR_ATTACKER, ABILITY_POISON_PUPPETEER, _end
    CompareVarToVar OPCODE_EQU, BTLVAR_ATTACKER, BTLVAR_SIDE_EFFECT_MON, _end
    CheckAbility CHECK_HAVE, BTLSCR_SIDE_EFFECT_MON, ABILITY_OWN_TEMPO, _end
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_CONFUSION, _end
    PlayBattleAnimation BTLSCR_SIDE_EFFECT_MON, BATTLE_ANIMATION_CONFUSED
    Wait 
    Random 3, 2
    UpdateMonDataFromVar OPCODE_FLAG_ON, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_VOLATILE_STATUS, BTLVAR_CALC_TEMP
    // {0} became confused!
    PrintMessage BattleStrings_Text_PokemonBecameConfused_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30

_end:
    End 
