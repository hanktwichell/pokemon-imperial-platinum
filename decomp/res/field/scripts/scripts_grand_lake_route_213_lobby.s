#include "macros/scrcmd.inc"
#include "res/text/bank/grand_lake_route_213_lobby.h"
#include "res/field/events/events_grand_lake_route_213_lobby.h"


    ScriptEntry GrandLakeRoute213Lobby_OnTransition
    ScriptEntry GrandLakeRoute213Lobby_Policeman
    ScriptEntry GrandLakeRoute213Lobby_AceTrainerF
    ScriptEntry GrandLakeRoute213Lobby_Looker
    ScriptEntry GrandLakeRoute213Lobby_SovereignBlackBelt
    ScriptEntry GrandLakeRoute213Lobby_SovereignHiker
    ScriptEntryEnd

GrandLakeRoute213Lobby_OnTransition:
    End

GrandLakeRoute213Lobby_Policeman:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message GrandLakeRoute213Lobby_Text_YouMayRest
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Message GrandLakeRoute213Lobby_Text_RestoredYourPokemon
    WaitButton
    CloseMessage
    ReleaseAll
    End

GrandLakeRoute213Lobby_AceTrainerF:
    NPCMessage GrandLakeRoute213Lobby_Text_HotelIsSoRomantic
    End

GrandLakeRoute213Lobby_Looker:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GoToIfSet FLAG_TALKED_TO_GRAND_LAKE_ROUTE_213_LOBBY_LOOKER, GrandLakeRoute213Lobby_IWillSearchInside
    SetFlag FLAG_TALKED_TO_GRAND_LAKE_ROUTE_213_LOBBY_LOOKER
    FacePlayer
    Message GrandLakeRoute213Lobby_Text_GoSearchOutside
    WaitButton
    CloseMessage
    ReleaseAll
    End

GrandLakeRoute213Lobby_IWillSearchInside:
    ApplyMovement LOCALID_LOOKER, GrandLakeRoute213Lobby_Movement_LookerFaceEast
    WaitMovement
    Message GrandLakeRoute213Lobby_Text_BraggingIsNotNecessary
    FacePlayer
    Message GrandLakeRoute213Lobby_Text_IWillSearchInside
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
GrandLakeRoute213Lobby_Movement_LookerFaceEast:
    FaceEast
    EndMovement

// Sovereign (E10): Renegade's Electirizer fan, arguing with the Magmarizer fan next to him.
GrandLakeRoute213Lobby_SovereignBlackBelt:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_GRAND_LAKE_ELECTIRIZER, GrandLakeRoute213Lobby_SovereignBlackBeltAgain
    Message GrandLakeRoute213Lobby_Text_SovereignBlackBeltGives
    SetVar VAR_0x8004, ITEM_ELECTIRIZER
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_GRAND_LAKE_ELECTIRIZER
    Message GrandLakeRoute213Lobby_Text_SovereignBlackBeltExplains
    WaitButton
    CloseMessage
    ReleaseAll
    End

GrandLakeRoute213Lobby_SovereignBlackBeltAgain:
    Message GrandLakeRoute213Lobby_Text_SovereignBlackBeltAgain
    WaitButton
    CloseMessage
    ReleaseAll
    End

// Sovereign (E10): Renegade's Magmarizer fan.
GrandLakeRoute213Lobby_SovereignHiker:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_GRAND_LAKE_MAGMARIZER, GrandLakeRoute213Lobby_SovereignHikerAgain
    Message GrandLakeRoute213Lobby_Text_SovereignHikerGives
    SetVar VAR_0x8004, ITEM_MAGMARIZER
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_GRAND_LAKE_MAGMARIZER
    Message GrandLakeRoute213Lobby_Text_SovereignHikerExplains
    WaitButton
    CloseMessage
    ReleaseAll
    End

GrandLakeRoute213Lobby_SovereignHikerAgain:
    Message GrandLakeRoute213Lobby_Text_SovereignHikerAgain
    WaitButton
    CloseMessage
    ReleaseAll
    End
