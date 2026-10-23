#include "macros/scrcmd.inc"
#include "res/field/events/events_mt_coronet_outside_north.h"


    ScriptEntry MtCoronetOutsideNorth_OnTransition
    ScriptEntry MtCoronetOutsideNorth_OnLoad
    ScriptEntry MtCoronetOutsideNorth_LegendaryCosmog
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): once the Alola Chronicle is open (VAR_SOVEREIGN_CHRONICLE
@ 3), a Cosmog (Lv. 5) floats in Mt. Coronet's top snowfield, the highest walkable spot, until it's caught
@ (FLAG_SOVEREIGN_CAUGHT_COSMOG). A second one comes once the player has Solgaleo or Lunala, so both can be raised
@ (_COSMOG_2). Vanilla gave this map no scripts (scripts_empty).
MtCoronetOutsideNorth_OnTransition:
    Call MtCoronetOutsideNorth_SovereignSetCosmogVisibility
    End

MtCoronetOutsideNorth_SovereignSetCosmogVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, MtCoronetOutsideNorth_SovereignSetCosmogVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_CAUGHT_COSMOG, MtCoronetOutsideNorth_SovereignShowCosmog
    GoToIfSet FLAG_SOVEREIGN_CAUGHT_COSMOG_2, MtCoronetOutsideNorth_SovereignSetCosmogVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_SOLGALEO, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, MtCoronetOutsideNorth_SovereignShowCosmog
    SovereignCheckSpeciesCaught SPECIES_LUNALA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, MtCoronetOutsideNorth_SovereignSetCosmogVisibilityEnd
MtCoronetOutsideNorth_SovereignShowCosmog:
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
MtCoronetOutsideNorth_SovereignSetCosmogVisibilityEnd:
    Return

MtCoronetOutsideNorth_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, MtCoronetOutsideNorth_RemoveLegendaryCosmog
    End

MtCoronetOutsideNorth_RemoveLegendaryCosmog:
    RemoveObject LOCALID_LEGENDARY_COSMOG
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

@ The Pokédex can't tell the first Cosmog from the second, so a catch sets a flag (VAR_RESULT is TRUE after a catch).
MtCoronetOutsideNorth_LegendaryCosmog:
    SetVar VAR_0x8004, SPECIES_COSMOG
    SetVar VAR_0x8005, 5
    Common_SovereignLegendaryEncounter
    GoToIfEq VAR_RESULT, FALSE, MtCoronetOutsideNorth_LegendaryCosmogEnd
    CallIfSet FLAG_SOVEREIGN_CAUGHT_COSMOG, MtCoronetOutsideNorth_SovereignSetCaughtCosmog2
    SetFlag FLAG_SOVEREIGN_CAUGHT_COSMOG
MtCoronetOutsideNorth_LegendaryCosmogEnd:
    End

MtCoronetOutsideNorth_SovereignSetCaughtCosmog2:
    SetFlag FLAG_SOVEREIGN_CAUGHT_COSMOG_2
    Return
