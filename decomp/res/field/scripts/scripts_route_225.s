#include "macros/scrcmd.inc"
#include "res/text/bank/route_225.h"
#include "res/field/events/events_route_225.h"


    ScriptEntry Route225_ArrowSignpostFightArea
    ScriptEntry Route225_ArrowSignpostSurvivalArea
    ScriptEntry Route225_SovereignHeather
    ScriptEntryEnd

Route225_ArrowSignpostFightArea:
    ShowArrowSign Route225_Text_SignFightArea
    End

Route225_ArrowSignpostSurvivalArea:
    ShowArrowSign Route225_Text_SignSurvivalArea
    End

@ Sovereign (E10, Renegade's Battle Zone): Heather gives the unofficial Wind Badge (just a keepsake, no item) to a player
@ who beats their team (Renegade's trainer 938).
Route225_SovereignHeather:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_HEATHER, Route225_SovereignHeatherThanks
    Message Route225_Text_SovereignHeatherIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route225_SovereignHeatherDecline
    Message Route225_Text_SovereignHeatherBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_BATTLE_ZONE_HEATHER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route225_SovereignHeatherLost
    Message Route225_Text_SovereignHeatherReward
    BufferPlayerName 0
    Message Route225_Text_SovereignHeatherReceived
    PlayFanfare SEQ_BADGE_sseq
    WaitFanfare
    Message Route225_Text_SovereignHeatherExplain
    WaitButton
    CloseMessage
    SetTrainerFlag TRAINER_SOVEREIGN_BATTLE_ZONE_HEATHER
    ReleaseAll
    End

Route225_SovereignHeatherThanks:
    Message Route225_Text_SovereignHeatherThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route225_SovereignHeatherDecline:
    CloseMessage
    ReleaseAll
    End

Route225_SovereignHeatherLost:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
