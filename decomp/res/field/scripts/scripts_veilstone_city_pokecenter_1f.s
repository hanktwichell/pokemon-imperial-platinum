#include "macros/scrcmd.inc"
#include "res/text/bank/veilstone_city_pokecenter_1f.h"
#include "res/field/events/events_veilstone_city_pokecenter_1f.h"


    ScriptEntry VeilstoneCityPokecenter1F_Nurse
    ScriptEntry VeilstoneCityPokecenter1F_Socialite
    ScriptEntry VeilstoneCityPokecenter1F_SchoolKidM
    ScriptEntry VeilstoneCityPokecenter1F_SovereignDragonTamer
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
