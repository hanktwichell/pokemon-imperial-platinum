#include "macros/scrcmd.inc"
#include "res/text/bank/route_216_house.h"
#include "res/field/events/events_route_216_house.h"


    ScriptEntry Route216House_Hiker
    ScriptEntry Route216House_SnowpointNPCF
    ScriptEntry Route216House_Bed
    ScriptEntry Route216House_AceTrainerM
    ScriptEntry Route216House_Gardenia
    ScriptEntryEnd

// Sovereign (E10): as in Renegade Platinum, an Ace Trainer gives TM13 (Ice Beam) to a Trainer with five badges, and
// Gardenia, out looking for a Snover, stops by once.

Route216House_Hiker:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message Route216House_Text_MakeYourselfAtHome
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, Route216House_HikerRest
    GoToIfEq VAR_RESULT, MENU_NO, Route216House_YouCanNapInBed
    End

Route216House_HikerRest:
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Message Route216House_Text_YourPokemonAreHealthy
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route216House_YouCanNapInBed:
    Message Route216House_Text_YouCanNapInBed
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route216House_SnowpointNPCF:
    NPCMessage Route216House_Text_IDontHaveThickFat
    End

Route216House_Bed:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    Message Route216House_Text_WantToRest
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, Route216House_RestInBed
    GoToIfEq VAR_RESULT, MENU_NO, Route216House_DontRestInBed
    End

Route216House_RestInBed:
    BufferPlayerName 0
    Message Route216House_Text_FellAsleepInBed
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    BufferPlayerName 0
    Message Route216House_Text_BecameFullyHealed
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route216House_DontRestInBed:
    CloseMessage
    ReleaseAll
    End

Route216House_AceTrainerM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_ROUTE_216_HOUSE_TM13, Route216House_NotGivingUp
    GoToIfBadgeAcquired BADGE_ID_RELIC, Route216House_HeresIceBeam
    Message Route216House_Text_SovereignMaybeWithFiveBadges
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route216House_HeresIceBeam:
    Message Route216House_Text_SovereignPassOnIceBeam
    SetVar VAR_0x8004, ITEM_TM13
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_ROUTE_216_HOUSE_TM13
    Message Route216House_Text_SovereignIceBeamCanFreeze
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route216House_NotGivingUp:
    Message Route216House_Text_SovereignNotGivingUpIsMyMagic
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route216House_Gardenia:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    Message Route216House_Text_SovereignSoColdHere
    CloseMessage
    FacePlayer
    ApplyMovement LOCALID_GARDENIA, Route216House_Movement_GardeniaExclamationMark
    WaitMovement
    Message Route216House_Text_SovereignImGardenia
    CloseMessage
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_EAST, Route216House_GardeniaLeaveEast
    ApplyMovement LOCALID_GARDENIA, Route216House_Movement_GardeniaLeave
    WaitMovement
    GoTo Route216House_RemoveGardenia

Route216House_GardeniaLeaveEast:
    ApplyMovement LOCALID_GARDENIA, Route216House_Movement_GardeniaLeaveEast
    WaitMovement
Route216House_RemoveGardenia:
    RemoveObject LOCALID_GARDENIA
    SetFlag FLAG_SOVEREIGN_HIDE_ROUTE_216_HOUSE_GARDENIA
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    ReleaseAll
    End

    .balign 4, 0
Route216House_Movement_GardeniaExclamationMark:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route216House_Movement_GardeniaLeave:
    WalkNormalWest
    WalkNormalSouth 5
    EndMovement

    .balign 4, 0
Route216House_Movement_GardeniaLeaveEast:
    WalkNormalSouth
    WalkNormalWest
    WalkNormalSouth 4
    EndMovement
