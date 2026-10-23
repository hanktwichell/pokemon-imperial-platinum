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
@ first talk opens the Unova Chronicle (VAR_SOVEREIGN_CHRONICLE 1). After that he tells where each sword not caught yet
@ stands; once all three are caught, he sends the player to Lake Valor for Keldeo. Then Truth and Ideals (below), and a
@ hint for Meloetta and Genesect while they aren't caught.
CanalaveLibrary2F_SovereignArchivist:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfGe VAR_SOVEREIGN_CHRONICLE, 1, CanalaveLibrary2F_SovereignArchivistUnova
    SetVar VAR_SOVEREIGN_CHRONICLE, 1
    Message CanalaveLibrary2F_Text_SovereignArchivistIntro
    GoTo CanalaveLibrary2F_SovereignArchivistEnd

CanalaveLibrary2F_SovereignArchivistUnova:
    SovereignCheckSpeciesCaught SPECIES_COBALION, VAR_0x8004
    SovereignCheckSpeciesCaught SPECIES_TERRAKION, VAR_0x8005
    SovereignCheckSpeciesCaught SPECIES_VIRIZION, VAR_0x8006
    GoToIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistSwords
    GoToIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistSwords
    GoToIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistSwords
    SovereignCheckSpeciesCaught SPECIES_KELDEO, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistKeldeoCaught
    Message CanalaveLibrary2F_Text_SovereignArchivistKeldeo
    GoTo CanalaveLibrary2F_SovereignArchivistDragons

CanalaveLibrary2F_SovereignArchivistKeldeoCaught:
    Message CanalaveLibrary2F_Text_SovereignArchivistKeldeoCaught
    GoTo CanalaveLibrary2F_SovereignArchivistDragons

CanalaveLibrary2F_SovereignArchivistSwords:
    Message CanalaveLibrary2F_Text_SovereignArchivistSwords
    CallIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistCobalion
    CallIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistTerrakion
    CallIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistVirizion
@ Truth and Ideals: the Light and Dark Stones on the first pass, a hint for each dragon not caught yet, then Kyurem,
@ then the DNA Splicers once Kyurem is caught.
CanalaveLibrary2F_SovereignArchivistDragons:
    CheckItem ITEM_LIGHT_STONE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistDragonHints
    SovereignCheckSpeciesCaught SPECIES_RESHIRAM, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistDragonHints
    Message CanalaveLibrary2F_Text_SovereignArchivistStones
    SetVar VAR_0x8004, ITEM_LIGHT_STONE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_DARK_STONE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
CanalaveLibrary2F_SovereignArchivistDragonHints:
    SovereignCheckSpeciesCaught SPECIES_RESHIRAM, VAR_0x8006
    SovereignCheckSpeciesCaught SPECIES_ZEKROM, VAR_0x8007
    CallIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistReshiram
    CallIfEq VAR_0x8007, FALSE, CanalaveLibrary2F_SovereignArchivistZekrom
    GoToIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistOthers
    GoToIfEq VAR_0x8007, FALSE, CanalaveLibrary2F_SovereignArchivistOthers
    SovereignCheckSpeciesCaught SPECIES_KYUREM, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistKyuremCaught
    Message CanalaveLibrary2F_Text_SovereignArchivistKyurem
    GoTo CanalaveLibrary2F_SovereignArchivistOthers

CanalaveLibrary2F_SovereignArchivistKyuremCaught:
    CheckItem ITEM_DNA_SPLICERS, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistOthers
    Message CanalaveLibrary2F_Text_SovereignArchivistDNASplicers
    SetVar VAR_0x8004, ITEM_DNA_SPLICERS
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
CanalaveLibrary2F_SovereignArchivistOthers:
    SovereignCheckSpeciesCaught SPECIES_MELOETTA, VAR_0x8004
    SovereignCheckSpeciesCaught SPECIES_GENESECT, VAR_0x8005
    CallIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistMeloetta
    CallIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistGenesect
    Message CanalaveLibrary2F_Text_SovereignArchivistKeepReading
    GoTo CanalaveLibrary2F_SovereignArchivistEnd

CanalaveLibrary2F_SovereignArchivistCobalion:
    Message CanalaveLibrary2F_Text_SovereignArchivistCobalion
    Return

CanalaveLibrary2F_SovereignArchivistTerrakion:
    Message CanalaveLibrary2F_Text_SovereignArchivistTerrakion
    Return

CanalaveLibrary2F_SovereignArchivistVirizion:
    Message CanalaveLibrary2F_Text_SovereignArchivistVirizion
    Return

CanalaveLibrary2F_SovereignArchivistReshiram:
    Message CanalaveLibrary2F_Text_SovereignArchivistReshiram
    Return

CanalaveLibrary2F_SovereignArchivistZekrom:
    Message CanalaveLibrary2F_Text_SovereignArchivistZekrom
    Return

CanalaveLibrary2F_SovereignArchivistMeloetta:
    Message CanalaveLibrary2F_Text_SovereignArchivistMeloetta
    Return

CanalaveLibrary2F_SovereignArchivistGenesect:
    Message CanalaveLibrary2F_Text_SovereignArchivistGenesect
    Return

CanalaveLibrary2F_SovereignArchivistEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End
