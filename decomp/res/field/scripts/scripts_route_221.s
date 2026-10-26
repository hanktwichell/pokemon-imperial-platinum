#include "macros/scrcmd.inc"
#include "res/text/bank/route_221.h"


    ScriptEntry Route221_WorkerWest
    ScriptEntry Route221_WorkerEast
    ScriptEntry Route221_SignboardPalPark
    ScriptEntry Route221_OnTransition
    ScriptEntry Route221_SovereignNurse
    ScriptEntryEnd

@ Sovereign (decision 47, as in Renegade): the lobby is open mid-game, for Darach and the Tea that Route 218's gate
@ asks for. The park itself waits for the Hall of Fame (the lobby worker), so the workers no longer stand at the door.
Route221_OnTransition:
    SetFlag FLAG_HIDE_ROUTE_221_WORKER_WEST
    SetFlag FLAG_HIDE_ROUTE_221_WORKER_EAST
    End

Route221_WorkerWest:
    NPCMessage Route221_Text_PalParkIsntOpenYet
    End

Route221_WorkerEast:
    NPCMessage Route221_Text_GettingPalParkReady
    End

Route221_SignboardPalPark:
    ShowLandmarkSign Route221_Text_SignPalPark
    End

@ Sovereign (E10, Renegade): a nurse on Route 221 heals the party.
Route221_SovereignNurse:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message Route221_Text_SovereignNurseHeal
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Message Route221_Text_SovereignNurseEnjoyPark
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
