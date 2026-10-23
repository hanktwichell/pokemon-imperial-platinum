#include "macros/scrcmd.inc"
#include "res/field/events/events_mt_coronet_6f.h"
#include "constants/sovereign_totem_trials.h"


    ScriptEntry MtCoronet6F_OnTransition
    ScriptEntry MtCoronet6F_OnLoad
    ScriptEntry MtCoronet6F_TotemKommoO
    ScriptEntryEnd

MtCoronet6F_HideTotemKommoO:
    SetFlag FLAG_MAP_LOCAL_HIDE_TOTEM
    Return

MtCoronet6F_RemoveTotemKommoO:
    RemoveObject LOCALID_TOTEM_KOMMO_O
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    Return

@ Sovereign (decision 18): the Totem Kommo-o trial.
MtCoronet6F_TotemKommoO:
    SetVar VAR_0x8004, TOTEM_TRIAL_KOMMO_O
    Common_SovereignTotemTrial
    End

MtCoronet6F_OnTransition:
    @ Sovereign: Totem Kommo-o's trial opens once Saturn is beaten at the Galactic HQ.
    CallIfSet FLAG_SOVEREIGN_TOTEM_TRIAL_KOMMO_O, MtCoronet6F_HideTotemKommoO
    CallIfUnset FLAG_DEFEATED_GALACTIC_HQ_CONTROL_ROOM_SATURN, MtCoronet6F_HideTotemKommoO
    GoToIfSet FLAG_SPEAR_PILLAR_IS_DISTORTED, MtCoronet6F_SetWarpSpearPillarDistorted
    GoToIfUnset FLAG_SPEAR_PILLAR_IS_DISTORTED, MtCoronet6F_TrySetWarpSpearPillarDialgaPalkia
    End

MtCoronet6F_OnLoad:
    CallIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, MtCoronet6F_RemoveTotemKommoO
    Call MtCoronet6F_RemoveSpearPillarWarps
    GoToIfSet FLAG_SPEAR_PILLAR_IS_DISTORTED, MtCoronet6F_SetWarpSpearPillarDistorted
    GoToIfUnset FLAG_SPEAR_PILLAR_IS_DISTORTED, MtCoronet6F_TrySetWarpSpearPillarDialgaPalkia
    End

MtCoronet6F_SetWarpSpearPillarDistorted:
    SetWarpEventPos 2, 7, 5
    End

MtCoronet6F_TrySetWarpSpearPillarDialgaPalkia:
    GoToIfGe VAR_EXITED_DISTORTION_WORLD_STATE, 2, MtCoronet6F_TrySetWarpSpearPillarDialga
    GoTo MtCoronet6F_SetWarpSpearPillarNormal
    End

MtCoronet6F_SetWarpSpearPillarNormal:
    SetWarpEventPos 1, 7, 5
    End

MtCoronet6F_TrySetWarpSpearPillarDialga:
    GoToIfUnset FLAG_UNLOCKED_DIALGA_PALKIA_SPEAR_PILLAR, MtCoronet6F_SetWarpSpearPillarNormal
    GoToIfSet FLAG_CAUGHT_DIALGA, MtCoronet6F_TrySetWarpSpearPillarPalkia
    GoToIfGe VAR_SPEAR_PILLAR_DIALGA_STATE, 1, MtCoronet6F_TrySetWarpSpearPillarPalkia
    CheckItem ITEM_ADAMANT_ORB, 1, VAR_MAP_LOCAL_0x01
    GoToIfEq VAR_MAP_LOCAL_0x01, TRUE, MtCoronet6F_SetWarpSpearPillarDialga
    CheckPartyHasHeldItem ITEM_ADAMANT_ORB, VAR_MAP_LOCAL_0x01
    GoToIfEq VAR_MAP_LOCAL_0x01, TRUE, MtCoronet6F_SetWarpSpearPillarDialga
    GoTo MtCoronet6F_TrySetWarpSpearPillarPalkia
    End

MtCoronet6F_TrySetWarpSpearPillarPalkia:
    GoToIfSet FLAG_CAUGHT_PALKIA, MtCoronet6F_SetWarpSpearPillarNormal
    GoToIfGe VAR_SPEAR_PILLAR_PALKIA_STATE, 1, MtCoronet6F_SetWarpSpearPillarNormal
    CheckItem ITEM_LUSTROUS_ORB, 1, VAR_MAP_LOCAL_0x01
    GoToIfEq VAR_MAP_LOCAL_0x01, TRUE, MtCoronet6F_SetWarpSpearPillarPalkia
    CheckPartyHasHeldItem ITEM_LUSTROUS_ORB, VAR_MAP_LOCAL_0x01
    GoToIfEq VAR_MAP_LOCAL_0x01, TRUE, MtCoronet6F_SetWarpSpearPillarPalkia
    GoTo MtCoronet6F_SetWarpSpearPillarNormal
    End

MtCoronet6F_SetWarpSpearPillarDialga:
    SetWarpEventPos 3, 7, 5
    End

MtCoronet6F_SetWarpSpearPillarPalkia:
    SetWarpEventPos 4, 7, 5
    End

MtCoronet6F_RemoveSpearPillarWarps:
    SetWarpEventPos 1, 1, 5
    SetWarpEventPos 2, 1, 5
    SetWarpEventPos 3, 1, 5
    SetWarpEventPos 4, 1, 5
    Return

    .balign 4, 0
