#include "macros/btlcmd.inc"

// Sovereign: Mud Sport is a field effect for 5 turns (Gen VI+), not the user's while it stays in, and fails while it
// lasts. BattleControllerPlayer_CheckFieldConditions counts it down.

_000:
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_MUD_SPORT_TURNS, 0, _018
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_MUD_SPORT_TURNS, 5
    // Electricity’s power was weakened!
    BufferMessage BattleStrings_Text_ElectricitysPowerWasWeakened, TAG_NONE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_PRINT_MESSAGE_AND_PLAY_ANIMATION
    End 

_018:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
