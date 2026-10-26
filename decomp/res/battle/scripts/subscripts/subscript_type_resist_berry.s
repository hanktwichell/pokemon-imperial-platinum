#include "macros/btlcmd.inc"


_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_IGNORE_TYPE_CHECKS|SYSCTL_IGNORE_IMMUNITIES, _262
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_ONE_HIT_KO, _262
    CheckAbility CHECK_NOT_HAVE, BTLSCR_ATTACKER, ABILITY_NORMALIZE, _020
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, 0x00000000
    GoTo _033

_020:
    CompareVarToValue OPCODE_EQU, BTLVAR_MOVE_TYPE, TYPE_NORMAL, _031
    UpdateVarFromVar OPCODE_GET, BTLVAR_MOVE_TYPE, BTLVAR_CALC_TEMP
    GoTo _033

_031:
    GetCurrentMoveData MOVEATTRIBUTE_TYPE

_033:
    GetItemHoldEffect BTLSCR_MSG_TEMP, BTLVAR_SCRIPT_TEMP
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 35, _128
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_SUPER_EFFECTIVE, _262
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 19, _135
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 20, _142
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 21, _149
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 22, _156
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 23, _163
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 24, _170
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 25, _177
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 26, _184
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 27, _191
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 28, _198
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 29, _205
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 30, _212
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 31, _219
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 32, _226
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 33, _233
    CompareVarToValue OPCODE_EQU, BTLVAR_SCRIPT_TEMP, 34, _240
    GoTo _262

_128:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000000, _245
    GoTo _262

_135:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x0000000A, _245
    GoTo _262

_142:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x0000000B, _245
    GoTo _262

_149:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x0000000D, _245
    GoTo _262

_156:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x0000000C, _245
    GoTo _262

_163:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x0000000F, _245
    GoTo _262

_170:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000001, _245
    GoTo _262

_177:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000003, _245
    GoTo _262

_184:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000004, _245
    GoTo _262

_191:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000002, _245
    GoTo _262

_198:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x0000000E, _245
    GoTo _262

_205:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000006, _245
    GoTo _262

_212:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000005, _245
    GoTo _262

_219:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000007, _245
    GoTo _262

_226:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000010, _245
    GoTo _262

_233:
    CompareVarToValue OPCODE_EQU, BTLVAR_CALC_TEMP, 0x00000011, _245
    GoTo _262

_240:
    CompareVarToValue OPCODE_NEQ, BTLVAR_CALC_TEMP, 0x00000008, _262

_245:
    // Sovereign (item 11): a foe's Unnerve (or As One) keeps the holder from eating it.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_UNNERVED_MSG_TEMP, TRUE, _262
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_HELD_ITEM
    Wait 
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 2
    // Sovereign (item 11): Ripen doubles the Berry's effect: a quarter of the damage.
    CheckAbility CHECK_NOT_HAVE, BTLSCR_MSG_TEMP, ABILITY_RIPEN, _sovereign_not_ripen
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 2

_sovereign_not_ripen:
    // The {0} weakened {1}’s power!
    PrintMessage BattleStrings_Text_TheItemWeakenedMovesPower, TAG_ITEM_MOVE, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    // Sovereign (item 11): Cheek Pouch restores a third of its max HP once the Berry is eaten, before the hit's damage
    // (as in Showdown). Its heal uses BTLVAR_HP_CALC_TEMP, so the damage waits in BTLVAR_CALC_TEMP.
    UpdateVarFromVar OPCODE_SET, BTLVAR_CALC_TEMP, BTLVAR_HP_CALC_TEMP
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_CHEEK_POUCH_MSG_TEMP, FALSE, _sovereign_no_pouch
    RemoveItem BTLSCR_MSG_TEMP
    Call BATTLE_SUBSCRIPT_SOVEREIGN_CHEEK_POUCH
    UpdateVarFromVar OPCODE_SET, BTLVAR_HP_CALC_TEMP, BTLVAR_CALC_TEMP
    End 

_sovereign_no_pouch:
    UpdateVarFromVar OPCODE_SET, BTLVAR_HP_CALC_TEMP, BTLVAR_CALC_TEMP
    RemoveItem BTLSCR_MSG_TEMP

_262:
    End 
