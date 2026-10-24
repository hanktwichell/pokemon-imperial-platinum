#include "macros/scrcmd.inc"
#include "res/text/bank/route_209_lost_tower_1f.h"
#include "res/field/events/events_route_209_lost_tower_1f.h"


    ScriptEntry Route209LostTower1F_OnTransition
    ScriptEntry Route209LostTower1F_PokemonBreederF1
    ScriptEntry Route209LostTower1F_PokemonBreederF2
    ScriptEntry Route209LostTower1F_SovereignScientistF
    ScriptEntry Route209LostTower1F_SovereignGhostMaster
    ScriptEntryEnd

Route209LostTower1F_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_LOST_TOWER
    End

Route209LostTower1F_PokemonBreederF1:
    NPCMessage Route209LostTower1F_Text_ThisIsWhereSpiritsRest
    End

Route209LostTower1F_PokemonBreederF2:
    NPCMessage Route209LostTower1F_Text_ThisIsTheLostTower
    End

    .balign 4, 0

// Sovereign (E10): Renegade's Reaper Cloth scientist.
Route209LostTower1F_SovereignScientistF:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_LOST_TOWER_REAPER_CLOTH, Route209LostTower1F_SovereignScientistFAgain
    Message Route209LostTower1F_Text_SovereignScientistFGives
    SetVar VAR_0x8004, ITEM_REAPER_CLOTH
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_LOST_TOWER_REAPER_CLOTH
    Message Route209LostTower1F_Text_SovereignScientistFExplains
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route209LostTower1F_SovereignScientistFAgain:
    Message Route209LostTower1F_Text_SovereignScientistFAgain
    WaitButton
    CloseMessage
    ReleaseAll
    End

@ Sovereign (E10, Renegade's Type Masters): the Ghost-type Master battles one Ghost-type Pokémon, alone in the party, for
@ the Spooky Plate (Renegade's trainer 1037).
Route209LostTower1F_SovereignGhostMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_GHOST_MASTER, Route209LostTower1F_SovereignGhostMasterThanks
    Message Route209LostTower1F_Text_SovereignGhostMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, Route209LostTower1F_SovereignGhostMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_GHOST, Route209LostTower1F_SovereignGhostMasterAsk
    GoToIfEq VAR_0x8005, TYPE_GHOST, Route209LostTower1F_SovereignGhostMasterAsk
Route209LostTower1F_SovereignGhostMasterOnlyOne:
    Message Route209LostTower1F_Text_SovereignGhostMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route209LostTower1F_SovereignGhostMasterAsk:
    Message Route209LostTower1F_Text_SovereignGhostMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route209LostTower1F_SovereignGhostMasterDecline
    Message Route209LostTower1F_Text_SovereignGhostMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GHOST_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route209LostTower1F_SovereignGhostMasterLost
    Message Route209LostTower1F_Text_SovereignGhostMasterWin
    SetVar VAR_0x8004, ITEM_SPOOKY_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_GHOST_MASTER
Route209LostTower1F_SovereignGhostMasterThanks:
    Message Route209LostTower1F_Text_SovereignGhostMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route209LostTower1F_SovereignGhostMasterDecline:
    Message Route209LostTower1F_Text_SovereignGhostMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route209LostTower1F_SovereignGhostMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message Route209LostTower1F_Text_SovereignGhostMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
