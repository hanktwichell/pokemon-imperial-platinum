#include "macros/btlcmd.inc"

// Sovereign (item 11): a Mirror Herb copies the stat rises its holder's foes just got (Sovereign_SetupMirrorHerb: the
// holder is BTLVAR_MSG_BATTLER_TEMP, the item BTLVAR_MSG_ITEM_TEMP) and is used up.

_000:
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_HELD_ITEM
    Wait 

_next:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_MIRROR_HERB_NEXT, 0, _used_up
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_HELD_ITEM
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_MSG_BATTLER_TEMP
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    GoTo _next

_used_up:
    RemoveItem BTLSCR_MSG_TEMP
    End 
