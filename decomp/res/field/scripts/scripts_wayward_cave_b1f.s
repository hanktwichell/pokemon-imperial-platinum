#include "macros/scrcmd.inc"
#include "res/field/events/events_wayward_cave_b1f.h"


    ScriptEntry WaywardCaveB1F_OnTransition
    ScriptEntry WaywardCaveB1F_OnLoad
    ScriptEntry WaywardCaveB1F_LegendaryZygarde
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Zygarde waits in an alcove of these hidden depths once
@ Xerneas and Yveltal are both caught, until it's caught too. Vanilla gave this floor no scripts (scripts_empty).
WaywardCaveB1F_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_ZYGARDE, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, WaywardCaveB1F_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_XERNEAS, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, WaywardCaveB1F_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_YVELTAL, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, WaywardCaveB1F_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
WaywardCaveB1F_OnTransitionEnd:
    End

WaywardCaveB1F_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, WaywardCaveB1F_RemoveLegendaryZygarde
    End

WaywardCaveB1F_RemoveLegendaryZygarde:
    RemoveObject LOCALID_LEGENDARY_ZYGARDE
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

WaywardCaveB1F_LegendaryZygarde:
    SetVar VAR_0x8004, SPECIES_ZYGARDE
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End
