#include "macros/scrcmd.inc"
#include "res/text/bank/route_209_gate_to_hearthome_city.h"
#include "res/field/events/events_route_209_gate_to_hearthome_city.h"


    ScriptEntry Route209GateToHearthomeCity_BattleGirl
    ScriptEntry Route209GateToHearthomeCity_CoordEvent_Rival
    ScriptEntryEnd

Route209GateToHearthomeCity_BattleGirl:
    NPCMessage Route209GateToHearthomeCity_Text_WreckedStonePillar
    End

Route209GateToHearthomeCity_CoordEvent_Rival:
    LockAll
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalNoticePlayer
    WaitMovement
    Common_SetRivalBGM
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8005, 5, Route209GateToHearthomeCity_RivalWalkToPlayerZ5
    CallIfEq VAR_0x8005, 6, Route209GateToHearthomeCity_RivalWalkToPlayerZ6
    CallIfEq VAR_0x8005, 7, Route209GateToHearthomeCity_RivalWalkToPlayerZ7
    CallIfEq VAR_0x8005, 8, Route209GateToHearthomeCity_RivalWalkToPlayerZ8
    CallIfEq VAR_0x8005, 9, Route209GateToHearthomeCity_RivalWalkToPlayerZ9
    BufferRivalName 0
    BufferPlayerName 1
    Message Route209GateToHearthomeCity_Text_LetsGetTheShowStarted
    CloseMessage
    GetPlayerStarterSpecies VAR_RESULT
    GoToIfEq VAR_RESULT, SPECIES_TURTWIG, Route209GateToHearthomeCity_StartRivalBattleTurtwig
    GoToIfEq VAR_RESULT, SPECIES_CHIMCHAR, Route209GateToHearthomeCity_StartRivalBattleChimchar
    GoTo Route209GateToHearthomeCity_StartRivalBattlePiplup
    End

Route209GateToHearthomeCity_StartRivalBattlePiplup:
    StartTrainerBattle TRAINER_RIVAL_ROUTE_209_PIPLUP
    GoTo Route209GateToHearthomeCity_PostRivalBattle
    End

Route209GateToHearthomeCity_StartRivalBattleTurtwig:
    StartTrainerBattle TRAINER_RIVAL_ROUTE_209_TURTWIG
    GoTo Route209GateToHearthomeCity_PostRivalBattle
    End

Route209GateToHearthomeCity_StartRivalBattleChimchar:
    StartTrainerBattle TRAINER_RIVAL_ROUTE_209_CHIMCHAR
    GoTo Route209GateToHearthomeCity_PostRivalBattle
    End

Route209GateToHearthomeCity_PostRivalBattle:
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route209GateToHearthomeCity_BlackOut
    BufferRivalName 0
    BufferPlayerName 1
    Message Route209GateToHearthomeCity_Text_MyStrategyDoesntWork
    CloseMessage
    @ Sovereign (E10, Renegade's Pokémon Mansion siege): a maid from the Pokémon Mansion runs in for help, and Barry
    @ heads off to Route 212 instead of Route 209. The siege starts (VAR_SOVEREIGN_MANSION_SIEGE_STATE 1).
    RemoveObject LOCALID_SOVEREIGN_MAID
    SetObjectEventPos LOCALID_SOVEREIGN_MAID, 1, 7
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    AddObject LOCALID_SOVEREIGN_MAID
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    LockObject LOCALID_SOVEREIGN_MAID
    Message Route209GateToHearthomeCity_Text_SovereignMaidHelp
    WaitButton
    CloseMessage
    ApplyMovement LOCALID_PLAYER, Route209GateToHearthomeCity_SovereignMovement_Notice
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_SovereignMovement_Notice
    WaitMovement
    ApplyMovement LOCALID_PLAYER, Route209GateToHearthomeCity_SovereignMovement_FaceWest
    WaitMovement
    Message Route209GateToHearthomeCity_Text_SovereignMaidThugs
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_MAID, Route209GateToHearthomeCity_SovereignMovement_FaceWest
    WaitMovement
    Message Route209GateToHearthomeCity_Text_SovereignMaidInformEveryone
    CloseMessage
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_SOVEREIGN_MAID
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_PLAYER, Route209GateToHearthomeCity_SovereignMovement_FaceEast
    WaitMovement
    BufferRivalName 0
    Message Route209GateToHearthomeCity_Text_SovereignRivalHelpTheLady
    CloseMessage
    SetVar VAR_SOVEREIGN_MANSION_SIEGE_STATE, 1
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8005, 5, Route209GateToHearthomeCity_RivalLeaveZ5
    CallIfEq VAR_0x8005, 6, Route209GateToHearthomeCity_RivalLeaveZ6
    CallIfEq VAR_0x8005, 7, Route209GateToHearthomeCity_RivalLeaveZ7
    CallIfEq VAR_0x8005, 8, Route209GateToHearthomeCity_RivalLeaveZ8
    CallIfEq VAR_0x8005, 9, Route209GateToHearthomeCity_RivalLeaveZ9
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_RIVAL
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    SetVar VAR_ROUTE_209_GATE_TO_HEARTHOME_CITY_STATE, 2
    ReleaseAll
    End

Route209GateToHearthomeCity_BlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

Route209GateToHearthomeCity_RivalWalkToPlayerZ5:
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalWalkToPlayerZ5
    WaitMovement
    Return

Route209GateToHearthomeCity_RivalWalkToPlayerZ6:
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalWalkToPlayerZ6
    WaitMovement
    Return

Route209GateToHearthomeCity_RivalWalkToPlayerZ7:
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalWalkToPlayerZ7
    WaitMovement
    Return

Route209GateToHearthomeCity_RivalWalkToPlayerZ8:
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalWalkToPlayerZ8
    WaitMovement
    Return

Route209GateToHearthomeCity_RivalWalkToPlayerZ9:
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalWalkToPlayerZ9
    WaitMovement
    Return

Route209GateToHearthomeCity_RivalLeaveZ5:
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalLeaveZ5
    WaitMovement
    Return

Route209GateToHearthomeCity_RivalLeaveZ6:
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalLeaveZ6
    WaitMovement
    Return

Route209GateToHearthomeCity_RivalLeaveZ7:
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalLeaveZ7
    WaitMovement
    Return

Route209GateToHearthomeCity_RivalLeaveZ8:
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalLeaveZ8
    WaitMovement
    Return

Route209GateToHearthomeCity_RivalLeaveZ9:
    ApplyMovement LOCALID_RIVAL, Route209GateToHearthomeCity_Movement_RivalLeaveZ9
    WaitMovement
    Return

    .balign 4, 0
Route209GateToHearthomeCity_Movement_Unused:
    WalkFastWest 4
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalWalkToPlayerZ5:
    WalkFastWest 2
    WalkFastNorth 2
    WalkOnSpotFastWest
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalWalkToPlayerZ6:
    WalkFastWest 2
    WalkFastNorth
    WalkOnSpotFastWest
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalWalkToPlayerZ7:
    WalkFastWest 2
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalWalkToPlayerZ8:
    WalkFastWest 2
    WalkFastSouth
    WalkOnSpotFastWest
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalWalkToPlayerZ9:
    WalkFastWest 2
    WalkFastSouth 2
    WalkOnSpotFastWest
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalLeaveZ5:
    WalkFastSouth 2
    WalkFastWest 5
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalLeaveZ6:
    WalkFastSouth
    WalkFastWest 5
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalLeaveZ7:
    WalkFastNorth
    WalkFastWest 2
    WalkFastSouth
    WalkFastWest 3
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalLeaveZ8:
    WalkFastNorth
    WalkFastWest 5
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalLeaveZ9:
    WalkFastNorth 2
    WalkFastWest 5
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_Movement_RivalNoticePlayer:
    Delay8
    EmoteExclamationMark
    Delay8
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_SovereignMovement_Notice:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_SovereignMovement_FaceWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
Route209GateToHearthomeCity_SovereignMovement_FaceEast:
    WalkOnSpotNormalEast
    EndMovement
