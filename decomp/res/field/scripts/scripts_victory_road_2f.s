#include "macros/scrcmd.inc"
#include "res/field/events/events_victory_road_2f.h"


    ScriptEntry VictoryRoad2F_OnTransition
    ScriptEntry VictoryRoad2F_OnLoad
    ScriptEntry VictoryRoad2F_LegendaryMoltres
    ScriptEntryEnd

@ Sovereign (E10 part 27, Renegade's legendary birds, decision 33): Moltres waits in the small room past the Strength
@ boulders after the Distortion World, until it is caught (Renegade: Lv. 60, a portal here). It stands beside the
@ boulders, clear of the tiles their puzzle needs. Vanilla gave this map no scripts (scripts_empty).
VictoryRoad2F_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfUnset FLAG_DEFEATED_TRAINER_GALACTIC_BOSS_CYRUS_DISTORTION_WORLD, VictoryRoad2F_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_MOLTRES, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, VictoryRoad2F_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
VictoryRoad2F_OnTransitionEnd:
    End

VictoryRoad2F_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, VictoryRoad2F_RemoveLegendaryMoltres
    End

VictoryRoad2F_RemoveLegendaryMoltres:
    RemoveObject LOCALID_LEGENDARY_MOLTRES
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

VictoryRoad2F_LegendaryMoltres:
    SetVar VAR_0x8004, SPECIES_MOLTRES
    SetVar VAR_0x8005, 60
    Common_SovereignLegendaryEncounter
    End
