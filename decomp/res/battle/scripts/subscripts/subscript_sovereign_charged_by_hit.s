#include "macros/btlcmd.inc"

// Sovereign (item 11): Electromorphosis and Wind Power. The hit charges the holder (the defender): its next Electric
// move before the end of next turn has double power, as after Charge (BattleSystem_TriggerAbilityOnHit).

_000:
    UpdateMonData OPCODE_FLAG_ON, BTLSCR_DEFENDER, BATTLEMON_MOVE_EFFECTS_MASK, MOVE_EFFECT_CHARGE
    UpdateMonData OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_CHARGED_TURNS, 2
    // {0}’s {1} charged it with power!
    PrintMessage BattleStrings_Text_SovereignAbilityChargedIt_Ally, TAG_NICKNAME_ABILITY, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    End 
