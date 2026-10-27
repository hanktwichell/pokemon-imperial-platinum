#include "macros/btlcmd.inc"


_000:
    // Sovereign: in a trainer battle, or used by the player's Pokémon, it switches the user out (Gen VIII+). Platinum's
    // failed in a trainer battle and let the player flee a wild one.
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_TRAINER, _sovereign_switch
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_ATTACKER, 1, _sovereign_switch
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_TELEPORT
    End 

_sovereign_switch:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_DIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_SOVEREIGN_TELEPORT_SWITCH
    End 
