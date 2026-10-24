#include "macros/scrcmd.inc"
#include "res/text/bank/fight_area_pokecenter_1f.h"
#include "res/field/events/events_fight_area_pokecenter_1f.h"


    ScriptEntry FightAreaPokecenter1F_Nurse
    ScriptEntry FightAreaPokecenter1F_Guitarist
    ScriptEntry FightAreaPokecenter1F_Waitress
    ScriptEntry FightAreaPokecenter1F_BlackBelt
    ScriptEntry FightAreaPokecenter1F_SovereignGreninjaTrainer
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

    .balign 4, 0
