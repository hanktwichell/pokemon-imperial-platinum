#include "macros/scrcmd.inc"
#include "res/text/bank/route_203.h"
#include "res/field/events/events_route_203.h"


    ScriptEntry Route203_Lass
    ScriptEntry Route203_ArrowSignpostJubilifeCity
    ScriptEntry Route203_ArrowSignpostOreburghCity
    ScriptEntry Route203_TrainerTipsSignpostEast
    ScriptEntry Route203_TrainerTipsSignpostWest
    ScriptEntry Route203_CoordEvent_Rival
    ScriptEntry Route203_SovereignMewShroomish
    ScriptEntryEnd

Route203_Lass:
    NPCMessage Route203_Text_FavoritePokemonAtTheTop
    End

Route203_ArrowSignpostJubilifeCity:
    ShowArrowSign Route203_Text_SignJubilifeCity
    End

Route203_ArrowSignpostOreburghCity:
    ShowArrowSign Route203_Text_SignOreburghCity
    End

Route203_TrainerTipsSignpostEast:
    ShowScrollingSign Route203_Text_TrainerTipsEvolveCanBeStopped
    End

Route203_TrainerTipsSignpostWest:
    ShowScrollingSign Route203_Text_TrainerTipsMovesUsePowerPoints
    End

Route203_CoordEvent_Rival:
    LockAll
    ApplyMovement LOCALID_RIVAL, Route203_Movement_RivalNoticePlayer
    WaitMovement
    Common_SetRivalBGM
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8005, 757, Route203_RivalWalkToPlayerZ757
    GoToIfEq VAR_0x8005, 758, Route203_RivalWalkToPlayerZ758
    GoToIfEq VAR_0x8005, 759, Route203_RivalWalkToPlayerZ759
    GoToIfEq VAR_0x8005, 760, Route203_RivalWalkToPlayerZ760
    End

Route203_RivalWalkToPlayerZ757:
    ApplyMovement LOCALID_RIVAL, Route203_Movement_RivalWalkToPlayerZ757
    WaitMovement
    GoTo Route203_RivalIntro

Route203_RivalWalkToPlayerZ758:
    ApplyMovement LOCALID_RIVAL, Route203_Movement_RivalWalkToPlayerZ758
    WaitMovement
    GoTo Route203_RivalIntro

Route203_RivalWalkToPlayerZ759:
    ApplyMovement LOCALID_RIVAL, Route203_Movement_RivalWalkToPlayerZ759
    WaitMovement
    GoTo Route203_RivalIntro

Route203_RivalWalkToPlayerZ760:
    ApplyMovement LOCALID_RIVAL, Route203_Movement_RivalWalkToPlayerZ760
    WaitMovement
    GoTo Route203_RivalIntro

Route203_RivalIntro:
    BufferRivalName 0
    BufferPlayerName 1
    Message Route203_Text_IGotTougher
    CloseMessage
    GetPlayerStarterSpecies VAR_RESULT
    GoToIfEq VAR_RESULT, SPECIES_TURTWIG, Route203_StartRivalBattleTurtwig
    GoToIfEq VAR_RESULT, SPECIES_CHIMCHAR, Route203_StartRivalBattleChimchar
    GoTo Route203_StartRivalBattlePiplup

Route203_StartRivalBattlePiplup:
    StartTrainerBattle TRAINER_RIVAL_ROUTE_203_PIPLUP
    GoTo Route203_RivalBattleEnd

Route203_StartRivalBattleTurtwig:
    StartTrainerBattle TRAINER_RIVAL_ROUTE_203_TURTWIG
    GoTo Route203_RivalBattleEnd

Route203_StartRivalBattleChimchar:
    StartTrainerBattle TRAINER_RIVAL_ROUTE_203_CHIMCHAR
    GoTo Route203_RivalBattleEnd

Route203_RivalBattleEnd:
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route203_BlackOutRivalBattle
    BufferRivalName 0
    Message Route203_Text_WhatDoYouMeanILost
    CloseMessage
    // Sovereign (E10): as in Renegade, Barry shares an Exp. Share from the parcel.
    ApplyMovement LOCALID_RIVAL, Route203_Movement_RivalNoticePlayer
    WaitMovement
    BufferPlayerName 1
    BufferRivalName 0
    Message Route203_Text_SovereignRivalTwoOfAnotherItem
    SetVar VAR_0x8004, ITEM_EXP_SHARE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    BufferRivalName 0
    Message Route203_Text_SovereignRivalOKBye
    CloseMessage
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8005, 757, Route203_RivalLeaveZ757
    GoToIfEq VAR_0x8005, 758, Route203_RivalLeaveZ758
    GoToIfEq VAR_0x8005, 759, Route203_RivalLeaveZ759
    GoToIfEq VAR_0x8005, 760, Route203_RivalLeaveZ760
    End

Route203_RivalLeaveZ757:
    ApplyMovement LOCALID_RIVAL, Route203_Movement_RivalLeaveZ757
    WaitMovement
    GoTo Route203_RemoveRival

Route203_RivalLeaveZ758:
    ApplyMovement LOCALID_RIVAL, Route203_Movement_RivalLeaveZ758
    WaitMovement
    GoTo Route203_RemoveRival

Route203_RivalLeaveZ759:
    ApplyMovement LOCALID_RIVAL, Route203_Movement_RivalLeaveZ759
    WaitMovement
    GoTo Route203_RemoveRival

Route203_RivalLeaveZ760:
    ApplyMovement LOCALID_RIVAL, Route203_Movement_RivalLeaveZ760
    WaitMovement
    GoTo Route203_RemoveRival

Route203_RemoveRival:
    RemoveObject LOCALID_RIVAL
    SetVar VAR_ROUTE_203_RIVAL_STATE, 1
    ReleaseAll
    End

Route203_BlackOutRivalBattle:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
Route203_Movement_RivalLeaveZ757:
    WalkFastEast 10
    EndMovement

    .balign 4, 0
Route203_Movement_RivalLeaveZ758:
    WalkFastEast 10
    EndMovement

    .balign 4, 0
Route203_Movement_RivalLeaveZ759:
    WalkFastEast 10
    EndMovement

    .balign 4, 0
Route203_Movement_RivalLeaveZ760:
    WalkFastEast 10
    EndMovement

    .balign 4, 0
Route203_Movement_RivalWalkToPlayerZ757:
    WalkFastWest 4
    EndMovement

    .balign 4, 0
Route203_Movement_RivalWalkToPlayerZ758:
    WalkFastWest 2
    WalkFastSouth
    WalkFastWest 2
    EndMovement

    .balign 4, 0
Route203_Movement_RivalWalkToPlayerZ759:
    WalkFastWest 2
    WalkFastSouth 2
    WalkFastWest 2
    EndMovement

    .balign 4, 0
Route203_Movement_RivalWalkToPlayerZ760:
    WalkFastWest 2
    WalkFastSouth 3
    WalkFastWest 2
    EndMovement

    .balign 4, 0
Route203_Movement_RivalNoticePlayer:
    Delay8
    EmoteExclamationMark
    Delay8
    EndMovement

@ Sovereign (E10, Renegade's Mew event, step 1 of 4): a hungry Shroomish wants an Oran Berry. Feeding it brings Mew,
@ which flies off to the next step (Route 203 Shroomish, Route 209 Buneary, Pastoria City Torchic, Route 201).
Route203_SovereignMewShroomish:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    PlayCry SPECIES_SHROOMISH
    Message Route203_Text_SovereignMewShroomishCry
    WaitCry
    Message Route203_Text_SovereignMewShroomishHungry
    CheckItem ITEM_ORAN_BERRY, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route203_SovereignMewShroomishEnd
    Message Route203_Text_SovereignMewShroomishAskGive
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route203_SovereignMewShroomishEnd
    RemoveItem ITEM_ORAN_BERRY, 1, VAR_RESULT
    PlayCry SPECIES_SHROOMISH
    Message Route203_Text_SovereignMewShroomishHappy
    WaitCry
    Message Route203_Text_SovereignMewShroomishAte
    CloseMessage
    WaitTime 5, VAR_RESULT
    FadeScreenOut FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    SetFlag FLAG_SOVEREIGN_HIDE_MEW_SHROOMISH
    RemoveObject LOCALID_SOVEREIGN_MEW_SHROOMISH
    SetObjectEventPos LOCALID_SOVEREIGN_MEW, 212, 746
    AddObject LOCALID_SOVEREIGN_MEW
    FadeScreenIn FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    ApplyMovement LOCALID_SOVEREIGN_MEW, Route203_SovereignMovement_MewNotice
    WaitMovement
    PlayCry SPECIES_MEW
    Message Route203_Text_SovereignMewCry
    WaitCry
    CloseMessage
    FadeScreenOut FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_MEW
    FadeScreenIn FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    WaitTime 15, VAR_RESULT
    Message Route203_Text_SovereignMewDisappeared
    WaitButton
    CloseMessage
    ClearFlag FLAG_SOVEREIGN_HIDE_MEW_BUNEARY
    ReleaseAll
    End

Route203_SovereignMewShroomishEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
Route203_SovereignMovement_MewNotice:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
