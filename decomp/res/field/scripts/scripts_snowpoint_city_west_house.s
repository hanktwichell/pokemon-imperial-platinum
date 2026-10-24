#include "macros/scrcmd.inc"
#include "res/text/bank/snowpoint_city_west_house.h"


    ScriptEntry SnowpointCityWestHouse_EvolutionItemSeller
    ScriptEntry SnowpointCityWestHouse_MegaStoneSage
    ScriptEntryEnd

// Sovereign (E10): Renegade Platinum's evolution-item seller, ₽10,000 an item (scrcmd_shop.c). Platinum's Mindy and
// her trade moved to Floaroma Town's middle house.
SnowpointCityWestHouse_EvolutionItemSeller:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message SnowpointCityWestHouse_Text_SovereignBuyEvolutionItems
    WaitButton
    CloseMessage
    PokeMartSpecialties MART_SPECIALTIES_ID_EVOLUTION_ITEMS_SNOWPOINT
    ReleaseAll
    End

// Sovereign (docs/MegaEvolution.md): the Mega Stone Sage, one of the four Mega Stone vendors
// (stock in data/mega_stones.yaml, written by tools/engine/gen_items.py).
SnowpointCityWestHouse_MegaStoneSage:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfBadgeAcquired BADGE_ID_ICICLE, SnowpointCityWestHouse_MegaStoneSageShop
    Message SnowpointCityWestHouse_Text_SovereignMegaStoneSageLocked
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointCityWestHouse_MegaStoneSageShop:
    Message SnowpointCityWestHouse_Text_SovereignMegaStoneSageWelcome
    WaitButton
    CloseMessage
    PokeMartSpecialties MART_SPECIALTIES_ID_MEGA_STONES_SNOWPOINT
    ReleaseAll
    End

    .balign 4, 0
