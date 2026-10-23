#include "macros/scrcmd.inc"
#include "res/field/events/events_old_chateau_dining_area.h"
#include "constants/sovereign_totem_trials.h"


    ScriptEntry OldChateauDiningArea_OnTransition
    ScriptEntry OldChateauDiningArea_OnFrame_OldManLeave
    ScriptEntry OldChateauDiningArea_TotemMimikyu
    ScriptEntry OldChateauDiningArea_OnLoad
    ScriptEntryEnd

OldChateauDiningArea_OnTransition:
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
