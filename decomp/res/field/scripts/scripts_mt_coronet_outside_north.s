#include "macros/scrcmd.inc"
#include "res/field/events/events_mt_coronet_outside_north.h"


    ScriptEntry MtCoronetOutsideNorth_OnTransition
    ScriptEntry MtCoronetOutsideNorth_OnLoad
    ScriptEntry MtCoronetOutsideNorth_LegendaryCelesteela
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): an Ultra Beast (Celesteela) stands on the highest snowfield
@ once Necrozma is caught, until it's caught. Vanilla gave this map no scripts (scripts_empty).
MtCoronetOutsideNorth_OnTransition:
    Call MtCoronetOutsideNorth_SovereignSetCelesteelaVisibility
    End

MtCoronetOutsideNorth_SovereignSetCelesteelaVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_NECROZMA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, MtCoronetOutsideNorth_SovereignSetCelesteelaVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_CELESTEELA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, MtCoronetOutsideNorth_SovereignSetCelesteelaVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
MtCoronetOutsideNorth_SovereignSetCelesteelaVisibilityEnd:
    Return

MtCoronetOutsideNorth_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, MtCoronetOutsideNorth_RemoveLegendaryCelesteela
    End

MtCoronetOutsideNorth_RemoveLegendaryCelesteela:
    RemoveObject LOCALID_LEGENDARY_CELESTEELA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

MtCoronetOutsideNorth_LegendaryCelesteela:
    SetVar VAR_0x8004, SPECIES_CELESTEELA
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End
