#include "macros/scrcmd.inc"
#include "res/text/bank/eterna_city_south_house.h"
#include "res/field/events/events_eterna_city_south_house.h"


    ScriptEntry EternaCitySouthHouse_ProfOak
    ScriptEntryEnd

EternaCitySouthHouse_ProfOak:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_CAUGHT_ROAMING_LEGENDARY_BIRDS, EternaCitySouthHouse_PokedexRatingsCheckOak2
    Call EternaCitySouthHouse_CheckCaughtAllRoamingLegendaryBirds
    GoToIfEq VAR_RESULT, TRUE, EternaCitySouthHouse_CaughtAllRoamingLegendaryBirds
    GoToIfSet FLAG_ACTIVATED_ROAMING_LEGENDARY_BIRDS, EternaCitySouthHouse_TryReactivateRoamingLegendaryBirds
    GoToIfSet FLAG_RECEIVED_ETERNA_CITY_SOUTH_HOUSE_UPGRADE, EternaCitySouthHouse_PokedexRatingsCheckOak
    BufferPlayerName 0
    Message EternaCitySouthHouse_Text_HowIsYourPokedex
    CloseMessage
    ApplyMovement LOCALID_PROF_OAK, EternaCitySouthHouse_Movement_EmoteExclamationMark
    WaitMovement
    Message EternaCitySouthHouse_Text_AcquaintanceSentSomething
    SetVar VAR_0x8004, ITEM_UPGRADE
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, EternaCitySouthHouse_BagIsFull
    Common_GiveItemQuantity
    SetFlag FLAG_RECEIVED_ETERNA_CITY_SOUTH_HOUSE_UPGRADE
    Message EternaCitySouthHouse_Text_PokemonThatEvolvesTradingWithUpgrade
    GoTo EternaCitySouthHouse_ActivateRoamingLegendaryBirds
    End

EternaCitySouthHouse_PokedexRatingsCheckOak:
    CallCommonScript 0x26E0
    End

EternaCitySouthHouse_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

@ Sovereign (E10 part 27, decision 33): the birds no longer roam. They stand where Renegade put its portals (Mt.
@ Coronet's summit, Valley Windworks, Victory Road) from the Distortion World on, so Oak only hints at the places.
@ FLAG_ACTIVATED_ROAMING_LEGENDARY_BIRDS now means Oak has given the hint.
EternaCitySouthHouse_ActivateRoamingLegendaryBirds:
    SetFlag FLAG_ACTIVATED_ROAMING_LEGENDARY_BIRDS
    Message EternaCitySouthHouse_Text_SightingsOfLegendaryBirds
    GoTo EternaCitySouthHouse_ProfOakEnd
    End

EternaCitySouthHouse_TryReactivateRoamingLegendaryBirds:
    Message EternaCitySouthHouse_Text_LegendaryBirdsExtremelyRare
    GoTo EternaCitySouthHouse_ProfOakEnd
    End

EternaCitySouthHouse_CaughtAllRoamingLegendaryBirds:
    Message EternaCitySouthHouse_Text_YouveCaughtLegendaryBirds
    SetFlag FLAG_CAUGHT_ROAMING_LEGENDARY_BIRDS
    CallCommonScript 0x26E1
    End

EternaCitySouthHouse_PokedexRatingsCheckOak2:
    CallCommonScript 0x26E0
    End

@ The birds can now be caught before Oak's first talk, so his praise waits until he has given the Up-Grade and his hint.
EternaCitySouthHouse_CheckCaughtAllRoamingLegendaryBirds:
    GoToIfUnset FLAG_ACTIVATED_ROAMING_LEGENDARY_BIRDS, EternaCitySouthHouse_DidNotCatchAllRoamingLegendaryBirds
    SovereignCheckSpeciesCaught SPECIES_MOLTRES, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, EternaCitySouthHouse_DidNotCatchAllRoamingLegendaryBirds
    SovereignCheckSpeciesCaught SPECIES_ZAPDOS, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, EternaCitySouthHouse_DidNotCatchAllRoamingLegendaryBirds
    SovereignCheckSpeciesCaught SPECIES_ARTICUNO, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, EternaCitySouthHouse_DidNotCatchAllRoamingLegendaryBirds
    SetVar VAR_RESULT, TRUE
    Return

EternaCitySouthHouse_DidNotCatchAllRoamingLegendaryBirds:
    SetVar VAR_RESULT, FALSE
    Return

EternaCitySouthHouse_ProfOakEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
EternaCitySouthHouse_Movement_EmoteExclamationMark:
    EmoteExclamationMark
    EndMovement
