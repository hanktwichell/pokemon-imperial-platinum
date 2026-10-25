#include "macros/scrcmd.inc"
#include "res/text/bank/hearthome_city_pokecenter_1f.h"
#include "res/field/events/events_hearthome_city_pokecenter_1f.h"


    ScriptEntry HearthomeCityPokecenter1F_Nurse
    ScriptEntry HearthomeCityPokecenter1F_Youngster
    ScriptEntry HearthomeCityPokecenter1F_Socialite
    ScriptEntry HearthomeCityPokecenter1F_Guitarist
    ScriptEntry HearthomeCityPokecenter1F_SovereignInterviewer
    ScriptEntry HearthomeCityPokecenter1F_SovereignCameraman
    ScriptEntryEnd

HearthomeCityPokecenter1F_Nurse:
    Common_CallPokecenterNurse LOCALID_HEARTHOME_NURSE
    End

HearthomeCityPokecenter1F_Youngster:
    NPCMessage HearthomeCityPokecenter1F_Text_HaveYouCheckedGlobalTerminal
    End

HearthomeCityPokecenter1F_Socialite:
    NPCMessage HearthomeCityPokecenter1F_Text_DoYouHaveAPoffinCase
    End

HearthomeCityPokecenter1F_Guitarist:
    NPCMessage HearthomeCityPokecenter1F_Text_FantinaLikesContestsToo
    End

    

@ Sovereign (E10, Renegade): Jubilife TV's quiz. Right answers and a win over the reporter's team earn that team:
@ Chespin, Fennekin and Froakie, Lv. 25. The trainer flag records the win. The prize needs room for all
@ three, and the reporter and cameraman leave once it's given.
HearthomeCityPokecenter1F_SovereignInterviewer:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    GoToIfDefeated TRAINER_SOVEREIGN_INTERVIEWER_KALOS, HearthomeCityPokecenter1F_SovereignInterviewerPrize
    CheckBadgeAcquired BADGE_ID_RELIC, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, HearthomeCityPokecenter1F_SovereignInterviewerNotYet
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, HearthomeCityPokecenter1F_SovereignInterviewerDeclined
    PlayFanfare SEQ_SLOT_ATARI_sseq
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerRollCamera
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerQuestion1
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, HearthomeCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerQuestion2
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, HearthomeCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerQuestion3
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, HearthomeCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    PlayFanfare SEQ_SLOT_OOATARI_sseq
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerQuestion4
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, HearthomeCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerQuestion5
    ShowYesNoMenu VAR_RESULT
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerLetsFind
    WaitFanfare
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_INTERVIEWER_KALOS
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, HearthomeCityPokecenter1F_SovereignInterviewerLost
    SetTrainerFlag TRAINER_SOVEREIGN_INTERVIEWER_KALOS
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerWon
    WaitButton
    CloseMessage
    ReleaseAll
    End

HearthomeCityPokecenter1F_SovereignInterviewerLost:
    BlackOutFromBattle
    ReleaseAll
    End

HearthomeCityPokecenter1F_SovereignInterviewerWrong:
    WaitFanfare
    PlaySE SEQ_SE_DP_BOX03_sseq
    WaitSE SEQ_SE_DP_BOX03_sseq
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerWrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

HearthomeCityPokecenter1F_SovereignInterviewerDeclined:
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerDeclined
    WaitButton
    CloseMessage
    ReleaseAll
    End

HearthomeCityPokecenter1F_SovereignInterviewerNotYet:
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerNotYet
    WaitButton
    CloseMessage
    ReleaseAll
    End

HearthomeCityPokecenter1F_SovereignInterviewerPrize:
    GetPartyCount VAR_RESULT
    GoToIfGt VAR_RESULT, 3, HearthomeCityPokecenter1F_SovereignInterviewerNoRoom
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerPrizeIntro
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerName1
    PlayFanfare SEQ_FANFA4_sseq
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerReceived1
    WaitFanfare
    GivePokemon SPECIES_CHESPIN, 25, ITEM_MIRACLE_SEED, VAR_RESULT
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerNickname1
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, HearthomeCityPokecenter1F_SovereignInterviewerNickname
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerName2
    PlayFanfare SEQ_FANFA4_sseq
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerReceived2
    WaitFanfare
    GivePokemon SPECIES_FENNEKIN, 25, ITEM_CHARCOAL, VAR_RESULT
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerNickname2
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, HearthomeCityPokecenter1F_SovereignInterviewerNickname
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerName3
    PlayFanfare SEQ_FANFA4_sseq
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerReceived3
    WaitFanfare
    GivePokemon SPECIES_FROAKIE, 25, ITEM_MYSTIC_WATER, VAR_RESULT
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerNickname3
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, HearthomeCityPokecenter1F_SovereignInterviewerNickname
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerBye
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SetFlag FLAG_SOVEREIGN_INTERVIEWER_KALOS_DONE
    RemoveObject LOCALID_HEARTHOME_SOVEREIGN_INTERVIEWER
    RemoveObject LOCALID_HEARTHOME_SOVEREIGN_CAMERAMAN
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

HearthomeCityPokecenter1F_SovereignInterviewerNoRoom:
    Message HearthomeCityPokecenter1F_Text_SovereignInterviewerNoRoom
    WaitButton
    CloseMessage
    ReleaseAll
    End

HearthomeCityPokecenter1F_SovereignInterviewerNickname:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, HearthomeCityPokecenter1F_SovereignInterviewerNicknamed
    FadeScreenIn
    WaitFadeScreen
    Return

HearthomeCityPokecenter1F_SovereignInterviewerNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

HearthomeCityPokecenter1F_SovereignCameraman:
    NPCMessage HearthomeCityPokecenter1F_Text_SovereignInterviewerCameraman
    End

    .balign 4, 0
