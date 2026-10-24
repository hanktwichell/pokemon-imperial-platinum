#include "macros/scrcmd.inc"
#include "res/text/bank/wayward_cave_1f.h"
#include "res/field/events/events_wayward_cave_1f.h"


    ScriptEntry WaywardCave1F_OnTransition
    ScriptEntry WaywardCave1F_Mira
    ScriptEntry WaywardCave1F_Dummy3
    ScriptEntry WaywardCave1F_CoordEvent_Exit
    ScriptEntry WaywardCave1F_OnLoad
    ScriptEntry WaywardCave1F_LegendaryNecrozma
    ScriptEntry WaywardCave1F_SovereignGabite
    ScriptEntry WaywardCave1F_SovereignMiraStays
    ScriptEntry WaywardCave1F_SovereignMiraRejoins
    ScriptEntry WaywardCave1F_SovereignCrimsonRibbon
    ScriptEntryEnd

// Sovereign (E10): Renegade Platinum's version of Mira's story. Mira waits near the hidden entrance, battles the
// player, then asks for help finding her Crimson Ribbon deep in the cave. Heading back to the exit without it, she
// stays behind to keep searching (VAR_SOVEREIGN_MIRA_QUEST_STATE: 1 following, 2 waiting, 3 ribbon found, 4 done);
// at the exit with it, she gives TM85 (Dazzling Gleam). A Gabite waits at the main entrance, and the Rock Smash rocks
// are gone, as in Renegade.

WaywardCave1F_OnTransition:
    Call WaywardCave1F_SovereignSetNecrozmaVisibility
    SetFlag FLAG_FIRST_ARRIVAL_WAYWARD_CAVE
    GoToIfUnset FLAG_TRAVELED_WITH_MIRA, WaywardCave1F_ResetFollowerMiraState
    End

WaywardCave1F_ResetFollowerMiraState:
    SetVar VAR_WAYWARD_CAVE_1F_FOLLOWER_MIRA_STATE, 0
    GoToIfNe VAR_SOVEREIGN_MIRA_QUEST_STATE, 1, WaywardCave1F_ResetFollowerMiraStateEnd
    SetVar VAR_SOVEREIGN_MIRA_QUEST_STATE, 2 // left with her (Escape Rope, Fly): she's back at her spot, waiting
WaywardCave1F_ResetFollowerMiraStateEnd:
    End

WaywardCave1F_Mira:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    SetPlayerBike FALSE
    GoToIfGe VAR_WAYWARD_CAVE_1F_FOLLOWER_MIRA_STATE, 1, WaywardCave1F_MiraMessage
    BufferPlayerName 0
    GoToIfSet FLAG_TALKED_TO_WAYWARD_CAVE_1F_MIRA, WaywardCave1F_SovereignMiraMetBefore
    ApplyMovement LOCALID_MIRA, WaywardCave1F_Movement_SovereignExclamationMark
    WaitMovement
    Message WaywardCave1F_Text_SovereignStayAwayFromMira
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_MIRA_WAYWARD_CAVE
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, WaywardCave1F_SovereignBlackOut
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message WaywardCave1F_Text_SovereignPleaseHelpFindMyItem
    GoTo WaywardCave1F_SovereignMiraJoins

// Meeting her again, back at her spot.
WaywardCave1F_SovereignMiraMetBefore:
    GoToIfUnset FLAG_SOVEREIGN_FOUND_CRIMSON_RIBBON, WaywardCave1F_SovereignYouCameBack
    GoToIfEq VAR_SOVEREIGN_MIRA_QUEST_STATE, 3, WaywardCave1F_SovereignThankYouLetsGetOut
    SetVar VAR_SOVEREIGN_MIRA_QUEST_STATE, 3 // the player found the ribbon while she waited
    Message WaywardCave1F_Text_SovereignThatsMyRibbon
    GoTo WaywardCave1F_SovereignMiraJoins

WaywardCave1F_SovereignYouCameBack:
    Message WaywardCave1F_Text_SovereignYouCameBack
    GoTo WaywardCave1F_SovereignMiraJoins

WaywardCave1F_SovereignThankYouLetsGetOut:
    Message WaywardCave1F_Text_SovereignThankYouLetsGetOut
WaywardCave1F_SovereignMiraJoins:
    BufferPlayerName 0
    PlayFanfare SEQ_GONIN_sseq
    Message WaywardCave1F_Text_PlayerDecidedToGoWithMira
    WaitFanfare
    SetFlag FLAG_TALKED_TO_WAYWARD_CAVE_1F_MIRA
    SetVar VAR_WAYWARD_CAVE_1F_FOLLOWER_MIRA_STATE, 1
    Message WaywardCave1F_Text_IllKeepYourPokemonHealthy
    WaitButton
    CloseMessage
    SetVar VAR_PARTNER_TRAINER_ID, TRAINER_MIRA_WAYWARD_CAVE
    SetHasPartner
    SetMovementType LOCALID_MIRA, MOVEMENT_TYPE_FOLLOW_PLAYER
    HealParty
    GoToIfSet FLAG_SOVEREIGN_FOUND_CRIMSON_RIBBON, WaywardCave1F_SovereignMiraJoinsWithRibbon
    SetVar VAR_SOVEREIGN_MIRA_QUEST_STATE, 1
    ReleaseAll
    End

WaywardCave1F_SovereignMiraJoinsWithRibbon:
    GoToIfEq VAR_SOVEREIGN_MIRA_QUEST_STATE, 3, WaywardCave1F_SovereignReleaseAll
    SetVar VAR_SOVEREIGN_MIRA_QUEST_STATE, 3 // the player found the ribbon before meeting her
    BufferPlayerName 0
    Message WaywardCave1F_Text_SovereignThatsMyRibbon
    WaitButton
    CloseMessage
WaywardCave1F_SovereignReleaseAll:
    ReleaseAll
    End

WaywardCave1F_SovereignBlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

WaywardCave1F_MiraMessage:
    GoToIfGe VAR_FOLLOWER_MIRA_TIMES_TALKED, 2, WaywardCave1F_MiraWillTryLikeYou
    GoToIfEq VAR_FOLLOWER_MIRA_TIMES_TALKED, 1, WaywardCave1F_EasyToGetConfused
    BufferPlayerName 0
    Message WaywardCave1F_Text_ILikeHelpfulMoves
    GoTo WaywardCave1F_IncreaseFollowerMiraTimesTalked

WaywardCave1F_EasyToGetConfused:
    Message WaywardCave1F_Text_EasyToGetConfused
    GoTo WaywardCave1F_IncreaseFollowerMiraTimesTalked

WaywardCave1F_MiraWillTryLikeYou:
    BufferPlayerName 0
    Message WaywardCave1F_Text_MiraWillTryLikeYou
    WaitButton
    CloseMessage
    ReleaseAll
    End

WaywardCave1F_IncreaseFollowerMiraTimesTalked:
    AddVar VAR_FOLLOWER_MIRA_TIMES_TALKED, 1
    WaitButton
    CloseMessage
    ReleaseAll
    End

WaywardCave1F_Dummy3:
    End

WaywardCave1F_CoordEvent_Exit:
    GoToIfNe VAR_SOVEREIGN_MIRA_QUEST_STATE, 3, WaywardCave1F_SovereignExitWithoutRibbon
    LockAll
    ClearHasPartner
    SetMovementType LOCALID_MIRA, MOVEMENT_TYPE_LOOK_WEST
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_WEST, WaywardCave1F_NoticeExitWest
    GoTo WaywardCave1F_NoticeExitSouth

WaywardCave1F_NoticeExitWest:
    ApplyMovement LOCALID_PLAYER, WaywardCave1F_Movement_PlayerWalkOnSpotEast
    ApplyMovement LOCALID_MIRA, WaywardCave1F_Movement_MiraWalkOnSpotWestExclamationMark
    WaitMovement
    GoTo WaywardCave1F_OhTheresTheExitThankYou

WaywardCave1F_NoticeExitSouth:
    ApplyMovement LOCALID_PLAYER, WaywardCave1F_Movement_PlayerWalkOnSpotNorth
    ApplyMovement LOCALID_MIRA, WaywardCave1F_Movement_MiraWalkOnSpotSouthExclamationMark
    WaitMovement
    GoTo WaywardCave1F_OhTheresTheExitThankYou

WaywardCave1F_OhTheresTheExitThankYou:
    BufferPlayerName 0
    Message WaywardCave1F_Text_SovereignTheresTheExit
    SetVar VAR_0x8004, ITEM_TM85
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Message WaywardCave1F_Text_SovereignTM85IsDazzlingGleam
    CloseMessage
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_EAST, WaywardCave1F_MiraWalkWestLeave
    GoTo WaywardCave1F_MiraWalkSouthLeave

WaywardCave1F_MiraWalkWestLeave:
    ApplyMovement LOCALID_PLAYER, WaywardCave1F_Movement_PlayerWalkNorthOnSpotSouth
    ApplyMovement LOCALID_MIRA, WaywardCave1F_Movement_MiraWalkWestLeave
    WaitMovement
    GoTo WaywardCave1F_RemoveMira

WaywardCave1F_MiraWalkSouthLeave:
    ApplyMovement LOCALID_PLAYER, WaywardCave1F_Movement_PlayerWalkEastOnSpotWest
    ApplyMovement LOCALID_MIRA, WaywardCave1F_Movement_MiraWalkSouthLeave
    WaitMovement
    GoTo WaywardCave1F_RemoveMira

WaywardCave1F_RemoveMira:
    RemoveObject LOCALID_MIRA
    SetFlag FLAG_TRAVELED_WITH_MIRA
    SetVar VAR_WAYWARD_CAVE_1F_FOLLOWER_MIRA_STATE, 2
    SetVar VAR_SOVEREIGN_MIRA_QUEST_STATE, 4
    ReleaseAll
    End

WaywardCave1F_SovereignExitWithoutRibbon:
    End

    .balign 4, 0
WaywardCave1F_Movement_PlayerWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
WaywardCave1F_Movement_PlayerWalkOnSpotNorth:
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
WaywardCave1F_Movement_PlayerWalkNorthOnSpotSouth:
    WalkNormalNorth
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
WaywardCave1F_Movement_PlayerWalkEastOnSpotWest:
    WalkNormalEast
    WalkOnSpotNormalWest
    EndMovement

WaywardCave1F_Movement_Unused:
    Delay8 5
    WalkNormalWest
    EndMovement

WaywardCave1F_Movement_Unused2:
    Delay8 5
    WalkNormalNorth
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
WaywardCave1F_Movement_MiraWalkOnSpotWestExclamationMark:
    WalkOnSpotNormalWest
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
WaywardCave1F_Movement_MiraWalkOnSpotSouthExclamationMark:
    WalkOnSpotNormalSouth
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
WaywardCave1F_Movement_MiraWalkWestLeave:
    Delay8 3
    WalkNormalWest
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
WaywardCave1F_Movement_MiraWalkSouthLeave:
    Delay8 3
    WalkNormalSouth
    WalkOnSpotNormalSouth
    EndMovement

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Necrozma, who steals the light, waits in the dark back
@ chamber where Mira was lost (the only Dark Flash cave), once the Alola Chronicle is open (VAR_SOVEREIGN_CHRONICLE 3)
@ and the player has Solgaleo or Lunala, until it's caught.
WaywardCave1F_SovereignSetNecrozmaVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, WaywardCave1F_SovereignSetNecrozmaVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_NECROZMA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, WaywardCave1F_SovereignSetNecrozmaVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_SOLGALEO, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, WaywardCave1F_SovereignShowNecrozma
    SovereignCheckSpeciesCaught SPECIES_LUNALA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, WaywardCave1F_SovereignSetNecrozmaVisibilityEnd
WaywardCave1F_SovereignShowNecrozma:
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
WaywardCave1F_SovereignSetNecrozmaVisibilityEnd:
    Return

WaywardCave1F_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, WaywardCave1F_RemoveLegendaryNecrozma
    End

WaywardCave1F_RemoveLegendaryNecrozma:
    RemoveObject LOCALID_LEGENDARY_NECROZMA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

WaywardCave1F_LegendaryNecrozma:
    SetVar VAR_0x8004, SPECIES_NECROZMA
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

WaywardCave1F_SovereignGabite:
    LockAll
    ApplyMovement LOCALID_PLAYER, WaywardCave1F_Movement_SovereignExclamationMark
    WaitMovement
    PlayCry SPECIES_GABITE
    Message WaywardCave1F_Text_SovereignGabiteCry
    WaitCry
    CloseMessage
    StartWildBattle SPECIES_GABITE, 25
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, WaywardCave1F_SovereignBlackOut
    SetVar VAR_SOVEREIGN_WAYWARD_CAVE_GABITE_STATE, 1
    ReleaseAll
    End

WaywardCave1F_SovereignMiraStays:
    LockAll
    ClearHasPartner
    SetMovementType LOCALID_MIRA, MOVEMENT_TYPE_LOOK_WEST
    ApplyMovement LOCALID_MIRA, WaywardCave1F_Movement_SovereignMiraFaceEast
    WaitMovement
    BufferPlayerName 0
    Message WaywardCave1F_Text_SovereignAreYouLeaving
    CloseMessage
    ApplyMovement LOCALID_MIRA, WaywardCave1F_Movement_SovereignMiraWalkWest
    WaitMovement
    SetVar VAR_WAYWARD_CAVE_1F_FOLLOWER_MIRA_STATE, 0
    SetVar VAR_SOVEREIGN_MIRA_QUEST_STATE, 2
    ReleaseAll
    End

WaywardCave1F_SovereignMiraRejoins:
    LockAll
    ApplyMovement LOCALID_MIRA, WaywardCave1F_Movement_SovereignMiraFaceEast
    WaitMovement
    BufferPlayerName 0
    GoTo WaywardCave1F_SovereignMiraMetBefore

WaywardCave1F_SovereignCrimsonRibbon:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    RemoveObject LOCALID_CRIMSON_RIBBON
    SetFlag FLAG_SOVEREIGN_FOUND_CRIMSON_RIBBON
    PlayFanfare SEQ_FANFA4_sseq
    BufferPlayerName 0
    Message WaywardCave1F_Text_SovereignFoundCrimsonRibbon
    WaitFanfare
    CloseMessage
    GoToIfNe VAR_WAYWARD_CAVE_1F_FOLLOWER_MIRA_STATE, 1, WaywardCave1F_SovereignReleaseAll
    ApplyMovement LOCALID_MIRA, WaywardCave1F_Movement_SovereignExclamationMark
    WaitMovement
    BufferPlayerName 0
    Message WaywardCave1F_Text_SovereignThatsMyRibbon
    WaitButton
    CloseMessage
    SetVar VAR_SOVEREIGN_MIRA_QUEST_STATE, 3
    ReleaseAll
    End

    .balign 4, 0
WaywardCave1F_Movement_SovereignExclamationMark:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
WaywardCave1F_Movement_SovereignMiraFaceEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
WaywardCave1F_Movement_SovereignMiraWalkWest:
    WalkNormalWest
    EndMovement
