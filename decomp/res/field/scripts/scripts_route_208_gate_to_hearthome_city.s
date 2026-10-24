#include "macros/scrcmd.inc"
#include "res/text/bank/route_208_gate_to_hearthome_city.h"
#include "res/field/events/events_route_208_gate_to_hearthome_city.h"

// Sovereign (E10): Renegade Platinum's gate. The first time the player walks through, Aaron of the Elite Four comes in
// from Route 208, heals the party, battles (an unofficial battle: losing is fine) and gives TM81 (X-Scissor). The gate's
// Pokémon Breeder, woman and Clefairy are gone, as in Renegade.

    ScriptEntry Route208GateToHearthomeCity_TriggerAaron
    ScriptEntryEnd

Route208GateToHearthomeCity_TriggerAaron:
    LockAll
    RemoveObject LOCALID_AARON
    SetObjectEventPos LOCALID_AARON, 1, 7
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    AddObject LOCALID_AARON
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    LockObject LOCALID_AARON
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8005, 5, Route208GateToHearthomeCity_AaronWalkToPlayerZ5
    GoToIfEq VAR_0x8005, 6, Route208GateToHearthomeCity_AaronWalkToPlayerZ6
    GoToIfEq VAR_0x8005, 8, Route208GateToHearthomeCity_AaronWalkToPlayerZ8
    GoToIfEq VAR_0x8005, 9, Route208GateToHearthomeCity_AaronWalkToPlayerZ9
    ApplyMovement LOCALID_AARON, Route208GateToHearthomeCity_Movement_AaronWalkToPlayerZ7
    WaitMovement
    GoTo Route208GateToHearthomeCity_AaronHealsParty

Route208GateToHearthomeCity_AaronWalkToPlayerZ5:
    ApplyMovement LOCALID_AARON, Route208GateToHearthomeCity_Movement_AaronWalkToPlayerZ5
    WaitMovement
    GoTo Route208GateToHearthomeCity_AaronHealsParty

Route208GateToHearthomeCity_AaronWalkToPlayerZ6:
    ApplyMovement LOCALID_AARON, Route208GateToHearthomeCity_Movement_AaronWalkToPlayerZ6
    WaitMovement
    GoTo Route208GateToHearthomeCity_AaronHealsParty

Route208GateToHearthomeCity_AaronWalkToPlayerZ8:
    ApplyMovement LOCALID_AARON, Route208GateToHearthomeCity_Movement_AaronWalkToPlayerZ8
    WaitMovement
    GoTo Route208GateToHearthomeCity_AaronHealsParty

Route208GateToHearthomeCity_AaronWalkToPlayerZ9:
    ApplyMovement LOCALID_AARON, Route208GateToHearthomeCity_Movement_AaronWalkToPlayerZ9
    WaitMovement
Route208GateToHearthomeCity_AaronHealsParty:
    ApplyMovement LOCALID_PLAYER, Route208GateToHearthomeCity_Movement_PlayerFaceWest
    WaitMovement
    Message Route208GateToHearthomeCity_Text_SovereignLetMeHealThem
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    BufferPlayerName 0
    Message Route208GateToHearthomeCity_Text_SovereignImAaron
Route208GateToHearthomeCity_AskForBattle:
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, Route208GateToHearthomeCity_BattleAaron
    Message Route208GateToHearthomeCity_Text_SovereignIdReconsider
    GoTo Route208GateToHearthomeCity_AskForBattle

Route208GateToHearthomeCity_BattleAaron:
    Message Route208GateToHearthomeCity_Text_SovereignHereComeMyPartners
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_AARON_ROUTE_208
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route208GateToHearthomeCity_LostToAaron
    LockAll
    Message Route208GateToHearthomeCity_Text_SovereignTrainedSeriouslyWell
    GoTo Route208GateToHearthomeCity_AaronGivesTM81

Route208GateToHearthomeCity_LostToAaron:
    ReturnToField
    LockAll
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message Route208GateToHearthomeCity_Text_SovereignThatWasFun
Route208GateToHearthomeCity_AaronGivesTM81:
    Message Route208GateToHearthomeCity_Text_SovereignTMForListening
    SetVar VAR_0x8004, ITEM_TM81
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Message Route208GateToHearthomeCity_Text_SovereignSeeYouAnotherTime
    CloseMessage
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8005, 5, Route208GateToHearthomeCity_AaronLeaveZ5
    GoToIfEq VAR_0x8005, 6, Route208GateToHearthomeCity_AaronLeaveZ6
    GoToIfEq VAR_0x8005, 8, Route208GateToHearthomeCity_AaronLeaveZ8
    GoToIfEq VAR_0x8005, 9, Route208GateToHearthomeCity_AaronLeaveZ9
    ApplyMovement LOCALID_AARON, Route208GateToHearthomeCity_Movement_AaronLeaveZ7
    WaitMovement
    GoTo Route208GateToHearthomeCity_RemoveAaron

Route208GateToHearthomeCity_AaronLeaveZ5:
    ApplyMovement LOCALID_AARON, Route208GateToHearthomeCity_Movement_AaronLeaveZ5
    WaitMovement
    GoTo Route208GateToHearthomeCity_RemoveAaron

Route208GateToHearthomeCity_AaronLeaveZ6:
    ApplyMovement LOCALID_AARON, Route208GateToHearthomeCity_Movement_AaronLeaveZ6
    WaitMovement
    GoTo Route208GateToHearthomeCity_RemoveAaron

Route208GateToHearthomeCity_AaronLeaveZ8:
    ApplyMovement LOCALID_AARON, Route208GateToHearthomeCity_Movement_AaronLeaveZ8
    WaitMovement
    GoTo Route208GateToHearthomeCity_RemoveAaron

Route208GateToHearthomeCity_AaronLeaveZ9:
    ApplyMovement LOCALID_AARON, Route208GateToHearthomeCity_Movement_AaronLeaveZ9
    WaitMovement
Route208GateToHearthomeCity_RemoveAaron:
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_AARON
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    SetVar VAR_SOVEREIGN_ROUTE_208_GATE_AARON_STATE, 1
    ReleaseAll
    End

    .balign 4, 0
Route208GateToHearthomeCity_Movement_AaronWalkToPlayerZ5:
    WalkNormalEast
    WalkNormalNorth 2
    WalkNormalEast 3
    EndMovement

    .balign 4, 0
Route208GateToHearthomeCity_Movement_AaronWalkToPlayerZ6:
    WalkNormalEast
    WalkNormalNorth
    WalkNormalEast 3
    EndMovement

    .balign 4, 0
Route208GateToHearthomeCity_Movement_AaronWalkToPlayerZ7:
    WalkNormalEast 4
    EndMovement

    .balign 4, 0
Route208GateToHearthomeCity_Movement_AaronWalkToPlayerZ8:
    WalkNormalEast
    WalkNormalSouth
    WalkNormalEast 3
    EndMovement

    .balign 4, 0
Route208GateToHearthomeCity_Movement_AaronWalkToPlayerZ9:
    WalkNormalEast
    WalkNormalSouth 2
    WalkNormalEast 3
    EndMovement

    .balign 4, 0
Route208GateToHearthomeCity_Movement_PlayerFaceWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
Route208GateToHearthomeCity_Movement_AaronLeaveZ5:
    WalkNormalWest
    WalkNormalSouth 2
    WalkNormalWest 3
    EndMovement

    .balign 4, 0
Route208GateToHearthomeCity_Movement_AaronLeaveZ6:
    WalkNormalWest
    WalkNormalSouth
    WalkNormalWest 3
    EndMovement

    .balign 4, 0
Route208GateToHearthomeCity_Movement_AaronLeaveZ7:
    WalkNormalWest 4
    EndMovement

    .balign 4, 0
Route208GateToHearthomeCity_Movement_AaronLeaveZ8:
    WalkNormalWest
    WalkNormalNorth
    WalkNormalWest 3
    EndMovement

    .balign 4, 0
Route208GateToHearthomeCity_Movement_AaronLeaveZ9:
    WalkNormalWest
    WalkNormalNorth 2
    WalkNormalWest 3
    EndMovement
