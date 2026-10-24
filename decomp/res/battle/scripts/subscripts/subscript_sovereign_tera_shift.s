#include "macros/btlcmd.inc"

// Sovereign (FM): Tera Shift made Terapagos Terastal as it entered battle. The C side (BattleSystem_TriggerFormChange)
// has already changed its form and max HP, and set HP_CALC_TEMP to how much its max HP rose: its HP rises by as much,
// as in Scarlet and Violet, so a Terapagos at full HP stays at full HP.

_000:
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
    // {0} transformed!
    PrintMessage BattleStrings_Text_PokemonTransformed_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    CompareVarToValue OPCODE_EQU, BTLVAR_HP_CALC_TEMP, 0, _end
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP

_end:
    End 
