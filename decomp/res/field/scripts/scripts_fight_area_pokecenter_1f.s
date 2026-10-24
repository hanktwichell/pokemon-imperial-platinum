#include "macros/scrcmd.inc"
#include "res/text/bank/fight_area_pokecenter_1f.h"
#include "res/field/events/events_fight_area_pokecenter_1f.h"


    ScriptEntry FightAreaPokecenter1F_Nurse
    ScriptEntry FightAreaPokecenter1F_Guitarist
    ScriptEntry FightAreaPokecenter1F_Waitress
    ScriptEntry FightAreaPokecenter1F_BlackBelt
    ScriptEntry FightAreaPokecenter1F_SovereignGreninjaTrainer
    ScriptEntry FightAreaPokecenter1F_SovereignEventGifts
    ScriptEntryEnd

FightAreaPokecenter1F_Nurse:
    Common_CallPokecenterNurse LOCALID_FIGHT_AREA_NURSE
    End

FightAreaPokecenter1F_Guitarist:
    NPCMessage FightAreaPokecenter1F_Text_BattleFrontiersTough
    End

FightAreaPokecenter1F_Waitress:
    NPCMessage FightAreaPokecenter1F_Text_BestTrainersAtBattleZone
    End

FightAreaPokecenter1F_BlackBelt:
    NPCMessage FightAreaPokecenter1F_Text_ToToughenMyself
    End

@ Sovereign (FM, owner 2026-10-24): an Ace Trainer gives Battle Bond Greninja, the Battle Frontier's bond. Level 50,
@ with the official demo's moves.
FightAreaPokecenter1F_SovereignGreninjaTrainer:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_BATTLE_BOND_GRENINJA, FightAreaPokecenter1F_SovereignGreninjaAfter
    Message FightAreaPokecenter1F_Text_SovereignGreninjaOffer
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, FightAreaPokecenter1F_SovereignGreninjaDeclined
    GetPartyCount VAR_RESULT
    GoToIfEq VAR_RESULT, 6, FightAreaPokecenter1F_SovereignGreninjaPartyFull
    Message FightAreaPokecenter1F_Text_SovereignGreninjaTakeCare
    PlayFanfare SEQ_FANFA4_sseq
    BufferPlayerName 0
    Message FightAreaPokecenter1F_Text_SovereignGreninjaReceived
    WaitFanfare
    GivePokemon SPECIES_GRENINJA, 50, ITEM_NONE, VAR_RESULT
    SetFlag FLAG_SOVEREIGN_RECEIVED_BATTLE_BOND_GRENINJA
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    SovereignSetPartyMonForm VAR_MAP_LOCAL_0x00, 1
    ResetPartyMonMoveSlot_Unused VAR_MAP_LOCAL_0x00, 0, MOVE_WATER_SHURIKEN
    ResetPartyMonMoveSlot_Unused VAR_MAP_LOCAL_0x00, 1, MOVE_AERIAL_ACE
    ResetPartyMonMoveSlot_Unused VAR_MAP_LOCAL_0x00, 2, MOVE_DOUBLE_TEAM
    ResetPartyMonMoveSlot_Unused VAR_MAP_LOCAL_0x00, 3, MOVE_NIGHT_SLASH
    Message FightAreaPokecenter1F_Text_SovereignGreninjaNickname
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, FightAreaPokecenter1F_SovereignGreninjaGiveNickname
    CloseMessage
    ReleaseAll
    End

FightAreaPokecenter1F_SovereignGreninjaGiveNickname:
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    OpenPokemonNamingScreen VAR_MAP_LOCAL_0x00, VAR_RESULT
    CallIfNe VAR_RESULT, 1, FightAreaPokecenter1F_SovereignGreninjaNicknamed
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

FightAreaPokecenter1F_SovereignGreninjaNicknamed:
    IncrementGameRecord RECORD_POKEMON_NICKNAMED
    Return

FightAreaPokecenter1F_SovereignGreninjaPartyFull:
    Message FightAreaPokecenter1F_Text_SovereignGreninjaPartyFull
    WaitButton
    CloseMessage
    ReleaseAll
    End

FightAreaPokecenter1F_SovereignGreninjaDeclined:
    Message FightAreaPokecenter1F_Text_SovereignGreninjaDeclined
    WaitButton
    CloseMessage
    ReleaseAll
    End

FightAreaPokecenter1F_SovereignGreninjaAfter:
    Message FightAreaPokecenter1F_Text_SovereignGreninjaAfter
    WaitButton
    CloseMessage
    ReleaseAll
    End

@ Sovereign (FM, temporary placement, owner 2026-10-24): the event-gift deliveryman gives each event form once, the
@ forms the official games gave at events (scrcmd.c sSovereignEventGifts: its species, form, level and signature move).
FightAreaPokecenter1F_SovereignEventGifts:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message FightAreaPokecenter1F_Text_SovereignEventGiftsIntro
    InitLocalTextListMenu 1, 1, 0, VAR_0x8008
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift00, 0
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift01, 1
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift02, 2
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift03, 3
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift04, 4
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift05, 5
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift06, 6
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift07, 7
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift08, 8
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift09, 9
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift10, 10
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift11, 11
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift12, 12
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift13, 13
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift14, 14
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift15, 15
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift16, 16
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift17, 17
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift18, 18
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift19, 19
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift20, 20
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift21, 21
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGift22, 22
    AddListMenuEntry FightAreaPokecenter1F_Text_SovereignEventGiftsCancel, 23
    ShowListMenu
    GoToIfGe VAR_0x8008, 23, FightAreaPokecenter1F_SovereignEventGiftsBye
    SovereignGetEventGift VAR_0x8008, VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8004, SPECIES_NONE, FightAreaPokecenter1F_SovereignEventGiftsAlreadyGiven
    GoToIfEq VAR_0x8005, 0, FightAreaPokecenter1F_SovereignEventGiftsRestyle
    GetPartyCount VAR_RESULT
    GoToIfEq VAR_RESULT, MAX_PARTY_SIZE, FightAreaPokecenter1F_SovereignGreninjaPartyFull
    PlayFanfare SEQ_FANFA4_sseq
    BufferPlayerName 0
    BufferSpeciesNameFromVar 1, VAR_0x8004, 0, 0
    Message FightAreaPokecenter1F_Text_SovereignEventGiftsReceived
    WaitFanfare
    GivePokemon VAR_0x8004, VAR_0x8005, ITEM_NONE, VAR_RESULT
    GetPartyCount VAR_MAP_LOCAL_0x00
    SubVar VAR_MAP_LOCAL_0x00, 1
    SovereignFinishEventGift VAR_0x8008, VAR_MAP_LOCAL_0x00
    Message FightAreaPokecenter1F_Text_SovereignEventGiftsNickname
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, FightAreaPokecenter1F_SovereignGreninjaGiveNickname
    CloseMessage
    ReleaseAll
    End

@ A Mythical's event form: he restyles one the player caught (Mythicals are never gifts).
FightAreaPokecenter1F_SovereignEventGiftsRestyle:
    BufferSpeciesNameFromVar 0, VAR_0x8004, 0, 0
    Message FightAreaPokecenter1F_Text_SovereignEventGiftsRestyleAsk
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SelectPokemonToTrade
    FadeScreenIn
    WaitFadeScreen
    GoToIfEq VAR_RESULT, 0xFF, FightAreaPokecenter1F_SovereignEventGiftsBye
    SovereignRestyleEventForm VAR_0x8008, VAR_RESULT, VAR_0x8006
    BufferSpeciesNameFromVar 0, VAR_0x8004, 0, 0
    GoToIfEq VAR_0x8006, FALSE, FightAreaPokecenter1F_SovereignEventGiftsRestyleWrong
    Message FightAreaPokecenter1F_Text_SovereignEventGiftsRestyled
    WaitButton
    CloseMessage
    ReleaseAll
    End

FightAreaPokecenter1F_SovereignEventGiftsRestyleWrong:
    Message FightAreaPokecenter1F_Text_SovereignEventGiftsRestyleWrong
    WaitButton
    CloseMessage
    ReleaseAll
    End

FightAreaPokecenter1F_SovereignEventGiftsAlreadyGiven:
    Message FightAreaPokecenter1F_Text_SovereignEventGiftsAlreadyGiven
    WaitButton
    CloseMessage
    ReleaseAll
    End

FightAreaPokecenter1F_SovereignEventGiftsBye:
    Message FightAreaPokecenter1F_Text_SovereignEventGiftsBye
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
