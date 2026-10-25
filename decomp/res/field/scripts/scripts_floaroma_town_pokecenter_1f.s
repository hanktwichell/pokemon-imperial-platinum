#include "macros/scrcmd.inc"
#include "res/text/bank/floaroma_town_pokecenter_1f.h"
#include "res/field/events/events_floaroma_town_pokecenter_1f.h"


    ScriptEntry FloaromaTownPokecenter1F_Nurse
    ScriptEntry FloaromaTownPokecenter1F_PokefanM
    ScriptEntry FloaromaTownPokecenter1F_BattleGirl
    ScriptEntry FloaromaTownPokecenter1F_AceTrainerF
    ScriptEntry FloaromaTownPokecenter1F_SovereignInterviewer
    ScriptEntry FloaromaTownPokecenter1F_SovereignCameraman
    ScriptEntryEnd

FloaromaTownPokecenter1F_Nurse:
    Common_CallPokecenterNurse LOCALID_FLOAROMA_NURSE
    End

FloaromaTownPokecenter1F_PokefanM:
    NPCMessage FloaromaTownPokecenter1F_Text_WithPokemonSafeToTravelAlone
    End

FloaromaTownPokecenter1F_BattleGirl:
    NPCMessage FloaromaTownPokecenter1F_Text_MyPokemonsHPGotLow
    End

FloaromaTownPokecenter1F_AceTrainerF:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfGe VAR_VALLEY_WINDWORKS_TEAM_GALACTIC_STATE, 2, FloaromaTownPokecenter1F_LongWayToEternaCity
    Message FloaromaTownPokecenter1F_Text_ProblemsWithElectricPower
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownPokecenter1F_LongWayToEternaCity:
    Message FloaromaTownPokecenter1F_Text_LongWayToEternaCity
    WaitButton
    CloseMessage
    ReleaseAll
    End

    

@ Sovereign (E10, Renegade): Jubilife TV's quiz. Right answers and a win over the reporter's team earn that team:
@ Chikorita, Cyndaquil and Totodile, Lv. 15. The trainer flag records the win. The prize needs room for all
@ three, and the reporter and cameraman leave once it's given.
FloaromaTownPokecenter1F_SovereignInterviewer:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    GoToIfDefeated TRAINER_SOVEREIGN_INTERVIEWER_JOHTO, FloaromaTownPokecenter1F_SovereignInterviewerPrize
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, FloaromaTownPokecenter1F_SovereignInterviewerDeclined
    PlayFanfare SEQ_SLOT_ATARI_sseq
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerRollCamera
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerQuestion1
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, FloaromaTownPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerQuestion2
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, FloaromaTownPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerQuestion3
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, FloaromaTownPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    PlayFanfare SEQ_SLOT_OOATARI_sseq
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerLetsFind
    WaitFanfare
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_INTERVIEWER_JOHTO
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, FloaromaTownPokecenter1F_SovereignInterviewerLost
    SetTrainerFlag TRAINER_SOVEREIGN_INTERVIEWER_JOHTO
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerWon
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownPokecenter1F_SovereignInterviewerLost:
    BlackOutFromBattle
    ReleaseAll
    End

FloaromaTownPokecenter1F_SovereignInterviewerWrong:
    WaitFanfare
    PlaySE SEQ_SE_DP_BOX03_sseq
    WaitSE SEQ_SE_DP_BOX03_sseq
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerWrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownPokecenter1F_SovereignInterviewerDeclined:
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerDeclined
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownPokecenter1F_SovereignInterviewerPrize:
    GetPartyCount VAR_RESULT
    GoToIfGt VAR_RESULT, 3, FloaromaTownPokecenter1F_SovereignInterviewerNoRoom
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerPrizeIntro
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerName1
    PlayFanfare SEQ_FANFA4_sseq
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerReceived1
    WaitFanfare
    GivePokemon SPECIES_CHIKORITA, 15, ITEM_MIRACLE_SEED, VAR_RESULT
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerNickname1
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, FloaromaTownPokecenter1F_SovereignInterviewerNickname
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerName2
    PlayFanfare SEQ_FANFA4_sseq
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerReceived2
    WaitFanfare
    GivePokemon SPECIES_CYNDAQUIL, 15, ITEM_CHARCOAL, VAR_RESULT
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerNickname2
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, FloaromaTownPokecenter1F_SovereignInterviewerNickname
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerName3
    PlayFanfare SEQ_FANFA4_sseq
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerReceived3
    WaitFanfare
    GivePokemon SPECIES_TOTODILE, 15, ITEM_MYSTIC_WATER, VAR_RESULT
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerNickname3
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, FloaromaTownPokecenter1F_SovereignInterviewerNickname
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerBye
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SetFlag FLAG_SOVEREIGN_INTERVIEWER_JOHTO_DONE
    RemoveObject LOCALID_FLOAROMA_SOVEREIGN_INTERVIEWER
    RemoveObject LOCALID_FLOAROMA_SOVEREIGN_CAMERAMAN
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

FloaromaTownPokecenter1F_SovereignInterviewerNoRoom:
    Message FloaromaTownPokecenter1F_Text_SovereignInterviewerNoRoom
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownPokecenter1F_SovereignInterviewerNickname:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, FloaromaTownPokecenter1F_SovereignInterviewerNicknamed
    FadeScreenIn
    WaitFadeScreen
    Return

FloaromaTownPokecenter1F_SovereignInterviewerNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

FloaromaTownPokecenter1F_SovereignCameraman:
    NPCMessage FloaromaTownPokecenter1F_Text_SovereignInterviewerCameraman
    End

    .balign 4, 0
