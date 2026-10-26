#include "macros/btlcmd.inc"


_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_ATTACKER_SELF_TURN_STATUS_FLAGS, SELF_TURN_FLAG_PLUCK_BERRY, _sovereign_taken
    // Sovereign (item 11): Cheek Pouch restores HP once the Berry is eaten.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_CHEEK_POUCH_MSG_TEMP, FALSE, _sovereign_remove
    RemoveItem BTLSCR_MSG_TEMP
    Call BATTLE_SUBSCRIPT_SOVEREIGN_CHEEK_POUCH
    GoTo _006

_sovereign_remove:
    RemoveItem BTLSCR_MSG_TEMP
    GoTo _006

_sovereign_taken:
    // Sovereign (item 11): Bug Bite, Pluck, Fling or Stuff Cheeks took the Berry already. The eater (Fling's target
    // too) has eaten a Berry for Belch, and Cheek Pouch works.
    SovereignMarkAteBerry BTLSCR_MSG_TEMP
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_CHEEK_POUCH_MSG_TEMP, FALSE, _006
    Call BATTLE_SUBSCRIPT_SOVEREIGN_CHEEK_POUCH

_006:
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_ATTACKER_SELF_TURN_STATUS_FLAGS, SELF_TURN_FLAG_PLUCK_BERRY
    End 
