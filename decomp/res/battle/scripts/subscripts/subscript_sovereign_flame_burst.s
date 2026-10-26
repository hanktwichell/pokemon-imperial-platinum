#include "macros/btlcmd.inc"

// Sovereign (item 11): Flame Burst. After the hit, the bursting flame hits the target's ally for 1/16 of its max HP
// (BTLVAR_SOVEREIGN_FLAME_BURST; not through Magic Guard), even when the target faints.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_FLAME_BURST, 0, _end
    // The bursting flame hit {0}!
    PrintMessage BattleStrings_Text_SovereignBurstingFlame_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait
    WaitButtonABTime 30
    Call BATTLE_SUBSCRIPT_UPDATE_HP

_end:
    End
