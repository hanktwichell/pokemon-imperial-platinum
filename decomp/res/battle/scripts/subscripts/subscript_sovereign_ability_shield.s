#include "macros/btlcmd.inc"

// Sovereign (item 11): a move that would change or suppress the Ability of an Ability Shield holder
// (BTLVAR_MSG_BATTLER_TEMP, set by BTLVAR_SOVEREIGN_ABILITY_SHIELD_ATTACKER or _DEFENDER) does nothing: "X used Y!",
// then the shield's message.

_000:
    // {0}’s Ability Shield protects its Ability!
    BufferMessage BattleStrings_Text_SovereignAbilityShieldProtects_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    PrintAttackMessage 
    Wait 
    WaitButtonABTime 30
    PrintBufferedMessage 
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK
    End 
