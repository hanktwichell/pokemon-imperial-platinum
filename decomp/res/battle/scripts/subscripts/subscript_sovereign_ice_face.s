#include "macros/btlcmd.inc"

// Sovereign (FM): Ice Face took a physical hit for Eiscue. The C side (BattleControllerPlayer_UseMove) has already
// changed it to Noice Face.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK, _009
    PlayMoveHitSound BTLSCR_MSG_TEMP
    FlickerMon BTLSCR_MSG_TEMP
    Wait 

_009:
    // {0}'s Ice Face took the hit!
    PrintMessage BattleStrings_Text_SovereignIceFace_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_FORM_CHANGE
    End 
