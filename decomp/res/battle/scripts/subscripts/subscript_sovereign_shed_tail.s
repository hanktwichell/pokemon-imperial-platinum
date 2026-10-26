#include "macros/btlcmd.inc"

// Sovereign (item 11): Shed Tail. The user pays half its max HP (rounded up) for a substitute, then switches out as with
// Baton Pass; the Pokemon that comes in gets the substitute and nothing else (BattleSystem_UpdateAfterSwitch). It fails
// with no Pokemon to switch to, when the user already has a substitute, or when it has half its HP or less.

_000:
    TryReplaceFaintedMon BTLSCR_ATTACKER, TRUE, _fail
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_ATTACKER, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_SUBSTITUTE, _fail
    PrintAttackMessage
    Wait
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SHED_TAIL, 0, _weak
    PlayBattleAnimation BTLSCR_ATTACKER, BATTLE_ANIMATION_SUBSTITUTE_IN
    Wait
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} shed its tail to create a decoy!
    PrintMessage BattleStrings_Text_SovereignShedTail_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait
    WaitButtonABTime 30
    TryRestoreStatusOnSwitch BTLSCR_ATTACKER, _switch
    UpdateMonData OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_STATUS, MON_CONDITION_NONE

_switch:
    DeletePokemon BTLSCR_ATTACKER
    Wait
    HealthBoxSlideOut BTLSCR_ATTACKER
    Wait
    UpdateVarFromVar OPCODE_SET, BTLVAR_SWITCHED_MON, BTLVAR_ATTACKER
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_BATON_PASS
    GoToSubscript BATTLE_SUBSCRIPT_SHOW_PARTY_LIST

_weak:
    WaitButtonABTime 30
    // It was too weak to make a substitute!
    PrintMessage BattleStrings_Text_ItWasTooWeakToMakeASubstitute, TAG_NONE
    Wait
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK
    End

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End
