#include "macros/scrcmd.inc"
#include "res/field/events/events_mt_coronet_iceberg_ruins.h"


    ScriptEntry MtCoronetIcebergRuins_OnTransition
    ScriptEntry MtCoronetIcebergRuins_OnLoad
    ScriptEntry MtCoronetIcebergRuins_LegendaryKyurem
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Kyurem sleeps in this ice chamber once Reshiram and Zekrom
@ are both caught, until it's caught too. Vanilla gave the room no scripts (scripts_empty). With a fateful-encounter
@ Regigigas in the party, Mt. Coronet's doorway leads to the Regice chamber (ICEBERG_RUINS) instead.
MtCoronetIcebergRuins_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_RESHIRAM, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, MtCoronetIcebergRuins_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_ZEKROM, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, MtCoronetIcebergRuins_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_KYUREM, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, MtCoronetIcebergRuins_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
MtCoronetIcebergRuins_OnTransitionEnd:
    End

MtCoronetIcebergRuins_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, MtCoronetIcebergRuins_RemoveLegendaryKyurem
    End

MtCoronetIcebergRuins_RemoveLegendaryKyurem:
    RemoveObject LOCALID_LEGENDARY_KYUREM
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

MtCoronetIcebergRuins_LegendaryKyurem:
    SetVar VAR_0x8004, SPECIES_KYUREM
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End
