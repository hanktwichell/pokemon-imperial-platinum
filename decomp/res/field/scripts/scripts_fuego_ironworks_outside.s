#include "macros/scrcmd.inc"
#include "res/text/bank/fuego_ironworks_outside.h"
#include "res/field/events/events_fuego_ironworks_outside.h"
#include "constants/sovereign_totem_trials.h"


    ScriptEntry FuegoIronworksOutside_Signboard
    ScriptEntry FuegoIronworksOutside_OnTransition
    ScriptEntry FuegoIronworksOutside_TotemSalazzle
    ScriptEntry FuegoIronworksOutside_OnLoad
    ScriptEntry FuegoIronworksOutside_LegendaryChiYu
    ScriptEntry FuegoIronworksOutside_SovereignStake7
    ScriptEntry FuegoIronworksOutside_SovereignStake8
    ScriptEntryEnd

@ Sovereign: Totem Salazzle's trial opens once Cyrus is beaten at Celestic Town (the Ironworks opens after Mars).
FuegoIronworksOutside_OnTransition:
    Call FuegoIronworksOutside_SovereignSetStake8Visibility
    Call FuegoIronworksOutside_SovereignSetStake7Visibility
    Call FuegoIronworksOutside_SovereignSetChiYuVisibility
    CallIfSet FLAG_SOVEREIGN_TOTEM_TRIAL_SALAZZLE, FuegoIronworksOutside_HideTotemSalazzle
    CallIfLt VAR_CELESTIC_TOWN_STATE, 1, FuegoIronworksOutside_HideTotemSalazzle
    End

FuegoIronworksOutside_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, FuegoIronworksOutside_RemoveLegendaryChiYu
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

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): one of the Treasures of Ruin, unsealed once both its stakes
@ on this map are pulled out (FLAG_SOVEREIGN_PULLED_STAKE_7 and _8), until it is caught.
FuegoIronworksOutside_SovereignSetChiYuVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, FuegoIronworksOutside_SovereignSetChiYuVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_PULLED_STAKE_7, FuegoIronworksOutside_SovereignSetChiYuVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_PULLED_STAKE_8, FuegoIronworksOutside_SovereignSetChiYuVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_CHI_YU, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, FuegoIronworksOutside_SovereignSetChiYuVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
FuegoIronworksOutside_SovereignSetChiYuVisibilityEnd:
    Return

FuegoIronworksOutside_RemoveLegendaryChiYu:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_CHI_YU, FuegoIronworksOutside_RemoveLegendaryChiYuEnd
    RemoveObject LOCALID_LEGENDARY_CHI_YU
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
FuegoIronworksOutside_RemoveLegendaryChiYuEnd:
    Return

FuegoIronworksOutside_LegendaryChiYu:
    SetVar VAR_0x8004, SPECIES_CHI_YU
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, the Treasures of Ruin): stake 7 of the two that seal ChiYu's shrine here, shown once the
@ Paldea Chronicle is open until it's pulled out (FLAG_SOVEREIGN_PULLED_STAKE_7).
FuegoIronworksOutside_SovereignSetStake7Visibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, FuegoIronworksOutside_SovereignSetStake7VisibilityEnd
    GoToIfSet FLAG_SOVEREIGN_PULLED_STAKE_7, FuegoIronworksOutside_SovereignSetStake7VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
FuegoIronworksOutside_SovereignSetStake7VisibilityEnd:
    Return

FuegoIronworksOutside_SovereignStake7:
    SetVar VAR_0x8004, FLAG_SOVEREIGN_PULLED_STAKE_7
    SetVar VAR_0x8005, LOCALID_SOVEREIGN_STAKE_7
    Common_SovereignStake
    GoToIfEq VAR_RESULT, FALSE, FuegoIronworksOutside_SovereignStake7End
    Call FuegoIronworksOutside_SovereignSetChiYuVisibility
    GoToIfSet FLAG_MAP_LOCAL_HIDE_LEGENDARY, FuegoIronworksOutside_SovereignStake7End
    AddObject LOCALID_LEGENDARY_CHI_YU
FuegoIronworksOutside_SovereignStake7End:
    End

@ Sovereign (the Chronicles, the Treasures of Ruin): stake 8 of the two that seal ChiYu's shrine here, shown once the
@ Paldea Chronicle is open until it's pulled out (FLAG_SOVEREIGN_PULLED_STAKE_8).
FuegoIronworksOutside_SovereignSetStake8Visibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, FuegoIronworksOutside_SovereignSetStake8VisibilityEnd
    GoToIfSet FLAG_SOVEREIGN_PULLED_STAKE_8, FuegoIronworksOutside_SovereignSetStake8VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
FuegoIronworksOutside_SovereignSetStake8VisibilityEnd:
    Return

FuegoIronworksOutside_SovereignStake8:
    SetVar VAR_0x8004, FLAG_SOVEREIGN_PULLED_STAKE_8
    SetVar VAR_0x8005, LOCALID_SOVEREIGN_STAKE_8
    Common_SovereignStake
    GoToIfEq VAR_RESULT, FALSE, FuegoIronworksOutside_SovereignStake8End
    Call FuegoIronworksOutside_SovereignSetChiYuVisibility
    GoToIfSet FLAG_MAP_LOCAL_HIDE_LEGENDARY, FuegoIronworksOutside_SovereignStake8End
    AddObject LOCALID_LEGENDARY_CHI_YU
FuegoIronworksOutside_SovereignStake8End:
    End
