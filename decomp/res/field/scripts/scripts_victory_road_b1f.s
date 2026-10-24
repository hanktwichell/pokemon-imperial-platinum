#include "macros/scrcmd.inc"
#include "res/field/events/events_victory_road_b1f.h"


    ScriptEntry VictoryRoadB1F_OnTransition
    ScriptEntry VictoryRoadB1F_OnLoad
    ScriptEntry VictoryRoadB1F_LegendaryEternatus
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Eternatus waits on the TM59 island (Surf) once Zacian and
@ Zamazenta are both caught, until it is caught. It moved here from Turnback Cave's Giratina room (owner, 2026-10-24).
VictoryRoadB1F_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 4, VictoryRoadB1F_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_ZACIAN, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, VictoryRoadB1F_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_ZAMAZENTA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, VictoryRoadB1F_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_ETERNATUS, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, VictoryRoadB1F_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
VictoryRoadB1F_OnTransitionEnd:
    End

VictoryRoadB1F_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, VictoryRoadB1F_RemoveLegendaryEternatus
    End

VictoryRoadB1F_RemoveLegendaryEternatus:
    RemoveObject LOCALID_LEGENDARY_ETERNATUS
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

VictoryRoadB1F_LegendaryEternatus:
    SetVar VAR_0x8004, SPECIES_ETERNATUS
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End
