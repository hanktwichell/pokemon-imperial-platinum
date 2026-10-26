#include "macros/btlcmd.inc"

// Sovereign (item 11): a Pokemon covered in powder uses a Fire move (BattleControllerPlayer_BeforeMove). The move fails
// after its attack message, and the user loses 1/4 of its max HP (rounded, at least 1). Magic Guard prevents the damage.

_000:
    PrintAttackMessage
    Wait
    WaitButtonABTime 15
    // When the flame touched the powder on the Pokémon, it exploded!
    PrintMessage BattleStrings_Text_SovereignPowderExploded, TAG_NONE
    Wait
    WaitButtonABTime 30
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_MAGIC_GUARD, _end
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    UpdateVar OPCODE_ADD, BTLVAR_HP_CALC_TEMP, 2
    UpdateVar OPCODE_DIV, BTLVAR_HP_CALC_TEMP, 4
    CompareVarToValue OPCODE_NEQ, BTLVAR_HP_CALC_TEMP, 0, _damage
    UpdateVar OPCODE_SET, BTLVAR_HP_CALC_TEMP, 1

_damage:
    UpdateVar OPCODE_MUL, BTLVAR_HP_CALC_TEMP, -1
    Call BATTLE_SUBSCRIPT_UPDATE_HP

_end:
    End
