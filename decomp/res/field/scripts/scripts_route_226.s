#include "macros/scrcmd.inc"
#include "res/text/bank/route_226.h"
#include "res/field/events/events_route_226.h"


    ScriptEntry Route226_ArrowSignpostSurvivalArea
    ScriptEntry Route226_ArrowSignpostRt227Rt228
    ScriptEntry Route226_OnTransition
    ScriptEntry Route226_OnLoad
    ScriptEntry Route226_LegendaryTapuFini
    ScriptEntry Route226_SovereignFireMaster
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Tapu Fini stands on the little beach under the cliffs, out
@ at sea, once the Alola Chronicle is open (VAR_SOVEREIGN_CHRONICLE 3), until it's caught.
Route226_OnTransition:
    Call Route226_SovereignSetTapuFiniVisibility
    End

Route226_SovereignSetTapuFiniVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, Route226_SovereignSetTapuFiniVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_TAPU_FINI, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route226_SovereignSetTapuFiniVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route226_SovereignSetTapuFiniVisibilityEnd:
    Return

Route226_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route226_RemoveLegendaryTapuFini
    End

Route226_RemoveLegendaryTapuFini:
    RemoveObject LOCALID_LEGENDARY_TAPU_FINI
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route226_LegendaryTapuFini:
    SetVar VAR_0x8004, SPECIES_TAPU_FINI
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

Route226_ArrowSignpostSurvivalArea:
    ShowArrowSign Route226_Text_SignSurvivalArea
    End

Route226_ArrowSignpostRt227Rt228:
    ShowArrowSign Route226_Text_SignRt227Rt228
    End

@ Sovereign (E10, Renegade's Type Masters): the Fire-type Master battles one Fire-type Pokémon, alone in the party, for
@ the Flame Plate (Renegade's trainer 1044).
Route226_SovereignFireMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_FIRE_MASTER, Route226_SovereignFireMasterThanks
    Message Route226_Text_SovereignFireMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, Route226_SovereignFireMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_FIRE, Route226_SovereignFireMasterAsk
    GoToIfEq VAR_0x8005, TYPE_FIRE, Route226_SovereignFireMasterAsk
Route226_SovereignFireMasterOnlyOne:
    Message Route226_Text_SovereignFireMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route226_SovereignFireMasterAsk:
    Message Route226_Text_SovereignFireMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route226_SovereignFireMasterDecline
    Message Route226_Text_SovereignFireMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_FIRE_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route226_SovereignFireMasterLost
    Message Route226_Text_SovereignFireMasterWin
    SetVar VAR_0x8004, ITEM_FLAME_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_FIRE_MASTER
Route226_SovereignFireMasterThanks:
    Message Route226_Text_SovereignFireMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route226_SovereignFireMasterDecline:
    Message Route226_Text_SovereignFireMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route226_SovereignFireMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message Route226_Text_SovereignFireMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
