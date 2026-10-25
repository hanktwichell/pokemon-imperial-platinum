#include "macros/scrcmd.inc"
#include "res/text/bank/menu_entries.h"
#include "res/text/bank/route_207.h"
#include "res/field/events/events_route_207.h"


    ScriptEntry Route207_OnTransition
    ScriptEntry Route207_CoordEvent_Counterpart
    ScriptEntry Route207_Dummy3
    ScriptEntry Route207_CyclistM
    ScriptEntry Route207_ArrowSignpostMtCoronet
    ScriptEntry Route207_ArrowSignpostOreburghCity
    ScriptEntry Route207_TrainerTipsSignpost
    ScriptEntry Route207_SovereignRockMaster
    ScriptEntryEnd

Route207_OnTransition:
    GetPlayerGender VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, GENDER_MALE, Route207_SetCounterpartGraphicsDawn
    GoToIfEq VAR_MAP_LOCAL_0x00, GENDER_FEMALE, Route207_SetCounterpartGraphicsLucas
    End

Route207_SetCounterpartGraphicsDawn:
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_PLAYER_F
    End

Route207_SetCounterpartGraphicsLucas:
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_PLAYER_M
    End

Route207_CoordEvent_Counterpart:
    LockAll
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    SetObjectEventPos LOCALID_COUNTERPART, 331, VAR_0x8005
    Call Route207_ShowCounterpart
    ApplyMovement LOCALID_COUNTERPART, Route207_Movement_CounterpartNoticePlayer
    WaitMovement
    Common_SetCounterpartBGM
    ApplyMovement LOCALID_COUNTERPART, Route207_Movement_CounterpartWalkToPlayer
    WaitMovement
    ApplyMovement LOCALID_PLAYER, Route207_Movement_PlayerFaceCounterpart
    WaitMovement
    GoTo Route207_Counterpart
    End

Route207_ShowCounterpart:
    ClearFlag FLAG_HIDE_ROUTE_207_COUNTERPART
    AddObject LOCALID_COUNTERPART
    LockObject LOCALID_COUNTERPART
    Return

Route207_Counterpart:
    GetPlayerGender VAR_RESULT
    GoToIfEq VAR_RESULT, GENDER_MALE, Route207_Dawn
    GoTo Route207_Lucas

@ Sovereign (E10, Renegade's Route 207 battle): the counterpart battles first (their team depends on the player's
@ starter: Renegade's trainers 940-945), then gives the Vs. Seeker as a training gift. The Dowsing Machine app follows
@ as in Platinum (Renegade drops it here).
Route207_Dawn:
    BufferPlayerName 0
    Message Route207_Text_DawnIllProveItInABattle
    CloseMessage
    GetPlayerStarterSpecies VAR_0x8004
    GoToIfEq VAR_0x8004, SPECIES_TURTWIG, Route207_DawnBattleTurtwig
    GoToIfEq VAR_0x8004, SPECIES_CHIMCHAR, Route207_DawnBattleChimchar
    StartTrainerBattle TRAINER_SOVEREIGN_DAWN_ROUTE_207_PIPLUP
    GoTo Route207_DawnBattleEnd

Route207_DawnBattleTurtwig:
    StartTrainerBattle TRAINER_SOVEREIGN_DAWN_ROUTE_207_TURTWIG
    GoTo Route207_DawnBattleEnd

Route207_DawnBattleChimchar:
    StartTrainerBattle TRAINER_SOVEREIGN_DAWN_ROUTE_207_CHIMCHAR
    GoTo Route207_DawnBattleEnd

Route207_DawnBattleEnd:
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route207_CounterpartBattleLost
    LockAll
    Common_SetCounterpartBGM
    BufferPlayerName 0
    Message Route207_Text_DawnGiftForTraining
    Call Route207_GiveVsSeeker
    Message Route207_Text_DawnHaveThisTooThen
    Call Route207_GivePoketchAppDowsingMachine
    Message Route207_Text_DawnUseDowsingMachineOften
    GoTo Route207_CounterpartLeave

Route207_Lucas:
    BufferPlayerName 0
    Message Route207_Text_LucasIllProveItInABattle
    CloseMessage
    GetPlayerStarterSpecies VAR_0x8004
    GoToIfEq VAR_0x8004, SPECIES_TURTWIG, Route207_LucasBattleTurtwig
    GoToIfEq VAR_0x8004, SPECIES_CHIMCHAR, Route207_LucasBattleChimchar
    StartTrainerBattle TRAINER_SOVEREIGN_LUCAS_ROUTE_207_PIPLUP
    GoTo Route207_LucasBattleEnd

Route207_LucasBattleTurtwig:
    StartTrainerBattle TRAINER_SOVEREIGN_LUCAS_ROUTE_207_TURTWIG
    GoTo Route207_LucasBattleEnd

Route207_LucasBattleChimchar:
    StartTrainerBattle TRAINER_SOVEREIGN_LUCAS_ROUTE_207_CHIMCHAR
    GoTo Route207_LucasBattleEnd

Route207_LucasBattleEnd:
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route207_CounterpartBattleLost
    LockAll
    Common_SetCounterpartBGM
    BufferPlayerName 0
    Message Route207_Text_LucasGiftForTraining
    Call Route207_GiveVsSeeker
    Message Route207_Text_LucasHaveThisTooThen
    Call Route207_GivePoketchAppDowsingMachine
    Message Route207_Text_LucasTryTouchingDowsingMachine
    GoTo Route207_CounterpartLeave

Route207_CounterpartBattleLost:
    RemoveObject LOCALID_COUNTERPART
    BlackOutFromBattle
    ReleaseAll
    End

Route207_GiveVsSeeker:
    SetFlag FLAG_UNLOCKED_VS_SEEKER_LVL_1
    SetVar VAR_0x8004, ITEM_VS_SEEKER
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Return

Route207_GivePoketchAppDowsingMachine:
    SetVar VAR_0x8004, POKETCH_APPID_DOWSINGMACHINE
    Common_GivePoketchApp
    BufferPoketchAppName 1, POKETCH_APPID_DOWSINGMACHINE
    Return

Route207_CounterpartLeave:
    CloseMessage
    ApplyMovement LOCALID_COUNTERPART, Route207_Movement_CounterpartLeave
    WaitMovement
    RemoveObject LOCALID_COUNTERPART
    Common_FadeToDefaultMusic
    SetVar VAR_ROUTE_207_COUNTERPART_TRIGGER_STATE, 1
    ReleaseAll
    End

    .balign 4, 0
Route207_Movement_PlayerFaceCounterpart:
    WalkOnSpotNormalWest
    EndMovement

Route207_Movement_Unused:
    Delay8 8
    WalkOnSpotNormalWest
    EndMovement

Route207_Movement_Unused2:
    Delay8 1
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
Route207_Movement_CounterpartNoticePlayer:
    WalkNormalEast 3
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route207_Movement_CounterpartWalkToPlayer:
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
Route207_Movement_CounterpartLeave:
    WalkNormalWest 8
    EndMovement

Route207_Dummy3:
    NPCMessage Route207_Text_Dummy8
    End

Route207_CyclistM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_RECEIVED_BICYCLE, Route207_ChangeGearTakeARun
    Message Route207_Text_ThatSlopesTooSlippery
    WaitButton
    CloseMessage
    ReleaseAll
    End

@ Sovereign (E10, Renegade): Mom gives the Bicycle (E10 part 11), so this cyclist blocks the slope's foot with
@ Renegade's broken-bike lines until the Cycle Shop manager is rescued in Eterna City (his hidden flag).
Route207_ChangeGearTakeARun:
    Message Route207_Text_SovereignBikeBroken
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route207_ArrowSignpostMtCoronet:
    ShowArrowSign Route207_Text_SignMtCoronet
    End

Route207_ArrowSignpostOreburghCity:
    ShowArrowSign Route207_Text_SignOreburghCity
    End

Route207_TrainerTipsSignpost:
    ShowScrollingSign Route207_Text_TrainerTipsImmobilizedIfAsleepOrParalyzed
    End

    

@ Sovereign (E10, Renegade's Type Masters): the Rock-type Master battles one Rock-type Pokémon, alone in the party, for
@ the Stone Plate (Renegade's trainer 1042).
Route207_SovereignRockMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_ROCK_MASTER, Route207_SovereignRockMasterThanks
    Message Route207_Text_SovereignRockMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, Route207_SovereignRockMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_ROCK, Route207_SovereignRockMasterAsk
    GoToIfEq VAR_0x8005, TYPE_ROCK, Route207_SovereignRockMasterAsk
Route207_SovereignRockMasterOnlyOne:
    Message Route207_Text_SovereignRockMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route207_SovereignRockMasterAsk:
    Message Route207_Text_SovereignRockMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route207_SovereignRockMasterDecline
    Message Route207_Text_SovereignRockMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_ROCK_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route207_SovereignRockMasterLost
    Message Route207_Text_SovereignRockMasterWin
    SetVar VAR_0x8004, ITEM_STONE_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_ROCK_MASTER
Route207_SovereignRockMasterThanks:
    Message Route207_Text_SovereignRockMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route207_SovereignRockMasterDecline:
    Message Route207_Text_SovereignRockMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route207_SovereignRockMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message Route207_Text_SovereignRockMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
