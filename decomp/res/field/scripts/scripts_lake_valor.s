#include "macros/scrcmd.inc"
#include "res/field/events/events_lake_valor.h"


    ScriptEntry LakeValor_Dummy1
    ScriptEntry LakeValor_OnTransition
    ScriptEntry LakeValor_OnLoad
    ScriptEntry LakeValor_LegendaryKeldeo
    ScriptEntryEnd

LakeValor_Dummy1:
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Keldeo, the young sword, comes to the north-west clearing
@ when the player brings Cobalion, Terrakion and Virizion along, until it's caught.
LakeValor_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 1, LakeValor_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_KELDEO, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, LakeValor_OnTransitionEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_COBALION
    GoToIfEq VAR_RESULT, FALSE, LakeValor_OnTransitionEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_TERRAKION
    GoToIfEq VAR_RESULT, FALSE, LakeValor_OnTransitionEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_VIRIZION
    GoToIfEq VAR_RESULT, FALSE, LakeValor_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
LakeValor_OnTransitionEnd:
    End

LakeValor_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, LakeValor_RemoveLegendaryKeldeo
    End

LakeValor_RemoveLegendaryKeldeo:
    RemoveObject LOCALID_LEGENDARY_KELDEO
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

LakeValor_LegendaryKeldeo:
    SetVar VAR_0x8004, SPECIES_KELDEO
    SetVar VAR_0x8005, 55
    Common_SovereignLegendaryEncounter
    End
