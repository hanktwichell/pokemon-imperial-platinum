#include "macros/scrcmd.inc"
#include "res/text/bank/veilstone_city_pokecenter_1f.h"
#include "res/field/events/events_veilstone_city_pokecenter_1f.h"


    ScriptEntry VeilstoneCityPokecenter1F_Nurse
    ScriptEntry VeilstoneCityPokecenter1F_Socialite
    ScriptEntry VeilstoneCityPokecenter1F_SchoolKidM
    ScriptEntry VeilstoneCityPokecenter1F_SovereignDragonTamer
    ScriptEntry VeilstoneCityPokecenter1F_SovereignInterviewer
    ScriptEntry VeilstoneCityPokecenter1F_SovereignCameraman
    ScriptEntryEnd

VeilstoneCityPokecenter1F_Nurse:
    Common_CallPokecenterNurse LOCALID_VEILSTONE_NURSE
    End

VeilstoneCityPokecenter1F_Socialite:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferTMHMMoveName 0, ITEM_HM03
    Message VeilstoneCityPokecenter1F_Text_IfYouUseFly
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SchoolKidM:
    NPCMessage VeilstoneCityPokecenter1F_Text_MayleneIsCute
    End

    .balign 4, 0

// Sovereign (E10): Renegade's Dragon Tamer Nils battles for the Dragon Scale.
VeilstoneCityPokecenter1F_SovereignDragonTamer:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_VEILSTONE_DRAGON_SCALE, VeilstoneCityPokecenter1F_SovereignDragonsAlwaysStrong
    Message VeilstoneCityPokecenter1F_Text_SovereignDuelWithDragons
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, VeilstoneCityPokecenter1F_SovereignPerhapsYouThinkIllWin
    Message VeilstoneCityPokecenter1F_Text_SovereignDraconicForce
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_DRAGON_TAMER_VEILSTONE
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, VeilstoneCityPokecenter1F_SovereignLostDragonBattle
    Message VeilstoneCityPokecenter1F_Text_SovereignBequeathItem
    SetVar VAR_0x8004, ITEM_DRAGON_SCALE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_VEILSTONE_DRAGON_SCALE
    Message VeilstoneCityPokecenter1F_Text_SovereignDragonScaleExplains
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SovereignDragonsAlwaysStrong:
    Message VeilstoneCityPokecenter1F_Text_SovereignDragonsAlwaysStrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SovereignPerhapsYouThinkIllWin:
    Message VeilstoneCityPokecenter1F_Text_SovereignPerhapsYouThinkIllWin
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SovereignLostDragonBattle:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message VeilstoneCityPokecenter1F_Text_SovereignDragonsAlwaysStrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

@ Sovereign (E10, Renegade): Jubilife TV's quiz. Right answers and a win over the reporter's team earn that team:
@ Rowlet, Litten and Popplio, Lv. 30. The trainer flag records the win. The prize needs room for all
@ three, and the reporter and cameraman leave once it's given.
VeilstoneCityPokecenter1F_SovereignInterviewer:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    GoToIfDefeated TRAINER_SOVEREIGN_INTERVIEWER_ALOLA, VeilstoneCityPokecenter1F_SovereignInterviewerPrize
    CheckBadgeAcquired BADGE_ID_COBBLE, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, VeilstoneCityPokecenter1F_SovereignInterviewerNotYet
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, VeilstoneCityPokecenter1F_SovereignInterviewerDeclined
    PlayFanfare SEQ_SLOT_ATARI_sseq
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerRollCamera
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerQuestion1
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, VeilstoneCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerQuestion2
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, VeilstoneCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerQuestion3
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, VeilstoneCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    PlayFanfare SEQ_SLOT_OOATARI_sseq
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerQuestion4
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, VeilstoneCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerQuestion5
    ShowYesNoMenu VAR_RESULT
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerLetsFind
    WaitFanfare
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_INTERVIEWER_ALOLA
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, VeilstoneCityPokecenter1F_SovereignInterviewerLost
    SetTrainerFlag TRAINER_SOVEREIGN_INTERVIEWER_ALOLA
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerWon
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SovereignInterviewerLost:
    BlackOutFromBattle
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SovereignInterviewerWrong:
    WaitFanfare
    PlaySE SEQ_SE_DP_BOX03_sseq
    WaitSE SEQ_SE_DP_BOX03_sseq
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerWrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SovereignInterviewerDeclined:
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerDeclined
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SovereignInterviewerNotYet:
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerNotYet
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SovereignInterviewerPrize:
    GetPartyCount VAR_RESULT
    GoToIfGt VAR_RESULT, 3, VeilstoneCityPokecenter1F_SovereignInterviewerNoRoom
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerPrizeIntro
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerName1
    PlayFanfare SEQ_FANFA4_sseq
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerReceived1
    WaitFanfare
    GivePokemon SPECIES_ROWLET, 30, ITEM_MIRACLE_SEED, VAR_RESULT
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerNickname1
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, VeilstoneCityPokecenter1F_SovereignInterviewerNickname
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerName2
    PlayFanfare SEQ_FANFA4_sseq
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerReceived2
    WaitFanfare
    GivePokemon SPECIES_LITTEN, 30, ITEM_CHARCOAL, VAR_RESULT
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerNickname2
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, VeilstoneCityPokecenter1F_SovereignInterviewerNickname
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerName3
    PlayFanfare SEQ_FANFA4_sseq
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerReceived3
    WaitFanfare
    GivePokemon SPECIES_POPPLIO, 30, ITEM_MYSTIC_WATER, VAR_RESULT
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerNickname3
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, VeilstoneCityPokecenter1F_SovereignInterviewerNickname
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerBye
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SetFlag FLAG_SOVEREIGN_INTERVIEWER_ALOLA_DONE
    RemoveObject LOCALID_VEILSTONE_SOVEREIGN_INTERVIEWER
    RemoveObject LOCALID_VEILSTONE_SOVEREIGN_CAMERAMAN
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SovereignInterviewerNoRoom:
    Message VeilstoneCityPokecenter1F_Text_SovereignInterviewerNoRoom
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCityPokecenter1F_SovereignInterviewerNickname:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, VeilstoneCityPokecenter1F_SovereignInterviewerNicknamed
    FadeScreenIn
    WaitFadeScreen
    Return

VeilstoneCityPokecenter1F_SovereignInterviewerNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

VeilstoneCityPokecenter1F_SovereignCameraman:
    NPCMessage VeilstoneCityPokecenter1F_Text_SovereignInterviewerCameraman
    End

    .balign 4, 0
