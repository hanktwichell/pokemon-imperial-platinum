#include "macros/scrcmd.inc"
#include "res/text/bank/solaceon_ruins_room_1.h"
#include "res/field/events/events_solaceon_ruins_room_1.h"


    ScriptEntry SolaceonRuinsRoom1_OnTransition
    ScriptEntry SolaceonRuinsRoom1_Inscription
    ScriptEntry SolaceonRuinsRoom1_SovereignPsychicMaster
    ScriptEntryEnd

SolaceonRuinsRoom1_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_SOLACEON_RUINS
    End

SolaceonRuinsRoom1_Inscription:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    MessageUnown SolaceonRuinsRoom1_Text_Directions
    WaitButton
    CloseMessage
    ReleaseAll
    End

    

@ Sovereign (E10, Renegade's Type Masters): the Psychic-type Master battles one Psychic-type Pokémon, alone in the party, for
@ the Mind Plate (Renegade's trainer 1048).
SolaceonRuinsRoom1_SovereignPsychicMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_PSYCHIC_MASTER, SolaceonRuinsRoom1_SovereignPsychicMasterThanks
    Message SolaceonRuinsRoom1_Text_SovereignPsychicMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, SolaceonRuinsRoom1_SovereignPsychicMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_PSYCHIC, SolaceonRuinsRoom1_SovereignPsychicMasterAsk
    GoToIfEq VAR_0x8005, TYPE_PSYCHIC, SolaceonRuinsRoom1_SovereignPsychicMasterAsk
SolaceonRuinsRoom1_SovereignPsychicMasterOnlyOne:
    Message SolaceonRuinsRoom1_Text_SovereignPsychicMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonRuinsRoom1_SovereignPsychicMasterAsk:
    Message SolaceonRuinsRoom1_Text_SovereignPsychicMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, SolaceonRuinsRoom1_SovereignPsychicMasterDecline
    Message SolaceonRuinsRoom1_Text_SovereignPsychicMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_PSYCHIC_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SolaceonRuinsRoom1_SovereignPsychicMasterLost
    Message SolaceonRuinsRoom1_Text_SovereignPsychicMasterWin
    SetVar VAR_0x8004, ITEM_MIND_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_PSYCHIC_MASTER
SolaceonRuinsRoom1_SovereignPsychicMasterThanks:
    Message SolaceonRuinsRoom1_Text_SovereignPsychicMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonRuinsRoom1_SovereignPsychicMasterDecline:
    Message SolaceonRuinsRoom1_Text_SovereignPsychicMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonRuinsRoom1_SovereignPsychicMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message SolaceonRuinsRoom1_Text_SovereignPsychicMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
