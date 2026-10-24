#include "macros/scrcmd.inc"
#include "res/text/bank/veilstone_city_southwest_house.h"
#include "res/field/events/events_veilstone_city_southwest_house.h"


    ScriptEntry VeilstoneCitySouthwestHouse_Beauty
    ScriptEntry VeilstoneCitySouthwestHouse_Youngster
    ScriptEntry VeilstoneCitySouthwestHouse_Pachirisu
    ScriptEntry VeilstoneCitySouthwestHouse_SovereignFightingMaster
    ScriptEntryEnd

VeilstoneCitySouthwestHouse_Beauty:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_DAILY_GOT_MASSAGE_VEILSTONE_CITY_SOUTHWEST_HOUSE, VeilstoneCitySouthwestHouse_ComeBackTomorrow
    Message VeilstoneCitySouthwestHouse_Text_ICanMassagePokemon
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, VeilstoneCitySouthwestHouse_ImNotShady
    Message VeilstoneCitySouthwestHouse_Text_MassageWhichPokemon
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SelectMoveTutorPokemon
    GetSelectedPartySlot VAR_MAP_LOCAL_0x00
    ReturnToField
    FadeScreenIn
    WaitFadeScreen
    GoToIfEq VAR_MAP_LOCAL_0x00, PARTY_SLOT_NONE, VeilstoneCitySouthwestHouse_ImNotShady
    GetPartyMonSpecies VAR_MAP_LOCAL_0x00, VAR_RESULT
    GoToIfEq VAR_RESULT, SPECIES_NONE, VeilstoneCitySouthwestHouse_IdBreakThatEgg
    Message VeilstoneCitySouthwestHouse_Text_LetsGetStarted
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlaySE SEQ_SE_DP_FW367_sseq
    WaitSE SEQ_SE_DP_FW367_sseq
    FadeScreenIn
    WaitFadeScreen
    BufferPartyMonNickname 0, VAR_MAP_LOCAL_0x00
    Message VeilstoneCitySouthwestHouse_Text_PokemonLooksContent
    SetFlag FLAG_DAILY_GOT_MASSAGE_VEILSTONE_CITY_SOUTHWEST_HOUSE
    IncreasePartyMonFriendship 3, VAR_MAP_LOCAL_0x00
    TryGetRandomMassageGirlAccessory VAR_0x8004
    GoToIfEq VAR_0x8004, -1, VeilstoneCitySouthwestHouse_DropByAgainTomorrow
    Message VeilstoneCitySouthwestHouse_Text_IFoundThis
    SetVar VAR_0x8005, 1
    Common_GiveAccessory
    GoTo VeilstoneCitySouthwestHouse_DropByAgainTomorrow

VeilstoneCitySouthwestHouse_ComeBackTomorrow:
    Message VeilstoneCitySouthwestHouse_Text_ComeBackTomorrow
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCitySouthwestHouse_IdBreakThatEgg:
    Message VeilstoneCitySouthwestHouse_Text_IdBreakThatEgg
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCitySouthwestHouse_ImNotShady:
    Message VeilstoneCitySouthwestHouse_Text_ImNotShady
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCitySouthwestHouse_DropByAgainTomorrow:
    Message VeilstoneCitySouthwestHouse_Text_DropByAgainTomorrow
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCitySouthwestHouse_Youngster:
    NPCMessage VeilstoneCitySouthwestHouse_Text_MyInLawIsScarfGuy
    End

VeilstoneCitySouthwestHouse_Pachirisu:
    PokemonCryAndMessage SPECIES_PACHIRISU, VeilstoneCitySouthwestHouse_Text_PachirisuCry
    End

    

@ Sovereign (E10, Renegade's Type Masters): the Fighting-type Master battles one Fighting-type Pokémon, alone in the party, for
@ the Fist Plate (Renegade's trainer 1039).
VeilstoneCitySouthwestHouse_SovereignFightingMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_FIGHTING_MASTER, VeilstoneCitySouthwestHouse_SovereignFightingMasterThanks
    Message VeilstoneCitySouthwestHouse_Text_SovereignFightingMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, VeilstoneCitySouthwestHouse_SovereignFightingMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_FIGHTING, VeilstoneCitySouthwestHouse_SovereignFightingMasterAsk
    GoToIfEq VAR_0x8005, TYPE_FIGHTING, VeilstoneCitySouthwestHouse_SovereignFightingMasterAsk
VeilstoneCitySouthwestHouse_SovereignFightingMasterOnlyOne:
    Message VeilstoneCitySouthwestHouse_Text_SovereignFightingMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCitySouthwestHouse_SovereignFightingMasterAsk:
    Message VeilstoneCitySouthwestHouse_Text_SovereignFightingMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, VeilstoneCitySouthwestHouse_SovereignFightingMasterDecline
    Message VeilstoneCitySouthwestHouse_Text_SovereignFightingMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_FIGHTING_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, VeilstoneCitySouthwestHouse_SovereignFightingMasterLost
    Message VeilstoneCitySouthwestHouse_Text_SovereignFightingMasterWin
    SetVar VAR_0x8004, ITEM_FIST_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_FIGHTING_MASTER
VeilstoneCitySouthwestHouse_SovereignFightingMasterThanks:
    Message VeilstoneCitySouthwestHouse_Text_SovereignFightingMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCitySouthwestHouse_SovereignFightingMasterDecline:
    Message VeilstoneCitySouthwestHouse_Text_SovereignFightingMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCitySouthwestHouse_SovereignFightingMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message VeilstoneCitySouthwestHouse_Text_SovereignFightingMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
