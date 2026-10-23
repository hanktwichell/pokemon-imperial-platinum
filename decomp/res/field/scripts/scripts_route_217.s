#include "macros/scrcmd.inc"
#include "res/text/bank/route_217.h"
#include "res/field/events/events_route_217.h"


    ScriptEntry Route217_IceRock
    ScriptEntry Route217_ArrowSignpostLakeAcuity
    ScriptEntry Route217_SnowpointNPCF
    ScriptEntry Route217_CoordEvent_Maylene
    ScriptEntry Route217_SovereignOnTransition
    ScriptEntry Route217_SovereignOnLoad
    ScriptEntry Route217_LegendaryGlastrier
    ScriptEntryEnd

Route217_IceRock:
    EventMessage Route217_Text_BoulderEncrustedWithIce
    End

Route217_ArrowSignpostLakeAcuity:
    ShowArrowSign Route217_Text_SignLakeAcuity
    End

Route217_SnowpointNPCF:
    NPCMessage Route217_Text_ImUsingDowsingMachine
    End

Route217_CoordEvent_Maylene:
    LockAll
    ClearFlag FLAG_HIDE_ROUTE_217_MAYLENE
    AddObject LOCALID_MAYLENE
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8004, 302, Route217_MayleneEnterX302
    CallIfEq VAR_0x8004, 303, Route217_MayleneEnterX303
    BufferPlayerName 0
    Message Route217_Text_OhPlayer
    CloseMessage
    ApplyMovement LOCALID_PLAYER, Route217_Movement_PlayerWalkOnSpotSouth
    WaitMovement
    ApplyMovement LOCALID_MAYLENE, Route217_Movement_MayleneWalkNorth
    WaitMovement
    Message Route217_Text_GoingToSnowpointCity
    CloseMessage
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8004, 302, Route217_MayleneLeaveX302
    CallIfEq VAR_0x8004, 303, Route217_MayleneLeaveX303
    RemoveObject LOCALID_MAYLENE
    SetVar VAR_ROUTE_217_STATE, 1
    SetFlag FLAG_HIDE_VEILSTONE_CITY_GYM_MAYLENE
    ReleaseAll
    End

Route217_MayleneEnterX302:
    ApplyMovement LOCALID_MAYLENE, Route217_Movement_MayleneEnterX302
    WaitMovement
    Return

Route217_MayleneEnterX303:
    ApplyMovement LOCALID_MAYLENE, Route217_Movement_MayleneEnterX303
    WaitMovement
    Return

Route217_MayleneLeaveX302:
    ApplyMovement LOCALID_PLAYER, Route217_Movement_PlayerWatchMayleneLeave
    ApplyMovement LOCALID_MAYLENE, Route217_Movement_MayleneLeaveX302
    WaitMovement
    Return

Route217_MayleneLeaveX303:
    ApplyMovement LOCALID_PLAYER, Route217_Movement_PlayerWatchMayleneLeave
    ApplyMovement LOCALID_MAYLENE, Route217_Movement_MayleneLeaveX303
    WaitMovement
    Return

    .balign 4, 0
Route217_Movement_PlayerWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
Route217_Movement_PlayerWatchMayleneLeave:
    Delay8 2
    Delay4
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
Route217_Movement_MayleneEnterX302:
    WalkNormalNorth 4
    WalkNormalWest 3
    WalkNormalNorth
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route217_Movement_MayleneEnterX303:
    WalkNormalNorth 4
    WalkNormalWest 2
    WalkNormalNorth
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route217_Movement_MayleneWalkNorth:
    WalkNormalNorth
    EndMovement

    .balign 4, 0
Route217_Movement_MayleneLeaveX302:
    WalkNormalEast
    WalkNormalNorth 3
    WalkNormalEast 2
    WalkNormalNorth 9
    EndMovement

    .balign 4, 0
Route217_Movement_MayleneLeaveX303:
    WalkNormalWest
    WalkNormalNorth 3
    WalkNormalEast 3
    WalkNormalNorth 9
    EndMovement

Route217_SovereignOnTransition:
    Call Route217_SovereignSetGlastrierVisibility
    End

Route217_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route217_RemoveLegendaryGlastrier
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Glastrier runs through the blizzard once Calyrex is caught,
@ until it is caught.
Route217_SovereignSetGlastrierVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 4, Route217_SovereignSetGlastrierVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_CALYREX, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route217_SovereignSetGlastrierVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_GLASTRIER, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route217_SovereignSetGlastrierVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route217_SovereignSetGlastrierVisibilityEnd:
    Return

Route217_RemoveLegendaryGlastrier:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_GLASTRIER, Route217_RemoveLegendaryGlastrierEnd
    RemoveObject LOCALID_LEGENDARY_GLASTRIER
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route217_RemoveLegendaryGlastrierEnd:
    Return

Route217_LegendaryGlastrier:
    SetVar VAR_0x8004, SPECIES_GLASTRIER
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End
