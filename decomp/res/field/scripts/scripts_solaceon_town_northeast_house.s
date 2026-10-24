#include "macros/scrcmd.inc"
#include "res/text/bank/solaceon_town_northeast_house.h"


    ScriptEntry SolaceonTownNortheastHouse_PokemonBreederF
    ScriptEntry SolaceonTownNortheastHouse_Cowgirl
    ScriptEntry SolaceonTownNortheastHouse_SovereignSocialite
    ScriptEntryEnd

SolaceonTownNortheastHouse_PokemonBreederF:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GetFirstNonEggInParty VAR_RESULT
    GetPartyMonNature VAR_0x8004, VAR_RESULT
    BufferNatureName 0, VAR_0x8004
    Message SolaceonTownNortheastHouse_Text_YourPokemonHasThisNature
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonTownNortheastHouse_Cowgirl:
    NPCMessage SolaceonTownNortheastHouse_Text_ThisAreaHadManyPokemon
    End

    

@ Sovereign (E10, Renegade's Jirachi event): the second of three wishes. The Socialite wants to see a Pokémon whose
@ head is on fire (Renegade's list: Ponyta, Rapidash, Moltres, Quilava, Infernape; Magmar, Slugma and Magmortar
@ don't count).
SolaceonTownNortheastHouse_SovereignSocialite:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_JIRACHI_WISH_SOLACEON, SolaceonTownNortheastHouse_SovereignSocialiteThanks
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteWish
    CheckPartyHasSpecies VAR_RESULT, SPECIES_PONYTA
    GoToIfEq VAR_RESULT, TRUE, SolaceonTownNortheastHouse_SovereignSocialitePonyta
    CheckPartyHasSpecies VAR_RESULT, SPECIES_RAPIDASH
    GoToIfEq VAR_RESULT, TRUE, SolaceonTownNortheastHouse_SovereignSocialiteRapidash
    CheckPartyHasSpecies VAR_RESULT, SPECIES_MOLTRES
    GoToIfEq VAR_RESULT, TRUE, SolaceonTownNortheastHouse_SovereignSocialiteMoltres
    CheckPartyHasSpecies VAR_RESULT, SPECIES_QUILAVA
    GoToIfEq VAR_RESULT, TRUE, SolaceonTownNortheastHouse_SovereignSocialiteQuilava
    CheckPartyHasSpecies VAR_RESULT, SPECIES_INFERNAPE
    GoToIfEq VAR_RESULT, TRUE, SolaceonTownNortheastHouse_SovereignSocialiteInfernape
    CheckPartyHasSpecies VAR_RESULT, SPECIES_MAGMAR
    GoToIfEq VAR_RESULT, TRUE, SolaceonTownNortheastHouse_SovereignSocialiteMagmar
    CheckPartyHasSpecies VAR_RESULT, SPECIES_SLUGMA
    GoToIfEq VAR_RESULT, TRUE, SolaceonTownNortheastHouse_SovereignSocialiteSlugma
    CheckPartyHasSpecies VAR_RESULT, SPECIES_MAGMORTAR
    GoToIfEq VAR_RESULT, TRUE, SolaceonTownNortheastHouse_SovereignSocialiteMagmortar
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteNoFlame
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonTownNortheastHouse_SovereignSocialitePonyta:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialitePonyta
    GoTo SolaceonTownNortheastHouse_SovereignSocialiteRavishing

SolaceonTownNortheastHouse_SovereignSocialiteRapidash:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteRapidash
    GoTo SolaceonTownNortheastHouse_SovereignSocialiteRavishing

SolaceonTownNortheastHouse_SovereignSocialiteMoltres:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteMoltres
    GoTo SolaceonTownNortheastHouse_SovereignSocialiteRavishing

SolaceonTownNortheastHouse_SovereignSocialiteQuilava:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteQuilava
    GoTo SolaceonTownNortheastHouse_SovereignSocialiteRavishing

SolaceonTownNortheastHouse_SovereignSocialiteInfernape:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteInfernape
    GoTo SolaceonTownNortheastHouse_SovereignSocialiteRavishing

SolaceonTownNortheastHouse_SovereignSocialiteMagmar:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteMagmar
    GoTo SolaceonTownNortheastHouse_SovereignSocialiteNotTheFire

SolaceonTownNortheastHouse_SovereignSocialiteSlugma:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteSlugma
    GoTo SolaceonTownNortheastHouse_SovereignSocialiteNotTheFire

SolaceonTownNortheastHouse_SovereignSocialiteMagmortar:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteMagmortar
    GoTo SolaceonTownNortheastHouse_SovereignSocialiteNotTheFire

SolaceonTownNortheastHouse_SovereignSocialiteRavishing:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteRavishing
    CloseMessage
    Call SolaceonTownNortheastHouse_SovereignWishGranted
    SetFlag FLAG_SOVEREIGN_JIRACHI_WISH_SOLACEON
    ReleaseAll
    End

SolaceonTownNortheastHouse_SovereignSocialiteNotTheFire:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteNotTheFire
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonTownNortheastHouse_SovereignSocialiteThanks:
    Message SolaceonTownNortheastHouse_Text_SovereignSocialiteThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonTownNortheastHouse_SovereignWishGranted:
    WaitTime 10, VAR_RESULT
    FadeScreenOut FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    PlayCry SPECIES_JIRACHI
    WaitCry
    FadeScreenIn FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    Message SolaceonTownNortheastHouse_Text_SovereignWishSeen
    WaitButton
    CloseMessage
    Return

    .balign 4, 0
