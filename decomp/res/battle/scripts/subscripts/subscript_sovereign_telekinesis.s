#include "macros/btlcmd.inc"

// Sovereign (item 11): Telekinesis lifts the target for 3 turns: Ground moves miss it and other moves (but one-hit KO
// moves) always hit it. It fails under Gravity, on a rooted or grounded target, or one already lifted.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_FIELD_CONDITIONS, FIELD_CONDITION_GRAVITY, _fail
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_TELEKINESIS_SIDE_EFFECT_MON, 0, _fail
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_SMACKED_DOWN_SIDE_EFFECT_MON, 0, _fail
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_MOVE_EFFECTS_MASK, MOVE_EFFECT_INGRAIN, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_TELEKINESIS_SIDE_EFFECT_MON, 3
    // {0} was hurled into the air!
    PrintMessage BattleStrings_Text_SovereignHurledIntoTheAir_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
