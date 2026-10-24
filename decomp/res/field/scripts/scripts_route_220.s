#include "macros/scrcmd.inc"
#include "res/field/events/events_route_220.h"


    ScriptEntry Route220_OnTransition
    ScriptEntry Route220_OnLoad
    ScriptEntry Route220_LegendaryLugia
    ScriptEntryEnd

@ Sovereign (E10 part 29, Renegade's Lugia): after the Hall of Fame, Lugia waits on the sandbar island at the bottom of
@ the route (Surf) while the player carries the Silver Wing (Professor Oak's, once Articuno, Zapdos and Moltres are
@ in the party), until it is caught (Renegade: Lv. 70, a portal here). Vanilla gave this map no scripts.
Route220_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfUnset FLAG_GAME_COMPLETED, Route220_OnTransitionEnd
    CheckItem ITEM_SILVER_WING, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route220_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_LUGIA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route220_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route220_OnTransitionEnd:
    End

Route220_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route220_RemoveLegendaryLugia
    End

Route220_RemoveLegendaryLugia:
    RemoveObject LOCALID_LEGENDARY_LUGIA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route220_LegendaryLugia:
    SetVar VAR_0x8004, SPECIES_LUGIA
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End
