#include "macros/scrcmd.inc"
#include "res/text/bank/eterna_forest.h"
#include "res/field/events/events_eterna_forest.h"
#include "constants/sovereign_totem_trials.h"

    ScriptEntry EternaForest_CoordEvent_CherylStartFollowing
    ScriptEntry EternaForest_CoordEvent_PlayerLeaveCheryl
    ScriptEntry EternaForest_CoordEvent_CherylLeavePlayer
    ScriptEntry EternaForest_Dummy4
    ScriptEntry EternaForest_Dummy5
    ScriptEntry EternaForest_BugCatcher
    ScriptEntry EternaForest_Gardenia
    ScriptEntry EternaForest_SignboardEternaForest
    ScriptEntry EternaForest_TrainerTipsSignpost
    ScriptEntry EternaForest_MossRock
    ScriptEntry EternaForest_OnTransition
    ScriptEntry EternaForest_OnFrame_CherylOldChateauCutscene
    ScriptEntry EternaForest_TotemVikavolt
    ScriptEntry EternaForest_OnLoad
    ScriptEntry EternaForest_LegendaryVirizion
    ScriptEntry EternaForest_LegendaryXerneas
    ScriptEntry EternaForest_SovereignCoordEvent_GSBall
    ScriptEntry EternaForest_SovereignPortal1
    ScriptEntry EternaForest_SovereignPortal2
    ScriptEntry EternaForest_SovereignPortal3
    ScriptEntry EternaForest_SovereignPortal4
    ScriptEntry EternaForest_SovereignPortal5
    ScriptEntry EternaForest_SovereignPortal6
    ScriptEntry EternaForest_SovereignPortal7
    ScriptEntry EternaForest_SovereignPortal8
    ScriptEntry EternaForest_LegendaryCelebi
    ScriptEntryEnd

EternaForest_OnTransition:
    Call EternaForest_SovereignSetVirizionVisibility
    Call EternaForest_SovereignSetXerneasVisibility
    Call EternaForest_SovereignSetPortalVisibility
    GoToIfUnset FLAG_TRAVELED_WITH_CHERYL, EternaForest_ResetFollowerCherylState
    End

@ Sovereign (the Chronicles): Virizion stands here once the Unova Chronicle is open, until it's caught.
EternaForest_SovereignSetVirizionVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 1, EternaForest_SovereignSetVirizionVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_VIRIZION, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, EternaForest_SovereignSetVirizionVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
EternaForest_SovereignSetVirizionVisibilityEnd:
    Return

@ Sovereign (the Chronicles): Xerneas stands in the nook beside the Old Chateau once the Kalos Chronicle is open
@ (VAR_SOVEREIGN_CHRONICLE 2), until it's caught. It has a hidden flag of its own, as Virizion shares the map.
EternaForest_SovereignSetXerneasVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 2, EternaForest_SovereignSetXerneasVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_XERNEAS, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, EternaForest_SovereignSetXerneasVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
EternaForest_SovereignSetXerneasVisibilityEnd:
    Return

EternaForest_ResetFollowerCherylState:
    SetVar VAR_ETERNA_FOREST_FOLLOWER_CHERYL_STATE, 0
    End

EternaForest_OnLoad:
    GoToIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, EternaForest_RemoveTotemVikavolt
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, EternaForest_RemoveLegendary
    End

@ Virizion and Xerneas share the map, so each one's script notes itself in VAR_MAP_LOCAL_0x00: map-local vars last
@ through a battle (they're cleared on map changes), and the special vars aren't readable from OnLoad then.
EternaForest_RemoveLegendary:
    GoToIfEq VAR_MAP_LOCAL_0x00, SPECIES_XERNEAS, EternaForest_RemoveLegendaryXerneas
    GoToIfEq VAR_MAP_LOCAL_0x00, SPECIES_CELEBI, EternaForest_SovereignRemoveLegendaryCelebi
    RemoveObject LOCALID_LEGENDARY_VIRIZION
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

EternaForest_RemoveLegendaryXerneas:
    RemoveObject LOCALID_LEGENDARY_XERNEAS
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

EternaForest_RemoveTotemVikavolt:
    RemoveObject LOCALID_TOTEM_VIKAVOLT
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    End

EternaForest_LegendaryVirizion:
    SetVar VAR_MAP_LOCAL_0x00, SPECIES_VIRIZION
    SetVar VAR_0x8004, SPECIES_VIRIZION
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

EternaForest_LegendaryXerneas:
    SetVar VAR_MAP_LOCAL_0x00, SPECIES_XERNEAS
    SetVar VAR_0x8004, SPECIES_XERNEAS
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (decision 18): the Totem Vikavolt trial. The forest opens after Mars, as the trial does.
EternaForest_TotemVikavolt:
    SetVar VAR_0x8004, TOTEM_TRIAL_VIKAVOLT
    Common_SovereignTotemTrial
    End

EternaForest_CoordEvent_CherylStartFollowing:
    LockAll
    SetPlayerBike FALSE
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8004, 28, EternaForest_CherylNoticeAndWalkToPlayerX28
    GoToIfEq VAR_0x8004, 29, EternaForest_CherylNoticeAndWalkToPlayerX29
    End

EternaForest_CherylNoticeAndWalkToPlayerX28:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylNoticeAndWalkToPlayerX28
    WaitMovement
    GoTo EternaForest_CherylStartFollowing

EternaForest_CherylNoticeAndWalkToPlayerX29:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylNoticeAndWalkToPlayerX29
    WaitMovement
    GoTo EternaForest_CherylStartFollowing

EternaForest_CherylStartFollowing:
    CallIfUnset FLAG_TALKED_TO_ETERNA_FOREST_CHERYL, EternaForest_MayIGoWithYou
    CallIfSet FLAG_TALKED_TO_ETERNA_FOREST_CHERYL, EternaForest_LetsGetThroughForestTogether
    BufferPlayerName 0
    PlayFanfare SEQ_GONIN_sseq
    Message EternaForest_Text_PlayerDecidedToGoWithCheryl
    WaitFanfare
    SetFlag FLAG_TALKED_TO_ETERNA_FOREST_CHERYL
    SetVar VAR_ETERNA_FOREST_FOLLOWER_CHERYL_STATE, 1
    Message EternaForest_Text_IllKeepPokemonHealthy
    WaitButton
    CloseMessage
    SetVar VAR_PARTNER_TRAINER_ID, TRAINER_CHERYL_ETERNA_FOREST
    SetHasPartner
    SetMovementType LOCALID_CHERYL, MOVEMENT_TYPE_FOLLOW_PLAYER
    SetObjectFlagIsPersistent LOCALID_CHERYL, TRUE
    ReleaseAll
    End

EternaForest_MayIGoWithYou:
    BufferPlayerName 0
    Message EternaForest_Text_MayIGoWithYou
    Return

EternaForest_LetsGetThroughForestTogether:
    BufferPlayerName 0
    Message EternaForest_Text_LetsGetThroughForestTogether
    Return

    .balign 4, 0
EternaForest_Movement_CherylNoticeAndWalkToPlayerX28:
    MoveAction_153
    WalkNormalSouth
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylNoticeAndWalkToPlayerX29:
    MoveAction_153
    WalkNormalSouth
    WalkNormalEast
    WalkOnSpotNormalSouth
    EndMovement

EternaForest_CoordEvent_PlayerLeaveCheryl:
    LockAll
    ClearHasPartner
    SetMovementType LOCALID_CHERYL, MOVEMENT_TYPE_LOOK_SOUTH
    SetObjectFlagIsPersistent LOCALID_CHERYL, FALSE
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkOnSpotSouth
    WaitMovement
    Message EternaForest_Text_IllWaitHereForYouThen
    CloseMessage
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8004, 28, EternaForest_CherylWalkBackToOriginalPositionX28
    GoToIfEq VAR_0x8004, 29, EternaForest_CherylWalkBackToOriginalPositionX29
    End

EternaForest_CherylWalkBackToOriginalPositionX28:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkBackToOriginalPositionX28
    WaitMovement
    GoTo EternaForest_ResetFollowerCherylStateAndRelease

EternaForest_CherylWalkBackToOriginalPositionX29:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkBackToOriginalPositionX29
    WaitMovement
    GoTo EternaForest_ResetFollowerCherylStateAndRelease

EternaForest_ResetFollowerCherylStateAndRelease:
    SetVar VAR_ETERNA_FOREST_FOLLOWER_CHERYL_STATE, 0
    ReleaseAll
    End

    .balign 4, 0
EternaForest_Movement_CherylWalkBackToOriginalPositionX28:
    WalkNormalNorth 2
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylWalkBackToOriginalPositionX29:
    WalkNormalNorth 2
    WalkNormalWest
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

EternaForest_CoordEvent_CherylLeavePlayer:
    LockAll
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylExclamationMark
    ApplyMovement LOCALID_PLAYER, EternaForest_Movement_PlayerWalkOnSpotWest
    WaitMovement
    BufferPlayerName 0
    Message EternaForest_Text_ThankYouSoMuch
    // Sovereign (E10): TM27 (Return), as in Renegade Platinum. The Soothe Bell is in a Route 203 item ball and with
    // the Pokémon Mansion's maid.
    SetVar VAR_0x8004, ITEM_TM27
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, EternaForest_CherylWalkToExit
    GoTo EternaForest_GiveSootheBell
    End

EternaForest_GiveSootheBell:
    Message EternaForest_Text_TokenOfAppreciation
    Common_GiveItemQuantityNoLineFeed
    GoTo EternaForest_CherylWalkToExit
    End

EternaForest_CherylWalkToExit:
    CloseMessage
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8005, 34, EternaForest_CherylWalkToExitX34
    GoToIfEq VAR_0x8005, 35, EternaForest_CherylWalkToExitX35
    GoToIfEq VAR_0x8005, 36, EternaForest_CherylWalkToExitX36
    GoToIfEq VAR_0x8005, 37, EternaForest_CherylWalkToExitX37
    GoToIfEq VAR_0x8005, 38, EternaForest_CherylWalkToExitX38
    GoTo EternaForest_CherylWalkToExitX39
    End

EternaForest_CherylWalkToExitX34:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkToExitX34
    ApplyMovement LOCALID_PLAYER, EternaForest_Movement_PlayerWatchCherylWalkToExitX34
    WaitMovement
    GoTo EternaForest_CherylLeave

EternaForest_CherylWalkToExitX35:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkToExitX35
    ApplyMovement LOCALID_PLAYER, EternaForest_Movement_PlayerWatchCherylWalkToExitX35
    WaitMovement
    GoTo EternaForest_CherylLeave

EternaForest_CherylWalkToExitX36:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkToExitX36
    ApplyMovement LOCALID_PLAYER, EternaForest_Movement_PlayerWatchCherylWalkToExitX36
    WaitMovement
    GoTo EternaForest_CherylLeave

EternaForest_CherylWalkToExitX37:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkToExitX37
    ApplyMovement LOCALID_PLAYER, EternaForest_Movement_PlayerWatchCherylWalkToExitX37
    WaitMovement
    GoTo EternaForest_CherylLeave

EternaForest_CherylWalkToExitX38:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkToExitX38
    ApplyMovement LOCALID_PLAYER, EternaForest_Movement_PlayerWatchCherylWalkToExitX38
    WaitMovement
    GoTo EternaForest_CherylLeave

EternaForest_CherylWalkToExitX39:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkToExitX39
    ApplyMovement LOCALID_PLAYER, EternaForest_Movement_PlayerWatchCherylWalkToExitX39
    WaitMovement
    GoTo EternaForest_CherylLeave

EternaForest_CherylLeave:
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkOnSpotWest
    WaitMovement
    Message EternaForest_Text_ImSureWellMeetAgain
    CloseMessage
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylLeave
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    ClearHasPartner
    RemoveObject LOCALID_CHERYL
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    SetFlag FLAG_TRAVELED_WITH_CHERYL
    SetVar VAR_ETERNA_FOREST_FOLLOWER_CHERYL_STATE, 2
    ReleaseAll
    End

    .balign 4, 0
EternaForest_Movement_CherylExclamationMark:
    WalkOnSpotNormalEast
    MoveAction_153
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylWalkToExitX34:
    WalkNormalSouth 2
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylWalkToExitX35:
    WalkNormalSouth
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylWalkToExitX36:
    WalkNormalSouth
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylWalkToExitX37:
    WalkNormalNorth
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylWalkToExitX38:
    WalkNormalNorth
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylWalkToExitX39:
    WalkNormalNorth 2
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylWalkOnSpotWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
EternaForest_Movement_CherylLeave:
    Delay8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
EternaForest_Movement_PlayerWalkOnSpotWest:
    Delay8 3
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
EternaForest_Movement_PlayerWatchCherylWalkToExitX34:
    Delay8 2
    WalkOnSpotNormalSouth
    Delay8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
EternaForest_Movement_PlayerWatchCherylWalkToExitX35:
    Delay8
    WalkOnSpotNormalSouth
    Delay8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
EternaForest_Movement_PlayerWatchCherylWalkToExitX36:
    Delay8
    WalkOnSpotNormalSouth
    Delay8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
EternaForest_Movement_PlayerWatchCherylWalkToExitX37:
    Delay8
    WalkOnSpotNormalNorth
    Delay8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
EternaForest_Movement_PlayerWatchCherylWalkToExitX38:
    Delay8
    WalkOnSpotNormalNorth
    Delay8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
EternaForest_Movement_PlayerWatchCherylWalkToExitX39:
    Delay8 2
    WalkOnSpotNormalNorth
    Delay8
    WalkOnSpotNormalEast
    EndMovement

EternaForest_Dummy4:
    LockAll
    BufferPlayerName 0
    ReleaseAll
    End

EternaForest_Dummy5:
    LockAll
    BufferPlayerName 0
    ReleaseAll
    End

EternaForest_BugCatcher:
    NPCMessage EternaForest_Text_ImSearchingForBugPokemon
    End

EternaForest_Gardenia:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message EternaForest_Text_WereYouIngriguedByRumors
    CloseMessage
    ApplyMovement LOCALID_GARDENIA, EternaForest_Movement_GardeniaWalkOnSpotNorth
    WaitMovement
    Message EternaForest_Text_GhostPokemonOfOldChateau
    FacePlayer
    Message EternaForest_Text_GoodLuckWithInvestigation
    CloseMessage
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_NORTH, EternaForest_GardeniaLeaveNorth
    GoToIfEq VAR_RESULT, DIR_SOUTH, EternaForest_GardeniaLeaveSouth
    GoToIfEq VAR_RESULT, DIR_WEST, EternaForest_GardeniaLeaveWest
    GoToIfEq VAR_RESULT, DIR_EAST, EternaForest_GardeniaLeaveEast
    End

EternaForest_GardeniaLeaveNorth:
    ApplyMovement LOCALID_GARDENIA, EternaForest_Movement_GardeniaLeaveNorth
    WaitMovement
    GoTo EternaForest_RemoveGardenia
    End

EternaForest_GardeniaLeaveSouth:
    ApplyMovement LOCALID_GARDENIA, EternaForest_Movement_GardeniaLeaveSouthWestEast
    WaitMovement
    GoTo EternaForest_RemoveGardenia
    End

EternaForest_GardeniaLeaveWest:
    ApplyMovement LOCALID_GARDENIA, EternaForest_Movement_GardeniaLeaveSouthWestEast
    WaitMovement
    GoTo EternaForest_RemoveGardenia
    End

EternaForest_GardeniaLeaveEast:
    ApplyMovement LOCALID_GARDENIA, EternaForest_Movement_GardeniaLeaveSouthWestEast
    WaitMovement
    GoTo EternaForest_RemoveGardenia
    End

EternaForest_RemoveGardenia:
    RemoveObject LOCALID_GARDENIA
    ReleaseAll
    End

    .balign 4, 0
EternaForest_Movement_GardeniaWalkOnSpotNorth:
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
EternaForest_Movement_GardeniaLeaveSouthWestEast:
    WalkNormalSouth 2
    WalkNormalEast 9
    EndMovement

    .balign 4, 0
EternaForest_Movement_GardeniaLeaveNorth:
    WalkNormalWest
    WalkNormalSouth 2
    WalkNormalEast 10
    EndMovement

EternaForest_SignboardEternaForest:
    ShowLandmarkSign EternaForest_Text_SignEternaForest
    End

EternaForest_TrainerTipsSignpost:
    ShowScrollingSign EternaForest_Text_TrainerTipsItemsOnGround
    End

// Sovereign (E10): as in Renegade, a piece of the Moss Rock falls off once: a Leaf Stone.
EternaForest_MossRock:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_ETERNA_FOREST_LEAF_STONE, EternaForest_MossRockCool
    Message EternaForest_Text_SovereignMossRockPieceFellOff
    SetVar VAR_0x8004, ITEM_LEAF_STONE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantityNoLineFeed
    CloseMessage
    SetFlag FLAG_SOVEREIGN_RECEIVED_ETERNA_FOREST_LEAF_STONE
    ReleaseAll
    End

EternaForest_MossRockCool:
    Message EternaForest_Text_RockIsCoveredInMoss
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaForest_OnFrame_CherylOldChateauCutscene:
    LockAll
    SetVar VAR_ETERNA_FOREST_CHERYL_OLD_CHATEAU_CUTSCENE_STATE, 2
    ApplyMovement LOCALID_CHERYL, EternaForest_Movement_CherylWalkOnSpotNorth
    WaitMovement
    Message EternaForest_Text_OldChateauAhead
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
EternaForest_Movement_CherylWalkOnSpotNorth:
    WalkOnSpotNormalNorth
    EndMovement

@ Sovereign (E10 part 28, Renegade's Celebi event): once the GS Ball has shaken here (VAR_SOVEREIGN_CELEBI_STATE 2), eight time
@ portals stand around the forest. Each holds the memory of a battle with one of Johto's Gym Leaders (Renegade's
@ trainers 1029-1036) and closes once that memory is beaten. With all eight beaten, Celebi itself waits near the
@ middle of the forest (70, 58), Lv. 40, until it is caught. Renegade puts it in a ninth portal; Sovereign shows the
@ Pokémon, as for its other legendaries. The portals' hidden flags are map-local (0x01-0x08).
EternaForest_SovereignSetPortalVisibility:
    SetFlag FLAG_MAP_LOCAL_0x01
    GoToIfLt VAR_SOVEREIGN_CELEBI_STATE, 2, EternaForest_SovereignSetPortal1VisibilityEnd
    GoToIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_FALKNER_MEMORY, EternaForest_SovereignSetPortal1VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_0x01
EternaForest_SovereignSetPortal1VisibilityEnd:
    SetFlag FLAG_MAP_LOCAL_0x02
    GoToIfLt VAR_SOVEREIGN_CELEBI_STATE, 2, EternaForest_SovereignSetPortal2VisibilityEnd
    GoToIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_BUGSY_MEMORY, EternaForest_SovereignSetPortal2VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_0x02
EternaForest_SovereignSetPortal2VisibilityEnd:
    SetFlag FLAG_MAP_LOCAL_0x03
    GoToIfLt VAR_SOVEREIGN_CELEBI_STATE, 2, EternaForest_SovereignSetPortal3VisibilityEnd
    GoToIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_WHITNEY_MEMORY, EternaForest_SovereignSetPortal3VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_0x03
EternaForest_SovereignSetPortal3VisibilityEnd:
    SetFlag FLAG_MAP_LOCAL_0x04
    GoToIfLt VAR_SOVEREIGN_CELEBI_STATE, 2, EternaForest_SovereignSetPortal4VisibilityEnd
    GoToIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_MORTY_MEMORY, EternaForest_SovereignSetPortal4VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_0x04
EternaForest_SovereignSetPortal4VisibilityEnd:
    SetFlag FLAG_MAP_LOCAL_0x05
    GoToIfLt VAR_SOVEREIGN_CELEBI_STATE, 2, EternaForest_SovereignSetPortal5VisibilityEnd
    GoToIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_CHUCK_MEMORY, EternaForest_SovereignSetPortal5VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_0x05
EternaForest_SovereignSetPortal5VisibilityEnd:
    SetFlag FLAG_MAP_LOCAL_0x06
    GoToIfLt VAR_SOVEREIGN_CELEBI_STATE, 2, EternaForest_SovereignSetPortal6VisibilityEnd
    GoToIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_JASMINE_MEMORY, EternaForest_SovereignSetPortal6VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_0x06
EternaForest_SovereignSetPortal6VisibilityEnd:
    SetFlag FLAG_MAP_LOCAL_0x07
    GoToIfLt VAR_SOVEREIGN_CELEBI_STATE, 2, EternaForest_SovereignSetPortal7VisibilityEnd
    GoToIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_PRYCE_MEMORY, EternaForest_SovereignSetPortal7VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_0x07
EternaForest_SovereignSetPortal7VisibilityEnd:
    SetFlag FLAG_MAP_LOCAL_0x08
    GoToIfLt VAR_SOVEREIGN_CELEBI_STATE, 2, EternaForest_SovereignSetPortal8VisibilityEnd
    GoToIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_CLAIR_MEMORY, EternaForest_SovereignSetPortal8VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_0x08
EternaForest_SovereignSetPortal8VisibilityEnd:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    GoToIfLt VAR_SOVEREIGN_CELEBI_STATE, 2, EternaForest_SovereignSetCelebiVisibilityEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_FALKNER_MEMORY, EternaForest_SovereignSetCelebiVisibilityEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_BUGSY_MEMORY, EternaForest_SovereignSetCelebiVisibilityEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_WHITNEY_MEMORY, EternaForest_SovereignSetCelebiVisibilityEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_MORTY_MEMORY, EternaForest_SovereignSetCelebiVisibilityEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_CHUCK_MEMORY, EternaForest_SovereignSetCelebiVisibilityEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_JASMINE_MEMORY, EternaForest_SovereignSetCelebiVisibilityEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_PRYCE_MEMORY, EternaForest_SovereignSetCelebiVisibilityEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_CLAIR_MEMORY, EternaForest_SovereignSetCelebiVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_CELEBI, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, EternaForest_SovereignSetCelebiVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
EternaForest_SovereignSetCelebiVisibilityEnd:
    Return

@ The GS Ball shakes as the player walks in from the Eterna City side: the portals open, and Celebi peeks out at the
@ player before vanishing.
EternaForest_SovereignCoordEvent_GSBall:
    LockAll
    Message EternaForest_Text_SovereignGSBallShaking
    CloseMessage
    FadeScreenOut FADE_SCREEN_SPEED_SLOW, COLOR_WHITE
    WaitFadeScreen
    SetVar VAR_SOVEREIGN_CELEBI_STATE, 2
    Call EternaForest_SovereignSetPortalVisibility
    AddObject LOCALID_SOVEREIGN_TIME_PORTAL_1
    AddObject LOCALID_SOVEREIGN_TIME_PORTAL_2
    AddObject LOCALID_SOVEREIGN_TIME_PORTAL_3
    AddObject LOCALID_SOVEREIGN_TIME_PORTAL_4
    AddObject LOCALID_SOVEREIGN_TIME_PORTAL_5
    AddObject LOCALID_SOVEREIGN_TIME_PORTAL_6
    AddObject LOCALID_SOVEREIGN_TIME_PORTAL_7
    AddObject LOCALID_SOVEREIGN_TIME_PORTAL_8
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    RemoveObject LOCALID_SOVEREIGN_CELEBI_SPIRIT
    SetObjectEventPos LOCALID_SOVEREIGN_CELEBI_SPIRIT, 73, VAR_0x8005
    AddObject LOCALID_SOVEREIGN_CELEBI_SPIRIT
    FadeScreenIn FADE_SCREEN_SPEED_SLOW, COLOR_WHITE
    WaitFadeScreen
    WaitTime 15, VAR_RESULT
    ApplyMovement LOCALID_SOVEREIGN_CELEBI_SPIRIT, EternaForest_Movement_SovereignCelebiNotice
    WaitMovement
    PlayCry SPECIES_CELEBI
    Message EternaForest_Text_SovereignCelebiBii
    WaitCry
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_CELEBI_SPIRIT, EternaForest_Movement_SovereignCelebiFlee
    WaitMovement
    RemoveObject LOCALID_SOVEREIGN_CELEBI_SPIRIT
    ReleaseAll
    End

EternaForest_SovereignPortal1:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_FALKNER_MEMORY
    SetVar VAR_MAP_LOCAL_0x02, LOCALID_SOVEREIGN_TIME_PORTAL_1
    SetVar VAR_MAP_LOCAL_0x03, 74
    SetVar VAR_MAP_LOCAL_0x04, 32
    GoTo EternaForest_SovereignPortal

EternaForest_SovereignPortal2:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_BUGSY_MEMORY
    SetVar VAR_MAP_LOCAL_0x02, LOCALID_SOVEREIGN_TIME_PORTAL_2
    SetVar VAR_MAP_LOCAL_0x03, 65
    SetVar VAR_MAP_LOCAL_0x04, 34
    GoTo EternaForest_SovereignPortal

EternaForest_SovereignPortal3:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_WHITNEY_MEMORY
    SetVar VAR_MAP_LOCAL_0x02, LOCALID_SOVEREIGN_TIME_PORTAL_3
    SetVar VAR_MAP_LOCAL_0x03, 82
    SetVar VAR_MAP_LOCAL_0x04, 46
    GoTo EternaForest_SovereignPortal

EternaForest_SovereignPortal4:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_MORTY_MEMORY
    SetVar VAR_MAP_LOCAL_0x02, LOCALID_SOVEREIGN_TIME_PORTAL_4
    SetVar VAR_MAP_LOCAL_0x03, 81
    SetVar VAR_MAP_LOCAL_0x04, 72
    GoTo EternaForest_SovereignPortal

EternaForest_SovereignPortal5:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_CHUCK_MEMORY
    SetVar VAR_MAP_LOCAL_0x02, LOCALID_SOVEREIGN_TIME_PORTAL_5
    SetVar VAR_MAP_LOCAL_0x03, 53
    SetVar VAR_MAP_LOCAL_0x04, 60
    GoTo EternaForest_SovereignPortal

EternaForest_SovereignPortal6:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_JASMINE_MEMORY
    SetVar VAR_MAP_LOCAL_0x02, LOCALID_SOVEREIGN_TIME_PORTAL_6
    SetVar VAR_MAP_LOCAL_0x03, 41
    SetVar VAR_MAP_LOCAL_0x04, 58
    GoTo EternaForest_SovereignPortal

EternaForest_SovereignPortal7:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_PRYCE_MEMORY
    SetVar VAR_MAP_LOCAL_0x02, LOCALID_SOVEREIGN_TIME_PORTAL_7
    SetVar VAR_MAP_LOCAL_0x03, 29
    SetVar VAR_MAP_LOCAL_0x04, 64
    GoTo EternaForest_SovereignPortal

EternaForest_SovereignPortal8:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_CLAIR_MEMORY
    SetVar VAR_MAP_LOCAL_0x02, LOCALID_SOVEREIGN_TIME_PORTAL_8
    SetVar VAR_MAP_LOCAL_0x03, 24
    SetVar VAR_MAP_LOCAL_0x04, 68
    GoTo EternaForest_SovereignPortal

@ The portal's memory trainer, its local ID and its tile are in map-local vars 0x01-0x04, which last through
@ the battle. After a win the portal closes and Celebi shows itself on its tile for a moment.
EternaForest_SovereignPortal:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    Message EternaForest_Text_SovereignPortal
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, EternaForest_SovereignPortalDeclined
    Message EternaForest_Text_SovereignPortalMemory
    CloseMessage
    StartTrainerBattle VAR_MAP_LOCAL_0x01
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, EternaForest_SovereignPortalLost
    SetTrainerFlag VAR_MAP_LOCAL_0x01
    FadeScreenOut FADE_SCREEN_SPEED_MEDIUM, COLOR_WHITE
    WaitFadeScreen
    RemoveObject VAR_MAP_LOCAL_0x02
    RemoveObject LOCALID_SOVEREIGN_CELEBI_SPIRIT
    SetObjectEventPos LOCALID_SOVEREIGN_CELEBI_SPIRIT, VAR_MAP_LOCAL_0x03, VAR_MAP_LOCAL_0x04
    AddObject LOCALID_SOVEREIGN_CELEBI_SPIRIT
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM, COLOR_WHITE
    WaitFadeScreen
    ApplyMovement LOCALID_SOVEREIGN_CELEBI_SPIRIT, EternaForest_Movement_SovereignCelebiEmote
    WaitMovement
    PlayCry SPECIES_CELEBI
    Message EternaForest_Text_SovereignCelebiSad
    WaitCry
    CloseMessage
    FadeScreenOut FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_CELEBI_SPIRIT
    FadeScreenIn FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    Message EternaForest_Text_SovereignPortalGone
    WaitButton
    CloseMessage
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_FALKNER_MEMORY, EternaForest_SovereignPortalEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_BUGSY_MEMORY, EternaForest_SovereignPortalEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_WHITNEY_MEMORY, EternaForest_SovereignPortalEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_MORTY_MEMORY, EternaForest_SovereignPortalEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_CHUCK_MEMORY, EternaForest_SovereignPortalEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_JASMINE_MEMORY, EternaForest_SovereignPortalEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_PRYCE_MEMORY, EternaForest_SovereignPortalEnd
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_CLAIR_MEMORY, EternaForest_SovereignPortalEnd
    WaitTime 15, VAR_RESULT
    FadeScreenOut FADE_SCREEN_SPEED_MEDIUM, COLOR_WHITE
    WaitFadeScreen
    PlayCry SPECIES_CELEBI
    WaitCry
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    AddObject LOCALID_LEGENDARY_CELEBI
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM, COLOR_WHITE
    WaitFadeScreen
    WaitTime 15, VAR_RESULT
    Message EternaForest_Text_SovereignCelebiPresence
    WaitButton
    CloseMessage
EternaForest_SovereignPortalEnd:
    ReleaseAll
    End

@ The message box is closed on every other path; closing it twice would remove its window twice.
EternaForest_SovereignPortalDeclined:
    CloseMessage
    ReleaseAll
    End

EternaForest_SovereignPortalLost:
    BlackOutFromBattle
    ReleaseAll
    End

EternaForest_LegendaryCelebi:
    SetVar VAR_MAP_LOCAL_0x00, SPECIES_CELEBI
    SetVar VAR_0x8004, SPECIES_CELEBI
    SetVar VAR_0x8005, 40
    Common_SovereignLegendaryEncounter
    End

EternaForest_SovereignRemoveLegendaryCelebi:
    RemoveObject LOCALID_LEGENDARY_CELEBI
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

    .balign 4, 0
EternaForest_Movement_SovereignCelebiNotice:
    FaceEast
    EmoteExclamationMark
    EndMovement

EternaForest_Movement_SovereignCelebiFlee:
    WalkFastWest 4
    EndMovement

EternaForest_Movement_SovereignCelebiEmote:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
