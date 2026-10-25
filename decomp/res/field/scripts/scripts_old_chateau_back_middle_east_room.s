#include "macros/scrcmd.inc"
#include "res/text/bank/jubilife_city.h"
#include "res/field/events/events_old_chateau_back_middle_east_room.h"


    ScriptEntry OldChateauBackMiddleEastRoom_OnTransition
    ScriptEntry OldChateauBackMiddleEastRoom_OnFrame_TwinLeave
    ScriptEntry OldChateauBackMiddleEastRoom_SovereignPainting
    ScriptEntry OldChateauBackMiddleEastRoom_SovereignCoordEvent_Gengar
    ScriptEntryEnd

OldChateauBackMiddleEastRoom_OnTransition:
    CheckShouldShowGhost 25, VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, 1, OldChateauBackMiddleEastRoom_ShowTwin
    SetFlag FLAG_HIDE_OLD_CHATEAU_BACK_MIDDLE_EAST_ROOM_TWIN
    End

OldChateauBackMiddleEastRoom_ShowTwin:
    ClearFlag FLAG_HIDE_OLD_CHATEAU_BACK_MIDDLE_EAST_ROOM_TWIN
    SetVar VAR_OLD_CHATEAU_BACK_MIDDLE_EAST_ROOM_TWIN_STATE, 1
    End

OldChateauBackMiddleEastRoom_OnFrame_TwinLeave:
    LockAll
    ApplyMovement LOCALID_TWIN, OldChateauBackMiddleEastRoom_Movement_TwinLeave
    WaitMovement
    SetFlag FLAG_HIDE_OLD_CHATEAU_BACK_MIDDLE_EAST_ROOM_TWIN
    RemoveObject LOCALID_TWIN
    SetVar VAR_OLD_CHATEAU_BACK_MIDDLE_EAST_ROOM_TWIN_STATE, 0
    ReleaseAll
    End

    .balign 4, 0
OldChateauBackMiddleEastRoom_Movement_TwinLeave:
    Delay16
    FaceSouth
    Delay16
    PauseAnimation
    WalkNormalSouth 2
    ResumeAnimation
    SetInvisible
    EndMovement

@ Sovereign (E10, Renegade): a painting's red eyes stare at the player. Leaving the room afterwards brings a Gengar,
@ Lv. 20, once (FLAG_SOVEREIGN_OLD_CHATEAU_GENGAR_DONE, after a win or a catch). VAR_MAP_LOCAL_0x01 arms the exit.
OldChateauBackMiddleEastRoom_SovereignPainting:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GoToIfSet FLAG_SOVEREIGN_OLD_CHATEAU_GENGAR_DONE, OldChateauBackMiddleEastRoom_SovereignPaintingGlaring
    Message JubilifeCity_Text_SovereignGengarEyes
    WaitButton
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, 1
    ReleaseAll
    End

OldChateauBackMiddleEastRoom_SovereignPaintingGlaring:
    Message JubilifeCity_Text_SovereignGengarGlaring
    WaitButton
    CloseMessage
    ReleaseAll
    End

OldChateauBackMiddleEastRoom_SovereignCoordEvent_Gengar:
    LockAll
    FadeScreenOut 6
    WaitFadeScreen
    WaitTime 15, VAR_RESULT
    PlayCry SPECIES_GENGAR
    WaitCry
    WaitTime 15, VAR_RESULT
    StartLegendaryBattle SPECIES_GENGAR, 20
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, OldChateauBackMiddleEastRoom_SovereignBlackOut
    SetFlag FLAG_SOVEREIGN_OLD_CHATEAU_GENGAR_DONE
    SetVar VAR_MAP_LOCAL_0x01, 0
    ReleaseAll
    End

OldChateauBackMiddleEastRoom_SovereignBlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
