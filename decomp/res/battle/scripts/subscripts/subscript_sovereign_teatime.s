#include "macros/btlcmd.inc"

// Sovereign (item 11): Teatime. Every Pokemon on the field holding a Berry eats it, in turn: each becomes the attacker
// while it eats (BTLVAR_SOVEREIGN_TEATIME_NEXT), as Stuff Cheeks eats its own Berry, and the user is the attacker again
// at the end. Unnerve doesn't stop it. It fails when no one holds a Berry.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_TEATIME_START, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // It’s teatime! Everyone dug in to their Berries!
    PrintMessage BattleStrings_Text_SovereignTeatime, TAG_NONE
    Wait
    WaitButtonABTime 30

_next:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_TEATIME_NEXT, 0, _end
    SovereignEatOwnBerry _next
    // {0} ate its {1}!
    PrintMessage BattleStrings_Text_SovereignPokemonAteItsItem_Ally, TAG_NICKNAME_ITEM, BTLSCR_ATTACKER, BTLSCR_ATTACKER
    Wait
    WaitButtonABTime 30
    RemoveItem BTLSCR_ATTACKER
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 0, _no_effect
    // The Berry's subscript ends with subscript_pluck_check (Cheek Pouch).
    CallFromVar BTLVAR_SCRIPT_TEMP
    GoTo _next

_no_effect:
    Call BATTLE_SUBSCRIPT_PLUCK_CHECK
    GoTo _next

_end:
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
