#include "macros/scrcmd.inc"
#include "res/text/bank/route_208.h"
#include "res/field/events/events_route_208.h"


    ScriptEntry Route208_ArrowSignpostMtCoronet
    ScriptEntry Route208_ArrowSignpostHearthomeCity
    ScriptEntry Route208_SignboardBerryMastersHouse
    ScriptEntry Route208_BlackBelt
    ScriptEntry Route208_TrainerTipsSignpost
    ScriptEntry Route208_SovereignOnTransition
    ScriptEntry Route208_SovereignOnLoad
    ScriptEntry Route208_LegendaryRaikou
    ScriptEntryEnd

Route208_ArrowSignpostMtCoronet:
    ShowArrowSign Route208_Text_SignMtCoronet
    End

Route208_ArrowSignpostHearthomeCity:
    ShowArrowSign Route208_Text_SignHearthomeCity
    End

Route208_SignboardBerryMastersHouse:
    ShowLandmarkSign Route208_Text_SignBerryMastersHouse
    End

Route208_TrainerTipsSignpost:
    ShowScrollingSign Route208_Text_TrainerTipsWatchBerrySoilColor
    End

Route208_BlackBelt:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_RECEIVED_ROUTE_208_ODD_KEYSTONE, Route208_GoToRoute209
    Message Route208_Text_JustTakeIt
    SetVar VAR_0x8004, ITEM_ODD_KEYSTONE
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route208_BagIsFull
    SetFlag FLAG_RECEIVED_ROUTE_208_ODD_KEYSTONE
    Common_GiveItemQuantityNoLineFeed
    CloseMessage
    ReleaseAll
    End

Route208_GoToRoute209:
    Message Route208_Text_GoToRoute209
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route208_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0

Route208_SovereignOnTransition:
    Call Route208_SovereignSetRaikouVisibility
    End

Route208_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route208_RemoveLegendaryRaikou
    End

@ Sovereign (E10, Renegade's legendary events): Raikou on the Rock Climb ledge, after the Distortion World, until it is caught (Renegade: Lv. 60, a portal here).
Route208_SovereignSetRaikouVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfUnset FLAG_DEFEATED_TRAINER_GALACTIC_BOSS_CYRUS_DISTORTION_WORLD, Route208_SovereignSetRaikouVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_RAIKOU, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route208_SovereignSetRaikouVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route208_SovereignSetRaikouVisibilityEnd:
    Return

Route208_RemoveLegendaryRaikou:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_RAIKOU, Route208_RemoveLegendaryRaikouEnd
    RemoveObject LOCALID_LEGENDARY_RAIKOU
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route208_RemoveLegendaryRaikouEnd:
    Return

Route208_LegendaryRaikou:
    SetVar VAR_0x8004, SPECIES_RAIKOU
    SetVar VAR_0x8005, 60
    Common_SovereignLegendaryEncounter
    End
