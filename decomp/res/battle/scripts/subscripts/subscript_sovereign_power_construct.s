#include "macros/btlcmd.inc"

// Sovereign (FM): Power Construct made Zygarde Complete. The C side (BattleSystem_TriggerTurnEndAbility) has already
// changed its form and max HP, and set HP_CALC_TEMP to how much its max HP rose.

_000:
    // You sense the presence of many!
    PrintMessage BattleStrings_Text_SovereignPowerConstructPresence, TAG_NONE
    Wait 
    WaitButtonABTime 30
    PlaySound BTLSCR_MSG_TEMP, 1980
    SetMosaic BTLSCR_MSG_TEMP, 8, 1
    Wait 
    ChangeForm BTLSCR_MSG_TEMP
    PlaySound BTLSCR_MSG_TEMP, 1984
    SetMosaic BTLSCR_MSG_TEMP, 0, 1
    Wait 
    // Show the new max HP before the HP rises to it.
    SovereignRefreshHealthBox BTLSCR_MSG_TEMP
    Wait 
    // {0} transformed into its Complete Forme!
    PrintMessage BattleStrings_Text_SovereignPowerConstructComplete_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    End 
