#include "macros/scrcmd.inc"
#include "res/field/events/events_mt_coronet_b1f.h"


    ScriptEntry MtCoronetB1F_OnTransition
    ScriptEntry MtCoronetB1F_OnLoad
    ScriptEntry MtCoronetB1F_LegendaryKyogre
    ScriptEntryEnd

@ Vanilla gave this floor no scripts (scripts_empty).
MtCoronetB1F_OnTransition:
    Call MtCoronetB1F_SovereignSetKyogreVisibility
    End

MtCoronetB1F_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, MtCoronetB1F_RemoveLegendaryKyogre
    End

@ Sovereign (E10, Renegade's legendary events): Kyogre on the island in the middle of the lake, after the Hall of Fame once Steven has given the Orbs (Renegade: a portal, Lv. 70, with the Blue Orb), until it is caught.
MtCoronetB1F_SovereignSetKyogreVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfUnset FLAG_GAME_COMPLETED, MtCoronetB1F_SovereignSetKyogreVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_STEVEN_GAVE_ORBS, MtCoronetB1F_SovereignSetKyogreVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_KYOGRE, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, MtCoronetB1F_SovereignSetKyogreVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
MtCoronetB1F_SovereignSetKyogreVisibilityEnd:
    Return

MtCoronetB1F_RemoveLegendaryKyogre:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_KYOGRE, MtCoronetB1F_RemoveLegendaryKyogreEnd
    RemoveObject LOCALID_LEGENDARY_KYOGRE
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
MtCoronetB1F_RemoveLegendaryKyogreEnd:
    Return

MtCoronetB1F_LegendaryKyogre:
    SetVar VAR_0x8004, SPECIES_KYOGRE
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

    .balign 4, 0
