#include "macros/btlcmd.inc"

// Sovereign (item 11): Quick Draw let the attacker move first (BattleSystem_CompareBattlerSpeed,
// BattleControllerPlayer_LoadQuickClawCheck). Runs instead of subscript_check_quick_claw, so it also clears a Quick
// Claw roll.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_WAITING_BATTLERS, 1, _end
    // {0}’s {1} let it move first!
    PrintMessage BattleStrings_Text_SovereignAbilityLetItMoveFirst_Ally, TAG_NICKNAME_ABILITY, BTLSCR_ATTACKER, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30

_end:
    UpdateMonData OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_QUICK_CLAW, 0
    End 
