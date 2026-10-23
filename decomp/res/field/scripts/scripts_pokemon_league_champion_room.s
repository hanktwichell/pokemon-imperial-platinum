#include "macros/scrcmd.inc"
#include "res/text/bank/pokemon_league_champion_room.h"
#include "res/field/events/events_pokemon_league_champion_room.h"


    ScriptEntry PokemonLeagueChampionRoom_OnTransition
    ScriptEntry PokemonLeagueChampionRoom_OnFrame_EnterRoom
    ScriptEntryEnd

PokemonLeagueChampionRoom_OnTransition:
    InitPersistedMapFeaturesForPlatformLift
    End

PokemonLeagueChampionRoom_OnFrame_EnterRoom:
    ApplyMovement LOCALID_PLAYER, PokemonLeagueChampionRoom_Movement_PlayerApproachCynthia
    WaitMovement
    PlayTrainerEncounterBGM TRAINER_CHAMPION_CYNTHIA
    CallIfUnset FLAG_GAME_COMPLETED, PokemonLeagueChampionRoom_CynthiaIntro
    CallIfSet FLAG_GAME_COMPLETED, PokemonLeagueChampionRoom_CynthiaGameCompletedIntro
    CloseMessage
    SetFlag FLAG_ALT_MUSIC_CHAMPION_ROOM
    CallIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueChampionRoom_StartCynthiaBattle
    CallIfSet FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueChampionRoom_StartCynthiaRematchBattle
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonLeagueChampionRoom_BlackOut
    Message PokemonLeagueChampionRoom_Text_CynthiaDefeat
    SetFlag FLAG_DEFEATED_CYNTHIA
    CallIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueChampionRoom_CreateJournalEventDefeatedCynthia
    CallIfSet FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueChampionRoom_CreateJournalEventDefeatedRematchCynthia
    CallIfSet FLAG_GAME_COMPLETED, PokemonLeagueChampionRoom_SovereignRematchWin
    Message PokemonLeagueChampionRoom_Text_ComeWithMe
    CloseMessage
    ApplyMovement LOCALID_CYNTHIA, PokemonLeagueChampionRoom_Movement_CynthiaWalkAwayFromElevator
    WaitMovement
    ApplyMovement LOCALID_PLAYER, PokemonLeagueChampionRoom_Movement_PlayerEnterElevator
    WaitMovement
    ApplyMovement LOCALID_CYNTHIA, PokemonLeagueChampionRoom_Movement_CynthiaFacePlayer
    WaitMovement
    WaitTime 30, VAR_RESULT
    TriggerPlatformLift
    WaitTime 30, VAR_RESULT
    SetFlag FLAG_HIDE_POKEMON_LEAGUE_HALLWAY_TO_HALL_OF_FAME_CYNTHIA
    SetFlag FLAG_HIDE_POKEMON_LEAGUE_HALLWAY_TO_HALL_OF_FAME_PROF_ROWAN
    ApplyMovement LOCALID_PLAYER, PokemonLeagueChampionRoom_Movement_PlayerEnterHallwayToHallOfFame
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    FadeScreenOut
    WaitFadeScreen
    Warp MAP_HEADER_POKEMON_LEAGUE_HALLWAY_TO_HALL_OF_FAME, 5, 23, DIR_NORTH
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

@ Sovereign (Story.md): the first rematch win turns the Crown into the Sovereign Crown, and Cynthia sends the player
@ to the Spear Pillar (FLAG_SOVEREIGN_CALLED_TO_SPEAR_PILLAR). She reminds them on later wins until the Sovereign is
@ beaten. FLAG_GAME_COMPLETED is set by the first Hall of Fame, so it is still unset during the first win.
PokemonLeagueChampionRoom_SovereignRematchWin:
    GoToIfSet FLAG_SOVEREIGN_DEFEATED_HENRY, PokemonLeagueChampionRoom_SovereignRematchWinEnd
    GoToIfSet FLAG_SOVEREIGN_CALLED_TO_SPEAR_PILLAR, PokemonLeagueChampionRoom_SovereignSpearPillarReminder
    CheckItem ITEM_CROWN, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonLeagueChampionRoom_SovereignRematchWinEnd
    Message PokemonLeagueChampionRoom_Text_SovereignSomethingIsGlowing
    Message PokemonLeagueChampionRoom_Text_SovereignCrownIsShining
    WaitButton
    CloseMessage
    RemoveItem ITEM_CROWN, 1, VAR_RESULT
    SetVar VAR_0x8004, ITEM_SOVEREIGN_CROWN
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantityNoLineFeed
    SetFlag FLAG_SOVEREIGN_CALLED_TO_SPEAR_PILLAR
    Message PokemonLeagueChampionRoom_Text_SovereignGoToSpearPillar
    Return

PokemonLeagueChampionRoom_SovereignSpearPillarReminder:
    Message PokemonLeagueChampionRoom_Text_SovereignSpearPillarReminder
PokemonLeagueChampionRoom_SovereignRematchWinEnd:
    Return

PokemonLeagueChampionRoom_CynthiaIntro:
    Message PokemonLeagueChampionRoom_Text_CynthiaIntro
    Return

PokemonLeagueChampionRoom_CynthiaGameCompletedIntro:
    Message PokemonLeagueChampionRoom_Text_CynthiaGameCompletedIntro
    Return

PokemonLeagueChampionRoom_StartCynthiaBattle:
    StartTrainerBattle TRAINER_CHAMPION_CYNTHIA
    Return

PokemonLeagueChampionRoom_StartCynthiaRematchBattle:
    StartTrainerBattle TRAINER_CHAMPION_CYNTHIA_REMATCH
    Return

PokemonLeagueChampionRoom_CreateJournalEventDefeatedCynthia:
    CreateJournalEvent LOCATION_EVENT_BEAT_CHAMPION, TRAINER_CHAMPION_CYNTHIA
    Return

PokemonLeagueChampionRoom_CreateJournalEventDefeatedRematchCynthia:
    CreateJournalEvent LOCATION_EVENT_BEAT_CHAMPION, TRAINER_CHAMPION_CYNTHIA_REMATCH
    Return

PokemonLeagueChampionRoom_BlackOut:
    ClearFlag FLAG_ALT_MUSIC_CHAMPION_ROOM
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
PokemonLeagueChampionRoom_Movement_PlayerApproachCynthia:
    WalkNormalNorth 4
    EndMovement

    .balign 4, 0
PokemonLeagueChampionRoom_Movement_PlayerEnterElevator:
    WalkNormalNorth 6
    EndMovement

    .balign 4, 0
PokemonLeagueChampionRoom_Movement_PlayerEnterHallwayToHallOfFame:
    WalkNormalNorth 6
    EndMovement

    .balign 4, 0
PokemonLeagueChampionRoom_Movement_CynthiaWalkAwayFromElevator:
    WalkNormalWest
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
PokemonLeagueChampionRoom_Movement_CynthiaFacePlayer:
    WalkOnSpotNormalNorth
    EndMovement
