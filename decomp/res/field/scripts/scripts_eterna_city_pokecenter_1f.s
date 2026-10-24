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

    .balign 4, 0
