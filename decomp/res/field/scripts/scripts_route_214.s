#include "macros/scrcmd.inc"
#include "res/field/events/events_route_214.h"
#include "res/text/bank/route_214.h"


    ScriptEntry Route214_ArrowSignpostVeilstoneCity
    ScriptEntry Route214_ArrowSignpostLakeValor
    ScriptEntry Route214_OnTransition
    ScriptEntry Route214_OnLoad
    ScriptEntry Route214_LegendaryTingLu
    ScriptEntry Route214_SovereignStake5
    ScriptEntry Route214_SovereignStake6
    ScriptEntry Route214_SovereignBlackBelt
    ScriptEntryEnd

Route214_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route214_RemoveLegendaryTingLu
    GetUnownFormsSeenCount VAR_MAP_LOCAL_0x00
    GoToIfGe VAR_MAP_LOCAL_0x00, 26, Route214_RemoveWarpsManiacCaveShortAndLong
    GoToIfGe VAR_MAP_LOCAL_0x00, 10, Route214_RemoveWarpsManiacCaveShortAndTunnel
    GoToIfLt VAR_MAP_LOCAL_0x00, 10, Route214_RemoveWarpsManiacCaveLongAndTunnel
    End

Route214_RemoveWarpsManiacCaveShortAndLong:
    SetWarpEventPos 2, 710, 670
    SetWarpEventPos 3, 710, 670
    End

Route214_RemoveWarpsManiacCaveShortAndTunnel:
    SetWarpEventPos 2, 710, 670
    SetWarpEventPos 4, 710, 670
    End

Route214_RemoveWarpsManiacCaveLongAndTunnel:
    SetWarpEventPos 3, 710, 670
    SetWarpEventPos 4, 710, 670
    End

Route214_OnTransition:
    Call Route214_SovereignSetStake6Visibility
    Call Route214_SovereignSetStake5Visibility
    Call Route214_SovereignSetTingLuVisibility
    GetUnownFormsSeenCount VAR_MAP_LOCAL_0x00
    GoToIfGe VAR_MAP_LOCAL_0x00, 26, Route214_RemoveWarpsManiacCaveShortAndLong
    GoToIfGe VAR_MAP_LOCAL_0x00, 10, Route214_RemoveWarpsManiacCaveShortAndTunnel
    GoToIfLt VAR_MAP_LOCAL_0x00, 10, Route214_RemoveWarpsManiacCaveLongAndTunnel
    End

Route214_ArrowSignpostVeilstoneCity:
    ShowArrowSign Route214_Text_SignVeilstoneCity
    End

Route214_ArrowSignpostLakeValor:
    ShowArrowSign Route214_Text_SignLakeValor
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): one of the Treasures of Ruin, unsealed once both its stakes
@ on this map are pulled out (FLAG_SOVEREIGN_PULLED_STAKE_5 and _6), until it is caught.
Route214_SovereignSetTingLuVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route214_SovereignSetTingLuVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_PULLED_STAKE_5, Route214_SovereignSetTingLuVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_PULLED_STAKE_6, Route214_SovereignSetTingLuVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_TING_LU, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route214_SovereignSetTingLuVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route214_SovereignSetTingLuVisibilityEnd:
    Return

Route214_RemoveLegendaryTingLu:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_TING_LU, Route214_RemoveLegendaryTingLuEnd
    RemoveObject LOCALID_LEGENDARY_TING_LU
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route214_RemoveLegendaryTingLuEnd:
    Return

Route214_LegendaryTingLu:
    SetVar VAR_0x8004, SPECIES_TING_LU
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, the Treasures of Ruin): stake 5 of the two that seal TingLu's shrine here, shown once the
@ Paldea Chronicle is open until it's pulled out (FLAG_SOVEREIGN_PULLED_STAKE_5).
Route214_SovereignSetStake5Visibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route214_SovereignSetStake5VisibilityEnd
    GoToIfSet FLAG_SOVEREIGN_PULLED_STAKE_5, Route214_SovereignSetStake5VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
Route214_SovereignSetStake5VisibilityEnd:
    Return

Route214_SovereignStake5:
    SetVar VAR_0x8004, FLAG_SOVEREIGN_PULLED_STAKE_5
    SetVar VAR_0x8005, LOCALID_SOVEREIGN_STAKE_5
    Common_SovereignStake
    GoToIfEq VAR_RESULT, FALSE, Route214_SovereignStake5End
    Call Route214_SovereignSetTingLuVisibility
    GoToIfSet FLAG_MAP_LOCAL_HIDE_LEGENDARY, Route214_SovereignStake5End
    AddObject LOCALID_LEGENDARY_TING_LU
Route214_SovereignStake5End:
    End

@ Sovereign (the Chronicles, the Treasures of Ruin): stake 6 of the two that seal TingLu's shrine here, shown once the
@ Paldea Chronicle is open until it's pulled out (FLAG_SOVEREIGN_PULLED_STAKE_6).
Route214_SovereignSetStake6Visibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route214_SovereignSetStake6VisibilityEnd
    GoToIfSet FLAG_SOVEREIGN_PULLED_STAKE_6, Route214_SovereignSetStake6VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
Route214_SovereignSetStake6VisibilityEnd:
    Return

Route214_SovereignStake6:
    SetVar VAR_0x8004, FLAG_SOVEREIGN_PULLED_STAKE_6
    SetVar VAR_0x8005, LOCALID_SOVEREIGN_STAKE_6
    Common_SovereignStake
    GoToIfEq VAR_RESULT, FALSE, Route214_SovereignStake6End
    Call Route214_SovereignSetTingLuVisibility
    GoToIfSet FLAG_MAP_LOCAL_HIDE_LEGENDARY, Route214_SovereignStake6End
    AddObject LOCALID_LEGENDARY_TING_LU
Route214_SovereignStake6End:
    End

// Sovereign (E10): Renegade's Choice Band Black Belt.
Route214_SovereignBlackBelt:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_ROUTE_214_CHOICE_BAND, Route214_SovereignBlackBeltAgain
    Message Route214_Text_SovereignBlackBeltGives
    SetVar VAR_0x8004, ITEM_CHOICE_BAND
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_ROUTE_214_CHOICE_BAND
    Message Route214_Text_SovereignBlackBeltExplains
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route214_SovereignBlackBeltAgain:
    Message Route214_Text_SovereignBlackBeltAgain
    WaitButton
    CloseMessage
    ReleaseAll
    End
