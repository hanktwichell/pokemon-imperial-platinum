#include "macros/scrcmd.inc"
#include "res/text/bank/pokemon_league.h"
#include "res/field/events/events_pokemon_league.h"


    ScriptEntry PokemonLeague_ArrowSignpostPokemonleague
    ScriptEntry PokemonLeague_SignboardVictoryRoad
    ScriptEntry PokemonLeague_Statue
    ScriptEntry PokemonLeague_SovereignGuard
    ScriptEntry PokemonLeague_CoordEvent_SovereignGuard
    ScriptEntry PokemonLeague_SovereignOnTransition
    ScriptEntry PokemonLeague_SovereignOnLoad
    ScriptEntry PokemonLeague_LegendaryRayquaza
    ScriptEntry PokemonLeague_SovereignFlyingMaster
    ScriptEntryEnd

@ Sovereign (decision 23): a guard at Victory Road's entrance. It opens with all eight Badges and Totem Togedemaru's
@ trial done (the last trial, Vista Lighthouse). The coord event covers the tiles beside him; VAR_MAP_LOCAL_0x00
@ starts at 0 on every visit, so the check runs again each time.
PokemonLeague_CoordEvent_SovereignGuard:
    CountBadgesAcquired VAR_RESULT
    GoToIfLt VAR_RESULT, 8, PokemonLeague_SovereignGuardBlockBadges
    GoToIfUnset FLAG_SOVEREIGN_TOTEM_TRIAL_TOGEDEMARU, PokemonLeague_SovereignGuardBlockTotem
    SetVar VAR_MAP_LOCAL_0x00, 1
    End

PokemonLeague_SovereignGuardBlockBadges:
    LockAll
    Message PokemonLeague_Text_SovereignNeedEightBadges
    GoTo PokemonLeague_SovereignGuardPushBack
    End

PokemonLeague_SovereignGuardBlockTotem:
    LockAll
    Message PokemonLeague_Text_SovereignTogedemaruFirst
PokemonLeague_SovereignGuardPushBack:
    WaitButton
    CloseMessage
    ApplyMovement LOCALID_PLAYER, PokemonLeague_Movement_SovereignPlayerStepBack
    WaitMovement
    ReleaseAll
    End

PokemonLeague_SovereignGuard:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CountBadgesAcquired VAR_RESULT
    GoToIfLt VAR_RESULT, 8, PokemonLeague_SovereignGuardNeedBadges
    GoToIfUnset FLAG_SOVEREIGN_TOTEM_TRIAL_TOGEDEMARU, PokemonLeague_SovereignGuardNeedTotem
    Message PokemonLeague_Text_SovereignVictoryRoadAwaits
    GoTo PokemonLeague_SovereignGuardEnd
    End

PokemonLeague_SovereignGuardNeedBadges:
    Message PokemonLeague_Text_SovereignNeedEightBadges
    GoTo PokemonLeague_SovereignGuardEnd
    End

PokemonLeague_SovereignGuardNeedTotem:
    Message PokemonLeague_Text_SovereignTogedemaruFirst
PokemonLeague_SovereignGuardEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
PokemonLeague_Movement_SovereignPlayerStepBack:
    WalkNormalSouth
    EndMovement

PokemonLeague_ArrowSignpostPokemonleague:
    ShowArrowSign PokemonLeague_Text_PokemonLeagueAhead
    End

PokemonLeague_SignboardVictoryRoad:
    ShowLandmarkSign PokemonLeague_Text_VictoryRoadAhead
    End

PokemonLeague_Statue:
    EventMessage PokemonLeague_Text_PinnacleOfTrainerdom
    End

    .balign 4, 0

PokemonLeague_SovereignOnTransition:
    Call PokemonLeague_SovereignSetRayquazaVisibility
    End

PokemonLeague_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, PokemonLeague_RemoveLegendaryRayquaza
    End

@ Sovereign (E10, Renegade's legendary events): Rayquaza on the strip of land below the waterfall, after the Hall of
@ Fame once Steven has given the Orbs (Renegade: a portal, Lv. 70, with the Jade Orb, which Sovereign doesn't have),
@ until it is caught.
PokemonLeague_SovereignSetRayquazaVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfUnset FLAG_GAME_COMPLETED, PokemonLeague_SovereignSetRayquazaVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_STEVEN_GAVE_ORBS, PokemonLeague_SovereignSetRayquazaVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_RAYQUAZA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, PokemonLeague_SovereignSetRayquazaVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
PokemonLeague_SovereignSetRayquazaVisibilityEnd:
    Return

PokemonLeague_RemoveLegendaryRayquaza:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_RAYQUAZA, PokemonLeague_RemoveLegendaryRayquazaEnd
    RemoveObject LOCALID_LEGENDARY_RAYQUAZA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
PokemonLeague_RemoveLegendaryRayquazaEnd:
    Return

PokemonLeague_LegendaryRayquaza:
    SetVar VAR_0x8004, SPECIES_RAYQUAZA
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (E10, Renegade's Type Masters): the Flying-type Master battles one Flying-type Pokémon, alone in the party, for
@ the Sky Plate (Renegade's trainer 1052).
PokemonLeague_SovereignFlyingMaster:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfDefeated TRAINER_SOVEREIGN_FLYING_MASTER, PokemonLeague_SovereignFlyingMasterThanks
    Message PokemonLeague_Text_SovereignFlyingMasterIntro
    GetPartyCount VAR_RESULT
    GoToIfNe VAR_RESULT, 1, PokemonLeague_SovereignFlyingMasterOnlyOne
    GetPartyMonType VAR_0x8004, VAR_0x8005, 0
    GoToIfEq VAR_0x8004, TYPE_FLYING, PokemonLeague_SovereignFlyingMasterAsk
    GoToIfEq VAR_0x8005, TYPE_FLYING, PokemonLeague_SovereignFlyingMasterAsk
PokemonLeague_SovereignFlyingMasterOnlyOne:
    Message PokemonLeague_Text_SovereignFlyingMasterFail
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeague_SovereignFlyingMasterAsk:
    Message PokemonLeague_Text_SovereignFlyingMasterAsk
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, PokemonLeague_SovereignFlyingMasterDecline
    Message PokemonLeague_Text_SovereignFlyingMasterBattle
    CloseMessage
    StartTrainerBattle TRAINER_SOVEREIGN_FLYING_MASTER
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonLeague_SovereignFlyingMasterLost
    Message PokemonLeague_Text_SovereignFlyingMasterWin
    SetVar VAR_0x8004, ITEM_SKY_PLATE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetTrainerFlag TRAINER_SOVEREIGN_FLYING_MASTER
PokemonLeague_SovereignFlyingMasterThanks:
    Message PokemonLeague_Text_SovereignFlyingMasterThanks
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeague_SovereignFlyingMasterDecline:
    Message PokemonLeague_Text_SovereignFlyingMasterDecline
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonLeague_SovereignFlyingMasterLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message PokemonLeague_Text_SovereignFlyingMasterLose
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
