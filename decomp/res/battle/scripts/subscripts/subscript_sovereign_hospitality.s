#include "macros/btlcmd.inc"

// Sovereign (item 11): Hospitality. As the holder (BTLVAR_MSG_ATTACKER) enters, its partner (BTLVAR_MSG_BATTLER_TEMP)
// restores a quarter of its max HP (BTLVAR_HP_CALC_TEMP).

_000:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} drank down all the matcha that {1} made!
    PrintMessage BattleStrings_Text_SovereignDrankMatcha_AllyAlly, TAG_NICKNAME_NICKNAME, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_MSG_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 
