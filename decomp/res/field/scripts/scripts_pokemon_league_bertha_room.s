#include "macros/scrcmd.inc"
#include "res/text/bank/pokemon_league_bertha_room.h"
#include "res/field/events/events_pokemon_league_bertha_room.h"


    ScriptEntry PokemonLeagueBerthaRoom_Bertha
    ScriptEntry PokemonLeagueBerthaRoom_OnFrame_EnterRoom
    ScriptEntryEnd

PokemonLeagueBerthaRoom_Bertha:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_DEFEATED_BERTHA, PokemonLeagueBerthaRoom_BerthaPostBattle
    PlayTrainerEncounterBGM TRAINER_ELITE_FOUR_BERTHA
    Message PokemonLeagueBerthaRoom_Text_BerthaIntro
    Call PokemonLeagueBerthaRoom_SovereignChooseFormat
    CloseMessage
    CallIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueBerthaRoom_StartBerthaBattle
    CallIfSet FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueBerthaRoom_StartBerthaRematchBattle
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonLeagueBerthaRoom_BlackOut
    SetFlag FLAG_DEFEATED_BERTHA
    PlaySE SEQ_SE_DP_KI_GASYAN_sseq
    RemoveObject LOCALID_EXIT_DOOR
    CallIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueBerthaRoom_CreateJournalEventDefeatedBertha
    CallIfSet FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonLeagueBerthaRoom_CreateJournalEventDefeatedRematchBertha
    Message PokemonLeagueBerthaRoom_Text_BerthaDefeat
    Call PokemonLeagueBerthaRoom_SovereignAnnounceForcedPair
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeagueBerthaRoom_StartBerthaBattle:
    GoToIfEq VAR_0x8008, 1, PokemonLeagueBerthaRoom_SovereignStartBerthaDoublesBattle
    StartTrainerBattle TRAINER_ELITE_FOUR_BERTHA
    Return

PokemonLeagueBerthaRoom_SovereignStartBerthaDoublesBattle:
    StartTrainerBattle TRAINER_SOVEREIGN_ELITE_FOUR_BERTHA_DOUBLES
    Return

PokemonLeagueBerthaRoom_StartBerthaRematchBattle:
    GoToIfEq VAR_0x8008, 1, PokemonLeagueBerthaRoom_SovereignStartBerthaRematchDoublesBattle
    StartTrainerBattle TRAINER_ELITE_FOUR_BERTHA_REMATCH
    Return

PokemonLeagueBerthaRoom_SovereignStartBerthaRematchDoublesBattle:
    StartTrainerBattle TRAINER_SOVEREIGN_ELITE_FOUR_BERTHA_REMATCH_DOUBLES
    Return

PokemonLeagueBerthaRoom_CreateJournalEventDefeatedBertha:
    CreateJournalEvent LOCATION_EVENT_BEAT_ELITE_FOUR_MEMBER, TRAINER_ELITE_FOUR_BERTHA
    Return

PokemonLeagueBerthaRoom_CreateJournalEventDefeatedRematchBertha:
    CreateJournalEvent LOCATION_EVENT_BEAT_ELITE_FOUR_MEMBER, TRAINER_ELITE_FOUR_BERTHA_REMATCH
    Return

PokemonLeagueBerthaRoom_BlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

PokemonLeagueBerthaRoom_BerthaPostBattle:
    Message PokemonLeagueBerthaRoom_Text_BerthaPostBattle
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeagueBerthaRoom_OnFrame_EnterRoom:
    LockAll
    ApplyMovement LOCALID_PLAYER, PokemonLeagueBerthaRoom_Movement_PlayerEnterRoom
    WaitMovement
    PlaySE SEQ_SE_DP_KI_GASYAN_sseq
    ClearFlag FLAG_HIDE_POKEMON_LEAGUE_BERTHA_ROOM_ENTRANCE_DOOR
    AddObject LOCALID_ENTRANCE_DOOR
    SetVar VAR_MAP_LOCAL_0x01, 1
    ReleaseAll
    End

@ Sovereign (E11, docs/EliteFourFormat.md): see PokemonLeagueAaronRoom_SovereignChooseFormat for the bits. The same
@ format as Aaron gives Flint and Lucian the other one, and Bertha says so after her battle.
PokemonLeagueBerthaRoom_SovereignChooseFormat:
    CheckVarBit VAR_SOVEREIGN_E4_FORMAT, 5, VAR_RESULT
    GoToIfEq VAR_RESULT, 1, PokemonLeagueBerthaRoom_SovereignDecidedFormat
    Common_SovereignE4AskFormat
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 1, VAR_RESULT
    SetVar VAR_0x8008, VAR_RESULT
    CheckVarBit VAR_SOVEREIGN_E4_FORMAT, 0, VAR_RESULT
    GoToIfNe VAR_RESULT, VAR_0x8008, PokemonLeagueBerthaRoom_SovereignChooseFormatEnd
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 5, 1
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 6, 1
    CallIfEq VAR_0x8008, 0, PokemonLeagueBerthaRoom_SovereignForcePairDoubles
    CallIfEq VAR_0x8008, 1, PokemonLeagueBerthaRoom_SovereignForcePairSingles
PokemonLeagueBerthaRoom_SovereignChooseFormatEnd:
    Return

PokemonLeagueBerthaRoom_SovereignForcePairDoubles:
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 2, 1
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 3, 1
    Return

PokemonLeagueBerthaRoom_SovereignForcePairSingles:
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 2, 0
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 3, 0
    Return

PokemonLeagueBerthaRoom_SovereignAnnounceForcedPair:
    CheckVarBit VAR_SOVEREIGN_E4_FORMAT, 6, VAR_RESULT
    GoToIfEq VAR_RESULT, 0, PokemonLeagueBerthaRoom_SovereignAnnounceEnd
    SetVarBit VAR_SOVEREIGN_E4_FORMAT, 6, 0
    WaitButton
    CheckVarBit VAR_SOVEREIGN_E4_FORMAT, 2, VAR_RESULT
    GoToIfEq VAR_RESULT, 1, PokemonLeagueBerthaRoom_SovereignAnnounceDoubles
    Message PokemonLeagueBerthaRoom_Text_SovereignTwiceDoubles
    Return

PokemonLeagueBerthaRoom_SovereignAnnounceDoubles:
    Message PokemonLeagueBerthaRoom_Text_SovereignTwiceSingles
PokemonLeagueBerthaRoom_SovereignAnnounceEnd:
    Return

PokemonLeagueBerthaRoom_SovereignDecidedFormat:
    CheckVarBit VAR_SOVEREIGN_E4_FORMAT, 1, VAR_0x8008
    GoToIfEq VAR_0x8008, 0, PokemonLeagueBerthaRoom_SovereignDecidedFormatEnd
    Common_SovereignE4CheckLoneMon
    SetVar VAR_0x8008, VAR_RESULT
PokemonLeagueBerthaRoom_SovereignDecidedFormatEnd:
    Return

    .balign 4, 0
PokemonLeagueBerthaRoom_Movement_PlayerEnterRoom:
    WalkNormalNorth 2
    EndMovement
