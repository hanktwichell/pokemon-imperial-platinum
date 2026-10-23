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
@ first talk opens the Unova Chronicle (VAR_SOVEREIGN_CHRONICLE 1). After that he offers a menu of the Chronicle's
@ legends, and each topic gives what's left of it: hints, and the key items (the Light and Dark Stones, the DNA
@ Splicers, the Reveal Glass, the Prison Bottle) or the release of the Forces of Nature roamers. The menu comes back
@ until the player is done. Once Kyurem, the Unova Chronicle's key, is caught, he opens the Kalos Chronicle
@ (VAR_SOVEREIGN_CHRONICLE 2) and first asks which Chronicle to read from. Xerneas and Yveltal, the Kalos key, open
@ the Alola Chronicle (3).
CanalaveLibrary2F_SovereignArchivist:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfGe VAR_SOVEREIGN_CHRONICLE, 1, CanalaveLibrary2F_SovereignArchivistRead
    SetVar VAR_SOVEREIGN_CHRONICLE, 1
    Message CanalaveLibrary2F_Text_SovereignArchivistIntro
    GoTo CanalaveLibrary2F_SovereignArchivistEnd

CanalaveLibrary2F_SovereignArchivistRead:
    GoToIfGe VAR_SOVEREIGN_CHRONICLE, 3, CanalaveLibrary2F_SovereignArchivistChapters
    GoToIfGe VAR_SOVEREIGN_CHRONICLE, 2, CanalaveLibrary2F_SovereignArchivistTryAlola
    SovereignCheckSpeciesCaught SPECIES_KYUREM, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistUnova
    SetVar VAR_SOVEREIGN_CHRONICLE, 2
    Message CanalaveLibrary2F_Text_SovereignArchivistKalosOpens
CanalaveLibrary2F_SovereignArchivistTryAlola:
    SovereignCheckSpeciesCaught SPECIES_XERNEAS, VAR_0x8004
    SovereignCheckSpeciesCaught SPECIES_YVELTAL, VAR_0x8005
    GoToIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistChapters
    GoToIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistChapters
    SetVar VAR_SOVEREIGN_CHRONICLE, 3
    Message CanalaveLibrary2F_Text_SovereignArchivistAlolaOpens
CanalaveLibrary2F_SovereignArchivistChapters:
    Message CanalaveLibrary2F_Text_SovereignArchivistWhichChronicle
    InitLocalTextMenu 31, 3, 0, VAR_RESULT
    SetMenuXOriginToRight
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuUnova, 0
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuKalos, 1
    CallIfGe VAR_SOVEREIGN_CHRONICLE, 3, CanalaveLibrary2F_SovereignArchivistAddAlolaEntry
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuDone, 9
    ShowMenu
    GoToIfEq VAR_RESULT, 0, CanalaveLibrary2F_SovereignArchivistUnova
    GoToIfEq VAR_RESULT, 1, CanalaveLibrary2F_SovereignArchivistKalos
    GoToIfEq VAR_RESULT, 2, CanalaveLibrary2F_SovereignArchivistAlola
    Message CanalaveLibrary2F_Text_SovereignArchivistKeepReadingChronicles
    GoTo CanalaveLibrary2F_SovereignArchivistEnd

CanalaveLibrary2F_SovereignArchivistAddAlolaEntry:
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuAlola, 2
    Return

CanalaveLibrary2F_SovereignArchivistUnova:
    Message CanalaveLibrary2F_Text_SovereignArchivistWhichLegend
CanalaveLibrary2F_SovereignArchivistMenu:
    InitLocalTextMenu 31, 3, 0, VAR_RESULT
    SetMenuXOriginToRight
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuSwords, 0
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuDragons, 1
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuForces, 2
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuOthers, 3
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuDone, 4
    ShowMenu
    GoToIfEq VAR_RESULT, 0, CanalaveLibrary2F_SovereignArchivistSwordsTopic
    GoToIfEq VAR_RESULT, 1, CanalaveLibrary2F_SovereignArchivistDragons
    GoToIfEq VAR_RESULT, 2, CanalaveLibrary2F_SovereignArchivistForces
    GoToIfEq VAR_RESULT, 3, CanalaveLibrary2F_SovereignArchivistOthers
    Message CanalaveLibrary2F_Text_SovereignArchivistKeepReading
    GoTo CanalaveLibrary2F_SovereignArchivistEnd

CanalaveLibrary2F_SovereignArchivistAskMore:
    Message CanalaveLibrary2F_Text_SovereignArchivistAnythingElse
    GoTo CanalaveLibrary2F_SovereignArchivistMenu

@ The Swords of Justice: where each sword not caught yet stands, then Keldeo.
CanalaveLibrary2F_SovereignArchivistSwordsTopic:
    SovereignCheckSpeciesCaught SPECIES_COBALION, VAR_0x8004
    SovereignCheckSpeciesCaught SPECIES_TERRAKION, VAR_0x8005
    SovereignCheckSpeciesCaught SPECIES_VIRIZION, VAR_0x8006
    GoToIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistSwords
    GoToIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistSwords
    GoToIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistSwords
    SovereignCheckSpeciesCaught SPECIES_KELDEO, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistKeldeoCaught
    Message CanalaveLibrary2F_Text_SovereignArchivistKeldeo
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

CanalaveLibrary2F_SovereignArchivistKeldeoCaught:
    Message CanalaveLibrary2F_Text_SovereignArchivistKeldeoCaught
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

CanalaveLibrary2F_SovereignArchivistSwords:
    Message CanalaveLibrary2F_Text_SovereignArchivistSwords
    CallIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistCobalion
    CallIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistTerrakion
    CallIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistVirizion
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

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
    GoToIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistAskMore
    GoToIfEq VAR_0x8007, FALSE, CanalaveLibrary2F_SovereignArchivistAskMore
    SovereignCheckSpeciesCaught SPECIES_KYUREM, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistKyuremCaught
    Message CanalaveLibrary2F_Text_SovereignArchivistKyurem
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

CanalaveLibrary2F_SovereignArchivistKyuremCaught:
    CheckItem ITEM_DNA_SPLICERS, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistDragonsDone
    Message CanalaveLibrary2F_Text_SovereignArchivistDNASplicers
    SetVar VAR_0x8004, ITEM_DNA_SPLICERS
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

CanalaveLibrary2F_SovereignArchivistDragonsDone:
    Message CanalaveLibrary2F_Text_SovereignArchivistDragonsDone
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

@ Forces of Nature: the first pass releases Tornadus and Thundurus as roamers (FLAG_SOVEREIGN_RELEASED_FORCES_OF_NATURE).
@ One knocked out is released again after the next Hall of Fame resets its state, as Professor Oak does for the
@ legendary birds. Once both are caught: the Reveal Glass, then Landorus, then Enamorus.
CanalaveLibrary2F_SovereignArchivistForces:
    GoToIfSet FLAG_SOVEREIGN_RELEASED_FORCES_OF_NATURE, CanalaveLibrary2F_SovereignArchivistForcesReleased
    Message CanalaveLibrary2F_Text_SovereignArchivistForcesRelease
    SetFlag FLAG_SOVEREIGN_RELEASED_FORCES_OF_NATURE
    ActivateRoamingPokemon ROAMING_SLOT_TORNADUS
    ActivateRoamingPokemon ROAMING_SLOT_THUNDURUS
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

CanalaveLibrary2F_SovereignArchivistForcesReleased:
    CallIfEq VAR_ROAMING_TORNADUS_STATE, ROAMER_STATE_RESET, CanalaveLibrary2F_SovereignArchivistReleaseTornadus
    CallIfEq VAR_ROAMING_THUNDURUS_STATE, ROAMER_STATE_RESET, CanalaveLibrary2F_SovereignArchivistReleaseThundurus
    SovereignCheckSpeciesCaught SPECIES_TORNADUS, VAR_0x8004
    SovereignCheckSpeciesCaught SPECIES_THUNDURUS, VAR_0x8005
    GoToIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistRoamers
    GoToIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistRoamers
    CheckItem ITEM_REVEAL_GLASS, 1, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistRevealGlass
    SovereignCheckSpeciesCaught SPECIES_LANDORUS, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistLandorus
    SovereignCheckSpeciesCaught SPECIES_ENAMORUS, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistForcesDone
    Message CanalaveLibrary2F_Text_SovereignArchivistEnamorus
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

CanalaveLibrary2F_SovereignArchivistForcesDone:
    Message CanalaveLibrary2F_Text_SovereignArchivistForcesDone
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

CanalaveLibrary2F_SovereignArchivistLandorus:
    Message CanalaveLibrary2F_Text_SovereignArchivistLandorus
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

CanalaveLibrary2F_SovereignArchivistRoamers:
    Message CanalaveLibrary2F_Text_SovereignArchivistRoamers
    GoToIfEq VAR_ROAMING_TORNADUS_STATE, ROAMER_STATE_DEFEATED, CanalaveLibrary2F_SovereignArchivistRoamerGone
    GoToIfEq VAR_ROAMING_THUNDURUS_STATE, ROAMER_STATE_DEFEATED, CanalaveLibrary2F_SovereignArchivistRoamerGone
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

CanalaveLibrary2F_SovereignArchivistRoamerGone:
    Message CanalaveLibrary2F_Text_SovereignArchivistRoamerGone
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

CanalaveLibrary2F_SovereignArchivistReleaseTornadus:
    SetVar VAR_ROAMING_TORNADUS_STATE, ROAMER_STATE_ROAMING
    ActivateRoamingPokemon ROAMING_SLOT_TORNADUS
    Return

CanalaveLibrary2F_SovereignArchivistReleaseThundurus:
    SetVar VAR_ROAMING_THUNDURUS_STATE, ROAMER_STATE_ROAMING
    ActivateRoamingPokemon ROAMING_SLOT_THUNDURUS
    Return

CanalaveLibrary2F_SovereignArchivistRevealGlass:
    Message CanalaveLibrary2F_Text_SovereignArchivistRevealGlass
    SetVar VAR_0x8004, ITEM_REVEAL_GLASS
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Return

@ The other Unova legends: Meloetta, Genesect and Victini.
CanalaveLibrary2F_SovereignArchivistOthers:
    SovereignCheckSpeciesCaught SPECIES_MELOETTA, VAR_0x8004
    SovereignCheckSpeciesCaught SPECIES_GENESECT, VAR_0x8005
    SovereignCheckSpeciesCaught SPECIES_VICTINI, VAR_0x8006
    CallIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistMeloetta
    CallIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistGenesect
    CallIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistVictini
    GoToIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistAskMore
    GoToIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistAskMore
    GoToIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistAskMore
    Message CanalaveLibrary2F_Text_SovereignArchivistOthersDone
    GoTo CanalaveLibrary2F_SovereignArchivistAskMore

@ The Kalos Chronicle: a menu of its legends, as for Unova's.
CanalaveLibrary2F_SovereignArchivistKalos:
    Message CanalaveLibrary2F_Text_SovereignArchivistKalosWhichLegend
CanalaveLibrary2F_SovereignArchivistKalosMenu:
    InitLocalTextMenu 31, 3, 0, VAR_RESULT
    SetMenuXOriginToRight
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuLife, 0
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuOthers, 1
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuDone, 2
    ShowMenu
    GoToIfEq VAR_RESULT, 0, CanalaveLibrary2F_SovereignArchivistLife
    GoToIfEq VAR_RESULT, 1, CanalaveLibrary2F_SovereignArchivistKalosOthers
    Message CanalaveLibrary2F_Text_SovereignArchivistKalosKeepReading
    GoTo CanalaveLibrary2F_SovereignArchivistEnd

CanalaveLibrary2F_SovereignArchivistKalosAskMore:
    Message CanalaveLibrary2F_Text_SovereignArchivistAnythingElse
    GoTo CanalaveLibrary2F_SovereignArchivistKalosMenu

@ Life and Destruction, the Kalos Chronicle's key: a hint for Xerneas and Yveltal while either is left, then Zygarde.
CanalaveLibrary2F_SovereignArchivistLife:
    SovereignCheckSpeciesCaught SPECIES_XERNEAS, VAR_0x8004
    SovereignCheckSpeciesCaught SPECIES_YVELTAL, VAR_0x8005
    GoToIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistLifeHints
    GoToIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistLifeHints
    SovereignCheckSpeciesCaught SPECIES_ZYGARDE, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, CanalaveLibrary2F_SovereignArchivistLifeDone
    Message CanalaveLibrary2F_Text_SovereignArchivistZygarde
    GoTo CanalaveLibrary2F_SovereignArchivistKalosAskMore

CanalaveLibrary2F_SovereignArchivistLifeDone:
    Message CanalaveLibrary2F_Text_SovereignArchivistLifeDone
    GoTo CanalaveLibrary2F_SovereignArchivistKalosAskMore

CanalaveLibrary2F_SovereignArchivistLifeHints:
    Message CanalaveLibrary2F_Text_SovereignArchivistLife
    CallIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistXerneas
    CallIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistYveltal
    GoTo CanalaveLibrary2F_SovereignArchivistKalosAskMore

@ The other Kalos legends: Diancie, Hoopa (the Prison Bottle first, while the player doesn't have it) and Volcanion.
CanalaveLibrary2F_SovereignArchivistKalosOthers:
    CheckItem ITEM_PRISON_BOTTLE, 1, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistPrisonBottle
    SovereignCheckSpeciesCaught SPECIES_DIANCIE, VAR_0x8006
    SovereignCheckSpeciesCaught SPECIES_HOOPA, VAR_0x8007
    SovereignCheckSpeciesCaught SPECIES_VOLCANION, VAR_0x8008
    CallIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistDiancie
    CallIfEq VAR_0x8007, FALSE, CanalaveLibrary2F_SovereignArchivistHoopa
    CallIfEq VAR_0x8008, FALSE, CanalaveLibrary2F_SovereignArchivistVolcanion
    GoToIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistKalosAskMore
    GoToIfEq VAR_0x8007, FALSE, CanalaveLibrary2F_SovereignArchivistKalosAskMore
    GoToIfEq VAR_0x8008, FALSE, CanalaveLibrary2F_SovereignArchivistKalosAskMore
    Message CanalaveLibrary2F_Text_SovereignArchivistKalosOthersDone
    GoTo CanalaveLibrary2F_SovereignArchivistKalosAskMore

@ The Alola Chronicle: a menu of its legends, as for Unova's and Kalos'.
CanalaveLibrary2F_SovereignArchivistAlola:
    Message CanalaveLibrary2F_Text_SovereignArchivistAlolaWhichLegend
CanalaveLibrary2F_SovereignArchivistAlolaMenu:
    InitLocalTextMenu 31, 3, 0, VAR_RESULT
    SetMenuXOriginToRight
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuGuardians, 0
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuSky, 1
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuUltra, 2
    AddMenuEntryImm CanalaveLibrary2F_Text_SovereignMenuDone, 9
    ShowMenu
    GoToIfEq VAR_RESULT, 0, CanalaveLibrary2F_SovereignArchivistGuardians
    GoToIfEq VAR_RESULT, 1, CanalaveLibrary2F_SovereignArchivistSky
    GoToIfEq VAR_RESULT, 2, CanalaveLibrary2F_SovereignArchivistUltra
    Message CanalaveLibrary2F_Text_SovereignArchivistAlolaKeepReading
    GoTo CanalaveLibrary2F_SovereignArchivistEnd

CanalaveLibrary2F_SovereignArchivistAlolaAskMore:
    Message CanalaveLibrary2F_Text_SovereignArchivistAnythingElse
    GoTo CanalaveLibrary2F_SovereignArchivistAlolaMenu

@ The Island Guardians: a hint for each Tapu not caught yet.
CanalaveLibrary2F_SovereignArchivistGuardians:
    SovereignCheckSpeciesCaught SPECIES_TAPU_KOKO, VAR_0x8004
    SovereignCheckSpeciesCaught SPECIES_TAPU_LELE, VAR_0x8005
    SovereignCheckSpeciesCaught SPECIES_TAPU_BULU, VAR_0x8006
    SovereignCheckSpeciesCaught SPECIES_TAPU_FINI, VAR_0x8007
    GoToIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistGuardianHints
    GoToIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistGuardianHints
    GoToIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistGuardianHints
    GoToIfEq VAR_0x8007, FALSE, CanalaveLibrary2F_SovereignArchivistGuardianHints
    Message CanalaveLibrary2F_Text_SovereignArchivistGuardiansDone
    GoTo CanalaveLibrary2F_SovereignArchivistAlolaAskMore

CanalaveLibrary2F_SovereignArchivistGuardianHints:
    Message CanalaveLibrary2F_Text_SovereignArchivistGuardians
    CallIfEq VAR_0x8004, FALSE, CanalaveLibrary2F_SovereignArchivistTapuKoko
    CallIfEq VAR_0x8005, FALSE, CanalaveLibrary2F_SovereignArchivistTapuLele
    CallIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistTapuBulu
    CallIfEq VAR_0x8007, FALSE, CanalaveLibrary2F_SovereignArchivistTapuFini
    GoTo CanalaveLibrary2F_SovereignArchivistAlolaAskMore

@ Sun and Moon, the Alola Chronicle's key: Cosmog at Spear Pillar (FLAG_SOVEREIGN_CAUGHT_COSMOG), how it evolves, then
@ once the player has Solgaleo or Lunala, the second Cosmog and Necrozma, then the N-Solarizer and N-Lunarizer once
@ Necrozma is caught.
CanalaveLibrary2F_SovereignArchivistSky:
    GoToIfUnset FLAG_SOVEREIGN_CAUGHT_COSMOG, CanalaveLibrary2F_SovereignArchivistCosmog
    SovereignCheckSpeciesCaught SPECIES_SOLGALEO, VAR_0x8004
    SovereignCheckSpeciesCaught SPECIES_LUNALA, VAR_0x8005
    GoToIfEq VAR_0x8004, TRUE, CanalaveLibrary2F_SovereignArchivistSkyNecrozma
    GoToIfEq VAR_0x8005, TRUE, CanalaveLibrary2F_SovereignArchivistSkyNecrozma
    Message CanalaveLibrary2F_Text_SovereignArchivistCosmogRaise
    GoTo CanalaveLibrary2F_SovereignArchivistAlolaAskMore

CanalaveLibrary2F_SovereignArchivistCosmog:
    Message CanalaveLibrary2F_Text_SovereignArchivistCosmog
    GoTo CanalaveLibrary2F_SovereignArchivistAlolaAskMore

CanalaveLibrary2F_SovereignArchivistSkyNecrozma:
    SovereignCheckSpeciesCaught SPECIES_NECROZMA, VAR_0x8006
    CallIfUnset FLAG_SOVEREIGN_CAUGHT_COSMOG_2, CanalaveLibrary2F_SovereignArchivistCosmogAgain
    CallIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistNecrozma
    GoToIfEq VAR_0x8006, FALSE, CanalaveLibrary2F_SovereignArchivistAlolaAskMore
    CheckItem ITEM_N_SOLARIZER, 1, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistSolarizers
    GoToIfUnset FLAG_SOVEREIGN_CAUGHT_COSMOG_2, CanalaveLibrary2F_SovereignArchivistAlolaAskMore
    Message CanalaveLibrary2F_Text_SovereignArchivistSkyDone
    GoTo CanalaveLibrary2F_SovereignArchivistAlolaAskMore

@ Ultra Beasts: once Necrozma is caught, a hint for each of the nine not caught yet (VAR_0x8008 counts them first).
CanalaveLibrary2F_SovereignArchivistUltra:
    SovereignCheckSpeciesCaught SPECIES_NECROZMA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistUltraLocked
    SetVar VAR_0x8008, 0
    SovereignCheckSpeciesCaught SPECIES_NIHILEGO, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistCountUltra
    SovereignCheckSpeciesCaught SPECIES_BUZZWOLE, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistCountUltra
    SovereignCheckSpeciesCaught SPECIES_PHEROMOSA, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistCountUltra
    SovereignCheckSpeciesCaught SPECIES_XURKITREE, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistCountUltra
    SovereignCheckSpeciesCaught SPECIES_CELESTEELA, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistCountUltra
    SovereignCheckSpeciesCaught SPECIES_KARTANA, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistCountUltra
    SovereignCheckSpeciesCaught SPECIES_GUZZLORD, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistCountUltra
    SovereignCheckSpeciesCaught SPECIES_STAKATAKA, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistCountUltra
    SovereignCheckSpeciesCaught SPECIES_BLACEPHALON, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistCountUltra
    GoToIfEq VAR_0x8008, 0, CanalaveLibrary2F_SovereignArchivistUltraDone
    Message CanalaveLibrary2F_Text_SovereignArchivistUltra
    SovereignCheckSpeciesCaught SPECIES_NIHILEGO, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistNihilego
    SovereignCheckSpeciesCaught SPECIES_BUZZWOLE, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistBuzzwole
    SovereignCheckSpeciesCaught SPECIES_PHEROMOSA, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistPheromosa
    SovereignCheckSpeciesCaught SPECIES_XURKITREE, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistXurkitree
    SovereignCheckSpeciesCaught SPECIES_CELESTEELA, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistCelesteela
    SovereignCheckSpeciesCaught SPECIES_KARTANA, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistKartana
    SovereignCheckSpeciesCaught SPECIES_GUZZLORD, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistGuzzlord
    SovereignCheckSpeciesCaught SPECIES_STAKATAKA, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistStakataka
    SovereignCheckSpeciesCaught SPECIES_BLACEPHALON, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, CanalaveLibrary2F_SovereignArchivistBlacephalon
    GoTo CanalaveLibrary2F_SovereignArchivistAlolaAskMore

CanalaveLibrary2F_SovereignArchivistUltraLocked:
    Message CanalaveLibrary2F_Text_SovereignArchivistUltraLocked
    GoTo CanalaveLibrary2F_SovereignArchivistAlolaAskMore

CanalaveLibrary2F_SovereignArchivistUltraDone:
    Message CanalaveLibrary2F_Text_SovereignArchivistUltraDone
    GoTo CanalaveLibrary2F_SovereignArchivistAlolaAskMore

CanalaveLibrary2F_SovereignArchivistCountUltra:
    AddVar VAR_0x8008, 1
    Return

CanalaveLibrary2F_SovereignArchivistSolarizers:
    Message CanalaveLibrary2F_Text_SovereignArchivistSolarizers
    SetVar VAR_0x8004, ITEM_N_SOLARIZER
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_N_LUNARIZER
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Return

CanalaveLibrary2F_SovereignArchivistPrisonBottle:
    Message CanalaveLibrary2F_Text_SovereignArchivistPrisonBottle
    SetVar VAR_0x8004, ITEM_PRISON_BOTTLE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Return

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

CanalaveLibrary2F_SovereignArchivistVictini:
    Message CanalaveLibrary2F_Text_SovereignArchivistVictini
    Return

CanalaveLibrary2F_SovereignArchivistXerneas:
    Message CanalaveLibrary2F_Text_SovereignArchivistXerneas
    Return

CanalaveLibrary2F_SovereignArchivistYveltal:
    Message CanalaveLibrary2F_Text_SovereignArchivistYveltal
    Return

CanalaveLibrary2F_SovereignArchivistDiancie:
    Message CanalaveLibrary2F_Text_SovereignArchivistDiancie
    Return

CanalaveLibrary2F_SovereignArchivistHoopa:
    Message CanalaveLibrary2F_Text_SovereignArchivistHoopa
    Return

CanalaveLibrary2F_SovereignArchivistVolcanion:
    Message CanalaveLibrary2F_Text_SovereignArchivistVolcanion
    Return

CanalaveLibrary2F_SovereignArchivistTapuKoko:
    Message CanalaveLibrary2F_Text_SovereignArchivistTapuKoko
    Return

CanalaveLibrary2F_SovereignArchivistTapuLele:
    Message CanalaveLibrary2F_Text_SovereignArchivistTapuLele
    Return

CanalaveLibrary2F_SovereignArchivistTapuBulu:
    Message CanalaveLibrary2F_Text_SovereignArchivistTapuBulu
    Return

CanalaveLibrary2F_SovereignArchivistTapuFini:
    Message CanalaveLibrary2F_Text_SovereignArchivistTapuFini
    Return

CanalaveLibrary2F_SovereignArchivistCosmogAgain:
    Message CanalaveLibrary2F_Text_SovereignArchivistCosmogAgain
    Return

CanalaveLibrary2F_SovereignArchivistNecrozma:
    Message CanalaveLibrary2F_Text_SovereignArchivistNecrozma
    Return

CanalaveLibrary2F_SovereignArchivistNihilego:
    Message CanalaveLibrary2F_Text_SovereignArchivistNihilego
    Return

CanalaveLibrary2F_SovereignArchivistBuzzwole:
    Message CanalaveLibrary2F_Text_SovereignArchivistBuzzwole
    Return

CanalaveLibrary2F_SovereignArchivistPheromosa:
    Message CanalaveLibrary2F_Text_SovereignArchivistPheromosa
    Return

CanalaveLibrary2F_SovereignArchivistXurkitree:
    Message CanalaveLibrary2F_Text_SovereignArchivistXurkitree
    Return

CanalaveLibrary2F_SovereignArchivistCelesteela:
    Message CanalaveLibrary2F_Text_SovereignArchivistCelesteela
    Return

CanalaveLibrary2F_SovereignArchivistKartana:
    Message CanalaveLibrary2F_Text_SovereignArchivistKartana
    Return

CanalaveLibrary2F_SovereignArchivistGuzzlord:
    Message CanalaveLibrary2F_Text_SovereignArchivistGuzzlord
    Return

CanalaveLibrary2F_SovereignArchivistStakataka:
    Message CanalaveLibrary2F_Text_SovereignArchivistStakataka
    Return

CanalaveLibrary2F_SovereignArchivistBlacephalon:
    Message CanalaveLibrary2F_Text_SovereignArchivistBlacephalon
    Return

CanalaveLibrary2F_SovereignArchivistEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End
