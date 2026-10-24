#include "macros/scrcmd.inc"
#include "res/text/bank/pastoria_city_pokecenter_1f.h"
#include "res/field/events/events_pastoria_city_pokecenter_1f.h"


    ScriptEntry PastoriaCityPokecenter1F_Nurse
    ScriptEntry PastoriaCityPokecenter1F_BlackBelt
    ScriptEntry PastoriaCityPokecenter1F_SchoolKidF
    ScriptEntry PastoriaCityPokecenter1F_SovereignInterviewer
    ScriptEntry PastoriaCityPokecenter1F_SovereignCameraman
    ScriptEntryEnd

PastoriaCityPokecenter1F_Nurse:
    Common_CallPokecenterNurse LOCALID_PASTORIA_NURSE
    End

PastoriaCityPokecenter1F_BlackBelt:
    NPCMessage PastoriaCityPokecenter1F_Text_GreatMarshIsVast
    End

PastoriaCityPokecenter1F_SchoolKidF:
    NPCMessage PastoriaCityPokecenter1F_Text_GreatMarshWasSea
    End

@ Sovereign (E10, Renegade): Jubilife TV's quiz. Right answers and a win over the reporter's team earn that team:
@ Grookey, Scorbunny and Sobble, Lv. 35. The trainer flag records the win. The prize needs room for all
@ three, and the reporter and cameraman leave once it's given.
PastoriaCityPokecenter1F_SovereignInterviewer:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    GoToIfDefeated TRAINER_SOVEREIGN_INTERVIEWER_GALAR, PastoriaCityPokecenter1F_SovereignInterviewerPrize
    CheckBadgeAcquired BADGE_ID_FEN, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PastoriaCityPokecenter1F_SovereignInterviewerNotYet
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, PastoriaCityPokecenter1F_SovereignInterviewerDeclined
    PlayFanfare SEQ_SLOT_ATARI_sseq
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerRollCamera
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerQuestion1
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, PastoriaCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerQuestion2
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, PastoriaCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerQuestion3
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, PastoriaCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    PlayFanfare SEQ_SLOT_OOATARI_sseq
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerQuestion4
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, PastoriaCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerQuestion5
    ShowYesNoMenu VAR_RESULT
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerLetsFind
    WaitFanfare
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_INTERVIEWER_GALAR
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PastoriaCityPokecenter1F_SovereignInterviewerLost
    SetTrainerFlag TRAINER_SOVEREIGN_INTERVIEWER_GALAR
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerWon
    WaitButton
    CloseMessage
    ReleaseAll
    End

PastoriaCityPokecenter1F_SovereignInterviewerLost:
    BlackOutFromBattle
    ReleaseAll
    End

PastoriaCityPokecenter1F_SovereignInterviewerWrong:
    WaitFanfare
    PlaySE SEQ_SE_DP_BOX03_sseq
    WaitSE SEQ_SE_DP_BOX03_sseq
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerWrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

PastoriaCityPokecenter1F_SovereignInterviewerDeclined:
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerDeclined
    WaitButton
    CloseMessage
    ReleaseAll
    End

PastoriaCityPokecenter1F_SovereignInterviewerNotYet:
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerNotYet
    WaitButton
    CloseMessage
    ReleaseAll
    End

PastoriaCityPokecenter1F_SovereignInterviewerPrize:
    GetPartyCount VAR_RESULT
    GoToIfGt VAR_RESULT, 3, PastoriaCityPokecenter1F_SovereignInterviewerNoRoom
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerPrizeIntro
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerName1
    PlayFanfare SEQ_FANFA4_sseq
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerReceived1
    WaitFanfare
    GivePokemon SPECIES_GROOKEY, 35, ITEM_MIRACLE_SEED, VAR_RESULT
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerNickname1
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, PastoriaCityPokecenter1F_SovereignInterviewerNickname
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerName2
    PlayFanfare SEQ_FANFA4_sseq
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerReceived2
    WaitFanfare
    GivePokemon SPECIES_SCORBUNNY, 35, ITEM_CHARCOAL, VAR_RESULT
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerNickname2
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, PastoriaCityPokecenter1F_SovereignInterviewerNickname
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerName3
    PlayFanfare SEQ_FANFA4_sseq
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerReceived3
    WaitFanfare
    GivePokemon SPECIES_SOBBLE, 35, ITEM_MYSTIC_WATER, VAR_RESULT
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerNickname3
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, PastoriaCityPokecenter1F_SovereignInterviewerNickname
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerBye
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SetFlag FLAG_SOVEREIGN_INTERVIEWER_GALAR_DONE
    RemoveObject LOCALID_PASTORIA_SOVEREIGN_INTERVIEWER
    RemoveObject LOCALID_PASTORIA_SOVEREIGN_CAMERAMAN
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

PastoriaCityPokecenter1F_SovereignInterviewerNoRoom:
    Message PastoriaCityPokecenter1F_Text_SovereignInterviewerNoRoom
    WaitButton
    CloseMessage
    ReleaseAll
    End

PastoriaCityPokecenter1F_SovereignInterviewerNickname:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, PastoriaCityPokecenter1F_SovereignInterviewerNicknamed
    FadeScreenIn
    WaitFadeScreen
    Return

PastoriaCityPokecenter1F_SovereignInterviewerNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

PastoriaCityPokecenter1F_SovereignCameraman:
    NPCMessage PastoriaCityPokecenter1F_Text_SovereignInterviewerCameraman
    End

    .balign 4, 0
