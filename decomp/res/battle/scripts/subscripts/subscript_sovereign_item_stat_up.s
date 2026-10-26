#include "macros/btlcmd.inc"

// Sovereign (item 11): a held item that raises its holder's stats once and is used up (Weakness Policy, Absorb Bulb,
// Cell Battery, Luminous Moss, Snowball; BattleSystem_TriggerHeldItemOnHit; the Throat Spray and Blunder Policy after
// a move; the Adrenaline Orb after an Intimidate). The holder is BTLVAR_MSG_BATTLER_TEMP,
// the item BTLVAR_MSG_ITEM_TEMP; BTLVAR_SIDE_EFFECT_PARAM is the first stat change, BTLVAR_MSG_TEMP a second one or 0.

_000:
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_HELD_ITEM
    Wait 
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_HELD_ITEM
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_MON, BTLVAR_MSG_BATTLER_TEMP
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 0, _used_up
    UpdateVarFromVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, BTLVAR_MSG_TEMP
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE

_used_up:
    RemoveItem BTLSCR_MSG_TEMP
    End 
