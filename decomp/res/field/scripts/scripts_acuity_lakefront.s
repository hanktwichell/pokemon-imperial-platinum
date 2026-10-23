#include "macros/scrcmd.inc"
#include "res/text/bank/acuity_lakefront.h"
#include "res/field/events/events_acuity_lakefront.h"


    ScriptEntry AcuityLakefront_OnTransition
    ScriptEntry AcuityLakefront_OnLoad
    ScriptEntry AcuityLakefront_ArrowSignpostLakeAcuity
    ScriptEntry AcuityLakefront_CoordEvent_Rival
    ScriptEntry AcuityLakefront_LegendaryChienPao
    ScriptEntry AcuityLakefront_SovereignStake3
    ScriptEntry AcuityLakefront_SovereignStake4
    ScriptEntryEnd

AcuityLakefront_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, AcuityLakefront_RemoveLegendaryChienPao
    GoToIfUnset FLAG_TEAM_GALACTIC_LEFT_LAKE_VERITY, AcuityLakefront_RemoveWarpsLakeAcuityNormal
    GoToIfSet FLAG_TEAM_GALACTIC_LEFT_LAKE_VERITY, AcuityLakefront_RemoveWarpsLakeAcuityLowWater
    End

AcuityLakefront_RemoveWarpsLakeAcuityNormal:
    SetWarpEventPos 2, 305, 229
    SetWarpEventPos 3, 306, 229
    End

AcuityLakefront_RemoveWarpsLakeAcuityLowWater:
    SetWarpEventPos 0, 305, 229
    SetWarpEventPos 1, 306, 229
    End

AcuityLakefront_OnTransition:
    Call AcuityLakefront_SovereignSetStake4Visibility
    Call AcuityLakefront_SovereignSetStake3Visibility
    Call AcuityLakefront_SovereignSetChienPaoVisibility
    CheckBadgeAcquired BADGE_ID_ICICLE, VAR_MAP_LOCAL_0x00
    CallIfEq VAR_MAP_LOCAL_0x00, TRUE, AcuityLakefront_SetVeilstoneGymMaylene
    GoToIfUnset FLAG_TEAM_GALACTIC_LEFT_LAKE_VERITY, AcuityLakefront_RemoveWarpsLakeAcuityNormal
    GoToIfSet FLAG_TEAM_GALACTIC_LEFT_LAKE_VERITY, AcuityLakefront_RemoveWarpsLakeAcuityLowWater
    End

AcuityLakefront_SetVeilstoneGymMaylene:
    SetFlag FLAG_HIDE_SNOWPOINT_CITY_POKECENTER_1F_MAYLENE
    ClearFlag FLAG_HIDE_VEILSTONE_CITY_GYM_MAYLENE
    Return

AcuityLakefront_ArrowSignpostLakeAcuity:
    ShowArrowSign AcuityLakefront_Text_SignLakeAcuityAhead
    End

AcuityLakefront_CoordEvent_Rival:
    LockAll
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    AddFreeCamera VAR_0x8004, VAR_0x8005
    ApplyFreeCameraMovement AcuityLakefront_Movement_CameraMoveNorth
    WaitMovement
    WaitTime 15, VAR_RESULT
    BufferRivalName 0
    BufferPlayerName 1
    Message AcuityLakefront_Text_CantClimbWithoutBadge
    CloseMessage
    ApplyMovement LOCALID_RIVAL, AcuityLakefront_Movement_RivalLeave
    WaitMovement
    RemoveObject LOCALID_RIVAL
    ApplyFreeCameraMovement AcuityLakefront_Movement_CameraMoveSouth
    WaitMovement
    RestoreCamera
    SetVar VAR_ACUITY_LAKEFRONT_STATE, 1
    ReleaseAll
    End

    .balign 4, 0
AcuityLakefront_Movement_CameraMoveNorth:
    WalkNormalNorth 6
    EndMovement

    .balign 4, 0
AcuityLakefront_Movement_CameraMoveSouth:
    WalkNormalSouth 6
    EndMovement

    .balign 4, 0
AcuityLakefront_Movement_RivalLeave:
    WalkNormalNorth 3
    WalkNormalWest
    WalkNormalNorth 4
    EndMovement

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): one of the Treasures of Ruin, unsealed once both its stakes
@ on this map are pulled out (FLAG_SOVEREIGN_PULLED_STAKE_3 and _4), until it is caught.
AcuityLakefront_SovereignSetChienPaoVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, AcuityLakefront_SovereignSetChienPaoVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_PULLED_STAKE_3, AcuityLakefront_SovereignSetChienPaoVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_PULLED_STAKE_4, AcuityLakefront_SovereignSetChienPaoVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_CHIEN_PAO, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, AcuityLakefront_SovereignSetChienPaoVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
AcuityLakefront_SovereignSetChienPaoVisibilityEnd:
    Return

AcuityLakefront_RemoveLegendaryChienPao:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_CHIEN_PAO, AcuityLakefront_RemoveLegendaryChienPaoEnd
    RemoveObject LOCALID_LEGENDARY_CHIEN_PAO
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
AcuityLakefront_RemoveLegendaryChienPaoEnd:
    Return

AcuityLakefront_LegendaryChienPao:
    SetVar VAR_0x8004, SPECIES_CHIEN_PAO
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, the Treasures of Ruin): stake 3 of the two that seal ChienPao's shrine here, shown once the
@ Paldea Chronicle is open until it's pulled out (FLAG_SOVEREIGN_PULLED_STAKE_3).
AcuityLakefront_SovereignSetStake3Visibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, AcuityLakefront_SovereignSetStake3VisibilityEnd
    GoToIfSet FLAG_SOVEREIGN_PULLED_STAKE_3, AcuityLakefront_SovereignSetStake3VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
AcuityLakefront_SovereignSetStake3VisibilityEnd:
    Return

AcuityLakefront_SovereignStake3:
    SetVar VAR_0x8004, FLAG_SOVEREIGN_PULLED_STAKE_3
    SetVar VAR_0x8005, LOCALID_SOVEREIGN_STAKE_3
    Common_SovereignStake
    GoToIfEq VAR_RESULT, FALSE, AcuityLakefront_SovereignStake3End
    Call AcuityLakefront_SovereignSetChienPaoVisibility
    GoToIfSet FLAG_MAP_LOCAL_HIDE_LEGENDARY, AcuityLakefront_SovereignStake3End
    AddObject LOCALID_LEGENDARY_CHIEN_PAO
AcuityLakefront_SovereignStake3End:
    End

@ Sovereign (the Chronicles, the Treasures of Ruin): stake 4 of the two that seal ChienPao's shrine here, shown once the
@ Paldea Chronicle is open until it's pulled out (FLAG_SOVEREIGN_PULLED_STAKE_4).
AcuityLakefront_SovereignSetStake4Visibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, AcuityLakefront_SovereignSetStake4VisibilityEnd
    GoToIfSet FLAG_SOVEREIGN_PULLED_STAKE_4, AcuityLakefront_SovereignSetStake4VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
AcuityLakefront_SovereignSetStake4VisibilityEnd:
    Return

AcuityLakefront_SovereignStake4:
    SetVar VAR_0x8004, FLAG_SOVEREIGN_PULLED_STAKE_4
    SetVar VAR_0x8005, LOCALID_SOVEREIGN_STAKE_4
    Common_SovereignStake
    GoToIfEq VAR_RESULT, FALSE, AcuityLakefront_SovereignStake4End
    Call AcuityLakefront_SovereignSetChienPaoVisibility
    GoToIfSet FLAG_MAP_LOCAL_HIDE_LEGENDARY, AcuityLakefront_SovereignStake4End
    AddObject LOCALID_LEGENDARY_CHIEN_PAO
AcuityLakefront_SovereignStake4End:
    End
