#include "macros/scrcmd.inc"
#include "res/text/bank/great_marsh_3.h"
#include "res/field/events/events_great_marsh_3.h"
#include "constants/sovereign_totem_trials.h"


    ScriptEntry GreatMarsh3_Collector
    ScriptEntry GreatMarsh3_SignboardArea3
    ScriptEntry GreatMarsh3_OnTransition
    ScriptEntry GreatMarsh3_TotemLurantis
    ScriptEntry GreatMarsh3_OnLoad
    ScriptEntryEnd

@ Sovereign: Totem Lurantis's trial opens once Maylene is beaten (the Cobble Badge). Then the Great Marsh's own
@ OnTransition (SafariGame_InitTram).
GreatMarsh3_OnTransition:
    CallIfSet FLAG_SOVEREIGN_TOTEM_TRIAL_LURANTIS, GreatMarsh3_HideTotemLurantis
    CheckBadgeAcquired BADGE_ID_COBBLE, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, GreatMarsh3_HideTotemLurantis
    InitGreatMarshTram
    End

GreatMarsh3_HideTotemLurantis:
    SetFlag FLAG_MAP_LOCAL_HIDE_TOTEM
    Return

GreatMarsh3_OnLoad:
    GoToIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, GreatMarsh3_RemoveTotemLurantis
    End

GreatMarsh3_RemoveTotemLurantis:
    RemoveObject LOCALID_TOTEM_LURANTIS
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    End

@ Sovereign (decision 18): the Totem Lurantis trial, during a Safari Game (CommonScript_SovereignTotemTrial ends the
@ game if the player loses).
GreatMarsh3_TotemLurantis:
    SetVar VAR_0x8004, TOTEM_TRIAL_LURANTIS
    Common_SovereignTotemTrial
    End

GreatMarsh3_Collector:
    NPCMessage GreatMarsh3_Text_WhatToDo
    End

GreatMarsh3_SignboardArea3:
    ShowLandmarkSign GreatMarsh3_Text_SignArea3
    End
