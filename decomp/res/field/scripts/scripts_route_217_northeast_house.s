#include "macros/scrcmd.inc"
#include "res/text/bank/route_217_northeast_house.h"
#include "res/field/events/events_route_217_northeast_house.h"


    ScriptEntry Route217NortheastHouse_PokemonBreederF
    ScriptEntry Route217NortheastHouse_OnTransition
    ScriptEntryEnd

@ Sovereign (E10, Renegade): she no longer vanishes after the Spell Tag. She dozes off, muttering about Darkrai's
@ nightmares, and the Lunar Wing wakes her: in her rage she hands over the Member Card (Darkrai's event). The card is a
@ key item, so having it marks the event done. Saves where she had already vanished get her back.
Route217NortheastHouse_OnTransition:
    ClearFlag FLAG_HIDE_ROUTE_217_NORTHEAST_HOUSE_POKEMON_BREEDER_F
    End

Route217NortheastHouse_PokemonBreederF:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GoToIfSet FLAG_RECEIVED_ROUTE_217_NORTHEAST_HOUSE_SPELL_TAG, Route217NortheastHouse_SovereignDarkrai
    FacePlayer
    Message Route217NortheastHouse_Text_PersonRareSight
    SetVar VAR_0x8004, ITEM_SPELL_TAG
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route217NortheastHouse_BagIsFull
    SetFlag FLAG_RECEIVED_ROUTE_217_NORTHEAST_HOUSE_SPELL_TAG
    Common_GiveItemQuantityNoLineFeed
    CloseMessage
    ReleaseAll
    End

Route217NortheastHouse_SovereignDarkrai:
    CheckItem ITEM_MEMBER_CARD, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route217NortheastHouse_SovereignVividNightmares
    Message Route217NortheastHouse_Text_SovereignNightmare
    WaitButton
    CloseMessage
    CheckItem ITEM_LUNAR_WING, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route217NortheastHouse_SovereignEnd
    WaitTime 15, VAR_RESULT
    BufferPlayerName 0
    Message Route217NortheastHouse_Text_SovereignLunarWingGlows
    Message Route217NortheastHouse_Text_SovereignWokeUp
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    CloseMessage
    FacePlayer
    ApplyMovement LOCALID_POKEMON_BREEDER_F, Route217NortheastHouse_SovereignMovement_Exclamation
    WaitMovement
    Message Route217NortheastHouse_Text_SovereignHowDareYou
    SetVar VAR_0x8004, ITEM_MEMBER_CARD
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Message Route217NortheastHouse_Text_SovereignGoToCanalave
    WaitButton
    CloseMessage
Route217NortheastHouse_SovereignEnd:
    ReleaseAll
    End

Route217NortheastHouse_SovereignVividNightmares:
    FacePlayer
    Message Route217NortheastHouse_Text_SovereignVividNightmares
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
Route217NortheastHouse_SovereignMovement_Exclamation:
    EmoteExclamationMark
    EndMovement

Route217NortheastHouse_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

Route217NortheastHouse_ExplainSpellTag:
    Message Route217NortheastHouse_Text_ExplainSpellTag
    WaitButton
    CloseMessage
    ReleaseAll
    End
