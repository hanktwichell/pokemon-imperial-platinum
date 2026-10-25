#include "macros/scrcmd.inc"
#include "res/text/bank/route_215.h"
#include "res/field/events/events_route_215.h"


    ScriptEntry Route215_Dummy1
    ScriptEntry Route215_BlackBelt
    ScriptEntry Route215_ArrowSignpostWest
    ScriptEntry Route215_ArrowSignpostVeilstoneCity
    ScriptEntry Route215_JoggerScott
    ScriptEntry Route215_JoggerCraig
    ScriptEntry Route215_OnTransition
    ScriptEntry Route215_TrainerTipsSignpost
    ScriptEntry Route215_OnLoad
    ScriptEntry Route215_LegendaryZekrom
    ScriptEntryEnd

Route215_OnTransition:
    Call Route215_SovereignSetZekromVisibility
    GetTimeOfDay VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, TIMEOFDAY_MORNING, Route215_SetJoggersBattle
    GoToIfInRange VAR_MAP_LOCAL_0x00, TIMEOFDAY_DAY, TIMEOFDAY_LATE_NIGHT, Route215_SetJoggersNoBattle
    End

Route215_SetJoggersBattle:
    ClearFlag FLAG_HIDE_ROUTE_215_JOGGER_SCOTT
    ClearFlag FLAG_HIDE_ROUTE_215_JOGGER_CRAIG
    SetFlag FLAG_HIDE_ROUTE_215_JOGGER_SCOTT_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_215_JOGGER_CRAIG_NO_BATTLE
    End

Route215_SetJoggersNoBattle:
    ClearFlag FLAG_HIDE_ROUTE_215_JOGGER_SCOTT_NO_BATTLE
    ClearFlag FLAG_HIDE_ROUTE_215_JOGGER_CRAIG_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_215_JOGGER_SCOTT
    SetFlag FLAG_HIDE_ROUTE_215_JOGGER_CRAIG
    End

Route215_Dummy1:
    NPCMessage Route215_Text_Dummy0
    End

Route215_BlackBelt:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_RECEIVED_ROUTE_215_TM66, Route215_PaybackIsHarsh
    Message Route215_Text_YupItsPayback
    SetVar VAR_0x8004, ITEM_TM66
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route215_BagIsFull
    Common_GiveItemQuantity
    SetFlag FLAG_RECEIVED_ROUTE_215_TM66
    GoTo Route215_PaybackIsHarsh

Route215_PaybackIsHarsh:
    Message Route215_Text_PaybackIsHarsh
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route215_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

Route215_ArrowSignpostWest:
    ShowArrowSign Route215_Text_SignCelesticTownSolaceonTown
    End

Route215_ArrowSignpostVeilstoneCity:
    ShowArrowSign Route215_Text_SignVeilstoneCity
    End

Route215_TrainerTipsSignpost:
    ShowScrollingSign Route215_Text_TrainerTipsPhysicalSpecial
    End

Route215_JoggerScott:
    NPCMessage Route215_Text_DontOverdoIt
    End

Route215_JoggerCraig:
    NPCMessage Route215_Text_ImOnlyHuman
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md; decision 34): Zekrom stands in the rain on the north-west
@ loop, north of the pillar, at night (8 pm to 4 am) while the player carries the Dark Stone (the Legend Archivist
@ gives it), until it's caught. It stood on Valley Windworks' island before decision 34 gave that to Zapdos.
Route215_SovereignSetZekromVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    CheckItem ITEM_DARK_STONE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route215_SovereignSetZekromVisibilityEnd
    GetTimeOfDay VAR_RESULT
    GoToIfLt VAR_RESULT, TIMEOFDAY_NIGHT, Route215_SovereignSetZekromVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZEKROM, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route215_SovereignSetZekromVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route215_SovereignSetZekromVisibilityEnd:
    Return

Route215_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route215_RemoveLegendaryZekrom
    End

Route215_RemoveLegendaryZekrom:
    RemoveObject LOCALID_LEGENDARY_ZEKROM
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route215_LegendaryZekrom:
    LockAll
    Message Route215_Text_SovereignDarkStoneCrackles
    WaitButton
    CloseMessage
    ReleaseAll
    SetVar VAR_0x8004, SPECIES_ZEKROM
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

    .balign 4, 0
