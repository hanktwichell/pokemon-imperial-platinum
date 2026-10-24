#include "macros/scrcmd.inc"
#include "res/text/bank/route_229.h"
#include "res/field/events/events_route_229.h"


    ScriptEntry Route229_PokefanM
    ScriptEntry Route229_ArrowSignpostResortArea
    ScriptEntry Route229_SovereignGene
    ScriptEntryEnd

Route229_PokefanM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_RECEIVED_ROUTE_229_NUGGET, Route229_ThoseAreMyNuggets
    Message Route229_Text_MakeItUpWithThis
    SetVar VAR_0x8004, ITEM_NUGGET
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route229_BagIsFull
    Common_GiveItemQuantity
    SetFlag FLAG_RECEIVED_ROUTE_229_NUGGET
    SetVar VAR_0x8004, ITEM_NUGGET
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route229_ThoseAreMyNuggets
    Message Route229_Text_TakeAnother
    Common_GiveItemQuantity
    GoTo Route229_ThoseAreMyNuggets
    End

Route229_ThoseAreMyNuggets:
    Message Route229_Text_ThoseAreMyNuggets
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route229_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

Route229_ArrowSignpostResortArea:
    ShowArrowSign Route229_Text_SignResortArea
    End

    

@ Sovereign (E10, Renegade's Battle Zone): Gene gives the unofficial General Badge (just a keepsake, no item) to a player
@ who beats their team (Renegade's trainer 1027).
Route229_SovereignGene:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_GENE, Route229_SovereignGeneThanks
    Message Route229_Text_SovereignGeneIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route229_SovereignGeneDecline
    Message Route229_Text_SovereignGeneBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_BATTLE_ZONE_GENE
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route229_SovereignGeneLost
    Message Route229_Text_SovereignGeneReward
    BufferPlayerName 0
    Message Route229_Text_SovereignGeneReceived
    PlayFanfare SEQ_BADGE_sseq
    WaitFanfare
    Message Route229_Text_SovereignGeneExplain
    WaitButton
    CloseMessage
    SetTrainerFlag TRAINER_SOVEREIGN_BATTLE_ZONE_GENE
    ReleaseAll
    End

Route229_SovereignGeneThanks:
    Message Route229_Text_SovereignGeneThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route229_SovereignGeneDecline:
    CloseMessage
    ReleaseAll
    End

Route229_SovereignGeneLost:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
