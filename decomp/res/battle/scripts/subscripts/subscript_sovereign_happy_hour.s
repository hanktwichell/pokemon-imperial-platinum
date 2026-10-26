#include "macros/btlcmd.inc"

// Sovereign (item 11): Happy Hour doubles the prize money when the player's side uses it (BTLVAR_SOVEREIGN_HAPPY_HOUR).

_000:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_HAPPY_HOUR, 0, _end
    // Everyone is caught up in the happy atmosphere!
    PrintMessage BattleStrings_Text_SovereignHappyAtmosphere, TAG_NONE
    Wait 
    WaitButtonABTime 30

_end:
    End 
