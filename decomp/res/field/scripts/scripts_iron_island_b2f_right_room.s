#include "macros/scrcmd.inc"
#include "res/field/events/events_iron_island_b2f_right_room.h"


    ScriptEntry IronIslandB2FRightRoom_OnTransition
    ScriptEntry IronIslandB2FRightRoom_OnLoad
    ScriptEntry IronIslandB2FRightRoom_LegendaryCobalion
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Cobalion stands in the top pocket of this side cave once
@ the Unova Chronicle is open, until it's caught. Vanilla gave this room no scripts (scripts_empty).
IronIslandB2FRightRoom_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 1, IronIslandB2FRightRoom_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_COBALION, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, IronIslandB2FRightRoom_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
IronIslandB2FRightRoom_OnTransitionEnd:
    End

IronIslandB2FRightRoom_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, IronIslandB2FRightRoom_RemoveLegendaryCobalion
    End

IronIslandB2FRightRoom_RemoveLegendaryCobalion:
    RemoveObject LOCALID_LEGENDARY_COBALION
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

IronIslandB2FRightRoom_LegendaryCobalion:
    SetVar VAR_0x8004, SPECIES_COBALION
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End
