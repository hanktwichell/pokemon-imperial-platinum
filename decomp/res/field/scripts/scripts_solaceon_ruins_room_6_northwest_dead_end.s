#include "macros/scrcmd.inc"
#include "res/field/events/events_solaceon_ruins_room_6_northwest_dead_end.h"


    ScriptEntry SolaceonRuinsRoom6NorthwestDeadEnd_OnTransition
    ScriptEntry SolaceonRuinsRoom6NorthwestDeadEnd_OnLoad
    ScriptEntry SolaceonRuinsRoom6NorthwestDeadEnd_LegendaryHoopa
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Hoopa plays in this dead end, round the pillar, while the
@ player carries the Prison Bottle, which the Archivist gives, until it's caught. It moved here from Room 7 (owner,
@ 2026-10-24), which Jirachi uses.
SolaceonRuinsRoom6NorthwestDeadEnd_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    CheckItem ITEM_PRISON_BOTTLE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SolaceonRuinsRoom6NorthwestDeadEnd_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_HOOPA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SolaceonRuinsRoom6NorthwestDeadEnd_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
SolaceonRuinsRoom6NorthwestDeadEnd_OnTransitionEnd:
    End

SolaceonRuinsRoom6NorthwestDeadEnd_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, SolaceonRuinsRoom6NorthwestDeadEnd_RemoveLegendaryHoopa
    End

SolaceonRuinsRoom6NorthwestDeadEnd_RemoveLegendaryHoopa:
    RemoveObject LOCALID_LEGENDARY_HOOPA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

SolaceonRuinsRoom6NorthwestDeadEnd_LegendaryHoopa:
    SetVar VAR_0x8004, SPECIES_HOOPA
    SetVar VAR_0x8005, 55
    Common_SovereignLegendaryEncounter
    End
