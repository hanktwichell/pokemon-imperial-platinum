#include "macros/btlcmd.inc"

// Sovereign: Synchronize passes on bad poisoning as bad poisoning (Gen V+; BattleSystem_SynchronizeStatus). The poison
// subscript makes its checks and messages for an Ability's poisoning, and a poisoning it gives becomes a bad one. It is
// separate because subscript_badly_poison has no room left in the script buffer.

_000:
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_NONE, _end
    Call BATTLE_SUBSCRIPT_POISON
    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_POISON, _end
    UpdateMonData OPCODE_FLAG_OFF, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_POISON
    UpdateMonData OPCODE_FLAG_ON, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_STATUS, MON_CONDITION_TOXIC

_end:
    End
