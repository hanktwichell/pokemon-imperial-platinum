#include "macros/scrcmd.inc"
#include "res/text/bank/route_229.h"
#include "res/field/events/events_route_229.h"


    ScriptEntry Route229_PokefanM
    ScriptEntry Route229_ArrowSignpostResortArea
    ScriptEntry Route229_OnTransition
    ScriptEntry Route229_OnLoad
    ScriptEntry Route229_LegendaryPheromosa
    ScriptEntry Route229_LegendaryMunkidori
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): an Ultra Beast (Pheromosa) waits in the pocket by the Reaper
@ Cloth once Necrozma is caught, until it's caught.
Route229_OnTransition:
    Call Route229_SovereignSetMunkidoriVisibility
    Call Route229_SovereignSetPheromosaVisibility
    End

Route229_SovereignSetPheromosaVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_NECROZMA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route229_SovereignSetPheromosaVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_PHEROMOSA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route229_SovereignSetPheromosaVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route229_SovereignSetPheromosaVisibilityEnd:
    Return

Route229_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route229_RemoveLegendaryMunkidori
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route229_RemoveLegendaryPheromosa
    End

Route229_RemoveLegendaryPheromosa:
    RemoveObject LOCALID_LEGENDARY_PHEROMOSA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route229_LegendaryPheromosa:
    SetVar VAR_0x8004, SPECIES_PHEROMOSA
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

Route229_PokefanM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_RECEIVED_ROUTE_229_NUGGET, Route229_ThoseAreMyNuggets
    Message Route229_Text_MakeItUpWithThis
    SetVar VAR_0x8004, ITEM_NUGGET
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route229_BagIsFull
    Common_GiveItemQuantity
    SetFlag FLAG_RECEIVED_ROUTE_229_NUGGET
    SetVar VAR_0x8004, ITEM_NUGGET
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route229_ThoseAreMyNuggets
    Message Route229_Text_TakeAnother
    Common_GiveItemQuantity
    GoTo Route229_ThoseAreMyNuggets
    End

Route229_ThoseAreMyNuggets:
    Message Route229_Text_ThoseAreMyNuggets
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route229_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

Route229_ArrowSignpostResortArea:
    ShowArrowSign Route229_Text_SignResortArea
    End

    .balign 4, 0

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Munkidori, one of the Loyal Three, waits here once the
@ Paldea Chronicle is open, until it is caught.
Route229_SovereignSetMunkidoriVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route229_SovereignSetMunkidoriVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MUNKIDORI, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route229_SovereignSetMunkidoriVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
Route229_SovereignSetMunkidoriVisibilityEnd:
    Return

Route229_RemoveLegendaryMunkidori:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_MUNKIDORI, Route229_RemoveLegendaryMunkidoriEnd
    RemoveObject LOCALID_LEGENDARY_MUNKIDORI
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route229_RemoveLegendaryMunkidoriEnd:
    Return

Route229_LegendaryMunkidori:
    SetVar VAR_0x8004, SPECIES_MUNKIDORI
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End
