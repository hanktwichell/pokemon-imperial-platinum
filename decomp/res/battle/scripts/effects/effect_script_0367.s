#include "macros/btlcmd.inc"

// Sovereign (item 11): First Impression. Damage, but it fails unless this is the user's first turn in battle since it
// came in (as Fake Out, without the flinch).

_000:
    CompareMonDataToVar OPCODE_NEQ, BTLSCR_ATTACKER, BATTLEMON_FAKE_OUT_TURN_NUMBER, BTLVAR_TOTAL_TURNS, _fail
    CalcCrit 
    CalcDamage 
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
