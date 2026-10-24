#include "macros/scrcmd.inc"
#include "res/text/bank/poffin_house.h"
#include "res/field/events/events_poffin_house.h"


    ScriptEntry PoffinHouse_Idol
    ScriptEntry PoffinHouse_OldMan
    ScriptEntry PoffinHouse_OldWoman
    ScriptEntry PoffinHouse_SchoolKidF
    ScriptEntry PoffinHouse_OnResume
    ScriptEntry PoffinHouse_OnTransition
    ScriptEntry PoffinHouse_SovereignCollector
    ScriptEntryEnd

PoffinHouse_OnTransition:
    CheckTVInterviewEligible TV_PROGRAM_SEGMENT_THREE_CHEERS_FOR_POFFIN_CORNER, VAR_MAP_LOCAL_0x00
    CallIfEq VAR_MAP_LOCAL_0x00, FALSE, PoffinHouse_HideReporter
    End

PoffinHouse_OnResume:
    CheckTVInterviewEligible TV_PROGRAM_SEGMENT_THREE_CHEERS_FOR_POFFIN_CORNER, VAR_MAP_LOCAL_0x00
    GoToIfNe VAR_MAP_LOCAL_0x00, FALSE, PoffinHouse_ShowReporter
    CallIfUnset FLAG_HIDE_POFFIN_HOUSE_REPORTER, PoffinHouse_HideReporter
    End

PoffinHouse_HideReporter:
    SetFlag FLAG_HIDE_POFFIN_HOUSE_REPORTER
    Return

PoffinHouse_ShowReporter:
    GoToIfSet FLAG_HIDE_POFFIN_HOUSE_REPORTER, PoffinHouse_AddReporter
    ClearFlag FLAG_HIDE_POFFIN_HOUSE_REPORTER
    End

PoffinHouse_AddReporter:
    ClearFlag FLAG_HIDE_POFFIN_HOUSE_REPORTER
    AddObject LOCALID_REPORTER
    End

PoffinHouse_Idol:
    NPCMessage PoffinHouse_Text_AdviceOnCookingPoffins
    End

PoffinHouse_OldMan:
    NPCMessage PoffinHouse_Text_HaveYouGotSomeBerries
    End

PoffinHouse_OldWoman:
    NPCMessage PoffinHouse_Text_EatingMakesPeopleHappy
    End

PoffinHouse_SchoolKidF:
    NPCMessage PoffinHouse_Text_ICanCookWithFriends
    End

// Sovereign (E10): as in Renegade Platinum, a man burned by boiling water gives TM55 (Scald) for a Burn Heal.
PoffinHouse_SovereignCollector:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_POFFIN_HOUSE_TM55, PoffinHouse_SovereignExplainScald
    Message PoffinHouse_Text_SovereignDoYouHaveBurnHeal
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, PoffinHouse_SovereignNoBurnHeal
    CheckItem ITEM_BURN_HEAL, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PoffinHouse_SovereignNoBurnHeal
    RemoveItem ITEM_BURN_HEAL, 1, VAR_RESULT
    Message PoffinHouse_Text_SovereignLetMeApplyIt
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    FadeScreenIn
    WaitFadeScreen
    Message PoffinHouse_Text_SovereignMuchBetter
    SetVar VAR_0x8004, ITEM_TM55
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_POFFIN_HOUSE_TM55
PoffinHouse_SovereignExplainScald:
    Message PoffinHouse_Text_SovereignExplainScald
    WaitButton
    CloseMessage
    ReleaseAll
    End

PoffinHouse_SovereignNoBurnHeal:
    Message PoffinHouse_Text_SovereignGetColdWater
    WaitButton
    CloseMessage
    ReleaseAll
    End
