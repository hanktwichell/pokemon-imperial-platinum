#include "macros/scrcmd.inc"
#include "res/text/bank/pokemon_mansion.h"
#include "res/field/events/events_pokemon_mansion.h"


    ScriptEntry PokemonMansion_OnTransition
    ScriptEntry PokemonMansion_MaidOffice
    ScriptEntry PokemonMansion_MaidTrophyGarden
    ScriptEntry PokemonMansion_MaidWest
    ScriptEntry PokemonMansion_MaidFarEast
    ScriptEntry PokemonMansion_MaidEast
    ScriptEntry PokemonMansion_SovereignGruntTrio
    ScriptEntry PokemonMansion_SovereignGruntGarden
    ScriptEntry PokemonMansion_SovereignClefairy
    ScriptEntry PokemonMansion_SovereignRival
    ScriptEntry PokemonMansion_SovereignGruntRoom1
    ScriptEntry PokemonMansion_SovereignGruntRoom2
    ScriptEntry PokemonMansion_SovereignGruntRoom3
    ScriptEntry PokemonMansion_SovereignGruntRoom4
    ScriptEntry PokemonMansion_SovereignGruntEast
    ScriptEntry PokemonMansion_SovereignHappiny
    ScriptEntry PokemonMansion_SovereignCoordEvent_Saturn
    ScriptEntryEnd

PokemonMansion_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_POKEMON_MANSION
    SetFlag FLAG_HIDE_POKEMON_MANSION_FIVE_MAID_KNOCKOUT_MAID
    SetFlag FLAG_HIDE_POKEMON_MANSION_FIVE_MAID_KNOCKOUT_BOSS
    Call PokemonMansion_SovereignSetSiegeVisibility
    GoToIfUnset FLAG_DAILY_SET_FIVE_MAID_KNOCKOUT_TURN_TARGET, PokemonMansion_InitFiveMaidKnockoutChallenge
    End

PokemonMansion_InitFiveMaidKnockoutChallenge:
    GetRandom VAR_FIVE_MAID_KNOCKOUT_TURN_TARGET, 5
    AddVar VAR_FIVE_MAID_KNOCKOUT_TURN_TARGET, 5
    SetFlag FLAG_DAILY_SET_FIVE_MAID_KNOCKOUT_TURN_TARGET
    ClearTrainerFlag TRAINER_RICH_BOY_LIAM
    ClearTrainerFlag TRAINER_LADY_CELESTE
    End

PokemonMansion_MaidOffice:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message PokemonMansion_Text_MrBacklotOffice
    WaitButton
    CloseMessage
    ApplyMovement LOCALID_MAID_OFFICE, PokemonMansion_Movement_MaidOfficeFaceSouth
    WaitMovement
    ReleaseAll
    End

PokemonMansion_MaidTrophyGarden:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message PokemonMansion_Text_ThisWayTrophyGarden
    WaitButton
    CloseMessage
    ApplyMovement LOCALID_MAID_TROPHY_GARDEN, PokemonMansion_Movement_MaidTrophyGardenFaceSouth
    WaitMovement
    ReleaseAll
    End

PokemonMansion_MaidWest:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_RICH_BOY_LIAM, PokemonMansion_VisitAgainTomorrow
    GoToIfDefeated TRAINER_LADY_CELESTE, PokemonMansion_VisitAgainTomorrow
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_NORTH, PokemonMansion_GetInPositionNorth
    GoToIfEq VAR_RESULT, DIR_SOUTH, PokemonMansion_GetInPositionSouth
    GoTo PokemonMansion_FiveMaidKnockoutChallenge
    End

PokemonMansion_GetInPositionNorth:
    ApplyMovement LOCALID_MAID_FAR_WEST, PokemonMansion_Movement_MaidFarWestWalkOnSpotEast
    ApplyMovement LOCALID_PLAYER, PokemonMansion_Movement_PlayerGetInPositionNorth
    WaitMovement
    GoTo PokemonMansion_FiveMaidKnockoutChallenge
    End

PokemonMansion_GetInPositionSouth:
    ApplyMovement LOCALID_MAID_FAR_WEST, PokemonMansion_Movement_MaidFarWestWalkOnSpotEast2
    ApplyMovement LOCALID_PLAYER, PokemonMansion_Movement_PlayerGetInPositionSouth
    WaitMovement
    GoTo PokemonMansion_FiveMaidKnockoutChallenge
    End

PokemonMansion_FiveMaidKnockoutChallenge:
    CallIfUnset FLAG_STARTED_FIVE_MAID_KNOCKOUT_CHALLENGE, PokemonMansion_ExplainChallenge
    CallIfSet FLAG_STARTED_FIVE_MAID_KNOCKOUT_CHALLENGE, PokemonMansion_TargetedTurnsIsThis
    SetFlag FLAG_STARTED_FIVE_MAID_KNOCKOUT_CHALLENGE
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, PokemonMansion_DontDoChallenge
    SetTrainerFlag TRAINER_RICH_BOY_LIAM
    SetTrainerFlag TRAINER_LADY_CELESTE
    Message PokemonMansion_Text_OurFirstMaid
    CloseMessage
    ApplyMovement LOCALID_MAID_FAR_WEST, PokemonMansion_Movement_MaidFarWestMoveAside
    WaitMovement
    SetVar VAR_TOTAL_TURNS_LAST_BATTLE, 0
    SetVar VAR_0x8005, 0
    ClearFlag FLAG_HIDE_POKEMON_MANSION_FIVE_MAID_KNOCKOUT_MAID
    AddObject LOCALID_FIVE_MAID_KNOCKOUT_MAID
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_MAID, PokemonMansion_Movement_KnockoutTrainerEnter
    WaitMovement
    Message PokemonMansion_Text_Maid1Intro
    CloseMessage
    StartTrainerBattle TRAINER_MAID_BELINDA
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_BlackOut
    AddVar VAR_0x8005, VAR_TOTAL_TURNS_LAST_BATTLE
    Message PokemonMansion_Text_Maid1Defeat
    CloseMessage
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_MAID, PokemonMansion_Movement_KnockoutTrainerLeave
    WaitMovement
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_MAID, PokemonMansion_Movement_KnockoutTrainerEnter
    WaitMovement
    Message PokemonMansion_Text_Maid2Intro
    CloseMessage
    StartTrainerBattle TRAINER_MAID_SOPHIE
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_BlackOut
    AddVar VAR_0x8005, VAR_TOTAL_TURNS_LAST_BATTLE
    Message PokemonMansion_Text_Maid2Defeat
    CloseMessage
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_MAID, PokemonMansion_Movement_KnockoutTrainerLeave
    WaitMovement
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_MAID, PokemonMansion_Movement_KnockoutTrainerEnter
    WaitMovement
    Message PokemonMansion_Text_Maid3Intro
    CloseMessage
    StartTrainerBattle TRAINER_MAID_EMILY
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_BlackOut
    AddVar VAR_0x8005, VAR_TOTAL_TURNS_LAST_BATTLE
    Message PokemonMansion_Text_Maid3Defeat
    CloseMessage
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_MAID, PokemonMansion_Movement_KnockoutTrainerLeave
    WaitMovement
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_MAID, PokemonMansion_Movement_KnockoutTrainerEnter
    WaitMovement
    Message PokemonMansion_Text_Maid4Intro
    CloseMessage
    StartTrainerBattle TRAINER_MAID_ELENA
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_BlackOut
    AddVar VAR_0x8005, VAR_TOTAL_TURNS_LAST_BATTLE
    Message PokemonMansion_Text_Maid4Defeat
    CloseMessage
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_MAID, PokemonMansion_Movement_KnockoutTrainerLeave
    WaitMovement
    ApplyMovement LOCALID_MAID_FAR_WEST, PokemonMansion_Movement_MaidFarWestMoveBackInPlace
    WaitMovement
    BufferNumber 0, VAR_FIVE_MAID_KNOCKOUT_TURN_TARGET
    BufferNumber 1, VAR_0x8005
    Message PokemonMansion_Text_DefeatedFourMaids
    CloseMessage
    ApplyMovement LOCALID_MAID_FAR_WEST, PokemonMansion_Movement_MaidFarWestMoveAside
    WaitMovement
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_MAID, PokemonMansion_Movement_KnockoutTrainerEnter
    WaitMovement
    Message PokemonMansion_Text_Maid5Intro
    CloseMessage
    StartTrainerBattle TRAINER_MAID_CLARE
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_BlackOut
    AddVar VAR_0x8005, VAR_TOTAL_TURNS_LAST_BATTLE
    Message PokemonMansion_Text_Maid5Defeat
    CloseMessage
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_MAID, PokemonMansion_Movement_KnockoutTrainerLeave
    WaitMovement
    RemoveObject LOCALID_FIVE_MAID_KNOCKOUT_MAID
    ApplyMovement LOCALID_MAID_FAR_WEST, PokemonMansion_Movement_MaidFarWestMoveBackInPlace
    WaitMovement
    BufferNumber 0, VAR_FIVE_MAID_KNOCKOUT_TURN_TARGET
    BufferNumber 1, VAR_0x8005
    Message PokemonMansion_Text_TargetedTurnsYourTurns
    GoToIfNe VAR_0x8005, VAR_FIVE_MAID_KNOCKOUT_TURN_TARGET, PokemonMansion_FailedChallenge
    GetRandom VAR_0x8006, 2
    CallIfEq VAR_0x8006, 0, PokemonMansion_SetOpponentLiam
    CallIfEq VAR_0x8006, 1, PokemonMansion_SetOpponentCeleste
    CloseMessage
    ApplyMovement LOCALID_MAID_FAR_WEST, PokemonMansion_Movement_MaidFarWestMoveAside
    WaitMovement
    ClearFlag FLAG_HIDE_POKEMON_MANSION_FIVE_MAID_KNOCKOUT_BOSS
    AddObject LOCALID_FIVE_MAID_KNOCKOUT_BOSS
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_BOSS, PokemonMansion_Movement_KnockoutTrainerEnter
    WaitMovement
    CallIfEq VAR_0x8006, 0, PokemonMansion_LiamIntro
    CallIfEq VAR_0x8006, 1, PokemonMansion_CelesteIntro
    CloseMessage
    StartTrainerBattle VAR_0x8007
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_BlackOut
    SetTrainerFlag TRAINER_RICH_BOY_LIAM
    SetTrainerFlag TRAINER_LADY_CELESTE
    CallIfEq VAR_0x8006, 0, PokemonMansion_LiamDefeat
    CallIfEq VAR_0x8006, 1, PokemonMansion_CelesteDefeat
    CloseMessage
    ApplyMovement LOCALID_FIVE_MAID_KNOCKOUT_BOSS, PokemonMansion_Movement_KnockoutTrainerLeave
    WaitMovement
    RemoveObject LOCALID_FIVE_MAID_KNOCKOUT_BOSS
    ApplyMovement LOCALID_MAID_FAR_WEST, PokemonMansion_Movement_MaidFarWestMoveBackInPlace
    WaitMovement
    CallIfEq VAR_0x8006, 0, PokemonMansion_TriumphedOverLiam
    CallIfEq VAR_0x8006, 1, PokemonMansion_TriumphedOverCeleste
    GoTo PokemonMansion_VisitAgainTomorrow
    End

PokemonMansion_VisitAgainTomorrow:
    Message PokemonMansion_Text_VisitAgainTomorrow
    GoTo PokemonMansion_MaidChallengeEnd
    End

PokemonMansion_SetOpponentLiam:
    SetVar VAR_0x8007, TRAINER_RICH_BOY_LIAM
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_RICH_BOY
    BufferTrainerName 2, VAR_0x8007
    Message PokemonMansion_Text_HitTargetBattleLiam
    Return

PokemonMansion_SetOpponentCeleste:
    SetVar VAR_0x8007, TRAINER_LADY_CELESTE
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_LADY
    BufferTrainerName 2, VAR_0x8007
    Message PokemonMansion_Text_HitTargetBattleCeleste
    Return

PokemonMansion_LiamIntro:
    Message PokemonMansion_Text_LiamIntro
    Return

PokemonMansion_CelesteIntro:
    Message PokemonMansion_Text_CelesteIntro
    Return

PokemonMansion_LiamDefeat:
    Message PokemonMansion_Text_LiamDefeat
    Return

PokemonMansion_CelesteDefeat:
    Message PokemonMansion_Text_CelesteDefeat
    Return

PokemonMansion_TriumphedOverLiam:
    Message PokemonMansion_Text_TriumphedOverLiam
    Return

PokemonMansion_TriumphedOverCeleste:
    Message PokemonMansion_Text_TriumphedOverCeleste
    Return

    .balign 4, 0
PokemonMansion_Movement_MaidFarWestWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
PokemonMansion_Movement_MaidFarWestWalkOnSpotEast2:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
PokemonMansion_Movement_MaidFarWestMoveAside:
    WalkNormalNorth
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
PokemonMansion_Movement_MaidFarWestMoveBackInPlace:
    WalkNormalSouth
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
PokemonMansion_Movement_KnockoutTrainerLeave:
    WalkOnSpotNormalWest
    SetInvisible
    EndMovement

    .balign 4, 0
PokemonMansion_Movement_KnockoutTrainerEnter:
    SetVisible
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
PokemonMansion_Movement_PlayerGetInPositionNorth:
    WalkNormalEast
    WalkNormalNorth
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
PokemonMansion_Movement_PlayerGetInPositionSouth:
    WalkNormalEast
    WalkNormalSouth
    WalkOnSpotNormalWest
    EndMovement

PokemonMansion_FailedChallenge:
    Message PokemonMansion_Text_PlentyToBeProud
    Message PokemonMansion_Text_VisitAgainTomorrow
    GoTo PokemonMansion_MaidChallengeEnd
    End

PokemonMansion_ExplainChallenge:
    Message PokemonMansion_Text_ChallengeFiveMaids
    BufferNumber 0, VAR_FIVE_MAID_KNOCKOUT_TURN_TARGET
    Message PokemonMansion_Text_TargetedTurnsIsThis
    Return

PokemonMansion_TargetedTurnsIsThis:
    BufferNumber 0, VAR_FIVE_MAID_KNOCKOUT_TURN_TARGET
    Message PokemonMansion_Text_TargetedTurnsIsThis
    Return

PokemonMansion_DontDoChallenge:
    Message PokemonMansion_Text_HowDisappointing
    GoTo PokemonMansion_MaidChallengeEnd
    End

PokemonMansion_MaidChallengeEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonMansion_BlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

PokemonMansion_MaidFarEast:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message PokemonMansion_Text_StrictlyOffLimits
    WaitButton
    CloseMessage
    ApplyMovement LOCALID_MAID_FAR_EAST, PokemonMansion_Movement_MaidFarEastFaceWest
    WaitMovement
    ReleaseAll
    End

    .balign 4, 0
PokemonMansion_Movement_MaidOfficeFaceSouth:
    FaceSouth
    EndMovement

    .balign 4, 0
PokemonMansion_Movement_MaidTrophyGardenFaceSouth:
    FaceSouth
    EndMovement

PokemonMansion_Movement_Unused:
    FaceEast
    EndMovement

    .balign 4, 0
PokemonMansion_Movement_MaidFarEastFaceWest:
    FaceWest
    EndMovement

PokemonMansion_MaidEast:
    NPCMessage PokemonMansion_Text_BookTugsAttention
    End

    

@ Sovereign (E10, Renegade's Pokémon Mansion siege, VAR_SOVEREIGN_MANSION_SIEGE_STATE 1-5): the maids are kept out of
@ sight, Team Galactic's grunts guard the rooms and the Trophy Garden's door (Renegade's trainers 952-958), and Barry
@ argues with one of them. Each grunt guarding a room had locked up one of Backlot's Clefairy (or his Happiny); once
@ they're all free, the Happiny's Metronome trick teleports the grunt at the garden door away, and Saturn comes out of
@ the garden with Mr. Backlot for a tag battle (959, 960) with Barry as the partner.
PokemonMansion_SovereignSetSiegeVisibility:
    SetFlag FLAG_MAP_LOCAL_0x02
    SetFlag FLAG_MAP_LOCAL_0x03
    SetFlag FLAG_MAP_LOCAL_0x04
    SetFlag FLAG_MAP_LOCAL_0x05
    SetFlag FLAG_MAP_LOCAL_0x06
    SetFlag FLAG_MAP_LOCAL_0x07
    SetFlag FLAG_MAP_LOCAL_0x08
    SetFlag FLAG_MAP_LOCAL_0x09
    SetFlag FLAG_MAP_LOCAL_0x0A
    SetFlag FLAG_MAP_LOCAL_0x0B
    SetFlag FLAG_MAP_LOCAL_0x0C
    SetFlag FLAG_MAP_LOCAL_0x0D
    GoToIfEq VAR_SOVEREIGN_MANSION_SIEGE_STATE, 0, PokemonMansion_SovereignSetSiegeVisibilityEnd
    GoToIfGe VAR_SOVEREIGN_MANSION_SIEGE_STATE, 6, PokemonMansion_SovereignSetSiegeVisibilityEnd
    SetFlag FLAG_MAP_LOCAL_0x01
    ClearFlag FLAG_MAP_LOCAL_0x02
    CallIfGe VAR_SOVEREIGN_MANSION_SIEGE_STATE, 3, PokemonMansion_SovereignShowRival
    CallIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_1, PokemonMansion_SovereignShowRoom1
    CallIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_2, PokemonMansion_SovereignShowRoom2
    CallIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_3, PokemonMansion_SovereignShowRoom3
    CallIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_OFFICE, PokemonMansion_SovereignShowOffice
    GoToIfGe VAR_SOVEREIGN_MANSION_SIEGE_STATE, 5, PokemonMansion_SovereignSetSiegeVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_0x08
    CallIfEq VAR_SOVEREIGN_MANSION_SIEGE_STATE, 4, PokemonMansion_SovereignShowClefairy1
    CallIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_1, PokemonMansion_SovereignShowClefairy2
    CallIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_2, PokemonMansion_SovereignShowClefairy3
    CallIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_3, PokemonMansion_SovereignShowHappiny
    CallIfSet FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_OFFICE, PokemonMansion_SovereignShowClefairy4
PokemonMansion_SovereignSetSiegeVisibilityEnd:
    Return

PokemonMansion_SovereignShowRival:
    ClearFlag FLAG_MAP_LOCAL_0x03
    Return

PokemonMansion_SovereignShowRoom1:
    ClearFlag FLAG_MAP_LOCAL_0x04
    Return

PokemonMansion_SovereignShowRoom2:
    ClearFlag FLAG_MAP_LOCAL_0x05
    Return

PokemonMansion_SovereignShowRoom3:
    ClearFlag FLAG_MAP_LOCAL_0x06
    Return

PokemonMansion_SovereignShowOffice:
    ClearFlag FLAG_MAP_LOCAL_0x07
    Return

PokemonMansion_SovereignShowClefairy1:
    ClearFlag FLAG_MAP_LOCAL_0x09
    Return

PokemonMansion_SovereignShowClefairy2:
    ClearFlag FLAG_MAP_LOCAL_0x0A
    Return

PokemonMansion_SovereignShowClefairy3:
    ClearFlag FLAG_MAP_LOCAL_0x0B
    Return

PokemonMansion_SovereignShowHappiny:
    ClearFlag FLAG_MAP_LOCAL_0x0C
    Return

PokemonMansion_SovereignShowClefairy4:
    ClearFlag FLAG_MAP_LOCAL_0x0D
    Return

PokemonMansion_SovereignSiegeLost:
    BlackOutFromBattle
    ReleaseAll
    End

@ Three grunts in a row (Renegade's 952-954), and the challenge is to beat them in exactly 6 turns in all. The grunt
@ doesn't keep the promise, but a Clefairy slips out behind him.
PokemonMansion_SovereignGruntTrio:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfGe VAR_SOVEREIGN_MANSION_SIEGE_STATE, 4, PokemonMansion_SovereignTrioNotAllowed
    GetPlayerDir VAR_RESULT
    CallIfEq VAR_RESULT, DIR_NORTH, PokemonMansion_SovereignTrioPlayerFromSouth
    CallIfEq VAR_RESULT, DIR_SOUTH, PokemonMansion_SovereignTrioPlayerFromNorth
    SetVar VAR_0x8005, 0
    Message PokemonMansion_Text_SovereignTrioChallenge
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, PokemonMansion_SovereignTrioDeclined
    PlayTrainerEncounterBGM TRAINER_SOVEREIGN_GRUNT_MANSION_TRIO_1
    Message PokemonMansion_Text_SovereignTrioVeryWell
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_MANSION_TRIO_1
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_SovereignSiegeLost
    AddVar VAR_0x8005, VAR_TOTAL_TURNS_LAST_BATTLE
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_TRIO, PokemonMansion_SovereignMovement_TrioOut
    WaitMovement
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_TRIO, PokemonMansion_SovereignMovement_TrioIn
    WaitMovement
    BufferNumber 1, VAR_0x8005
    Message PokemonMansion_Text_SovereignTrioSoFar
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_MANSION_TRIO_2
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_SovereignSiegeLost
    AddVar VAR_0x8005, VAR_TOTAL_TURNS_LAST_BATTLE
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_TRIO, PokemonMansion_SovereignMovement_TrioOut
    WaitMovement
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_TRIO, PokemonMansion_SovereignMovement_TrioIn
    WaitMovement
    BufferNumber 1, VAR_0x8005
    Message PokemonMansion_Text_SovereignTrioHadTurns
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_MANSION_TRIO_3
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_SovereignSiegeLost
    AddVar VAR_0x8005, VAR_TOTAL_TURNS_LAST_BATTLE
    BufferNumber 1, VAR_0x8005
    Message PokemonMansion_Text_SovereignTrioBeatAll
    GoToIfNe VAR_0x8005, 6, PokemonMansion_SovereignTrioNotSix
    Message PokemonMansion_Text_SovereignTrioNoPromises
    WaitButton
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_TRIO, PokemonMansion_SovereignMovement_TrioStartled
    WaitMovement
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_TRIO, PokemonMansion_SovereignMovement_StepBackEast
    ApplyMovement LOCALID_PLAYER, PokemonMansion_SovereignMovement_StepBackEast
    WaitMovement
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    SetObjectEventPos LOCALID_SOVEREIGN_CLEFAIRY_RUN, 1, 7
    AddObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    LockObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    PlayCry SPECIES_CLEFAIRY
    Message PokemonMansion_Text_SovereignClefairyCry
    WaitCry
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_RUN, PokemonMansion_SovereignMovement_ClefairyEscape
    WaitMovement
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_TRIO, PokemonMansion_SovereignMovement_FaceEast
    WaitMovement
    Message PokemonMansion_Text_SovereignSpacePokemonEscaped
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_TRIO, PokemonMansion_SovereignMovement_TrioBackToPlace
    WaitMovement
    SetVar VAR_SOVEREIGN_MANSION_SIEGE_STATE, 4
    ClearFlag FLAG_MAP_LOCAL_0x09
    AddObject LOCALID_SOVEREIGN_CLEFAIRY_1
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    ReleaseAll
    End

PokemonMansion_SovereignTrioPlayerFromSouth:
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_TRIO, PokemonMansion_SovereignMovement_FaceEast
    ApplyMovement LOCALID_PLAYER, PokemonMansion_SovereignMovement_PlayerAroundFromSouth
    WaitMovement
    Return

PokemonMansion_SovereignTrioPlayerFromNorth:
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_TRIO, PokemonMansion_SovereignMovement_FaceEast
    ApplyMovement LOCALID_PLAYER, PokemonMansion_SovereignMovement_PlayerAroundFromNorth
    WaitMovement
    Return

PokemonMansion_SovereignTrioNotAllowed:
    Message PokemonMansion_Text_SovereignTrioNotAllowed
    GoTo PokemonMansion_SovereignWaitRelease

PokemonMansion_SovereignTrioDeclined:
    Message PokemonMansion_Text_SovereignTrioDeclined
    GoTo PokemonMansion_SovereignWaitRelease

PokemonMansion_SovereignTrioNotSix:
    Message PokemonMansion_Text_SovereignTrioNotSix
    GoTo PokemonMansion_SovereignWaitRelease

PokemonMansion_SovereignWaitRelease:
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonMansion_SovereignGruntGarden:
    NPCMessage PokemonMansion_Text_SovereignGardenGrunt
    End

PokemonMansion_SovereignClefairy:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    PlayCry SPECIES_CLEFAIRY
    Message PokemonMansion_Text_SovereignClefairyCry
    WaitCry
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonMansion_SovereignRival:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    BufferRivalName 0
    Message PokemonMansion_Text_SovereignRivalOneTurn
    GoTo PokemonMansion_SovereignWaitRelease

PokemonMansion_SovereignGruntEast:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    Message PokemonMansion_Text_SovereignEastGrunt
    GoTo PokemonMansion_SovereignWaitRelease

PokemonMansion_SovereignGruntRoom1:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    PlayTrainerEncounterBGM TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_1
    Message PokemonMansion_Text_SovereignRoom1Intro
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_1
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_SovereignSiegeLost
    SetTrainerFlag TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_1
    Message PokemonMansion_Text_SovereignRoom1Lost
    WaitButton
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_GRUNT_ROOM_1
    FadeScreenIn
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    SetObjectEventPos LOCALID_SOVEREIGN_CLEFAIRY_RUN, 5, 6
    AddObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    LockObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    PlayCry SPECIES_CLEFAIRY
    Message PokemonMansion_Text_SovereignClefairyCry
    WaitCry
    CloseMessage
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_NORTH, PokemonMansion_SovereignRoom1Run1
    GoToIfEq VAR_RESULT, DIR_SOUTH, PokemonMansion_SovereignRoom1Run1
    GoToIfEq VAR_RESULT, DIR_EAST, PokemonMansion_SovereignRoom1Run1
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_RUN, PokemonMansion_SovereignMovement_RunSouthEast
    WaitMovement
    GoTo PokemonMansion_SovereignRoom1Ran

PokemonMansion_SovereignRoom1Run1:
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_RUN, PokemonMansion_SovereignMovement_RunEast
    WaitMovement
PokemonMansion_SovereignRoom1Ran:
    ClearFlag FLAG_MAP_LOCAL_0x0A
    AddObject LOCALID_SOVEREIGN_CLEFAIRY_2
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    ReleaseAll
    End

PokemonMansion_SovereignGruntRoom2:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    PlayTrainerEncounterBGM TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_2
    Message PokemonMansion_Text_SovereignRoom2Intro
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_2
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_SovereignSiegeLost
    SetTrainerFlag TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_2
    Message PokemonMansion_Text_SovereignRoom2Lost
    WaitButton
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_GRUNT_ROOM_2
    FadeScreenIn
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    SetObjectEventPos LOCALID_SOVEREIGN_CLEFAIRY_RUN, 13, 6
    AddObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    LockObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    PlayCry SPECIES_CLEFAIRY
    Message PokemonMansion_Text_SovereignClefairyCry
    WaitCry
    CloseMessage
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_NORTH, PokemonMansion_SovereignRoom2Run1
    GoToIfEq VAR_RESULT, DIR_SOUTH, PokemonMansion_SovereignRoom2Run1
    GoToIfEq VAR_RESULT, DIR_EAST, PokemonMansion_SovereignRoom2Run1
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_RUN, PokemonMansion_SovereignMovement_RunSouthEast
    WaitMovement
    GoTo PokemonMansion_SovereignRoom2Ran

PokemonMansion_SovereignRoom2Run1:
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_RUN, PokemonMansion_SovereignMovement_RunEast
    WaitMovement
PokemonMansion_SovereignRoom2Ran:
    ClearFlag FLAG_MAP_LOCAL_0x0B
    AddObject LOCALID_SOVEREIGN_CLEFAIRY_3
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    ReleaseAll
    End

PokemonMansion_SovereignGruntRoom3:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    PlayTrainerEncounterBGM TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_3
    Message PokemonMansion_Text_SovereignRoom3Intro
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_3
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_SovereignSiegeLost
    SetTrainerFlag TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_3
    Message PokemonMansion_Text_SovereignRoom3Lost
    WaitButton
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_GRUNT_ROOM_3
    FadeScreenIn
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_HAPPINY_RUN
    SetObjectEventPos LOCALID_SOVEREIGN_HAPPINY_RUN, 21, 6
    AddObject LOCALID_SOVEREIGN_HAPPINY_RUN
    LockObject LOCALID_SOVEREIGN_HAPPINY_RUN
    PlayCry SPECIES_HAPPINY
    Message PokemonMansion_Text_SovereignHappinyCry
    WaitCry
    CloseMessage
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_NORTH, PokemonMansion_SovereignRoom3Run1
    GoToIfEq VAR_RESULT, DIR_SOUTH, PokemonMansion_SovereignRoom3Run1
    GoToIfEq VAR_RESULT, DIR_EAST, PokemonMansion_SovereignRoom3Run1
    ApplyMovement LOCALID_SOVEREIGN_HAPPINY_RUN, PokemonMansion_SovereignMovement_RunSouthEast
    WaitMovement
    GoTo PokemonMansion_SovereignRoom3Ran

PokemonMansion_SovereignRoom3Run1:
    ApplyMovement LOCALID_SOVEREIGN_HAPPINY_RUN, PokemonMansion_SovereignMovement_RunEast
    WaitMovement
PokemonMansion_SovereignRoom3Ran:
    ClearFlag FLAG_MAP_LOCAL_0x0C
    AddObject LOCALID_SOVEREIGN_HAPPINY
    RemoveObject LOCALID_SOVEREIGN_HAPPINY_RUN
    ReleaseAll
    End

PokemonMansion_SovereignGruntRoom4:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    PlayTrainerEncounterBGM TRAINER_SOVEREIGN_GRUNT_MANSION_OFFICE
    Message PokemonMansion_Text_SovereignOfficeIntro
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRUNT_MANSION_OFFICE
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_SovereignSiegeLost
    SetTrainerFlag TRAINER_SOVEREIGN_GRUNT_MANSION_OFFICE
    Message PokemonMansion_Text_SovereignOfficeLost
    WaitButton
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_GRUNT_OFFICE
    FadeScreenIn
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    SetObjectEventPos LOCALID_SOVEREIGN_CLEFAIRY_RUN, 48, 6
    AddObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    LockObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    PlayCry SPECIES_CLEFAIRY
    Message PokemonMansion_Text_SovereignClefairyCry
    WaitCry
    CloseMessage
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_NORTH, PokemonMansion_SovereignRoom4Run1
    GoToIfEq VAR_RESULT, DIR_SOUTH, PokemonMansion_SovereignRoom4Run1
    GoToIfEq VAR_RESULT, DIR_WEST, PokemonMansion_SovereignRoom4Run1
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_RUN, PokemonMansion_SovereignMovement_RunSouthWest
    WaitMovement
    GoTo PokemonMansion_SovereignRoom4Ran

PokemonMansion_SovereignRoom4Run1:
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_RUN, PokemonMansion_SovereignMovement_RunWest
    WaitMovement
PokemonMansion_SovereignRoom4Ran:
    ClearFlag FLAG_MAP_LOCAL_0x0D
    AddObject LOCALID_SOVEREIGN_CLEFAIRY_4
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_RUN
    ReleaseAll
    End

@ With all four Clefairy back, the Happiny's Metronome turns into Teleport, and the grunt at the garden door is gone.
PokemonMansion_SovereignHappiny:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GoToIfNe VAR_SOVEREIGN_MANSION_SIEGE_STATE, 4, PokemonMansion_SovereignHappinyWaiting
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_1, PokemonMansion_SovereignHappinyWaiting
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_2, PokemonMansion_SovereignHappinyWaiting
    GoToIfUnset FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_OFFICE, PokemonMansion_SovereignHappinyWaiting
    PlayCry SPECIES_HAPPINY
    Message PokemonMansion_Text_SovereignHappinyInstructions
    WaitCry
    CloseMessage
    PlayCry SPECIES_CLEFAIRY
    Message PokemonMansion_Text_SovereignClefairyCry
    WaitCry
    CloseMessage
    Call PokemonMansion_SovereignClefairySpin
    PlayCry SPECIES_HAPPINY
    Message PokemonMansion_Text_SovereignHappinyWagged
    WaitCry
    CloseMessage
    PlayCry SPECIES_CLEFAIRY
    Message PokemonMansion_Text_SovereignClefairyCry
    WaitCry
    CloseMessage
    Call PokemonMansion_SovereignClefairySpin
    Message PokemonMansion_Text_SovereignMetronome
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_GARDEN, PokemonMansion_SovereignMovement_Notice
    WaitMovement
    PlaySE SEQ_SE_DP_TELE_sseq
    ApplyMovement LOCALID_SOVEREIGN_GRUNT_GARDEN, PokemonMansion_SovereignMovement_TeleportSpin
    WaitMovement
    RemoveObject LOCALID_SOVEREIGN_GRUNT_GARDEN
    WaitTime 15, VAR_RESULT
    PlayCry SPECIES_CLEFAIRY
    Message PokemonMansion_Text_SovereignClefairyCry
    WaitCry
    CloseMessage
    Call PokemonMansion_SovereignClefairySpin
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_1, PokemonMansion_SovereignMovement_Clefairy1Leave
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_3, PokemonMansion_SovereignMovement_Clefairy3Leave
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_2, PokemonMansion_SovereignMovement_Clefairy2Leave
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_4, PokemonMansion_SovereignMovement_Clefairy4Leave
    WaitMovement
    ApplyMovement LOCALID_SOVEREIGN_HAPPINY, PokemonMansion_SovereignMovement_HappinyToPlayer
    ApplyMovement LOCALID_PLAYER, PokemonMansion_SovereignMovement_FaceWest
    WaitMovement
    Message PokemonMansion_Text_SovereignHappinyHeldOut
    SetVar VAR_0x8004, ITEM_LUCKY_EGG
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    PlayCry SPECIES_HAPPINY
    Message PokemonMansion_Text_SovereignHappinyCry
    WaitCry
    WaitButton
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_HAPPINY, PokemonMansion_SovereignMovement_HappinyLeave
    WaitMovement
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_1
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_2
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_3
    RemoveObject LOCALID_SOVEREIGN_HAPPINY
    RemoveObject LOCALID_SOVEREIGN_CLEFAIRY_4
    SetVar VAR_SOVEREIGN_MANSION_SIEGE_STATE, 5
    ReleaseAll
    End

PokemonMansion_SovereignHappinyWaiting:
    PlayCry SPECIES_HAPPINY
    Message PokemonMansion_Text_SovereignHappinyWaiting
    WaitCry
    GoTo PokemonMansion_SovereignWaitRelease

PokemonMansion_SovereignClefairySpin:
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_1, PokemonMansion_SovereignMovement_Spin1
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_2, PokemonMansion_SovereignMovement_Spin2
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_3, PokemonMansion_SovereignMovement_Spin3
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY_4, PokemonMansion_SovereignMovement_Spin3
    WaitMovement
    Return

@ Saturn comes out of the Trophy Garden with Mr. Backlot, and Barry teams up with the player. Winning ends the siege.
PokemonMansion_SovereignCoordEvent_Saturn:
    LockAll
    RemoveObject LOCALID_SOVEREIGN_RIVAL_SCENE
    SetObjectEventPos LOCALID_SOVEREIGN_RIVAL_SCENE, 42, 7
    AddObject LOCALID_SOVEREIGN_RIVAL_SCENE
    LockObject LOCALID_SOVEREIGN_RIVAL_SCENE
    BufferRivalName 0
    BufferPlayerName 1
    Message PokemonMansion_Text_SovereignRivalCallsPlayer
    WaitButton
    CloseMessage
    ApplyMovement LOCALID_PLAYER, PokemonMansion_SovereignMovement_Notice
    WaitMovement
    ApplyMovement LOCALID_SOVEREIGN_RIVAL_SCENE, PokemonMansion_SovereignMovement_RivalToPlayer
    ApplyMovement LOCALID_PLAYER, PokemonMansion_SovereignMovement_PlayerToRival
    WaitMovement
    Message PokemonMansion_Text_SovereignRivalWhew
    CloseMessage
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_SOVEREIGN_SATURN
    SetObjectEventPos LOCALID_SOVEREIGN_SATURN, 33, 3
    AddObject LOCALID_SOVEREIGN_SATURN
    LockObject LOCALID_SOVEREIGN_SATURN
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_SOVEREIGN_SATURN, PokemonMansion_SovereignMovement_Notice
    ApplyMovement LOCALID_SOVEREIGN_RIVAL_SCENE, PokemonMansion_SovereignMovement_FaceNorth
    ApplyMovement LOCALID_PLAYER, PokemonMansion_SovereignMovement_FaceNorth
    WaitMovement
    Message PokemonMansion_Text_SovereignSaturnWhoAreYou
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_SATURN, PokemonMansion_SovereignMovement_SaturnStepOut
    WaitMovement
    Message PokemonMansion_Text_SovereignSaturnComeAlong
    WaitButton
    CloseMessage
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_SOVEREIGN_BACKLOT
    SetObjectEventPos LOCALID_SOVEREIGN_BACKLOT, 33, 3
    AddObject LOCALID_SOVEREIGN_BACKLOT
    LockObject LOCALID_SOVEREIGN_BACKLOT
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    Message PokemonMansion_Text_SovereignBacklotPoorMansion
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_SATURN, PokemonMansion_SovereignMovement_WalkSouth2
    ApplyMovement LOCALID_SOVEREIGN_BACKLOT, PokemonMansion_SovereignMovement_WalkSouth2
    WaitMovement
    Message PokemonMansion_Text_SovereignSaturnRecognize
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_SATURN, PokemonMansion_SovereignMovement_FaceNorth
    WaitMovement
    Message PokemonMansion_Text_SovereignSaturnEject
    Message PokemonMansion_Text_SovereignBacklotPreferNot
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_SATURN, PokemonMansion_SovereignMovement_FaceSouth
    ApplyMovement LOCALID_SOVEREIGN_BACKLOT, PokemonMansion_SovereignMovement_BacklotTakesPlace
    WaitMovement
    ApplyMovement LOCALID_SOVEREIGN_RIVAL_SCENE, PokemonMansion_SovereignMovement_FaceWest
    WaitMovement
    BufferRivalName 0
    BufferPlayerName 1
    Message PokemonMansion_Text_SovereignRivalTeamUp
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_RIVAL_SCENE, PokemonMansion_SovereignMovement_FaceNorth
    WaitMovement
    GetPlayerStarterSpecies VAR_RESULT
    GoToIfEq VAR_RESULT, SPECIES_TURTWIG, PokemonMansion_SovereignTagBattleTurtwig
    GoToIfEq VAR_RESULT, SPECIES_CHIMCHAR, PokemonMansion_SovereignTagBattleChimchar
    StartTagBattle TRAINER_RIVAL_ROUTE_209_PIPLUP, TRAINER_SOVEREIGN_SATURN_POKEMON_MANSION, TRAINER_SOVEREIGN_BACKLOT_POKEMON_MANSION
    GoTo PokemonMansion_SovereignAfterTagBattle

PokemonMansion_SovereignTagBattleTurtwig:
    StartTagBattle TRAINER_RIVAL_ROUTE_209_TURTWIG, TRAINER_SOVEREIGN_SATURN_POKEMON_MANSION, TRAINER_SOVEREIGN_BACKLOT_POKEMON_MANSION
    GoTo PokemonMansion_SovereignAfterTagBattle

PokemonMansion_SovereignTagBattleChimchar:
    StartTagBattle TRAINER_RIVAL_ROUTE_209_CHIMCHAR, TRAINER_SOVEREIGN_SATURN_POKEMON_MANSION, TRAINER_SOVEREIGN_BACKLOT_POKEMON_MANSION
PokemonMansion_SovereignAfterTagBattle:
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonMansion_SovereignSiegeLost
    Message PokemonMansion_Text_SovereignSaturnLost
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_SATURN
    SetVar VAR_SOVEREIGN_MANSION_SIEGE_STATE, 6
    RemoveObject LOCALID_SOVEREIGN_RIVAL
    RemoveObject LOCALID_SOVEREIGN_GRUNT_EAST
    RemoveObject LOCALID_SOVEREIGN_GRUNT_TRIO
    ClearFlag FLAG_MAP_LOCAL_0x01
    AddObject LOCALID_MAID_FAR_WEST
    AddObject LOCALID_MAID_FAR_EAST
    FadeScreenIn
    WaitFadeScreen
    ApplyMovement LOCALID_PLAYER, PokemonMansion_SovereignMovement_FaceEast
    ApplyMovement LOCALID_SOVEREIGN_RIVAL_SCENE, PokemonMansion_SovereignMovement_FaceWest
    WaitMovement
    BufferRivalName 0
    BufferPlayerName 1
    Message PokemonMansion_Text_SovereignRivalOffToSolaceon
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_RIVAL_SCENE, PokemonMansion_SovereignMovement_RivalLeave
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_SOVEREIGN_RIVAL_SCENE
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_SOVEREIGN_BACKLOT, PokemonMansion_SovereignMovement_BacklotToPlayer
    WaitMovement
    Message PokemonMansion_Text_SovereignBacklotThanks
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_BACKLOT, PokemonMansion_SovereignMovement_BacklotLeave
    WaitMovement
    RemoveObject LOCALID_SOVEREIGN_BACKLOT
    ReleaseAll
    End

    .balign 4, 0
PokemonMansion_SovereignMovement_Notice:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_FaceNorth:
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_FaceSouth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_FaceWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_FaceEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_TrioOut:
    WalkOnSpotNormalWest
    SetInvisible
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_TrioIn:
    SetVisible
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_TrioStartled:
    WalkOnSpotNormalWest
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_StepBackEast:
    LockDir
    WalkNormalEast
    UnlockDir
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_ClefairyEscape:
    WalkFastSouth
    WalkFastEast 12
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_TrioBackToPlace:
    WalkNormalWest
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_PlayerAroundFromSouth:
    WalkNormalEast
    WalkNormalNorth
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_PlayerAroundFromNorth:
    WalkNormalEast
    WalkNormalSouth
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_RunEast:
    WalkFastEast 2
    WalkFastSouth
    WalkFastEast 10
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_RunSouthEast:
    WalkFastSouth
    WalkFastEast 12
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_RunWest:
    WalkFastWest 2
    WalkFastSouth
    WalkFastWest 10
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_RunSouthWest:
    WalkFastSouth
    WalkFastWest 12
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_Spin1:
    FaceSouth 4
    FaceWest 4
    FaceNorth 4
    FaceEast 4
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_Spin2:
    FaceSouth 4
    FaceEast 4
    FaceNorth 4
    FaceWest 4
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_Spin3:
    FaceWest 4
    FaceSouth 4
    FaceEast 4
    FaceNorth 4
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_TeleportSpin:
    FaceWest
    FaceNorth
    FaceEast
    FaceSouth
    FaceWest
    FaceNorth
    FaceEast
    FaceSouth
    FaceWest
    FaceNorth
    FaceEast
    FaceSouth
    FaceWest
    FaceNorth
    FaceEast
    FaceSouth
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_Clefairy1Leave:
    WalkFastSouth 4
    WalkFastWest 10
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_Clefairy3Leave:
    WalkFastSouth 3
    WalkFastWest 10
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_Clefairy2Leave:
    WalkFastSouth 4
    WalkFastEast 10
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_Clefairy4Leave:
    WalkFastSouth 3
    WalkFastEast 10
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_HappinyToPlayer:
    WalkFastWest
    WalkFastSouth
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_HappinyLeave:
    WalkFastSouth 2
    WalkFastWest 10
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_RivalToPlayer:
    WalkFastWest 8
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_PlayerToRival:
    WalkNormalSouth 4
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_SaturnStepOut:
    WalkNormalSouth
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_WalkSouth2:
    WalkNormalSouth 2
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_BacklotTakesPlace:
    WalkNormalEast
    WalkNormalSouth
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_RivalLeave:
    WalkFastSouth 2
    WalkFastWest
    WalkFastSouth 7
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_BacklotToPlayer:
    WalkNormalSouth
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
PokemonMansion_SovereignMovement_BacklotLeave:
    WalkNormalEast 10
    EndMovement

    .balign 4, 0
