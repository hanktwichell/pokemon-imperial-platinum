#include "macros/scrcmd.inc"
#include "res/text/bank/turnback_cave_giratina_room.h"
#include "res/field/events/events_turnback_cave_giratina_room.h"


    ScriptEntry TurnbackCaveGiratinaRoom_OnLoad
    ScriptEntry TurnbackCaveGiratinaRoom_Giratina
    ScriptEntry TurnbackCaveGiratinaRoom_Item
    ScriptEntry TurnbackCaveGiratinaRoom_Inscription
    ScriptEntry TurnbackCaveGiratinaRoom_OnTransition
    ScriptEntry TurnbackCaveGiratinaRoom_Portal
    ScriptEntry TurnbackCaveGiratinaRoom_LegendaryEternatus
    ScriptEntryEnd

TurnbackCaveGiratinaRoom_OnTransition:
    Call TurnbackCaveGiratinaRoom_SovereignSetEternatusVisibility
    End

TurnbackCaveGiratinaRoom_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, TurnbackCaveGiratinaRoom_RemoveLegendaryEternatus
    GoToIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, TurnbackCaveGiratinaRoom_RemoveGiratina
    End

TurnbackCaveGiratinaRoom_RemoveGiratina:
    SetFlag FLAG_HIDE_TURNBACK_CAVE_GIRATINA_ROOM_GIRATINA
    RemoveObject LOCALID_GIRATINA
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    End

TurnbackCaveGiratinaRoom_Giratina:
    LockAll
    PlaySE SE_CONFIRM_sseq_3
    WaitSE SE_CONFIRM_sseq_3
    PlayCry SPECIES_GIRATINA
    Message TurnbackCaveGiratinaRoom_Text_GiratinaCry
    CloseMessage
    SetFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    StartLegendaryBattle SPECIES_GIRATINA, 70
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, TurnbackCaveGiratinaRoom_BlackOut
    CheckDidNotCapture VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, TurnbackCaveGiratinaRoom_DefeatedGiratina
    GoTo TurnbackCaveGiratinaRoom_CaughtGiratina
    End

TurnbackCaveGiratinaRoom_CaughtGiratina:
    SetFlag FLAG_CAUGHT_GIRATINA
    SetFlag FLAG_HIDE_TURNBACK_CAVE_GIRATINA_ROOM_GIRATINA
    ReleaseAll
    End

TurnbackCaveGiratinaRoom_DefeatedGiratina:
    Message TurnbackCaveGiratinaRoom_Text_GiratinaDisappeared
    WaitButton
    CloseMessage
    ReleaseAll
    End

TurnbackCaveGiratinaRoom_BlackOut:
    ClearFlag FLAG_HIDE_TURNBACK_CAVE_GIRATINA_ROOM_GIRATINA
    BlackOutFromBattle
    ReleaseAll
    End

TurnbackCaveGiratinaRoom_Item:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GoToIfEq VAR_TURNBACK_CAVE_ROOMS_VISITED, 3, TurnbackCaveGiratinaRoom_SetItemReaperCloth
    GoToIfLt VAR_TURNBACK_CAVE_ROOMS_VISITED, 15, TurnbackCaveGiratinaRoom_SetItemRareBone
    SetVar VAR_0x8004, ITEM_STARDUST
TurnbackCaveGiratinaRoom_GiveItem:
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, TurnbackCaveGiratinaRoom_BagIsFull
    Common_GiveItemQuantityNoLineFeed
    CloseMessage
    RemoveObject LOCALID_ITEM
    ReleaseAll
    End

TurnbackCaveGiratinaRoom_SetItemReaperCloth:
    SetVar VAR_0x8004, ITEM_REAPER_CLOTH
    GoTo TurnbackCaveGiratinaRoom_GiveItem

TurnbackCaveGiratinaRoom_SetItemRareBone:
    SetVar VAR_0x8004, ITEM_RARE_BONE
    GoTo TurnbackCaveGiratinaRoom_GiveItem

TurnbackCaveGiratinaRoom_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

TurnbackCaveGiratinaRoom_Inscription:
    EventMessage TurnbackCaveGiratinaRoom_Text_PlaceWhereWorldsOverlap
    End

TurnbackCaveGiratinaRoom_Portal:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    Message TurnbackCaveGiratinaRoom_Text_GoToDistortionWorld
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, TurnbackCaveGiratinaRoom_GoToDistortionWorld
    GoTo TurnbackCaveGiratinaRoom_PortalEnd
    End

TurnbackCaveGiratinaRoom_GoToDistortionWorld:
    BufferPlayerName 0
    Message TurnbackCaveGiratinaRoom_Text_PlayerLeaptIntoPortal
    CloseMessage
    PlaySE SEQ_SE_PL_SYUWA_sseq
    SetPartyGiratinaForm GIRATINA_FORM_ORIGIN
    FadeScreenOut
    WaitFadeScreen
    Warp MAP_HEADER_DISTORTION_WORLD_TURNBACK_CAVE_ROOM, 116, 75, DIR_SOUTH
    FadeScreenIn
    WaitFadeScreen
    End

TurnbackCaveGiratinaRoom_PortalEnd:
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Eternatus appears in the deepest room once Zacian and
@ Zamazenta are both caught, until it is caught.
TurnbackCaveGiratinaRoom_SovereignSetEternatusVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 4, TurnbackCaveGiratinaRoom_SovereignSetEternatusVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZACIAN, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, TurnbackCaveGiratinaRoom_SovereignSetEternatusVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZAMAZENTA, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, TurnbackCaveGiratinaRoom_SovereignSetEternatusVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ETERNATUS, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, TurnbackCaveGiratinaRoom_SovereignSetEternatusVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
TurnbackCaveGiratinaRoom_SovereignSetEternatusVisibilityEnd:
    Return

TurnbackCaveGiratinaRoom_RemoveLegendaryEternatus:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_ETERNATUS, TurnbackCaveGiratinaRoom_RemoveLegendaryEternatusEnd
    RemoveObject LOCALID_LEGENDARY_ETERNATUS
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
TurnbackCaveGiratinaRoom_RemoveLegendaryEternatusEnd:
    Return

TurnbackCaveGiratinaRoom_LegendaryEternatus:
    SetVar VAR_0x8004, SPECIES_ETERNATUS
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End
