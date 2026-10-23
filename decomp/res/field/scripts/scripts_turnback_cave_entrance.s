#include "macros/scrcmd.inc"
#include "res/text/bank/turnback_cave_entrance.h"
#include "res/field/events/events_turnback_cave_entrance.h"


    ScriptEntry TurnbackCaveEntrance_OnTransition
    ScriptEntry TurnbackCaveEntrance_Inscription
    ScriptEntry TurnbackCaveEntrance_OnLoad
    ScriptEntry TurnbackCaveEntrance_LegendaryGuzzlord
    ScriptEntryEnd

TurnbackCaveEntrance_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_TURNBACK_CAVE
    Call TurnbackCaveEntrance_SovereignSetGuzzlordVisibility
    Call TurnbackCaveEntrance_ResetVars
    InitTurnbackCave VAR_TURNBACK_CAVE_PILLARS_SEEN, VAR_TURNBACK_CAVE_ROOMS_VISITED
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): an Ultra Beast (Guzzlord) lurks in the first room once
@ Necrozma is caught, until it's caught.
TurnbackCaveEntrance_SovereignSetGuzzlordVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_NECROZMA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, TurnbackCaveEntrance_SovereignSetGuzzlordVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_GUZZLORD, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, TurnbackCaveEntrance_SovereignSetGuzzlordVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
TurnbackCaveEntrance_SovereignSetGuzzlordVisibilityEnd:
    Return

TurnbackCaveEntrance_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, TurnbackCaveEntrance_RemoveLegendaryGuzzlord
    End

TurnbackCaveEntrance_RemoveLegendaryGuzzlord:
    RemoveObject LOCALID_LEGENDARY_GUZZLORD
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

TurnbackCaveEntrance_LegendaryGuzzlord:
    SetVar VAR_0x8004, SPECIES_GUZZLORD
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

TurnbackCaveEntrance_ResetVars:
    SetVar VAR_TURNBACK_CAVE_PILLARS_SEEN, 0
    SetVar VAR_TURNBACK_CAVE_ROOMS_VISITED, 0
    Return

TurnbackCaveEntrance_Inscription:
    GoToIfSet FLAG_CAUGHT_GIRATINA, TurnbackCaveEntrance_PastThreePillarsOfferUp
    EventMessage TurnbackCaveEntrance_Text_PastThreePillars
    End

TurnbackCaveEntrance_PastThreePillarsOfferUp:
    EventMessage TurnbackCaveEntrance_Text_PastThreePillarsOfferUp
    End

    .balign 4, 0
