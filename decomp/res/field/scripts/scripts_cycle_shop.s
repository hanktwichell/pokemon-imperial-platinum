#include "macros/scrcmd.inc"
#include "res/text/bank/cycle_shop.h"


    ScriptEntry CycleShop_PokefanM
    ScriptEntry CycleShop_Clefairy
    ScriptEntry CycleShop_Youngster
    ScriptEntry CycleShop_Manual
    ScriptEntry CycleShop_Catalog
    ScriptEntryEnd

// Sovereign (E10): as in Renegade, Mom already gave the Bicycle, so the manager gives a Dawn Stone instead.
CycleShop_PokefanM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_CYCLE_SHOP_DAWN_STONE, CycleShop_IllReadOperatingManual
    Message CycleShop_Text_ThanksForRescuingMe
    Message CycleShop_Text_SovereignYouAlreadyOwnThisBike
    SetVar VAR_0x8004, ITEM_DAWN_STONE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_CYCLE_SHOP_DAWN_STONE
    SetVar VAR_ETERNA_CITY_BLOCK_EXITS_STATE, 1
    SetBlackOutWarpId 9
    GoTo CycleShop_IllReadOperatingManual
    End

CycleShop_IllReadOperatingManual:
    Message CycleShop_Text_IllReadOperatingManual
    WaitButton
    CloseMessage
    ReleaseAll
    End

CycleShop_Clefairy:
    PokemonCryAndMessage SPECIES_CLEFAIRY, CycleShop_Text_ClefairyPipPiih
    End

CycleShop_Youngster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_TEAM_GALACTIC_LEFT_ETERNA_BUILDING, CycleShop_WhatWasTeamGalacticTrying
    Message CycleShop_Text_ManagersGoneOff
    WaitButton
    CloseMessage
    ReleaseAll
    End

CycleShop_WhatWasTeamGalacticTrying:
    Message CycleShop_Text_WhatWasTeamGalacticTrying
    WaitButton
    CloseMessage
    ReleaseAll
    End

CycleShop_Manual:
    EventMessage CycleShop_Text_ManualOnLatestBicycle
    End

CycleShop_Catalog:
    EventMessage CycleShop_Text_CatalogFromHoenn
    End

    .balign 4, 0
