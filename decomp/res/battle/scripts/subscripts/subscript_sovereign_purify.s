#include "macros/btlcmd.inc"

// Sovereign (item 11): Purify heals the target's status condition, then the user regains 1/2 of its max HP (fails
// against a target without one).

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_MISSED|MOVE_STATUS_SEMI_INVULNERABLE, _fail
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_STATUS, MON_CONDITION_NONE, _fail
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    UpdateMonData OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_STATUS, MON_CONDITION_NONE
    // {0}’s status returned to normal!
    PrintMessage BattleStrings_Text_PokemonsStatusReturnedToNormal_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait 
    SetHealthBoxStatusIcon BTLSCR_DEFENDER, BATTLE_ANIMATION_NONE
    WaitButtonABTime 30
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 2
    // the user regains the HP in BTLVAR_HP_CALC_TEMP, unless it's full
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_MAX_HP, BTLVAR_CALC_TEMP
    CompareMonDataToVar OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, BTLVAR_CALC_TEMP, _end
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    PlayBattleAnimation BTLSCR_ATTACKER, BATTLE_ANIMATION_RESTORE_HP
    Wait 
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} regained health!
    PrintMessage BattleStrings_Text_PokemonRegainedHealth_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30

_end:
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
