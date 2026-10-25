#include "macros/scrcmd.inc"
#include "generated/hidden_locations.h"
#include "res/text/bank/route_224.h"
#include "res/field/events/events_route_224.h"


    ScriptEntry Route224_OnTransition
    ScriptEntry Route224_OnResume
    ScriptEntry Route224_Tablet
    ScriptEntry Route224_ProfOak
    ScriptEntry Route224_CoordEvent_Marley
    ScriptEntry Route224_Marley
    ScriptEntry Route224_OnLoad
    ScriptEntry Route224_LegendaryEnamorus
    ScriptEntry Route224_LegendaryPecharunt
    ScriptEntry Route224_SovereignCounterpart
    ScriptEntry Route224_SovereignNurse
    ScriptEntryEnd

Route224_OnTransition:
    Call Route224_SovereignSetPecharuntVisibility
    Call Route224_SovereignSetEnamorusVisibility
    CallIfEq VAR_SHAYMIN_EVENT_STATE, 1, Route224_IncreaseVars
    GoToIfSet FLAG_WROTE_ON_ROUTE_224_TABLET, Route224_DontHideProfOak
    CheckGameCompleted VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, FALSE, Route224_DontHideProfOak
    GetNationalDexEnabled VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, FALSE, Route224_DontHideProfOak
    @ Sovereign (E10, Renegade): no Shaymin distribution check; Oak gives his letter in Eterna City.
    CheckItem ITEM_OAKS_LETTER, 1, VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, FALSE, Route224_DontHideProfOak
    ClearFlag FLAG_HIDE_ROUTE_224_PROF_OAK
Route224_DontHideProfOak:
    Call Route224_SovereignSetCounterpart
    End

Route224_OnResume:
    GoToIfSet FLAG_WROTE_ON_ROUTE_224_TABLET, Route224_OnResumeEnd
    CallIfEq VAR_ROUTE_224_PROF_OAK_STATE, 1, Route224_SetProfOakDirNorth
Route224_OnResumeEnd:
    End

Route224_SetProfOakDirNorth:
    ScrCmd_18C LOCALID_PROF_OAK, DIR_NORTH
    Return

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Enamorus waits by the tablet, the Flower Paradise gate, once
@ Landorus is caught, until it's caught too.
Route224_SovereignSetEnamorusVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SovereignCheckSpeciesCaught SPECIES_LANDORUS, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route224_SovereignSetEnamorusVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ENAMORUS, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route224_SovereignSetEnamorusVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route224_SovereignSetEnamorusVisibilityEnd:
    Return

Route224_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route224_RemoveLegendaryPecharunt
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route224_RemoveLegendaryEnamorus
    End

Route224_RemoveLegendaryEnamorus:
    RemoveObject LOCALID_LEGENDARY_ENAMORUS
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route224_LegendaryEnamorus:
    SetVar VAR_0x8004, SPECIES_ENAMORUS
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

Route224_Unused:
    SetFlag FLAG_HIDE_ROUTE_224_MARLEY
    Return

Route224_IncreaseVars:
    SetVar VAR_SHAYMIN_EVENT_STATE, 2
    SetVar VAR_ROUTE_224_STATE, 1
    Return

Route224_Tablet:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_WROTE_ON_ROUTE_224_TABLET, Route224_NameWhomIThank
    Message Route224_Text_SurfaceIsUnmarked
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route224_NameWhomIThank:
    BufferTabletName 1
    Message Route224_Text_NameWhomIThank
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route224_ProfOak:
    GoToIfSet FLAG_WROTE_ON_ROUTE_224_TABLET, Route224_WhatWasThatPokemon2Return2
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    SetVar VAR_ROUTE_224_PROF_OAK_STATE, 1
    BufferPlayerName 0
    GetPlayerGender VAR_RESULT
    GoToIfEq VAR_RESULT, GENDER_FEMALE, Route224_ExamineTabletFemale
    Message Route224_Text_ExamineTabletMale
Route224_ExamineTablet:
    CloseMessage
    Call Route224_PlayerWalkToTabletFaceProfOak
    BufferPlayerName 0
    Message Route224_Text_SayThanksToWhom
    CloseMessage
Route224_ExpressThanks:
    FadeScreenOut
    WaitFadeScreen
    OpenShayminTabletNamingScreen VAR_RESULT
    FadeScreenIn
    WaitFadeScreen
    GoToIfEq VAR_RESULT, 1, Route224_NotSuggestingNoOne
    BufferPlayerName 0
    BufferTabletName 1
    Message Route224_Text_ExpressThanksToName
    ShowYesNoMenu VAR_RESULT
    CloseMessage
    GoToIfEq VAR_RESULT, MENU_NO, Route224_ExpressThanks
    Call Route224_PlayerProfOakFaceTablet
    WaitTime 15, VAR_RESULT
    FadeOutBGM 0, 10
    FadeScreenOut FADE_SCREEN_SPEED_SLOW, COLOR_WHITE
    WaitFadeScreen
    EnableHiddenLocation HIDDEN_LOCATION_SEABREAK_PATH
    SetPlayerVolume SOUND_VOLUME_MIN
    Warp MAP_HEADER_ROUTE_224, 908, 492, DIR_NORTH
    WaitTime 15, VAR_RESULT
    FadeScreenIn FADE_SCREEN_SPEED_SLOW, COLOR_WHITE
    WaitFadeScreen
    Call Route224_ShayminSceneMovement
    CallIfNe VAR_SHAYMIN_EVENT_STATE, 2, Route224_WhatWasThatPokemon2Return
    CallIfEq VAR_SHAYMIN_EVENT_STATE, 2, Route224_ThankYou
    WaitButton
    CloseMessage
    SetPlayerVolume SOUND_VOLUME_MAX
    FadeInBGM 10
    SetFlag FLAG_WROTE_ON_ROUTE_224_TABLET
    SetFlag FLAG_HIDE_ROUTE_224_PROF_OAK
    SetFlag FLAG_HIDE_ROUTE_224_MARLEY
    SetVar VAR_ROUTE_224_PROF_OAK_STATE, 0
    ReleaseAll
    End

Route224_WhatWasThatPokemon2Return:
    Message Route224_Text_WhatWasThatPokemon2
    Return

Route224_ThankYou:
    Message Route224_Text_WhatWasThatPokemon
    CloseMessage
    ApplyMovement LOCALID_MARLEY, Route224_Movement_MarleyWalkOnSpotEast
    WaitMovement
    ApplyMovement LOCALID_PLAYER, Route224_Movement_PlayerWalkOnSpotWest
    WaitMovement
    WaitTime 15, VAR_RESULT
    Message Route224_Text_ThankYou
    Return

Route224_ExamineTabletFemale:
    Message Route224_Text_ExamineTabletFemale
    GoTo Route224_ExamineTablet

Route224_NotSuggestingNoOne:
    Message Route224_Text_NotSuggestingNoOne
    CloseMessage
    GoTo Route224_ExpressThanks

Route224_WhatWasThatPokemon2Return2:
    NPCMessage Route224_Text_WhatWasThatPokemon2
    End

Route224_PlayerWalkToTabletFaceProfOak:
    GetPlayerMapPos VAR_0x8000, VAR_0x8001
    SetVar VAR_0x8008, VAR_0x8000
    GoToIfEq VAR_0x8008, 909, Route224_PlayerWalkToTabletFaceProfOakX909
    GoToIfEq VAR_0x8008, 910, Route224_PlayerWalkToTabletFaceProfOakX910
    ApplyMovement LOCALID_PLAYER, Route224_Movement_PlayerFaceTabletThenProfOak
    WaitMovement
    Return

Route224_PlayerWalkToTabletFaceProfOakX909:
    ApplyMovement LOCALID_PLAYER, Route224_Movement_PlayerWalkToTabletFaceProfOakX909
    ApplyMovement LOCALID_PROF_OAK, Route224_Movement_ProfOakWatchPlayerWalkToTabletX909
    WaitMovement
    Return

Route224_PlayerWalkToTabletFaceProfOakX910:
    ApplyMovement LOCALID_PLAYER, Route224_Movement_PlayerWalkToTabletFaceProfOakX910
    ApplyMovement LOCALID_PROF_OAK, Route224_Movement_ProfOakWatchPlayerWalkToTabletX910
    WaitMovement
    Return

Route224_PlayerProfOakFaceTablet:
    ApplyMovement LOCALID_PLAYER, Route224_Movement_FaceNorth
    ApplyMovement LOCALID_PROF_OAK, Route224_Movement_FaceNorth
    WaitMovement
    Return

Route224_MarleyNoticeShaymin:
    ApplyMovement LOCALID_MARLEY, Route224_Movement_MarleyNoticeShaymin
    Return

Route224_ShayminSceneMovement:
    ApplyMovement LOCALID_PROF_OAK, Route224_Movement_ProfOakLookAround
    ApplyMovement LOCALID_PLAYER, Route224_Movement_PlayerLookAround
    ApplyMovement LOCALID_SHAYMIN, Route224_Movement_ShayminEnter
    WaitMovement
    PlayCry SPECIES_SHAYMIN
    WaitCry
    CallIfEq VAR_SHAYMIN_EVENT_STATE, 2, Route224_MarleyNoticeShaymin
    ApplyMovement LOCALID_PROF_OAK, Route224_Movement_ProfOakNoticeShaymin
    ApplyMovement LOCALID_SHAYMIN, Route224_Movement_ShayminNoticePeople
    ApplyMovement LOCALID_PLAYER, Route224_Movement_PlayerNoticeShaymin
    WaitMovement
    ApplyMovement LOCALID_SHAYMIN, Route224_Movement_ShayminLeave
    WaitMovement
    SetFlag FLAG_HIDE_ROUTE_224_SHAYMIN
    RemoveObject LOCALID_SHAYMIN
    PlayCry SPECIES_SHAYMIN
    WaitCry
    ApplyMovement LOCALID_PROF_OAK, Route224_Movement_ProfOakFaceWest
    WaitMovement
    Return

    .balign 4, 0
Route224_Movement_PlayerFaceTabletThenProfOak:
    FaceNorth
    Delay16
    FaceEast
    EndMovement

    .balign 4, 0
Route224_Movement_PlayerWalkToTabletFaceProfOakX909:
    WalkNormalWest
    WalkNormalNorth
    Delay16
    FaceEast
    EndMovement

    .balign 4, 0
Route224_Movement_PlayerWalkToTabletFaceProfOakX910:
    WalkNormalSouth
    WalkNormalWest 2
    WalkNormalNorth
    Delay16
    FaceEast
    EndMovement

    .balign 4, 0
Route224_Movement_ProfOakWatchPlayerWalkToTabletX909:
    Delay8
    FaceWest
    EndMovement

    .balign 4, 0
Route224_Movement_ProfOakWatchPlayerWalkToTabletX910:
    Delay8
    FaceSouth
    Delay8 2
    FaceWest
    EndMovement

    .balign 4, 0
Route224_Movement_FaceNorth:
    FaceNorth
    EndMovement

    .balign 4, 0
Route224_Movement_ProfOakNoticeShaymin:
    FaceEast
    EmoteExclamationMark
    Delay16
    EndMovement

    .balign 4, 0
Route224_Movement_PlayerNoticeShaymin:
    Delay16
    FaceEast
    EmoteExclamationMark
    Delay16
    EndMovement

    .balign 4, 0
Route224_Movement_ShayminNoticePeople:
    FaceWest
    EmoteExclamationMark
    Delay16
    EndMovement

    .balign 4, 0
Route224_Movement_ProfOakFaceWest:
    FaceWest
    EndMovement

    .balign 4, 0
Route224_Movement_PlayerLookAround:
    FaceWest
    Delay16
    FaceSouth
    Delay16
    FaceEast
    Delay16
    FaceSouth
    Delay16
    FaceWest
    Delay16
    FaceNorth
    Delay16
    FaceSouth
    Delay16
    EndMovement

    .balign 4, 0
Route224_Movement_ProfOakLookAround:
    FaceSouth
    Delay16
    FaceEast
    Delay16
    FaceSouth
    Delay16
    FaceWest
    Delay16
    FaceNorth
    Delay16
    EndMovement

Route224_Movement_Unused:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
Route224_Movement_PlayerWalkOnSpotWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
Route224_Movement_ShayminEnter:
    WalkNormalSouth 12
    EndMovement

    .balign 4, 0
Route224_Movement_ShayminLeave:
    FaceNorth
    Delay16
    WalkSlightlyFastNorth 12
    EndMovement

Route224_CoordEvent_Marley:
    LockAll
    ClearFlag FLAG_HIDE_ROUTE_224_MARLEY
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8005, 496, Route224_MarleyWalkToPlayerZ496
    GoToIfEq VAR_0x8005, 497, Route224_MarleyWalkToPlayerZ497
    GoToIfEq VAR_0x8005, 498, Route224_MarleyWalkToPlayerZ498
    End

Route224_MarleyWalkToPlayerZ496:
    SetObjectEventPos LOCALID_MARLEY, 902, 504
    AddObject LOCALID_MARLEY
    LockObject LOCALID_MARLEY
    ApplyMovement LOCALID_MARLEY, Route224_Movement_MarleyWalkToPlayerZ496
    WaitMovement
    GoTo Route224_PokemonThatConveysGratitude
    End

Route224_MarleyWalkToPlayerZ497:
    SetObjectEventPos LOCALID_MARLEY, 902, 505
    AddObject LOCALID_MARLEY
    LockObject LOCALID_MARLEY
    ApplyMovement LOCALID_MARLEY, Route224_Movement_MarleyWalkToPlayerZ497
    WaitMovement
    GoTo Route224_PokemonThatConveysGratitude
    End

Route224_MarleyWalkToPlayerZ498:
    SetObjectEventPos LOCALID_MARLEY, 902, 506
    AddObject LOCALID_MARLEY
    LockObject LOCALID_MARLEY
    ApplyMovement LOCALID_MARLEY, Route224_Movement_MarleyWalkToPlayerZ498
    WaitMovement
    GoTo Route224_PokemonThatConveysGratitude
    End

Route224_PokemonThatConveysGratitude:
    ApplyMovement LOCALID_PLAYER, Route224_Movement_PlayerWalkOnSpotWest2
    WaitMovement
    Message Route224_Text_PokemonThatConveysGratitude
    CloseMessage
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_0x8005, 496, Route224_MarleyWalkToTabletZ496
    GoToIfEq VAR_0x8005, 497, Route224_MarleyWalkToTabletZ497
    GoToIfEq VAR_0x8005, 498, Route224_MarleyWalkToTabletZ498
    End

Route224_MarleyWalkToTabletZ496:
    ApplyMovement LOCALID_MARLEY, Route224_Movement_MarleyWalkToTabletZ496
    ApplyMovement LOCALID_PLAYER, Route224_Movement_PlayerWatchMarleyWalkToTabletZ496
    WaitMovement
    GoTo Route224_ThatStoneTablet
    End

Route224_MarleyWalkToTabletZ497:
    ApplyMovement LOCALID_MARLEY, Route224_Movement_MarleyWalkToTabletZ497
    ApplyMovement LOCALID_PLAYER, Route224_Movement_PlayerWatchMarleyWalkToTabletZ497
    WaitMovement
    GoTo Route224_ThatStoneTablet
    End

Route224_MarleyWalkToTabletZ498:
    ApplyMovement LOCALID_MARLEY, Route224_Movement_MarleyWalkToTabletZ498
    ApplyMovement LOCALID_PLAYER, Route224_Movement_PlayerWatchMarleyWalkToTabletZ498
    WaitMovement
    GoTo Route224_ThatStoneTablet
    End

Route224_ThatStoneTablet:
    SetVar VAR_SHAYMIN_EVENT_STATE, 2
    SetVar VAR_ROUTE_224_STATE, 2
    Message Route224_Text_ThatStoneTablet
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
Route224_Movement_MarleyWalkToPlayerZ496:
    WalkNormalNorth 8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
Route224_Movement_MarleyWalkToPlayerZ497:
    WalkNormalNorth 8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
Route224_Movement_MarleyWalkToPlayerZ498:
    WalkNormalNorth 8
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
Route224_Movement_MarleyWalkToTabletZ496:
    WalkNormalSouth
    WalkNormalEast 5
    WalkNormalNorth 4
    EndMovement

    .balign 4, 0
Route224_Movement_MarleyWalkToTabletZ497:
    WalkNormalNorth
    WalkNormalEast 5
    WalkNormalNorth 3
    EndMovement

    .balign 4, 0
Route224_Movement_MarleyWalkToTabletZ498:
    WalkNormalNorth 2
    WalkNormalEast 5
    WalkNormalNorth 3
    EndMovement

    .balign 4, 0
Route224_Movement_MarleyWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

Route224_Marley:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_WROTE_ON_ROUTE_224_TABLET, Route224_ThankYouToo
    Message Route224_Text_ThatStoneTablet
    WaitButton
    CloseMessage
    ApplyMovement LOCALID_MARLEY, Route224_Movement_MarleyFaceNorth
    WaitMovement
    ReleaseAll
    End

Route224_ThankYouToo:
    Message Route224_Text_ThankYouToo
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
Route224_Movement_PlayerWalkOnSpotWest2:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
Route224_Movement_PlayerWatchMarleyWalkToTabletZ496:
    Delay8 2
    WalkOnSpotNormalEast
    Delay8 4
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
Route224_Movement_PlayerWatchMarleyWalkToTabletZ497:
    Delay8 2
    WalkOnSpotNormalEast
    Delay8 3
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
Route224_Movement_PlayerWatchMarleyWalkToTabletZ498:
    Delay8 2
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
Route224_Movement_MarleyFaceNorth:
    FaceNorth
    EndMovement

    .balign 4, 0
Route224_Movement_MarleyNoticeShaymin:
    FaceEast
    EmoteExclamationMark
    EndMovement

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Pecharunt, the Loyal Three's master, appears once all three
@ are caught, until it is caught.
Route224_SovereignSetPecharuntVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route224_SovereignSetPecharuntVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_OKIDOGI, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route224_SovereignSetPecharuntVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MUNKIDORI, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route224_SovereignSetPecharuntVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_FEZANDIPITI, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route224_SovereignSetPecharuntVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_PECHARUNT, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route224_SovereignSetPecharuntVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
Route224_SovereignSetPecharuntVisibilityEnd:
    Return

Route224_RemoveLegendaryPecharunt:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_PECHARUNT, Route224_RemoveLegendaryPecharuntEnd
    RemoveObject LOCALID_LEGENDARY_PECHARUNT
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route224_RemoveLegendaryPecharuntEnd:
    Return

Route224_LegendaryPecharunt:
    SetVar VAR_0x8004, SPECIES_PECHARUNT
    SetVar VAR_0x8005, 60
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (E10, Renegade): the counterpart waits by the stone tablet for a last battle before the League rematches
@ (Renegade's trainers 975-980, by the player's starter). They leave once beaten, and stay out of the way while
@ Professor Oak's Shaymin scene is on.
Route224_SovereignSetCounterpart:
    GetPlayerGender VAR_RESULT
    CallIfEq VAR_RESULT, GENDER_MALE, Route224_SovereignSetCounterpartDawn
    CallIfEq VAR_RESULT, GENDER_FEMALE, Route224_SovereignSetCounterpartLucas
    ClearFlag FLAG_MAP_LOCAL_HIDE_SOVEREIGN_NPC
    GoToIfUnset FLAG_HIDE_ROUTE_224_PROF_OAK, Route224_SovereignHideCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_CHIMCHAR, Route224_SovereignHideCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_PIPLUP, Route224_SovereignHideCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_TURTWIG, Route224_SovereignHideCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_CHIMCHAR, Route224_SovereignHideCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_PIPLUP, Route224_SovereignHideCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_TURTWIG, Route224_SovereignHideCounterpart
    Return

Route224_SovereignHideCounterpart:
    SetFlag FLAG_MAP_LOCAL_HIDE_SOVEREIGN_NPC
    Return

Route224_SovereignSetCounterpartDawn:
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_PLAYER_F
    Return

Route224_SovereignSetCounterpartLucas:
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_PLAYER_M
    Return

Route224_SovereignCounterpart:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    BufferPlayerName 0
    GetPlayerGender VAR_RESULT
    GoToIfSet FLAG_SOVEREIGN_ROUTE_224_COUNTERPART_MET, Route224_SovereignAskCounterpart
    GoToIfEq VAR_RESULT, GENDER_FEMALE, Route224_SovereignMeetLucas
    GoTo Route224_SovereignMeetDawn

Route224_SovereignAskCounterpart:
    FacePlayer
    GoToIfEq VAR_RESULT, GENDER_FEMALE, Route224_SovereignAskLucas
    GoTo Route224_SovereignAskDawn

Route224_SovereignMeetDawn:
    Message Route224_Text_SovereignDawnThisStoneTablet
    CloseMessage
    FacePlayer
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route224_SovereignMovement_CounterpartNotice
    WaitMovement
    BufferPlayerName 0
    Message Route224_Text_SovereignDawnLetsBattleAgain
    WaitButton
    CloseMessage
    SetFlag FLAG_SOVEREIGN_ROUTE_224_COUNTERPART_MET
    ReleaseAll
    End

Route224_SovereignAskDawn:
    Message Route224_Text_SovereignDawnReadyToBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route224_SovereignNotReadyDawn
    Message Route224_Text_SovereignDawnLetsGetStarted
    CloseMessage
    GetPlayerStarterSpecies VAR_RESULT
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_DAWN_ROUTE_224_TURTWIG
    CallIfEq VAR_RESULT, SPECIES_CHIMCHAR, Route224_SovereignSetDawnChimchar
    CallIfEq VAR_RESULT, SPECIES_PIPLUP, Route224_SovereignSetDawnPiplup
    StartTrainerBattle VAR_MAP_LOCAL_0x01
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route224_SovereignCounterpartLost
    SetTrainerFlag VAR_MAP_LOCAL_0x01
    BufferPlayerName 0
    Message Route224_Text_SovereignDawnYouveGrown
    CloseMessage
    GoTo Route224_SovereignCounterpartLeave

Route224_SovereignSetDawnChimchar:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_DAWN_ROUTE_224_CHIMCHAR
    Return

Route224_SovereignSetDawnPiplup:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_DAWN_ROUTE_224_PIPLUP
    Return

Route224_SovereignNotReadyDawn:
    Message Route224_Text_SovereignDawnGoGetReady
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route224_SovereignMeetLucas:
    Message Route224_Text_SovereignLucasThisStoneTablet
    CloseMessage
    FacePlayer
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route224_SovereignMovement_CounterpartNotice
    WaitMovement
    BufferPlayerName 0
    Message Route224_Text_SovereignLucasLetsBattleAgain
    WaitButton
    CloseMessage
    SetFlag FLAG_SOVEREIGN_ROUTE_224_COUNTERPART_MET
    ReleaseAll
    End

Route224_SovereignAskLucas:
    Message Route224_Text_SovereignLucasReadyToBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Route224_SovereignNotReadyLucas
    Message Route224_Text_SovereignLucasLetsGetStarted
    CloseMessage
    GetPlayerStarterSpecies VAR_RESULT
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_LUCAS_ROUTE_224_TURTWIG
    CallIfEq VAR_RESULT, SPECIES_CHIMCHAR, Route224_SovereignSetLucasChimchar
    CallIfEq VAR_RESULT, SPECIES_PIPLUP, Route224_SovereignSetLucasPiplup
    StartTrainerBattle VAR_MAP_LOCAL_0x01
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route224_SovereignCounterpartLost
    SetTrainerFlag VAR_MAP_LOCAL_0x01
    BufferPlayerName 0
    Message Route224_Text_SovereignLucasYouveGrown
    CloseMessage
    GoTo Route224_SovereignCounterpartLeave

Route224_SovereignSetLucasChimchar:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_LUCAS_ROUTE_224_CHIMCHAR
    Return

Route224_SovereignSetLucasPiplup:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_LUCAS_ROUTE_224_PIPLUP
    Return

Route224_SovereignNotReadyLucas:
    Message Route224_Text_SovereignLucasGoGetReady
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route224_SovereignCounterpartLost:
    BlackOutFromBattle
    ReleaseAll
    End

Route224_SovereignCounterpartLeave:
    GetPlayerDir VAR_RESULT
    GoToIfEq VAR_RESULT, DIR_NORTH, Route224_SovereignCounterpartLeaveBehindPlayer
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route224_SovereignMovement_CounterpartLeave
    WaitMovement
    GoTo Route224_SovereignCounterpartGone

Route224_SovereignCounterpartLeaveBehindPlayer:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route224_SovereignMovement_CounterpartLeaveAroundPlayer
    WaitMovement
Route224_SovereignCounterpartGone:
    RemoveObject LOCALID_SOVEREIGN_COUNTERPART
    ReleaseAll
    End

@ Sovereign (E10, Renegade): a nurse at the Victory Road entrance heals the party.
Route224_SovereignNurse:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message Route224_Text_SovereignNurseHeal
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Message Route224_Text_SovereignNurseGoodLuck
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
Route224_SovereignMovement_CounterpartNotice:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route224_SovereignMovement_CounterpartLeaveAroundPlayer:
    WalkNormalWest
    WalkNormalSouth 3
    WalkNormalWest 4
    WalkNormalSouth 5
    EndMovement

    .balign 4, 0
Route224_SovereignMovement_CounterpartLeave:
    WalkNormalSouth 3
    WalkNormalWest 5
    WalkNormalSouth 5
    EndMovement

    .balign 4, 0
