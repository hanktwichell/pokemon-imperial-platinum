#include "field/field_system.h"

#include <nitro.h>
#include <string.h>

#include "constants/field/map_load.h"
#include "constants/heap.h"
#include "generated/map_headers.h"
#include "generated/signpost_commands.h"

#include "applications/poketch/poketch_system.h"
#include "applications/title_screen.h"
#include "field/field_system_sub2_t.h"
#include "overlay005/field_control.h"
#include "overlay005/fieldmap.h"
#include "overlay005/map_name_popup.h"
#include "overlay005/ov5_021DFB54.h"
#include "overlay005/ov5_021EA714.h"
#include "overlay005/signpost.h"

#include "bag.h"
#include "bg_window.h"
#include "comm_player_manager.h"
#include "communication_system.h"
#include "field_map_change.h"
#include "field_overworld_state.h"
#include "field_system.h"
#include "field_task.h"
#include "game_overlay.h"
#include "heap.h"
#include "main.h"
#include "map_header_data.h"
#include "map_matrix.h"
#include "overlay_manager.h"
#include "party.h"
#include "player_avatar.h"
#include "player_move.h"
#include "pokedex_memory.h"
#include "pokemon.h"
#include "pokeradar.h"
#include "roaming_pokemon.h"
#include "savedata.h"
#include "script_manager.h"
#include "sovereign_test.h"
#include "special_encounter.h"
#include "system.h"
#include "unk_0209C370.h"

FS_EXTERN_OVERLAY(overlay5);
FS_EXTERN_OVERLAY(game_opening);

static BOOL InitFieldSystemContinue(ApplicationManager *appMan, int *state);
static BOOL InitFieldSystemNewGame(ApplicationManager *appMan, int *state);
static BOOL ExecuteFieldProcesses(ApplicationManager *appMan, int *state);
static BOOL ReturnToTitleScreen(ApplicationManager *appMan, int *state);
static FieldSystem *InitFieldSystem(ApplicationManager *appMan);
static void TeardownFieldSystem(ApplicationManager *appMan);
static void ExecuteAndCleanupIfDone(ApplicationManager **appManPtr);
static BOOL HandleInputsEventsAndProcesses(FieldSystem *fieldSystem);
static void HandleFieldInput(FieldSystem *fieldSystem);

static FieldSystem *sFieldSystem;

static BOOL InitFieldSystemContinue(ApplicationManager *appMan, int *state)
{
    ApplicationArgs *argv = ApplicationManager_Args(appMan);
    sFieldSystem = InitFieldSystem(appMan);

    if (argv->error) {
        FieldSystem_StartLoadMapFromErrorTask(sFieldSystem);
    } else {
        FieldSystem_SetLoadSavedGameMapTask(sFieldSystem);
    }

    argv->error = FALSE;
    return TRUE;
}

static BOOL InitFieldSystemNewGame(ApplicationManager *appMan, int *state)
{
    sFieldSystem = InitFieldSystem(appMan);
    FieldSystem_SetLoadNewGameSpawnTask(sFieldSystem);
    return TRUE;
}

static BOOL ExecuteFieldProcesses(ApplicationManager *appMan, int *state)
{
    if (HandleInputsEventsAndProcesses(ApplicationManager_Data(appMan))) {
        return TRUE;
    } else {
        return FALSE;
    }
}

static BOOL ReturnToTitleScreen(ApplicationManager *appMan, int *state)
{
    TeardownFieldSystem(appMan);
    EnqueueApplication(FS_OVERLAY_ID(game_opening), &gTitleScreenAppTemplate);
    return TRUE;
}

const ApplicationManagerTemplate gFieldSystemNewGameTemplate = {
    .init = InitFieldSystemNewGame,
    .main = ExecuteFieldProcesses,
    .exit = ReturnToTitleScreen,
    .overlayID = FS_OVERLAY_ID_NONE,
};

const ApplicationManagerTemplate gFieldSystemContinueTemplate = {
    .init = InitFieldSystemContinue,
    .main = ExecuteFieldProcesses,
    .exit = ReturnToTitleScreen,
    .overlayID = FS_OVERLAY_ID_NONE,
};

void FieldSystem_StartFieldMapInner(FieldSystem *fieldSystem)
{
    GF_ASSERT(fieldSystem->processManager->child == NULL);
    GF_ASSERT(fieldSystem->processManager->parent == NULL);
    Overlay_LoadByID(FS_OVERLAY_ID(overlay5), OVERLAY_LOAD_ASYNC);

    fieldSystem->runningFieldMap = FALSE;
    fieldSystem->processManager->pause = FALSE;
    fieldSystem->processManager->parent = ApplicationManager_New(&gFieldMapTemplate, fieldSystem, HEAP_ID_FIELD2);
}

void FieldSystem_FlagNotRunningFieldMap(FieldSystem *fieldSystem)
{
    fieldSystem->runningFieldMap = FALSE;
}

BOOL FieldSystem_HasParentProcess(FieldSystem *fieldSystem)
{
    return fieldSystem->processManager->parent != NULL;
}

BOOL FieldSystem_IsRunningFieldMapInner(FieldSystem *fieldSystem)
{
    return fieldSystem->processManager->parent != NULL && fieldSystem->runningFieldMap;
}

BOOL FieldSystem_HasChildProcess(FieldSystem *fieldSystem)
{
    return fieldSystem->processManager->child != NULL;
}

void FieldSystem_StartChildProcess(FieldSystem *fieldSystem, const ApplicationManagerTemplate *appTemplate, void *appArgs)
{
    GF_ASSERT(fieldSystem->processManager->child == NULL);
    FieldSystem_FlagNotRunningFieldMap(fieldSystem);
    fieldSystem->processManager->child = ApplicationManager_New(appTemplate, appArgs, HEAP_ID_FIELD2);
}

static FieldSystem *InitFieldSystem(ApplicationManager *appMan)
{
    Heap_Create(HEAP_ID_APPLICATION, HEAP_ID_FIELD2, HEAP_SIZE_FIELD2);
    Heap_Create(HEAP_ID_APPLICATION, HEAP_ID_FIELD3, HEAP_SIZE_FIELD3);
    Heap_Create(HEAP_ID_SYSTEM, HEAP_ID_NETWORK_ICON, HEAP_SIZE_NETWORK_ICON);

    FieldSystem *fieldSystem = ApplicationManager_NewData(appMan, sizeof(FieldSystem), HEAP_ID_FIELD2);
    MI_CpuClear8(fieldSystem, sizeof(FieldSystem));

    fieldSystem->processManager = Heap_Alloc(HEAP_ID_FIELD2, sizeof(FieldProcessManager));
    fieldSystem->processManager->parent = NULL;
    fieldSystem->processManager->child = NULL;
    fieldSystem->processManager->pause = FALSE;
    fieldSystem->processManager->kill = FALSE;
    fieldSystem->saveData = ((ApplicationArgs *)ApplicationManager_Args(appMan))->saveData;
    fieldSystem->task = NULL;
    fieldSystem->location = FieldOverworldState_GetPlayerLocation(SaveData_GetFieldOverworldState(fieldSystem->saveData));
    fieldSystem->mapMatrix = MapMatrix_New();

    MapHeaderData_Init(fieldSystem, HEAP_ID_FIELD2);

    fieldSystem->bagCursor = BagCursor_New(HEAP_ID_FIELD2);

    fieldSystem->chain = RadarChain_Init(HEAP_ID_FIELD2);
    RadarChain_Clear(fieldSystem->chain);

    fieldSystem->pokedexMemory = PokedexMemory_New(HEAP_ID_FIELD2);
    fieldSystem->battleSubscreenCursorOn = sub_0209C370(HEAP_ID_FIELD2);

    return fieldSystem;
}

static void TeardownFieldSystem(ApplicationManager *appMan)
{
    FieldSystem *fieldSystem = ApplicationManager_Data(appMan);

    MapMatrix_Free(fieldSystem->mapMatrix);
    MapHeaderData_Free(fieldSystem);
    Heap_Free(fieldSystem->bagCursor);
    RadarChain_Free(fieldSystem->chain);
    PokedexMemory_Free(fieldSystem->pokedexMemory);
    sub_0209C388(fieldSystem->battleSubscreenCursorOn);

    Heap_Free(fieldSystem->processManager);
    ApplicationManager_FreeData(appMan);
    Heap_Destroy(HEAP_ID_NETWORK_ICON);
    Heap_Destroy(HEAP_ID_FIELD2);
    Heap_Destroy(HEAP_ID_FIELD3);
}

static void ExecuteAndCleanupIfDone(ApplicationManager **appManPtr)
{
    if (*appManPtr && ApplicationManager_Exec(*appManPtr)) {
        ApplicationManager_Free(*appManPtr);
        *appManPtr = NULL;
    }
}

#ifdef SOVEREIGN_TEST
// Test build only (include/sovereign_test.h): the frames the field map has run with no task (no script, warp or
// battle) and the map it was on; test harnesses read them to tell when the player is free to move.
u32 gSovereignTestIdleFrames;
u32 gSovereignTestIdleMapHeaderID;
u16 gSovereignTestPlayerTile[2];
struct SovereignTestParty gSovereignTestParty;
struct SovereignTestRoamer gSovereignTestRoamers[ROAMING_SLOT_MAX];
struct SovereignTestWatch gSovereignTestWatch[SOVEREIGN_TEST_WATCHES];

static void SovereignTest_NoteParty(FieldSystem *fieldSystem)
{
    Party *party = SaveData_GetParty(fieldSystem->saveData);

    gSovereignTestParty.count = Party_GetCurrentCount(party);

    for (int i = 0; i < gSovereignTestParty.count; i++) {
        Pokemon *mon = Party_GetPokemonBySlotIndex(party, i);
        struct SovereignTestPartyMon *noted = &gSovereignTestParty.mons[i];

        noted->species = Pokemon_GetValue(mon, MON_DATA_SPECIES, NULL);
        noted->form = Pokemon_GetValue(mon, MON_DATA_FORM, NULL);
        noted->level = Pokemon_GetValue(mon, MON_DATA_LEVEL, NULL);
        noted->ability = Pokemon_GetValue(mon, MON_DATA_ABILITY, NULL);
        noted->hasHiddenAbility = Pokemon_GetValue(mon, MON_DATA_HAS_HIDDEN_ABILITY, NULL);
        noted->heldItem = Pokemon_GetValue(mon, MON_DATA_HELD_ITEM, NULL);
        noted->isEgg = Pokemon_GetValue(mon, MON_DATA_IS_EGG, NULL);

        for (int j = 0; j < 4; j++) {
            noted->moves[j] = Pokemon_GetValue(mon, MON_DATA_MOVE1 + j, NULL);
        }
    }

    gSovereignTestParty.wanted = FALSE;
}

static void SovereignTest_NoteRoamers(FieldSystem *fieldSystem)
{
    SpecialEncounter *speEnc = SaveData_GetSpecialEncounters(fieldSystem->saveData);

    for (u8 slot = 0; slot < ROAMING_SLOT_MAX; slot++) {
        struct SovereignTestRoamer *noted = &gSovereignTestRoamers[slot];
        Roamer *roamer = SpecialEncounter_GetRoamer(speEnc, slot);

        noted->routeIndex = SpecialEncounter_GetRoamerRouteIndex(speEnc, slot);
        noted->mapHeaderID = SpecialEncounter_IsRoamerActive(speEnc, slot) ? RoamingPokemon_GetRouteFromId(noted->routeIndex) : 0;
        noted->level = Roamer_GetData(roamer, ROAMER_DATA_LEVEL);
        noted->species = Roamer_GetData(roamer, ROAMER_DATA_SPECIES);
        noted->hp = Roamer_GetData(roamer, ROAMER_DATA_CURRENT_HP);
        noted->personality = Roamer_GetData(roamer, ROAMER_DATA_PERSONALITY);
    }
}
#endif

static BOOL HandleInputsEventsAndProcesses(FieldSystem *fieldSystem)
{
#ifdef SOVEREIGN_TEST
    if (fieldSystem->runningFieldMap && fieldSystem->playerAvatar != NULL) {
        gSovereignTestPlayerTile[0] = PlayerAvatar_GetXPos(fieldSystem->playerAvatar);
        gSovereignTestPlayerTile[1] = PlayerAvatar_GetZPos(fieldSystem->playerAvatar);
    }

    if (fieldSystem->runningFieldMap && FieldSystem_IsRunningTask(fieldSystem) == FALSE) {
        gSovereignTestIdleFrames++;
        gSovereignTestIdleMapHeaderID = fieldSystem->location->mapHeaderID;

        if (gSovereignTestParty.wanted) {
            SovereignTest_NoteParty(fieldSystem);
        }

        SovereignTest_NoteRoamers(fieldSystem);

        for (int i = 0; i < SOVEREIGN_TEST_WATCHES; i++) {
            if (gSovereignTestWatch[i].var != 0) {
                gSovereignTestWatch[i].value = *FieldSystem_GetVarPointer(fieldSystem, gSovereignTestWatch[i].var);
            }
        }
    }
#endif

    HandleFieldInput(fieldSystem);
    if (FieldTask_Run(fieldSystem) == TRUE && fieldSystem->unk_04 != NULL) {
        FieldSystem_SendPoketchEvent(fieldSystem, POKETCH_EVENT_SLEEP, 0);
    }

    if (fieldSystem->processManager->parent) {
        ExecuteAndCleanupIfDone(&fieldSystem->processManager->parent);

        if (fieldSystem->processManager->parent == NULL) {
            Overlay_UnloadByID(FS_OVERLAY_ID(overlay5));
        }
    } else if (fieldSystem->processManager->child) {
        ExecuteAndCleanupIfDone(&fieldSystem->processManager->child);
    }

    // Does not match with return (expression)
    if (fieldSystem->processManager->kill
        && !fieldSystem->task
        && !fieldSystem->processManager->parent
        && !fieldSystem->processManager->child) {
        return TRUE;
    }

    return FALSE;
}

static void HandleFieldInput(FieldSystem *fieldSystem)
{
    BOOL processInput = FALSE;
    if (!fieldSystem->processManager->pause && fieldSystem->runningFieldMap && FieldSystem_IsRunningTask(fieldSystem) == FALSE) {
        processInput = TRUE;
    }

    FieldInput fieldInput;
    if (processInput) {
        PlayerAvatar_UpdatePlayerMoveState(fieldSystem->playerAvatar);
        FieldInput_Update(&fieldInput, fieldSystem, gSystem.pressedKeys, gSystem.heldKeys);
    }

    enum MapLoadType loadType = fieldSystem->mapLoadType;
    if (fieldSystem->location->mapHeaderID == MAP_HEADER_BATTLE_TOWER) {
        loadType = MAP_LOAD_TYPE_OVERWORLD;
    }

    switch (loadType) {
    case MAP_LOAD_TYPE_UNDERGROUND:
        if (processInput && sub_02058C40()) {
            FieldInput_Process_Underground(&fieldInput, fieldSystem);
        }

        sub_0205805C(fieldSystem, processInput);
        break;

    case MAP_LOAD_TYPE_COLOSSEUM:
        if (processInput) {
            if (sub_02058C40()) {
                if (FieldInput_Process_Colosseum(&fieldInput, fieldSystem) == TRUE) {
                    processInput = FALSE;
                }
            } else {
                processInput = FALSE;
            }
        }

        sub_0205805C(fieldSystem, processInput);
        break;

    case MAP_LOAD_TYPE_UNION:
        if (processInput) {
            if (FieldInput_Process_UnionRoom(&fieldInput, fieldSystem) != TRUE) {
                PlayerAvatar_MoveMain(fieldSystem->playerAvatar, fieldSystem->landDataMan, -1, fieldInput.pressedKeys, fieldInput.heldKeys, 0);
            }
        }
        break;

    case MAP_LOAD_TYPE_BATTLE_TOWER:
        if (processInput) {
            if (FieldInput_Process_BattleTower(&fieldInput, fieldSystem) == TRUE) {
                MapNamePopUp_Hide(fieldSystem->unk_04->mapPopup);
                Signpost_DoCommand(fieldSystem, SIGNPOST_CMD_REMOVE);
                ov5_021E0EEC(fieldSystem->playerAvatar);
                FieldSystem_SendPoketchEvent(fieldSystem, POKETCH_EVENT_SLEEP, 1);
            } else {
                if (gSystem.pressedKeys & PAD_BUTTON_A) {
                    MapNamePopUp_Hide(fieldSystem->unk_04->mapPopup);
                }

                BOOL tappedPoketch = FALSE;
                PoketchSystem *poketchSys = FieldSystem_GetPoketchSystem();
                if (poketchSys != NULL) {
                    tappedPoketch = PoketchSystem_IsTapped(poketchSys);
                }

                PlayerAvatar_MoveMain(fieldSystem->playerAvatar, fieldSystem->landDataMan, -1, fieldInput.pressedKeys, fieldInput.heldKeys, tappedPoketch);
            }
        }
        break;

    default:
        if (processInput) {
            if (FieldInput_Process(&fieldInput, fieldSystem) == TRUE) {
                MapNamePopUp_Hide(fieldSystem->unk_04->mapPopup);
                Signpost_DoCommand(fieldSystem, SIGNPOST_CMD_REMOVE);
                PlayerAvatar_ClearMoveState(fieldSystem->playerAvatar);
                ov5_021E0EEC(fieldSystem->playerAvatar);
                FieldSystem_SendPoketchEvent(fieldSystem, POKETCH_EVENT_SLEEP, 1);
            } else {
                if (gSystem.pressedKeys & PAD_BUTTON_A) {
                    MapNamePopUp_Hide(fieldSystem->unk_04->mapPopup);
                }

                BOOL tappedPoketch = 0;
                PoketchSystem *poketchSys = FieldSystem_GetPoketchSystem();
                if (poketchSys != NULL) {
                    tappedPoketch = PoketchSystem_IsTapped(poketchSys);
                }

                PlayerAvatar_MoveMain(fieldSystem->playerAvatar, fieldSystem->landDataMan, -1, fieldInput.pressedKeys, fieldInput.heldKeys, tappedPoketch);
            }
        }
        break;
    }
}

void FieldSystem_PauseProcessing(void)
{
    sFieldSystem->processManager->pause = TRUE;
    CommSys_DisableSendMovementData();
}

void FieldSystem_ResumeProcessing(void)
{
    sFieldSystem->processManager->pause = FALSE;
    CommSys_EnableSendMovementData();
}

struct PoketchSystem *FieldSystem_GetPoketchSystem(void)
{
    if (sFieldSystem->unk_04 == NULL) {
        return NULL;
    }

    return sFieldSystem->unk_04->poketchSys;
}

BgConfig *FieldSystem_GetBgConfig(void *fieldSystem)
{
    return ((FieldSystem *)fieldSystem)->bgConfig;
}

SaveData *FieldSystem_GetSaveData(void *fieldSystem)
{
    return ((FieldSystem *)fieldSystem)->saveData;
}
