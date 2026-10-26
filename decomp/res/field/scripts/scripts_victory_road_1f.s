#include "macros/scrcmd.inc"
#include "res/text/bank/victory_road_1f.h"
#include "res/field/events/events_victory_road_1f.h"


    ScriptEntry VictoryRoad_OnTransition
    ScriptEntry VictoryRoad_Collector
    ScriptEntry VictoryRoad1F_SovereignNurse
    ScriptEntry VictoryRoad1F_SovereignCoordEvent_Collector
    ScriptEntryEnd

@ Sovereign (E10, decision 46, Renegade): Victory Road's back area and Route 224 come before the League. The collector
@ no longer blocks the back area post-game: he stands by the way out to the League (38, 18) until the counterpart by
@ Route 224's tablet has been beaten. VAR_MAP_LOCAL_0x01 arms his trigger (0) or not (1).
VictoryRoad_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_VICTORY_ROAD
    SetFlag FLAG_HIDE_VICTORY_ROAD_1F_COLLECTOR
    SetVar VAR_MAP_LOCAL_0x01, 1
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_CHIMCHAR, VictoryRoad_DontShowCollector
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_PIPLUP, VictoryRoad_DontShowCollector
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_TURTWIG, VictoryRoad_DontShowCollector
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_CHIMCHAR, VictoryRoad_DontShowCollector
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_PIPLUP, VictoryRoad_DontShowCollector
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_TURTWIG, VictoryRoad_DontShowCollector
    ClearFlag FLAG_HIDE_VICTORY_ROAD_1F_COLLECTOR
    SetVar VAR_MAP_LOCAL_0x01, 0
VictoryRoad_DontShowCollector:
    End

VictoryRoad_Collector:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message VictoryRoad1F_Text_SovereignNotReadyYet
    WaitButton
    CloseMessage
    ReleaseAll
    End

@ Stepping beside him on the way out: he stops the player, sends them to Route 224, and they step back.
VictoryRoad1F_SovereignCoordEvent_Collector:
    LockAll
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8004, 37, VictoryRoad1F_SovereignCollectorNoticeWest
    CallIfEq VAR_0x8004, 39, VictoryRoad1F_SovereignCollectorNoticeEast
    Message VictoryRoad1F_Text_SovereignHoldIt
    CloseMessage
    CallIfEq VAR_0x8004, 37, VictoryRoad1F_SovereignPlayerFaceEast
    CallIfEq VAR_0x8004, 39, VictoryRoad1F_SovereignPlayerFaceWest
    Message VictoryRoad1F_Text_SovereignNotReadyYet
    CloseMessage
    ApplyMovement LOCALID_PLAYER, VictoryRoad1F_SovereignMovement_PlayerStepBack
    ApplyMovement LOCALID_COLLECTOR, VictoryRoad1F_SovereignMovement_CollectorFaceSouth
    WaitMovement
    ReleaseAll
    End

VictoryRoad1F_SovereignCollectorNoticeWest:
    ApplyMovement LOCALID_COLLECTOR, VictoryRoad1F_SovereignMovement_CollectorNoticeWest
    WaitMovement
    Return

VictoryRoad1F_SovereignCollectorNoticeEast:
    ApplyMovement LOCALID_COLLECTOR, VictoryRoad1F_SovereignMovement_CollectorNoticeEast
    WaitMovement
    Return

VictoryRoad1F_SovereignPlayerFaceEast:
    ApplyMovement LOCALID_PLAYER, VictoryRoad1F_SovereignMovement_PlayerFaceEast
    WaitMovement
    Return

VictoryRoad1F_SovereignPlayerFaceWest:
    ApplyMovement LOCALID_PLAYER, VictoryRoad1F_SovereignMovement_PlayerFaceWest
    WaitMovement
    Return

@ Sovereign (E10, Renegade): two nurses in Victory Road heal the party.
VictoryRoad1F_SovereignNurse:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message VictoryRoad1F_Text_SovereignNurseHeal
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Message VictoryRoad1F_Text_SovereignNurseGoodLuck
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
VictoryRoad1F_SovereignMovement_PlayerStepBack:
    WalkNormalSouth
    EndMovement

    .balign 4, 0
VictoryRoad1F_SovereignMovement_CollectorFaceSouth:
    FaceSouth
    EndMovement

    .balign 4, 0
VictoryRoad1F_SovereignMovement_CollectorNoticeWest:
    FaceWest
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
VictoryRoad1F_SovereignMovement_CollectorNoticeEast:
    FaceEast
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
VictoryRoad1F_SovereignMovement_PlayerFaceEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
VictoryRoad1F_SovereignMovement_PlayerFaceWest:
    WalkOnSpotNormalWest
    EndMovement
