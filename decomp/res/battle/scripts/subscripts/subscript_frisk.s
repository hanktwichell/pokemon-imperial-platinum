#include "macros/btlcmd.inc"

// Sovereign: Frisk (BTLSCR_MSG_BATTLER_TEMP) finds every foe's held item, one message each, in Speed order (Gen VI+).

_000:
    WaitButtonABTime 15
    UpdateVar OPCODE_SET, BTLVAR_BATTLER_SPEED_TEMP, 0

_loop:
    GetMonBySpeedOrder BTLVAR_SIDE_EFFECT_MON
    IfSameSide BTLSCR_MSG_BATTLER_TEMP, BTLSCR_SIDE_EFFECT_MON, _next
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _next
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_HELD_ITEM, ITEM_NONE, _next
    // {0} frisked {1} and found its {2}!
    PrintMessage BattleStrings_Text_SovereignFriskedItem_AllyAlly, TAG_NICKNAME_NICKNAME_ITEM, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_SIDE_EFFECT_MON, BTLSCR_SIDE_EFFECT_MON
    Wait
    WaitButtonABTime 30

_next:
    UpdateVar OPCODE_ADD, BTLVAR_BATTLER_SPEED_TEMP, 1
    GoToIfValidMon BTLVAR_BATTLER_SPEED_TEMP, _loop
    End
