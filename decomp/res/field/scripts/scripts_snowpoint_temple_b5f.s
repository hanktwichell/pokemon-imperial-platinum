#include "macros/scrcmd.inc"
#include "res/text/bank/snowpoint_temple_b5f.h"
#include "res/field/events/events_snowpoint_temple_b5f.h"


    ScriptEntry SnowpointTempleB5F_OnLoad
    ScriptEntry SnowpointTempleB5F_Regigigas
    ScriptEntry SnowpointTempleB5F_SovereignOnTransition
    ScriptEntry SnowpointTempleB5F_SovereignCoordEvent_Candice
    ScriptEntryEnd

SnowpointTempleB5F_OnLoad:
    GoToIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, SnowpointTempleB5F_RemoveRegigigas
    End

SnowpointTempleB5F_RemoveRegigigas:
    SetFlag FLAG_HIDE_SNOWPOINT_TEMPLE_B5F_REGIGIGAS
    RemoveObject LOCALID_REGIGIGAS
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    End

SnowpointTempleB5F_Regigigas:
    LockAll
    PlaySE SE_CONFIRM_sseq_3
    WaitSE SE_CONFIRM_sseq_3
    GoToIfSet FLAG_AWAKENED_REGIGIGAS, SnowpointTempleB5F_EncounterRegigigas
    @ Sovereign (E10 part 26): the temple opens before the Gym now, so, as in Renegade, Regigigas also waits for the
    @ Champion.
    GoToIfUnset FLAG_GAME_COMPLETED, SnowpointTempleB5F_GatherThreePokemon
    CheckHasAllLegendaryTitansInParty VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SnowpointTempleB5F_GatherThreePokemon
    SetFlag FLAG_AWAKENED_REGIGIGAS
    BufferPlayerName 0
    Message SnowpointTempleB5F_Text_KingShallAppear
    CloseMessage
    ReleaseObject LOCALID_REGIGIGAS
    ShakeObject LOCALID_REGIGIGAS, 8, 90, 3, 0
    LockObject LOCALID_REGIGIGAS
    GoTo SnowpointTempleB5F_EncounterRegigigas
    End

SnowpointTempleB5F_GatherThreePokemon:
    BufferPlayerName 0
    Message SnowpointTempleB5F_Text_GatherThreePokemon
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointTempleB5F_EncounterRegigigas:
    Message SnowpointTempleB5F_Text_RegigigasCry
    CloseMessage
    PlayCry SPECIES_REGIGIGAS
    WaitCry
    SetFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    @ Sovereign (E10): Lv. 70, as in Renegade.
    StartLegendaryBattle SPECIES_REGIGIGAS, 70
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SnowpointTempleB5F_BlackOut
    CheckDidNotCapture VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SnowpointTempleB5F_RegigigasDisappeared
    SetFlag FLAG_CAUGHT_REGIGIGAS
    ReleaseAll
    End

SnowpointTempleB5F_RegigigasDisappeared:
    Message SnowpointTempleB5F_Text_RegigigasDisappeared
    WaitButton
    CloseMessage
    ReleaseAll
    End

SnowpointTempleB5F_BlackOut:
    BlackOutFromBattle
    ReleaseAll
    End

    

@ Sovereign (E10 part 26, Renegade's Snowpoint Temple story): before the Snowpoint Gym, Regigigas is stirring, and
@ Candice and Maylene stand before it. With the player's help they put it back to sleep, and Candice gives HM08 (Rock
@ Climb). The HM in the bag is the record of it (an HM can't leave the bag).
SnowpointTempleB5F_SovereignOnTransition:
    CheckItem ITEM_HM08, 1, VAR_MAP_LOCAL_0x02
    GoToIfEq VAR_MAP_LOCAL_0x02, FALSE, SnowpointTempleB5F_SovereignOnTransitionEnd
    SetFlag FLAG_MAP_LOCAL_0x01
    SetVar VAR_MAP_LOCAL_0x01, 1
SnowpointTempleB5F_SovereignOnTransitionEnd:
    End

SnowpointTempleB5F_SovereignCoordEvent_Candice:
    LockAll
    ApplyMovement LOCALID_SOVEREIGN_MAYLENE, SnowpointTempleB5F_SovereignMovement_Notice
    ApplyMovement LOCALID_SOVEREIGN_CANDICE, SnowpointTempleB5F_SovereignMovement_Notice
    WaitMovement
    BufferPlayerName 0
    Message SnowpointTempleB5F_Text_SovereignMayleneSituation
    CloseMessage
    Message SnowpointTempleB5F_Text_SovereignCandiceHelpUs
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_MAYLENE, SnowpointTempleB5F_SovereignMovement_FaceNorth
    ApplyMovement LOCALID_SOVEREIGN_CANDICE, SnowpointTempleB5F_SovereignMovement_FaceNorth
    WaitMovement
    WaitTime 15, VAR_RESULT
    ReleaseObject LOCALID_REGIGIGAS
    ShakeObject LOCALID_REGIGIGAS, 8, 90, 3, 0
    LockObject LOCALID_REGIGIGAS
    PlayCry SPECIES_REGIGIGAS
    Message SnowpointTempleB5F_Text_RegigigasCry
    WaitCry
    CloseMessage
    ApplyMovement LOCALID_PLAYER, SnowpointTempleB5F_SovereignMovement_StepUp
    WaitMovement
    FadeScreenOut
    WaitFadeScreen
    PlayCry SPECIES_REGIGIGAS
    WaitCry
    WaitTime 30, VAR_RESULT
    PlayCry SPECIES_REGIGIGAS
    WaitCry
    WaitTime 30, VAR_RESULT
    FadeScreenIn
    WaitFadeScreen
    Message SnowpointTempleB5F_Text_SovereignCandiceBackToSleep
    CloseMessage
    ApplyMovement LOCALID_SOVEREIGN_CANDICE, SnowpointTempleB5F_SovereignMovement_FaceWest
    ApplyMovement LOCALID_SOVEREIGN_MAYLENE, SnowpointTempleB5F_SovereignMovement_FaceEast
    ApplyMovement LOCALID_PLAYER, SnowpointTempleB5F_SovereignMovement_FaceEast
    WaitMovement
    Message SnowpointTempleB5F_Text_SovereignCandiceThanks
    CloseMessage
    SetVar VAR_0x8004, ITEM_HM08
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Message SnowpointTempleB5F_Text_SovereignCandiceRockClimb
    CloseMessage
    ApplyMovement LOCALID_PLAYER, SnowpointTempleB5F_SovereignMovement_FaceWest
    WaitMovement
    BufferPlayerName 0
    Message SnowpointTempleB5F_Text_SovereignMayleneThanks
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, 1
    FadeScreenOut
    WaitFadeScreen
    RemoveObject LOCALID_SOVEREIGN_MAYLENE
    RemoveObject LOCALID_SOVEREIGN_CANDICE
    SetFlag FLAG_MAP_LOCAL_0x01
    FadeScreenIn
    WaitFadeScreen
    ReleaseAll
    End

    .balign 4, 0
SnowpointTempleB5F_SovereignMovement_Notice:
    FaceSouth
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
SnowpointTempleB5F_SovereignMovement_FaceNorth:
    WalkOnSpotNormalNorth
    EndMovement

    .balign 4, 0
SnowpointTempleB5F_SovereignMovement_StepUp:
    WalkNormalNorth 2
    EndMovement

    .balign 4, 0
SnowpointTempleB5F_SovereignMovement_FaceWest:
    WalkOnSpotNormalWest
    EndMovement

    .balign 4, 0
SnowpointTempleB5F_SovereignMovement_FaceEast:
    WalkOnSpotNormalEast
    EndMovement

    .balign 4, 0
