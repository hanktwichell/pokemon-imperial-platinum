#include "macros/btlcmd.inc"

// Sovereign (FM): Disguise took a hit for Mimikyu. The C side (BattleControllerPlayer_UseMove) has already busted the
// disguise and set HP_CALC_TEMP to 1/8 of Mimikyu's max HP.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK, _009
    PlayMoveHitSound BTLSCR_MSG_TEMP
    FlickerMon BTLSCR_MSG_TEMP
    Wait 

_009:
    // Its disguise served it as a decoy!
    PrintMessage BattleStrings_Text_SovereignDisguiseDecoy, TAG_NONE
    Wait 
    WaitButtonABTime 30
    PlaySound BTLSCR_MSG_TEMP, 1980
    SetMosaic BTLSCR_MSG_TEMP, 8, 1
    Wait 
    ChangeForm BTLSCR_MSG_TEMP
    PlaySound BTLSCR_MSG_TEMP, 1984
    SetMosaic BTLSCR_MSG_TEMP, 0, 1
    Wait 
    // {0}'s disguise was busted!
    PrintMessage BattleStrings_Text_SovereignDisguiseBusted_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    End 
