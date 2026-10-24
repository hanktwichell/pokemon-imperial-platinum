#include "macros/btlcmd.inc"

// Sovereign (FM): a Palafin that became Hero as it switched out (BtlCmd_TryRestoreStatusOnSwitch) comes back in.

_000:
    // {0} underwent a heroic transformation!
    PrintMessage BattleStrings_Text_SovereignZeroToHero_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    End 
