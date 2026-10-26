#include "macros/btlcmd.inc"

// Sovereign (item 11): Population Bomb hits up to 10 times, checking accuracy on each hit like Triple Kick, at the same
// power each time. Skill Link and Loaded Dice change it in BtlCmd_SetMultiHit.

_000:
    SetMultiHit 10, SYSCTL_TRIPLE_KICK
    UpdateVar OPCODE_SET, BTLVAR_AFTER_MOVE_MESSAGE_TYPE, AFTER_MOVE_MESSAGE_MULTI_HIT
    CalcCrit 
    CalcDamage 
    End 
