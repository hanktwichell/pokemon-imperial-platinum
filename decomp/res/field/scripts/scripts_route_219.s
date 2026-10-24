#include "macros/scrcmd.inc"
#include "res/text/bank/route_219.h"
#include "res/field/events/events_route_219.h"


    ScriptEntry Route219_ArrowSignpostSandgemBeach
    ScriptEntry Route219_SovereignWaterMaster
    ScriptEntryEnd

Route219_ArrowSignpostSandgemBeach:
    ShowArrowSign Route219_Text_SignSandgemBeach
    End

    

@ Sovereign (E10, Renegade's Type Masters): the Water-type Master battles one Water-type Pokémon, alone in the party, for
@ the Splash Plate (Renegade's trainer 1045).
Route219_SovereignWaterMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_WATER_MASTER, Route219_SovereignWaterMasterThanks
    Message Route219_Text_SovereignWaterMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, Route219_SovereignWaterMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_WATER, Route219_SovereignWaterMasterAsk
    GoToIfEq VAR_0x8005, TYPE_WATER, Route219_SovereignWaterMasterAsk
Route219_SovereignWaterMasterOnlyOne:
    Message Route219_Text_SovereignWaterMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route219_SovereignWaterMasterAsk:
    Message Route219_Text_SovereignWaterMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route219_SovereignWaterMasterDecline
    Message Route219_Text_SovereignWaterMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_WATER_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route219_SovereignWaterMasterLost
    Message Route219_Text_SovereignWaterMasterWin
    SetVar VAR_0x8004, ITEM_SPLASH_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_WATER_MASTER
Route219_SovereignWaterMasterThanks:
    Message Route219_Text_SovereignWaterMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route219_SovereignWaterMasterDecline:
    Message Route219_Text_SovereignWaterMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route219_SovereignWaterMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message Route219_Text_SovereignWaterMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
