#include "macros/btlcmd.inc"

// Sovereign (item 11): Wonder Room. Lasts 5 turns; using it again while it's up ends it.

_000:
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_WONDER_ROOM_TURNS, 0, _end
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_WONDER_ROOM_TURNS, 5
    BufferMessage BattleStrings_Text_SovereignWonderRoomStart, TAG_NONE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_PRINT_MESSAGE_AND_PLAY_ANIMATION
    End 

_end:
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_WONDER_ROOM_TURNS, 0
    BufferMessage BattleStrings_Text_SovereignWonderRoomEnd, TAG_NONE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_PRINT_MESSAGE_AND_PLAY_ANIMATION
    End 
