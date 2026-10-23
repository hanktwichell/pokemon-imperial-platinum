#include "macros/scrcmd.inc"
#include "res/text/bank/fuego_ironworks_outside.h"
#include "res/field/events/events_fuego_ironworks_outside.h"
#include "constants/sovereign_totem_trials.h"


    ScriptEntry FuegoIronworksOutside_Signboard
    ScriptEntry FuegoIronworksOutside_OnTransition
    ScriptEntry FuegoIronworksOutside_TotemSalazzle
    ScriptEntry FuegoIronworksOutside_OnLoad
    ScriptEntryEnd

@ Sovereign: Totem Salazzle's trial opens once Cyrus is beaten at Celestic Town (the Ironworks opens after Mars).
FuegoIronworksOutside_OnTransition:
    CallIfSet FLAG_SOVEREIGN_TOTEM_TRIAL_SALAZZLE, FuegoIronworksOutside_HideTotemSalazzle
    CallIfLt VAR_CELESTIC_TOWN_STATE, 1, FuegoIronworksOutside_HideTotemSalazzle
    End

FuegoIronworksOutside_OnLoad:
    CallIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, FuegoIronworksOutside_RemoveTotemSalazzle
    End

FuegoIronworksOutside_HideTotemSalazzle:
    SetFlag FLAG_MAP_LOCAL_HIDE_TOTEM
    Return

FuegoIronworksOutside_RemoveTotemSalazzle:
    RemoveObject LOCALID_TOTEM_SALAZZLE
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    Return

@ Sovereign (decision 18): the Totem Salazzle trial.
FuegoIronworksOutside_TotemSalazzle:
    SetVar VAR_0x8004, TOTEM_TRIAL_SALAZZLE
    Common_SovereignTotemTrial
    End

FuegoIronworksOutside_Signboard:
    ShowLandmarkSign FuegoIronworksOutside_Text_SignFuegoIronworks
    End

    .balign 4, 0
