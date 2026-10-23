#include "macros/scrcmd.inc"
#include "res/text/bank/stark_mountain_outside.h"
#include "res/field/events/events_stark_mountain_outside.h"


    ScriptEntry StarkMountainOutside_OnTransition
    ScriptEntry StarkMountainOutside_SignboardStarkMountain
    ScriptEntry StarkMountainOutside_CoordEvent_Grunts
    ScriptEntry StarkMountainOutside_OnFrame_LookerBuck
    ScriptEntry StarkMountainOutside_OnLoad
    ScriptEntry StarkMountainOutside_LegendaryBlacephalon
    ScriptEntryEnd

StarkMountainOutside_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_STARK_MOUNTAIN_EXTERIOR
    Call StarkMountainOutside_SovereignSetBlacephalonVisibility
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): an Ultra Beast (Blacephalon) juggles its head in the hollow
@ east of the entrance once Necrozma is caught, until it's caught.
StarkMountainOutside_SovereignSetBlacephalonVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_NECROZMA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, StarkMountainOutside_SovereignSetBlacephalonVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_BLACEPHALON, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, StarkMountainOutside_SovereignSetBlacephalonVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
StarkMountainOutside_SovereignSetBlacephalonVisibilityEnd:
    Return

StarkMountainOutside_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, StarkMountainOutside_RemoveLegendaryBlacephalon
    End

StarkMountainOutside_RemoveLegendaryBlacephalon:
    RemoveObject LOCALID_LEGENDARY_BLACEPHALON
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

StarkMountainOutside_LegendaryBlacephalon:
    SetVar VAR_0x8004, SPECIES_BLACEPHALON
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

StarkMountainOutside_SignboardStarkMountain:
    ShowLandmarkSign StarkMountainOutside_Text_SignStarkMountain
    End

StarkMountainOutside_CoordEvent_Grunts:
    LockAll
    ApplyMovement LOCALID_GRUNT_M_1, StarkMountainOutside_Movement_GruntM1Enter
    ApplyMovement LOCALID_GRUNT_M_2, StarkMountainOutside_Movement_GruntM2Enter
    WaitMovement
    Message StarkMountainOutside_Text_LetsDoThis
    CloseMessage
    ApplyMovement LOCALID_GRUNT_M_1, StarkMountainOutside_Movement_GruntM1WalkToEntrance
    ApplyMovement LOCALID_GRUNT_M_2, StarkMountainOutside_Movement_GruntM2WalkToEntrance
    WaitMovement
    ApplyMovement LOCALID_GRUNT_M_2, StarkMountainOutside_Movement_GruntM2WalkOnSpotEast
    WaitMovement
    Message StarkMountainOutside_Text_CanHeReplaceCyrus
    CloseMessage
    ApplyMovement LOCALID_GRUNT_M_1, StarkMountainOutside_Movement_GruntM1WalkOnSpotWestNorth
    WaitMovement
    Message StarkMountainOutside_Text_GoodTimeToBeDone
    CloseMessage
    ApplyMovement LOCALID_GRUNT_M_1, StarkMountainOutside_Movement_GruntM1EnterStarkMountain
    ApplyMovement LOCALID_GRUNT_M_2, StarkMountainOutside_Movement_GruntM2EnterStarkMountain
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_GRUNT_M_1
    RemoveObject LOCALID_GRUNT_M_2
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    SetVar VAR_STARK_MOUNTAIN_OUTSIDE_STATE, 1
    ReleaseAll
    End

    .balign 4, 0
StarkMountainOutside_Movement_GruntM1Enter:
    WalkNormalEast 4
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_GruntM1WalkToEntrance:
    WalkNormalSouth 2
    WalkNormalEast 4
    WalkNormalNorth
    EndMovement

StarkMountainOutside_Movement_Unused:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_GruntM1WalkOnSpotWestNorth:
    WalkOnSpotNormalWest
    Delay8 2
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_GruntM1EnterStarkMountain:
    WalkNormalNorth 2
    SetInvisible
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_GruntM2Enter:
    WalkNormalNorth
    WalkNormalEast 3
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_GruntM2WalkToEntrance:
    WalkNormalEast
    WalkNormalSouth 2
    WalkNormalEast 3
    WalkNormalNorth
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_GruntM2WalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_GruntM2EnterStarkMountain:
    WalkNormalEast
    WalkNormalNorth 2
    SetInvisible
    EndMovement

StarkMountainOutside_OnFrame_LookerBuck:
    LockAll
    Message StarkMountainOutside_Text_InhaledVolcanicAsh
    CloseMessage
    WaitTime 15, VAR_RESULT
    Message StarkMountainOutside_Text_MagmaStone
    ApplyMovement LOCALID_BUCK, StarkMountainOutside_Movement_BuckWalkOnSpotEast
    WaitMovement
    Message StarkMountainOutside_Text_IllPutItBack
    CloseMessage
    ApplyMovement LOCALID_BUCK, StarkMountainOutside_Movement_BuckEnterStarkMountain
    WaitMovement
    ApplyMovement LOCALID_LOOKER, StarkMountainOutside_Movement_LookerWalkOnSpotWestSouth
    WaitMovement
    BufferPlayerName 0
    Message StarkMountainOutside_Text_WorkIsFinished
    CloseMessage
    WaitTime 15, VAR_RESULT
    ApplyMovement LOCALID_BUCK, StarkMountainOutside_Movement_BuckExitStarkMountain
    ApplyMovement LOCALID_LOOKER, StarkMountainOutside_Movement_LookerWalkOnSpotWest
    WaitMovement
    BufferPlayerName 0
    Message StarkMountainOutside_Text_SwingByMyPlace
    CloseMessage
    ApplyMovement LOCALID_BUCK, StarkMountainOutside_Movement_BuckLeave
    ApplyMovement LOCALID_PLAYER, StarkMountainOutside_Movement_PlayerWalkOnSpotWest
    WaitMovement
    RemoveObject LOCALID_BUCK
    ApplyMovement LOCALID_LOOKER, StarkMountainOutside_Movement_LookerWalkOnSpotSouth
    ApplyMovement LOCALID_PLAYER, StarkMountainOutside_Movement_PlayerWalkOnSpotNorth
    WaitMovement
    BufferPlayerName 0
    Message StarkMountainOutside_Text_FarewellMyFriend
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_LOOKER
    FadeScreenIn
    WaitFadeScreen
    SetVar VAR_STARK_MOUNTAIN_OUTSIDE_STATE, 3
    ReleaseAll
    End

    .balign 4, 0
StarkMountainOutside_Movement_LookerWalkOnSpotWestSouth:
    WalkOnSpotNormalWest
    Delay8 2
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_LookerWalkOnSpotWest:
    Delay8
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_LookerWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_BuckWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_BuckEnterStarkMountain:
    WalkNormalNorth 2
    SetInvisible
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_BuckExitStarkMountain:
    SetVisible
    WalkNormalSouth
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_BuckLeave:
    WalkNormalSouth 2
    WalkNormalWest 5
    WalkNormalNorth 2
    WalkNormalWest 3
    WalkFasterSouth 9
    WalkFasterEast 10
    WalkNormalNorth 6
    WalkNormalEast 8
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_PlayerWalkOnSpotWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
StarkMountainOutside_Movement_PlayerWalkOnSpotNorth:
    WalkOnSpotNormalNorth
    EndMovement
