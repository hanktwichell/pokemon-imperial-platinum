#include "macros/btlcmd.inc"

// Sovereign (item 11): Syrup Bomb's Speed drop at the end of the turn (BattleControllerPlayer_CheckMonConditions sets
// the battler and the stat change).

_000:
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    End 
