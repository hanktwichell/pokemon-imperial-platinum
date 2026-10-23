#include "macros/scrcmd.inc"
#include "res/field/events/events_route_210_north.h"
#include "res/text/bank/route_210_north.h"


    ScriptEntry Route210North_BlackBelt
    ScriptEntry Route210North_ArrowSignpostCelesticTown
    ScriptEntry Route210North_SignboardGrandmaWilmasHouse
    ScriptEntry Route210North_SovereignOnTransition
    ScriptEntry Route210North_SovereignOnLoad
    ScriptEntry Route210North_LegendaryZacian
    ScriptEntry Route210North_LegendaryZamazenta
    ScriptEntryEnd

Route210North_BlackBelt:
    NPCMessage Route210North_Text_HowDoesDefogWork
    End

Route210North_ArrowSignpostCelesticTown:
    ShowArrowSign Route210North_Text_SignCelesticTown
    End

Route210North_SignboardGrandmaWilmasHouse:
    ShowLandmarkSign Route210North_Text_SignGrandmaWilmasHouse
    End

    .balign 4, 0

Route210North_SovereignOnTransition:
    Call Route210North_SovereignSetZamazentaVisibility
    Call Route210North_SovereignSetZacianVisibility
    End

Route210North_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route210North_RemoveLegendaryZamazenta
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route210North_RemoveLegendaryZacian
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Zacian, holding the Rusted Sword, waits in the fog once the
@ Galar Chronicle is open, until it is caught.
Route210North_SovereignSetZacianVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 4, Route210North_SovereignSetZacianVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZACIAN, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route210North_SovereignSetZacianVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route210North_SovereignSetZacianVisibilityEnd:
    Return

Route210North_RemoveLegendaryZacian:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_ZACIAN, Route210North_RemoveLegendaryZacianEnd
    RemoveObject LOCALID_LEGENDARY_ZACIAN
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route210North_RemoveLegendaryZacianEnd:
    Return

Route210North_LegendaryZacian:
    SetVar VAR_SOVEREIGN_LEGENDARY_HELD_ITEM, ITEM_RUSTED_SWORD
    SetVar VAR_0x8004, SPECIES_ZACIAN
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Zamazenta, holding the Rusted Shield, comes to the fog once
@ Zacian is caught, until it is caught.
Route210North_SovereignSetZamazentaVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 4, Route210North_SovereignSetZamazentaVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZACIAN, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route210North_SovereignSetZamazentaVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZAMAZENTA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route210North_SovereignSetZamazentaVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
Route210North_SovereignSetZamazentaVisibilityEnd:
    Return

Route210North_RemoveLegendaryZamazenta:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_ZAMAZENTA, Route210North_RemoveLegendaryZamazentaEnd
    RemoveObject LOCALID_LEGENDARY_ZAMAZENTA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route210North_RemoveLegendaryZamazentaEnd:
    Return

Route210North_LegendaryZamazenta:
    SetVar VAR_SOVEREIGN_LEGENDARY_HELD_ITEM, ITEM_RUSTED_SHIELD
    SetVar VAR_0x8004, SPECIES_ZAMAZENTA
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End
