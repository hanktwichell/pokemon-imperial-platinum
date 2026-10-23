#include "macros/scrcmd.inc"
#include "res/field/events/events_route_228_rock_peak_ruins.h"


    ScriptEntry Route228RockPeakRuins_OnTransition
    ScriptEntry Route228RockPeakRuins_OnLoad
    ScriptEntry Route228RockPeakRuins_LegendaryLandorus
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Landorus appears in these ruins, the shrine on Route 228,
@ when the player brings Tornadus and Thundurus along, until it's caught. Vanilla gave the room no scripts
@ (scripts_empty). With a fateful-encounter Regigigas in the party, Route 228's doorway leads to the Regirock chamber
@ (ROCK_PEAK_RUINS) instead.
Route228RockPeakRuins_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_LANDORUS, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route228RockPeakRuins_OnTransitionEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_TORNADUS
    GoToIfEq VAR_RESULT, FALSE, Route228RockPeakRuins_OnTransitionEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_THUNDURUS
    GoToIfEq VAR_RESULT, FALSE, Route228RockPeakRuins_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route228RockPeakRuins_OnTransitionEnd:
    End

Route228RockPeakRuins_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route228RockPeakRuins_RemoveLegendaryLandorus
    End

Route228RockPeakRuins_RemoveLegendaryLandorus:
    RemoveObject LOCALID_LEGENDARY_LANDORUS
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route228RockPeakRuins_LegendaryLandorus:
    SetVar VAR_0x8004, SPECIES_LANDORUS
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End
