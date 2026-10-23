#include "macros/scrcmd.inc"
#include "res/text/bank/canalave_library_2f.h"
#include "res/field/events/events_canalave_library_2f.h"


    ScriptEntry CanalaveLibrary2F_SchoolKidM
    ScriptEntry CanalaveLibrary2F_Bookshelves
    ScriptEntry CanalaveLibrary2F_Shelves
    ScriptEntry CanalaveLibrary2F_BgSign
    ScriptEntry CanalaveLibrary2F_OnTransition
    ScriptEntry CanalaveLibrary2F_OnFrame_Hiker
    ScriptEntry CanalaveLibrary2F_SovereignArchivist
    ScriptEntryEnd

CanalaveLibrary2F_OnTransition:
    SetFlag FLAG_HIDE_CANALAVE_LIBRARY_2F_HIKER
    CallIfEq VAR_ARCEUS_EVENT_STATE, 2, CanalaveLibrary2F_ShowHiker
    CallIfUnset FLAG_GAME_COMPLETED, CanalaveLibrary2F_SovereignHideArchivist
    End

CanalaveLibrary2F_SovereignHideArchivist:
    SetFlag FLAG_MAP_LOCAL_HIDE_SOVEREIGN_NPC
    Return

CanalaveLibrary2F_ShowHiker:
    ClearFlag FLAG_HIDE_CANALAVE_LIBRARY_2F_HIKER
    Return

CanalaveLibrary2F_SchoolKidM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_LAKE_VALOR_EXPLODED, CanalaveLibrary2F_TremorWasWicked
    Message CanalaveLibrary2F_Text_ThirdFloorEasyRead
    WaitButton
    CloseMessage
    ReleaseAll
    End

CanalaveLibrary2F_TremorWasWicked:
    Message CanalaveLibrary2F_Text_TremorWasWicked
    WaitButton
    CloseMessage
    ReleaseAll
    End

CanalaveLibrary2F_Bookshelves:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GoToIfGe VAR_ARCEUS_EVENT_STATE, 3, CanalaveLibrary2F_SinnohAsToldOnPlates
    Message CanalaveLibrary2F_Text_BookshelvesAreCrammed
    GoTo CanalaveLibrary2F_BookshelvesEnd
    End

CanalaveLibrary2F_BookshelvesEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

CanalaveLibrary2F_SinnohAsToldOnPlates:
    BufferPlayerName 0
    Message CanalaveLibrary2F_Text_SinnohAsToldOnPlates
    GoTo CanalaveLibrary2F_BookshelvesEnd
    End

CanalaveLibrary2F_Shelves:
    EventMessage CanalaveLibrary2F_Text_ShelvesLinedWithBooks
    End

CanalaveLibrary2F_BgSign:
    EventMessage CanalaveLibrary2F_Text_RefrainFromBringingFood
    End

CanalaveLibrary2F_OnFrame_Hiker:
    LockAll
    ApplyMovement LOCALID_HIKER, CanalaveLibrary2F_Movement_HikerNoticeWalkToPlayer
    WaitMovement
    Message CanalaveLibrary2F_Text_WantToHearAboutJourney
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, CanalaveLibrary2F_TheWayISeeIt
    GoToIfEq VAR_RESULT, MENU_NO, CanalaveLibrary2F_LetsNotBeHasty
    End

CanalaveLibrary2F_LetsNotBeHasty:
    Message CanalaveLibrary2F_Text_LetsNotBeHasty
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, CanalaveLibrary2F_TheWayISeeIt
    GoToIfEq VAR_RESULT, MENU_NO, CanalaveLibrary2F_LetsNotBeHasty
    End

CanalaveLibrary2F_TheWayISeeIt:
    Message CanalaveLibrary2F_Text_TheWayISeeIt
    CloseMessage
    ApplyMovement LOCALID_HIKER, CanalaveLibrary2F_Movement_HikerLookAround
    WaitMovement
    Message CanalaveLibrary2F_Text_WantToHearMore
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, CanalaveLibrary2F_ThereWerePlates
    GoToIfEq VAR_RESULT, MENU_NO, CanalaveLibrary2F_DontTeaseMe
    End

CanalaveLibrary2F_DontTeaseMe:
    Message CanalaveLibrary2F_Text_DontTeaseMe
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, CanalaveLibrary2F_ThereWerePlates
    GoToIfEq VAR_RESULT, MENU_NO, CanalaveLibrary2F_DontTeaseMe
    End

CanalaveLibrary2F_ThereWerePlates:
    Message CanalaveLibrary2F_Text_ThereWerePlates
    CloseMessage
    ApplyMovement LOCALID_HIKER, CanalaveLibrary2F_Movement_HikerWalkOnSpotWest
    WaitMovement
    Message CanalaveLibrary2F_Text_WroteDownEngravings
    CloseMessage
    ApplyMovement LOCALID_HIKER, CanalaveLibrary2F_Movement_HikerWalkOnSpotEast
    WaitMovement
    Message CanalaveLibrary2F_Text_GladICameToSinnoh
    CloseMessage
    ApplyMovement LOCALID_PLAYER, CanalaveLibrary2F_Movement_PlayerMoveAside
    ApplyMovement LOCALID_HIKER, CanalaveLibrary2F_Movement_HikerLeave
    WaitMovement
    RemoveObject LOCALID_HIKER
    SetVar VAR_ARCEUS_EVENT_STATE, 3
    ReleaseAll
    End

    .balign 4, 0
CanalaveLibrary2F_Movement_HikerNoticeWalkToPlayer:
    WalkOnSpotNormalEast
    EmoteExclamationMark
    WalkNormalEast
    WalkNormalNorth
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
CanalaveLibrary2F_Movement_HikerLookAround:
    WalkOnSpotNormalSouth
    WalkOnSpotNormalNorth
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
CanalaveLibrary2F_Movement_HikerWalkOnSpotWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
CanalaveLibrary2F_Movement_HikerWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
CanalaveLibrary2F_Movement_HikerLeave:
    Delay8 2
    WalkNormalEast 2
    EndMovement

    .balign 4, 0
CanalaveLibrary2F_Movement_PlayerMoveAside:
    WalkNormalSouth
    WalkOnSpotNormalNorth
    EndMovement

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): the Legend Archivist, here from the first Hall of Fame. His
@ first talk opens the Unova Chronicle (VAR_SOVEREIGN_CHRONICLE 1).
CanalaveLibrary2F_SovereignArchivist:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfGe VAR_SOVEREIGN_CHRONICLE, 1, CanalaveLibrary2F_SovereignArchivistUnova
    SetVar VAR_SOVEREIGN_CHRONICLE, 1
    Message CanalaveLibrary2F_Text_SovereignArchivistIntro
    GoTo CanalaveLibrary2F_SovereignArchivistEnd

CanalaveLibrary2F_SovereignArchivistUnova:
    SovereignCheckSpeciesCaught SPECIES_VIRIZION, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistVirizionCaught
    Message CanalaveLibrary2F_Text_SovereignArchivistVirizion
    GoTo CanalaveLibrary2F_SovereignArchivistEnd

CanalaveLibrary2F_SovereignArchivistVirizionCaught:
    Message CanalaveLibrary2F_Text_SovereignArchivistVirizionCaught
CanalaveLibrary2F_SovereignArchivistEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End
