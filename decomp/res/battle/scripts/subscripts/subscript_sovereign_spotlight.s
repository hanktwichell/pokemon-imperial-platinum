#include "macros/btlcmd.inc"

// Sovereign (item 11): Spotlight. The target's foes aim their moves at it this turn, as if it had used Follow Me
// (BTLVAR_SOVEREIGN_SPOTLIGHT: it fails in a single battle).

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SPOTLIGHT, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // {0} became the center of attention!
    PrintMessage BattleStrings_Text_PokemonBecameTheCenterOfAttention_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait
    WaitButtonABTime 30
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
