#include "macros/scrcmd.inc"
#include "generated/distribution_events.h"
#include "res/text/bank/spear_pillar.h"
#include "res/field/events/events_spear_pillar.h"
#include "constants/versions.h"


    ScriptEntry SpearPillar_OnTransition
    ScriptEntry SpearPillar_OnLoad
    ScriptEntry SpearPillar_CoordEvent_Grunts
    ScriptEntry SpearPillar_Cyrus
    ScriptEntry SpearPillar_CoordEvent_MarsJupiter
    ScriptEntry SpearPillar_Grunts
    ScriptEntry SpearPillar_Jupiter
    ScriptEntry SpearPillar_Mars
    ScriptEntry SpearPillar_LegendaryCosmog
    ScriptEntry SpearPillar_LegendaryNecrozma
    ScriptEntry SpearPillar_SovereignAncientRift
    ScriptEntry SpearPillar_SovereignFutureRift
    ScriptEntryEnd

SpearPillar_OnTransition:
    Call SpearPillar_SovereignSetRiftsVisibility
    SetFlag FLAG_FIRST_ARRIVAL_SPEAR_PILLAR
    Call SpearPillar_SovereignSetSkyVisibility
    Call SpearPillar_TryHideRival
    Call SpearPillar_TryEnableHallOfOrigin
    GetPlayerGender VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, GENDER_MALE, SpearPillar_SetCounterpartGraphicsDawn
    GoToIfEq VAR_MAP_LOCAL_0x00, GENDER_FEMALE, SpearPillar_SetCounterpartGraphicsLucas
    End

SpearPillar_SetCounterpartGraphicsDawn:
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_PLAYER_F
    End

SpearPillar_SetCounterpartGraphicsLucas:
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_PLAYER_M
    End

SpearPillar_TryEnableHallOfOrigin:
    CheckGameCompleted VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, FALSE, SpearPillar_TryEnableHallOfOriginEnd
    GetNationalDexEnabled VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, FALSE, SpearPillar_TryEnableHallOfOriginEnd
    CheckItem ITEM_AZURE_FLUTE, 1, VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, FALSE, SpearPillar_TryEnableHallOfOriginEnd
    CheckDistributionEvent DISTRIBUTION_EVENT_ARCEUS, VAR_MAP_LOCAL_0x00
    GoToIfEq VAR_MAP_LOCAL_0x00, FALSE, SpearPillar_TryEnableHallOfOriginEnd
    GoToIfSet FLAG_CAUGHT_ARCEUS, SpearPillar_TryEnableHallOfOriginEnd
    SetVar VAR_HALL_OF_ORIGIN_STATE, 1
    GoTo SpearPillar_TryEnableHallOfOriginEnd
    End

SpearPillar_TryEnableHallOfOriginEnd:
    Return

SpearPillar_TryHideRival:
    Dummy1F9 VAR_SPEAR_PILLAR_STATE
    GoToIfInRange VAR_SPEAR_PILLAR_STATE, 0, 3, SpearPillar_HideRival
    Return

SpearPillar_HideRival:
    SetFlag FLAG_HIDE_SPEAR_PILLAR_RIVAL
    Return

SpearPillar_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, SpearPillar_SovereignRemoveRift
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, SpearPillar_RemoveLegendary
    End

@ Cosmog and Necrozma share the plaza, so each one's script notes its species in VAR_MAP_LOCAL_0x02 for the removal
@ after a battle (map-local vars last through it; see Eterna Forest).
SpearPillar_RemoveLegendary:
    GoToIfEq VAR_MAP_LOCAL_0x02, SPECIES_COSMOG, SpearPillar_RemoveLegendaryCosmog
    GoTo SpearPillar_RemoveLegendaryNecrozma
    End

SpearPillar_RemoveLegendaryCosmog:
    RemoveObject LOCALID_LEGENDARY_COSMOG
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): once the Alola Chronicle is open (VAR_SOVEREIGN_CHRONICLE
@ 3), a Cosmog (Lv. 5) floats in the middle of the plaza until it's caught (FLAG_SOVEREIGN_CAUGHT_COSMOG). A second
@ one comes once the player has Solgaleo or Lunala, so both can be raised (_COSMOG_2). Necrozma then stands north of it
@ until it's caught.
SpearPillar_SovereignSetSkyVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, SpearPillar_SovereignSetSkyVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_SOLGALEO, VAR_MAP_LOCAL_0x01
    CallIfEq VAR_MAP_LOCAL_0x01, FALSE, SpearPillar_SovereignCheckLunala
    GoToIfUnset FLAG_SOVEREIGN_CAUGHT_COSMOG, SpearPillar_SovereignShowCosmog
    GoToIfSet FLAG_SOVEREIGN_CAUGHT_COSMOG_2, SpearPillar_SovereignTryShowNecrozma
    GoToIfEq VAR_MAP_LOCAL_0x01, FALSE, SpearPillar_SovereignTryShowNecrozma
SpearPillar_SovereignShowCosmog:
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
SpearPillar_SovereignTryShowNecrozma:
    GoToIfEq VAR_MAP_LOCAL_0x01, FALSE, SpearPillar_SovereignSetSkyVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_NECROZMA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SpearPillar_SovereignSetSkyVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
SpearPillar_SovereignSetSkyVisibilityEnd:
    Return

SpearPillar_SovereignCheckLunala:
    SovereignCheckSpeciesCaught SPECIES_LUNALA, VAR_MAP_LOCAL_0x01
    Return

@ The Pokédex can't tell the first Cosmog from the second, so a catch sets a flag (VAR_RESULT is TRUE after a catch).
SpearPillar_LegendaryCosmog:
    SetVar VAR_MAP_LOCAL_0x02, SPECIES_COSMOG
    SetVar VAR_0x8004, SPECIES_COSMOG
    SetVar VAR_0x8005, 5
    Common_SovereignLegendaryEncounter
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_LegendaryCosmogEnd
    CallIfSet FLAG_SOVEREIGN_CAUGHT_COSMOG, SpearPillar_SovereignSetCaughtCosmog2
    SetFlag FLAG_SOVEREIGN_CAUGHT_COSMOG
SpearPillar_LegendaryCosmogEnd:
    End

SpearPillar_SovereignSetCaughtCosmog2:
    SetFlag FLAG_SOVEREIGN_CAUGHT_COSMOG_2
    Return

SpearPillar_RemoveLegendaryNecrozma:
    RemoveObject LOCALID_LEGENDARY_NECROZMA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

SpearPillar_LegendaryNecrozma:
    SetVar VAR_MAP_LOCAL_0x02, SPECIES_NECROZMA
    SetVar VAR_0x8004, SPECIES_NECROZMA
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

SpearPillar_SetMessageVar:
    GetGameVersion VAR_RESULT
    SetVar VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_RESULT, VERSION_DIAMOND, SpearPillar_SetMessageVarReturn
    GoToIfEq VAR_RESULT, VERSION_PLATINUM, SpearPillar_SetMessageVarReturn
    SetVar VAR_0x8004, VAR_0x8006
SpearPillar_SetMessageVarReturn:
    Return

SpearPillar_Unused:
    GetPlayerGender VAR_RESULT
    SetVar VAR_0x8004, VAR_0x8005
    GoToIfEq VAR_RESULT, GENDER_FEMALE, SpearPillar_Unused2
    SetVar VAR_0x8004, VAR_0x8006
SpearPillar_Unused2:
    Return

SpearPillar_CoordEvent_Grunts:
    LockAll
    ApplyMovement LOCALID_GRUNT_F, SpearPillar_Movement_GruntFWalkOnSpotEast
    ApplyMovement LOCALID_GRUNT_M, SpearPillar_Movement_GruntMWalkOnSpotWest
    WaitMovement
    @ Sovereign (decision 23): Mars and Jupiter wait on Totem Kommo-o's trial (Mt. Coronet 6F).
    GoToIfUnset FLAG_SOVEREIGN_TOTEM_TRIAL_KOMMO_O, SpearPillar_GruntsWaitOnTotem
    CheckHasTwoAliveMons VAR_RESULT
    GoToIfNe VAR_RESULT, FALSE, SpearPillar_BattleGrunts
    GoTo SpearPillar_GruntsOnlyOnePokemon
    End

SpearPillar_GruntsOnlyOnePokemon:
    Message SpearPillar_Text_OnlyOnePokemon
    CloseMessage
    ApplyMovement LOCALID_PLAYER, SpearPillar_Movement_PlayerWalkSouth
    WaitMovement
    ApplyMovement LOCALID_GRUNT_F, SpearPillar_Movement_GruntFWalkOnSpotSouth
    ApplyMovement LOCALID_GRUNT_M, SpearPillar_Movement_GruntMWalkOnSpotSouth
    WaitMovement
    ReleaseAll
    End

SpearPillar_GruntsWaitOnTotem:
    Message SpearPillar_Text_SovereignKommoOBelow
    CloseMessage
    ApplyMovement LOCALID_PLAYER, SpearPillar_Movement_PlayerWalkSouth
    WaitMovement
    ApplyMovement LOCALID_GRUNT_F, SpearPillar_Movement_GruntFWalkOnSpotSouth
    ApplyMovement LOCALID_GRUNT_M, SpearPillar_Movement_GruntMWalkOnSpotSouth
    WaitMovement
    ReleaseAll
    End

SpearPillar_BattleGrunts:
    Call SpearPillar_StartBattleGrunts
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_BlackOutGrunts
    SetVar VAR_SPEAR_PILLAR_STATE, 1
    Message SpearPillar_Text_WeLetYouPass
    WaitButton
    CloseMessage
    ReleaseAll
    End

SpearPillar_StartBattleGrunts:
    Message SpearPillar_Text_TakeYouDown
    CloseMessage
    StartTrainerBattle TRAINER_GALACTIC_GRUNT_SPEAR_PILLAR_1, TRAINER_GALACTIC_GRUNT_SPEAR_PILLAR_2
    CheckWonBattle VAR_RESULT
    Return

SpearPillar_BlackOutGrunts:
    BlackOutFromBattle
    ReleaseAll
    End

    .balign 4, 0
SpearPillar_Movement_GruntFWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
SpearPillar_Movement_GruntFWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
SpearPillar_Movement_GruntMWalkOnSpotWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
SpearPillar_Movement_GruntMWalkOnSpotSouth:
    WalkOnSpotNormalSouth
    EndMovement

    .balign 4, 0
SpearPillar_Movement_PlayerWalkSouth:
    Delay4 5
    WalkNormalSouth
    EndMovement

SpearPillar_Grunts:
    NPCMessage SpearPillar_Text_WeLetYouPass
    End

SpearPillar_Jupiter:
    NPCMessage SpearPillar_Text_BeQuietAndWatch
    End

SpearPillar_Mars:
    NPCMessage SpearPillar_Text_SurprisedYouMadeIt
    End

SpearPillar_CoordEvent_MarsJupiter:
    LockAll
    Call SpearPillar_MarsJupiterWalkToPlayer
    Message SpearPillar_Text_GoThroughMeFirst
    Message SpearPillar_Text_IllBeNext
    CloseMessage
    Call SpearPillar_RivalEnter
    BufferRivalName 0
    Message SpearPillar_Text_DontPartyWithoutMe
    Message SpearPillar_Text_Huh
    Message SpearPillar_Text_ImHereForRevenge
    Message SpearPillar_Text_LetsBattleTwoOnTwo
    CloseMessage
    Call SpearPillar_SetRivalPartnerTeam
    StartTagBattle VAR_0x8004, TRAINER_COMMANDER_MARS_SPEAR_PILLAR, TRAINER_COMMANDER_JUPITER_SPEAR_PILLAR
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_BlackOutMarsJupiter
    Call SpearPillar_PlayerRivalFaceEachOther
    BufferRivalName 0
    BufferPlayerName 1
    Message SpearPillar_Text_IllHelpYou
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    Message SpearPillar_Text_FullyHealedPokemon
    Message SpearPillar_Text_ItsYourShowNow
    CloseMessage
    ScrCmd_18C LOCALID_PLAYER, DIR_SOUTH
    ApplyMovement LOCALID_RIVAL, SpearPillar_Movement_RivalLeave
    WaitMovement
    RemoveObject LOCALID_RIVAL
    SetVar VAR_SPEAR_PILLAR_STATE, 2
    GoTo SpearPillar_Cyrus
    End

SpearPillar_BlackOutMarsJupiter:
    SetVar VAR_SPEAR_PILLAR_STATE, 1
    BlackOutFromBattle
    ReleaseAll
    End

SpearPillar_RivalEnter:
    ClearFlag FLAG_HIDE_SPEAR_PILLAR_RIVAL
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    SetVar VAR_0x8008, VAR_0x8004
    GoToIfEq VAR_0x8008, 30, SpearPillar_RivalEnterX30
    GoToIfEq VAR_0x8008, 31, SpearPillar_RivalEnterX31
    GoToIfEq VAR_0x8008, 32, SpearPillar_RivalEnterX32
    Return

SpearPillar_RivalEnterX30:
    SetObjectEventPos LOCALID_RIVAL, 31, 40
    AddObject LOCALID_RIVAL
    ApplyMovement LOCALID_RIVAL, SpearPillar_Movement_RivalEnter
    WaitMovement
    ScrCmd_18C LOCALID_RIVAL, DIR_EAST
    Return

SpearPillar_RivalEnterX31:
    SetObjectEventPos LOCALID_RIVAL, 30, 40
    AddObject LOCALID_RIVAL
    ApplyMovement LOCALID_RIVAL, SpearPillar_Movement_RivalEnter
    WaitMovement
    ScrCmd_18C LOCALID_RIVAL, DIR_WEST
    Return

SpearPillar_RivalEnterX32:
    SetObjectEventPos LOCALID_RIVAL, 31, 40
    AddObject LOCALID_RIVAL
    ApplyMovement LOCALID_RIVAL, SpearPillar_Movement_RivalEnter
    WaitMovement
    ScrCmd_18C LOCALID_RIVAL, DIR_WEST
    Return

SpearPillar_MarsJupiterWalkToPlayer:
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    SetVar VAR_0x8008, VAR_0x8004
    GoToIfEq VAR_0x8008, 30, SpearPillar_MarsJupiterWalkToPlayerX30
    GoToIfEq VAR_0x8008, 31, SpearPillar_MarsJupiterWalkToPlayerX31
    GoToIfEq VAR_0x8008, 32, SpearPillar_MarsJupiterWalkToPlayerX32
    Return

SpearPillar_MarsJupiterWalkToPlayerX30:
    ScrCmd_18C LOCALID_PLAYER, DIR_WEST
    ApplyMovement LOCALID_JUPITER, SpearPillar_Movement_JupiterWalkOnSpotEast
    ApplyMovement LOCALID_MARS, SpearPillar_Movement_MarsWalkWest
    WaitMovement
    Return

SpearPillar_MarsJupiterWalkToPlayerX31:
    ScrCmd_18C LOCALID_PLAYER, DIR_EAST
    ApplyMovement LOCALID_JUPITER, SpearPillar_Movement_JupiterWalkOnSpotEast2
    ApplyMovement LOCALID_MARS, SpearPillar_Movement_MarsWalkWest2
    WaitMovement
    Return

SpearPillar_MarsJupiterWalkToPlayerX32:
    ScrCmd_18C LOCALID_PLAYER, DIR_EAST
    ApplyMovement LOCALID_JUPITER, SpearPillar_Movement_JupiterWalkEast
    ApplyMovement LOCALID_MARS, SpearPillar_Movement_MarsWalkOnSpotWest
    WaitMovement
    Return

    .balign 4, 0
SpearPillar_Movement_JupiterWalkOnSpotEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
SpearPillar_Movement_MarsWalkWest:
    WalkNormalWest
    EndMovement

    .balign 4, 0
SpearPillar_Movement_JupiterWalkOnSpotEast2:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
SpearPillar_Movement_MarsWalkWest2:
    WalkNormalWest
    EndMovement

    .balign 4, 0
SpearPillar_Movement_JupiterWalkEast:
    WalkNormalEast
    EndMovement

    .balign 4, 0
SpearPillar_Movement_MarsWalkOnSpotWest:
    WalkOnSpotNormalWest
    EndMovement

SpearPillar_SetRivalPartnerTeam:
    GetPlayerStarterSpecies VAR_RESULT
    SetVar VAR_0x8004, TRAINER_RIVAL_SPEAR_PILLAR_CHIMCHAR
    GoToIfEq VAR_RESULT, SPECIES_CHIMCHAR, SpearPillar_Return
    SetVar VAR_0x8004, TRAINER_RIVAL_SPEAR_PILLAR_TURTWIG
    GoToIfEq VAR_RESULT, SPECIES_TURTWIG, SpearPillar_Return
    SetVar VAR_0x8004, TRAINER_RIVAL_SPEAR_PILLAR_PIPLUP
SpearPillar_Return:
    Return

SpearPillar_PlayerRivalFaceEachOther:
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    SetVar VAR_0x8008, VAR_0x8004
    GoToIfEq VAR_0x8008, 30, SpearPillar_PlayerRivalFaceEachOtherX30
    GoToIfEq VAR_0x8008, 31, SpearPillar_PlayerRivalFaceEachOtherX31
    GoToIfEq VAR_0x8008, 32, SpearPillar_PlayerRivalFaceEachOtherX32
    Return

SpearPillar_PlayerRivalFaceEachOtherX30:
    ScrCmd_18C LOCALID_PLAYER, DIR_EAST
    ScrCmd_18C LOCALID_RIVAL, DIR_WEST
    Return

SpearPillar_PlayerRivalFaceEachOtherX31:
    ScrCmd_18C LOCALID_PLAYER, DIR_WEST
    ScrCmd_18C LOCALID_RIVAL, DIR_EAST
    Return

SpearPillar_PlayerRivalFaceEachOtherX32:
    ScrCmd_18C LOCALID_PLAYER, DIR_WEST
    ScrCmd_18C LOCALID_RIVAL, DIR_EAST
    Return

SpearPillar_Unused3:
    ApplyMovement LOCALID_JUPITER, SpearPillar_Movement_Unused
    ApplyMovement LOCALID_MARS, SpearPillar_Movement_Unused2
    WaitMovement
    Return

    .balign 4, 0
SpearPillar_Movement_Unused:
    FaceEast
    LockDir
    WalkSlowWest
    UnlockDir
    EndMovement

SpearPillar_Movement_Unused2:
    FaceWest
    LockDir
    WalkSlowEast
    UnlockDir
    EndMovement

    .balign 4, 0
SpearPillar_Movement_RivalEnter:
    Delay4 2
    WalkFastNorth 8
    EndMovement

    .balign 4, 0
SpearPillar_Movement_RivalLeave:
    WalkFastSouth 8
    EndMovement

SpearPillar_Cyrus:
    ApplyMovement LOCALID_PLAYER, SpearPillar_Movement_PlayerWalkOnSpotNorth
    WaitMovement
    GetPlayerMapPos VAR_0x8000, VAR_0x8001
    AddFreeCamera VAR_0x8000, VAR_0x8001
    Call SpearPillar_CameraMoveToCyrus
    WaitMovement
    SetVar VAR_0x8005, SpearPillar_Text_EverythingIsReady
    SetVar VAR_0x8006, SpearPillar_Text_Dummy68
    Call SpearPillar_SetMessageVar
    MessageVar VAR_0x8004
    CloseMessage
    FadeOutBGM 0, 30
    ScrCmd_20D 0, VAR_RESULT
    WaitTime 10, VAR_RESULT
    PlaySE SEQ_SE_PL_KUSARI_sseq
    WaitTime 20, VAR_RESULT
    PlayMusic SEQ_THE_EVENT02_sseq
    SetSubScene63
    GoTo SpearPillar_WaitThenWarpToSpearPillarDistorted
    End

SpearPillar_WaitThenWarpToSpearPillarDistorted:
    ScrCmd_20D 1, VAR_RESULT
    GoToIfEq VAR_RESULT, 0, SpearPillar_WaitThenWarpToSpearPillarDistorted
    ScrCmd_2FB
    SetFlag FLAG_HIDE_SPEAR_PILLAR_GRUNTS
    SetFlag FLAG_HIDE_SPEAR_PILLAR_MARS_JUPITER
    SetFlag FLAG_HIDE_SPEAR_PILLAR_CYRUS
    SetVar VAR_SPEAR_PILLAR_STATE, 3
    SetFlag FLAG_UNLOCKED_VS_SEEKER_LVL_3
    ClearFlag FLAG_HIDE_SPEAR_PILLAR_DISTORTED_TEAM_GALACTIC
    SetFlag FLAG_SPEAR_PILLAR_IS_DISTORTED
    SetVar VAR_SPEAR_PILLAR_DISTORTED_STATE, 1
    SetSpeciesSeen SPECIES_DIALGA
    SetSpeciesSeen SPECIES_PALKIA
    RestoreCamera
    Warp MAP_HEADER_SPEAR_PILLAR_DISTORTED, 30, 30, DIR_NORTH
    End

    .balign 4, 0
SpearPillar_Movement_PlayerWalkOnSpotNorth:
    WalkOnSpotNormalNorth
    EndMovement

SpearPillar_CameraMoveToCyrus:
    GetPlayerMapPos VAR_0x8004, VAR_0x8005
    SetVar VAR_0x8008, VAR_0x8004
    GoToIfEq VAR_0x8008, 29, SpearPillar_CameraMoveToCyrusX29
    GoToIfEq VAR_0x8008, 30, SpearPillar_CameraMoveToCyrusX30
    GoToIfEq VAR_0x8008, 31, SpearPillar_CameraMoveToCyrusX31
    GoToIfEq VAR_0x8008, 32, SpearPillar_CameraMoveToCyrusX32
    GoToIfEq VAR_0x8008, 33, SpearPillar_CameraMoveToCyrusX33
    Return

SpearPillar_CameraMoveToCyrusX29:
    ApplyFreeCameraMovement SpearPillar_Movement_CameraMoveToCyrusX29
    Return

SpearPillar_CameraMoveToCyrusX30:
    ApplyFreeCameraMovement SpearPillar_Movement_CameraMoveToCyrusX30
    Return

SpearPillar_CameraMoveToCyrusX31:
    ApplyFreeCameraMovement SpearPillar_Movement_CameraMoveToCyrusX31
    Return

SpearPillar_CameraMoveToCyrusX32:
    ApplyFreeCameraMovement SpearPillar_Movement_CameraMoveToCyrusX32
    Return

SpearPillar_CameraMoveToCyrusX33:
    ApplyFreeCameraMovement SpearPillar_Movement_CameraMoveToCyrusX33
    Return

    .balign 4, 0
SpearPillar_Movement_CameraMoveToCyrusX29:
    Delay8
    WalkNormalNorth 6
    WalkNormalEast 2
    EndMovement

    .balign 4, 0
SpearPillar_Movement_CameraMoveToCyrusX30:
    Delay8
    WalkNormalNorth 6
    WalkNormalEast
    EndMovement

    .balign 4, 0
SpearPillar_Movement_CameraMoveToCyrusX31:
    Delay8
    WalkNormalNorth 6
    EndMovement

    .balign 4, 0
SpearPillar_Movement_CameraMoveToCyrusX32:
    Delay8
    WalkNormalNorth 6
    WalkNormalWest
    EndMovement

    .balign 4, 0
SpearPillar_Movement_CameraMoveToCyrusX33:
    Delay8
    WalkNormalNorth 6
    WalkNormalWest 2
    EndMovement

@ Sovereign (the Chronicles, the Paldea Chronicle's Time Rifts): once the Paldea Chronicle is open, a rift in time
@ (after Dialga is caught) and one in space (after Palkia is caught) each hold the first Paradox Pokémon of their ten
@ not caught yet. The rift shows that Pokémon (VAR_OBJ_GFX_ID_1 and _2) and VAR_MAP_LOCAL_0x03 and _0x04 hold its
@ species for the battle and the removal after it. A rift closes once all ten are caught.
SpearPillar_SovereignSetRiftsVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    SetVar VAR_MAP_LOCAL_0x03, 0
    SetVar VAR_MAP_LOCAL_0x04, 0
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, SpearPillar_SovereignSetRiftsVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_DIALGA, VAR_RESULT
    CallIfEq VAR_RESULT, TRUE, SpearPillar_SovereignPickAncient
    SovereignCheckSpeciesCaught SPECIES_PALKIA, VAR_RESULT
    CallIfEq VAR_RESULT, TRUE, SpearPillar_SovereignPickFuture
SpearPillar_SovereignSetRiftsVisibilityEnd:
    Return

SpearPillar_SovereignPickAncient:
    SovereignCheckSpeciesCaught SPECIES_GREAT_TUSK, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignAncientGreatTusk
    SovereignCheckSpeciesCaught SPECIES_SCREAM_TAIL, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignAncientScreamTail
    SovereignCheckSpeciesCaught SPECIES_BRUTE_BONNET, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignAncientBruteBonnet
    SovereignCheckSpeciesCaught SPECIES_FLUTTER_MANE, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignAncientFlutterMane
    SovereignCheckSpeciesCaught SPECIES_SLITHER_WING, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignAncientSlitherWing
    SovereignCheckSpeciesCaught SPECIES_SANDY_SHOCKS, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignAncientSandyShocks
    SovereignCheckSpeciesCaught SPECIES_ROARING_MOON, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignAncientRoaringMoon
    SovereignCheckSpeciesCaught SPECIES_WALKING_WAKE, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignAncientWalkingWake
    SovereignCheckSpeciesCaught SPECIES_GOUGING_FIRE, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignAncientGougingFire
    SovereignCheckSpeciesCaught SPECIES_RAGING_BOLT, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignAncientRagingBolt
    Return

SpearPillar_SovereignAncientGreatTusk:
    SetVar VAR_MAP_LOCAL_0x03, SPECIES_GREAT_TUSK
    SetVar VAR_OBJ_GFX_ID_1, OBJ_EVENT_GFX_LEGENDARY_GREAT_TUSK
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    Return

SpearPillar_SovereignAncientScreamTail:
    SetVar VAR_MAP_LOCAL_0x03, SPECIES_SCREAM_TAIL
    SetVar VAR_OBJ_GFX_ID_1, OBJ_EVENT_GFX_LEGENDARY_SCREAM_TAIL
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    Return

SpearPillar_SovereignAncientBruteBonnet:
    SetVar VAR_MAP_LOCAL_0x03, SPECIES_BRUTE_BONNET
    SetVar VAR_OBJ_GFX_ID_1, OBJ_EVENT_GFX_LEGENDARY_BRUTE_BONNET
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    Return

SpearPillar_SovereignAncientFlutterMane:
    SetVar VAR_MAP_LOCAL_0x03, SPECIES_FLUTTER_MANE
    SetVar VAR_OBJ_GFX_ID_1, OBJ_EVENT_GFX_LEGENDARY_FLUTTER_MANE
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    Return

SpearPillar_SovereignAncientSlitherWing:
    SetVar VAR_MAP_LOCAL_0x03, SPECIES_SLITHER_WING
    SetVar VAR_OBJ_GFX_ID_1, OBJ_EVENT_GFX_LEGENDARY_SLITHER_WING
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    Return

SpearPillar_SovereignAncientSandyShocks:
    SetVar VAR_MAP_LOCAL_0x03, SPECIES_SANDY_SHOCKS
    SetVar VAR_OBJ_GFX_ID_1, OBJ_EVENT_GFX_LEGENDARY_SANDY_SHOCKS
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    Return

SpearPillar_SovereignAncientRoaringMoon:
    SetVar VAR_MAP_LOCAL_0x03, SPECIES_ROARING_MOON
    SetVar VAR_OBJ_GFX_ID_1, OBJ_EVENT_GFX_LEGENDARY_ROARING_MOON
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    Return

SpearPillar_SovereignAncientWalkingWake:
    SetVar VAR_MAP_LOCAL_0x03, SPECIES_WALKING_WAKE
    SetVar VAR_OBJ_GFX_ID_1, OBJ_EVENT_GFX_LEGENDARY_WALKING_WAKE
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    Return

SpearPillar_SovereignAncientGougingFire:
    SetVar VAR_MAP_LOCAL_0x03, SPECIES_GOUGING_FIRE
    SetVar VAR_OBJ_GFX_ID_1, OBJ_EVENT_GFX_LEGENDARY_GOUGING_FIRE
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    Return

SpearPillar_SovereignAncientRagingBolt:
    SetVar VAR_MAP_LOCAL_0x03, SPECIES_RAGING_BOLT
    SetVar VAR_OBJ_GFX_ID_1, OBJ_EVENT_GFX_LEGENDARY_RAGING_BOLT
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    Return

SpearPillar_SovereignPickFuture:
    SovereignCheckSpeciesCaught SPECIES_IRON_TREADS, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignFutureIronTreads
    SovereignCheckSpeciesCaught SPECIES_IRON_BUNDLE, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignFutureIronBundle
    SovereignCheckSpeciesCaught SPECIES_IRON_HANDS, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignFutureIronHands
    SovereignCheckSpeciesCaught SPECIES_IRON_JUGULIS, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignFutureIronJugulis
    SovereignCheckSpeciesCaught SPECIES_IRON_MOTH, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignFutureIronMoth
    SovereignCheckSpeciesCaught SPECIES_IRON_THORNS, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignFutureIronThorns
    SovereignCheckSpeciesCaught SPECIES_IRON_VALIANT, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignFutureIronValiant
    SovereignCheckSpeciesCaught SPECIES_IRON_LEAVES, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignFutureIronLeaves
    SovereignCheckSpeciesCaught SPECIES_IRON_BOULDER, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignFutureIronBoulder
    SovereignCheckSpeciesCaught SPECIES_IRON_CROWN, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SpearPillar_SovereignFutureIronCrown
    Return

SpearPillar_SovereignFutureIronTreads:
    SetVar VAR_MAP_LOCAL_0x04, SPECIES_IRON_TREADS
    SetVar VAR_OBJ_GFX_ID_2, OBJ_EVENT_GFX_LEGENDARY_IRON_TREADS
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    Return

SpearPillar_SovereignFutureIronBundle:
    SetVar VAR_MAP_LOCAL_0x04, SPECIES_IRON_BUNDLE
    SetVar VAR_OBJ_GFX_ID_2, OBJ_EVENT_GFX_LEGENDARY_IRON_BUNDLE
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    Return

SpearPillar_SovereignFutureIronHands:
    SetVar VAR_MAP_LOCAL_0x04, SPECIES_IRON_HANDS
    SetVar VAR_OBJ_GFX_ID_2, OBJ_EVENT_GFX_LEGENDARY_IRON_HANDS
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    Return

SpearPillar_SovereignFutureIronJugulis:
    SetVar VAR_MAP_LOCAL_0x04, SPECIES_IRON_JUGULIS
    SetVar VAR_OBJ_GFX_ID_2, OBJ_EVENT_GFX_LEGENDARY_IRON_JUGULIS
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    Return

SpearPillar_SovereignFutureIronMoth:
    SetVar VAR_MAP_LOCAL_0x04, SPECIES_IRON_MOTH
    SetVar VAR_OBJ_GFX_ID_2, OBJ_EVENT_GFX_LEGENDARY_IRON_MOTH
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    Return

SpearPillar_SovereignFutureIronThorns:
    SetVar VAR_MAP_LOCAL_0x04, SPECIES_IRON_THORNS
    SetVar VAR_OBJ_GFX_ID_2, OBJ_EVENT_GFX_LEGENDARY_IRON_THORNS
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    Return

SpearPillar_SovereignFutureIronValiant:
    SetVar VAR_MAP_LOCAL_0x04, SPECIES_IRON_VALIANT
    SetVar VAR_OBJ_GFX_ID_2, OBJ_EVENT_GFX_LEGENDARY_IRON_VALIANT
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    Return

SpearPillar_SovereignFutureIronLeaves:
    SetVar VAR_MAP_LOCAL_0x04, SPECIES_IRON_LEAVES
    SetVar VAR_OBJ_GFX_ID_2, OBJ_EVENT_GFX_LEGENDARY_IRON_LEAVES
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    Return

SpearPillar_SovereignFutureIronBoulder:
    SetVar VAR_MAP_LOCAL_0x04, SPECIES_IRON_BOULDER
    SetVar VAR_OBJ_GFX_ID_2, OBJ_EVENT_GFX_LEGENDARY_IRON_BOULDER
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    Return

SpearPillar_SovereignFutureIronCrown:
    SetVar VAR_MAP_LOCAL_0x04, SPECIES_IRON_CROWN
    SetVar VAR_OBJ_GFX_ID_2, OBJ_EVENT_GFX_LEGENDARY_IRON_CROWN
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_4
    Return

SpearPillar_SovereignRemoveRift:
    GoToIfEq VAR_SOVEREIGN_LEGENDARY_SPECIES, VAR_MAP_LOCAL_0x03, SpearPillar_SovereignRemoveAncientRift
    GoToIfEq VAR_SOVEREIGN_LEGENDARY_SPECIES, VAR_MAP_LOCAL_0x04, SpearPillar_SovereignRemoveFutureRift
    Return

SpearPillar_SovereignRemoveAncientRift:
    RemoveObject LOCALID_SOVEREIGN_ANCIENT_RIFT
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    Return

SpearPillar_SovereignRemoveFutureRift:
    RemoveObject LOCALID_SOVEREIGN_FUTURE_RIFT
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    Return

SpearPillar_SovereignAncientRift:
    SetVar VAR_0x8004, VAR_MAP_LOCAL_0x03
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

SpearPillar_SovereignFutureRift:
    SetVar VAR_0x8004, VAR_MAP_LOCAL_0x04
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End
