#include "macros/btlcmd.inc"

// Sovereign (item 11): Clear Smog. After the hit, the target's stat stages are reset.

_000:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_CUR_HP, 0, _end
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_ATTACK_STAGE, 6
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_DEFENSE_STAGE, 6
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_SPEED_STAGE, 6
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_SP_ATTACK_STAGE, 6
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_SP_DEFENSE_STAGE, 6
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_ACCURACY_STAGE, 6
    UpdateMonData OPCODE_SET, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_EVASION_STAGE, 6
    // {0}’s stat changes were removed!
    PrintMessage BattleStrings_Text_SovereignStatChangesRemoved_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait 
    WaitButtonABTime 30

_end:
    End 
