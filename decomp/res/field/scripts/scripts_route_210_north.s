#include "macros/scrcmd.inc"
#include "res/field/events/events_route_210_north.h"
#include "res/text/bank/route_210_north.h"


    ScriptEntry Route210North_BlackBelt
    ScriptEntry Route210North_ArrowSignpostCelesticTown
    ScriptEntry Route210North_SignboardGrandmaWilmasHouse
    ScriptEntry Route210North_SovereignOnTransition
    ScriptEntry Route210North_SovereignOnLoad
    ScriptEntry Route210North_LegendaryZacian
    ScriptEntry Route210North_LegendaryZamazenta
    ScriptEntry Route210North_SovereignCounterpartBattle
    ScriptEntryEnd

Route210North_BlackBelt:
    NPCMessage Route210North_Text_HowDoesDefogWork
    End

Route210North_ArrowSignpostCelesticTown:
    ShowArrowSign Route210North_Text_SignCelesticTown
    End

Route210North_SignboardGrandmaWilmasHouse:
    ShowLandmarkSign Route210North_Text_SignGrandmaWilmasHouse
    End

    .balign 4, 0

Route210North_SovereignOnTransition:
    Call Route210North_SovereignSetZamazentaVisibility
    Call Route210North_SovereignSetZacianVisibility
    End

Route210North_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route210North_RemoveLegendaryZamazenta
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route210North_RemoveLegendaryZacian
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Zacian, holding the Rusted Sword, waits in the fog once the
@ Galar Chronicle is open, until it is caught.
Route210North_SovereignSetZacianVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 4, Route210North_SovereignSetZacianVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZACIAN, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route210North_SovereignSetZacianVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route210North_SovereignSetZacianVisibilityEnd:
    Return

Route210North_RemoveLegendaryZacian:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_ZACIAN, Route210North_RemoveLegendaryZacianEnd
    RemoveObject LOCALID_LEGENDARY_ZACIAN
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route210North_RemoveLegendaryZacianEnd:
    Return

Route210North_LegendaryZacian:
    SetVar VAR_SOVEREIGN_LEGENDARY_HELD_ITEM, ITEM_RUSTED_SWORD
    SetVar VAR_0x8004, SPECIES_ZACIAN
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Zamazenta, holding the Rusted Shield, comes to the fog once
@ Zacian is caught, until it is caught.
Route210North_SovereignSetZamazentaVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 4, Route210North_SovereignSetZamazentaVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZACIAN, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route210North_SovereignSetZamazentaVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZAMAZENTA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route210North_SovereignSetZamazentaVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
Route210North_SovereignSetZamazentaVisibilityEnd:
    Return

Route210North_RemoveLegendaryZamazenta:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_ZAMAZENTA, Route210North_RemoveLegendaryZamazentaEnd
    RemoveObject LOCALID_LEGENDARY_ZAMAZENTA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route210North_RemoveLegendaryZamazentaEnd:
    Return

Route210North_LegendaryZamazenta:
    SetVar VAR_SOVEREIGN_LEGENDARY_HELD_ITEM, ITEM_RUSTED_SHIELD
    SetVar VAR_0x8004, SPECIES_ZAMAZENTA
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (E10, Renegade's Route 210 battle): the first time the player walks north past the fog, the counterpart
@ comes over, heals the party and battles (their team depends on the player's starter: Renegade's trainers 963-968).
Route210North_SovereignCounterpartBattle:
    LockAll
    GetPlayerGender VAR_RESULT
    CallIfEq VAR_RESULT, GENDER_MALE, Route210North_SovereignSetCounterpartDawn
    CallIfEq VAR_RESULT, GENDER_FEMALE, Route210North_SovereignSetCounterpartLucas
    RemoveObject LOCALID_SOVEREIGN_COUNTERPART
    SetObjectEventPos LOCALID_SOVEREIGN_COUNTERPART, 489, 530
    AddObject LOCALID_SOVEREIGN_COUNTERPART
    LockObject LOCALID_SOVEREIGN_COUNTERPART
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartNotice
    WaitMovement
    Common_SetCounterpartBGM
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8005, 528, Route210North_SovereignCounterpartApproach528
    CallIfEq VAR_0x8005, 529, Route210North_SovereignCounterpartApproach529
    CallIfEq VAR_0x8005, 530, Route210North_SovereignCounterpartApproach530
    CallIfEq VAR_0x8005, 531, Route210North_SovereignCounterpartApproach531
    CallIfEq VAR_0x8005, 532, Route210North_SovereignCounterpartApproach532
    ApplyMovement LOCALID_PLAYER, Route210North_SovereignMovement_PlayerFaceEast
    WaitMovement
    BufferPlayerName 0
    GetPlayerGender VAR_RESULT
    GoToIfEq VAR_RESULT, GENDER_FEMALE, Route210North_SovereignCounterpartLucas
    GoTo Route210North_SovereignCounterpartDawn

Route210North_SovereignSetCounterpartDawn:
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_PLAYER_F
    Return

Route210North_SovereignSetCounterpartLucas:
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_PLAYER_M
    Return

Route210North_SovereignCounterpartDawn:
    Message Route210North_Text_SovereignCounterpartDawnHi
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Message Route210North_Text_SovereignCounterpartDawnLetsBattle
    CloseMessage
    GetPlayerStarterSpecies VAR_0x8004
    GoToIfEq VAR_0x8004, SPECIES_TURTWIG, Route210North_SovereignCounterpartDawnTurtwig
    GoToIfEq VAR_0x8004, SPECIES_CHIMCHAR, Route210North_SovereignCounterpartDawnChimchar
    StartTrainerBattle TRAINER_SOVEREIGN_DAWN_ROUTE_210_PIPLUP
    GoTo Route210North_SovereignCounterpartDawnBattleEnd

Route210North_SovereignCounterpartDawnTurtwig:
    StartTrainerBattle TRAINER_SOVEREIGN_DAWN_ROUTE_210_TURTWIG
    GoTo Route210North_SovereignCounterpartDawnBattleEnd

Route210North_SovereignCounterpartDawnChimchar:
    StartTrainerBattle TRAINER_SOVEREIGN_DAWN_ROUTE_210_CHIMCHAR
    GoTo Route210North_SovereignCounterpartDawnBattleEnd

Route210North_SovereignCounterpartDawnBattleEnd:
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route210North_SovereignCounterpartLost
    BufferPlayerName 0
    Message Route210North_Text_SovereignCounterpartDawnSeeYou
    CloseMessage
    GoTo Route210North_SovereignCounterpartLeave

Route210North_SovereignCounterpartLucas:
    Message Route210North_Text_SovereignCounterpartLucasHi
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Message Route210North_Text_SovereignCounterpartLucasLetsBattle
    CloseMessage
    GetPlayerStarterSpecies VAR_0x8004
    GoToIfEq VAR_0x8004, SPECIES_TURTWIG, Route210North_SovereignCounterpartLucasTurtwig
    GoToIfEq VAR_0x8004, SPECIES_CHIMCHAR, Route210North_SovereignCounterpartLucasChimchar
    StartTrainerBattle TRAINER_SOVEREIGN_LUCAS_ROUTE_210_PIPLUP
    GoTo Route210North_SovereignCounterpartLucasBattleEnd

Route210North_SovereignCounterpartLucasTurtwig:
    StartTrainerBattle TRAINER_SOVEREIGN_LUCAS_ROUTE_210_TURTWIG
    GoTo Route210North_SovereignCounterpartLucasBattleEnd

Route210North_SovereignCounterpartLucasChimchar:
    StartTrainerBattle TRAINER_SOVEREIGN_LUCAS_ROUTE_210_CHIMCHAR
    GoTo Route210North_SovereignCounterpartLucasBattleEnd

Route210North_SovereignCounterpartLucasBattleEnd:
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Route210North_SovereignCounterpartLost
    BufferPlayerName 0
    Message Route210North_Text_SovereignCounterpartLucasSeeYou
    CloseMessage
    GoTo Route210North_SovereignCounterpartLeave

Route210North_SovereignCounterpartLost:
    RemoveObject LOCALID_SOVEREIGN_COUNTERPART
    Common_FadeToDefaultMusic
    BlackOutFromBattle
    ReleaseAll
    End

Route210North_SovereignCounterpartLeave:
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    CallIfEq VAR_0x8005, 528, Route210North_SovereignCounterpartLeave528
    CallIfEq VAR_0x8005, 529, Route210North_SovereignCounterpartLeave529
    CallIfEq VAR_0x8005, 530, Route210North_SovereignCounterpartLeave530
    CallIfEq VAR_0x8005, 531, Route210North_SovereignCounterpartLeave531
    CallIfEq VAR_0x8005, 532, Route210North_SovereignCounterpartLeave532
    RemoveObject LOCALID_SOVEREIGN_COUNTERPART
    Common_FadeToDefaultMusic
    SetVar VAR_SOVEREIGN_ROUTE_210_COUNTERPART_STATE, 1
    ReleaseAll
    End

Route210North_SovereignCounterpartApproach528:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartApproach528
    WaitMovement
    Return

Route210North_SovereignCounterpartLeave528:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartLeave528
    WaitMovement
    Return

Route210North_SovereignCounterpartApproach529:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartApproach529
    WaitMovement
    Return

Route210North_SovereignCounterpartLeave529:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartLeave529
    WaitMovement
    Return

Route210North_SovereignCounterpartApproach530:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartApproach530
    WaitMovement
    Return

Route210North_SovereignCounterpartLeave530:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartLeave530
    WaitMovement
    Return

Route210North_SovereignCounterpartApproach531:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartApproach531
    WaitMovement
    Return

Route210North_SovereignCounterpartLeave531:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartLeave531
    WaitMovement
    Return

Route210North_SovereignCounterpartApproach532:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartApproach532
    WaitMovement
    Return

Route210North_SovereignCounterpartLeave532:
    ApplyMovement LOCALID_SOVEREIGN_COUNTERPART, Route210North_SovereignMovement_CounterpartLeave532
    WaitMovement
    Return

    .balign 4, 0
Route210North_SovereignMovement_CounterpartNotice:
    WalkNormalWest 3
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_PlayerFaceEast:
    FaceEast
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_CounterpartApproach528:
    WalkNormalWest 3
    WalkNormalNorth 2
    WalkNormalWest 2
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_CounterpartLeave528:
    WalkNormalEast 3
    WalkNormalSouth 2
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_CounterpartApproach529:
    WalkNormalWest 3
    WalkNormalNorth
    WalkNormalWest 2
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_CounterpartLeave529:
    WalkNormalEast 3
    WalkNormalSouth
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_CounterpartApproach530:
    WalkNormalWest 5
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_CounterpartLeave530:
    WalkNormalEast 8
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_CounterpartApproach531:
    WalkNormalWest 3
    WalkNormalSouth
    WalkNormalWest 2
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_CounterpartLeave531:
    WalkNormalEast 3
    WalkNormalNorth
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_CounterpartApproach532:
    WalkNormalWest 3
    WalkNormalSouth 2
    WalkNormalWest 2
    EndMovement

    .balign 4, 0
Route210North_SovereignMovement_CounterpartLeave532:
    WalkNormalEast 3
    WalkNormalNorth 2
    WalkNormalEast 5
    EndMovement

    .balign 4, 0
