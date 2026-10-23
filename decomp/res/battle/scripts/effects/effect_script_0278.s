#include "macros/btlcmd.inc"

// Sovereign (item 11): Body Press. A plain hit; BattleSystem_CalcMoveDamage uses the user's Defense and Defense stage
// in place of its Attack.

_000:
    CalcCrit 
    CalcDamage 
    End 
