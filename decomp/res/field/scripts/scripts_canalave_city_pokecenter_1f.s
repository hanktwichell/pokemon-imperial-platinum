#include "macros/scrcmd.inc"
#include "res/text/bank/canalave_city_pokecenter_1f.h"
#include "res/field/events/events_canalave_city_pokecenter_1f.h"


    ScriptEntry CanalaveCityPokecenter1F_Nurse
    ScriptEntry CanalaveCityPokecenter1F_PokemonBreederF
    ScriptEntry CanalaveCityPokecenter1F_Lass
    ScriptEntry CanalaveCityPokecenter1F_ScientistM
    ScriptEntry CanalaveCityPokecenter1F_BugCatcher
    ScriptEntry CanalaveCityPokecenter1F_SovereignInterviewer
    ScriptEntry CanalaveCityPokecenter1F_SovereignCameraman
    ScriptEntryEnd

CanalaveCityPokecenter1F_Nurse:
    Common_CallPokecenterNurse LOCALID_CANALAVE_NURSE
    End

CanalaveCityPokecenter1F_PokemonBreederF:
    NPCMessage CanalaveCityPokecenter1F_Text_BoatToIronIsland
    End

CanalaveCityPokecenter1F_Lass:
    NPCMessage CanalaveCityPokecenter1F_Text_StrengthHMIronIsland
    End

CanalaveCityPokecenter1F_ScientistM:
    NPCMessage CanalaveCityPokecenter1F_Text_DifferentAbilities
    End

CanalaveCityPokecenter1F_BugCatcher:
    NPCMessage CanalaveCityPokecenter1F_Text_CoolRumor
    End

    

@ Sovereign (E10, Renegade): Jubilife TV's quiz. Right answers and a win over the reporter's team earn that team:
@ Sprigatito, Fuecoco and Quaxly, Lv. 40. The trainer flag records the win. The prize needs room for all
@ three, and the reporter and cameraman leave once it's given.
CanalaveCityPokecenter1F_SovereignInterviewer:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    GoToIfDefeated TRAINER_SOVEREIGN_INTERVIEWER_PALDEA, CanalaveCityPokecenter1F_SovereignInterviewerPrize
    CheckBadgeAcquired BADGE_ID_MINE, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, CanalaveCityPokecenter1F_SovereignInterviewerNotYet
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, CanalaveCityPokecenter1F_SovereignInterviewerDeclined
    PlayFanfare SEQ_SLOT_ATARI_sseq
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerRollCamera
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerQuestion1
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, CanalaveCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerQuestion2
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, CanalaveCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerQuestion3
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, CanalaveCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    PlayFanfare SEQ_SLOT_OOATARI_sseq
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerQuestion4
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, CanalaveCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerQuestion5
    ShowYesNoMenu VAR_RESULT
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerLetsFind
    WaitFanfare
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_INTERVIEWER_PALDEA
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, CanalaveCityPokecenter1F_SovereignInterviewerLost
    SetTrainerFlag TRAINER_SOVEREIGN_INTERVIEWER_PALDEA
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerWon
    WaitButton
    CloseMessage
    ReleaseAll
    End

CanalaveCityPokecenter1F_SovereignInterviewerLost:
    BlackOutFromBattle
    ReleaseAll
    End

CanalaveCityPokecenter1F_SovereignInterviewerWrong:
    WaitFanfare
    PlaySE SEQ_SE_DP_BOX03_sseq
    WaitSE SEQ_SE_DP_BOX03_sseq
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerWrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

CanalaveCityPokecenter1F_SovereignInterviewerDeclined:
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerDeclined
    WaitButton
    CloseMessage
    ReleaseAll
    End

CanalaveCityPokecenter1F_SovereignInterviewerNotYet:
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerNotYet
    WaitButton
    CloseMessage
    ReleaseAll
    End

CanalaveCityPokecenter1F_SovereignInterviewerPrize:
    GetPartyCount VAR_RESULT
    GoToIfGt VAR_RESULT, 3, CanalaveCityPokecenter1F_SovereignInterviewerNoRoom
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerPrizeIntro
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerName1
    PlayFanfare SEQ_FANFA4_sseq
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerReceived1
    WaitFanfare
    GivePokemon SPECIES_SPRIGATITO, 40, ITEM_MIRACLE_SEED, VAR_RESULT
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerNickname1
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, CanalaveCityPokecenter1F_SovereignInterviewerNickname
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerName2
    PlayFanfare SEQ_FANFA4_sseq
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerReceived2
    WaitFanfare
    GivePokemon SPECIES_FUECOCO, 40, ITEM_CHARCOAL, VAR_RESULT
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerNickname2
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, CanalaveCityPokecenter1F_SovereignInterviewerNickname
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerName3
    PlayFanfare SEQ_FANFA4_sseq
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerReceived3
    WaitFanfare
    GivePokemon SPECIES_QUAXLY, 40, ITEM_MYSTIC_WATER, VAR_RESULT
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerNickname3
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, CanalaveCityPokecenter1F_SovereignInterviewerNickname
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerBye
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SetFlag FLAG_SOVEREIGN_INTERVIEWER_PALDEA_DONE
    RemoveObject LOCALID_CANALAVE_SOVEREIGN_INTERVIEWER
    RemoveObject LOCALID_CANALAVE_SOVEREIGN_CAMERAMAN
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

CanalaveCityPokecenter1F_SovereignInterviewerNoRoom:
    Message CanalaveCityPokecenter1F_Text_SovereignInterviewerNoRoom
    WaitButton
    CloseMessage
    ReleaseAll
    End

CanalaveCityPokecenter1F_SovereignInterviewerNickname:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, CanalaveCityPokecenter1F_SovereignInterviewerNicknamed
    FadeScreenIn
    WaitFadeScreen
    Return

CanalaveCityPokecenter1F_SovereignInterviewerNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

CanalaveCityPokecenter1F_SovereignCameraman:
    NPCMessage CanalaveCityPokecenter1F_Text_SovereignInterviewerCameraman
    End

    .balign 4, 0
