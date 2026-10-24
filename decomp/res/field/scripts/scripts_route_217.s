#include "macros/scrcmd.inc"
#include "res/text/bank/route_217.h"
#include "res/field/events/events_route_217.h"


    ScriptEntry Route217_IceRock
    ScriptEntry Route217_ArrowSignpostLakeAcuity
    ScriptEntry Route217_SnowpointNPCF
    ScriptEntry Route217_CoordEvent_Maylene
    ScriptEntryEnd

// Sovereign (E10): as in Renegade Platinum, a piece of the Ice Rock comes off once: an Ice Stone.
Route217_IceRock:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_ROUTE_217_ICE_ROCK_ICE_STONE, Route217_IceRockEncrustedWithIce
    Message Route217_Text_SovereignAPieceFellOff
    SetVar VAR_0x8004, ITEM_ICE_STONE
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route217_IceRockBagIsFull
    SetFlag FLAG_SOVEREIGN_RECEIVED_ROUTE_217_ICE_ROCK_ICE_STONE
    Common_GiveItemQuantity
    CloseMessage
    ReleaseAll
    End

Route217_IceRockEncrustedWithIce:
    Message Route217_Text_BoulderEncrustedWithIce
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route217_IceRockBagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
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
    // Sovereign (E10): Maylene gives TM52 (Focus Blast), as in Renegade Platinum.
    Message Route217_Text_SovereignGoingToSnowpointCity
    SetVar VAR_0x8004, ITEM_TM52
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Message Route217_Text_SovereignThatContainsFocusBlast
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
