#include "macros/btlcmd.inc"

// Sovereign (item 11): Fairy Lock. No one can escape (flee or switch out) this turn and the next; a Ghost type, Shed
// Shell, a Smoke Ball and Run Away still get away (Battler_IsTrapped, Battler_IsTrappedMsg). It fails while it's on.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_FAIRY_LOCK, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // No one will be able to run away during the next turn!
    PrintMessage BattleStrings_Text_SovereignFairyLock, TAG_NONE
    Wait
    WaitButtonABTime 30
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
