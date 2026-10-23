#include "macros/scrcmd.inc"
#include "res/field/events/events_old_chateau_dining_area.h"
#include "constants/sovereign_totem_trials.h"


    ScriptEntry OldChateauDiningArea_OnTransition
    ScriptEntry OldChateauDiningArea_OnFrame_OldManLeave
    ScriptEntry OldChateauDiningArea_TotemMimikyu
    ScriptEntry OldChateauDiningArea_OnLoad
    ScriptEntry OldChateauDiningArea_LegendaryMarshadow
    ScriptEntryEnd

OldChateauDiningArea_OnTransition:
    Call OldChateauDiningArea_SovereignSetMarshadowVisibility
    @ Sovereign: Totem Mimikyu's trial opens once Jupiter has left the Galactic Eterna Building.
    CallIfSet FLAG_SOVEREIGN_TOTEM_TRIAL_MIMIKYU, OldChateauDiningArea_HideTotemMimikyu
    CallIfUnset FLAG_TEAM_GALACTIC_LEFT_ETERNA_BUILDING, OldChateauDiningArea_HideTotemMimikyu
    CheckShouldShowGhost 10, VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, 1, OldChateauDiningArea_ShowOldMan
    SetFlag FLAG_HIDE_OLD_CHATEAU_DINING_AREA_OLD_MAN
    End

OldChateauDiningArea_ShowOldMan:
    ClearFlag FLAG_HIDE_OLD_CHATEAU_DINING_AREA_OLD_MAN
    SetVar VAR_OLD_CHATEAU_DINING_AREA_OLD_MAN_STATE, 1
    End

OldChateauDiningArea_HideTotemMimikyu:
    SetFlag FLAG_MAP_LOCAL_HIDE_TOTEM
    Return

OldChateauDiningArea_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, OldChateauDiningArea_RemoveLegendaryMarshadow
    GoToIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, OldChateauDiningArea_RemoveTotemMimikyu
    End

OldChateauDiningArea_RemoveTotemMimikyu:
    RemoveObject LOCALID_TOTEM_MIMIKYU
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    End

@ Sovereign (decision 18): the Totem Mimikyu trial.
OldChateauDiningArea_TotemMimikyu:
    SetVar VAR_0x8004, TOTEM_TRIAL_MIMIKYU
    Common_SovereignTotemTrial
    End

OldChateauDiningArea_OnFrame_OldManLeave:
    LockAll
    ApplyMovement LOCALID_PLAYER, OldChateauDiningArea_Movement_PlayerWatchOldManLeave
    ApplyMovement LOCALID_OLD_MAN, OldChateauDiningArea_Movement_OldManLeave
    WaitMovement
    SetFlag FLAG_HIDE_OLD_CHATEAU_DINING_AREA_OLD_MAN
    RemoveObject LOCALID_OLD_MAN
    SetVar VAR_OLD_CHATEAU_DINING_AREA_OLD_MAN_STATE, 0
    ReleaseAll
    End

    .balign 4, 0
OldChateauDiningArea_Movement_PlayerWatchOldManLeave:
    WalkNormalNorth
    Delay32
    FaceWest
    EndMovement

    .balign 4, 0
OldChateauDiningArea_Movement_OldManLeave:
    Delay8
    FaceWest
    Delay16
    PauseAnimation
    WalkNormalWest 10
    ResumeAnimation
    SetInvisible
    EndMovement

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Marshadow lurks in the dining room's shadows once the Alola
@ Chronicle is open, until it is caught.
OldChateauDiningArea_SovereignSetMarshadowVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, OldChateauDiningArea_SovereignSetMarshadowVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MARSHADOW, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, OldChateauDiningArea_SovereignSetMarshadowVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
OldChateauDiningArea_SovereignSetMarshadowVisibilityEnd:
    Return

OldChateauDiningArea_RemoveLegendaryMarshadow:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_MARSHADOW, OldChateauDiningArea_RemoveLegendaryMarshadowEnd
    RemoveObject LOCALID_LEGENDARY_MARSHADOW
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
OldChateauDiningArea_RemoveLegendaryMarshadowEnd:
    Return

OldChateauDiningArea_LegendaryMarshadow:
    SetVar VAR_0x8004, SPECIES_MARSHADOW
    SetVar VAR_0x8005, 50
    Common_SovereignLegendaryEncounter
    End
