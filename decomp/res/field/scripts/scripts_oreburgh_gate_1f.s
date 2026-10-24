#include "macros/scrcmd.inc"
#include "res/text/bank/oreburgh_gate_1f.h"
#include "res/field/events/events_oreburgh_gate_1f.h"


    ScriptEntry OreburghGate1F_OnTransition
    ScriptEntry OreburghGate1F_Hiker
    ScriptEntry OreburghGate1F_CoordEvent_Hiker
    ScriptEntry OreburghGate1F_SovereignGroundMaster
    ScriptEntryEnd

OreburghGate1F_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_OREBURGH_GATE
    End

OreburghGate1F_Hiker:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CheckBadgeAcquired BADGE_ID_COAL, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, OreburghGate1F_HikerGiveHM
    Message OreburghGate1F_Text_NowYouCanUseRockSmash
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghGate1F_HikerGiveHM:
    GoToIfSet FLAG_RECEIVED_HM06, OreburghGate1F_ThatHMContainsRockSmash
    Message OreburghGate1F_Text_MakeAGiftOfThisHM
    SetVar VAR_0x8004, ITEM_HM06
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Call OreburghGate1F_SetFlagReceivedHM06
    GoTo OreburghGate1F_ThatHMContainsRockSmash

OreburghGate1F_ThatHMContainsRockSmash:
    Message OreburghGate1F_Text_ThatHMContainsRockSmash
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghGate1F_SetFlagReceivedHM06:
    SetFlag FLAG_RECEIVED_HM06
    SetVar VAR_OREBURGH_GATE_1F_HIKER_STATE, 2
    Return

OreburghGate1F_CoordEvent_Hiker:
    LockAll
    ApplyMovement LOCALID_HIKER, OreburghGate1F_Movement_HikerWalkToPlayer
    ApplyMovement LOCALID_PLAYER, OreburghGate1F_Movement_PlayerFaceHiker
    WaitMovement
    Message OreburghGate1F_Text_MakeAGiftOfThisHM
    SetVar VAR_0x8004, ITEM_HM06
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Call OreburghGate1F_SetFlagReceivedHM06
    Message OreburghGate1F_Text_ThatHMContainsRockSmash
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
OreburghGate1F_Movement_PlayerFaceHiker:
    Delay8
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
OreburghGate1F_Movement_HikerWalkToPlayer:
    WalkOnSpotNormalSouth
    EmoteExclamationMark
    WalkNormalSouth
    EndMovement

@ Sovereign (E10, Renegade's Type Masters): the Ground-type Master battles one Ground-type Pokémon, alone in the party, for
@ the Earth Plate (Renegade's trainer 1041).
OreburghGate1F_SovereignGroundMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_GROUND_MASTER, OreburghGate1F_SovereignGroundMasterThanks
    Message OreburghGate1F_Text_SovereignGroundMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, OreburghGate1F_SovereignGroundMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_GROUND, OreburghGate1F_SovereignGroundMasterAsk
    GoToIfEq VAR_0x8005, TYPE_GROUND, OreburghGate1F_SovereignGroundMasterAsk
OreburghGate1F_SovereignGroundMasterOnlyOne:
    Message OreburghGate1F_Text_SovereignGroundMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghGate1F_SovereignGroundMasterAsk:
    Message OreburghGate1F_Text_SovereignGroundMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, OreburghGate1F_SovereignGroundMasterDecline
    Message OreburghGate1F_Text_SovereignGroundMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_GROUND_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, OreburghGate1F_SovereignGroundMasterLost
    Message OreburghGate1F_Text_SovereignGroundMasterWin
    SetVar VAR_0x8004, ITEM_EARTH_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_GROUND_MASTER
OreburghGate1F_SovereignGroundMasterThanks:
    Message OreburghGate1F_Text_SovereignGroundMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghGate1F_SovereignGroundMasterDecline:
    Message OreburghGate1F_Text_SovereignGroundMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghGate1F_SovereignGroundMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message OreburghGate1F_Text_SovereignGroundMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
