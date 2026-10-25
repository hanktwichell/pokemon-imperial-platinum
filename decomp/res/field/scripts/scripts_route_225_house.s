#include "macros/scrcmd.inc"
#include "res/text/bank/route_225_house.h"


    ScriptEntry Route225House_Worker
    ScriptEntryEnd

@ Sovereign (E10, Renegade): the worker heals the party on every talk, as in Renegade. Vanilla's Fresh Water still
@ comes on the first talk.
Route225House_Worker:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message Route225House_Text_SovereignHeal
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    GoToIfSet FLAG_RECEIVED_ROUTE_225_HOUSE_FRESH_WATER, Route225House_SovereignTipTop
    Message Route225House_Text_LetPokemonDrinkThis
    SetVar VAR_0x8004, ITEM_FRESH_WATER
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route225House_BagIsFull
    Common_GiveItemQuantity
    SetFlag FLAG_RECEIVED_ROUTE_225_HOUSE_FRESH_WATER
Route225House_SovereignTipTop:
    Message Route225House_Text_SovereignTipTop
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route225House_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End
