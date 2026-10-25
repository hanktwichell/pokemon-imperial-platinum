#include "macros/scrcmd.inc"
#include "res/text/bank/pokemon_league_flint_room.h"
#include "res/field/events/events_pokemon_league_flint_room.h"


    ScriptEntry PokemonLeagueFlintRoom_Flint
    ScriptEntry PokemonLeagueFlintRoom_OnFrame_EnterRoom
    ScriptEntryEnd

PokemonLeagueFlintRoom_Flint:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_DEFEATED_FLINT, PokemonLeagueFlintRoom_PostBattle
    PlayTrainerEncounterBGM TRAINER_ELITE_FOUR_FLINT
    CallIfUnset FLAG_GAME_COMPLETED, PokemonLeagueFlintRoom_FlintIntro
    CallIfSet FLAG_GAME_COMPLETED, PokemonLeagueFlintRoom_FlintGameCompletedIntro
    Call PokemonLeagueFlintRoom_SovereignChooseFormat
    CloseMessage
    CallIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueFlintRoom_StartFlintBattle
    CallIfSet FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueFlintRoom_StartFlintRematchBattle
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonLeagueFlintRoom_BlackOut
    SetFlag FLAG_DEFEATED_FLINT
    PlaySE SEQ_SE_DP_KI_GASYAN_sseq
    RemoveObject LOCALID_EXIT_DOOR
    CallIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueFlintRoom_CreateJournalEventDefeatedFlint
    CallIfSet FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueFlintRoom_CreateJournalEventDefeatedRematchFlint
    CallIfUnset FLAG_GAME_COMPLETED, PokemonLeagueFlintRoom_FlintDefeat
    CallIfSet FLAG_GAME_COMPLETED, PokemonLeagueFlintRoom_FlintGameCompletedDefeat
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeagueFlintRoom_StartFlintBattle:
    GoToIfEq VAR_0x8008, 1, PokemonLeagueFlintRoom_SovereignStartFlintDoublesBattle
    StartTrainerBattle TRAINER_ELITE_FOUR_FLINT
    Return

PokemonLeagueFlintRoom_SovereignStartFlintDoublesBattle:
    StartTrainerBattle TRAINER_SOVEREIGN_ELITE_FOUR_FLINT_DOUBLES
    Return

PokemonLeagueFlintRoom_StartFlintRematchBattle:
    GoToIfEq VAR_0x8008, 1, PokemonLeagueFlintRoom_SovereignStartFlintRematchDoublesBattle
    StartTrainerBattle TRAINER_ELITE_FOUR_FLINT_REMATCH
    Return

PokemonLeagueFlintRoom_SovereignStartFlintRematchDoublesBattle:
    StartTrainerBattle TRAINER_SOVEREIGN_ELITE_FOUR_FLINT_REMATCH_DOUBLES
    Return

PokemonLeagueFlintRoom_CreateJournalEventDefeatedFlint:
    CreateJournalEvent LOCATION_EVENT_BEAT_ELITE_FOUR_MEMBER, TRAINER_ELITE_FOUR_FLINT
    Return

PokemonLeagueFlintRoom_CreateJournalEventDefeatedRematchFlint:
    CreateJournalEvent LOCATION_EVENT_BEAT_ELITE_FOUR_MEMBER, TRAINER_ELITE_FOUR_FLINT_REMATCH
    Return

PokemonLeagueFlintRoom_BlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

PokemonLeagueFlintRoom_PostBattle:
    CallIfUnset FLAG_GAME_COMPLETED, PokemonLeagueFlintRoom_FlintPostBattle
    CallIfSet FLAG_GAME_COMPLETED, PokemonLeagueFlintRoom_FlintGameCompletedPostBattle
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeagueFlintRoom_FlintIntro:
    Message PokemonLeagueFlintRoom_Text_FlintIntroPart1
    CloseMessage
    ApplyMovement LOCALID_FLINT, PokemonLeagueFlintRoom_Movement_WalkFastInPlace
    WaitMovement
    Message PokemonLeagueFlintRoom_Text_FlintIntroPart2
    Return

PokemonLeagueFlintRoom_FlintGameCompletedIntro:
    Message PokemonLeagueFlintRoom_Text_FlintGameCompletedIntro
    Return

PokemonLeagueFlintRoom_FlintDefeat:
    Message PokemonLeagueFlintRoom_Text_FlintDefeat
    Return

PokemonLeagueFlintRoom_FlintGameCompletedDefeat:
    Message PokemonLeagueFlintRoom_Text_FlintGameCompletedDefeat
    Return

PokemonLeagueFlintRoom_FlintPostBattle:
    Message PokemonLeagueFlintRoom_Text_FlintPostBattle
    Return

PokemonLeagueFlintRoom_FlintGameCompletedPostBattle:
    Message PokemonLeagueFlintRoom_Text_FlintGameCompletedPostBattle
    Return

@ Sovereign (E11, docs/EliteFourFormat.md): see PokemonLeagueAaronRoom_SovereignChooseFormat for the bits. Flint asks
@ only when Aaron and Bertha differed; Lucian gets the other format.
PokemonLeagueFlintRoom_SovereignChooseFormat:
    CheckVarBit VAR_SOVEREIGN_E4_FORMAT, 5, VAR_RESULT
    GoToIfEq VAR_RESULT, 1, PokemonLeagueFlintRoom_SovereignDecidedFormat
    Common_SovereignE4AskFormat
    SetVar VAR_0x8008, VAR_RESULT
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 2, VAR_RESULT
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 5, 1
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 3, 1
    CallIfEq VAR_0x8008, 1, PokemonLeagueFlintRoom_SovereignLucianSingles
    Return

PokemonLeagueFlintRoom_SovereignLucianSingles:
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 3, 0
    Return

PokemonLeagueFlintRoom_SovereignDecidedFormat:
    CheckVarBit VAR_SOVEREIGN_E4_FORMAT, 2, VAR_0x8008
    GoToIfEq VAR_0x8008, 0, PokemonLeagueFlintRoom_SovereignDecidedFormatEnd
    Common_SovereignE4CheckLoneMon
    SetVar VAR_0x8008, VAR_RESULT
PokemonLeagueFlintRoom_SovereignDecidedFormatEnd:
    Return

    .balign 4, 0
PokemonLeagueFlintRoom_Movement_WalkFastInPlace:
    LockDir
    WalkOnSpotNormalSouth 3
    WalkOnSpotFastSouth 4
    WalkOnSpotFasterSouth 2
    UnlockDir
    EndMovement

PokemonLeagueFlintRoom_OnFrame_EnterRoom:
    LockAll
    ApplyMovement LOCALID_PLAYER, PokemonLeagueFlintRoom_Movement_PlayerEnterRoom
    WaitMovement
    PlaySE SEQ_SE_DP_KI_GASYAN_sseq
    ClearFlag FLAG_HIDE_POKEMON_LEAGUE_FLINT_ROOM_ENTRANCE_DOOR
    AddObject LOCALID_ENTRANCE_DOOR
    SetVar VAR_MAP_LOCAL_0x01, 1
    ReleaseAll
    End

    .balign 4, 0
PokemonLeagueFlintRoom_Movement_PlayerEnterRoom:
    WalkNormalNorth 2
    EndMovement
