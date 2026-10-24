#include "macros/btlcmd.inc"

// Sovereign (FM): Battle Bond made Greninja Ash-Greninja after its move knocked out a foe. The C side
// (AFTER_MOVE_HIT_STATE_KNOCKOUT_ABILITY) has already changed its form.

_000:
    // {0} became fully charged due to its bond with its Trainer!
    PrintMessage BattleStrings_Text_SovereignBattleBondCharged_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    PlaySound BTLSCR_MSG_TEMP, 1980
    SetMosaic BTLSCR_MSG_TEMP, 8, 1
    Wait 
    ChangeForm BTLSCR_MSG_TEMP
    PlaySound BTLSCR_MSG_TEMP, 1984
    SetMosaic BTLSCR_MSG_TEMP, 0, 1
    Wait 
    // {0} became Ash-Greninja!
    PrintMessage BattleStrings_Text_SovereignBattleBondAsh_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    End 
