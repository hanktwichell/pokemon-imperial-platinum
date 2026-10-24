#include "macros/scrcmd.inc"
#include "res/text/bank/route_217_west_house.h"


    ScriptEntry Route217WestHouse_Hiker
    ScriptEntryEnd

@ Sovereign (E10 part 26): as in Renegade, Candice gives HM08 in the Snowpoint Temple, and this hiker lets the
@ player rest (Platinum: the Icicle Plate for finding the HM; the Ice-type Master gives it now).
Route217WestHouse_Hiker:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message Route217WestHouse_Text_SovereignTakeSomeRest
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Message Route217WestHouse_Text_SovereignKeepWarm
    WaitButton
    CloseMessage
    ReleaseAll
    End
