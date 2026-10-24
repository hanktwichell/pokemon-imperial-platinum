#include "macros/scrcmd.inc"
#include "res/field/events/events_route_212_north.h"
#include "res/text/bank/route_212_north.h"


    ScriptEntry Route212North_Youngster
    ScriptEntry Route212North_ArrowSignpostHearthomeCity
    ScriptEntry Route212North_SignboardPokemonMansion
    ScriptEntry Route212North_TrainerTipsSignpost
    ScriptEntry Route212North_Collector
    ScriptEntry Route212North_PolicemanBobby
    ScriptEntry Route212North_PolicemanAlex
    ScriptEntry Route212North_PolicemanDylan
    ScriptEntry Route212North_PolicemanCaleb
    ScriptEntry Route212North_OnTransition
    ScriptEntry Route212North_SovereignOnLoad
    ScriptEntry Route212North_LegendaryWoChien
    ScriptEntry Route212North_SovereignStake1
    ScriptEntry Route212North_SovereignStake2
    ScriptEntry Route212North_SovereignGrunt1
    ScriptEntry Route212North_SovereignGrunt2
    ScriptEntry Route212North_SovereignGrunt3
    ScriptEntry Route212North_SovereignCoordEvent_GateGrunts
    ScriptEntry Route212North_SovereignCoordEvent_Rival
    ScriptEntryEnd

Route212North_OnTransition:
    Call Route212North_SovereignSetSiegeVisibility
    Call Route212North_SovereignSetStake2Visibility
    Call Route212North_SovereignSetStake1Visibility
    Call Route212North_SovereignSetWoChienVisibility
    GetTimeOfDay VAR_MAP_LOCAL_0x00
    GoToIfInRange VAR_MAP_LOCAL_0x00, TIMEOFDAY_MORNING, TIMEOFDAY_TWILIGHT, Route212North_SetPolicemenNoBattle
    GoToIfInRange VAR_MAP_LOCAL_0x00, TIMEOFDAY_NIGHT, TIMEOFDAY_LATE_NIGHT, Route212North_SetPolicemenBattle
    End

Route212North_SetPolicemenNoBattle:
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_BOBBY_NO_BATTLE
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_ALEX_NO_BATTLE
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_DYLAN_NO_BATTLE
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_CALEB_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_BOBBY
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_ALEX
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_DYLAN
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_CALEB
    End

Route212North_SetPolicemenBattle:
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_BOBBY
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_ALEX
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_DYLAN
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_CALEB
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_BOBBY_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_ALEX_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_DYLAN_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_CALEB_NO_BATTLE
    End

Route212North_Youngster:
    NPCMessage Route212North_Text_MrBacklotLikesVisitors
    End

Route212North_ArrowSignpostHearthomeCity:
    ShowArrowSign Route212North_Text_SignHearthomeCity
    End

Route212North_SignboardPokemonMansion:
    ShowLandmarkSign Route212North_Text_SignPokemonMansion
    End

Route212North_TrainerTipsSignpost:
    ShowScrollingSign Route212North_Text_TrainerTipsReorganizeItems
    End

Route212North_Collector:
    NPCMessage Route212North_Text_FindAttractiveTree
    End

Route212North_PolicemanBobby:
    NPCMessage Route212North_Text_SayHiToPolicemen
    End

Route212North_PolicemanAlex:
    NPCMessage Route212North_Text_PatrolsDayAndNight
    End

Route212North_PolicemanDylan:
    NPCMessage Route212North_Text_WorkingHard
    End

Route212North_PolicemanCaleb:
    NPCMessage Route212North_Text_PatrolTooMuch
    End

    .balign 4, 0

Route212North_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route212North_RemoveLegendaryWoChien
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): one of the Treasures of Ruin, unsealed once both its stakes
@ on this map are pulled out (FLAG_SOVEREIGN_PULLED_STAKE_1 and _2), until it is caught.
Route212North_SovereignSetWoChienVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route212North_SovereignSetWoChienVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_PULLED_STAKE_1, Route212North_SovereignSetWoChienVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_PULLED_STAKE_2, Route212North_SovereignSetWoChienVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_WO_CHIEN, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route212North_SovereignSetWoChienVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route212North_SovereignSetWoChienVisibilityEnd:
    Return

Route212North_RemoveLegendaryWoChien:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_WO_CHIEN, Route212North_RemoveLegendaryWoChienEnd
    RemoveObject LOCALID_LEGENDARY_WO_CHIEN
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route212North_RemoveLegendaryWoChienEnd:
    Return

Route212North_LegendaryWoChien:
    SetVar VAR_0x8004, SPECIES_WO_CHIEN
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, the Treasures of Ruin): stake 1 of the two that seal WoChien's shrine here, shown once the
@ Paldea Chronicle is open until it's pulled out (FLAG_SOVEREIGN_PULLED_STAKE_1).
Route212North_SovereignSetStake1Visibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route212North_SovereignSetStake1VisibilityEnd
    GoToIfSet FLAG_SOVEREIGN_PULLED_STAKE_1, Route212North_SovereignSetStake1VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
Route212North_SovereignSetStake1VisibilityEnd:
    Return

Route212North_SovereignStake1:
    SetVar VAR_0x8004, FLAG_SOVEREIGN_PULLED_STAKE_1
    SetVar VAR_0x8005, LOCALID_SOVEREIGN_STAKE_1
    Common_SovereignStake
    GoToIfEq VAR_RESULT, FALSE, Route212North_SovereignStake1End
    Call Route212North_SovereignSetWoChienVisibility
    GoToIfSet FLAG_MAP_LOCAL_HIDE_LEGENDARY, Route212North_SovereignStake1End
    AddObject LOCALID_LEGENDARY_WO_CHIEN
Route212North_SovereignStake1End:
    End

@ Sovereign (the Chronicles, the Treasures of Ruin): stake 2 of the two that seal WoChien's shrine here, shown once the
@ Paldea Chronicle is open until it's pulled out (FLAG_SOVEREIGN_PULLED_STAKE_2).
Route212North_SovereignSetStake2Visibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route212North_SovereignSetStake2VisibilityEnd
    GoToIfSet FLAG_SOVEREIGN_PULLED_STAKE_2, Route212North_SovereignSetStake2VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
Route212North_SovereignSetStake2VisibilityEnd:
    Return

Route212North_SovereignStake2:
    SetVar VAR_0x8004, FLAG_SOVEREIGN_PULLED_STAKE_2
    SetVar VAR_0x8005, LOCALID_SOVEREIGN_STAKE_2
    Common_SovereignStake
    GoToIfEq VAR_RESULT, FALSE, Route212North_SovereignStake2End
    Call Route212North_SovereignSetWoChienVisibility
    GoToIfSet FLAG_MAP_LOCAL_HIDE_LEGENDARY, Route212North_SovereignStake2End
    AddObject LOCALID_LEGENDARY_WO_CHIEN
Route212North_SovereignStake2End:
    End

@ Sovereign (E10, Renegade's Pokémon Mansion siege): Team Galactic holds the Pokémon Mansion from Barry's battle in
@ the Route 209 gate until Saturn is beaten inside (VAR_SOVEREIGN_MANSION_SIEGE_STATE 1-5). Meanwhile three grunts
@ stand on the route (Renegade's trainers 947-949), two more guard the Mansion's door (950, 951), and the visitors
@ stay away.
Route212North_SovereignSetSiegeVisibility:
    SetFlag FLAG_MAP_LOCAL_0x01
    SetFlag FLAG_MAP_LOCAL_0x02
    GoToIfEq VAR_SOVEREIGN_MANSION_SIEGE_STATE, 0, Route212North_SovereignSetSiegeVisibilityEnd
    GoToIfGe VAR_SOVEREIGN_MANSION_SIEGE_STATE, 6, Route212North_SovereignSetSiegeVisibilityEnd
    SetFlag FLAG_MAP_LOCAL_0x03
    ClearFlag FLAG_MAP_LOCAL_0x01
    GoToIfNe VAR_SOVEREIGN_MANSION_SIEGE_STATE, 1, Route212North_SovereignSetSiegeVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_0x02
Route212North_SovereignSetSiegeVisibilityEnd:
    Return

Route212North_SovereignGrunt1:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_GRUNT_ROUTE_212_1, Route212North_SovereignGrunt1After
    PlayTrainerEncounterBGM TRAINER_SOVEREIGN_GRUNT_ROUTE_212_1
    Message Route212North_Text_SovereignGrunt1Intro
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_ROUTE_212_1
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route212North_SovereignSiegeLost
    SetTrainerFlag TRAINER_SOVEREIGN_GRUNT_ROUTE_212_1
    ReleaseAll
    End

Route212North_SovereignGrunt1After:
    Message Route212North_Text_SovereignGrunt1After
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route212North_SovereignGrunt2:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_GRUNT_ROUTE_212_2, Route212North_SovereignGrunt2After
    PlayTrainerEncounterBGM TRAINER_SOVEREIGN_GRUNT_ROUTE_212_2
    Message Route212North_Text_SovereignGrunt2Intro
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_ROUTE_212_2
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route212North_SovereignSiegeLost
    SetTrainerFlag TRAINER_SOVEREIGN_GRUNT_ROUTE_212_2
    ReleaseAll
    End

Route212North_SovereignGrunt2After:
    Message Route212North_Text_SovereignGrunt2After
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route212North_SovereignGrunt3:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_GRUNT_ROUTE_212_3, Route212North_SovereignGrunt3After
    PlayTrainerEncounterBGM TRAINER_SOVEREIGN_GRUNT_ROUTE_212_3
    Message Route212North_Text_SovereignGrunt3Intro
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_ROUTE_212_3
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route212North_SovereignSiegeLost
    SetTrainerFlag TRAINER_SOVEREIGN_GRUNT_ROUTE_212_3
    ReleaseAll
    End

Route212North_SovereignGrunt3After:
    Message Route212North_Text_SovereignGrunt3After
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route212North_SovereignSiegeLost:
    BlackOutFromBattle
    ReleaseAll
    End

@ The two grunts at the Mansion's door battle together (a double battle). Like every Team Galactic encounter, they
@ wait on the Totem trial before them (docs/Story.md): Mimikyu's, at the Old Chateau.
Route212North_SovereignCoordEvent_GateGrunts:
    LockAll
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_1, Route212North_SovereignMovement_Notice
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_2, Route212North_SovereignMovement_Notice
    WaitMovement
    GoToIfUnset FLAG_SOVEREIGN_TOTEM_TRIAL_MIMIKYU, Route212North_SovereignGateGruntsWaitOnTotem
    PlayTrainerEncounterBGM TRAINER_SOVEREIGN_GRUNT_MANSION_GATE_1
    BufferPlayerName 0
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_1, Route212North_SovereignMovement_Stomp
    WaitMovement
    Message Route212North_Text_SovereignGateGrunt1
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_2, Route212North_SovereignMovement_Stomp
    WaitMovement
    Message Route212North_Text_SovereignGateGrunt2
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_1, Route212North_SovereignMovement_Stomp
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_2, Route212North_SovereignMovement_Stomp
    WaitMovement
    Message Route212North_Text_SovereignGateGruntsBegone
    WaitButton
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_MANSION_GATE_1, TRAINER_SOVEREIGN_GRUNT_MANSION_GATE_2
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route212North_SovereignSiegeLost
    SetVar VAR_SOVEREIGN_MANSION_SIEGE_STATE, 2
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_1, Route212North_SovereignMovement_FaceEast
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_2, Route212North_SovereignMovement_FaceWest
    WaitMovement
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_1, Route212North_SovereignMovement_Grunt1Panic
    WaitMovement
    Message Route212North_Text_SovereignGateGrunt1Lost
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_2, Route212North_SovereignMovement_Grunt2Panic
    WaitMovement
    Message Route212North_Text_SovereignGateGrunt2Lost
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_1, Route212North_SovereignMovement_RunToMansion
    ApplyMovement LOCALID_SOVEREIGN_GATE_GRUNT_2, Route212North_SovereignMovement_RunToMansion
    WaitMovement
    RemoveObject LOCALID_SOVEREIGN_GATE_GRUNT_1
    RemoveObject LOCALID_SOVEREIGN_GATE_GRUNT_2
    ReleaseAll
    End

Route212North_SovereignGateGruntsWaitOnTotem:
    Message Route212North_Text_SovereignGateGruntsMimikyu
    WaitButton
    CloseMessage
    ApplyMovement LOCALID_PLAYER, Route212North_SovereignMovement_StepBack
    WaitMovement
    ReleaseAll
    End

@ Barry catches up with the player on the way to the Mansion's door, then runs in ahead.
Route212North_SovereignCoordEvent_Rival:
    LockAll
    BufferRivalName 0
    BufferPlayerName 1
    Message Route212North_Text_SovereignRivalYo
    WaitButton
    CloseMessage
    Common_SetRivalBGM
    ApplyMovement LOCALID_PLAYER, Route212North_SovereignMovement_FaceSouth
    WaitMovement
    RemoveObject LOCALID_SOVEREIGN_RIVAL
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    SetObjectEventPos LOCALID_SOVEREIGN_RIVAL, VAR_0x8004, 806
    AddObject LOCALID_SOVEREIGN_RIVAL
    LockObject LOCALID_SOVEREIGN_RIVAL
    ApplyMovement LOCALID_SOVEREIGN_RIVAL, Route212North_SovereignMovement_RivalArrive
    WaitMovement
    BufferRivalName 0
    Message Route212North_Text_SovereignRivalEasyGoons
    CloseMessage
    GoToIfEq VAR_0x8004, 471, Route212North_SovereignRivalLeaveWest
    ApplyMovement LOCALID_SOVEREIGN_RIVAL, Route212North_SovereignMovement_RivalLeaveEast
    WaitMovement
    GoTo Route212North_SovereignRivalLeft

Route212North_SovereignRivalLeaveWest:
    ApplyMovement LOCALID_SOVEREIGN_RIVAL, Route212North_SovereignMovement_RivalLeaveWest
    WaitMovement
Route212North_SovereignRivalLeft:
    Common_FadeToDefaultMusic
    SetVar VAR_SOVEREIGN_MANSION_SIEGE_STATE, 3
    RemoveObject LOCALID_SOVEREIGN_RIVAL
    ReleaseAll
    End

    .balign 4, 0
Route212North_SovereignMovement_Notice:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_Stomp:
    WalkOnSpotFastSouth 4
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_FaceEast:
    WalkOnSpotFastEast
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_FaceWest:
    WalkOnSpotFastWest
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_Grunt1Panic:
    WalkOnSpotFastEast 4
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_Grunt2Panic:
    WalkOnSpotFastWest 4
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_RunToMansion:
    WalkFastNorth 7
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_StepBack:
    WalkNormalSouth
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_FaceSouth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_RivalArrive:
    WalkFastNorth 7
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_RivalLeaveEast:
    WalkFastEast
    WalkFastNorth 10
    EndMovement

    .balign 4, 0
Route212North_SovereignMovement_RivalLeaveWest:
    WalkFastWest
    WalkFastNorth 10
    EndMovement

    .balign 4, 0
