#include "macros/btlcmd.inc"

// Sovereign (item 11): Electromorphosis and Wind Power. A hit (or a tailwind, for Wind Power) charges the holder,
// BTLVAR_MSG_BATTLER_TEMP: its next Electric move before the end of next turn has double power, as after Charge
// (BattleSystem_TriggerAbilityOnHit, subscript_tailwind_start).

_000:
    UpdateMonData OPCODE_FLAG_ON, BTLSCR_MSG_BATTLER_TEMP, BATTLEMON_MOVE_EFFECTS_MASK, MOVE_EFFECT_CHARGE
    UpdateMonData OPCODE_SET, BTLSCR_MSG_BATTLER_TEMP, BATTLEMON_CHARGED_TURNS, 2
    // {0}’s {1} charged it with power!
    PrintMessage BattleStrings_Text_SovereignAbilityChargedIt_Ally, TAG_NICKNAME_ABILITY, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_MSG_BATTLER_TEMP
    Wait 
    WaitButtonABTime 30
    End 
