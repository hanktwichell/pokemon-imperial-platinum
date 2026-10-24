#include "macros/scrcmd.inc"
#include "res/text/bank/route_230.h"
#include "res/field/events/events_route_230.h"


    ScriptEntry Route230_ArrowSignpostFightArea
    ScriptEntry Route230_Fisherman
    ScriptEntry Route230_RichBoy
    ScriptEntry Route230_SovereignLuna
    ScriptEntryEnd

Route230_ArrowSignpostFightArea:
    ShowArrowSign Route230_Text_SignFightArea
    End

Route230_Fisherman:
    NPCMessage Route230_Text_VisitBattleFrontier
    End

Route230_RichBoy:
    NPCMessage Route230_Text_ChallengeOtherTrainers
    End

    

@ Sovereign (E10, Renegade's Battle Zone): Luna gives the unofficial Moon Badge (just a keepsake, no item) to a player
@ who beats their team (Renegade's trainer 1028).
Route230_SovereignLuna:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_LUNA, Route230_SovereignLunaThanks
    Message Route230_Text_SovereignLunaIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route230_SovereignLunaDecline
    Message Route230_Text_SovereignLunaBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_BATTLE_ZONE_LUNA
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route230_SovereignLunaLost
    Message Route230_Text_SovereignLunaReward
    BufferPlayerName 0
    Message Route230_Text_SovereignLunaReceived
    PlayFanfare SEQ_BADGE_sseq
    WaitFanfare
    Message Route230_Text_SovereignLunaExplain
    WaitButton
    CloseMessage
    SetTrainerFlag TRAINER_SOVEREIGN_BATTLE_ZONE_LUNA
    ReleaseAll
    End

Route230_SovereignLunaThanks:
    Message Route230_Text_SovereignLunaThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route230_SovereignLunaDecline:
    CloseMessage
    ReleaseAll
    End

Route230_SovereignLunaLost:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
