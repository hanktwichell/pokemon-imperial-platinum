#include "macros/scrcmd.inc"
#include "res/text/bank/floaroma_meadow.h"
#include "res/field/events/events_floaroma_meadow.h"
#include "constants/sovereign_totem_trials.h"


    ScriptEntry FloaromaMeadow_OnTransition
    ScriptEntry FloaromaMeadow_CoordEvent_Grunts
    ScriptEntry FloaromaMeadow_Grunt_Unused
    ScriptEntry FloaromaMeadow_Grunt_Unused
    ScriptEntry FloaromaMeadow_PokefanM
    ScriptEntry FloaromaMeadow_Dummy6
    ScriptEntry FloaromaMeadow_ItemWorksKey
    ScriptEntry FloaromaMeadow_TotemRibombee
    ScriptEntry FloaromaMeadow_OnLoad
    ScriptEntry FloaromaMeadow_LegendaryTapuBulu
    ScriptEntry FloaromaMeadow_SovereignGrassMaster
    ScriptEntryEnd

FloaromaMeadow_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_FLOAROMA_MEADOW
    @ Sovereign: Totem Ribombee's trial opens once Mars is beaten at the Valley Windworks.
    CallIfSet FLAG_SOVEREIGN_TOTEM_TRIAL_RIBOMBEE, FloaromaMeadow_HideTotemRibombee
    CallIfLt VAR_VALLEY_WINDWORKS_STATE, 2, FloaromaMeadow_HideTotemRibombee
    Call FloaromaMeadow_SovereignSetTapuBuluVisibility
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Tapu Bulu stands among the flowers of the north field once
@ the Alola Chronicle is open (VAR_SOVEREIGN_CHRONICLE 3), until it's caught.
FloaromaMeadow_SovereignSetTapuBuluVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, FloaromaMeadow_SovereignSetTapuBuluVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_TAPU_BULU, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, FloaromaMeadow_SovereignSetTapuBuluVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
FloaromaMeadow_SovereignSetTapuBuluVisibilityEnd:
    Return

FloaromaMeadow_HideTotemRibombee:
    SetFlag FLAG_MAP_LOCAL_HIDE_TOTEM
    Return

FloaromaMeadow_OnLoad:
    GoToIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, FloaromaMeadow_RemoveTotemRibombee
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, FloaromaMeadow_RemoveLegendaryTapuBulu
    End

FloaromaMeadow_RemoveLegendaryTapuBulu:
    RemoveObject LOCALID_LEGENDARY_TAPU_BULU
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

FloaromaMeadow_LegendaryTapuBulu:
    SetVar VAR_0x8004, SPECIES_TAPU_BULU
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

FloaromaMeadow_RemoveTotemRibombee:
    RemoveObject LOCALID_TOTEM_RIBOMBEE
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    End

@ Sovereign (decision 18): the Totem Ribombee trial.
FloaromaMeadow_TotemRibombee:
    SetVar VAR_0x8004, TOTEM_TRIAL_RIBOMBEE
    Common_SovereignTotemTrial
    End

FloaromaMeadow_CoordEvent_Grunts:
    LockAll
    Call FloaromaMeadow_GruntsNoticePlayer
    StartTrainerBattle TRAINER_GALACTIC_GRUNT_FLOAROMA_MEADOW_1
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, FloaromaMeadow_BlackOut
    Call FloaromaMeadow_DefeatedGrunt1
    StartTrainerBattle TRAINER_GALACTIC_GRUNT_FLOAROMA_MEADOW_2
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, FloaromaMeadow_BlackOut
    Call FloaromaMeadow_DefeatedGrunts
    SetFlag FLAG_ALT_MUSIC_FLOAROMA_MEADOW
    ReleaseAll
    End

FloaromaMeadow_BlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
FloaromaMeadow_Movement_GruntNoticePlayer:
    WalkOnSpotNormalSouth
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
FloaromaMeadow_Movement_GruntWestWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
FloaromaMeadow_Movement_GruntWestWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

FloaromaMeadow_Movement_Unused:
    WalkNormalNorth 9
    EndMovement

FloaromaMeadow_Movement_Unused2:
    WalkNormalNorth 9
    EndMovement

    .balign 4, 0
FloaromaMeadow_Movement_PokefanMWalkToPlayerX12:
    WalkNormalSouth
    WalkOnSpotNormalEast
    Delay8 3
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
FloaromaMeadow_Movement_PokefanMWalkToPlayerX13:
    WalkNormalSouth
    WalkOnSpotNormalEast
    Delay8 3
    WalkNormalEast
    WalkOnSpotNormalSouth
    EndMovement

FloaromaMeadow_GruntsNoticePlayer:
    Message FloaromaMeadow_Text_HandOverThatHoney
    Message FloaromaMeadow_Text_DoAsWeSay
    ApplyMovement LOCALID_GRUNT_M_WEST, FloaromaMeadow_Movement_GruntNoticePlayer
    ApplyMovement LOCALID_GRUNT_M_EAST, FloaromaMeadow_Movement_GruntNoticePlayer
    WaitMovement
    Message FloaromaMeadow_Text_WhatllWeDo
    Message FloaromaMeadow_Text_EnsureTheBratStaysQuiet
    CloseMessage
    Return

FloaromaMeadow_DefeatedGrunt1:
    ApplyMovement LOCALID_GRUNT_M_WEST, FloaromaMeadow_Movement_GruntWestWalkOnSpotEast
    WaitMovement
    Message FloaromaMeadow_Text_ThisIsSoLame
    CloseMessage
    ApplyMovement LOCALID_GRUNT_M_WEST, FloaromaMeadow_Movement_GruntWestWalkOnSpotSouth
    WaitMovement
    Message FloaromaMeadow_Text_ImUpNextHeheheh
    CloseMessage
    Return

FloaromaMeadow_DefeatedGrunts:
    Message FloaromaMeadow_Text_LetsGetBackToWindworks
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_GRUNT_M_WEST
    RemoveObject LOCALID_GRUNT_M_EAST
    SetVar VAR_FLOAROMA_MEADOW_STATE, 1
    FadeScreenIn
    WaitFadeScreen
    ClearFlag FLAG_HIDE_FLOAROMA_MEADOW_WORKS_KEY
    AddObject LOCALID_ITEM_WORKS_KEY
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8004, 12, FloaromaMeadow_PokefanMWalkToPlayerX12
    CallIfEq VAR_0x8004, 13, FloaromaMeadow_PokefanMWalkToPlayerX13
    RemoveObject LOCALID_ITEM_WORKS_KEY
    Message FloaromaMeadow_Text_KeyMustBeForWindworks
    SetVar VAR_0x8004, ITEM_WORKS_KEY
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_OBTAINED_FLOAROMA_MEADOW_WORKS_KEY
    Message FloaromaMeadow_Text_ThankYouTakeALot
    SetVar VAR_0x8004, ITEM_HONEY
    SetVar VAR_0x8005, 10
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, FloaromaMeadow_CantGiveHoneyBagIsFull
    Common_GiveItemQuantity
    Message FloaromaMeadow_Text_SlatherHoneyOnATree
    GoTo FloaromaMeadow_DefeatedGruntsReturn

FloaromaMeadow_CantGiveHoneyBagIsFull:
    Message FloaromaMeadow_Text_YourBagsFull
FloaromaMeadow_DefeatedGruntsReturn:
    SetFlag FLAG_DEFEATED_FLOAROMA_MEADOW_GRUNTS
    WaitButton
    CloseMessage
    Return

FloaromaMeadow_PokefanMWalkToPlayerX12:
    ApplyMovement LOCALID_POKEFAN_M, FloaromaMeadow_Movement_PokefanMWalkToPlayerX12
    WaitMovement
    Return

FloaromaMeadow_PokefanMWalkToPlayerX13:
    ApplyMovement LOCALID_POKEFAN_M, FloaromaMeadow_Movement_PokefanMWalkToPlayerX13
    WaitMovement
    Return

FloaromaMeadow_Unused:
    BlackOutFromBattle
    ReleaseAll
    End

FloaromaMeadow_Grunt_Unused:
    End

FloaromaMeadow_PokefanM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CallIfUnset FLAG_GAME_COMPLETED, FloaromaMeadow_SovereignFullPriceMsg
    CallIfSet FLAG_GAME_COMPLETED, FloaromaMeadow_SovereignHalfPriceMsg
    ShowMoney 20, 2
    GoTo FloaromaMeadow_ShowMenuHoney
    End

FloaromaMeadow_ShowMenuHoney:
    InitLocalTextMenu 30, 11, 0, VAR_RESULT
    SetMenuXOriginToRight
    AddMenuEntryImm FloaromaMeadow_Text_Times1, 0
    AddMenuEntryImm FloaromaMeadow_Text_Times10, 1
    AddMenuEntryImm FloaromaMeadow_Text_NoThanks, 2
    ShowMenu
    SetVar VAR_0x8008, VAR_RESULT
    GoToIfEq VAR_0x8008, 0, FloaromaMeadow_TryBuy1Honey
    GoToIfEq VAR_0x8008, 1, FloaromaMeadow_TryBuy10Honey
    GoToIfEq VAR_0x8008, 2, FloaromaMeadow_OopsyWellComeAgain
    GoTo FloaromaMeadow_OopsyWellComeAgain
    End

FloaromaMeadow_TryBuy1Honey:
    GoToIfSet FLAG_GAME_COMPLETED, FloaromaMeadow_TryBuy1HoneySovereignHalf
    GoToIfNotEnoughMoney 100, FloaromaMeadow_NotEnoughMoney
    SetVar VAR_0x8005, 1
    SetVar VAR_0x8006, 100
    GoTo FloaromaMeadow_TryGiveHoney
    End

FloaromaMeadow_TryBuy10Honey:
    GoToIfSet FLAG_GAME_COMPLETED, FloaromaMeadow_TryBuy10HoneySovereignHalf
    GoToIfNotEnoughMoney 1000, FloaromaMeadow_NotEnoughMoney
    SetVar VAR_0x8005, 10
    SetVar VAR_0x8006, 1000
    GoTo FloaromaMeadow_TryGiveHoney
    End

FloaromaMeadow_TryGiveHoney:
    SetVar VAR_0x8004, ITEM_HONEY
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, FloaromaMeadow_CantBuyHoneyBagIsFull
    RemoveMoney2 VAR_0x8006
    UpdateMoneyDisplay
    PlaySE SEQ_SE_DP_REGI_sseq
    WaitSE SEQ_SE_DP_REGI_sseq
    Common_GiveItemQuantityNoLineFeed
    HideMoney
    CloseMessage
    ReleaseAll
    End

FloaromaMeadow_OopsyWellComeAgain:
    Message FloaromaMeadow_Text_OopsyWellComeAgain
    WaitButton
    HideMoney
    CloseMessage
    ReleaseAll
    End

FloaromaMeadow_CantBuyHoneyBagIsFull:
    Message FloaromaMeadow_Text_YourBagsFull
    WaitButton
    HideMoney
    CloseMessage
    ReleaseAll
    End

FloaromaMeadow_NotEnoughMoney:
    Message FloaromaMeadow_Text_NotEnoughMoney
    WaitButton
    HideMoney
    CloseMessage
    ReleaseAll
    End

FloaromaMeadow_Dummy6:
    ShowArrowSign FloaromaMeadow_Text_Dummy18
    End

FloaromaMeadow_ItemWorksKey:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    SetVar VAR_0x8004, ITEM_WORKS_KEY
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    CloseMessage
    SetFlag FLAG_OBTAINED_FLOAROMA_MEADOW_WORKS_KEY
    RemoveObject LOCALID_ITEM_WORKS_KEY
    ReleaseAll
    End

@ Sovereign (E10, Renegade's Type Masters): the Grass-type Master battles one Grass-type Pokémon, alone in the party, for
@ the Meadow Plate (Renegade's trainer 1046).
FloaromaMeadow_SovereignGrassMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_GRASS_MASTER, FloaromaMeadow_SovereignGrassMasterThanks
    Message FloaromaMeadow_Text_SovereignGrassMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, FloaromaMeadow_SovereignGrassMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_GRASS, FloaromaMeadow_SovereignGrassMasterAsk
    GoToIfEq VAR_0x8005, TYPE_GRASS, FloaromaMeadow_SovereignGrassMasterAsk
FloaromaMeadow_SovereignGrassMasterOnlyOne:
    Message FloaromaMeadow_Text_SovereignGrassMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaMeadow_SovereignGrassMasterAsk:
    Message FloaromaMeadow_Text_SovereignGrassMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, FloaromaMeadow_SovereignGrassMasterDecline
    Message FloaromaMeadow_Text_SovereignGrassMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GRASS_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, FloaromaMeadow_SovereignGrassMasterLost
    Message FloaromaMeadow_Text_SovereignGrassMasterWin
    SetVar VAR_0x8004, ITEM_MEADOW_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_GRASS_MASTER
FloaromaMeadow_SovereignGrassMasterThanks:
    Message FloaromaMeadow_Text_SovereignGrassMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaMeadow_SovereignGrassMasterDecline:
    Message FloaromaMeadow_Text_SovereignGrassMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaMeadow_SovereignGrassMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message FloaromaMeadow_Text_SovereignGrassMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0

@ Sovereign (decision 24, owner 2026-10-24): after the Hall of Fame, scripted sales are half price too.
FloaromaMeadow_SovereignFullPriceMsg:
    Message FloaromaMeadow_Text_BuySomeHoney
    Return

FloaromaMeadow_SovereignHalfPriceMsg:
    Message FloaromaMeadow_Text_SovereignBuySomeHoneyHalf
    Return

FloaromaMeadow_TryBuy1HoneySovereignHalf:
    GoToIfNotEnoughMoney 50, FloaromaMeadow_NotEnoughMoney
    SetVar VAR_0x8005, 1
    SetVar VAR_0x8006, 50
    GoTo FloaromaMeadow_TryGiveHoney
    End

FloaromaMeadow_TryBuy10HoneySovereignHalf:
    GoToIfNotEnoughMoney 500, FloaromaMeadow_NotEnoughMoney
    SetVar VAR_0x8005, 10
    SetVar VAR_0x8006, 500
    GoTo FloaromaMeadow_TryGiveHoney
    End
