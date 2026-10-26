#include "macros/btlcmd.inc"

// Sovereign (item 11): Trick-or-Treat (Ghost) and Forest's Curse (Grass) add a third type to the target, in place of one
// added before (BTLVAR_SOVEREIGN_ADD_TYPE). It fails on a target that has the type already.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_ADD_TYPE, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, TYPE_GRASS, _grass
    // Ghost type was added to {0}!
    PrintMessage BattleStrings_Text_SovereignGhostTypeAdded_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    GoTo _done

_grass:
    // Grass type was added to {0}!
    PrintMessage BattleStrings_Text_SovereignGrassTypeAdded_Ally, TAG_NICKNAME, BTLSCR_DEFENDER

_done:
    Wait
    WaitButtonABTime 30
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
