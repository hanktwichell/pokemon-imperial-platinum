#include "macros/scrcmd.inc"
#include "res/text/bank/fullmoon_island_forest.h"
#include "res/field/events/events_fullmoon_island_forest.h"


    ScriptEntry FullmoonIslandForest_Dummy1
    ScriptEntry FullmoonIslandForest_Cresselia
    ScriptEntry FullmoonIslandForest_OnTransition
    ScriptEntry FullmoonIslandForest_OnLoad
    ScriptEntry FullmoonIslandForest_LegendaryTapuLele
    ScriptEntry FullmoonIslandForest_SovereignLatiRock
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Tapu Lele stands at the north-west edge of the grove once
@ the Alola Chronicle is open (VAR_SOVEREIGN_CHRONICLE 3), until it's caught.
FullmoonIslandForest_OnTransition:
    Call FullmoonIslandForest_SovereignSetTapuLeleVisibility
    Call FullmoonIslandForest_SovereignSetLatiRockVisibility
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
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_TAPU_LELE, FullmoonIslandForest_RemoveLegendaryTapuLeleEnd
    RemoveObject LOCALID_LEGENDARY_TAPU_LELE
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
FullmoonIslandForest_RemoveLegendaryTapuLeleEnd:
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

@ Sovereign (E10, Renegade's legendary events): once Cresselia is caught (and the Lunar Wing taken), a mysterious rock
@ stands where it was. Read from below with the Soul Dew (Steven's gift), it asks "red or blue": Latias or Latios,
@ Lv. 68, until each is caught.
FullmoonIslandForest_SovereignSetLatiRockVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfUnset FLAG_OBTAINED_FULLMOON_ISLAND_FOREST_LUNAR_WING, FullmoonIslandForest_SovereignSetLatiRockVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_CRESSELIA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, FullmoonIslandForest_SovereignSetLatiRockVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
FullmoonIslandForest_SovereignSetLatiRockVisibilityEnd:
    Return

FullmoonIslandForest_SovereignLatiRock:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_NORTH, FullmoonIslandForest_SovereignLatiRockFront
    Message FullmoonIslandForest_Text_SovereignMysteriousRockCarving
    GoTo FullmoonIslandForest_SovereignLatiRockEnd

FullmoonIslandForest_SovereignLatiRockFront:
    Message FullmoonIslandForest_Text_SovereignAllDreamsAreReality
    WaitButton
    CloseMessage
    CheckItem ITEM_SOUL_DEW, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, FullmoonIslandForest_SovereignLatiRockRelease
    WaitTime 15, VAR_RESULT
    Message FullmoonIslandForest_Text_SovereignSoulDewGlowing
    Message FullmoonIslandForest_Text_SovereignRedOrBlue
    InitLocalTextMenu 31, 11, 0, VAR_RESULT
    SetMenuXOriginToRight
    AddMenuEntryImm FullmoonIslandForest_Text_SovereignMenuRed, 0
    AddMenuEntryImm FullmoonIslandForest_Text_SovereignMenuBlue, 1
    AddMenuEntryImm FullmoonIslandForest_Text_SovereignMenuNeither, 2
    ShowMenu
    CloseMessage
    GoToIfEq VAR_RESULT, 0, FullmoonIslandForest_SovereignLatias
    GoToIfEq VAR_RESULT, 1, FullmoonIslandForest_SovereignLatios
    GoTo FullmoonIslandForest_SovereignLatiRockRelease

FullmoonIslandForest_SovereignLatias:
    SovereignCheckSpeciesCaught SPECIES_LATIAS, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, FullmoonIslandForest_SovereignNothingHappened
    SetVar VAR_0x8004, SPECIES_LATIAS
    GoTo FullmoonIslandForest_SovereignLatiEncounter

FullmoonIslandForest_SovereignLatios:
    SovereignCheckSpeciesCaught SPECIES_LATIOS, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, FullmoonIslandForest_SovereignNothingHappened
    SetVar VAR_0x8004, SPECIES_LATIOS
FullmoonIslandForest_SovereignLatiEncounter:
    SetVar VAR_0x8005, 68
    Common_SovereignLegendaryEncounter
    End

FullmoonIslandForest_SovereignNothingHappened:
    Message FullmoonIslandForest_Text_SovereignButNothingHappened
FullmoonIslandForest_SovereignLatiRockEnd:
    WaitButton
    CloseMessage
FullmoonIslandForest_SovereignLatiRockRelease:
    ReleaseAll
    End
