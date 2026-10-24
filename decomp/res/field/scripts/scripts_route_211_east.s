#include "macros/scrcmd.inc"
#include "res/field/events/events_route_211_east.h"
#include "res/text/bank/route_211_east.h"


    ScriptEntry Route211East_AceTrainerM
    ScriptEntry Route211East_ArrowSignpostMtCoronet
    ScriptEntry Route211East_TrainerTipsSignpost
    ScriptEntry Route211East_ArrowSignpostCelesticTown
    ScriptEntry Route211East_SovereignOnTransition
    ScriptEntry Route211East_SovereignOnLoad
    ScriptEntry Route211East_LegendaryOgerpon
    ScriptEntry Route211East_LegendaryEntei
    ScriptEntryEnd

Route211East_AceTrainerM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GoToIfSet FLAG_RECEIVED_ROUTE_211_EAST_TM77, Route211East_ExplainPsychUp
    Message Route211East_Text_ImStrong
    CloseMessage
    FacePlayer
    ApplyMovement VAR_LAST_TALKED, Route211East_Movement_ExclamationMark
    WaitMovement
    Message Route211East_Text_YouStartledMe
    SetVar VAR_0x8004, ITEM_TM77
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route211East_BagIsFull
    Common_GiveItemQuantity
    SetFlag FLAG_RECEIVED_ROUTE_211_EAST_TM77
    GoTo Route211East_ExplainPsychUp

Route211East_ExplainPsychUp:
    FacePlayer
    Message Route211East_Text_ExplainPsychUp
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route211East_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
Route211East_Movement_ExclamationMark:
    EmoteExclamationMark
    EndMovement

Route211East_ArrowSignpostMtCoronet:
    ShowArrowSign Route211East_Text_SignMtCoronet
    End

Route211East_TrainerTipsSignpost:
    ShowScrollingSign Route211East_Text_TrainerTipsCheckSupply
    End

Route211East_ArrowSignpostCelesticTown:
    ShowArrowSign Route211East_Text_SignCelesticTown
    End

    .balign 4, 0

Route211East_SovereignOnTransition:
    Call Route211East_SovereignSetOgerponVisibility
    Call Route211East_SovereignSetEnteiVisibility
    End

Route211East_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route211East_RemoveLegendaryOgerpon
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route211East_RemoveLegendaryEntei
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Ogerpon, wearing the Teal Mask, waits by the mountain path
@ once the Paldea Chronicle is open, until it is caught.
Route211East_SovereignSetOgerponVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route211East_SovereignSetOgerponVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_OGERPON, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route211East_SovereignSetOgerponVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route211East_SovereignSetOgerponVisibilityEnd:
    Return

Route211East_RemoveLegendaryOgerpon:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_OGERPON, Route211East_RemoveLegendaryOgerponEnd
    RemoveObject LOCALID_LEGENDARY_OGERPON
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route211East_RemoveLegendaryOgerponEnd:
    Return

Route211East_LegendaryOgerpon:
    SetVar VAR_SOVEREIGN_LEGENDARY_HELD_ITEM, ITEM_TEAL_MASK
    SetVar VAR_0x8004, SPECIES_OGERPON
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (E10, Renegade's legendary events): Entei at the end of the Rock Climb ledge, after the Distortion World, until it is caught (Renegade: Lv. 60, a portal here, where Platinum had TM29).
Route211East_SovereignSetEnteiVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfUnset FLAG_DEFEATED_TRAINER_GALACTIC_BOSS_CYRUS_DISTORTION_WORLD, Route211East_SovereignSetEnteiVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ENTEI, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route211East_SovereignSetEnteiVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
Route211East_SovereignSetEnteiVisibilityEnd:
    Return

Route211East_RemoveLegendaryEntei:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_ENTEI, Route211East_RemoveLegendaryEnteiEnd
    RemoveObject LOCALID_LEGENDARY_ENTEI
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route211East_RemoveLegendaryEnteiEnd:
    Return

Route211East_LegendaryEntei:
    SetVar VAR_0x8004, SPECIES_ENTEI
    SetVar VAR_0x8005, 60
    Common_SovereignLegendaryEncounter
    End
