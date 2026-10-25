#include "macros/scrcmd.inc"
#include "res/text/bank/menu_entries.h"
#include "res/text/bank/oreburgh_city_pokecenter_1f.h"
#include "res/field/events/events_oreburgh_city_pokecenter_1f.h"


    ScriptEntry OreburghCityPokecenter1F_Nurse
    ScriptEntry OreburghCityPokecenter1F_NinjaBoy
    ScriptEntry OreburghCityPokecenter1F_AceTrainerF
    ScriptEntry OreburghCityPokecenter1F_Psychic
    ScriptEntry OreburghCityPokecenter1F_Gentleman
    ScriptEntry OreburghCityPokecenter1F_KidWithNDSWest
    ScriptEntry OreburghCityPokecenter1F_KidWithNDSEast
    ScriptEntry OreburghCityPokecenter1F_SovereignInterviewer
    ScriptEntry OreburghCityPokecenter1F_SovereignCameraman
    ScriptEntryEnd

OreburghCityPokecenter1F_Nurse:
    Common_CallPokecenterNurse LOCALID_OREBURGH_NURSE
    End

OreburghCityPokecenter1F_NinjaBoy:
    NPCMessage OreburghCityPokecenter1F_Text_IGotAPalPadDownstairs
    End

OreburghCityPokecenter1F_AceTrainerF:
    NPCMessage OreburghCityPokecenter1F_Text_SwitchOnThePC
    End

OreburghCityPokecenter1F_Psychic:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_CHOSE_UNION_ROOM_APPEARANCE, OreburghCityPokecenter1F_WhatKindOfTrainerDoYouLike
    Message OreburghCityPokecenter1F_Text_TellMeFavoriteKindOfTrainer
    GoTo OreburghCityPokecenter1F_BeWhichKindOfTrainer

OreburghCityPokecenter1F_WhatKindOfTrainerDoYouLike:
    BufferTrainerClassFromAppearance 0
    Message OreburghCityPokecenter1F_Text_WhatKindOfTrainerDoYouLike
    GoTo OreburghCityPokecenter1F_BeWhichKindOfTrainer

OreburghCityPokecenter1F_BeWhichKindOfTrainer:
    Message OreburghCityPokecenter1F_Text_BeWhichKindOfTrainer
    LoadTrainerAppearances
    InitGlobalTextMenu 1, 1, 0, VAR_RESULT
    AddMenuEntryImm MenuEntries_Text_TrainerAppearanceVariant1, 0
    AddMenuEntryImm MenuEntries_Text_TrainerAppearanceVariant2, 1
    AddMenuEntryImm MenuEntries_Text_TrainerAppearanceVariant3, 2
    AddMenuEntryImm MenuEntries_Text_TrainerAppearanceVariant4, 3
    AddMenuEntryImm MenuEntries_Text_TrainerAppearancesExit, 4
    ShowMenu
    SetVar VAR_0x8004, VAR_RESULT
    SetVar VAR_0x8008, VAR_RESULT
    GoToIfEq VAR_0x8008, 4, OreburghCityPokecenter1F_IllJustTalkToYouLater
    GoToIfEq VAR_0x8008, -2, OreburghCityPokecenter1F_IllJustTalkToYouLater
    GetTrainerInfoTrainerClass VAR_0x8004, VAR_0x8005
    BufferTrainerClassNameWithArticle 0, VAR_0x8005
    CapitalizeFirstLetter 0
    Message OreburghCityPokecenter1F_Text_IsThisWhatYouWantToBe
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, OreburghCityPokecenter1F_SetTrainerClass
    GoTo OreburghCityPokecenter1F_BeWhichKindOfTrainer

OreburghCityPokecenter1F_IllJustTalkToYouLater:
    Message OreburghCityPokecenter1F_Text_IllJustTalkToYouLater
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghCityPokecenter1F_SetTrainerClass:
    BufferTrainerClassNameWithArticle 0, VAR_0x8005
    Message OreburghCityPokecenter1F_Text_SoThisIsWhatYouLike
    SetFlag FLAG_CHOSE_UNION_ROOM_APPEARANCE
    CalculateTrainerInfoAppearance VAR_0x8004, VAR_0x8005
    SetTrainerInfoAppearance VAR_0x8005
    GoTo OreburghCityPokecenter1F_IllJustTalkToYouLater

OreburghCityPokecenter1F_Gentleman:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_GAME_COMPLETED, OreburghCityPokecenter1F_WhatOrWhoIsTeamGalactic
    Message OreburghCityPokecenter1F_Text_TeamGalacticIsAMystery
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghCityPokecenter1F_WhatOrWhoIsTeamGalactic:
    Message OreburghCityPokecenter1F_Text_WhatOrWhoIsTeamGalactic
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghCityPokecenter1F_KidWithNDSWest:
    NPCMessage OreburghCityPokecenter1F_Text_CaptureBattleVideoUsingVsRecorder
    End

OreburghCityPokecenter1F_KidWithNDSEast:
    NPCMessage OreburghCityPokecenter1F_Text_CoolYouHaveAVsRecorder
    End

    

@ Sovereign (E10, Renegade): Jubilife TV's quiz. Right answers and a win over the reporter's team earn that team:
@ Treecko, Torchic and Mudkip, Lv. 10. The trainer flag records the win. The prize needs room for all
@ three, and the reporter and cameraman leave once it's given.
OreburghCityPokecenter1F_SovereignInterviewer:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    GoToIfDefeated TRAINER_SOVEREIGN_INTERVIEWER_HOENN, OreburghCityPokecenter1F_SovereignInterviewerPrize
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, OreburghCityPokecenter1F_SovereignInterviewerDeclined
    PlayFanfare SEQ_SLOT_ATARI_sseq
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerRollCamera
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerQuestion1
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_YES, OreburghCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerQuestion2
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, OreburghCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerQuestion3
    ShowYesNoMenu VAR_RESULT
    GoToIfNe VAR_RESULT, MENU_NO, OreburghCityPokecenter1F_SovereignInterviewerWrong
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    PlayFanfare SEQ_SLOT_OOATARI_sseq
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerQuestion4
    ShowYesNoMenu VAR_RESULT
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    CallIfEq VAR_RESULT, MENU_YES, OreburghCityPokecenter1F_SovereignInterviewerAnswerYes
    CallIfEq VAR_RESULT, MENU_NO, OreburghCityPokecenter1F_SovereignInterviewerAnswerNo
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerQuestion5
    ShowYesNoMenu VAR_RESULT
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerLetsFind
    WaitFanfare
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_INTERVIEWER_HOENN
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, OreburghCityPokecenter1F_SovereignInterviewerLost
    SetTrainerFlag TRAINER_SOVEREIGN_INTERVIEWER_HOENN
    PlaySE SEQ_SE_DP_PINPON_sseq
    WaitSE SEQ_SE_DP_PINPON_sseq
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerWon
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghCityPokecenter1F_SovereignInterviewerLost:
    BlackOutFromBattle
    ReleaseAll
    End

OreburghCityPokecenter1F_SovereignInterviewerWrong:
    WaitFanfare
    PlaySE SEQ_SE_DP_BOX03_sseq
    WaitSE SEQ_SE_DP_BOX03_sseq
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerWrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghCityPokecenter1F_SovereignInterviewerDeclined:
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerDeclined
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghCityPokecenter1F_SovereignInterviewerAnswerYes:
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerAnswerYes
    Return

OreburghCityPokecenter1F_SovereignInterviewerAnswerNo:
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerAnswerNo
    Return

OreburghCityPokecenter1F_SovereignInterviewerPrize:
    GetPartyCount VAR_RESULT
    GoToIfGt VAR_RESULT, 3, OreburghCityPokecenter1F_SovereignInterviewerNoRoom
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerPrizeIntro
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerName1
    PlayFanfare SEQ_FANFA4_sseq
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerReceived1
    WaitFanfare
    GivePokemon SPECIES_TREECKO, 10, ITEM_MIRACLE_SEED, VAR_RESULT
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerNickname1
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, OreburghCityPokecenter1F_SovereignInterviewerNickname
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerName2
    PlayFanfare SEQ_FANFA4_sseq
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerReceived2
    WaitFanfare
    GivePokemon SPECIES_TORCHIC, 10, ITEM_CHARCOAL, VAR_RESULT
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerNickname2
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, OreburghCityPokecenter1F_SovereignInterviewerNickname
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerName3
    PlayFanfare SEQ_FANFA4_sseq
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerReceived3
    WaitFanfare
    GivePokemon SPECIES_MUDKIP, 10, ITEM_MYSTIC_WATER, VAR_RESULT
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerNickname3
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    CallIfEq VAR_RESULT, MENU_YES, OreburghCityPokecenter1F_SovereignInterviewerNickname
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerBye
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SetFlag FLAG_SOVEREIGN_INTERVIEWER_HOENN_DONE
    RemoveObject LOCALID_OREBURGH_SOVEREIGN_INTERVIEWER
    RemoveObject LOCALID_OREBURGH_SOVEREIGN_CAMERAMAN
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

OreburghCityPokecenter1F_SovereignInterviewerNoRoom:
    Message OreburghCityPokecenter1F_Text_SovereignInterviewerNoRoom
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghCityPokecenter1F_SovereignInterviewerNickname:
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, OreburghCityPokecenter1F_SovereignInterviewerNicknamed
    FadeScreenIn
    WaitFadeScreen
    Return

OreburghCityPokecenter1F_SovereignInterviewerNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

OreburghCityPokecenter1F_SovereignCameraman:
    NPCMessage OreburghCityPokecenter1F_Text_SovereignInterviewerCameraman
    End

    .balign 4, 0
