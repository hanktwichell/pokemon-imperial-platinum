#include "macros/scrcmd.inc"
#include "res/text/bank/route_227.h"
#include "res/field/events/events_route_227.h"


    ScriptEntry Route227_CoordEvent_WakeRival
    ScriptEntry Route227_ArrowSignpostStarkMountain
    ScriptEntry Route227_CoordEvent_Buck
    ScriptEntry Route227_Buck
    ScriptEntry Route227_OnTransition
    ScriptEntry Route227_OnLoad
    ScriptEntry Route227_LegendaryTerrakion
    ScriptEntry Route227_SovereignSlythe
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Terrakion stands in the rock pocket at the north end once
@ the Unova Chronicle is open, until it's caught.
Route227_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 1, Route227_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_TERRAKION, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route227_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route227_OnTransitionEnd:
    End

Route227_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route227_RemoveLegendaryTerrakion
    End

Route227_RemoveLegendaryTerrakion:
    RemoveObject LOCALID_LEGENDARY_TERRAKION
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route227_LegendaryTerrakion:
    SetVar VAR_0x8004, SPECIES_TERRAKION
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

Route227_CoordEvent_WakeRival:
    LockAll
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8004, 739, Route227_PlayerWalkWestOnSpotNorth
    ApplyMovement LOCALID_CRASHER_WAKE, Route227_Movement_WakeNoticePlayer
    ApplyMovement LOCALID_RIVAL, Route227_Movement_RivalNoticePlayer
    ApplyMovement LOCALID_PLAYER, Route227_Movement_PlayerFaceNorth
    WaitMovement
    BufferPlayerName 0
    Message Route227_Text_IfItIsntPlayer
    CloseMessage
    ApplyMovement LOCALID_RIVAL, Route227_Movement_RivalWalkOnSpotWest
    WaitMovement
    WaitTime 15, VAR_RESULT
    BufferRivalName 1
    Message Route227_Text_ThatsMyMaster
    CloseMessage
    ApplyMovement LOCALID_CRASHER_WAKE, Route227_Movement_WakeWalkOnSpotEast
    WaitMovement
    Message Route227_Text_StillTroubleUnderstanding
    BufferRivalName 1
    Message Route227_Text_DontBeThatWay
    ApplyMovement LOCALID_CRASHER_WAKE, Route227_Movement_WakeWalkOnSpotSouth
    WaitMovement
    BufferPlayerName 0
    Message Route227_Text_BetterBeFullyPrepared
    CloseMessage
    ApplyMovement LOCALID_CRASHER_WAKE, Route227_Movement_WakeLeave
    ApplyMovement LOCALID_PLAYER, Route227_Movement_PlayerWalkWestWatchWakeLeave
    ApplyMovement LOCALID_RIVAL, Route227_Movement_RivalWatchWakeLeave
    WaitMovement
    RemoveObject LOCALID_CRASHER_WAKE
    ApplyMovement LOCALID_RIVAL, Route227_Movement_RivalWalkOnSpotSouth
    ApplyMovement LOCALID_PLAYER, Route227_Movement_PlayerWalkToRival
    WaitMovement
    WaitTime 5, VAR_RESULT
    BufferRivalName 1
    Message Route227_Text_OffToBattleFrontier
    Message Route227_Text_WaitForMe
    CloseMessage
    ApplyMovement LOCALID_RIVAL, Route227_Movement_RivalLeave
    ApplyMovement LOCALID_PLAYER, Route227_Movement_PlayerWatchRivalLeave
    WaitMovement
    RemoveObject LOCALID_RIVAL
    SetVar VAR_ROUTE_227_WAKE_RIVAL_STATE, 1
    ReleaseAll
    End

Route227_PlayerWalkWestOnSpotNorth:
    ApplyMovement LOCALID_PLAYER, Route227_Movement_PlayerWalkWestOnSpotNorth
    WaitMovement
    Return

    .balign 4, 0
Route227_Movement_PlayerWalkWestOnSpotNorth:
    WalkNormalWest
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
Route227_Movement_PlayerFaceNorth:
    FaceNorth
    EndMovement

    .balign 4, 0
Route227_Movement_PlayerWalkToRival:
    WalkNormalEast
    WalkNormalNorth
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
Route227_Movement_PlayerWatchRivalLeave:
    Delay8
    WalkOnSpotNormalSouth
    EndMovement

Route227_Movement_Unused:
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
Route227_Movement_PlayerWalkWestWatchWakeLeave:
    WalkNormalWest
    WalkOnSpotNormalEast
    Delay4
    WalkOnSpotNormalSouth
    EndMovement

Route227_Movement_Unused2:
    Delay8
    WalkOnSpotNormalWest
    Delay4
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
Route227_Movement_RivalNoticePlayer:
    WalkOnSpotNormalSouth
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route227_Movement_RivalWalkOnSpotWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
Route227_Movement_RivalWatchWakeLeave:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
Route227_Movement_RivalWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
Route227_Movement_RivalLeave:
    WalkFastSouth 9
    EndMovement

Route227_Movement_Unused3:
    WalkFastSouth 9
    EndMovement

    .balign 4, 0
Route227_Movement_WakeNoticePlayer:
    WalkOnSpotNormalSouth
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route227_Movement_WakeWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
Route227_Movement_WakeWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

Route227_Movement_Unused4:
    Delay8
    WalkOnSpotNormalEast
    EndMovement

Route227_Movement_Unused5:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
Route227_Movement_WakeLeave:
    Delay8 2
    WalkNormalSouth 9
    EndMovement

Route227_Movement_Unused6:
    WalkNormalSouth 9
    EndMovement

Route227_ArrowSignpostStarkMountain:
    ShowArrowSign Route227_Text_SignStarkMountain
    End

Route227_Buck:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Route227_Text_SovereignBuckBeatAllSix
    Call Route227_SovereignCheckBadges
    GoToIfEq VAR_RESULT, FALSE, Route227_SovereignBuckNotYet
    GoTo Route227_SovereignBuckBattle
    End

Route227_CoordEvent_Buck:
    LockAll
    ApplyMovement LOCALID_BUCK, Route227_SovereignMovement_BuckNoticePlayer
    ApplyMovement LOCALID_PLAYER, Route227_Movement_PlayerFaceBuck
    WaitMovement
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8005, 259, Route227_SovereignPlayerWalkToBuck1
    CallIfEq VAR_0x8005, 260, Route227_SovereignPlayerWalkToBuck2
    BufferPlayerName 0
    Message Route227_Text_SovereignBuckBeatAllSix
    Call Route227_SovereignCheckBadges
    GoToIfEq VAR_RESULT, FALSE, Route227_SovereignBuckNotYetStepAside
    GoTo Route227_SovereignBuckBattle
    End

Route227_AskPatrolStarkMountain:
    BufferPlayerName 0
    Message Route227_Text_PatrolStarkMountain
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, Route227_GoonsCausingTrouble
    GoToIfEq VAR_RESULT, MENU_NO, Route227_IllKeepAsking
    End

Route227_IllKeepAsking:
    Message Route227_Text_IllKeepAsking
    GoTo Route227_AskPatrolStarkMountain
    End

Route227_GoonsCausingTrouble:
    ApplyMovement LOCALID_BUCK, Route227_Movement_BuckWalkOnSpotNorth
    WaitMovement
    Message Route227_Text_GoonsCausingTrouble
    ApplyMovement LOCALID_BUCK, Route227_Movement_BuckWalkOnSpotSouth
    WaitMovement
    Message Route227_Text_WhatMe
    CloseMessage
    SetVar VAR_ROUTE_227_BUCK_STATE, 1
    ReleaseAll
    End

    .balign 4, 0
Route227_Movement_PlayerFaceBuck:
    FaceNorth
    EndMovement

Route227_Movement_Unused7:
    Delay8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
Route227_Movement_BuckNoticePlayer:
    WalkOnSpotNormalSouth
    EmoteExclamationMark
    WalkNormalSouth
    EndMovement

    .balign 4, 0
Route227_Movement_BuckWalkOnSpotNorth:
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
Route227_Movement_BuckWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

@ Sovereign (E10, Renegade's Battle Zone): Slythe gives the unofficial Acid Badge (just a keepsake, no item) to a player
@ who beats their team (Renegade's trainer 1025).
Route227_SovereignSlythe:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_SLYTHE, Route227_SovereignSlytheThanks
    Message Route227_Text_SovereignSlytheIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route227_SovereignSlytheDecline
    Message Route227_Text_SovereignSlytheBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_BATTLE_ZONE_SLYTHE
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route227_SovereignSlytheLost
    Message Route227_Text_SovereignSlytheReward
    BufferPlayerName 0
    Message Route227_Text_SovereignSlytheReceived
    PlayFanfare SEQ_BADGE_sseq
    WaitFanfare
    Message Route227_Text_SovereignSlytheExplain
    WaitButton
    CloseMessage
    SetTrainerFlag TRAINER_SOVEREIGN_BATTLE_ZONE_SLYTHE
    ReleaseAll
    End

Route227_SovereignSlytheThanks:
    Message Route227_Text_SovereignSlytheThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route227_SovereignSlytheDecline:
    CloseMessage
    ReleaseAll
    End

Route227_SovereignSlytheLost:
    BlackOutFromBattle
    ReleaseAll
    End

    

@ Sovereign (E10, Renegade): Buck waits below the ledges near Stark Mountain. Once the player has beaten the six
@ Battle Zone leaders (their trainer flags are the badges), he battles (Renegade's trainer 1023), heals the party, asks
@ for the Stark Mountain patrol and leaves. Until then the coord event sends the player on.
Route227_SovereignCheckBadges:
    SetVar VAR_RESULT, FALSE
    GoToIfNotDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_WYVER, Route227_SovereignCheckBadgesEnd
    GoToIfNotDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_HEATHER, Route227_SovereignCheckBadgesEnd
    GoToIfNotDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_SLYTHE, Route227_SovereignCheckBadgesEnd
    GoToIfNotDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_SHADE, Route227_SovereignCheckBadgesEnd
    GoToIfNotDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_GENE, Route227_SovereignCheckBadgesEnd
    GoToIfNotDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_LUNA, Route227_SovereignCheckBadgesEnd
    SetVar VAR_RESULT, TRUE
Route227_SovereignCheckBadgesEnd:
    Return

Route227_SovereignBuckBattle:
    Message Route227_Text_SovereignBuckYouDidIt
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_BUCK_ROUTE_227
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route227_SovereignBuckLost
    Message Route227_Text_SovereignBuckSmokingHot
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    BufferPlayerName 0
    Message Route227_Text_SovereignBuckPatrolStarkMountain
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_BUCK
    SetTrainerFlag TRAINER_SOVEREIGN_BUCK_ROUTE_227
    SetVar VAR_ROUTE_227_BUCK_STATE, 1
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

Route227_SovereignBuckNotYet:
    Message Route227_Text_SovereignBuckNotYet
    CloseMessage
    ReleaseAll
    End

Route227_SovereignBuckNotYetStepAside:
    Message Route227_Text_SovereignBuckNotYet
    CloseMessage
    ApplyMovement LOCALID_PLAYER, Route227_SovereignMovement_PlayerStepWest
    WaitMovement
    ReleaseAll
    End

Route227_SovereignBuckLost:
    BlackOutFromBattle
    ReleaseAll
    End

Route227_SovereignPlayerWalkToBuck1:
    ApplyMovement LOCALID_PLAYER, Route227_SovereignMovement_PlayerWalkNorth1
    WaitMovement
    Return

Route227_SovereignPlayerWalkToBuck2:
    ApplyMovement LOCALID_PLAYER, Route227_SovereignMovement_PlayerWalkNorth2
    WaitMovement
    Return

    .balign 4, 0
Route227_SovereignMovement_BuckNoticePlayer:
    FaceSouth
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route227_SovereignMovement_PlayerWalkNorth1:
    WalkNormalNorth
    EndMovement

    .balign 4, 0
Route227_SovereignMovement_PlayerWalkNorth2:
    WalkNormalNorth 2
    EndMovement

    .balign 4, 0
Route227_SovereignMovement_PlayerStepWest:
    WalkNormalWest
    EndMovement

    .balign 4, 0
