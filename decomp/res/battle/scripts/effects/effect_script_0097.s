#include "macros/btlcmd.inc"


_000:
    // Sovereign (item 11): a Comatose user is as if asleep, without the "fast asleep" message.
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_COMATOSE, _sovereign_talk
    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_ATTACKER, BATTLEMON_STATUS, MON_CONDITION_SLEEP, _013
    Call BATTLE_SUBSCRIPT_SLEEPING

_sovereign_talk:
    TrySleepTalk _013
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    GoToMoveScript FALSE

_013:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
