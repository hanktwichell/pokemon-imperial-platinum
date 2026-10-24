#include "macros/scrcmd.inc"
#include "res/text/bank/solaceon_town.h"
#include "res/field/events/events_solaceon_town.h"


    ScriptEntry SolaceonTown_Rancher1
    ScriptEntry SolaceonTown_Cowgirl1
    ScriptEntry SolaceonTown_Twin
    ScriptEntry SolaceonTown_Cowgirl2
    ScriptEntry SolaceonTown_Rancher2
    ScriptEntry SolaceonTown_RuinManiac
    ScriptEntry SolaceonTown_MapSignpost
    ScriptEntry SolaceonTown_SignboardPokemonDayCare
    ScriptEntry SolaceonTown_SignboardPokemonNewsPress
    ScriptEntry SolaceonTown_OnTransition
    ScriptEntry SolaceonTown_OnResume
    ScriptEntry SolaceonTown_CoordEvent_Rival
    ScriptEntry SolaceonTown_SovereignLucian
    ScriptEntryEnd

SolaceonTown_OnResume:
    End

SolaceonTown_OnTransition:
    CheckDaycareHasEgg VAR_MAP_LOCAL_0x00
    GoToIfNe VAR_MAP_LOCAL_0x00, FALSE, SolaceonTown_SetDayCareManDirEast
    End

SolaceonTown_SetDayCareManDirEast:
    SetObjectEventDir LOCALID_DAY_CARE_MAN, DIR_EAST
    End

SolaceonTown_Rancher1:
    NPCMessage SolaceonTown_Text_BreathingInRefreshingAir
    End

SolaceonTown_Cowgirl1:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfBadgeAcquired BADGE_ID_RELIC, SolaceonTown_TakeATour
    Message SolaceonTown_Text_TakeItEasy
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonTown_TakeATour:
    Message SolaceonTown_Text_TakeATour
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonTown_Twin:
    NPCMessage SolaceonTown_Text_ImTooLittle
    End

SolaceonTown_Cowgirl2:
    NPCMessage SolaceonTown_Text_IVisitTheLostTower
    End

SolaceonTown_Rancher2:
    NPCMessage SolaceonTown_Text_UsedToBeNothing
    End

SolaceonTown_RuinManiac:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CheckPoketchAppRegistered POKETCH_APPID_POKEMONHISTORY, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SolaceonTown_EachPokemonOwnHistory
    GetLocalDexSeenCount VAR_RESULT
    GoToIfLt VAR_RESULT, 50, SolaceonTown_IfCompetentMetFiftyPokemon
    Message SolaceonTown_Text_PoketchAppPokemonHistory
    SetVar VAR_0x8004, POKETCH_APPID_POKEMONHISTORY
    Common_GivePoketchApp
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonTown_IfCompetentMetFiftyPokemon:
    Message SolaceonTown_Text_IfCompetentMetFiftyPokemon
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonTown_EachPokemonOwnHistory:
    Message SolaceonTown_Text_EachPokemonOwnHistory
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonTown_MapSignpost:
    ShowMapSign SolaceonTown_Text_MapSign
    End

SolaceonTown_SignboardPokemonDayCare:
    ShowLandmarkSign SolaceonTown_Text_SignPokemonDayCare
    End

SolaceonTown_SignboardPokemonNewsPress:
    ShowLandmarkSign SolaceonTown_Text_SignPokemonNewsPress
    End

SolaceonTown_CoordEvent_Rival:
    LockAll
    ApplyMovement LOCALID_PLAYER, SolaceonTown_Movement_PlayerNoticeRival
    WaitMovement
    Common_SetRivalBGM
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    SetObjectEventPos LOCALID_RIVAL, VAR_0x8004, 661
    ClearFlag FLAG_HIDE_SOLACEON_TOWN_RIVAL
    AddObject LOCALID_RIVAL
    LockObject LOCALID_RIVAL
    ApplyMovement LOCALID_PLAYER, SolaceonTown_Movement_PlayerFaceNorth
    ApplyMovement LOCALID_RIVAL, SolaceonTown_Movement_RivalWalkSouth
    WaitMovement
    Message SolaceonTown_Text_Yahoo
    CloseMessage
    ApplyMovement LOCALID_RIVAL, SolaceonTown_Movement_RivalLookAround
    WaitMovement
    BufferRivalName 0
    BufferPlayerName 1
    Message SolaceonTown_Text_IGotSomethingCool
    ApplyMovement LOCALID_RIVAL, SolaceonTown_Movement_RivalExclamationMark
    WaitMovement
    Message SolaceonTown_Text_CheckOutTheRuins
    CloseMessage
    ApplyMovement LOCALID_RIVAL, SolaceonTown_Movement_RivalLeave
    WaitMovement
    RemoveObject LOCALID_RIVAL
    Common_FadeToDefaultMusic2
    SetVar VAR_SOLACEON_TOWN_STATE, 1
    ReleaseAll
    End

    .balign 4, 0
SolaceonTown_Movement_RivalWalkSouth:
    WalkFastSouth 7
    EndMovement

    .balign 4, 0
SolaceonTown_Movement_RivalLookAround:
    WalkOnSpotFastWest
    Delay8
    WalkOnSpotFastEast
    Delay8
    WalkOnSpotFastSouth
    EndMovement

    .balign 4, 0
SolaceonTown_Movement_RivalExclamationMark:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
SolaceonTown_Movement_RivalLeave:
    WalkFastNorth 7
    EndMovement

    .balign 4, 0
SolaceonTown_Movement_PlayerNoticeRival:
    Delay8
    EmoteExclamationMark
    Delay8 3
    EndMovement

    .balign 4, 0
SolaceonTown_Movement_PlayerFaceNorth:
    FaceNorth
    EndMovement

// Sovereign (E10): as in Renegade Platinum, Lucian of the Elite Four comes down from the Solaceon Ruins the first time
// the player walks past and gives TM29 (Psychic).
SolaceonTown_SovereignLucian:
    LockAll
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_LUCIAN
    SetObjectEventPos LOCALID_LUCIAN, 595, 656
    AddObject LOCALID_LUCIAN
    LockObject LOCALID_LUCIAN
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_LUCIAN, SolaceonTown_Movement_SovereignLucianExclamationMark
    WaitMovement
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8005, 660, SolaceonTown_SovereignLucianWalkToPlayerZ660
    CallIfEq VAR_0x8005, 661, SolaceonTown_SovereignLucianWalkToPlayerZ661
    Message SolaceonTown_Text_SovereignImLucian
    SetVar VAR_0x8004, ITEM_TM29
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Message SolaceonTown_Text_SovereignFurtherResearch
    CloseMessage
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8005, 660, SolaceonTown_SovereignLucianLeaveZ660
    CallIfEq VAR_0x8005, 661, SolaceonTown_SovereignLucianLeaveZ661
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_LUCIAN
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    SetVar VAR_SOVEREIGN_SOLACEON_LUCIAN_STATE, 1
    ReleaseAll
    End

SolaceonTown_SovereignLucianWalkToPlayerZ660:
    ApplyMovement LOCALID_LUCIAN, SolaceonTown_Movement_SovereignLucianWalkToPlayerZ660
    WaitMovement
    Return

SolaceonTown_SovereignLucianWalkToPlayerZ661:
    ApplyMovement LOCALID_LUCIAN, SolaceonTown_Movement_SovereignLucianWalkToPlayerZ661
    WaitMovement
    Return

SolaceonTown_SovereignLucianLeaveZ660:
    ApplyMovement LOCALID_LUCIAN, SolaceonTown_Movement_SovereignLucianLeaveZ660
    WaitMovement
    Return

SolaceonTown_SovereignLucianLeaveZ661:
    ApplyMovement LOCALID_LUCIAN, SolaceonTown_Movement_SovereignLucianLeaveZ661
    WaitMovement
    Return

    .balign 4, 0
SolaceonTown_Movement_SovereignLucianExclamationMark:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
SolaceonTown_Movement_SovereignLucianWalkToPlayerZ660:
    WalkNormalSouth 4
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
SolaceonTown_Movement_SovereignLucianWalkToPlayerZ661:
    WalkNormalSouth 5
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
SolaceonTown_Movement_SovereignLucianLeaveZ660:
    WalkNormalNorth 4
    EndMovement

    .balign 4, 0
SolaceonTown_Movement_SovereignLucianLeaveZ661:
    WalkNormalNorth 5
    EndMovement
