#include "macros/btlcmd.inc"

// Sovereign (item 11): Corrosive Gas takes away the target's held item (TryKnockOff, with its own message). Sticky Hold
// keeps the item. A Substitute blocks it.

_000:
    CheckSubstitute BTLSCR_DEFENDER, _fail
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_ABILITY, ABILITY_MULTITYPE, _fail
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_HELD_ITEM, ITEM_GRISEOUS_ORB, _fail
    TryKnockOff _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    PrintBufferedMessage 
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
