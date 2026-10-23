#include "macros/scrcmd.inc"
#include "res/text/bank/oreburgh_mine_b1f.h"
#include "res/field/events/events_oreburgh_mine_b1f.h"


    ScriptEntry OreburghMineB1F_OnTransition
    ScriptEntry OreburghMineB1F_Worker
    ScriptEntry OreburghMineB1F_Twin
    ScriptEntry OreburghMineB1F_Hiker
    ScriptEntry OreburghMineB1F_SovereignOnLoad
    ScriptEntry OreburghMineB1F_LegendaryMeltan
    ScriptEntry OreburghMineB1F_LegendaryMelmetal
    ScriptEntryEnd

OreburghMineB1F_OnTransition:
    Call OreburghMineB1F_SovereignSetMelmetalVisibility
    Call OreburghMineB1F_SovereignSetMeltanVisibility
    SetFlag FLAG_FIRST_ARRIVAL_OREBURGH_MINE
    SetFlag FLAG_HIDE_OREBURGH_MINE_B1F_HIKER
    CallIfEq VAR_ARCEUS_EVENT_STATE, 1, OreburghMineB1F_ShowHiker
    End

OreburghMineB1F_ShowHiker:
    ClearFlag FLAG_HIDE_OREBURGH_MINE_B1F_HIKER
    Return

OreburghMineB1F_Worker:
    NPCMessage OreburghMineB1F_Text_EveryoneKeepsTheirOwnPokemon
    End

OreburghMineB1F_Twin:
    NPCMessage OreburghMineB1F_Text_SomeRocksStartedMoving
    End

OreburghMineB1F_Hiker:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_COULD_NOT_RECEIVE_OREBURGH_MINE_B1F_FLAME_PLATE, OreburghMineB1F_TryGiveFlamePlateAgain
    Message OreburghMineB1F_Text_IFoundSomethingInteresting
    GoTo OreburghMineB1F_TryGiveFlamePlate
    End

OreburghMineB1F_TryGiveFlamePlate:
    SetVar VAR_0x8004, ITEM_FLAME_PLATE
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, OreburghMineB1F_YouHaveAnOverabundance
    Common_GiveItemQuantity
    Message OreburghMineB1F_Text_CreatedAtSameTimeAsSinnoh
    CloseMessage
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8005, 3, OreburghMineB1F_HikerLeaveZ3
    GoToIfEq VAR_0x8005, 4, OreburghMineB1F_HikerLeaveZ4
    GoToIfEq VAR_0x8005, 5, OreburghMineB1F_HikerLeaveZ5
    End

OreburghMineB1F_HikerLeaveZ3:
    ApplyMovement LOCALID_HIKER, OreburghMineB1F_Movement_HikerLeaveZ3
    WaitMovement
    GoTo OreburghMineB1F_RemoveHiker
    End

OreburghMineB1F_HikerLeaveZ4:
    ApplyMovement LOCALID_HIKER, OreburghMineB1F_Movement_HikerLeaveZ4Or5
    WaitMovement
    GoTo OreburghMineB1F_RemoveHiker
    End

OreburghMineB1F_HikerLeaveZ5:
    ApplyMovement LOCALID_HIKER, OreburghMineB1F_Movement_HikerLeaveZ4Or5
    WaitMovement
    GoTo OreburghMineB1F_RemoveHiker
    End

OreburghMineB1F_RemoveHiker:
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    RemoveObject LOCALID_HIKER
    SetVar VAR_ARCEUS_EVENT_STATE, 2
    ReleaseAll
    End

OreburghMineB1F_YouHaveAnOverabundance:
    SetFlag FLAG_COULD_NOT_RECEIVE_OREBURGH_MINE_B1F_FLAME_PLATE
    Message OreburghMineB1F_Text_YouHaveAnOverabundance
    GoTo OreburghMineB1F_HikerEnd
    End

OreburghMineB1F_HikerEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

OreburghMineB1F_TryGiveFlamePlateAgain:
    Message OreburghMineB1F_Text_YouMayHaveItIfYoudLike
    GoTo OreburghMineB1F_TryGiveFlamePlate
    End

    .balign 4, 0
OreburghMineB1F_Movement_HikerLeaveZ3:
    WalkNormalWest
    WalkNormalNorth 3
    EndMovement

    .balign 4, 0
OreburghMineB1F_Movement_HikerLeaveZ4Or5:
    WalkNormalNorth 3
    EndMovement

OreburghMineB1F_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, OreburghMineB1F_RemoveLegendaryMelmetal
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, OreburghMineB1F_RemoveLegendaryMeltan
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Meltan waits among the ore once the Alola Chronicle is
@ open, until it is caught.
OreburghMineB1F_SovereignSetMeltanVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, OreburghMineB1F_SovereignSetMeltanVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MELTAN, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, OreburghMineB1F_SovereignSetMeltanVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
OreburghMineB1F_SovereignSetMeltanVisibilityEnd:
    Return

OreburghMineB1F_RemoveLegendaryMeltan:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_MELTAN, OreburghMineB1F_RemoveLegendaryMeltanEnd
    RemoveObject LOCALID_LEGENDARY_MELTAN
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
OreburghMineB1F_RemoveLegendaryMeltanEnd:
    Return

OreburghMineB1F_LegendaryMeltan:
    SetVar VAR_0x8004, SPECIES_MELTAN
    SetVar VAR_0x8005, 40
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Melmetal appears once Meltan is caught, until it is caught.
OreburghMineB1F_SovereignSetMelmetalVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, OreburghMineB1F_SovereignSetMelmetalVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MELTAN, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, OreburghMineB1F_SovereignSetMelmetalVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MELMETAL, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, OreburghMineB1F_SovereignSetMelmetalVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
OreburghMineB1F_SovereignSetMelmetalVisibilityEnd:
    Return

OreburghMineB1F_RemoveLegendaryMelmetal:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_MELMETAL, OreburghMineB1F_RemoveLegendaryMelmetalEnd
    RemoveObject LOCALID_LEGENDARY_MELMETAL
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
OreburghMineB1F_RemoveLegendaryMelmetalEnd:
    Return

OreburghMineB1F_LegendaryMelmetal:
    SetVar VAR_0x8004, SPECIES_MELMETAL
    SetVar VAR_0x8005, 50
    Common_SovereignLegendaryEncounter
    End
