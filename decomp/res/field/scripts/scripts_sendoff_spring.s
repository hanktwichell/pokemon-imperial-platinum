#include "macros/scrcmd.inc"
#include "res/text/bank/sendoff_spring.h"
#include "res/field/events/events_sendoff_spring.h"


    ScriptEntry SendoffSpring_OnFrame_Cynthia
    ScriptEntry SendoffSpring_Cynthia
    ScriptEntry SendoffSpring_OnTransition
    ScriptEntry SendoffSpring_SovereignOnLoad
    ScriptEntry SendoffSpring_LegendaryKoraidon
    ScriptEntry SendoffSpring_LegendaryMiraidon
    ScriptEntry SendoffSpring_LegendaryTerapagos
    ScriptEntryEnd

SendoffSpring_OnTransition:
    Call SendoffSpring_SovereignSetTerapagosVisibility
    Call SendoffSpring_SovereignSetMiraidonVisibility
    Call SendoffSpring_SovereignSetKoraidonVisibility
    CallIfSet FLAG_CAUGHT_GIRATINA, SendoffSpring_ShowTurnbackCaveItem
    End

SendoffSpring_ShowTurnbackCaveItem:
    ClearFlag FLAG_HIDE_TURNBACK_CAVE_GIRATINA_ROOM_ITEM
    Return

SendoffSpring_OnFrame_Cynthia:
    LockAll
    SetPartyGiratinaForm GIRATINA_FORM_ALTERED
    ScrCmd_2B5 MAP_HEADER_UNKNOWN_266, 762, 714
    Message SendoffSpring_Text_ThisPlace
    CloseMessage
    ApplyMovement LOCALID_CYNTHIA, SendoffSpring_Movement_CynthiaLookAround
    WaitMovement
    ApplyMovement LOCALID_PLAYER, SendoffSpring_Movement_PlayerWalkOnSpotWest
    WaitMovement
    Message SendoffSpring_Text_ItsTheSendoffSpring
    CloseMessage
    ApplyMovement LOCALID_CYNTHIA, SendoffSpring_Movement_CynthiaWalkOnSpotEast
    WaitMovement
    BufferPlayerName 0
    Message SendoffSpring_Text_YouShouldVisitProfRowan
    WaitButton
    CloseMessage
    SetVar VAR_EXITED_DISTORTION_WORLD_STATE, 2
    SetVar VAR_SANDGEM_TOWN_LAB_STATE, 2
    SetFlag FLAG_HIDE_SPEAR_PILLAR_DISTORTED_TEAM_GALACTIC
    ClearFlag FLAG_SPEAR_PILLAR_IS_DISTORTED
    SetFlag FLAG_HIDE_MT_CORONET_GALACTIC_GRUNTS
    SetFlag FLAG_HIDE_MT_CORONET_1F_NORTH_ROOM_1_GRUNT_F
    SetFlag FLAG_HIDE_MT_CORONET_2F_LOOKER
    SetFlag FLAG_ALT_MUSIC_GALACTIC_HQ_1F
    ClearFlag FLAG_HIDE_GALACTIC_HQ_1F_SATURN
    SetFlag FLAG_GALACTIC_LEFT_LAKE_VALOR
    SetFlag FLAG_HIDE_MT_CORONET_1F_NORTH_ROOM_1_GRUNT_F
    ReleaseAll
    End

    .balign 4, 0
SendoffSpring_Movement_PlayerWalkOnSpotWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
SendoffSpring_Movement_CynthiaLookAround:
    WalkOnSpotFastWest
    Delay8
    WalkOnSpotFastEast
    Delay8 2
    WalkOnSpotFastNorth
    EndMovement

    .balign 4, 0
SendoffSpring_Movement_CynthiaWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

SendoffSpring_Cynthia:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfGe VAR_EXITED_DISTORTION_WORLD_STATE, 3, SendoffSpring_IWishIBattledGiratina
    Message SendoffSpring_Text_GoTellProfRowan
    GoTo SendoffSpring_CynthiaEnd
    End

SendoffSpring_IWishIBattledGiratina:
    Message SendoffSpring_Text_IWishIBattledGiratina
    GoTo SendoffSpring_CynthiaEnd
    End

SendoffSpring_CynthiaEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0

SendoffSpring_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, SendoffSpring_RemoveLegendaryTerapagos
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, SendoffSpring_RemoveLegendaryMiraidon
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, SendoffSpring_RemoveLegendaryKoraidon
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Koraidon appears once the Oreburgh Mining Museum's fossil
@ maniac has given all ten ancient Paradox Pokemon (owner, 2026-10-24), until it is caught.
SendoffSpring_SovereignSetKoraidonVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, SendoffSpring_SovereignSetKoraidonVisibilityEnd
    SovereignCheckParadoxEraComplete 0, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SendoffSpring_SovereignSetKoraidonVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_KORAIDON, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SendoffSpring_SovereignSetKoraidonVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
SendoffSpring_SovereignSetKoraidonVisibilityEnd:
    Return

SendoffSpring_RemoveLegendaryKoraidon:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_KORAIDON, SendoffSpring_RemoveLegendaryKoraidonEnd
    RemoveObject LOCALID_LEGENDARY_KORAIDON
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
SendoffSpring_RemoveLegendaryKoraidonEnd:
    Return

SendoffSpring_LegendaryKoraidon:
    SetVar VAR_0x8004, SPECIES_KORAIDON
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Miraidon appears once the Oreburgh Mining Museum's
@ futuristic scientist has given all ten future Paradox Pokemon (owner, 2026-10-24), until it is caught.
SendoffSpring_SovereignSetMiraidonVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, SendoffSpring_SovereignSetMiraidonVisibilityEnd
    SovereignCheckParadoxEraComplete 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SendoffSpring_SovereignSetMiraidonVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MIRAIDON, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SendoffSpring_SovereignSetMiraidonVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
SendoffSpring_SovereignSetMiraidonVisibilityEnd:
    Return

SendoffSpring_RemoveLegendaryMiraidon:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_MIRAIDON, SendoffSpring_RemoveLegendaryMiraidonEnd
    RemoveObject LOCALID_LEGENDARY_MIRAIDON
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
SendoffSpring_RemoveLegendaryMiraidonEnd:
    Return

SendoffSpring_LegendaryMiraidon:
    SetVar VAR_0x8004, SPECIES_MIRAIDON
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Terapagos appears once Koraidon and Miraidon are both
@ caught, until it is caught.
SendoffSpring_SovereignSetTerapagosVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, SendoffSpring_SovereignSetTerapagosVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_KORAIDON, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SendoffSpring_SovereignSetTerapagosVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MIRAIDON, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SendoffSpring_SovereignSetTerapagosVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_TERAPAGOS, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SendoffSpring_SovereignSetTerapagosVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
SendoffSpring_SovereignSetTerapagosVisibilityEnd:
    Return

SendoffSpring_RemoveLegendaryTerapagos:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_TERAPAGOS, SendoffSpring_RemoveLegendaryTerapagosEnd
    RemoveObject LOCALID_LEGENDARY_TERAPAGOS
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
SendoffSpring_RemoveLegendaryTerapagosEnd:
    Return

SendoffSpring_LegendaryTerapagos:
    SetVar VAR_0x8004, SPECIES_TERAPAGOS
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End
