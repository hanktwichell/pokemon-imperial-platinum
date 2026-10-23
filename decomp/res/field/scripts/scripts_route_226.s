#include "macros/scrcmd.inc"
#include "res/text/bank/route_226.h"
#include "res/field/events/events_route_226.h"


    ScriptEntry Route226_ArrowSignpostSurvivalArea
    ScriptEntry Route226_ArrowSignpostRt227Rt228
    ScriptEntry Route226_OnTransition
    ScriptEntry Route226_OnLoad
    ScriptEntry Route226_LegendaryTapuFini
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Tapu Fini stands on the little beach under the cliffs, out
@ at sea, once the Alola Chronicle is open (VAR_SOVEREIGN_CHRONICLE 3), until it's caught.
Route226_OnTransition:
    Call Route226_SovereignSetTapuFiniVisibility
    End

Route226_SovereignSetTapuFiniVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, Route226_SovereignSetTapuFiniVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_TAPU_FINI, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route226_SovereignSetTapuFiniVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route226_SovereignSetTapuFiniVisibilityEnd:
    Return

Route226_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route226_RemoveLegendaryTapuFini
    End

Route226_RemoveLegendaryTapuFini:
    RemoveObject LOCALID_LEGENDARY_TAPU_FINI
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route226_LegendaryTapuFini:
    SetVar VAR_0x8004, SPECIES_TAPU_FINI
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

Route226_ArrowSignpostSurvivalArea:
    ShowArrowSign Route226_Text_SignSurvivalArea
    End

Route226_ArrowSignpostRt227Rt228:
    ShowArrowSign Route226_Text_SignRt227Rt228
    End
