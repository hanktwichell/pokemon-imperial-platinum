#include "macros/btlcmd.inc"

// Sovereign (item 11): Mortal Spin poisons the target (not through a Substitute), then clears the user's side like
// Rapid Spin (binding, Leech Seed, hazards) without its Speed boost.

_000:
    CheckSubstitute BTLSCR_DEFENDER, _spin
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_CUR_HP, 0, _spin
    Call BATTLE_SUBSCRIPT_POISON

_spin:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0, _end
    RapidSpin 

_end:
    End 
