#include "macros/btlcmd.inc"


_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SIDE_CONDITIONS_ATTACKER, SIDE_CONDITION_TAILWIND, _018
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // The tailwind blew from behind your team!
    PrintMessage BattleStrings_Text_TheTailwindBlewFromBehindYourTeam, TAG_NONE_SIDE_CONSCIOUS, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_SIDE_CONDITIONS_ATTACKER, SIDE_CONDITION_TAILWIND
    // Sovereign (item 11): the tailwind raises the Attack of each Wind Rider on its side 1 stage, and charges each Wind
    // Power.
    UpdateVar OPCODE_SET, BTLVAR_BATTLER_SPEED_TEMP, 0

_sovereign_wind:
    GetMonBySpeedOrder BTLVAR_MSG_BATTLER_TEMP
    IfSameSide BTLSCR_ATTACKER, BTLSCR_MSG_BATTLER_TEMP, _sovereign_same_side
    GoTo _sovereign_next

_sovereign_same_side:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_MSG_BATTLER_TEMP, BATTLEMON_CUR_HP, 0, _sovereign_next
    CheckAbility CHECK_HAVE, BTLSCR_MSG_BATTLER_TEMP, ABILITY_WIND_POWER, _sovereign_wind_power
    CheckAbility CHECK_NOT_HAVE, BTLSCR_MSG_BATTLER_TEMP, ABILITY_WIND_RIDER, _sovereign_next
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_MSG_BATTLER_TEMP
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    GoTo _sovereign_next

_sovereign_wind_power:
    Call BATTLE_SUBSCRIPT_SOVEREIGN_CHARGED_BY_HIT

_sovereign_next:
    UpdateVar OPCODE_ADD, BTLVAR_BATTLER_SPEED_TEMP, 1
    GoToIfValidMon BTLVAR_BATTLER_SPEED_TEMP, _sovereign_wind
    End 

_018:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
