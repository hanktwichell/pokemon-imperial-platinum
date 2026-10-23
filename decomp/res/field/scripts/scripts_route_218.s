#include "macros/scrcmd.inc"
#include "res/text/bank/route_218.h"


    ScriptEntry Route218_ArrowSignpostCanalaveCity
    ScriptEntry Route218_ArrowSignpostJubilifeCity
    ScriptEntry Route218_Guitarist
    ScriptEntry Route218_Fisherman
    ScriptEntry Route218_ClefairySouth
    ScriptEntry Route218_ClefairyNorth
    ScriptEntry Route218_Pikachu
    ScriptEntry Route218_OnTransition
    ScriptEntryEnd

@ Sovereign (decision 23): the blockade stays until Totem Salazzle's trial is done (it used to leave once Cyrus was
@ beaten at Celestic Town), so Canalave and the lakes' Saturn and Mars wait on it.
Route218_OnTransition:
    GoToIfUnset FLAG_SOVEREIGN_TOTEM_TRIAL_SALAZZLE, Route218_OnTransitionEnd
    SetFlag FLAG_HIDE_ROUTE_218_BLOCKADE
Route218_OnTransitionEnd:
    End

Route218_ArrowSignpostCanalaveCity:
    ShowArrowSign Route218_Text_SignCanalaveCity
    End

Route218_ArrowSignpostJubilifeCity:
    ShowArrowSign Route218_Text_SignJubilifeCity
    End

Route218_Guitarist:
    GoToIfGe VAR_CELESTIC_TOWN_STATE, 1, Route218_GuitaristSalazzle
    EventMessage Route218_Text_ClefairyCuterNow
    End

Route218_GuitaristSalazzle:
    EventMessage Route218_Text_SovereignSalazzleChasedUsOut
    End

Route218_Fisherman:
    EventMessage Route218_Text_PikachuDazzle
    End

Route218_ClefairySouth:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    WaitSE SE_CONFIRM_sseq_3
    PlayCry SPECIES_CLEFAIRY
    Message Route218_Text_ClefairyCryPippiih
    WaitCry
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route218_ClefairyNorth:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    WaitSE SE_CONFIRM_sseq_3
    PlayCry SPECIES_CLEFAIRY
    Message Route218_Text_ClefairyCryPippippiih
    WaitCry
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route218_Pikachu:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    WaitSE SE_CONFIRM_sseq_3
    PlayCry SPECIES_PIKACHU
    Message Route218_Text_PikachuCry
    WaitCry
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
