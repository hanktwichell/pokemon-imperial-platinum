#include "macros/btlcmd.inc"

// Sovereign (item 11): Plasma Fists. After the hit, Normal moves are Electric for the rest of the turn (no message if
// the deluge of ions is already on).

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_ION_DELUGE, 0, _end
    // A deluge of ions showers the battlefield!
    PrintMessage BattleStrings_Text_SovereignIonDeluge, TAG_NONE
    Wait
    WaitButtonABTime 30

_end:
    End
