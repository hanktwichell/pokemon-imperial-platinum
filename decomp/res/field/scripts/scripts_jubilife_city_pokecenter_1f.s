#include "macros/scrcmd.inc"
#include "res/text/bank/jubilife_city_pokecenter_1f.h"
#include "res/field/events/events_jubilife_city_pokecenter_1f.h"


    ScriptEntry JubilifeCityPokecenter1F_Nurse
    ScriptEntry JubilifeCityPokecenter1F_Twin
    ScriptEntry JubilifeCityPokecenter1F_SchoolKidM
    ScriptEntry JubilifeCityPokecenter1F_TrainerF
    ScriptEntry JubilifeCityPokecenter1F_SovereignInterviewer
    ScriptEntry JubilifeCityPokecenter1F_SovereignCameraman
    ScriptEntryEnd

JubilifeCityPokecenter1F_Nurse:
    Common_CallPokecenterNurse LOCALID_JUBILIFE_NURSE
    End

JubilifeCityPokecenter1F_Twin:
    NPCMessage JubilifeCityPokecenter1F_Text_StrengthsAndWeaknesses
    End

JubilifeCityPokecenter1F_SchoolKidM:
    NPCMessage JubilifeCityPokecenter1F_Text_ChatAndTradeInUnionRoom
    End

JubilifeCityPokecenter1F_TrainerF:
    NPCMessage JubilifeCityPokecenter1F_Text_CanStillCatchWithSixPokemon
    End

    

@ Sovereign (E10, Renegade): Jubilife TV's quiz. Right answers and a win over the reporter's team earn that team:
@ Bulbasaur, Charmander and Squirtle, Lv. 5. The trainer flag records the win. The prize needs room for all
@ three, and the reporter and cameraman leave once it's given.
JubilifeCityPokecenter1F_SovereignInterviewer:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    GoToIfDefeated TRAINER_SOVEREIGN_INTERVIEWER_KANTO, JubilifeCityPokecenter1F_SovereignInterviewerPrize
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, JubilifeCityPokecenter1F_SovereignInterviewerDeclined
    PlayFanfare SEQ_SLOT_ATARI_sseq
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerRollCamera
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerQuestion1
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, JubilifeCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerQuestion2
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, JubilifeCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerQuestion3
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, JubilifeCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    PlayFanfare SEQ_SLOT_OOATARI_sseq
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerQuestion4
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, JubilifeCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerQuestion5
    ShowYesNoMenu VAR_RESULT
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerLetsFind
    WaitFanfare
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_INTERVIEWER_KANTO
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, JubilifeCityPokecenter1F_SovereignInterviewerLost
    SetTrainerFlag TRAINER_SOVEREIGN_INTERVIEWER_KANTO
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerWon
    WaitButton
    CloseMessage
    ReleaseAll
    End

JubilifeCityPokecenter1F_SovereignInterviewerLost:
    BlackOutFromBattle
    ReleaseAll
    End

JubilifeCityPokecenter1F_SovereignInterviewerWrong:
    WaitFanfare
    PlaySE SEQ_SE_DP_BOX03_sseq
    WaitSE SEQ_SE_DP_BOX03_sseq
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerWrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

JubilifeCityPokecenter1F_SovereignInterviewerDeclined:
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerDeclined
    WaitButton
    CloseMessage
    ReleaseAll
    End

JubilifeCityPokecenter1F_SovereignInterviewerPrize:
    GetPartyCount VAR_RESULT
    GoToIfGt VAR_RESULT, 3, JubilifeCityPokecenter1F_SovereignInterviewerNoRoom
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerPrizeIntro
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerName1
    PlayFanfare SEQ_FANFA4_sseq
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerReceived1
    WaitFanfare
    GivePokemon SPECIES_BULBASAUR, 5, ITEM_MIRACLE_SEED, VAR_RESULT
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerNickname1
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, JubilifeCityPokecenter1F_SovereignInterviewerNickname
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerName2
    PlayFanfare SEQ_FANFA4_sseq
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerReceived2
    WaitFanfare
    GivePokemon SPECIES_CHARMANDER, 5, ITEM_CHARCOAL, VAR_RESULT
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerNickname2
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, JubilifeCityPokecenter1F_SovereignInterviewerNickname
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerName3
    PlayFanfare SEQ_FANFA4_sseq
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerReceived3
    WaitFanfare
    GivePokemon SPECIES_SQUIRTLE, 5, ITEM_MYSTIC_WATER, VAR_RESULT
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerNickname3
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, JubilifeCityPokecenter1F_SovereignInterviewerNickname
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerBye
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SetFlag FLAG_SOVEREIGN_INTERVIEWER_KANTO_DONE
    RemoveObject LOCALID_JUBILIFE_SOVEREIGN_INTERVIEWER
    RemoveObject LOCALID_JUBILIFE_SOVEREIGN_CAMERAMAN
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

JubilifeCityPokecenter1F_SovereignInterviewerNoRoom:
    Message JubilifeCityPokecenter1F_Text_SovereignInterviewerNoRoom
    WaitButton
    CloseMessage
    ReleaseAll
    End

JubilifeCityPokecenter1F_SovereignInterviewerNickname:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, JubilifeCityPokecenter1F_SovereignInterviewerNicknamed
    FadeScreenIn
    WaitFadeScreen
    Return

JubilifeCityPokecenter1F_SovereignInterviewerNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

JubilifeCityPokecenter1F_SovereignCameraman:
    NPCMessage JubilifeCityPokecenter1F_Text_SovereignInterviewerCameraman
    End

    .balign 4, 0
