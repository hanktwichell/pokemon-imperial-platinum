#include "macros/btlcmd.inc"

// Sovereign (item 11): the last Neutralizing Gas in battle is gone (BattleSystem_TriggerEffectOnSwitch).

_000:
    // The effects of the neutralizing gas wore off!
    PrintMessage BattleStrings_Text_SovereignNeutralizingGasEnd, TAG_NONE
    Wait
    WaitButtonABTime 30
    End
