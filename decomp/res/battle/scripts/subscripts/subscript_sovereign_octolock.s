#include "macros/btlcmd.inc"

// Sovereign (item 11): Octolock. The target can't escape while the user stays in (as Mean Look), and its Defense and
// Sp. Def fall at the end of each turn (subscript_sovereign_octolock_drop). It fails against a target already held, a
// Ghost type, or a Substitute.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CheckSubstitute BTLSCR_DEFENDER, _fail
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_OCTOLOCK, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_DEFENDER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_MEAN_LOOK, _message
    UpdateMonData OPCODE_FLAG_ON, BTLSCR_DEFENDER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_MEAN_LOOK
    UpdateMonDataFromVar OPCODE_FLAG_ON, BTLSCR_DEFENDER, BATTLEMON_MEAN_LOOK_TARGET, BTLVAR_ATTACKER

_message:
    // {0} can no longer escape!
    PrintMessage BattleStrings_Text_PokemonCanNoLongerEscape_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait
    WaitButtonABTime 30
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
