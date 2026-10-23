#include "macros/scrcmd.inc"
#include "res/text/bank/oreburgh_mine_b2f.h"
#include "res/field/events/events_oreburgh_mine_b2f.h"


    ScriptEntry OreburghMineB2F_Roark
    ScriptEntry OreburghMineB2F_Machop1
    ScriptEntry OreburghMineB2F_Machop3
    ScriptEntry OreburghMineB2F_Machop2
    ScriptEntry OreburghMineB2F_Worker
    ScriptEntry OreburghMineB2F_OnTransition
    ScriptEntry OreburghMineB2F_OnLoad
    ScriptEntry OreburghMineB2F_LegendaryDiancie
    ScriptEntry OreburghMineB2F_LegendaryMeltan
    ScriptEntry OreburghMineB2F_LegendaryMelmetal
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Diancie shines in the nook by the mine's west wall once the
@ Kalos Chronicle is open (VAR_SOVEREIGN_CHRONICLE 2) and a Carbink is in the party, until it's caught.
OreburghMineB2F_OnTransition:
    Call OreburghMineB2F_SovereignSetMelmetalVisibility
    Call OreburghMineB2F_SovereignSetMeltanVisibility
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 2, OreburghMineB2F_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_DIANCIE, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, OreburghMineB2F_OnTransitionEnd
    CheckPartyHasSpecies VAR_RESULT, SPECIES_CARBINK
    GoToIfEq VAR_RESULT, FALSE, OreburghMineB2F_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
OreburghMineB2F_OnTransitionEnd:
    End

OreburghMineB2F_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, OreburghMineB2F_RemoveLegendaryMelmetal
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, OreburghMineB2F_RemoveLegendaryMeltan
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, OreburghMineB2F_RemoveLegendaryDiancie
    End

OreburghMineB2F_RemoveLegendaryDiancie:
    RemoveObject LOCALID_LEGENDARY_DIANCIE
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

OreburghMineB2F_LegendaryDiancie:
    SetVar VAR_0x8004, SPECIES_DIANCIE
    SetVar VAR_0x8005, 55
    Common_SovereignLegendaryEncounter
    End

OreburghMineB2F_Roark:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoTo OreburghMineB2F_RoarkTurnBackEast

OreburghMineB2F_Unused:
    ApplyMovement LOCALID_ROARK, OreburghMineB2F_Movement_Unused2
    WaitMovement
    GoTo OreburghMineB2F_RoarkUseRockSmash

OreburghMineB2F_RoarkTurnBackEast:
    ApplyMovement LOCALID_ROARK, OreburghMineB2F_Movement_RoarkTurnBackEast
    WaitMovement
    GoTo OreburghMineB2F_RoarkUseRockSmash

OreburghMineB2F_RoarkUseRockSmash:
    Message OreburghMineB2F_Text_StandBackAndWatch
    CloseMessage
    StartDestroyObstacleAnimation 2, VAR_0x8005
    WaitTime 10, VAR_RESULT
    RemoveObject LOCALID_ROCK_SMASH_1
OreburghMineB2F_WaitRockSmash:
    WaitTime 1, VAR_RESULT
    GoToIfEq VAR_0x8005, 0, OreburghMineB2F_WaitRockSmash
    FacePlayer
    Message OreburghMineB2F_Text_BouldersNeedToBeSmashed
    CloseMessage
    GoTo OreburghMineB2F_RoarkLeave

OreburghMineB2F_Unused2:
    ApplyMovement LOCALID_ROARK, OreburghMineB2F_Movement_Unused
    ApplyMovement LOCALID_PLAYER, OreburghMineB2F_Movement_Unused3
    WaitMovement
    GoTo OreburghMineB2F_RemoveRoark

OreburghMineB2F_RoarkLeave:
    ApplyMovement LOCALID_ROARK, OreburghMineB2F_Movement_RoarkLeave
    WaitMovement
    GoTo OreburghMineB2F_RemoveRoark

OreburghMineB2F_RemoveRoark:
    RemoveObject LOCALID_ROARK
    SetFlag FLAG_ROARK_RETURNED_TO_OREBURGH_GYM
    SetFlag FLAG_HIDE_OREBURGH_CITY_RIVAL
    ReleaseAll
    End

    .balign 4, 0
OreburghMineB2F_Movement_Unused:
    WalkNormalNorth
    WalkNormalEast 10
    EndMovement

    .balign 4, 0
OreburghMineB2F_Movement_RoarkLeave:
    WalkNormalEast 10
    EndMovement

OreburghMineB2F_Movement_Unused2:
    Delay8 2
    WalkOnSpotNormalNorth
    Delay8 4
    EndMovement

    .balign 4, 0
OreburghMineB2F_Movement_RoarkTurnBackEast:
    Delay8 2
    WalkOnSpotNormalEast
    Delay8 4
    EndMovement

OreburghMineB2F_Movement_Unused3:
    Delay8
    WalkOnSpotNormalNorth
    Delay8 2
    WalkOnSpotNormalEast
    EndMovement

OreburghMineB2F_Machop1:
    PokemonCryAndMessage SPECIES_MACHOP, OreburghMineB2F_Text_MachopCryMaaacho
    End

OreburghMineB2F_Machop3:
    PokemonCryAndMessage SPECIES_MACHOP, OreburghMineB2F_Text_MachopCryChopChop
    End

OreburghMineB2F_Machop2:
    PokemonCryAndMessage SPECIES_MACHOP, OreburghMineB2F_Text_MachopCryChopmacho
    End

OreburghMineB2F_Worker:
    NPCMessage OreburghMineB2F_Text_IMetMachopOnRoute207
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Meltan waits among the ore once the Alola Chronicle is
@ open, until it is caught.
OreburghMineB2F_SovereignSetMeltanVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, OreburghMineB2F_SovereignSetMeltanVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MELTAN, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, OreburghMineB2F_SovereignSetMeltanVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
OreburghMineB2F_SovereignSetMeltanVisibilityEnd:
    Return

OreburghMineB2F_RemoveLegendaryMeltan:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_MELTAN, OreburghMineB2F_RemoveLegendaryMeltanEnd
    RemoveObject LOCALID_LEGENDARY_MELTAN
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
OreburghMineB2F_RemoveLegendaryMeltanEnd:
    Return

OreburghMineB2F_LegendaryMeltan:
    SetVar VAR_0x8004, SPECIES_MELTAN
    SetVar VAR_0x8005, 40
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Melmetal appears once Meltan is caught, until it is caught.
OreburghMineB2F_SovereignSetMelmetalVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, OreburghMineB2F_SovereignSetMelmetalVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MELTAN, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, OreburghMineB2F_SovereignSetMelmetalVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MELMETAL, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, OreburghMineB2F_SovereignSetMelmetalVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
OreburghMineB2F_SovereignSetMelmetalVisibilityEnd:
    Return

OreburghMineB2F_RemoveLegendaryMelmetal:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_MELMETAL, OreburghMineB2F_RemoveLegendaryMelmetalEnd
    RemoveObject LOCALID_LEGENDARY_MELMETAL
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
OreburghMineB2F_RemoveLegendaryMelmetalEnd:
    Return

OreburghMineB2F_LegendaryMelmetal:
    SetVar VAR_0x8004, SPECIES_MELMETAL
    SetVar VAR_0x8005, 50
    Common_SovereignLegendaryEncounter
    End
