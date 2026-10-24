#include "macros/scrcmd.inc"
#include "res/text/bank/eterna_city_pokecenter_1f.h"
#include "res/field/events/events_eterna_city_pokecenter_1f.h"


    ScriptEntry EternaCityPokecenter1F_Nurse
    ScriptEntry EternaCityPokecenter1F_BattleGirl
    ScriptEntry EternaCityPokecenter1F_SchoolKidM
    ScriptEntry EternaCityPokecenter1F_Buneary
    ScriptEntry EternaCityPokecenter1F_PokemonBreederF
    ScriptEntry EternaCityPokecenter1F_SovereignIdol
    ScriptEntry EternaCityPokecenter1F_SovereignClefairy
    ScriptEntry EternaCityPokecenter1F_SovereignInterviewer
    ScriptEntry EternaCityPokecenter1F_SovereignCameraman
    ScriptEntryEnd

EternaCityPokecenter1F_Nurse:
    Common_CallPokecenterNurse LOCALID_ETERNA_NURSE
    End

EternaCityPokecenter1F_BattleGirl:
    NPCMessage EternaCityPokecenter1F_Text_FaintMeansNoPowerToBattle
    End

EternaCityPokecenter1F_SchoolKidM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_TEAM_GALACTIC_LEFT_ETERNA_BUILDING, EternaCityPokecenter1F_IGotMyPokemonBack
    Message EternaCityPokecenter1F_Text_TeamGalacticTookMyPokemon
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_IGotMyPokemonBack:
    Message EternaCityPokecenter1F_Text_IGotMyPokemonBack
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_Buneary:
    PokemonCryAndMessage SPECIES_BUNEARY, EternaCityPokecenter1F_Text_BunearyBunbun
    End

EternaCityPokecenter1F_PokemonBreederF:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfEq VAR_MAP_LOCAL_0x02, 1, EternaCityPokecenter1F_PokemonWillOpenUp
    CheckPoketchAppRegistered POKETCH_APPID_FRIENDSHIPCHECKER, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, EternaCityPokecenter1F_GivePoketchAppFriendshipChecker
    GetFirstNonEggInParty VAR_0x8000
    BufferPartyMonSpecies 0, VAR_0x8000
    Message EternaCityPokecenter1F_Text_OhYourPokemon
    GetPartyMonFriendship VAR_RESULT, VAR_0x8000
    GoToIfGe VAR_RESULT, 120, EternaCityPokecenter1F_ItSeemsToLikeYou
    GoToIfGe VAR_RESULT, 70, EternaCityPokecenter1F_ItsBecomingComfortable
    GoTo EternaCityPokecenter1F_NeedsToGetUsedToYou
    End

EternaCityPokecenter1F_GivePoketchAppFriendshipChecker:
    Message EternaCityPokecenter1F_Text_ShowHowClosePokemonFeel
    SetVar VAR_MAP_LOCAL_0x02, 1
    SetVar VAR_0x8004, POKETCH_APPID_FRIENDSHIPCHECKER
    Common_GivePoketchApp
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_PokemonWillOpenUp:
    Message EternaCityPokecenter1F_Text_PokemonWillOpenUp
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_ItSeemsToLikeYou:
    Message EternaCityPokecenter1F_Text_ItSeemsToLikeYou
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_ItsBecomingComfortable:
    Message EternaCityPokecenter1F_Text_ItsBecomingComfortable
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_NeedsToGetUsedToYou:
    Message EternaCityPokecenter1F_Text_NeedsToGetUsedToYou
    WaitButton
    CloseMessage
    ReleaseAll
    End

@ Sovereign (E10, Renegade's Jirachi event): the first of three wishes. The Idol wants her Clefairy to learn Dazzling
@ Gleam (TM85, Mira's gift in Wayward Cave). Granting it is seen by Jirachi (docs/LegendaryTriggers.md).
EternaCityPokecenter1F_SovereignIdol:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_JIRACHI_WISH_ETERNA, EternaCityPokecenter1F_SovereignIdolThanks
    Message EternaCityPokecenter1F_Text_SovereignIdolWish
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, EternaCityPokecenter1F_SovereignIdolNoTM
    CheckItem ITEM_TM85, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, EternaCityPokecenter1F_SovereignIdolNoTM
    RemoveItem ITEM_TM85, 1, VAR_RESULT
    BufferPlayerName 0
    Message EternaCityPokecenter1F_Text_SovereignIdolBootedTM
    PlayFanfare SEQ_WAZA_sseq
    Message EternaCityPokecenter1F_Text_SovereignIdolClefairyLearned
    WaitFanfare
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_CLEFAIRY, EternaCityPokecenter1F_SovereignMovement_ClefairyJump
    WaitMovement
    PlayCry SPECIES_CLEFAIRY
    Message EternaCityPokecenter1F_Text_SovereignClefairyCry
    WaitCry
    CloseMessage
    Message EternaCityPokecenter1F_Text_SovereignIdolDreamRealized
    CloseMessage
    Call EternaCityPokecenter1F_SovereignWishGranted
    SetFlag FLAG_SOVEREIGN_JIRACHI_WISH_ETERNA
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignIdolThanks:
    Message EternaCityPokecenter1F_Text_SovereignIdolThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignIdolNoTM:
    Message EternaCityPokecenter1F_Text_SovereignIdolNoTM
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignClefairy:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    WaitSE SE_CONFIRM_sseq_3
    PlayCry SPECIES_CLEFAIRY
    Message EternaCityPokecenter1F_Text_SovereignClefairyCry
    WaitCry
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignWishGranted:
    WaitTime 10, VAR_RESULT
    FadeScreenOut FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    PlayCry SPECIES_JIRACHI
    WaitCry
    FadeScreenIn FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    Message EternaCityPokecenter1F_Text_SovereignWishSeen
    WaitButton
    CloseMessage
    Return

    .balign 4, 0
EternaCityPokecenter1F_SovereignMovement_ClefairyJump:
    JumpOnSpotFastWest 2
    EndMovement

    

@ Sovereign (E10, Renegade): Jubilife TV's quiz. Right answers and a win over the reporter's team earn that team:
@ Snivy, Tepig and Oshawott, Lv. 20. The trainer flag records the win. The prize needs room for all
@ three, and the reporter and cameraman leave once it's given.
EternaCityPokecenter1F_SovereignInterviewer:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    GoToIfDefeated TRAINER_SOVEREIGN_INTERVIEWER_UNOVA, EternaCityPokecenter1F_SovereignInterviewerPrize
    CheckBadgeAcquired BADGE_ID_FOREST, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, EternaCityPokecenter1F_SovereignInterviewerNotYet
    Message EternaCityPokecenter1F_Text_SovereignInterviewerIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, EternaCityPokecenter1F_SovereignInterviewerDeclined
    PlayFanfare SEQ_SLOT_ATARI_sseq
    Message EternaCityPokecenter1F_Text_SovereignInterviewerRollCamera
    Message EternaCityPokecenter1F_Text_SovereignInterviewerQuestion1
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, EternaCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message EternaCityPokecenter1F_Text_SovereignInterviewerQuestion2
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, EternaCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message EternaCityPokecenter1F_Text_SovereignInterviewerQuestion3
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, EternaCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    PlayFanfare SEQ_SLOT_OOATARI_sseq
    Message EternaCityPokecenter1F_Text_SovereignInterviewerQuestion4
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, EternaCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message EternaCityPokecenter1F_Text_SovereignInterviewerQuestion5
    ShowYesNoMenu VAR_RESULT
    Message EternaCityPokecenter1F_Text_SovereignInterviewerLetsFind
    WaitFanfare
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_INTERVIEWER_UNOVA
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, EternaCityPokecenter1F_SovereignInterviewerLost
    SetTrainerFlag TRAINER_SOVEREIGN_INTERVIEWER_UNOVA
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message EternaCityPokecenter1F_Text_SovereignInterviewerWon
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignInterviewerLost:
    BlackOutFromBattle
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignInterviewerWrong:
    WaitFanfare
    PlaySE SEQ_SE_DP_BOX03_sseq
    WaitSE SEQ_SE_DP_BOX03_sseq
    Message EternaCityPokecenter1F_Text_SovereignInterviewerWrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignInterviewerDeclined:
    Message EternaCityPokecenter1F_Text_SovereignInterviewerDeclined
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignInterviewerNotYet:
    Message EternaCityPokecenter1F_Text_SovereignInterviewerNotYet
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignInterviewerPrize:
    GetPartyCount VAR_RESULT
    GoToIfGt VAR_RESULT, 3, EternaCityPokecenter1F_SovereignInterviewerNoRoom
    Message EternaCityPokecenter1F_Text_SovereignInterviewerPrizeIntro
    Message EternaCityPokecenter1F_Text_SovereignInterviewerName1
    PlayFanfare SEQ_FANFA4_sseq
    Message EternaCityPokecenter1F_Text_SovereignInterviewerReceived1
    WaitFanfare
    GivePokemon SPECIES_SNIVY, 20, ITEM_MIRACLE_SEED, VAR_RESULT
    Message EternaCityPokecenter1F_Text_SovereignInterviewerNickname1
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, EternaCityPokecenter1F_SovereignInterviewerNickname
    Message EternaCityPokecenter1F_Text_SovereignInterviewerName2
    PlayFanfare SEQ_FANFA4_sseq
    Message EternaCityPokecenter1F_Text_SovereignInterviewerReceived2
    WaitFanfare
    GivePokemon SPECIES_TEPIG, 20, ITEM_CHARCOAL, VAR_RESULT
    Message EternaCityPokecenter1F_Text_SovereignInterviewerNickname2
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, EternaCityPokecenter1F_SovereignInterviewerNickname
    Message EternaCityPokecenter1F_Text_SovereignInterviewerName3
    PlayFanfare SEQ_FANFA4_sseq
    Message EternaCityPokecenter1F_Text_SovereignInterviewerReceived3
    WaitFanfare
    GivePokemon SPECIES_OSHAWOTT, 20, ITEM_MYSTIC_WATER, VAR_RESULT
    Message EternaCityPokecenter1F_Text_SovereignInterviewerNickname3
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, EternaCityPokecenter1F_SovereignInterviewerNickname
    Message EternaCityPokecenter1F_Text_SovereignInterviewerBye
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SetFlag FLAG_SOVEREIGN_INTERVIEWER_UNOVA_DONE
    RemoveObject LOCALID_ETERNA_SOVEREIGN_INTERVIEWER
    RemoveObject LOCALID_ETERNA_SOVEREIGN_CAMERAMAN
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignInterviewerNoRoom:
    Message EternaCityPokecenter1F_Text_SovereignInterviewerNoRoom
    WaitButton
    CloseMessage
    ReleaseAll
    End

EternaCityPokecenter1F_SovereignInterviewerNickname:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, EternaCityPokecenter1F_SovereignInterviewerNicknamed
    FadeScreenIn
    WaitFadeScreen
    Return

EternaCityPokecenter1F_SovereignInterviewerNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

EternaCityPokecenter1F_SovereignCameraman:
    NPCMessage EternaCityPokecenter1F_Text_SovereignInterviewerCameraman
    End

    .balign 4, 0
