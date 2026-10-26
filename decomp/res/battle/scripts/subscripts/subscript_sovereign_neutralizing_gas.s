#include "macros/btlcmd.inc"

// Sovereign (item 11): Neutralizing Gas comes in (BattleSystem_TriggerEffectOnSwitch).

_000:
    // Neutralizing gas filled the area!
    PrintMessage BattleStrings_Text_SovereignNeutralizingGas, TAG_NONE
    Wait
    WaitButtonABTime 30
    End
