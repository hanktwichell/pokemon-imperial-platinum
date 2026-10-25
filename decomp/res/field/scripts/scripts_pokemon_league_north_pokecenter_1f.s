#include "macros/scrcmd.inc"
#include "res/text/bank/pokemon_league_north_pokecenter_1f.h"
#include "res/field/events/events_pokemon_league_north_pokecenter_1f.h"


    ScriptEntry PokemonLeagueNorthPokecenter1F_DoorGuard
    ScriptEntry PokemonLeagueNorthPokecenter1F_VendorCommon
    ScriptEntry PokemonLeagueNorthPokecenter1F_VendorSpecial
    ScriptEntry PokemonLeagueNorthPokecenter1F_CoordEvent_Rival
    ScriptEntry PokemonLeagueNorthPokecenter1F_OnTransition
    ScriptEntry PokemonLeagueNorthPokecenter1F_AceTrainerF
    ScriptEntry PokemonLeagueNorthPokecenter1F_Guitarist
    ScriptEntry PokemonLeagueNorthPokecenter1F_Nurse
    ScriptEntry PokemonLeagueNorthPokecenter1F_SovereignTMCollector
    ScriptEntryEnd

PokemonLeagueNorthPokecenter1F_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_POKEMON_LEAGUE
    SetFlag FLAG_HIDE_POKEMON_LEAGUE_AARON_ROOM_ENTRANCE_DOOR
    SetFlag FLAG_HIDE_POKEMON_LEAGUE_BERTHA_ROOM_ENTRANCE_DOOR
    SetFlag FLAG_HIDE_POKEMON_LEAGUE_FLINT_ROOM_ENTRANCE_DOOR
    SetFlag FLAG_HIDE_POKEMON_LEAGUE_LUCIAN_ROOM_ENTRANCE_DOOR
    ClearFlag FLAG_HIDE_POKEMON_LEAGUE_AARON_ROOM_EXIT_DOOR
    ClearFlag FLAG_HIDE_POKEMON_LEAGUE_BERTHA_ROOM_EXIT_DOOR
    ClearFlag FLAG_HIDE_POKEMON_LEAGUE_FLINT_ROOM_EXIT_DOOR
    ClearFlag FLAG_HIDE_POKEMON_LEAGUE_LUCIAN_ROOM_EXIT_DOOR
    ClearFlag FLAG_DEFEATED_AARON
    ClearFlag FLAG_DEFEATED_BERTHA
    ClearFlag FLAG_DEFEATED_FLINT
    ClearFlag FLAG_DEFEATED_LUCIAN
    Call PokemonLeagueNorthPokecenter1F_SovereignCheckRematchLocked
    GoToIfEq VAR_RESULT, TRUE, PokemonLeagueNorthPokecenter1F_SovereignDoorGuardStays
    GoToIfSet FLAG_POKEMON_LEAGUE_DOOR_GUARD_MOVED_AWAY, PokemonLeagueNorthPokecenter1F_SetPositionDoorGuardAwayFromDoor
PokemonLeagueNorthPokecenter1F_SovereignDoorGuardStays:
    End

PokemonLeagueNorthPokecenter1F_SetPositionDoorGuardAwayFromDoor:
    SetObjectEventPos LOCALID_LEAGUE_NORTH_DOOR_GUARD, 12, 3
    End

PokemonLeagueNorthPokecenter1F_DoorGuard:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Call PokemonLeagueNorthPokecenter1F_SovereignCheckRematchLocked
    GoToIfEq VAR_RESULT, TRUE, PokemonLeagueNorthPokecenter1F_SovereignRematchLocked
    GoToIfSet FLAG_POKEMON_LEAGUE_DOOR_GUARD_MOVED_AWAY, PokemonLeagueNorthPokecenter1F_DoorGuardAfterMovingAway
    Message PokemonLeagueNorthPokecenter1F_Text_ExamineGymBadges
    CloseMessage
    PlayFanfare SEQ_BADGE_sseq
    WaitFanfare
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_NORTH, PokemonLeagueNorthPokecenter1F_DoorGuardMoveAwayEastSouth
    GoToIfEq VAR_RESULT, DIR_WEST, PokemonLeagueNorthPokecenter1F_DoorGuardMoveAwayWest
    GoToIfEq VAR_RESULT, DIR_EAST, PokemonLeagueNorthPokecenter1F_DoorGuardMoveAwayEastWest
    End

PokemonLeagueNorthPokecenter1F_DoorGuardMoveAwayEastSouth:
    ApplyMovement LOCALID_LEAGUE_NORTH_DOOR_GUARD, PokemonLeagueNorthPokecenter1F_Movement_DoorGuardMoveAwayEastSouth
    WaitMovement
    GoTo PokemonLeagueNorthPokecenter1F_DoorGuardMovedAway

PokemonLeagueNorthPokecenter1F_DoorGuardMoveAwayWest:
    ApplyMovement LOCALID_LEAGUE_NORTH_DOOR_GUARD, PokemonLeagueNorthPokecenter1F_Movement_DoorGuardMoveAwayWest
    WaitMovement
    GoTo PokemonLeagueNorthPokecenter1F_DoorGuardMovedAway

PokemonLeagueNorthPokecenter1F_DoorGuardMoveAwayEastWest:
    ApplyMovement LOCALID_LEAGUE_NORTH_DOOR_GUARD, PokemonLeagueNorthPokecenter1F_Movement_DoorGuardMoveAwayEastWest
    WaitMovement
    GoTo PokemonLeagueNorthPokecenter1F_DoorGuardMovedAway

PokemonLeagueNorthPokecenter1F_DoorGuardMovedAway:
    SetFlag FLAG_POKEMON_LEAGUE_DOOR_GUARD_MOVED_AWAY
    Message PokemonLeagueNorthPokecenter1F_Text_CollectedAllGymBadges
    WaitButton
    CloseMessage
    ReleaseAll
    End

@ Sovereign (Story.md): after the first Hall of Fame, the Elite Four rematch waits until the DIALGA and PALKIA
@ encounters at the Spear Pillar are both done (caught, or the battle won or fled). Their state vars reset at each Hall
@ of Fame while uncaught, so the first pass is kept in FLAG_SOVEREIGN_REMATCH_UNLOCKED. VAR_RESULT: TRUE while locked.
PokemonLeagueNorthPokecenter1F_SovereignCheckRematchLocked:
    SetVar VAR_RESULT, FALSE
    GoToIfUnset FLAG_GAME_COMPLETED, PokemonLeagueNorthPokecenter1F_SovereignCheckRematchLockedEnd
    GoToIfSet FLAG_SOVEREIGN_REMATCH_UNLOCKED, PokemonLeagueNorthPokecenter1F_SovereignCheckRematchLockedEnd
    SetVar VAR_RESULT, TRUE
    GoToIfSet FLAG_CAUGHT_DIALGA, PokemonLeagueNorthPokecenter1F_SovereignCheckPalkia
    GoToIfLt VAR_SPEAR_PILLAR_DIALGA_STATE, 1, PokemonLeagueNorthPokecenter1F_SovereignCheckRematchLockedEnd
PokemonLeagueNorthPokecenter1F_SovereignCheckPalkia:
    GoToIfSet FLAG_CAUGHT_PALKIA, PokemonLeagueNorthPokecenter1F_SovereignRematchUnlocked
    GoToIfLt VAR_SPEAR_PILLAR_PALKIA_STATE, 1, PokemonLeagueNorthPokecenter1F_SovereignCheckRematchLockedEnd
PokemonLeagueNorthPokecenter1F_SovereignRematchUnlocked:
    SetFlag FLAG_SOVEREIGN_REMATCH_UNLOCKED
    SetVar VAR_RESULT, FALSE
PokemonLeagueNorthPokecenter1F_SovereignCheckRematchLockedEnd:
    Return

PokemonLeagueNorthPokecenter1F_SovereignRematchLocked:
    Message PokemonLeagueNorthPokecenter1F_Text_SovereignSpearPillarFirst
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeagueNorthPokecenter1F_DoorGuardAfterMovingAway:
    Message PokemonLeagueNorthPokecenter1F_Text_YouWillFaceTheEliteFour
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
PokemonLeagueNorthPokecenter1F_Movement_DoorGuardMoveAwayEastSouth:
    WalkNormalEast
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
PokemonLeagueNorthPokecenter1F_Movement_DoorGuardMoveAwayWest:
    WalkNormalWest
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
PokemonLeagueNorthPokecenter1F_Movement_DoorGuardMoveAwayEastWest:
    WalkNormalEast
    WalkOnSpotNormalWest
    EndMovement

PokemonLeagueNorthPokecenter1F_VendorCommon:
    PokeMartCommonWithGreeting
    End

PokemonLeagueNorthPokecenter1F_VendorSpecial:
    PokeMartSpecialtiesWithGreeting MART_SPECIALTIES_ID_POKEMON_LEAGUE
    End

PokemonLeagueNorthPokecenter1F_CoordEvent_Rival:
    LockAll
    ClearFlag FLAG_HIDE_POKEMON_LEAGUE_NORTH_POKECENTER_1F_RIVAL
    AddObject LOCALID_LEAGUE_NORTH_RIVAL
    Common_SetRivalBGM
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8004, 10, PokemonLeagueNorthPokecenter1F_RivalEnterWest
    GoToIfEq VAR_0x8004, 11, PokemonLeagueNorthPokecenter1F_RivalEnterNorth
    GoToIfEq VAR_0x8004, 12, PokemonLeagueNorthPokecenter1F_RivalEnterEast
    End

PokemonLeagueNorthPokecenter1F_RivalEnterWest:
    ApplyMovement LOCALID_LEAGUE_NORTH_RIVAL, PokemonLeagueNorthPokecenter1F_Movement_RivalEnterWest
    WaitMovement
    GoTo PokemonLeagueNorthPokecenter1F_RivalIntro

PokemonLeagueNorthPokecenter1F_RivalEnterNorth:
    ApplyMovement LOCALID_LEAGUE_NORTH_RIVAL, PokemonLeagueNorthPokecenter1F_Movement_RivalEnterNorth
    WaitMovement
    GoTo PokemonLeagueNorthPokecenter1F_RivalIntro

PokemonLeagueNorthPokecenter1F_RivalEnterEast:
    ApplyMovement LOCALID_LEAGUE_NORTH_RIVAL, PokemonLeagueNorthPokecenter1F_Movement_RivalEnterEast
    WaitMovement
    GoTo PokemonLeagueNorthPokecenter1F_RivalIntro

PokemonLeagueNorthPokecenter1F_RivalIntro:
    ApplyMovement LOCALID_PLAYER, PokemonLeagueNorthPokecenter1F_Movement_PlayerFaceRival
    WaitMovement
    BufferRivalName 0
    Message PokemonLeagueNorthPokecenter1F_Text_RivalIntro
    CloseMessage
    GetPlayerStarterSpecies VAR_RESULT
    GoToIfEq VAR_RESULT, SPECIES_TURTWIG, PokemonLeagueNorthPokecenter1F_StartRivalTurtwigBattle
    GoToIfEq VAR_RESULT, SPECIES_CHIMCHAR, PokemonLeagueNorthPokecenter1F_StartRivalChimcharBattle
    GoTo PokemonLeagueNorthPokecenter1F_StartRivalPiplupBattle

PokemonLeagueNorthPokecenter1F_StartRivalPiplupBattle:
    StartTrainerBattle TRAINER_RIVAL_POKEMON_LEAGUE_PIPLUP
    GoTo PokemonLeagueNorthPokecenter1F_RivalPostBattle

PokemonLeagueNorthPokecenter1F_StartRivalTurtwigBattle:
    StartTrainerBattle TRAINER_RIVAL_POKEMON_LEAGUE_TURTWIG
    GoTo PokemonLeagueNorthPokecenter1F_RivalPostBattle

PokemonLeagueNorthPokecenter1F_StartRivalChimcharBattle:
    StartTrainerBattle TRAINER_RIVAL_POKEMON_LEAGUE_CHIMCHAR
    GoTo PokemonLeagueNorthPokecenter1F_RivalPostBattle

PokemonLeagueNorthPokecenter1F_RivalPostBattle:
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonLeagueNorthPokecenter1F_BlackOutFromRivalBattle
    BufferRivalName 0
    BufferPlayerName 1
    Message PokemonLeagueNorthPokecenter1F_Text_RivalDefeat
    CloseMessage
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8004, 10, PokemonLeagueNorthPokecenter1F_RivalLeaveEast
    GoToIfEq VAR_0x8004, 11, PokemonLeagueNorthPokecenter1F_RivalLeaveSouth
    GoToIfEq VAR_0x8004, 12, PokemonLeagueNorthPokecenter1F_RivalLeaveWest
    End

PokemonLeagueNorthPokecenter1F_RivalLeaveEast:
    ApplyMovement LOCALID_LEAGUE_NORTH_RIVAL, PokemonLeagueNorthPokecenter1F_Movement_RivalLeaveEast
    WaitMovement
    GoTo PokemonLeagueNorthPokecenter1F_RemoveRival

PokemonLeagueNorthPokecenter1F_RivalLeaveSouth:
    ApplyMovement LOCALID_LEAGUE_NORTH_RIVAL, PokemonLeagueNorthPokecenter1F_Movement_RivalLeaveSouth
    WaitMovement
    GoTo PokemonLeagueNorthPokecenter1F_RemoveRival

PokemonLeagueNorthPokecenter1F_RivalLeaveWest:
    ApplyMovement LOCALID_LEAGUE_NORTH_RIVAL, PokemonLeagueNorthPokecenter1F_Movement_RivalLeaveWest
    WaitMovement
    GoTo PokemonLeagueNorthPokecenter1F_RemoveRival

PokemonLeagueNorthPokecenter1F_RemoveRival:
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_LEAGUE_NORTH_RIVAL
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    SetVar VAR_RIVAL_BEAT_SUNYSHORE_GYM, 1
    ReleaseAll
    End

PokemonLeagueNorthPokecenter1F_BlackOutFromRivalBattle:
    SetFlag FLAG_HIDE_POKEMON_LEAGUE_NORTH_POKECENTER_1F_RIVAL
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
PokemonLeagueNorthPokecenter1F_Movement_PlayerFaceRival:
    WalkOnSpotFastSouth
    EndMovement

    .balign 4, 0
PokemonLeagueNorthPokecenter1F_Movement_RivalEnterWest:
    WalkFastNorth 3
    WalkFastWest
    WalkFastNorth 3
    EndMovement

    .balign 4, 0
PokemonLeagueNorthPokecenter1F_Movement_RivalEnterNorth:
    WalkFastNorth 6
    EndMovement

    .balign 4, 0
PokemonLeagueNorthPokecenter1F_Movement_RivalEnterEast:
    WalkFastNorth 3
    WalkFastEast
    WalkFastNorth 3
    EndMovement

    .balign 4, 0
PokemonLeagueNorthPokecenter1F_Movement_RivalLeaveEast:
    WalkFastSouth 3
    WalkFastEast
    WalkFastSouth 3
    EndMovement

    .balign 4, 0
PokemonLeagueNorthPokecenter1F_Movement_RivalLeaveSouth:
    WalkFastSouth 6
    EndMovement

    .balign 4, 0
PokemonLeagueNorthPokecenter1F_Movement_RivalLeaveWest:
    WalkFastSouth 3
    WalkFastWest
    WalkFastSouth 3
    EndMovement

PokemonLeagueNorthPokecenter1F_AceTrainerF:
    NPCMessage PokemonLeagueNorthPokecenter1F_Text_ImNeverGivingUp
    End

PokemonLeagueNorthPokecenter1F_Guitarist:
    NPCMessage PokemonLeagueNorthPokecenter1F_Text_ExperienceItForYourself
    End

PokemonLeagueNorthPokecenter1F_Nurse:
    Common_CallPokecenterNurse LOCALID_LEAGUE_NORTH_NURSE
    End

@ Sovereign (E10, Renegade): the TM collector tops every TM up to 99, after a Yes. A TM always fits the bag and comes
@ as 99 of it (E10 part 2), so adding one of each TM is enough.
PokemonLeagueNorthPokecenter1F_SovereignTMCollector:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message PokemonLeagueNorthPokecenter1F_Text_SovereignTMCollectorAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, PokemonLeagueNorthPokecenter1F_SovereignTMCollectorEnd
    Message PokemonLeagueNorthPokecenter1F_Text_SovereignTMCollectorYes
    WaitButton
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SetVar VAR_0x8004, ITEM_TM01
PokemonLeagueNorthPokecenter1F_SovereignTMCollectorLoop:
    AddItem VAR_0x8004, 1, VAR_RESULT
    AddVar VAR_0x8004, 1
    GoToIfLe VAR_0x8004, ITEM_TM92, PokemonLeagueNorthPokecenter1F_SovereignTMCollectorLoop
    PlayFanfare SEQ_WAZA_sseq
    WaitFanfare
    FadeScreenIn
    WaitFadeScreen
PokemonLeagueNorthPokecenter1F_SovereignTMCollectorEnd:
    Message PokemonLeagueNorthPokecenter1F_Text_SovereignTMCollectorNo
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
