#include "macros/scrcmd.inc"
#include "res/text/bank/pastoria_city_north_house.h"


    ScriptEntry PastoriaCityNorthHouse_ScientistM
    ScriptEntry PastoriaCityNorthHouse_Psyduck
    ScriptEntry PastoriaCityNorthHouse_KidWithNDS
    ScriptEntry PastoriaCityNorthHouse_SovereignLapras
    ScriptEntryEnd

PastoriaCityNorthHouse_ScientistM:
    NPCMessage PastoriaCityNorthHouse_Text_QuickTramTransportation
    End

PastoriaCityNorthHouse_Psyduck:
    PokemonCryAndMessage SPECIES_PSYDUCK, PastoriaCityNorthHouse_Text_PsyduckCry
    End

PastoriaCityNorthHouse_KidWithNDS:
    NPCMessage PastoriaCityNorthHouse_Text_QuickTramsAreSlow
    End

    

@ Sovereign (E10, Renegade): a socialite from far away tells of her Lapras and its days at sea, then gives it to the
@ player (Lv. 35, holding a NeverMeltIce). VAR_MAP_LOCAL_0x01 skips the story on a second talk.
PastoriaCityNorthHouse_SovereignLapras:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_LAPRAS, PastoriaCityNorthHouse_SovereignLaprasAfter
    GoToIfEq VAR_MAP_LOCAL_0x01, 1, PastoriaCityNorthHouse_SovereignLaprasEntrust
    Message PastoriaCityNorthHouse_Text_SovereignLaprasAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, PastoriaCityNorthHouse_SovereignLaprasNoStory
    Message PastoriaCityNorthHouse_Text_SovereignLaprasStory
    SetVar VAR_MAP_LOCAL_0x01, 1
PastoriaCityNorthHouse_SovereignLaprasEntrust:
    Message PastoriaCityNorthHouse_Text_SovereignLaprasEntrust
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, PastoriaCityNorthHouse_SovereignLaprasDeclined
    GetPartyCount VAR_RESULT
    GoToIfEq VAR_RESULT, 6, PastoriaCityNorthHouse_SovereignLaprasPartyFull
    Message PastoriaCityNorthHouse_Text_SovereignLaprasRelief
    PlayFanfare SEQ_FANFA4_sseq
    BufferPlayerName 0
    Message PastoriaCityNorthHouse_Text_SovereignLaprasReceived
    WaitFanfare
    GivePokemon SPECIES_LAPRAS, 35, ITEM_NEVERMELTICE, VAR_RESULT
    SetFlag FLAG_SOVEREIGN_RECEIVED_LAPRAS
    Message PastoriaCityNorthHouse_Text_SovereignLaprasNickname
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, PastoriaCityNorthHouse_SovereignLaprasNickname
    ReleaseAll
    End

PastoriaCityNorthHouse_SovereignLaprasAfter:
    Message PastoriaCityNorthHouse_Text_SovereignLaprasAfter
    WaitButton
    CloseMessage
    ReleaseAll
    End

PastoriaCityNorthHouse_SovereignLaprasNoStory:
    Message PastoriaCityNorthHouse_Text_SovereignLaprasNoStory
    GoTo PastoriaCityNorthHouse_SovereignLaprasEnd

PastoriaCityNorthHouse_SovereignLaprasDeclined:
    Message PastoriaCityNorthHouse_Text_SovereignLaprasDeclined
    GoTo PastoriaCityNorthHouse_SovereignLaprasEnd

PastoriaCityNorthHouse_SovereignLaprasPartyFull:
    Message PastoriaCityNorthHouse_Text_SovereignLaprasPartyFull
PastoriaCityNorthHouse_SovereignLaprasEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

PastoriaCityNorthHouse_SovereignLaprasNickname:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, PastoriaCityNorthHouse_SovereignLaprasNicknamed
    FadeScreenIn
    WaitFadeScreen
    Return

PastoriaCityNorthHouse_SovereignLaprasNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

    .balign 4, 0
