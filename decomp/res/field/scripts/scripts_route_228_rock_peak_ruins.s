#include "macros/scrcmd.inc"
#include "res/field/events/events_route_228_rock_peak_ruins.h"


    ScriptEntry Route228RockPeakRuins_OnTransition
    ScriptEntry Route228RockPeakRuins_OnLoad
    ScriptEntry Route228RockPeakRuins_LegendaryRegidrago
    ScriptEntryEnd

@ Sovereign: vanilla gave this room no scripts (scripts_empty). With a fateful-encounter Regigigas in the party, Route
@ 228's doorway leads to the Regirock chamber (ROCK_PEAK_RUINS) instead. Landorus stood here until 2026-10-24; it now
@ waits outside on Route 228.
Route228RockPeakRuins_OnTransition:
    Call Route228RockPeakRuins_SovereignSetRegidragoVisibility
    End

Route228RockPeakRuins_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route228RockPeakRuins_RemoveLegendaryRegidrago
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Regidrago appears in the ruins while Regirock, Regice and
@ Registeel are in the party, once the Galar Chronicle is open, until it is caught.
Route228RockPeakRuins_SovereignSetRegidragoVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 4, Route228RockPeakRuins_SovereignSetRegidragoVisibilityEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_REGIROCK
    GoToIfEq VAR_RESULT, FALSE, Route228RockPeakRuins_SovereignSetRegidragoVisibilityEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_REGICE
    GoToIfEq VAR_RESULT, FALSE, Route228RockPeakRuins_SovereignSetRegidragoVisibilityEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_REGISTEEL
    GoToIfEq VAR_RESULT, FALSE, Route228RockPeakRuins_SovereignSetRegidragoVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_REGIDRAGO, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route228RockPeakRuins_SovereignSetRegidragoVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
Route228RockPeakRuins_SovereignSetRegidragoVisibilityEnd:
    Return

Route228RockPeakRuins_RemoveLegendaryRegidrago:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_REGIDRAGO, Route228RockPeakRuins_RemoveLegendaryRegidragoEnd
    RemoveObject LOCALID_LEGENDARY_REGIDRAGO
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route228RockPeakRuins_RemoveLegendaryRegidragoEnd:
    Return

Route228RockPeakRuins_LegendaryRegidrago:
    SetVar VAR_0x8004, SPECIES_REGIDRAGO
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End
