#include "macros/btlcmd.inc"


_000:
    ChangeStatStage _041, _059, _060
    CompareVarToValue OPCODE_NEQ, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_DIRECT, _010
    PrintAttackMessage 
    Wait 

_010:
    CompareVarToValue OPCODE_NEQ, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_DIRECT, _018
    PlayMoveAnimation BTLSCR_ATTACKER
    Wait 

_018:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_UPDATE_STAT_STAGES, _036
    PlayBattleAnimationFromVar BTLSCR_SIDE_EFFECT_MON, BTLVAR_SCRIPT_TEMP
    Wait 
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_STAT_STAGE_CHANGE_SHOWN, _036
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_UPDATE_STAT_STAGES

_036:
    PrintBufferedMessage 
    Wait 
    WaitButtonABTime 30
    GoTo _059

_041:
    CompareVarToValue OPCODE_NEQ, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_DIRECT, _048
    PrintAttackMessage 
    Wait 

_048:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_TURN_OFF_MESSAGES, _059
    WaitButtonABTime 30
    PrintBufferedMessage 
    Wait 
    WaitButtonABTime 30

_059:
    // Sovereign (item 11): after Mirror Armor sent a drop back to its source, the holder is the side-effect target
    // again (BtlCmd_ChangeStatStage).
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_MIRROR_ARMOR_HOLDER, 0, _sovereign_end
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_SOVEREIGN_MIRROR_ARMOR_HOLDER
    UpdateVar OPCODE_SUB, BTLVAR_SIDE_EFFECT_MON, 1
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_MIRROR_ARMOR_HOLDER, 0

_sovereign_end:
    End 

_060:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
