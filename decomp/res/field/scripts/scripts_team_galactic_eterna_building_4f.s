#include "macros/scrcmd.inc"
#include "res/text/bank/team_galactic_eterna_building_4f.h"
#include "res/field/events/events_team_galactic_eterna_building_4f.h"


    ScriptEntry TeamGalacticEternaBuilding4F_OnLoad
    ScriptEntry TeamGalacticEternaBuilding4F_Jupiter
    ScriptEntry TeamGalacticEternaBuilding4F_Clefairy
    ScriptEntry TeamGalacticEternaBuilding4F_Buneary
    ScriptEntry TeamGalacticEternaBuilding4F_PokefanM
    ScriptEntry TeamGalacticEternaBuilding4F_BgSign
    ScriptEntry TeamGalacticEternaBuilding4F_SovereignPorygon
    ScriptEntryEnd

TeamGalacticEternaBuilding4F_OnLoad:
    ScrCmd_2CD
    End

TeamGalacticEternaBuilding4F_Unused:
    ScrCmd_2CD
    End

TeamGalacticEternaBuilding4F_Jupiter:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    ApplyMovement LOCALID_POKEFAN_M, TeamGalacticEternaBuilding4F_Movement_PokefanMWalkOnSpotNorth
    WaitMovement
    Message TeamGalacticEternaBuilding4F_Text_IWillDealWithYou
    CloseMessage
    StartTrainerBattle TRAINER_COMMANDER_JUPITER_TEAM_GALACTIC_ETERNA_BUILDING
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, TeamGalacticEternaBuilding4F_BlackOut
    Message TeamGalacticEternaBuilding4F_Text_WellArentYouTough
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_JUPITER
    FadeScreenIn
    WaitFadeScreen
    WaitTime 15, VAR_RESULT
    GetPlayerDir VAR_0x8004
    GoToIfEq VAR_0x8004, DIR_NORTH, TeamGalacticEternaBuilding4F_PokefanMWalkToPlayerNorth
    GoToIfEq VAR_0x8004, DIR_WEST, TeamGalacticEternaBuilding4F_PokefanMWalkToPlayerWest
    GoToIfEq VAR_0x8004, DIR_EAST, TeamGalacticEternaBuilding4F_PokefanMWalkToPlayerEast
    End

TeamGalacticEternaBuilding4F_PokefanMWalkToPlayerNorth:
    ApplyMovement LOCALID_POKEFAN_M, TeamGalacticEternaBuilding4F_Movement_PokefanMWalkToPlayerNorth
    ApplyMovement LOCALID_PLAYER, TeamGalacticEternaBuilding4F_Movement_PlayerFacePokefanM
    WaitMovement
    GoTo TeamGalacticEternaBuilding4F_HandleTeamGalacticLeftEternaBuilding
    End

TeamGalacticEternaBuilding4F_PokefanMWalkToPlayerWest:
    ApplyMovement LOCALID_POKEFAN_M, TeamGalacticEternaBuilding4F_Movement_PokefanMWalkToPlayerWest
    WaitMovement
    GoTo TeamGalacticEternaBuilding4F_HandleTeamGalacticLeftEternaBuilding
    End

TeamGalacticEternaBuilding4F_PokefanMWalkToPlayerEast:
    ApplyMovement LOCALID_POKEFAN_M, TeamGalacticEternaBuilding4F_Movement_PokefanMWalkToPlayerEast
    WaitMovement
    GoTo TeamGalacticEternaBuilding4F_HandleTeamGalacticLeftEternaBuilding
    End

TeamGalacticEternaBuilding4F_HandleTeamGalacticLeftEternaBuilding:
    Message TeamGalacticEternaBuilding4F_Text_ThankYouCruiseByCycleShop
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SetFlag FLAG_HIDE_ETERNA_CITY_GALACTIC_GRUNTS
    SetFlag FLAG_HIDE_TEAM_GALACTIC_ETERNA_BUILDING_1F_LOOKER
    SetFlag FLAG_HIDE_TEAM_GALACTIC_ETERNA_BUILDING_1F_GRUNT_M_LOOKER
    SetFlag FLAG_TEAM_GALACTIC_LEFT_ETERNA_BUILDING
    ClearFlag FLAG_HIDE_CYCLE_SHOP_POKEFAN_M
    ClearFlag FLAG_HIDE_CYCLE_SHOP_CLEFAIRY
    ClearFlag FLAG_HIDE_ETERNA_CITY_POKECENTER_1F_BUNEARY
    RemoveObject LOCALID_POKEFAN_M
    RemoveObject LOCALID_CLEFAIRY
    RemoveObject LOCALID_BUNEARY
    SetVar VAR_ETERNA_CITY_STATE, 3
    FadeScreenIn
    WaitFadeScreen
    SetFlag FLAG_ALT_MUSIC_GALACTIC_ETERNA_BUILDING
    ReleaseAll
    End

TeamGalacticEternaBuilding4F_BlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
TeamGalacticEternaBuilding4F_Movement_PokefanMWalkOnSpotNorth:
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
TeamGalacticEternaBuilding4F_Movement_PokefanMWalkToPlayerNorth:
    WalkNormalNorth
    EndMovement

TeamGalacticEternaBuilding4F_Movement_Unused:
    Delay8
    WalkNormalEast 2
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
TeamGalacticEternaBuilding4F_Movement_PokefanMWalkToPlayerWest:
    WalkNormalNorth 3
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
TeamGalacticEternaBuilding4F_Movement_PokefanMWalkToPlayerEast:
    WalkNormalNorth 3
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
TeamGalacticEternaBuilding4F_Movement_PlayerFacePokefanM:
    Delay8
    WalkOnSpotNormalSouth
    EndMovement

TeamGalacticEternaBuilding4F_Movement_Unused2:
    WalkOnSpotNormalWest
    Delay4
    WalkOnSpotNormalSouth
    EndMovement

TeamGalacticEternaBuilding4F_Movement_Unused3:
    WalkOnSpotNormalWest
    EndMovement

TeamGalacticEternaBuilding4F_Clefairy:
    PokemonCryAndMessage SPECIES_CLEFAIRY, TeamGalacticEternaBuilding4F_Text_ClefairyCry
    End

TeamGalacticEternaBuilding4F_Buneary:
    PokemonCryAndMessage SPECIES_BUNEARY, TeamGalacticEternaBuilding4F_Text_BunearyCry
    End

TeamGalacticEternaBuilding4F_PokefanM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_TEAM_GALACTIC_LEFT_ETERNA_BUILDING, TeamGalacticEternaBuilding4F_ThankYouCruiseByCycleShop
    Message TeamGalacticEternaBuilding4F_Text_WhatsWithTeamGalactic
    WaitButton
    CloseMessage
    ReleaseAll
    End

TeamGalacticEternaBuilding4F_ThankYouCruiseByCycleShop:
    Message TeamGalacticEternaBuilding4F_Text_ThankYouCruiseByCycleShop
    WaitButton
    CloseMessage
    ReleaseAll
    End

TeamGalacticEternaBuilding4F_BgSign:
    EventMessage TeamGalacticEternaBuilding4F_Text_WorkingForWorldPeace
    End

// Sovereign (E10): Renegade's Porygon, a Poké Ball behind Jupiter (it was the Veilstone northeast house gift).
TeamGalacticEternaBuilding4F_SovereignPorygon:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    BufferPlayerName 0
    PlayCry SPECIES_PORYGON
    DrawPokemonPreview SPECIES_PORYGON, GENDER_MALE
    Message TeamGalacticEternaBuilding4F_Text_SovereignItsAPorygon
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, TeamGalacticEternaBuilding4F_SovereignPorygonSad
    GetPartyCount VAR_RESULT
    GoToIfEq VAR_RESULT, MAX_PARTY_SIZE, TeamGalacticEternaBuilding4F_SovereignPorygonNoRoom
    RemovePokemonPreview
    SetFlag FLAG_RECEIVED_TEAM_GALACTIC_ETERNA_BUILDING_PORYGON
    RemoveObject LOCALID_SOVEREIGN_PORYGON_BALL
    PlayFanfare SEQ_FANFA4_sseq
    Message TeamGalacticEternaBuilding4F_Text_SovereignAdoptedPorygon
    WaitFanfare
    GivePokemon SPECIES_PORYGON, 22, ITEM_NONE, VAR_RESULT
    Message TeamGalacticEternaBuilding4F_Text_SovereignNicknamePorygon
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    GoToIfEq VAR_RESULT, MENU_YES, TeamGalacticEternaBuilding4F_SovereignNicknamePorygon
    ReleaseAll
    End

TeamGalacticEternaBuilding4F_SovereignNicknamePorygon:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, TeamGalacticEternaBuilding4F_SovereignIncrementRecordNicknamed
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

TeamGalacticEternaBuilding4F_SovereignIncrementRecordNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

TeamGalacticEternaBuilding4F_SovereignPorygonSad:
    Message TeamGalacticEternaBuilding4F_Text_SovereignPorygonLooksSad
    GoTo TeamGalacticEternaBuilding4F_SovereignPorygonEnd
    End

TeamGalacticEternaBuilding4F_SovereignPorygonNoRoom:
    Message TeamGalacticEternaBuilding4F_Text_SovereignNoRoomForPorygon
    GoTo TeamGalacticEternaBuilding4F_SovereignPorygonEnd
    End

TeamGalacticEternaBuilding4F_SovereignPorygonEnd:
    WaitButton
    RemovePokemonPreview
    CloseMessage
    ReleaseAll
    End
