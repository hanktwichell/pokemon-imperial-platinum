#include "macros/btlcmd.inc"

// Sovereign (item 11): Ion Deluge. Normal moves are Electric for the rest of the turn (BTLVAR_SOVEREIGN_ION_DELUGE: it
// fails if Ion Deluge or Plasma Fists already started it).

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_ION_DELUGE, 0, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // A deluge of ions showers the battlefield!
    PrintMessage BattleStrings_Text_SovereignIonDeluge, TAG_NONE
    Wait
    WaitButtonABTime 30
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
