#include "macros/scrcmd.inc"
#include "res/text/bank/verity_cavern.h"
#include "res/field/events/events_verity_cavern.h"


    ScriptEntry VerityCavern_OnTransition
    ScriptEntry VerityCavern_Mesprit
    ScriptEntry VerityCavern_OnLoad
    ScriptEntryEnd

VerityCavern_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_VERITY_CAVERN
    End

VerityCavern_OnLoad:
    GoToIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, VerityCavern_RemoveMesprit
    End

@ Sovereign (E10, Renegade's legendary events): Mesprit doesn't roam. Like Uxie and Azelf it's a Lv. 60 battle in its
@ cavern, and it comes back each visit until it's caught, so the battle only hides it for this visit.
VerityCavern_RemoveMesprit:
    RemoveObject LOCALID_MESPRIT
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    End

VerityCavern_Mesprit:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    PlayCry SPECIES_MESPRIT
    Message VerityCavern_Text_MespritCry
    CloseMessage
    SetFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    StartLegendaryBattle SPECIES_MESPRIT, 60
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, VerityCavern_LostBattle
    CheckDidNotCapture VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, VerityCavern_MespritDisappeared
    SetFlag FLAG_HIDE_VERITY_CAVERN_MESPRIT
    ReleaseAll
    End

VerityCavern_MespritDisappeared:
    Message VerityCavern_Text_SovereignMespritDisappeared
    WaitButton
    CloseMessage
    ReleaseAll
    End

VerityCavern_LostBattle:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
