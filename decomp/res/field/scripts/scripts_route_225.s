#include "macros/scrcmd.inc"
#include "res/text/bank/route_225.h"
#include "res/field/events/events_route_225.h"


    ScriptEntry Route225_ArrowSignpostFightArea
    ScriptEntry Route225_ArrowSignpostSurvivalArea
    ScriptEntry Route225_OnTransition
    ScriptEntry Route225_OnLoad
    ScriptEntry Route225_LegendaryBuzzwole
    ScriptEntry Route225_LegendaryOkidogi
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): an Ultra Beast (Buzzwole) flexes by the item in the north
@ field once Necrozma is caught, until it's caught.
Route225_OnTransition:
    Call Route225_SovereignSetOkidogiVisibility
    Call Route225_SovereignSetBuzzwoleVisibility
    End

Route225_SovereignSetBuzzwoleVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_NECROZMA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route225_SovereignSetBuzzwoleVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_BUZZWOLE, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route225_SovereignSetBuzzwoleVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route225_SovereignSetBuzzwoleVisibilityEnd:
    Return

Route225_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route225_RemoveLegendaryOkidogi
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route225_RemoveLegendaryBuzzwole
    End

Route225_RemoveLegendaryBuzzwole:
    RemoveObject LOCALID_LEGENDARY_BUZZWOLE
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route225_LegendaryBuzzwole:
    SetVar VAR_0x8004, SPECIES_BUZZWOLE
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

Route225_ArrowSignpostFightArea:
    ShowArrowSign Route225_Text_SignFightArea
    End

Route225_ArrowSignpostSurvivalArea:
    ShowArrowSign Route225_Text_SignSurvivalArea
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Okidogi, one of the Loyal Three, waits here once the Paldea
@ Chronicle is open, until it is caught.
Route225_SovereignSetOkidogiVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route225_SovereignSetOkidogiVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_OKIDOGI, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route225_SovereignSetOkidogiVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
Route225_SovereignSetOkidogiVisibilityEnd:
    Return

Route225_RemoveLegendaryOkidogi:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_OKIDOGI, Route225_RemoveLegendaryOkidogiEnd
    RemoveObject LOCALID_LEGENDARY_OKIDOGI
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route225_RemoveLegendaryOkidogiEnd:
    Return

Route225_LegendaryOkidogi:
    SetVar VAR_0x8004, SPECIES_OKIDOGI
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End
