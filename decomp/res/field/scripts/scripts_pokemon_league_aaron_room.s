#include "macros/scrcmd.inc"
#include "res/text/bank/pokemon_league_aaron_room.h"
#include "res/field/events/events_pokemon_league_aaron_room.h"


    ScriptEntry PokemonLeagueAaronRoom_Aaron
    ScriptEntry PokemonLeagueAaronRoom_OnFrame_EnterRoom
    ScriptEntryEnd

PokemonLeagueAaronRoom_Aaron:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_DEFEATED_AARON, PokemonLeagueAaronRoom_AaronPostBattle
    PlayTrainerEncounterBGM TRAINER_ELITE_FOUR_AARON
    Message PokemonLeagueAaronRoom_Text_AaronIntro
    Call PokemonLeagueAaronRoom_SovereignChooseFormat
    CloseMessage
    CallIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueAaronRoom_StartAaronBattle
    CallIfSet FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueAaronRoom_StartAaronRematchBattle
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonLeagueAaronRoom_BlackOut
    SetFlag FLAG_DEFEATED_AARON
    PlaySE SEQ_SE_DP_KI_GASYAN_sseq
    RemoveObject LOCALID_EXIT_DOOR
    CallIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueAaronRoom_CreateJournalEventDefeatedAaron
    CallIfSet FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueAaronRoom_CreateJournalEventDefeatedRematchAaron
    Message PokemonLeagueAaronRoom_Text_AaronDefeat
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeagueAaronRoom_StartAaronBattle:
    GoToIfEq VAR_0x8008, 1, PokemonLeagueAaronRoom_SovereignStartAaronDoublesBattle
    StartTrainerBattle TRAINER_ELITE_FOUR_AARON
    Return

PokemonLeagueAaronRoom_SovereignStartAaronDoublesBattle:
    StartTrainerBattle TRAINER_SOVEREIGN_ELITE_FOUR_AARON_DOUBLES
    Return

PokemonLeagueAaronRoom_StartAaronRematchBattle:
    GoToIfEq VAR_0x8008, 1, PokemonLeagueAaronRoom_SovereignStartAaronRematchDoublesBattle
    StartTrainerBattle TRAINER_ELITE_FOUR_AARON_REMATCH
    Return

PokemonLeagueAaronRoom_SovereignStartAaronRematchDoublesBattle:
    StartTrainerBattle TRAINER_SOVEREIGN_ELITE_FOUR_AARON_REMATCH_DOUBLES
    Return

PokemonLeagueAaronRoom_CreateJournalEventDefeatedAaron:
    CreateJournalEvent LOCATION_EVENT_BEAT_ELITE_FOUR_MEMBER, TRAINER_ELITE_FOUR_AARON
    Return

PokemonLeagueAaronRoom_CreateJournalEventDefeatedRematchAaron:
    CreateJournalEvent LOCATION_EVENT_BEAT_ELITE_FOUR_MEMBER, TRAINER_ELITE_FOUR_AARON_REMATCH
    Return

PokemonLeagueAaronRoom_BlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

PokemonLeagueAaronRoom_AaronPostBattle:
    Message PokemonLeagueAaronRoom_Text_AaronPostBattle
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeagueAaronRoom_OnFrame_EnterRoom:
    LockAll
    ApplyMovement LOCALID_PLAYER, PokemonLeagueAaronRoom_Movement_PlayerEnterRoom
    WaitMovement
    PlaySE SEQ_SE_DP_KI_GASYAN_sseq
    ClearFlag FLAG_HIDE_POKEMON_LEAGUE_AARON_ROOM_ENTRANCE_DOOR
    AddObject LOCALID_ENTRANCE_DOOR
    SetVar VAR_MAP_LOCAL_0x01, 1
    ReleaseAll
    End

@ Sovereign (E11, docs/EliteFourFormat.md): Aaron starts each run, so he sets VAR_SOVEREIGN_E4_FORMAT afresh. Its
@ bits: 0 Aaron, 1 Bertha, 2 Flint, 3 Lucian, 4 Cynthia (1 = doubles), 5 the rest is decided (no more questions),
@ 6 Bertha announces the forced pair. The first challenge, and "Two and two" in a rematch, give two singles and two
@ doubles among the four, and Cynthia doubles. VAR_0x8008 = this battle's format (1 doubles).
PokemonLeagueAaronRoom_SovereignChooseFormat:
    GoToIfUnset FLAG_GAME_COMPLETED, PokemonLeagueAaronRoom_SovereignTwoAndTwo
    Message PokemonLeagueAaronRoom_Text_SovereignHowToChallenge
    InitLocalTextMenu 31, 11, 0, VAR_RESULT, FALSE
    SetMenuXOriginToRight
    AddMenuEntryImm PokemonLeagueAaronRoom_Text_SovereignMenuAllSingles, 0
    AddMenuEntryImm PokemonLeagueAaronRoom_Text_SovereignMenuAllDoubles, 1
    AddMenuEntryImm PokemonLeagueAaronRoom_Text_SovereignMenuTwoAndTwo, 2
    ShowMenu
    GoToIfEq VAR_RESULT, 0, PokemonLeagueAaronRoom_SovereignAllSingles
    GoToIfEq VAR_RESULT, 1, PokemonLeagueAaronRoom_SovereignAllDoubles
PokemonLeagueAaronRoom_SovereignTwoAndTwo:
    SetVar VAR_SOVEREIGN_E4_FORMAT, 16
    Common_SovereignE4AskFormat
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 0, VAR_RESULT
    SetVar VAR_0x8008, VAR_RESULT
    Return

PokemonLeagueAaronRoom_SovereignAllSingles:
    SetVar VAR_SOVEREIGN_E4_FORMAT, 32
    SetVar VAR_0x8008, 0
    Return

PokemonLeagueAaronRoom_SovereignAllDoubles:
    SetVar VAR_SOVEREIGN_E4_FORMAT, 63
    Common_SovereignE4CheckLoneMon
    SetVar VAR_0x8008, VAR_RESULT
    Return

    .balign 4, 0
PokemonLeagueAaronRoom_Movement_PlayerEnterRoom:
    WalkNormalNorth 2
    EndMovement
