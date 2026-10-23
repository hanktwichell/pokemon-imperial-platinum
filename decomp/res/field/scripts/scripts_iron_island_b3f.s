#include "macros/scrcmd.inc"
#include "res/field/events/events_iron_island_b3f.h"


    ScriptEntry IronIslandB3F_OnTransition
    ScriptEntry IronIslandB3F_CoordEvent_PlatformLift
    ScriptEntry IronIslandB3F_Dummy3
    ScriptEntry IronIslandB3F_OnLoad
    ScriptEntry IronIslandB3F_LegendaryNihilego
    ScriptEntryEnd

IronIslandB3F_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, IronIslandB3F_RemoveLegendaryNihilego
    CheckPartyHasFatefulEncounterRegigigas VAR_MAP_LOCAL_0x04
    GoToIfEq VAR_MAP_LOCAL_0x04, FALSE, IronIslandB3F_RemoveWarpIronRuinsWithRegisteel
    GoToIfEq VAR_MAP_LOCAL_0x04, TRUE, IronIslandB3F_RemoveWarpIronRuinsWithoutRegisteel
    End

IronIslandB3F_OnTransition:
    Call IronIslandB3F_SovereignSetNihilegoVisibility
    InitPersistedMapFeaturesForPlatformLift
    CallIfNe VAR_IRON_RUINS_STATE, RUINS_STATE_CAUGHT_REGI, IronIslandB3F_ResetIronRuinsState
    CheckPartyHasFatefulEncounterRegigigas VAR_MAP_LOCAL_0x04
    GoToIfEq VAR_MAP_LOCAL_0x04, FALSE, IronIslandB3F_RemoveWarpIronRuinsWithRegisteel
    GoToIfEq VAR_MAP_LOCAL_0x04, TRUE, IronIslandB3F_RemoveWarpIronRuinsWithoutRegisteel
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): an Ultra Beast (Nihilego) floats in the east pocket once
@ Necrozma is caught, until it's caught.
IronIslandB3F_SovereignSetNihilegoVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_NECROZMA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, IronIslandB3F_SovereignSetNihilegoVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_NIHILEGO, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, IronIslandB3F_SovereignSetNihilegoVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
IronIslandB3F_SovereignSetNihilegoVisibilityEnd:
    Return

IronIslandB3F_RemoveLegendaryNihilego:
    RemoveObject LOCALID_LEGENDARY_NIHILEGO
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    Return

IronIslandB3F_LegendaryNihilego:
    SetVar VAR_0x8004, SPECIES_NIHILEGO
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

IronIslandB3F_RemoveWarpIronRuinsWithRegisteel:
    SetWarpEventPos 3, 17, 1
    End

IronIslandB3F_RemoveWarpIronRuinsWithoutRegisteel:
    SetWarpEventPos 2, 17, 1
    End

IronIslandB3F_CoordEvent_PlatformLift:
    TriggerPlatformLift
    End

IronIslandB3F_ResetIronRuinsState:
    SetVar VAR_IRON_RUINS_STATE, 0
    Return

IronIslandB3F_Dummy3:
    End

    .balign 4, 0
