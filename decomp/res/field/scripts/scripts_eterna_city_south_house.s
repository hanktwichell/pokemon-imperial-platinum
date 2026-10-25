#include "macros/scrcmd.inc"
#include "res/text/bank/eterna_city_south_house.h"
#include "res/field/events/events_eterna_city_south_house.h"


    ScriptEntry EternaCitySouthHouse_ProfOak
    ScriptEntryEnd

EternaCitySouthHouse_ProfOak:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    @ Sovereign (E10, Renegade): once the counterpart has been beaten by Route 224's tablet (part 30), Oak gives Oak's
    @ Letter and asks to meet there (Shaymin's event, without the distribution). The letter is a key item, so having it
    @ marks this done.
    CheckItem ITEM_OAKS_LETTER, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, EternaCitySouthHouse_SovereignAfterOaksLetter
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_CHIMCHAR, EternaCitySouthHouse_SovereignOaksLetter
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_PIPLUP, EternaCitySouthHouse_SovereignOaksLetter
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_TURTWIG, EternaCitySouthHouse_SovereignOaksLetter
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_CHIMCHAR, EternaCitySouthHouse_SovereignOaksLetter
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_PIPLUP, EternaCitySouthHouse_SovereignOaksLetter
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_TURTWIG, EternaCitySouthHouse_SovereignOaksLetter
EternaCitySouthHouse_SovereignAfterOaksLetter:
    GoToIfSet FLAG_CAUGHT_ROAMING_LEGENDARY_BIRDS, EternaCitySouthHouse_SovereignQuests
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

@ VAR_SHAYMIN_EVENT_STATE 1 is what the distribution set in vanilla: Route 224 then brings Marley and Oak to the tablet.
EternaCitySouthHouse_SovereignOaksLetter:
    BufferPlayerName 0
    Message EternaCitySouthHouse_Text_SovereignOaksLetter
    SetVar VAR_0x8004, ITEM_OAKS_LETTER
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Message EternaCitySouthHouse_Text_SovereignMeetMeOnRoute224
    SetVar VAR_SHAYMIN_EVENT_STATE, 1
    WaitButton
    CloseMessage
    ReleaseAll
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

@ Sovereign (E10 part 29, Renegade's QUESTS): once Oak has praised the three birds, he shows his two Clear Wings. With
@ Articuno, Zapdos and Moltres in the party one turns into the Silver Wing (Lugia, Route 220); then, with Raikou,
@ Entei and Suicune, the other turns into the Rainbow Wing (Ho-Oh, the Lost Tower). Both are key items, so holding
@ them is the record. Otherwise Oak gives his hint and then rates the Pokédex, as before.
EternaCitySouthHouse_SovereignQuests:
    BufferPlayerName 0
    CheckItem ITEM_SILVER_WING, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, EternaCitySouthHouse_SovereignQuestRainbow
    Message EternaCitySouthHouse_Text_SovereignClearWings
    WaitButton
    CloseMessage
    CheckPartyHasSpecies VAR_RESULT, SPECIES_ARTICUNO
    GoToIfEq VAR_RESULT, FALSE, EternaCitySouthHouse_PokedexRatingsCheckOak2
    CheckPartyHasSpecies VAR_RESULT, SPECIES_ZAPDOS
    GoToIfEq VAR_RESULT, FALSE, EternaCitySouthHouse_PokedexRatingsCheckOak2
    CheckPartyHasSpecies VAR_RESULT, SPECIES_MOLTRES
    GoToIfEq VAR_RESULT, FALSE, EternaCitySouthHouse_PokedexRatingsCheckOak2
    ApplyMovement LOCALID_PROF_OAK, EternaCitySouthHouse_Movement_EmoteExclamationMark
    WaitMovement
    Message EternaCitySouthHouse_Text_SovereignBirdsInParty
    CloseMessage
    Call EternaCitySouthHouse_SovereignWingFlash
    Message EternaCitySouthHouse_Text_SovereignOh
    CloseMessage
    Call EternaCitySouthHouse_SovereignWingFlash
    Message EternaCitySouthHouse_Text_SovereignSilverWing
    SetVar VAR_0x8004, ITEM_SILVER_WING
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Message EternaCitySouthHouse_Text_SovereignLugiaHint
    CloseMessage
    ReleaseAll
    End

EternaCitySouthHouse_SovereignQuestRainbow:
    CheckItem ITEM_RAINBOW_WING, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, EternaCitySouthHouse_PokedexRatingsCheckOak2
    Message EternaCitySouthHouse_Text_SovereignRainbowClearWing
    WaitButton
    CloseMessage
    CheckPartyHasSpecies VAR_RESULT, SPECIES_RAIKOU
    GoToIfEq VAR_RESULT, FALSE, EternaCitySouthHouse_PokedexRatingsCheckOak2
    CheckPartyHasSpecies VAR_RESULT, SPECIES_ENTEI
    GoToIfEq VAR_RESULT, FALSE, EternaCitySouthHouse_PokedexRatingsCheckOak2
    CheckPartyHasSpecies VAR_RESULT, SPECIES_SUICUNE
    GoToIfEq VAR_RESULT, FALSE, EternaCitySouthHouse_PokedexRatingsCheckOak2
    ApplyMovement LOCALID_PROF_OAK, EternaCitySouthHouse_Movement_EmoteExclamationMark
    WaitMovement
    Message EternaCitySouthHouse_Text_SovereignBeastsInParty
    CloseMessage
    Call EternaCitySouthHouse_SovereignWingFlash
    Message EternaCitySouthHouse_Text_SovereignRainbowWing
    SetVar VAR_0x8004, ITEM_RAINBOW_WING
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Message EternaCitySouthHouse_Text_SovereignHoOhHint
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCitySouthHouse_SovereignWingFlash:
    FadeScreenOut FADE_SCREEN_SPEED_MEDIUM, COLOR_WHITE
    WaitFadeScreen
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM, COLOR_WHITE
    WaitFadeScreen
    WaitTime 15, VAR_RESULT
    Return
