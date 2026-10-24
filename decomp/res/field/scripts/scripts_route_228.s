#include "macros/scrcmd.inc"
#include "res/text/bank/route_228.h"
#include "res/field/events/events_route_228.h"


    ScriptEntry Route228_ArrowSignpostRt226
    ScriptEntry Route228_ArrowSignpostRt229
    ScriptEntry Route228_OnTransition
    ScriptEntry Route228_OnLoad
    ScriptEntry Route228_SovereignShade
    ScriptEntry Route228_LegendaryLandorus
    ScriptEntryEnd

Route228_OnTransition:
    Call Route228_SovereignSetLandorusVisibility
    CallIfNe VAR_ROCK_PEAK_RUINS_STATE, RUINS_STATE_CAUGHT_REGI, Route228_ResetRockPeakRuinsState
    CheckPartyHasFatefulEncounterRegigigas VAR_MAP_LOCAL_0x01
    GoToIfEq VAR_MAP_LOCAL_0x01, FALSE, Route228_RemoveWarpRockPeakRuinsWithRegirock
    GoToIfEq VAR_MAP_LOCAL_0x01, TRUE, Route228_RemoveWarpRockPeakRuinsWithoutRegirock
    End

Route228_ResetRockPeakRuinsState:
    SetVar VAR_ROCK_PEAK_RUINS_STATE, 0
    Return

Route228_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route228_RemoveLegendaryLandorus
    CheckPartyHasFatefulEncounterRegigigas VAR_MAP_LOCAL_0x01
    GoToIfEq VAR_MAP_LOCAL_0x01, FALSE, Route228_RemoveWarpRockPeakRuinsWithRegirock
    GoToIfEq VAR_MAP_LOCAL_0x01, TRUE, Route228_RemoveWarpRockPeakRuinsWithoutRegirock
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Landorus waits at the north end of the first sand field
@ when the player brings Tornadus and Thundurus along, until it's caught. It moved here from the Rock Peak Ruins
@ doorway room (owner, 2026-10-24).
Route228_SovereignSetLandorusVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_LANDORUS, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route228_SovereignSetLandorusVisibilityEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_TORNADUS
    GoToIfEq VAR_RESULT, FALSE, Route228_SovereignSetLandorusVisibilityEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_THUNDURUS
    GoToIfEq VAR_RESULT, FALSE, Route228_SovereignSetLandorusVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route228_SovereignSetLandorusVisibilityEnd:
    Return

Route228_RemoveLegendaryLandorus:
    RemoveObject LOCALID_LEGENDARY_LANDORUS
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    Return

Route228_LegendaryLandorus:
    SetVar VAR_0x8004, SPECIES_LANDORUS
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

Route228_RemoveWarpRockPeakRuinsWithRegirock:
    SetWarpEventPos 5, 783, 339
    End

Route228_RemoveWarpRockPeakRuinsWithoutRegirock:
    SetWarpEventPos 4, 783, 339
    End

Route228_ArrowSignpostRt226:
    ShowArrowSign Route228_Text_SignRt226
    End

Route228_ArrowSignpostRt229:
    ShowArrowSign Route228_Text_SignRt229
    End

    

@ Sovereign (E10, Renegade's Battle Zone): Shade gives the unofficial Shadow Badge (just a keepsake, no item) to a player
@ who beats their team (Renegade's trainer 1026).
Route228_SovereignShade:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_BATTLE_ZONE_SHADE, Route228_SovereignShadeThanks
    Message Route228_Text_SovereignShadeIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route228_SovereignShadeDecline
    Message Route228_Text_SovereignShadeBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_BATTLE_ZONE_SHADE
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route228_SovereignShadeLost
    Message Route228_Text_SovereignShadeReward
    BufferPlayerName 0
    Message Route228_Text_SovereignShadeReceived
    PlayFanfare SEQ_BADGE_sseq
    WaitFanfare
    Message Route228_Text_SovereignShadeExplain
    WaitButton
    CloseMessage
    SetTrainerFlag TRAINER_SOVEREIGN_BATTLE_ZONE_SHADE
    ReleaseAll
    End

Route228_SovereignShadeThanks:
    Message Route228_Text_SovereignShadeThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route228_SovereignShadeDecline:
    CloseMessage
    ReleaseAll
    End

Route228_SovereignShadeLost:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
