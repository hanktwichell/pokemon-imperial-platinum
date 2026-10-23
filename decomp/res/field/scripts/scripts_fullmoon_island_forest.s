#include "macros/scrcmd.inc"
#include "res/text/bank/fullmoon_island_forest.h"
#include "res/field/events/events_fullmoon_island_forest.h"


    ScriptEntry FullmoonIslandForest_Dummy1
    ScriptEntry FullmoonIslandForest_Cresselia
    ScriptEntry FullmoonIslandForest_OnTransition
    ScriptEntry FullmoonIslandForest_OnLoad
    ScriptEntry FullmoonIslandForest_LegendaryTapuLele
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Tapu Lele stands at the north-west edge of the grove once
@ the Alola Chronicle is open (VAR_SOVEREIGN_CHRONICLE 3), until it's caught.
FullmoonIslandForest_OnTransition:
    Call FullmoonIslandForest_SovereignSetTapuLeleVisibility
    End

FullmoonIslandForest_SovereignSetTapuLeleVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, FullmoonIslandForest_SovereignSetTapuLeleVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_TAPU_LELE, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, FullmoonIslandForest_SovereignSetTapuLeleVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
FullmoonIslandForest_SovereignSetTapuLeleVisibilityEnd:
    Return

FullmoonIslandForest_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, FullmoonIslandForest_RemoveLegendaryTapuLele
    End

FullmoonIslandForest_RemoveLegendaryTapuLele:
    RemoveObject LOCALID_LEGENDARY_TAPU_LELE
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

FullmoonIslandForest_LegendaryTapuLele:
    SetVar VAR_0x8004, SPECIES_TAPU_LELE
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

FullmoonIslandForest_Dummy1:
    End

FullmoonIslandForest_Cresselia:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    DrawPokemonPreview SPECIES_CRESSELIA, GENDER_FEMALE
    WaitABPress
    RemovePokemonPreview
    PlayCry SPECIES_CRESSELIA
    GetPlayerDir VAR_RESULT
    CallIfEq VAR_RESULT, DIR_NORTH, FullmoonIslandForest_CresseliaMoveAwayForLunarWing
    ReleaseObject LOCALID_CRESSELIA
    FlickerObject LOCALID_CRESSELIA, 6, 8
    LockObject LOCALID_CRESSELIA
    SetFlag FLAG_HIDE_FULLMOON_ISLAND_FOREST_CRESSELIA
    RemoveObject LOCALID_CRESSELIA
    ActivateRoamingPokemon ROAMING_SLOT_CRESSELIA
    GoToIfEq VAR_ROAMING_CRESSELIA_STATE, ROAMER_STATE_RESET, FullmoonIslandForest_ResetCresseliaRoamingState
    ClearFlag FLAG_OBTAINED_FULLMOON_ISLAND_FOREST_LUNAR_WING
    AddObject LOCALID_ITEM_LUNAR_WING
    SetFlag FLAG_MET_CRESSELIA
    Message FullmoonIslandForest_Text_SomethingSparkling
    WaitButton
    CloseMessage
    ReleaseAll
    End

FullmoonIslandForest_ResetCresseliaRoamingState:
    SetVar VAR_ROAMING_CRESSELIA_STATE, ROAMER_STATE_ROAMING
    ReleaseAll
    End

FullmoonIslandForest_CresseliaMoveAwayForLunarWing:
    SetObjectEventPos LOCALID_ITEM_LUNAR_WING, 16, 14
    ApplyMovement LOCALID_CRESSELIA, FullmoonIslandForest_Movement_CresseliaMoveBackNorth
    WaitMovement
    Return

    .balign 4, 0
FullmoonIslandForest_Movement_CresseliaMoveBackNorth:
    LockDir
    WalkNormalNorth
    UnlockDir
    EndMovement
