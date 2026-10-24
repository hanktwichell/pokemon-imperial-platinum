#include "macros/scrcmd.inc"
#include "res/text/bank/stark_mountain_room_1.h"
#include "res/field/events/events_stark_mountain_room_1.h"


    ScriptEntry StarkMountainOutside_OnTransition
    ScriptEntry StarkMountainOutside_OnFrame_TeamGalactic
    ScriptEntry StarkMountainRoom1_OnLoad
    ScriptEntry StarkMountainRoom1_LegendaryVolcanion
    ScriptEntry StarkMountainRoom1_LegendaryGroudon
    ScriptEntryEnd

StarkMountainOutside_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_STARK_MOUNTAIN_INTERIOR
    SetFlag FLAG_HIDE_ROUTE_227_BUCK
    Call StarkMountainRoom1_SovereignSetVolcanionVisibility
    Call StarkMountainRoom1_SovereignSetGroudonVisibility
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Volcanion stands at the end of this cave's long east
@ tunnel once the Kalos Chronicle is open (VAR_SOVEREIGN_CHRONICLE 2), until it's caught.
StarkMountainRoom1_SovereignSetVolcanionVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 2, StarkMountainRoom1_SovereignSetVolcanionVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_VOLCANION, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, StarkMountainRoom1_SovereignSetVolcanionVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
StarkMountainRoom1_SovereignSetVolcanionVisibilityEnd:
    Return

StarkMountainRoom1_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, StarkMountainRoom1_RemoveLegendaryGroudon
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, StarkMountainRoom1_RemoveLegendaryVolcanion
    End

StarkMountainRoom1_RemoveLegendaryVolcanion:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_VOLCANION, StarkMountainRoom1_RemoveLegendaryVolcanionEnd
    RemoveObject LOCALID_LEGENDARY_VOLCANION
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
StarkMountainRoom1_RemoveLegendaryVolcanionEnd:
    End

StarkMountainRoom1_LegendaryVolcanion:
    SetVar VAR_0x8004, SPECIES_VOLCANION
    SetVar VAR_0x8005, 60
    Common_SovereignLegendaryEncounter
    End

StarkMountainOutside_OnFrame_TeamGalactic:
    LockAll
    ApplyMovement LOCALID_MARS, StarkMountainRoom1_Movement_MarsWalkOnSpotSouth
    WaitMovement
    Message StarkMountainRoom1_Text_IllMakeYouTalk
    CloseMessage
    ApplyMovement LOCALID_MARS, StarkMountainRoom1_Movement_MarsWalkSouth
    WaitMovement
    StartTrainerBattle TRAINER_COMMANDER_MARS_STARK_MOUNTAIN
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, StarkMountainRoom1_LostBattle
    Message StarkMountainRoom1_Text_PokemonLetMeDown
    CloseMessage
    ApplyMovement LOCALID_MARS, StarkMountainRoom1_Movement_MarsWalkBack
    WaitMovement
    ApplyMovement LOCALID_JUPITER, StarkMountainRoom1_Movement_JupiterWalkOnSpotWestSouth
    WaitMovement
    Message StarkMountainRoom1_Text_IllGoUpNext
    CloseMessage
    ApplyMovement LOCALID_JUPITER, StarkMountainRoom1_Movement_JupiterWalkSouth
    WaitMovement
    StartTrainerBattle TRAINER_COMMANDER_JUPITER_STARK_MOUNTAIN
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, StarkMountainRoom1_LostBattle
    Message StarkMountainRoom1_Text_HowDareYou
    CloseMessage
    WaitTime 15, VAR_RESULT
    ApplyMovement LOCALID_MARS, StarkMountainRoom1_Movement_MarsExclamationMark
    ApplyMovement LOCALID_JUPITER, StarkMountainRoom1_Movement_JupiterFaceMars
    WaitMovement
    Message StarkMountainRoom1_Text_ThatsItForMe
    ApplyMovement LOCALID_JUPITER, StarkMountainRoom1_Movement_JupiterWalkOnSpotNorth
    WaitMovement
    Message StarkMountainRoom1_Text_ImQuittingToo
    CloseMessage
    ApplyMovement LOCALID_MARS, StarkMountainRoom1_Movement_MarsWalkOnSpotNorthSouth
    WaitMovement
    Message StarkMountainRoom1_Text_BackToOrdinaryGirls
    CloseMessage
    ApplyMovement LOCALID_MARS, StarkMountainRoom1_Movement_MarsLeave
    ApplyMovement LOCALID_PLAYER, StarkMountainRoom1_Movement_PlayerMoveAside
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_JUPITER, StarkMountainRoom1_Movement_JupiterWalkOnSpotEast
    WaitMovement
    Message StarkMountainRoom1_Text_NotOrdinaryGirl
    CloseMessage
    ApplyMovement LOCALID_JUPITER, StarkMountainRoom1_Movement_JupiterLeave
    WaitMovement
    PlaySE SEQ_SE_DP_KAIDAN2_sseq
    WaitSE SEQ_SE_DP_KAIDAN2_sseq
    ApplyMovement LOCALID_CHARON, StarkMountainRoom1_Movement_CharonWalkOnSpotSouth
    ApplyMovement LOCALID_PLAYER, StarkMountainRoom1_Movement_PlayerWalkOnSpotNorth
    WaitMovement
    Message StarkMountainRoom1_Text_ImpressionableAndImpetuous
    Message StarkMountainRoom1_Text_OffToCollectMagmaStone
    CloseMessage
    ApplyMovement LOCALID_CHARON, StarkMountainRoom1_Movement_CharonLeave
    ApplyMovement LOCALID_GRUNT_M_1, StarkMountainRoom1_Movement_GruntM1Leave
    ApplyMovement LOCALID_GRUNT_M_2, StarkMountainRoom1_Movement_GruntM2Leave
    WaitMovement
    RemoveObject LOCALID_CHARON
    RemoveObject LOCALID_MARS
    RemoveObject LOCALID_JUPITER
    RemoveObject LOCALID_GRUNT_M_1
    RemoveObject LOCALID_GRUNT_M_2
    SetVar VAR_STARK_MOUNTAIN_ROOM_1_STATE, 1
    ReleaseAll
    End

StarkMountainRoom1_LostBattle:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
StarkMountainRoom1_Movement_MarsWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_MarsWalkSouth:
    WalkNormalSouth
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_MarsWalkBack:
    WalkNormalNorth
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_MarsExclamationMark:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_MarsWalkOnSpotNorthSouth:
    WalkOnSpotNormalNorth
    Delay8 2
    WalkOnSpotNormalSouth
    Delay8 2
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_MarsLeave:
    WalkNormalSouth 2
    Delay8
    WalkNormalSouth
    SetInvisible
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_PlayerMoveAside:
    Delay8 2
    WalkNormalWest
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_PlayerWalkOnSpotNorth:
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_JupiterWalkOnSpotWestSouth:
    WalkOnSpotNormalWest
    Delay8 2
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_JupiterWalkSouth:
    WalkNormalSouth
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_JupiterWalkOnSpotNorth:
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_JupiterWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_JupiterLeave:
    WalkNormalWest
    WalkNormalSouth 2
    SetInvisible
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_JupiterFaceMars:
    Delay8
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_CharonWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_CharonLeave:
    WalkNormalNorth 7
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_GruntM1Leave:
    WalkNormalEast
    WalkNormalNorth 7
    EndMovement

    .balign 4, 0
StarkMountainRoom1_Movement_GruntM2Leave:
    Delay8
    WalkNormalWest
    WalkNormalNorth 7
    EndMovement

@ Sovereign (E10, Renegade's legendary events): Groudon left of the steps to the next room, after the Hall of Fame once Steven has given the Orbs (Renegade: a portal, Lv. 70, with the Red Orb), until it is caught. The Full Heal ball that stood there moved to (12, 3), as in Renegade.
StarkMountainRoom1_SovereignSetGroudonVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfUnset FLAG_GAME_COMPLETED, StarkMountainRoom1_SovereignSetGroudonVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_STEVEN_GAVE_ORBS, StarkMountainRoom1_SovereignSetGroudonVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_GROUDON, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, StarkMountainRoom1_SovereignSetGroudonVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
StarkMountainRoom1_SovereignSetGroudonVisibilityEnd:
    Return

StarkMountainRoom1_RemoveLegendaryGroudon:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_GROUDON, StarkMountainRoom1_RemoveLegendaryGroudonEnd
    RemoveObject LOCALID_LEGENDARY_GROUDON
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
StarkMountainRoom1_RemoveLegendaryGroudonEnd:
    Return

StarkMountainRoom1_LegendaryGroudon:
    SetVar VAR_0x8004, SPECIES_GROUDON
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End
