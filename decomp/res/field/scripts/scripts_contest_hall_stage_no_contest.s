#include "macros/scrcmd.inc"
#include "res/text/bank/contest_hall_stage_no_contest.h"
#include "res/field/events/events_contest_hall_stage_no_contest.h"


    ScriptEntry ContestHallStageNoContest_Hiker
    ScriptEntry ContestHallStageNoContest_Idol
    ScriptEntry ContestHallStageNoContest_Beauty
    ScriptEntry ContestHallStageNoContest_BlackBelt
    ScriptEntry ContestHallStageNoContest_OnTransition
    ScriptEntry ContestHallStageNoContest_OnLoad
    ScriptEntry ContestHallStageNoContest_LegendaryMeloetta
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Meloetta stands before the stage once a Pokémon has sung the
@ Relic Song for the composer in the lobby (FLAG_SOVEREIGN_MELOETTA_SONG), until it's caught.
ContestHallStageNoContest_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfUnset FLAG_SOVEREIGN_MELOETTA_SONG, ContestHallStageNoContest_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_MELOETTA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, ContestHallStageNoContest_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
ContestHallStageNoContest_OnTransitionEnd:
    End

ContestHallStageNoContest_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, ContestHallStageNoContest_RemoveLegendaryMeloetta
    End

ContestHallStageNoContest_RemoveLegendaryMeloetta:
    RemoveObject LOCALID_LEGENDARY_MELOETTA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

ContestHallStageNoContest_LegendaryMeloetta:
    SetVar VAR_0x8004, SPECIES_MELOETTA
    SetVar VAR_0x8005, 55
    Common_SovereignLegendaryEncounter
    End

ContestHallStageNoContest_Hiker:
    NPCMessage ContestHallStageNoContest_Text_DressUpYourPokemon
    End

ContestHallStageNoContest_Idol:
    NPCMessage ContestHallStageNoContest_Text_MimicTheLeadDancer
    End

ContestHallStageNoContest_Beauty:
    NPCMessage ContestHallStageNoContest_Text_PokemonNeedTheRightMoves
    End

ContestHallStageNoContest_BlackBelt:
    NPCMessage ContestHallStageNoContest_Text_PullOffACoolMove
    End

    .balign 4, 0
