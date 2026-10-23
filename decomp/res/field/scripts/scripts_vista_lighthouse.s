#include "macros/scrcmd.inc"
#include "res/text/bank/vista_lighthouse.h"
#include "res/field/events/events_vista_lighthouse.h"
#include "constants/sovereign_totem_trials.h"


    ScriptEntry VistaLighthouse_Sailor
    ScriptEntry VistaLighthouse_Youngster
    ScriptEntry VistaLighthouse_Binoculars
    ScriptEntry VistaLighthouse_Volkner
    ScriptEntry VistaLighthouse_OnTransition
    ScriptEntry VistaLighthouse_TotemTogedemaru
    ScriptEntry VistaLighthouse_OnLoad
    ScriptEntry VistaLighthouse_LegendaryVictini
    ScriptEntryEnd

@ Sovereign: Totem Togedemaru's trial, the last, opens once Cyrus is beaten in the Distortion World.
VistaLighthouse_OnTransition:
    CallIfSet FLAG_SOVEREIGN_TOTEM_TRIAL_TOGEDEMARU, VistaLighthouse_HideTotemTogedemaru
    CallIfLt VAR_DISTORTION_WORLD_PROGRESS, DIST_WORLD_PROGRESS_WON_CYRUS_BATTLE, VistaLighthouse_HideTotemTogedemaru
    Call VistaLighthouse_SovereignSetVictiniVisibility
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Victini sits on the lighthouse's west side once the Unova
@ Chronicle is open, until it's caught.
VistaLighthouse_SovereignSetVictiniVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 1, VistaLighthouse_SovereignSetVictiniVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_VICTINI, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, VistaLighthouse_SovereignSetVictiniVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
VistaLighthouse_SovereignSetVictiniVisibilityEnd:
    Return

VistaLighthouse_OnLoad:
    CallIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, VistaLighthouse_RemoveTotemTogedemaru
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, VistaLighthouse_RemoveLegendaryVictini
    End

VistaLighthouse_RemoveLegendaryVictini:
    RemoveObject LOCALID_LEGENDARY_VICTINI
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

VistaLighthouse_LegendaryVictini:
    SetVar VAR_0x8004, SPECIES_VICTINI
    SetVar VAR_0x8005, 55
    Common_SovereignLegendaryEncounter
    End

VistaLighthouse_HideTotemTogedemaru:
    SetFlag FLAG_MAP_LOCAL_HIDE_TOTEM
    Return

VistaLighthouse_RemoveTotemTogedemaru:
    RemoveObject LOCALID_TOTEM_TOGEDEMARU
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    Return

@ Sovereign (decision 18): the Totem Togedemaru trial.
VistaLighthouse_TotemTogedemaru:
    SetVar VAR_0x8004, TOTEM_TRIAL_TOGEDEMARU
    Common_SovereignTotemTrial
    End

VistaLighthouse_Sailor:
    NPCMessage VistaLighthouse_Text_LighthouseRepresentsSafety
    End

VistaLighthouse_Youngster:
    NPCMessage VistaLighthouse_Text_GoingFarAwayOneDay
    End

VistaLighthouse_Binoculars:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    BufferPlayerName 0
    Message VistaLighthouse_Text_PlayerLookedThroughBinoculars
    CloseMessage
    UseVistaLighthouseBinoculars
    ReleaseAll
    End

VistaLighthouse_Volkner:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message VistaLighthouse_Text_YoureTheLatestChallenger
    Message VistaLighthouse_Text_IWantThrillAgain
    Message VistaLighthouse_Text_UnleashArsenalAtYou
    CloseMessage
    WaitTime 15, VAR_RESULT
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_NORTH, VistaLighthouse_VolknerWalkToDoorNorth
    GoToIfEq VAR_RESULT, DIR_WEST, VistaLighthouse_VolknerWalkToDoorWest
    GoToIfEq VAR_RESULT, DIR_EAST, VistaLighthouse_VolknerWalkToDoorEast
    End

VistaLighthouse_VolknerWalkToDoorNorth:
    ApplyMovement LOCALID_VOLKNER, VistaLighthouse_Movement_VolknerWalkToDoorNorth
    ApplyMovement LOCALID_PLAYER, VistaLighthouse_Movement_PlayerWatchVolknerWalkToDoorNorth
    WaitMovement
    GoTo VistaLighthouse_VolknerLeave

VistaLighthouse_VolknerWalkToDoorWest:
    ApplyMovement LOCALID_VOLKNER, VistaLighthouse_Movement_VolknerWalkToDoorWestEast
    ApplyMovement LOCALID_PLAYER, VistaLighthouse_Movement_PlayerWatchVolknerWalkToDoorWest
    WaitMovement
    GoTo VistaLighthouse_VolknerLeave

VistaLighthouse_VolknerWalkToDoorEast:
    ApplyMovement LOCALID_VOLKNER, VistaLighthouse_Movement_VolknerWalkToDoorWestEast
    WaitMovement
    GoTo VistaLighthouse_VolknerLeave

VistaLighthouse_VolknerLeave:
    LoadDoorAnimation 0, 0, 6, 9, ANIMATION_TAG_DOOR_1
    PlayDoorOpenAnimation ANIMATION_TAG_DOOR_1
    WaitForAnimation ANIMATION_TAG_DOOR_1
    ApplyMovement LOCALID_VOLKNER, VistaLighthouse_Movement_VolknerLeave
    WaitMovement
    PlayDoorCloseAnimation ANIMATION_TAG_DOOR_1
    WaitForAnimation ANIMATION_TAG_DOOR_1
    UnloadAnimation ANIMATION_TAG_DOOR_1
    RemoveObject LOCALID_VOLKNER
    SetFlag FLAG_VOLKNER_RETURNED_TO_GYM
    ReleaseAll
    End

    .balign 4, 0
VistaLighthouse_Movement_VolknerWalkToDoorNorth:
    WalkNormalEast 3
    WalkNormalSouth 6
    WalkNormalWest 3
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
VistaLighthouse_Movement_VolknerWalkToDoorWestEast:
    WalkNormalSouth
    WalkNormalEast 3
    WalkNormalSouth 5
    WalkNormalWest 3
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
VistaLighthouse_Movement_VolknerLeave:
    WalkNormalNorth
    SetInvisible
    EndMovement

    .balign 4, 0
VistaLighthouse_Movement_PlayerWatchVolknerWalkToDoorNorth:
    Delay8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
VistaLighthouse_Movement_PlayerWatchVolknerWalkToDoorWest:
    Delay8
    WalkOnSpotNormalSouth
    Delay8
    WalkOnSpotNormalEast
    EndMovement
