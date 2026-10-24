#include "macros/scrcmd.inc"
#include "res/text/bank/snowpoint_city_east_house.h"


    ScriptEntry SnowpointCityEastHouse_ExpertM
    ScriptEntry SnowpointCityEastHouse_SovereignFisherman
    ScriptEntryEnd

SnowpointCityEastHouse_ExpertM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_DAILY_HEARD_TRENDY_SAYING_SNOWPOINT_CITY_EAST_HOUSE, SnowpointCityEastHouse_UseTrendySayings
    CheckAllToughWordsUnlocked VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SnowpointCityEastHouse_AreYouUsingTrendySayings
    Message SnowpointCityEastHouse_Text_HearTrendySaying
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, SnowpointCityEastHouse_ComeOnNow
    TryBufferAndUnlockRandomToughWord VAR_RESULT, 0
    GoToIfEq VAR_RESULT, -1, SnowpointCityEastHouse_AreYouUsingTrendySayings
    SetFlag FLAG_DAILY_HEARD_TRENDY_SAYING_SNOWPOINT_CITY_EAST_HOUSE
    Message SnowpointCityEastHouse_Text_TrendyThingIsThis
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCityEastHouse_UseTrendySayings:
    Message SnowpointCityEastHouse_Text_UseTrendySayings
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCityEastHouse_ComeOnNow:
    Message SnowpointCityEastHouse_Text_ComeOnNow
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCityEastHouse_AreYouUsingTrendySayings:
    Message SnowpointCityEastHouse_Text_AreYouUsingTrendySayings
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0

// Sovereign (E10): Renegade's Super Rod fisherman. (The move tutor who lived here teaches in the Route 212 house.) He shares FLAG_RECEIVED_SUPER_ROD with the Fight Area fisherman, so the rod comes once.
SnowpointCityEastHouse_SovereignFisherman:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_RECEIVED_SUPER_ROD, SnowpointCityEastHouse_SovereignFishermanAgain
    Message SnowpointCityEastHouse_Text_SovereignFishermanGives
    SetVar VAR_0x8004, ITEM_SUPER_ROD
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_RECEIVED_SUPER_ROD
    Message SnowpointCityEastHouse_Text_SovereignFishermanExplains
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCityEastHouse_SovereignFishermanAgain:
    Message SnowpointCityEastHouse_Text_SovereignFishermanAgain
    WaitButton
    CloseMessage
    ReleaseAll
    End
