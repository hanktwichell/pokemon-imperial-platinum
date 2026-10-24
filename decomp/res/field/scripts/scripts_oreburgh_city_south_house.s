#include "macros/scrcmd.inc"
#include "res/text/bank/oreburgh_city_south_house.h"
#include "res/field/events/events_oreburgh_city_south_house.h"


    ScriptEntry OreburghCitySouthHouse_Steven
    ScriptEntryEnd

// Sovereign (E10): Renegade Platinum's Steven. He gives a Beldum, then talks about Hoenn, battles after the Hall of
// Fame, and runs a chain of requests: the Magma Stone for the Soul Dew (Latias and Latios), Latias and Latios for the
// legendary titans, and the titans for the Red and Blue Orbs (Kyogre, Groudon, Rayquaza).
OreburghCitySouthHouse_Steven:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_BELDUM, OreburghCitySouthHouse_StevenMenu
    GoToIfSet FLAG_SOVEREIGN_MET_STEVEN, OreburghCitySouthHouse_StevenOfferBeldum
    Message OreburghCitySouthHouse_Text_StevenIntro
    SetFlag FLAG_SOVEREIGN_MET_STEVEN
OreburghCitySouthHouse_StevenOfferBeldum:
    DrawPokemonPreview SPECIES_BELDUM, GENDER_MALE
    Message OreburghCitySouthHouse_Text_StevenWillYouRaiseBeldum
    ShowYesNoMenu VAR_RESULT
    RemovePokemonPreview
    GoToIfEq VAR_RESULT, MENU_NO, OreburghCitySouthHouse_StevenAreYouSure
    GetPartyCount VAR_RESULT
    GoToIfEq VAR_RESULT, MAX_PARTY_SIZE, OreburghCitySouthHouse_StevenPartyFull
    BufferPlayerName 0
    PlayFanfare SEQ_FANFA4_sseq
    Message OreburghCitySouthHouse_Text_StevenObtainedBeldum
    WaitFanfare
    GivePokemon SPECIES_BELDUM, 10, ITEM_NONE, VAR_RESULT
    SetFlag FLAG_SOVEREIGN_RECEIVED_BELDUM
    Message OreburghCitySouthHouse_Text_StevenNicknameBeldum
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, OreburghCitySouthHouse_StevenNicknameBeldum
    Message OreburghCitySouthHouse_Text_StevenTakeGoodCareOfIt
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenNicknameBeldum:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, OreburghCitySouthHouse_StevenIncrementRecordNicknamed
    FadeScreenIn
    WaitFadeScreen
    Return

OreburghCitySouthHouse_StevenIncrementRecordNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

OreburghCitySouthHouse_StevenAreYouSure:
    Message OreburghCitySouthHouse_Text_StevenAreYouSure
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenPartyFull:
    Message OreburghCitySouthHouse_Text_StevenPartyFull
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenMenu:
    Message OreburghCitySouthHouse_Text_StevenWhatToTalkAbout
    InitLocalTextMenu 31, 9, 0, VAR_RESULT
    SetMenuXOriginToRight
    AddMenuEntryImm OreburghCitySouthHouse_Text_StevenMenuGeneral, 0
    AddMenuEntryImm OreburghCitySouthHouse_Text_StevenMenuQuests, 1
    AddMenuEntryImm OreburghCitySouthHouse_Text_StevenMenuBattle, 2
    AddMenuEntryImm OreburghCitySouthHouse_Text_StevenMenuNothing, 3
    ShowMenu
    GoToIfEq VAR_RESULT, 0, OreburghCitySouthHouse_StevenGeneral
    GoToIfEq VAR_RESULT, 1, OreburghCitySouthHouse_StevenQuests
    GoToIfEq VAR_RESULT, 2, OreburghCitySouthHouse_StevenBattle
    CloseMessage
    ReleaseAll
    End

OreburghCitySouthHouse_StevenGeneral:
    GetRandom VAR_RESULT, 5
    GoToIfEq VAR_RESULT, 0, OreburghCitySouthHouse_StevenGeneral0
    GoToIfEq VAR_RESULT, 1, OreburghCitySouthHouse_StevenGeneral1
    GoToIfEq VAR_RESULT, 2, OreburghCitySouthHouse_StevenGeneral2
    GoToIfEq VAR_RESULT, 3, OreburghCitySouthHouse_StevenGeneral3
    Message OreburghCitySouthHouse_Text_StevenGeneralBattleZone
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenGeneral0:
    Message OreburghCitySouthHouse_Text_StevenGeneralHoenn
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenGeneral1:
    Message OreburghCitySouthHouse_Text_StevenGeneralSteelTypes
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenGeneral2:
    Message OreburghCitySouthHouse_Text_StevenGeneralUnova
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenGeneral3:
    Message OreburghCitySouthHouse_Text_StevenGeneralAlola
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenQuests:
    GoToIfSet FLAG_SOVEREIGN_STEVEN_GAVE_SOUL_DEW, OreburghCitySouthHouse_StevenQuestLatis
    Message OreburghCitySouthHouse_Text_StevenMagmaStone
    WaitButton
    CloseMessage
    CheckItem ITEM_MAGMA_STONE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, OreburghCitySouthHouse_StevenRelease
    ApplyMovement LOCALID_STEVEN, OreburghCitySouthHouse_Movement_StevenExclamation
    WaitMovement
    Message OreburghCitySouthHouse_Text_StevenThatsTheMagmaStone
    BufferPlayerName 0
    RemoveItem ITEM_MAGMA_STONE, 1, VAR_RESULT
    Message OreburghCitySouthHouse_Text_StevenHandedOverMagmaStone
    Message OreburghCitySouthHouse_Text_StevenBeholdSoulDew
    SetVar VAR_0x8004, ITEM_SOUL_DEW
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_STEVEN_GAVE_SOUL_DEW
    Message OreburghCitySouthHouse_Text_StevenLatiasAndLatios
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenQuestLatis:
    GoToIfSet FLAG_SOVEREIGN_STEVEN_SAW_LATIS, OreburghCitySouthHouse_StevenQuestTitans
    Message OreburghCitySouthHouse_Text_StevenLatiasAndLatios
    WaitButton
    CloseMessage
    CheckPartyHasSpecies VAR_RESULT, SPECIES_LATIAS
    GoToIfEq VAR_RESULT, FALSE, OreburghCitySouthHouse_StevenRelease
    CheckPartyHasSpecies VAR_RESULT, SPECIES_LATIOS
    GoToIfEq VAR_RESULT, FALSE, OreburghCitySouthHouse_StevenRelease
    ApplyMovement LOCALID_STEVEN, OreburghCitySouthHouse_Movement_StevenExclamation
    WaitMovement
    SetFlag FLAG_SOVEREIGN_STEVEN_SAW_LATIS
    Message OreburghCitySouthHouse_Text_StevenThatsLatiasAndLatios
OreburghCitySouthHouse_StevenQuestTitans:
    GoToIfSet FLAG_SOVEREIGN_STEVEN_GAVE_ORBS, OreburghCitySouthHouse_StevenThankYou
    Message OreburghCitySouthHouse_Text_StevenLegendaryTitans
    WaitButton
    CloseMessage
    CheckPartyHasSpecies VAR_RESULT, SPECIES_REGIROCK
    GoToIfEq VAR_RESULT, FALSE, OreburghCitySouthHouse_StevenRelease
    CheckPartyHasSpecies VAR_RESULT, SPECIES_REGICE
    GoToIfEq VAR_RESULT, FALSE, OreburghCitySouthHouse_StevenRelease
    CheckPartyHasSpecies VAR_RESULT, SPECIES_REGISTEEL
    GoToIfEq VAR_RESULT, FALSE, OreburghCitySouthHouse_StevenRelease
    ApplyMovement LOCALID_STEVEN, OreburghCitySouthHouse_Movement_StevenExclamation
    WaitMovement
    SetFlag FLAG_SOVEREIGN_STEVEN_GAVE_ORBS
    Message OreburghCitySouthHouse_Text_StevenThatsTheTitans
    SetVar VAR_0x8005, 1
    SetVar VAR_0x8004, ITEM_RED_ORB
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_BLUE_ORB
    Common_GiveItemQuantity
    Message OreburghCitySouthHouse_Text_StevenGroudonKyogreRayquaza
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenThankYou:
    Message OreburghCitySouthHouse_Text_StevenThankYou
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenBattle:
    GoToIfSet FLAG_GAME_COMPLETED, OreburghCitySouthHouse_StevenStartBattle
    Message OreburghCitySouthHouse_Text_StevenYouWouldntStandAChance
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenStartBattle:
    Message OreburghCitySouthHouse_Text_StevenGladlyAccept
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_STEVEN_OREBURGH
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, OreburghCitySouthHouse_StevenLostBattle
    Message OreburghCitySouthHouse_Text_StevenYouveBecomeStrong
    GoTo OreburghCitySouthHouse_StevenEnd

OreburghCitySouthHouse_StevenLostBattle:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message OreburghCitySouthHouse_Text_StevenYouveBecomeStrong
OreburghCitySouthHouse_StevenEnd:
    WaitButton
    CloseMessage
OreburghCitySouthHouse_StevenRelease:
    ReleaseAll
    End

    .balign 4, 0
OreburghCitySouthHouse_Movement_StevenExclamation:
    EmoteExclamationMark
    EndMovement
