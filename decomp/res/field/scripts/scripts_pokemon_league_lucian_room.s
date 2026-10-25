#include "macros/scrcmd.inc"
#include "res/text/bank/pokemon_league_lucian_room.h"
#include "res/field/events/events_pokemon_league_lucian_room.h"


    ScriptEntry PokemonLeagueLucianRoom_Lucian
    ScriptEntry PokemonLeagueLucianRoom_OnFrame_EnterRoom
    ScriptEntryEnd

PokemonLeagueLucianRoom_Lucian:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_DEFEATED_LUCIAN, PokemonLeagueLucianRoom_LucianPostBattle
    PlayTrainerEncounterBGM TRAINER_ELITE_FOUR_LUCIAN
    Message PokemonLeagueLucianRoom_Text_LucianIntro
    Call PokemonLeagueLucianRoom_SovereignDecidedFormat
    CloseMessage
    CallIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueLucianRoom_StartLucianBattle
    CallIfSet FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueLucianRoom_StartLucianRematchBattle
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonLeagueLucianRoom_BlackOut
    SetFlag FLAG_DEFEATED_LUCIAN
    PlaySE SEQ_SE_DP_KI_GASYAN_sseq
    RemoveObject LOCALID_EXIT_DOOR
    CallIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueLucianRoom_CreateJournalEventDefeatedLucian
    CallIfSet FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueLucianRoom_CreateJournalEventDefeatedRematchLucian
    Message PokemonLeagueLucianRoom_Text_LucianDefeat
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeagueLucianRoom_StartLucianBattle:
    GoToIfEq VAR_0x8008, 1, PokemonLeagueLucianRoom_SovereignStartLucianDoublesBattle
    StartTrainerBattle TRAINER_ELITE_FOUR_LUCIAN
    Return

PokemonLeagueLucianRoom_SovereignStartLucianDoublesBattle:
    StartTrainerBattle TRAINER_SOVEREIGN_ELITE_FOUR_LUCIAN_DOUBLES
    Return

PokemonLeagueLucianRoom_StartLucianRematchBattle:
    GoToIfEq VAR_0x8008, 1, PokemonLeagueLucianRoom_SovereignStartLucianRematchDoublesBattle
    StartTrainerBattle TRAINER_ELITE_FOUR_LUCIAN_REMATCH
    Return

PokemonLeagueLucianRoom_SovereignStartLucianRematchDoublesBattle:
    StartTrainerBattle TRAINER_SOVEREIGN_ELITE_FOUR_LUCIAN_REMATCH_DOUBLES
    Return

PokemonLeagueLucianRoom_CreateJournalEventDefeatedLucian:
    CreateJournalEvent LOCATION_EVENT_BEAT_ELITE_FOUR_MEMBER, TRAINER_ELITE_FOUR_LUCIAN
    Return

PokemonLeagueLucianRoom_CreateJournalEventDefeatedRematchLucian:
    CreateJournalEvent LOCATION_EVENT_BEAT_ELITE_FOUR_MEMBER, TRAINER_ELITE_FOUR_LUCIAN_REMATCH
    Return

PokemonLeagueLucianRoom_BlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

PokemonLeagueLucianRoom_LucianPostBattle:
    Message PokemonLeagueLucianRoom_Text_LucianPostBattle
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeagueLucianRoom_OnFrame_EnterRoom:
    LockAll
    ApplyMovement LOCALID_PLAYER, PokemonLeagueLucianRoom_Movement_PlayerEnterRoom
    WaitMovement
    PlaySE SEQ_SE_DP_KI_GASYAN_sseq
    ClearFlag FLAG_HIDE_POKEMON_LEAGUE_LUCIAN_ROOM_ENTRANCE_DOOR
    AddObject LOCALID_ENTRANCE_DOOR
    SetVar VAR_MAP_LOCAL_0x01, 1
    ReleaseAll
    End

@ Sovereign (E11, docs/EliteFourFormat.md): Lucian's format was decided earlier in the run (bit 3 of
@ VAR_SOVEREIGN_E4_FORMAT, see PokemonLeagueAaronRoom_SovereignChooseFormat).
PokemonLeagueLucianRoom_SovereignDecidedFormat:
    CheckVarBit VAR_SOVEREIGN_E4_FORMAT, 3, VAR_0x8008
    GoToIfEq VAR_0x8008, 0, PokemonLeagueLucianRoom_SovereignDecidedFormatEnd
    Common_SovereignE4CheckLoneMon
    SetVar VAR_0x8008, VAR_RESULT
PokemonLeagueLucianRoom_SovereignDecidedFormatEnd:
    Return

    .balign 4, 0
PokemonLeagueLucianRoom_Movement_PlayerEnterRoom:
    WalkNormalNorth 2
    EndMovement
