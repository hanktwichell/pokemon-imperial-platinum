#include "macros/scrcmd.inc"
#include "res/text/bank/pastoria_city_observatory_gate_2f.h"
#include "res/field/events/events_pastoria_city_observatory_gate_2f.h"


    ScriptEntry PastoriaCityObservatoryGate2F_Binocular
    ScriptEntry PastoriaCityObservatoryGate2F_AceTrainerF
    ScriptEntry PastoriaCityObservatoryGate2F_BugCatcher
    ScriptEntry PastoriaCityObservatoryGate2F_PokefanM
    ScriptEntry PastoriaCityObservatoryGate2F_Picnicker
    ScriptEntry PastoriaCityObservatoryGate2F_SovereignPoisonMaster
    ScriptEntryEnd

PastoriaCityObservatoryGate2F_Binocular:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    ShowMoney 20, 2
    Message PastoriaCityObservatoryGate2F_Text_AskPut100InBinoculars
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    GoToIfEq VAR_RESULT, MENU_YES, PastoriaCityObservatoryGate2F_TryUseBinoculars
    HideMoney
    ReleaseAll
    End

PastoriaCityObservatoryGate2F_TryUseBinoculars:
    GoToIfNotEnoughMoney 100, PastoriaCityObservatoryGate2F_NotEnoughMoney
    RemoveMoney 100
    UpdateMoneyDisplay
    PlaySE SEQ_SE_DP_REGI_sseq
    WaitSE SEQ_SE_DP_REGI_sseq
    HideMoney
    StartGreatMarshLookout
    ReleaseAll
    End

PastoriaCityObservatoryGate2F_NotEnoughMoney:
    Message PastoriaCityObservatoryGate2F_Text_NotEnoughMoney
    WaitButton
    CloseMessage
    HideMoney
    ReleaseAll
    End

PastoriaCityObservatoryGate2F_AceTrainerF:
    NPCMessage PastoriaCityObservatoryGate2F_Text_PokemonDifferFromYesterday
    End

PastoriaCityObservatoryGate2F_BugCatcher:
    NPCMessage PastoriaCityObservatoryGate2F_Text_YouCanSeePokemon
    End

PastoriaCityObservatoryGate2F_PokefanM:
    NPCMessage PastoriaCityObservatoryGate2F_Text_TakeQuickTrams
    End

PastoriaCityObservatoryGate2F_Picnicker:
    NPCMessage PastoriaCityObservatoryGate2F_Text_YouCanSinkInBog
    End

@ Sovereign (E10, Renegade's Type Masters): the Poison-type Master battles one Poison-type Pokémon, alone in the party, for
@ the Toxic Plate (Renegade's trainer 1040).
PastoriaCityObservatoryGate2F_SovereignPoisonMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_POISON_MASTER, PastoriaCityObservatoryGate2F_SovereignPoisonMasterThanks
    Message PastoriaCityObservatoryGate2F_Text_SovereignPoisonMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, PastoriaCityObservatoryGate2F_SovereignPoisonMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_POISON, PastoriaCityObservatoryGate2F_SovereignPoisonMasterAsk
    GoToIfEq VAR_0x8005, TYPE_POISON, PastoriaCityObservatoryGate2F_SovereignPoisonMasterAsk
PastoriaCityObservatoryGate2F_SovereignPoisonMasterOnlyOne:
    Message PastoriaCityObservatoryGate2F_Text_SovereignPoisonMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

PastoriaCityObservatoryGate2F_SovereignPoisonMasterAsk:
    Message PastoriaCityObservatoryGate2F_Text_SovereignPoisonMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, PastoriaCityObservatoryGate2F_SovereignPoisonMasterDecline
    Message PastoriaCityObservatoryGate2F_Text_SovereignPoisonMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_POISON_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PastoriaCityObservatoryGate2F_SovereignPoisonMasterLost
    Message PastoriaCityObservatoryGate2F_Text_SovereignPoisonMasterWin
    SetVar VAR_0x8004, ITEM_TOXIC_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_POISON_MASTER
PastoriaCityObservatoryGate2F_SovereignPoisonMasterThanks:
    Message PastoriaCityObservatoryGate2F_Text_SovereignPoisonMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

PastoriaCityObservatoryGate2F_SovereignPoisonMasterDecline:
    Message PastoriaCityObservatoryGate2F_Text_SovereignPoisonMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

PastoriaCityObservatoryGate2F_SovereignPoisonMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message PastoriaCityObservatoryGate2F_Text_SovereignPoisonMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
