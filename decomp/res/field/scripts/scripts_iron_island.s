#include "macros/scrcmd.inc"
#include "res/text/bank/iron_island.h"
#include "res/field/events/events_iron_island.h"


    ScriptEntry IronIsland_OnTransition
    ScriptEntry IronIsland_Sailor
    ScriptEntry IronIsland_Riley
    ScriptEntry IronIsland_SovereignSteelMaster
    ScriptEntryEnd

IronIsland_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_IRON_ISLAND_EXTERIOR
    End

IronIsland_Sailor:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GetPlayerDir VAR_0x8004
    FacePlayer
    Message IronIsland_Text_WantToSailSomewhere
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    GoToIfEq VAR_RESULT, MENU_YES, IronIsland_TakeShipToCanalave
    GoTo IronIsland_TellWheneverSetSail

IronIsland_TakeShipToCanalave:
    Message IronIsland_Text_AnchorsAweigh
    CloseMessage
    Call IronIsland_SailorEnterShip
    CallIfEq VAR_0x8004, DIR_SOUTH, IronIsland_PlayerEnterShipSouth
    CallIfEq VAR_0x8004, DIR_WEST, IronIsland_PlayerEnterShipWest
    TakeShipToCanalave
    ReleaseAll
    End

IronIsland_TellWheneverSetSail:
    Message IronIsland_Text_TellWheneverSetSail
    WaitButton
    CloseMessage
    ReleaseAll
    End

IronIsland_SailorEnterShip:
    ApplyMovement LOCALID_SAILOR, IronIsland_Movement_SailorFaceWest
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_SAILOR, IronIsland_Movement_SetInvisible
    WaitMovement
    Return

IronIsland_PlayerEnterShipSouth:
    ApplyMovement LOCALID_PLAYER, IronIsland_Movement_PlayerWalkToShipSouth
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_PLAYER, IronIsland_Movement_SetInvisible
    WaitMovement
    Return

IronIsland_PlayerEnterShipWest:
    ApplyMovement LOCALID_PLAYER, IronIsland_Movement_PlayerWalkToShipWest
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_PLAYER, IronIsland_Movement_SetInvisible
    WaitMovement
    Return

    .balign 4, 0
IronIsland_Movement_SailorFaceWest:
    FaceWest
    Delay15
    EndMovement

    .balign 4, 0
IronIsland_Movement_SetInvisible:
    SetInvisible
    EndMovement

    .balign 4, 0
IronIsland_Movement_PlayerWalkToShipSouth:
    WalkNormalSouth
    FaceWest
    Delay15
    EndMovement

    .balign 4, 0
IronIsland_Movement_PlayerWalkToShipWest:
    WalkNormalWest
    Delay15
    EndMovement

// Sovereign (E10): as in Renegade Platinum, Riley battles the player at the entrance (HM04 comes after the Galactic
// grunts on B2F), and Julian, a Steel-type master, battles a player whose only Pokémon is a Steel type for the Iron
// Plate.
IronIsland_Riley:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message IronIsland_Text_SovereignRileyLetsBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_RILEY_IRON_ISLAND
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, IronIsland_SovereignBlackOut
    Message IronIsland_Text_SovereignRileyStrongAura
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Message IronIsland_Text_SovereignRileyTrainingInside
    GoTo IronIsland_RileyEnterIronIsland
    End

IronIsland_SovereignBlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

IronIsland_SovereignSteelMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_IRON_ISLAND_IRON_PLATE, IronIsland_SovereignThanksForSteelBattle
    Message IronIsland_Text_SovereignSteelTypeMaster
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, IronIsland_SovereignOnlyOneSteelType
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_STEEL, IronIsland_SovereignAskSteelBattle
    GoToIfEq VAR_0x8005, TYPE_STEEL, IronIsland_SovereignAskSteelBattle
IronIsland_SovereignOnlyOneSteelType:
    Message IronIsland_Text_SovereignOnlyOneSteelType
    WaitButton
    CloseMessage
    ReleaseAll
    End

IronIsland_SovereignAskSteelBattle:
    Message IronIsland_Text_SovereignWhoHasUltimateSteelType
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, IronIsland_SovereignCantWin
    Message IronIsland_Text_SovereignTimeForSteelBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_STEEL_MASTER_IRON_ISLAND
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, IronIsland_SovereignLostSteelBattle
    Message IronIsland_Text_SovereignYouOwnUltimateSteelType
    SetVar VAR_0x8004, ITEM_IRON_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_IRON_ISLAND_IRON_PLATE
IronIsland_SovereignThanksForSteelBattle:
    Message IronIsland_Text_SovereignThanksForSteelBattle
    WaitButton
    CloseMessage
    ReleaseAll
    End

IronIsland_SovereignCantWin:
    Message IronIsland_Text_SovereignFeelYouCantWin
    WaitButton
    CloseMessage
    ReleaseAll
    End

IronIsland_SovereignLostSteelBattle:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message IronIsland_Text_SovereignUltimateSteelTypeIsMine
    WaitButton
    CloseMessage
    ReleaseAll
    End

IronIsland_RileyEnterIronIsland:
    CloseMessage
    ApplyMovement LOCALID_RILEY, IronIsland_Movement_RileyWalkOnSpotNorth
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_RILEY
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    ReleaseAll
    End

    .balign 4, 0
IronIsland_Movement_RileyWalkOnSpotNorth:
    WalkOnSpotNormalNorth
    EndMovement
