#include "macros/scrcmd.inc"
#include "res/text/bank/snowpoint_city.h"
#include "res/field/events/events_snowpoint_city.h"


    ScriptEntry SnowpointCity_OnTransition
    ScriptEntry SnowpointCity_TempleGuard
    ScriptEntry SnowpointCity_CoordEvent_TempleGuard
    ScriptEntry SnowpointCity_Candice
    ScriptEntry SnowpointCity_AceTrainerSnowF
    ScriptEntry SnowpointCity_SnowpointNPCF1
    ScriptEntry SnowpointCity_SnowpointNPCF2
    ScriptEntry SnowpointCity_SnowpointNPCM
    ScriptEntry SnowpointCity_Sailor
    ScriptEntry SnowpointCity_MapSignpost
    ScriptEntry SnowpointCity_GymSignpost
    ScriptEntry SnowpointCity_SailorSSSpiral
    ScriptEntry SnowpointCity_SovereignIceMaster
    ScriptEntry SnowpointCity_SovereignGymGuide
    ScriptEntry SnowpointCity_SovereignTempleGuards
    ScriptEntry SnowpointCity_SovereignCoordEvent_Tremor
    ScriptEntryEnd

SnowpointCity_OnTransition:
    Call SnowpointCity_SovereignSetTempleVisibility
    GoToIfGe VAR_SNOWPOINT_CITY_STATE, 1, SnowpointCity_HideCandice
    End

SnowpointCity_HideCandice:
    SetFlag FLAG_HIDE_SNOWPOINT_CITY_CANDICE
    End

SnowpointCity_CoordEvent_TempleGuard:
    LockAll
    ApplyMovement LOCALID_TEMPLE_GUARD, SnowpointCity_Movement_TempleGuardWalkOnSpotWest
    WaitMovement
    Message SnowpointCity_Text_OnlyChosenMayEnterTemple
    CloseMessage
    GetNationalDexEnabled VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SnowpointCity_CheckAllowEnterTemple
    GoTo SnowpointCity_TempleGuardBlockPlayer
    End

SnowpointCity_TempleGuardBlockPlayer:
    ApplyMovement LOCALID_TEMPLE_GUARD, SnowpointCity_Movement_TempleGuardWalkOnSpotSOuth
    ApplyMovement LOCALID_PLAYER, SnowpointCity_Movement_PlayerWalkSouth
    WaitMovement
    ReleaseAll
    End

SnowpointCity_CheckAllowEnterTemple:
    GoToIfUnset FLAG_GAME_COMPLETED, SnowpointCity_TempleGuardBlockPlayer
    GoTo SnowpointCity_CallAllowEnterTemple

    .balign 4, 0
SnowpointCity_Movement_TempleGuardWalkOnSpotWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_TempleGuardWalkOnSpotSOuth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_PlayerWalkSouth:
    WalkNormalSouth
    EndMovement

SnowpointCity_TempleGuard:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GetNationalDexEnabled VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SnowpointCity_TempleGuardNationalDex
    GoTo SnowpointCity_MayNotEnterTemple

SnowpointCity_MayNotEnterTemple:
    Message SnowpointCity_Text_OnlyChosenMayEnterTemple2
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_TempleGuardNationalDex:
    GoToIfUnset FLAG_GAME_COMPLETED, SnowpointCity_MayNotEnterTemple
    GoToIfEq VAR_SNOWPOINT_CITY_STATE, 0, SnowpointCity_OnlyChosenMayEnterTemple
    Message SnowpointCity_Text_BuiltInAncientTimes
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_OnlyChosenMayEnterTemple:
    Message SnowpointCity_Text_OnlyChosenMayEnterTemple
    CloseMessage
    Call SnowpointCity_AllowEnterTemple
    ReleaseAll
    End

SnowpointCity_CallAllowEnterTemple:
    Call SnowpointCity_AllowEnterTemple
    ReleaseAll
    End

SnowpointCity_AllowEnterTemple:
    WaitTime 30, VAR_RESULT
    ClearFlag FLAG_HIDE_SNOWPOINT_CITY_CANDICE
    AddObject LOCALID_CANDICE
    ApplyMovement LOCALID_CANDICE, SnowpointCity_Movement_CandiceEnter
    WaitMovement
    Message SnowpointCity_Text_LetThatPersonIn
    CloseMessage
    ApplyMovement LOCALID_PLAYER, SnowpointCity_Movement_PlayerWalkOnSpotSouth
    ApplyMovement LOCALID_TEMPLE_GUARD, SnowpointCity_Movement_TempleGuardFaceSouth
    WaitMovement
    SetVar VAR_SNOWPOINT_CITY_STATE, 1
    Message SnowpointCity_Text_EnjoyYourExploring
    WaitButton
    CloseMessage
    Return

    .balign 4, 0
SnowpointCity_Movement_TempleGuardFaceSouth:
    FaceSouth
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_PlayerWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_CandiceEnter:
    WalkNormalNorth 7
    EndMovement

SnowpointCity_Candice:
    NPCMessage SnowpointCity_Text_EnjoyYourExploring
    End

SnowpointCity_AceTrainerSnowF:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CheckItem ITEM_HM08, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SnowpointCity_AceTrainerSnowFTremors
    Message SnowpointCity_Text_TownIsFreezingCold
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_AceTrainerSnowFTremors:
    Message SnowpointCity_Text_SovereignTremorsFreezingCold
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SnowpointNPCF1:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CheckItem ITEM_HM08, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SnowpointCity_SnowpointNPCF1Tremors
    Message SnowpointCity_Text_ScarfLooksWarm
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SnowpointNPCF1Tremors:
    Message SnowpointCity_Text_SovereignTremorsScarf
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SnowpointNPCF2:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CheckItem ITEM_HM08, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SnowpointCity_SnowpointNPCF2Tremors
    Message SnowpointCity_Text_CandiceIsTeachingMe
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SnowpointNPCF2Tremors:
    Message SnowpointCity_Text_SovereignTremorsCandice
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SnowpointNPCM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CheckItem ITEM_HM08, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SnowpointCity_SovereignNPCMTremors
    GoToIfGe VAR_SNOWPOINT_CITY_STATE, 1, SnowpointCity_PokemonDraggedCityHere
    Message SnowpointCity_Text_IWantToLookAroundTemple
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_PokemonDraggedCityHere:
    Message SnowpointCity_Text_PokemonDraggedCityHere
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_Sailor:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CheckItem ITEM_HM08, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SnowpointCity_SailorTremors
    Message SnowpointCity_Text_NothingExceptionalHere
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SailorTremors:
    Message SnowpointCity_Text_SovereignTremorsExceptional
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_MapSignpost:
    ShowMapSign SnowpointCity_Text_MapSign
    End

SnowpointCity_GymSignpost:
    ShowScrollingSign SnowpointCity_Text_SignPokemonGym
    End

SnowpointCity_SailorSSSpiral:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfUnset FLAG_GAME_COMPLETED, SnowpointCity_ILookForwardToAGreatTrainer
    Message SnowpointCity_Text_SailToBattleZone
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, SnowpointCity_TakeShipToBattleZone
    GoToIfEq VAR_RESULT, MENU_NO, SnowpointCity_YouCantGoUsingSurf
    End

SnowpointCity_ILookForwardToAGreatTrainer:
    Message SnowpointCity_Text_ILookForwardToAGreatTrainer
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_YouCantGoUsingSurf:
    Message SnowpointCity_Text_YouCantGoUsingSurf
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_TakeShipToBattleZone:
    CallIfUnset FLAG_SAILED_TO_BATTLE_ZONE, SnowpointCity_Cynthia
    Message SnowpointCity_Text_LetsSetSail
    CloseMessage
    Call SnowpointCity_SailorEnterShip
    Call SnowpointCity_PlayerEnterShip
    TakeShipFromSnowpoint DIR_EAST, MAP_HEADER_FIGHT_AREA, 623, 434
    ReleaseAll
    End

SnowpointCity_Cynthia:
    ClearFlag FLAG_HIDE_SNOWPOINT_CITY_CYNTHIA
    AddObject LOCALID_CYNTHIA
    LockObject LOCALID_CYNTHIA
    CloseMessage
    ApplyMovement LOCALID_CYNTHIA, SnowpointCity_Movement_CynthiaEnter
    WaitMovement
    Message SnowpointCity_Text_ImGladIWaited
    ApplyMovement LOCALID_PLAYER, SnowpointCity_Movement_PlayerNoticeCynthia
    WaitMovement
    CloseMessage
    ApplyMovement LOCALID_CYNTHIA, SnowpointCity_Movement_CynthiaWalkEast
    WaitMovement
    WaitTime 15, VAR_RESULT
    Message SnowpointCity_Text_GoodThatOurWorldChanges
    CloseMessage
    ApplyMovement LOCALID_CYNTHIA, SnowpointCity_Movement_CynthiaWalkWestOnSpotSouth
    WaitMovement
    Message SnowpointCity_Text_TravelToFarOffPlaces
    CloseMessage
    ApplyMovement LOCALID_CYNTHIA, SnowpointCity_Movement_CynthiaLeave
    WaitMovement
    RemoveObject LOCALID_CYNTHIA
    ApplyMovement LOCALID_PLAYER, SnowpointCity_Movement_PlayerWalkOnSpotSouth2
    WaitMovement
    SetFlag FLAG_SAILED_TO_BATTLE_ZONE
    Return

    .balign 4, 0
SnowpointCity_Movement_PlayerNoticeCynthia:
    EmoteExclamationMark
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_PlayerWalkOnSpotSouth2:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_CynthiaEnter:
    WalkNormalWest 4
    WalkNormalSouth 2
    WalkNormalWest 6
    WalkNormalSouth 2
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_CynthiaWalkEast:
    WalkNormalEast
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_CynthiaWalkWestOnSpotSouth:
    WalkNormalWest
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_CynthiaLeave:
    WalkNormalNorth 2
    WalkNormalEast 3
    WalkNormalNorth 2
    WalkNormalEast 7
    EndMovement

SnowpointCity_SailorEnterShip:
    ApplyMovement LOCALID_SAILOR_SS_SPIRAL, SnowpointCity_Movement_SailorSSSpiralFaceSouth
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_SAILOR_SS_SPIRAL, SnowpointCity_Movement_SetInvisible
    WaitMovement
    Return

SnowpointCity_PlayerEnterShip:
    ApplyMovement LOCALID_PLAYER, SnowpointCity_Movement_PlayerWalkToShip
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_PLAYER, SnowpointCity_Movement_SetInvisible
    WaitMovement
    Return

    .balign 4, 0
SnowpointCity_Movement_SailorSSSpiralFaceSouth:
    FaceSouth
    Delay15
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_SetInvisible:
    SetInvisible
    EndMovement

    .balign 4, 0
SnowpointCity_Movement_PlayerWalkToShip:
    WalkNormalSouth
    Delay15
    EndMovement

@ Sovereign (E10, Renegade's Type Masters): the Ice-type Master battles one Ice-type Pokémon, alone in the party, for
@ the Icicle Plate (Renegade's trainer 1049).
SnowpointCity_SovereignIceMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_ICE_MASTER, SnowpointCity_SovereignIceMasterThanks
    Message SnowpointCity_Text_SovereignIceMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, SnowpointCity_SovereignIceMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_ICE, SnowpointCity_SovereignIceMasterAsk
    GoToIfEq VAR_0x8005, TYPE_ICE, SnowpointCity_SovereignIceMasterAsk
SnowpointCity_SovereignIceMasterOnlyOne:
    Message SnowpointCity_Text_SovereignIceMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SovereignIceMasterAsk:
    Message SnowpointCity_Text_SovereignIceMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, SnowpointCity_SovereignIceMasterDecline
    Message SnowpointCity_Text_SovereignIceMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_ICE_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SnowpointCity_SovereignIceMasterLost
    Message SnowpointCity_Text_SovereignIceMasterWin
    SetVar VAR_0x8004, ITEM_ICICLE_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_ICE_MASTER
SnowpointCity_SovereignIceMasterThanks:
    Message SnowpointCity_Text_SovereignIceMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SovereignIceMasterDecline:
    Message SnowpointCity_Text_SovereignIceMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SovereignIceMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message SnowpointCity_Text_SovereignIceMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    

@ Sovereign (E10 part 26, Renegade's Snowpoint Temple story): Regigigas is stirring in the temple's basement and the
@ town shakes. Candice has gone down to calm it, so the Gym guide stands at the Gym door, and two Ace Trainers let only
@ the strong into the temple (Renegade's trainers 936 and 937). Once Candice has given the player HM08 down there, it's
@ all over.
SnowpointCity_SovereignSetTempleVisibility:
    SetFlag FLAG_MAP_LOCAL_0x01
    CheckItem ITEM_HM08, 1, VAR_MAP_LOCAL_0x02
    GoToIfEq VAR_MAP_LOCAL_0x02, TRUE, SnowpointCity_SovereignTremorsOver
    ClearFlag FLAG_MAP_LOCAL_0x01
    Return

SnowpointCity_SovereignTremorsOver:
    SetVar VAR_MAP_LOCAL_0x01, 9
    Return

SnowpointCity_SovereignCoordEvent_Tremor:
    LockAll
    ScrCmd_29F 1
    AddVar VAR_MAP_LOCAL_0x01, 1
    ReleaseAll
    End

SnowpointCity_SovereignGymGuide:
    NPCMessage SnowpointCity_Text_SovereignGymGuide
    End

SnowpointCity_SovereignNPCMTremors:
    Message SnowpointCity_Text_SovereignTremorsTemple
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SovereignTempleGuards:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message SnowpointCity_Text_SovereignGuardsChallenge
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, SnowpointCity_SovereignTempleGuardsDeclined
    GetPartyCount VAR_RESULT
    GoToIfLt VAR_RESULT, 2, SnowpointCity_SovereignTempleGuardsNeedTwo
    Message SnowpointCity_Text_SovereignGuardsBegin
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_ARAN_SNOWPOINT_TEMPLE, TRAINER_SOVEREIGN_NEPHENEE_SNOWPOINT_TEMPLE
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SnowpointCity_SovereignTempleGuardsLost
    SetTrainerFlag TRAINER_SOVEREIGN_ARAN_SNOWPOINT_TEMPLE
    SetTrainerFlag TRAINER_SOVEREIGN_NEPHENEE_SNOWPOINT_TEMPLE
    Message SnowpointCity_Text_SovereignGuardsYouMayEnter
    WaitButton
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_ARAN
    RemoveObject LOCALID_TEMPLE_GUARD
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

SnowpointCity_SovereignTempleGuardsNeedTwo:
    Message SnowpointCity_Text_SovereignGuardsNeedTwo
    WaitButton
SnowpointCity_SovereignTempleGuardsDeclined:
    CloseMessage
    ReleaseAll
    End

SnowpointCity_SovereignTempleGuardsLost:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
