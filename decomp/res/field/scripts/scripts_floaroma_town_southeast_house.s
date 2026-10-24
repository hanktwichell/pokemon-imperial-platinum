#include "macros/scrcmd.inc"
#include "res/text/bank/floaroma_town_southeast_house.h"


    ScriptEntry FloaromaTownSoutheastHouse_ItemFanatic
    ScriptEntry FloaromaTownSoutheastHouse_PokefanF
    ScriptEntryEnd

// Sovereign (E10): Renegade's Item Fanatic. Show him a Pokémon with an item of its own and he gives you that item
// (both, for Ditto and Clamperl), once per Pokémon. Sirfetch'd counts with Farfetch'd (Leek), as in Gen IX.
FloaromaTownSoutheastHouse_ItemFanatic:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_TALKED_TO_FLOAROMA_ITEM_FANATIC, FloaromaTownSoutheastHouse_ItemFanaticCheckParty
    SetFlag FLAG_TALKED_TO_FLOAROMA_ITEM_FANATIC
    Message FloaromaTownSoutheastHouse_Text_ImAnItemFanatic
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownSoutheastHouse_ItemFanaticCheckParty:
    Message FloaromaTownSoutheastHouse_Text_ShowMeAPokemon
    SetVar VAR_0x8008, SPECIES_PIKACHU
    CheckPartyHasSpecies VAR_RESULT, SPECIES_PIKACHU
    GoToIfEq VAR_RESULT, TRUE, FloaromaTownSoutheastHouse_ItemFanaticPikachu
    SetVar VAR_0x8008, SPECIES_FARFETCHD
    CheckPartyHasSpecies VAR_RESULT, SPECIES_FARFETCHD
    GoToIfEq VAR_RESULT, TRUE, FloaromaTownSoutheastHouse_ItemFanaticFarfetchd
    SetVar VAR_0x8008, SPECIES_SIRFETCHD
    CheckPartyHasSpecies VAR_RESULT, SPECIES_SIRFETCHD
    GoToIfEq VAR_RESULT, TRUE, FloaromaTownSoutheastHouse_ItemFanaticFarfetchd
    SetVar VAR_0x8008, SPECIES_CUBONE
    CheckPartyHasSpecies VAR_RESULT, SPECIES_CUBONE
    GoToIfEq VAR_RESULT, TRUE, FloaromaTownSoutheastHouse_ItemFanaticCubone
    SetVar VAR_0x8008, SPECIES_MAROWAK
    CheckPartyHasSpecies VAR_RESULT, SPECIES_MAROWAK
    GoToIfEq VAR_RESULT, TRUE, FloaromaTownSoutheastHouse_ItemFanaticCubone
    SetVar VAR_0x8008, SPECIES_CHANSEY
    CheckPartyHasSpecies VAR_RESULT, SPECIES_CHANSEY
    GoToIfEq VAR_RESULT, TRUE, FloaromaTownSoutheastHouse_ItemFanaticChansey
    SetVar VAR_0x8008, SPECIES_DITTO
    CheckPartyHasSpecies VAR_RESULT, SPECIES_DITTO
    GoToIfEq VAR_RESULT, TRUE, FloaromaTownSoutheastHouse_ItemFanaticDitto
    SetVar VAR_0x8008, SPECIES_CLAMPERL
    CheckPartyHasSpecies VAR_RESULT, SPECIES_CLAMPERL
    GoToIfEq VAR_RESULT, TRUE, FloaromaTownSoutheastHouse_ItemFanaticClamperl
    Message FloaromaTownSoutheastHouse_Text_NoPokemonCanUseSpecialItem
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownSoutheastHouse_ItemFanaticPikachu:
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_PIKACHU, FloaromaTownSoutheastHouse_ItemFanaticAlreadyGiven
    SetFlag FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_PIKACHU
    SetVar VAR_0x8004, ITEM_LIGHT_BALL
    GoTo FloaromaTownSoutheastHouse_ItemFanaticGiveOne

FloaromaTownSoutheastHouse_ItemFanaticFarfetchd:
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_FARFETCHD, FloaromaTownSoutheastHouse_ItemFanaticAlreadyGiven
    SetFlag FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_FARFETCHD
    SetVar VAR_0x8004, ITEM_STICK
    GoTo FloaromaTownSoutheastHouse_ItemFanaticGiveOne

FloaromaTownSoutheastHouse_ItemFanaticCubone:
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_CUBONE, FloaromaTownSoutheastHouse_ItemFanaticAlreadyGiven
    SetFlag FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_CUBONE
    SetVar VAR_0x8004, ITEM_THICK_CLUB
    GoTo FloaromaTownSoutheastHouse_ItemFanaticGiveOne

FloaromaTownSoutheastHouse_ItemFanaticChansey:
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_CHANSEY, FloaromaTownSoutheastHouse_ItemFanaticAlreadyGiven
    SetFlag FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_CHANSEY
    SetVar VAR_0x8004, ITEM_LUCKY_PUNCH
    GoTo FloaromaTownSoutheastHouse_ItemFanaticGiveOne

FloaromaTownSoutheastHouse_ItemFanaticDitto:
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_DITTO, FloaromaTownSoutheastHouse_ItemFanaticAlreadyGiven
    SetFlag FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_DITTO
    BufferSpeciesNameFromVar 0, VAR_0x8008, 0, 0
    Message FloaromaTownSoutheastHouse_Text_TwoSpecialItems
    SetVar VAR_0x8004, ITEM_METAL_POWDER
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_QUICK_POWDER
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    GoTo FloaromaTownSoutheastHouse_ItemFanaticComeBack

FloaromaTownSoutheastHouse_ItemFanaticClamperl:
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_CLAMPERL, FloaromaTownSoutheastHouse_ItemFanaticAlreadyGiven
    SetFlag FLAG_SOVEREIGN_RECEIVED_ITEM_FANATIC_CLAMPERL
    BufferSpeciesNameFromVar 0, VAR_0x8008, 0, 0
    Message FloaromaTownSoutheastHouse_Text_TwoSpecialItems
    SetVar VAR_0x8004, ITEM_DEEPSEATOOTH
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_DEEPSEASCALE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    GoTo FloaromaTownSoutheastHouse_ItemFanaticComeBack

FloaromaTownSoutheastHouse_ItemFanaticGiveOne:
    BufferSpeciesNameFromVar 0, VAR_0x8008, 0, 0
    BufferItemName 1, VAR_0x8004
    Message FloaromaTownSoutheastHouse_Text_HeresOneForYou
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
FloaromaTownSoutheastHouse_ItemFanaticComeBack:
    Message FloaromaTownSoutheastHouse_Text_ComeBackWithMorePokemon
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownSoutheastHouse_ItemFanaticAlreadyGiven:
    BufferSpeciesNameFromVar 0, VAR_0x8008, 0, 0
    Message FloaromaTownSoutheastHouse_Text_AlreadyGivenThatItem
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownSoutheastHouse_PokefanF:
    NPCMessage FloaromaTownSoutheastHouse_Text_MarowakThickClub
    End

    .balign 4, 0
