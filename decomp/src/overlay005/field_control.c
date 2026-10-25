#include "overlay005/field_control.h"

#include <nitro.h>
#include <string.h>

#include "constants/sovereign_totem_trials.h"
#include "constants/field/dynamic_map_features.h"
#include "constants/field_poison.h"
#include "constants/player_avatar.h"
#include "generated/game_records.h"
#include "generated/trainer_score_events.h"

#include "struct_decls/map_object.h"
#include "struct_defs/daycare.h"

#include "field/field_system.h"
#include "field/field_system_sub2_t.h"
#include "overlay005/daycare.h"
#include "overlay005/honey_tree.h"
#include "overlay005/ov5_021DFB54.h"
#include "overlay005/ov5_021E1154.h"
#include "overlay005/ov5_021EA714.h"
#include "overlay005/ov5_021EF4BC.h"
#include "overlay005/villa_furniture.h"
#include "overlay005/vs_seeker.h"
#include "overlay006/repel_step_update.h"
#include "overlay006/wild_encounters.h"
#include "overlay008/gym_features.h"
#include "overlay009/ov9_02249960.h"
#include "underground/manager.h"

#include "catching_show.h"
#include "comm_manager.h"
#include "comm_player_manager.h"
#include "communication_information.h"
#include "communication_system.h"
#include "daycare_save.h"
#include "encounter.h"
#include "field_comm_manager.h"
#include "field_map_change.h"
#include "field_overworld_state.h"
#include "game_records.h"
#include "sovereign_field_moves.h"
#include "inlines.h"
#include "item_use_functions.h"
#include "location.h"
#include "map_header.h"
#include "map_header_data.h"
#include "map_object.h"
#include "map_tile_behavior.h"
#include "party.h"
#include "persisted_map_features_init.h"
#include "player_avatar.h"
#include "player_move.h"
#include "pokemon.h"
#include "pokeradar.h"
#include "save_player.h"
#include "script_manager.h"
#include "sound_playback.h"
#include "start_menu.h"

#ifdef SOVEREIGN_TEST
#include "generated/species.h"
#include "generated/trainers.h"

#include "generated/items.h"
#include "generated/moves.h"

#include "encounter.h"
#include "field_task.h"
#include "math_util.h"
#include "sovereign_form_items.h"
#include "sovereign_test.h"
#include "unk_02092494.h"
#endif
#include "system.h"
#include "system_flags.h"
#include "system_vars.h"
#include "terrain_collision_manager.h"
#include "trainer_encounter.h"
#include "trainer_info.h"
#include "unk_0203C954.h"
#include "unk_02054884.h"
#include "unk_02056B30.h"
#include "unk_0205A0D8.h"
#include "unk_0205B33C.h"
#include "vars_flags.h"
#include "wireless_manager.h"

static BOOL Field_CheckMapTransition(FieldSystem *fieldSystem, const FieldInput *input);
static u16 Field_TileBehaviorToScript(FieldSystem *fieldSystem, u8 behavior);
static BOOL Field_CheckWildEncounter(FieldSystem *fieldSystem);
static BOOL Field_ProcessStep(FieldSystem *fieldSystem);
static BOOL Field_CheckCoordEvent(FieldSystem *fieldSystem);
static BOOL Field_CheckTransition(FieldSystem *fieldSystem, const int playerX, const int playerZ, const u8 curTileBehavior);
static BOOL Field_UpdateDaycare(FieldSystem *fieldSystem);
static BOOL Field_UpdatePoison(FieldSystem *fieldSystem);
static BOOL Field_UpdateSafari(FieldSystem *fieldSystem);
static BOOL Field_UpdateVsSeeker(FieldSystem *fieldSystem);
static BOOL Field_UpdatePokeRadar(FieldSystem *fieldSystem);
static BOOL Field_CheckSign(FieldSystem *fieldSystem);
static BOOL Field_UpdateRepel(FieldSystem *fieldSystem);
static BOOL Field_UpdateFriendship(FieldSystem *fieldSystem);
static void Field_CalculateFriendship(FieldSystem *fieldSystem);
static void Field_GetPlayerPos(const FieldSystem *fieldSystem, int *playerX, int *playerZ);
static void Field_Step(const FieldSystem *fieldSystem, int *playerX, int *playerZ);
static void Field_StepInDirection(const FieldSystem *fieldSystem, int playerDir, int *playerX, int *playerZ);
static u8 Field_CurrentTileBehavior(const FieldSystem *fieldSystem);
static u8 Field_NextTileBehavior(const FieldSystem *fieldSystem);
static BOOL Field_MapConnection(const FieldSystem *fieldSystem, int playerX, int playerZ, Location *nextMap);
static void Field_TrySetMapConnection(FieldSystem *fieldSystem);
static BOOL Field_DistortionInteract(FieldSystem *fieldSystem, MapObject **object);
static int Field_CheckTrainerInfo(void);

static void FieldInput_Clear(FieldInput *input)
{
    input->interact = FALSE;
    input->endMovement = FALSE;
    input->menu = FALSE;
    input->registeredItem = FALSE;
    input->sign = FALSE;
    input->mapTransition = FALSE;
    input->movement = FALSE;
    input->dummy1 = FALSE;
    input->dummy2 = FALSE;
    input->dummy3 = FALSE;
    input->dummy4 = FALSE;
    input->dummy5 = FALSE;
    input->playerDir = DIR_NONE;
    input->transitionDir = DIR_NONE;
}

void FieldInput_Update(FieldInput *input, FieldSystem *fieldSystem, u16 pressedKeys, u16 heldKeys)
{
    FieldInput_Clear(input);

    int moveState = PlayerAvatar_GetPlayerMoveState(fieldSystem->playerAvatar);
    int avatarState = PlayerAvatar_GetMoveState(fieldSystem->playerAvatar);
    int playerDir = PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar);

    input->pressedKeys = pressedKeys;
    input->heldKeys = heldKeys;

    if (moveState == PLAYER_MOVE_STATE_END || moveState == PLAYER_MOVE_STATE_NONE) {
        if (pressedKeys & PAD_BUTTON_X) {
            input->menu = TRUE;
        }

        if (pressedKeys & PAD_BUTTON_Y) {
            input->registeredItem = TRUE;
        }

        if (pressedKeys & PAD_BUTTON_A) {
            input->interact = TRUE;
        }

        if (pressedKeys & PAD_BUTTON_B) {
            input->dummy1 = TRUE;
        }

        if (heldKeys & PAD_KEY) {
            input->sign = TRUE;
        }

        if (heldKeys & PAD_KEY) {
            input->mapTransition = TRUE;
        }
    }

    if (moveState == PLAYER_MOVE_STATE_END && avatarState == AVATAR_MOVE_STATE_MOVING) {
        input->movement = TRUE;
    }

    if (moveState == PLAYER_MOVE_STATE_END) {
        input->endMovement = TRUE;
    }

    if (playerDir == DIR_NORTH && heldKeys & PAD_KEY_UP
        || playerDir == DIR_SOUTH && heldKeys & PAD_KEY_DOWN
        || playerDir == DIR_WEST && heldKeys & PAD_KEY_LEFT
        || playerDir == DIR_EAST && heldKeys & PAD_KEY_RIGHT) {

        input->transitionDir = playerDir;
    } else {
        input->transitionDir = DIR_NONE;
    }

    input->playerDir = PlayerAvatar_CalcFaceDirection(fieldSystem->playerAvatar, pressedKeys, heldKeys);
}

#ifdef SOVEREIGN_TEST
static int sSovereignTestBattleResult;
static u8 sSovereignTestTotemTrial;

// The moves a test lead knows: Moonblast, Dazzling Gleam, Play Rough (the moves the battle harnesses pick) and
// Draining Kiss.
static const u16 sSovereignTestFairyMoves[LEARNED_MOVES_MAX] = { MOVE_MOONBLAST, MOVE_DAZZLING_GLEAM, MOVE_PLAY_ROUGH, MOVE_DRAINING_KISS };

// Test build only: the party's lead becomes the Pokémon a test harness wrote to gSovereignTestLead, as the player's
// own, given its item, and knowing four Fairy moves or the ones set, at the HP set (include/sovereign_test.h).
static void SovereignTest_SetLead(FieldSystem *fieldSystem)
{
    Pokemon *mon = Party_GetPokemonBySlotIndex(SaveData_GetParty(fieldSystem->saveData), 0);
    int form = gSovereignTestLead.form;
    u32 item = gSovereignTestLead.item;
    u8 hiddenAbility = gSovereignTestLead.hiddenAbility;

    u32 personality = gSovereignTestLead.personality;

    while (personality == 0
        || (gSovereignTestLead.personality == 0 && gSovereignTestLead.gender != 0
            && Pokemon_GetGenderOf(gSovereignTestLead.species, personality) != gSovereignTestLead.gender - 1)) {
        personality = LCRNG_Next() | (LCRNG_Next() << 16);
    }

    Pokemon_InitWith(mon, gSovereignTestLead.species, gSovereignTestLead.level, INIT_IVS_RANDOM, TRUE, personality, OTID_NOT_SET, 0);
    UpdateMonStatusAndTrainerInfo(mon, SaveData_GetTrainerInfo(fieldSystem->saveData), 0, 0, HEAP_ID_FIELD2);
    Pokemon_SetValue(mon, MON_DATA_FORM, &form);
    Pokemon_SetValue(mon, MON_DATA_HAS_HIDDEN_ABILITY, &hiddenAbility);
    Pokemon_CalcAbility(mon);
    Pokemon_CalcLevelAndStats(mon);
    Pokemon_SetValue(mon, MON_DATA_HELD_ITEM, &item);
    // As the party menu gives an item: Arceus's Plates, Silvally's Memories, Genesect's Drives, Ogerpon's masks, Origin
    // Dialga and Palkia, and Giratina's Griseous Orb set the form.
    Pokemon_SetArceusForm(mon);
    Pokemon_SetGiratinaFormByHeldItem(mon);

    for (int i = 0; i < LEARNED_MOVES_MAX; i++) {
        u16 move = gSovereignTestLead.moves[i] != MOVE_NONE ? gSovereignTestLead.moves[i] : sSovereignTestFairyMoves[i];

        Pokemon_ResetMoveSlot(mon, move == SOVEREIGN_TEST_NO_MOVE ? MOVE_NONE : move, i);
    }

    if (gSovereignTestLead.friendship) {
        u32 friendship = gSovereignTestLead.friendship;

        Pokemon_SetValue(mon, MON_DATA_FRIENDSHIP, &friendship);
    }

    if (gSovereignTestLead.hpPercent) {
        u32 hp = Pokemon_GetValue(mon, MON_DATA_MAX_HP, NULL) * gSovereignTestLead.hpPercent / 100;

        hp = hp ? hp : 1;
        Pokemon_SetValue(mon, MON_DATA_HP, &hp);
    }

    gSovereignTestLead.species = SPECIES_NONE;

    if (gSovereignTestPartner.species != SPECIES_NONE) {
        Pokemon *partner = Party_GetPokemonBySlotIndex(SaveData_GetParty(fieldSystem->saveData), 1);
        form = gSovereignTestPartner.form;

        Pokemon_InitWith(partner, gSovereignTestPartner.species, gSovereignTestPartner.level, INIT_IVS_RANDOM, FALSE, 0, OTID_NOT_SET, 0);
        UpdateMonStatusAndTrainerInfo(partner, SaveData_GetTrainerInfo(fieldSystem->saveData), 0, 0, HEAP_ID_FIELD2);
        Pokemon_SetValue(partner, MON_DATA_FORM, &form);
        Pokemon_CalcAbility(partner);
        Pokemon_CalcLevelAndStats(partner);
        gSovereignTestPartner.species = SPECIES_NONE;
    }
}

// Test build only: evolves the lead as the evolution screen does, the way a test harness wrote to gSovereignTestEvolve,
// and writes down what it became (include/sovereign_test.h).
static void SovereignTest_Evolve(FieldSystem *fieldSystem)
{
    Party *party = SaveData_GetParty(fieldSystem->saveData);
    Pokemon *lead = Party_GetPokemonBySlotIndex(party, 0);
    int evoType;

    gSovereignTestEvolve.target = Pokemon_GetEvolutionTargetSpecies(party, lead, gSovereignTestEvolve.evoClass, gSovereignTestEvolve.param, &evoType);

    if (gSovereignTestEvolve.target != SPECIES_NONE) {
        Pokemon_SovereignSetEvolvedSpecies(lead, gSovereignTestEvolve.target, evoType);
        Pokemon_CalcAbility(lead);
        Pokemon_CalcLevelAndStats(lead);
    }

    gSovereignTestEvolve.species = Pokemon_GetValue(lead, MON_DATA_SPECIES, NULL);
    gSovereignTestEvolve.form = Pokemon_GetValue(lead, MON_DATA_FORM, NULL);
    gSovereignTestEvolve.evolve = FALSE;
}

// Test build only: breeds the two Pokémon a test harness wrote to gSovereignTestBreed in the Day Care, hatches the Egg
// at once and makes it the party's lead, knowing the four Fairy moves, and writes down what the Egg and the hatched
// Pokémon are (include/sovereign_test.h).
static void SovereignTest_Breed(FieldSystem *fieldSystem)
{
    SaveData *saveData = fieldSystem->saveData;
    Party *party = SaveData_GetParty(saveData);
    Daycare *daycare = SaveData_GetDaycare(saveData);

    for (int i = 0; i < 2; i++) {
        Pokemon *mon = Party_GetPokemonBySlotIndex(party, 1 + i);
        u16 species = gSovereignTestBreed.species[i];
        int form = gSovereignTestBreed.forms[i];
        u32 item = gSovereignTestBreed.items[i];
        u32 personality = 0;

        while (personality == 0
            || (gSovereignTestBreed.genders[i] != 0 && Pokemon_GetGenderOf(species, personality) != gSovereignTestBreed.genders[i] - 1)) {
            personality = LCRNG_Next() | (LCRNG_Next() << 16);
        }

        Pokemon_InitWith(mon, species, 50, INIT_IVS_RANDOM, TRUE, personality, OTID_NOT_SET, 0);
        UpdateMonStatusAndTrainerInfo(mon, SaveData_GetTrainerInfo(saveData), 0, 0, HEAP_ID_FIELD2);
        Pokemon_SetValue(mon, MON_DATA_FORM, &form);
        Pokemon_SetValue(mon, MON_DATA_HELD_ITEM, &item);
        Pokemon_CalcAbility(mon);
        Pokemon_CalcLevelAndStats(mon);
    }

    Daycare_MoveToEmptySlotFromParty(party, 2, daycare, saveData);
    Daycare_MoveToEmptySlotFromParty(party, 1, daycare, saveData);
    Daycare_SetOffspringPersonality(daycare, gSovereignTestBreed.personality);
    Daycare_GiveEggFromDaycare(daycare, party, SaveData_GetTrainerInfo(saveData));

    int last = Party_GetCurrentCount(party) - 1;
    Pokemon *egg = Party_GetPokemonBySlotIndex(party, last);

    gSovereignTestBreed.eggSpecies = Pokemon_GetValue(egg, MON_DATA_SPECIES, NULL);
    gSovereignTestBreed.eggForm = Pokemon_GetValue(egg, MON_DATA_FORM, NULL);
    Egg_CreateHatchedMon(egg, HEAP_ID_FIELD2);
    gSovereignTestBreed.hatchedSpecies = Pokemon_GetValue(egg, MON_DATA_SPECIES, NULL);
    gSovereignTestBreed.hatchedForm = Pokemon_GetValue(egg, MON_DATA_FORM, NULL);

    for (int i = 0; i < LEARNED_MOVES_MAX; i++) {
        Pokemon_ResetMoveSlot(egg, sSovereignTestFairyMoves[i], i);
    }

    Party_SwapSlots(party, 0, last);
    gSovereignTestBreed.breed = FALSE;
}

// Test build only: uses the key item a test harness wrote to gSovereignTestItemUse on the lead, as the party menu does
// (it takes a fused partner out of the party), and writes down what it did (include/sovereign_test.h).
static void SovereignTest_UseItem(FieldSystem *fieldSystem, int use)
{
    Party *party = SaveData_GetParty(fieldSystem->saveData);
    int changedSlot, fusedPartnerSlot;

    gSovereignTestItemUse.results[use] = SovereignFormItem_Use(fieldSystem->saveData, party, 0, gSovereignTestItemUse.item, &changedSlot, &fusedPartnerSlot);

    if (fusedPartnerSlot >= 0) {
        Party_RemovePokemonBySlotIndex(party, fusedPartnerSlot);
    }

    Pokemon *lead = Party_GetPokemonBySlotIndex(party, 0);

    gSovereignTestItemUse.forms[use] = Pokemon_GetValue(lead, MON_DATA_FORM, NULL);
    gSovereignTestItemUse.partyCounts[use] = Party_GetCurrentCount(party);
    gSovereignTestItemUse.lastSpecies[use] = Pokemon_GetValue(Party_GetPokemonBySlotIndex(party, Party_GetCurrentCount(party) - 1), MON_DATA_SPECIES, NULL);

    for (int i = 0; i < LEARNED_MOVES_MAX; i++) {
        gSovereignTestItemUse.moves[use][i] = Pokemon_GetValue(lead, MON_DATA_MOVE1 + i, NULL);
    }
}

// Test build only (meson -Dsovereign_test=true): a wild battle (Chansey Lv. 30, or the Pokémon a test harness wrote to
// gSovereignTestWild); with env 1 a trainer battle (TRAINER_SOVEREIGN_TEST, or the trainer a test harness wrote to
// gSovereignTestBattleTrainer); with env 2 the next Totem trial (data/totem_trials.yaml, in order). A test harness can
// set the party's lead first (gSovereignTestLead) and use a form-change key item on it before and after the battle
// (gSovereignTestItemUse), and reads the lead's form when the battle is over.
static BOOL SovereignTest_BattleTask(FieldTask *task)
{
    int *state = FieldTask_GetState(task);

    if (*state == 0) {
        if (gSovereignTestLead.species != SPECIES_NONE) {
            SovereignTest_SetLead(FieldTask_GetFieldSystem(task));
        }

        if (gSovereignTestItemUse.item != ITEM_NONE) {
            SovereignTest_UseItem(FieldTask_GetFieldSystem(task), 0);
        }

        if (gSovereignTestEvolve.evolve) {
            SovereignTest_Evolve(FieldTask_GetFieldSystem(task));
        }

        if (gSovereignTestBreed.breed) {
            SovereignTest_Breed(FieldTask_GetFieldSystem(task));
        }

        if (FieldTask_GetEnv(task) == (void *)2) {
            Encounter_SovereignNewTotemTrial(task, sSovereignTestTotemTrial++ % SOVEREIGN_TOTEM_TRIAL_COUNT, &sSovereignTestBattleResult);
        } else if (FieldTask_GetEnv(task) != NULL) {
            // TRAINER_SOVEREIGN_TEST: a double battle against the developer team in the Sovereign trainer format (E9).
            int trainer = gSovereignTestBattleTrainer != TRAINER_NONE ? gSovereignTestBattleTrainer : TRAINER_SOVEREIGN_TEST;

            gSovereignTestBattleTrainer = TRAINER_NONE;
            Encounter_NewVsTrainer(task, trainer, TRAINER_NONE, TRAINER_NONE, HEAP_ID_FIELD2, &sSovereignTestBattleResult);
        } else if (gSovereignTestWild.species != SPECIES_NONE) {
            Encounter_SovereignTestNewVsWildForm(task, gSovereignTestWild.species, gSovereignTestWild.form, gSovereignTestWild.level, gSovereignTestWild.move, &sSovereignTestBattleResult);
            gSovereignTestWild.species = SPECIES_NONE;
        } else {
            Encounter_NewVsSpeciesAtLevel(task, SPECIES_CHANSEY, 30, &sSovereignTestBattleResult, FALSE);
        }

        (*state)++;
        return FALSE;
    }

    Pokemon *lead = Party_GetPokemonBySlotIndex(SaveData_GetParty(FieldTask_GetFieldSystem(task)->saveData), 0);
    gSovereignTestLeadFormAfter = Pokemon_GetValue(lead, MON_DATA_FORM, NULL);

    if (gSovereignTestItemUse.item != ITEM_NONE && gSovereignTestItemUse.times > 1) {
        SovereignTest_UseItem(FieldTask_GetFieldSystem(task), 1);
    }

    gSovereignTestItemUse.item = ITEM_NONE;
    return TRUE;
}
#endif

BOOL FieldInput_Process(const FieldInput *input, FieldSystem *fieldSystem)
{
    if (input->dummy5 == FALSE && FieldSystem_RunInitScript(fieldSystem, INIT_SCRIPT_ON_FRAME_TABLE) == TRUE) {
        return TRUE;
    }

    // dummy5 will always be false, so this branch will always be taken, but it doesn't match without the condition
    if (input->dummy5 == FALSE) {
        BOOL hasTwoAliveMons = Party_HasTwoAliveMons(SaveData_GetParty(fieldSystem->saveData));

        if (SystemFlag_CheckHasPartner(SaveData_GetVarsFlags(fieldSystem->saveData)) == TRUE) {
            hasTwoAliveMons = TRUE;
        }

        if (FieldSystem_CheckForTrainersWantingBattle(fieldSystem, hasTwoAliveMons) == TRUE
            || (PersistedMapFeatures_IsCurrentDynamicMap(fieldSystem, DYNAMIC_MAP_FEATURES_HEARTHOME_GYM) == TRUE
                && HearthomeGym_CheckIfPlayerSeesTrainer(fieldSystem) == TRUE)) {

            PlayerAvatar_ClearMoveState(fieldSystem->playerAvatar);
            MapObjectMan_PauseAllMovement(fieldSystem->mapObjMan);
            return TRUE;
        }
    }

    if (input->movement) {
        SystemFlag_ClearStep(SaveData_GetVarsFlags(fieldSystem->saveData));

        if (Field_ProcessStep(fieldSystem) == TRUE) {
            return TRUE;
        }
    }

    if (input->dummy5 == FALSE) {
        int playerEvent = PLAYER_EVENT_NONE;
        enum FaceDirection direction = PlayerAvatar_CalcFaceDirection(fieldSystem->playerAvatar, input->pressedKeys, input->heldKeys);

        if (SystemFlag_HandleStrengthActive(SaveData_GetVarsFlags(fieldSystem->saveData), HANDLE_FLAG_CHECK)) {
            playerEvent |= PLAYER_EVENT_USED_STRENGTH;
        }

        if (Sovereign_FieldMovePartySlot(fieldSystem->saveData, MOVE_WATERFALL) != PARTY_SLOT_NONE) { // Sovereign: HM in the bag is enough
            playerEvent |= PLAYER_EVENT_USED_WATERFALL;
        }

        if (PersistedMapFeatures_IsCurrentDynamicMap(fieldSystem, DYNAMIC_MAP_FEATURES_DISTORTION_WORLD) == TRUE && DistWorld_ArePersistedFeaturesInit(fieldSystem) == TRUE) {
            playerEvent |= PLAYER_EVENT_DISTORTION_WORLD;
        }

        if (ov5_021DFDE0(fieldSystem, fieldSystem->playerAvatar, direction, playerEvent) == TRUE) {
            return TRUE;
        }
    }

    if (input->endMovement) {
        if (Field_CheckWildEncounter(fieldSystem)) {
            return TRUE;
        }

        if (Field_CheckSign(fieldSystem) == TRUE) {
            return TRUE;
        }

        if (PersistedMapFeatures_IsCurrentDynamicMap(fieldSystem, DYNAMIC_MAP_FEATURES_DISTORTION_WORLD) == TRUE) {
            int direction = (s8)input->playerDir;

            if (direction == DIR_NONE) {
                direction = PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar);
            }

            if (DistWorld_HandlePlayerMovementEnd(fieldSystem, direction) == TRUE) {
                return TRUE;
            }
        }
    }

    if (input->sign
        && PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar) == input->playerDir
        && Field_CheckSign(fieldSystem) == TRUE) {
        return TRUE;
    }

    if (input->interact) {
        int validInteraction;
        MapObject *object;

        if (PersistedMapFeatures_IsCurrentDynamicMap(fieldSystem, DYNAMIC_MAP_FEATURES_DISTORTION_WORLD) == TRUE) {
            validInteraction = Field_DistortionInteract(fieldSystem, &object);
        } else {
            validInteraction = sub_0203CA40(fieldSystem, &object);
        }

        if (validInteraction == TRUE) {
            if (PlayerAvatar_CheckForceStopMovement(fieldSystem->playerAvatar) == TRUE) {
                PlayerAvatar_ForceStopMovement(fieldSystem->playerAvatar, PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar));
            }

            if (MapObject_GetTrainerType(object) != 0x9) {
                ScriptManager_Set(fieldSystem, MapObject_GetScript(object), object);
            } else {
                ScriptManager_Set(fieldSystem, 0, object);
            }

            return TRUE;
        }

        enum AvatarDistortionState distortionState = PlayerAvatar_MapDistortionState(fieldSystem->playerAvatar);

        if (distortionState == AVATAR_DISTORTION_STATE_NONE || distortionState == AVATAR_DISTORTION_STATE_ACTIVE) {
            int event = FieldEvent_GetInteractedBgEventScript(fieldSystem, MapHeaderData_GetBgEvents(fieldSystem), MapHeaderData_GetNumBgEvents(fieldSystem));

            if (event != 0xffff) {
                ScriptManager_Set(fieldSystem, event, NULL);
                return TRUE;
            }
        }

        if (distortionState == AVATAR_DISTORTION_STATE_NONE) {
            int event;

            if (HoneyTree_TryInteract(fieldSystem, &event)) {
                ScriptManager_Set(fieldSystem, event, NULL);
                return TRUE;
            }
        }

        int distortionDir = PlayerAvatar_GetDistortionDir(fieldSystem->playerAvatar);
        u32 distortionBehavior = PlayerAvatar_GetDistortionFacingTileBehaviour(fieldSystem->playerAvatar, distortionDir);
        int distortionScript = Field_TileBehaviorToScript(fieldSystem, distortionBehavior);

        if (distortionScript != 0xffff) {
            ScriptManager_Set(fieldSystem, distortionScript, NULL);
            return TRUE;
        }

        int playerX, playerZ;
        int playerDir = PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar);

        Field_Step(fieldSystem, &playerX, &playerZ);

        if (FieldSystem_TrySetVillaFurnitureScript(fieldSystem, playerX, playerZ, playerDir) == TRUE) {
            return TRUE;
        }
    }

    if (input->mapTransition) {
        if (PersistedMapFeatures_IsCurrentDynamicMap(fieldSystem, DYNAMIC_MAP_FEATURES_DISTORTION_WORLD) == TRUE) {
            DistWorld_CheckMapTransition(fieldSystem, input->transitionDir);
        } else if (Field_CheckMapTransition(fieldSystem, input) == TRUE) {
            Field_TrySetMapConnection(fieldSystem);
            return TRUE;
        }
    }

    if (input->registeredItem && sub_02069238(fieldSystem) == TRUE) {
        return TRUE;
    }

    if (input->menu && FieldSystem_IsInValidLocation(fieldSystem) == TRUE) {
        Sound_PlayEffect(SEQ_SE_DP_WIN_OPEN_sseq);
        StartMenu_Open(fieldSystem);
        return TRUE;
    }

#ifdef SOVEREIGN_TEST
    // Test build only: SELECT starts a wild battle, SELECT+R a trainer battle, SELECT+B+R the next Totem trial,
    // SELECT+L breeds and hatches an egg, SELECT+B opens Easy Chat, SELECT+L+R warps to the next test location
    // (script_manager.c).
    if ((input->pressedKeys & PAD_BUTTON_SELECT) && input->menu == FALSE) {
        int moveState = PlayerAvatar_GetPlayerMoveState(fieldSystem->playerAvatar);

        if ((input->heldKeys & PAD_BUTTON_B) && (input->heldKeys & PAD_BUTTON_R) && (moveState == PLAYER_MOVE_STATE_END || moveState == PLAYER_MOVE_STATE_NONE)) {
            FieldSystem_CreateTask(fieldSystem, SovereignTest_BattleTask, (void *)2);
            return TRUE;
        }

        if ((input->heldKeys & PAD_BUTTON_B) && (moveState == PLAYER_MOVE_STATE_END || moveState == PLAYER_MOVE_STATE_NONE)) {
            SovereignTest_OpenEasyChat(fieldSystem);
            return TRUE;
        }

        if ((input->heldKeys & PAD_BUTTON_L) && (input->heldKeys & PAD_BUTTON_R) && (moveState == PLAYER_MOVE_STATE_END || moveState == PLAYER_MOVE_STATE_NONE)) {
            SovereignTest_WarpNext(fieldSystem);
            return TRUE;
        }

        if ((input->heldKeys & PAD_BUTTON_L) && (moveState == PLAYER_MOVE_STATE_END || moveState == PLAYER_MOVE_STATE_NONE)) {
            SovereignTest_BreedAndHatch(fieldSystem);
            return FALSE;
        }

        if (moveState == PLAYER_MOVE_STATE_END || moveState == PLAYER_MOVE_STATE_NONE) {
            FieldSystem_CreateTask(fieldSystem, SovereignTest_BattleTask, (input->heldKeys & PAD_BUTTON_R) ? (void *)1 : NULL);
            return TRUE;
        }
    }
#endif

    return FALSE;
}

static BOOL Field_CheckSign(FieldSystem *fieldSystem)
{
    MapObject *object;

    if (sub_0203CBE0(fieldSystem, &object) == TRUE) {
        ScriptManager_Set(fieldSystem, MapObject_GetScript(object), object);
        return TRUE;
    }

    int event = FieldEvent_GetInteractedWallSignScript(fieldSystem, MapHeaderData_GetBgEvents(fieldSystem), MapHeaderData_GetNumBgEvents(fieldSystem));

    if (event != 0xffff) {
        ScriptManager_Set(fieldSystem, event, NULL);
        return TRUE;
    }

    return FALSE;
}

BOOL FieldInput_Process_Underground(FieldInput *input, FieldSystem *fieldSystem)
{
    if (input->dummy5 == FALSE && FieldSystem_RunInitScript(fieldSystem, INIT_SCRIPT_ON_FRAME_TABLE) == TRUE) {
        return TRUE;
    }

    if (sub_020363A0() || CommPlayer_GetMovementTimer(CommSys_CurNetId()) != 0) {
        return FALSE;
    }

    UndergroundMan_ProgressInteractCooldown();

    if (input->interact) {
        UndergroundMan_ProcessInteract(0);
        return FALSE;
    }

    if (input->menu) {
        UndergroundMan_OpenMenu();
        return FALSE;
    }

    if (UndergroundMan_CheckForTouchInput()) {
        return FALSE;
    }

    return FALSE;
}

BOOL FieldInput_Process_Colosseum(FieldInput *input, FieldSystem *fieldSystem)
{
    if (input->mapTransition
        && input->transitionDir == DIR_SOUTH
        && TileBehavior_IsWarpEntranceSouth(Field_CurrentTileBehavior(fieldSystem))) {

        ScriptManager_Set(fieldSystem, SCRIPT_ID(COMMUNICATION_CLUB, 1), NULL);
        return TRUE;
    }

    if (sub_020363A0() || CommPlayer_GetMovementTimer(CommSys_CurNetId()) != 0 || !FieldCommManager_IsInMovementState()) {
        return FALSE;
    }

    if (input->interact) {
        MapObject *object;

        if (sub_0203CA40(fieldSystem, &object) == TRUE && MapObject_GetMovementType(object) != 0x1) {
            if (PlayerAvatar_CheckForceStopMovement(fieldSystem->playerAvatar) == TRUE) {
                PlayerAvatar_ForceStopMovement(fieldSystem->playerAvatar, PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar));
            }

            ScriptManager_Set(fieldSystem, MapObject_GetScript(object), object);
            return TRUE;
        }
    }

    if (input->interact) {
        sub_0205B2D4(fieldSystem);
        return TRUE;
    }

    if (input->menu) {
        Sound_PlayEffect(SEQ_SE_DP_WIN_OPEN_sseq);
        StartMenu_OpenColosseum(fieldSystem);
        return TRUE;
    }

    return FALSE;
}

static int Field_CheckTrainerInfo(void)
{
    // C99-style declaration doesn't match
    int netId;
    int ret = 0;

    for (netId = 1; netId < 5; netId++) {
        TrainerInfo *info = CommInfo_TrainerInfo(netId);

        if (info != NULL) {
            ret++;
        }
    }

    return ret >= 1;
}

BOOL FieldInput_Process_UnionRoom(const FieldInput *input, FieldSystem *fieldSystem)
{
    if (WirelessManager_GetConnectedBitmap() & 0xfe) {
        if (Field_CheckTrainerInfo() && CommSys_ConnectedCount() > 1) {
            ScriptManager_Set(fieldSystem, 5, NULL);
            return TRUE;
        }

        return FALSE;
    }

    if (input->interact) {
        MapObject *object;

        if (sub_0203CA40(fieldSystem, &object) == TRUE) {
            if (PlayerAvatar_CheckForceStopMovement(fieldSystem->playerAvatar) == TRUE) {
                PlayerAvatar_ForceStopMovement(fieldSystem->playerAvatar, PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar));
            }

            CommManager_PauseUnionClient();
            ScriptManager_Set(fieldSystem, MapObject_GetScript(object), object);

            return TRUE;
        }
    }

    if (input->movement && TileBehavior_IsWarpPanel(Field_CurrentTileBehavior(fieldSystem))) {
        sub_020545EC(fieldSystem);
        return TRUE;
    }

    if (input->menu && CommSys_ConnectedCount() <= 1) {
        Sound_PlayEffect(SEQ_SE_DP_WIN_OPEN_sseq);
        StartMenu_OpenUnionRoom(fieldSystem);
        sub_0205BEA8(4);
        CommManager_PauseUnionServer();
        return TRUE;
    }

    return FALSE;
}

int FieldInput_Process_BattleTower(const FieldInput *input, FieldSystem *fieldSystem)
{
    if (input->dummy5 == FALSE && FieldSystem_RunInitScript(fieldSystem, INIT_SCRIPT_ON_FRAME_TABLE) == TRUE) {
        return TRUE;
    }

    if (input->interact) {
        MapObject *object;

        if (sub_0203CA40(fieldSystem, &object) == TRUE) {
            if (PlayerAvatar_CheckForceStopMovement(fieldSystem->playerAvatar) == TRUE) {
                PlayerAvatar_ForceStopMovement(fieldSystem->playerAvatar, PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar));
            }

            if (MapObject_GetTrainerType(object) != 0x9) {
                ScriptManager_Set(fieldSystem, MapObject_GetScript(object), object);
            } else {
                ScriptManager_Set(fieldSystem, 0, object);
            }

            return TRUE;
        }

        int v2 = FieldEvent_GetInteractedBgEventScript(fieldSystem, MapHeaderData_GetBgEvents(fieldSystem), MapHeaderData_GetNumBgEvents(fieldSystem));

        if (v2 != 0xffff) {
            ScriptManager_Set(fieldSystem, v2, NULL);
            return TRUE;
        }

        int tileScript = Field_TileBehaviorToScript(fieldSystem, Field_NextTileBehavior(fieldSystem));

        if (tileScript != 0xffff) {
            ScriptManager_Set(fieldSystem, tileScript, NULL);
            return TRUE;
        }
    }

    if (input->mapTransition && Field_CheckMapTransition(fieldSystem, input) == TRUE) {
        return TRUE;
    }

    if (input->registeredItem && sub_02069238(fieldSystem) == TRUE) {
        return TRUE;
    }

    if (input->menu) {
        Sound_PlayEffect(SEQ_SE_DP_WIN_OPEN_sseq);
        StartMenu_Open(fieldSystem);
        return TRUE;
    }

    return FALSE;
}

static BOOL Field_CheckWildEncounter(FieldSystem *fieldSystem)
{
    int playerX, playerZ;

    Field_GetPlayerPos(fieldSystem, &playerX, &playerZ);

    if (SystemFlag_CheckInPalPark(SaveData_GetVarsFlags(fieldSystem->saveData)) == TRUE) {
        if (CatchingShow_CheckWildEncounter(fieldSystem, playerX, playerZ) == TRUE) {
            Encounter_NewVsPalParkTransfer(fieldSystem, CatchingShow_GetBattleDataTransfer(fieldSystem));
            return TRUE;
        } else {
            return FALSE;
        }
    }

    return MapHeader_HasWildEncounters(fieldSystem->location->mapHeaderID) && WildEncounters_TryWildEncounter(fieldSystem) == TRUE;
}

static BOOL Field_CheckMapTransition(FieldSystem *fieldSystem, const FieldInput *input)
{
    if (input->transitionDir == DIR_NONE) {
        return FALSE;
    }

    if (PersistedMapFeatures_IsCurrentDynamicMap(fieldSystem, DYNAMIC_MAP_FEATURES_VEILSTONE_GYM) == TRUE && VeilstoneGym_HitPunchingBag(fieldSystem) == TRUE) {
        return TRUE;
    }

    int playerX, playerZ;
    Field_Step(fieldSystem, &playerX, &playerZ);

    if (TerrainCollisionManager_CheckCollision(fieldSystem, playerX, playerZ) == FALSE) {
        return FALSE;
    }

    u8 tileBehavior;
    Location nextMap;

    if (Field_MapConnection(fieldSystem, playerX, playerZ, &nextMap) && input->transitionDir != DIR_NONE) {
        tileBehavior = TerrainCollisionManager_GetTileBehavior(fieldSystem, playerX, playerZ);

        if (TileBehavior_IsDoor(tileBehavior)) {
            int transitionDir = input->transitionDir;

            if (PersistedMapFeatures_IsCurrentDynamicMap(fieldSystem, DYNAMIC_MAP_FEATURES_HEARTHOME_GYM) == TRUE) {
                HearthomeGym_CheckIfEnteredIncorrectDoor(fieldSystem, playerX, playerZ, &transitionDir);
            }

            sub_02056BDC(fieldSystem, nextMap.mapHeaderID, nextMap.warpId, 0, 0, transitionDir, 1);

            return TRUE;
        }
    }

    Field_GetPlayerPos(fieldSystem, &playerX, &playerZ);

    tileBehavior = TerrainCollisionManager_GetTileBehavior(fieldSystem, playerX, playerZ);

    if (TileBehavior_IsWarpEntranceEast(tileBehavior) || TileBehavior_IsWarpEast(tileBehavior)) {
        if (input->transitionDir != DIR_EAST) {
            return FALSE;
        }
    } else if (TileBehavior_IsWarpEntranceWest(tileBehavior) || TileBehavior_IsWarpWest(tileBehavior)) {
        if (input->transitionDir != DIR_WEST) {
            return FALSE;
        }
    } else if (TileBehavior_IsWarpEntranceSouth(tileBehavior) || TileBehavior_IsWarpSouth(tileBehavior)) {
        if (input->transitionDir != DIR_SOUTH) {
            return FALSE;
        }
    } else if (TileBehavior_IsWarpStairsEast(tileBehavior)) {
        if (input->transitionDir != DIR_EAST) {
            return FALSE;
        }
    } else if (TileBehavior_IsWarpStairsWest(tileBehavior)) {
        if (input->transitionDir != DIR_WEST) {
            return FALSE;
        }
    }

    if (Field_MapConnection(fieldSystem, playerX, playerZ, &nextMap) == FALSE) {
        return FALSE;
    }

    int transitionType;

    if (TileBehavior_IsDoor(tileBehavior)) {
        transitionType = 1;
    } else if (TileBehavior_IsWarpStairsEast(tileBehavior)) {
        transitionType = 3;
    } else if (TileBehavior_IsWarpStairsWest(tileBehavior)) {
        transitionType = 3;
    } else if (TileBehavior_IsWarpEntranceEast(tileBehavior) || TileBehavior_IsWarpEast(tileBehavior)
        || TileBehavior_IsWarpEntranceWest(tileBehavior) || TileBehavior_IsWarpWest(tileBehavior)
        || TileBehavior_IsWarpEntranceSouth(tileBehavior) || TileBehavior_IsWarpSouth(tileBehavior)) {
        sub_02056C18(fieldSystem, nextMap.mapHeaderID, nextMap.warpId, 0, 0, input->transitionDir);
        return TRUE;
    } else {
        return FALSE;
    }

    // these statements are unreachable, but required for matching
    sub_02056BDC(fieldSystem, nextMap.mapHeaderID, nextMap.warpId, 0, 0, input->transitionDir, transitionType);

    return TRUE;
}

u16 Field_TileBehaviorToScript(FieldSystem *fieldSystem, u8 behavior)
{
    int playerDir = PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar);

    if (TileBehavior_IsPC(behavior) && playerDir == DIR_NORTH) {
        return SCRIPT_ID(COMMON_SCRIPTS, 18);
    } else if (TileBehavior_IsSmallBookshelf1(behavior)) {
        return SCRIPT_ID(BG_EVENTS, 0);
    } else if (TileBehavior_IsSmallBookshelf2(behavior)) {
        return SCRIPT_ID(BG_EVENTS, 1);
    } else if (TileBehavior_IsBookshelf1(behavior)) {
        return SCRIPT_ID(BG_EVENTS, 2);
    } else if (TileBehavior_IsBookshelf2(behavior)) {
        return SCRIPT_ID(BG_EVENTS, 3);
    } else if (TileBehavior_IsTrashCan(behavior)) {
        return SCRIPT_ID(BG_EVENTS, 4);
    } else if (TileBehavior_IsMartShelf1(behavior)) {
        return SCRIPT_ID(BG_EVENTS, 5);
    } else if (TileBehavior_IsMartShelf2(behavior)) {
        return SCRIPT_ID(BG_EVENTS, 6);
    } else if (TileBehavior_IsMartShelf3(behavior)) {
        return SCRIPT_ID(BG_EVENTS, 7);
    } else if (TileBehavior_IsWaterfall(behavior)) {
        return SCRIPT_ID(FIELD_MOVES, 6);
    } else if (TileBehavior_IsTownMap(behavior)) {
        return SCRIPT_ID(BG_EVENTS, 8);
    } else if (TileBehavior_IsBikeParking(behavior)) {
        return SCRIPT_ID(COMMON_SCRIPTS, 30);
    } else if (TileBehavior_IsTV(behavior) && playerDir == DIR_NORTH) {
        return SCRIPT_ID(TV_BROADCAST, 0);
    }

    if (PlayerAvatar_CanUseRockClimb(behavior, playerDir)) {
        return SCRIPT_ID(FIELD_MOVES, 3);
    }

    if (PlayerAvatar_GetPlayerState(fieldSystem->playerAvatar) != PLAYER_AVATAR_SURFING) {
        TrainerInfo *info = SaveData_GetTrainerInfo(fieldSystem->saveData);
        u32 distortionBehavior = PlayerAvatar_GetDistortionCurrTileBehaviour(fieldSystem->playerAvatar);

        if (PlayerAvatar_CanUseSurf(fieldSystem->playerAvatar, distortionBehavior, behavior) && TrainerInfo_HasBadge(info, 3)) {
            if (Sovereign_FieldMovePartySlot(fieldSystem->saveData, MOVE_SURF) != PARTY_SLOT_NONE) { // Sovereign: HM in the bag is enough
                return SCRIPT_ID(FIELD_MOVES, 4);
            }
        }
    }

    return 0xffff;
}

static BOOL Field_ProcessStep(FieldSystem *fieldSystem)
{
    if (PersistedMapFeatures_IsCurrentDynamicMap(fieldSystem, DYNAMIC_MAP_FEATURES_CANALAVE_GYM) == TRUE && CanalaveGym_CheckIfPlayerOnPlatform(fieldSystem)) {
        return TRUE;
    }

    if (PersistedMapFeatures_IsCurrentDynamicMap(fieldSystem, DYNAMIC_MAP_FEATURES_DISTORTION_WORLD) == TRUE && DistWorld_HandlePlayerPositionChanged(fieldSystem) == TRUE) {
        return TRUE;
    }

    int playerDir = PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar);

    if (ov5_021E1154(fieldSystem, fieldSystem->playerAvatar, playerDir) == TRUE) {
        return TRUE;
    }

    int playerX = PlayerAvatar_GetXPos(fieldSystem->playerAvatar);
    int playerZ = PlayerAvatar_GetZPos(fieldSystem->playerAvatar);
    u8 tileBehavior = TerrainCollisionManager_GetTileBehavior(fieldSystem, playerX, playerZ);

    if (Field_CheckCoordEvent(fieldSystem) == TRUE) {
        return TRUE;
    }

    if (Field_CheckTransition(fieldSystem, playerX, playerZ, tileBehavior) == TRUE) {
        Field_TrySetMapConnection(fieldSystem);
        return TRUE;
    }

    if (PlayerAvatar_CheckForcedMovement(fieldSystem->playerAvatar)) {
        return FALSE;
    }

    FieldSystem_SendPoketchEvent(fieldSystem, POKETCH_EVENT_PEDOMETER, 1);

    if (Field_UpdatePoison(fieldSystem) == TRUE) {
        return TRUE;
    }

    if (Field_UpdateSafari(fieldSystem) == TRUE) {
        return TRUE;
    }

    if (Field_UpdateDaycare(fieldSystem) == TRUE) {
        return TRUE;
    }

    if (Field_UpdateVsSeeker(fieldSystem) == TRUE) {
        return TRUE;
    }

    if (Field_UpdatePokeRadar(fieldSystem) == TRUE) {
        return TRUE;
    }

    if (Field_UpdateRepel(fieldSystem) == TRUE) {
        return TRUE;
    }

    if (Field_UpdateFriendship(fieldSystem)) {
        Field_CalculateFriendship(fieldSystem);
    }

    SystemVars_IncrementAmitySquareStepCount(SaveData_GetVarsFlags(fieldSystem->saveData));
    return FALSE;
}

static BOOL Field_CheckCoordEvent(FieldSystem *fieldSystem)
{
    u16 event = sub_0203CC14(fieldSystem, MapHeaderData_GetCoordEvents(fieldSystem), MapHeaderData_GetNumCoordEvents(fieldSystem));

    if (event != 0xffff) {
        ScriptManager_Set(fieldSystem, event, NULL);
        return TRUE;
    }

    return FALSE;
}

static BOOL Field_CheckTransition(FieldSystem *fieldSystem, const int playerX, const int playerZ, const u8 curTileBehavior)
{
    Location nextMap;

    if (Field_MapConnection(fieldSystem, playerX, playerZ, &nextMap) == FALSE) {
        return FALSE;
    }

    if (TileBehavior_IsEscalatorFlipFace(curTileBehavior) == TRUE) {
        int playerDir = PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar);

        if (playerDir == DIR_WEST) {
            playerDir = DIR_EAST;
        } else if (playerDir == DIR_EAST) {
            playerDir = DIR_WEST;
        } else {
            GF_ASSERT(FALSE);
            return FALSE;
        }

        sub_02056BDC(fieldSystem, nextMap.mapHeaderID, nextMap.warpId, 0, 0, playerDir, 2);
        return TRUE;
    } else if (TileBehavior_IsEscalator(curTileBehavior) == TRUE) {
        int playerDir = PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar);

        if (playerDir != DIR_WEST && playerDir != DIR_EAST) {
            GF_ASSERT(FALSE);
            return FALSE;
        }

        sub_02056BDC(fieldSystem, nextMap.mapHeaderID, nextMap.warpId, 0, 0, playerDir, 2);
        return TRUE;
    }

    if (TileBehavior_IsWarpEntranceNorth(curTileBehavior) || TileBehavior_IsWarpNorth(curTileBehavior)) {
        sub_02056C18(fieldSystem, nextMap.mapHeaderID, nextMap.warpId, 0, 0, 0);
        return TRUE;
    }

    if (TileBehavior_IsWarpPanel(curTileBehavior)) {
        FieldSystem_StartMapChangeWarpTask(fieldSystem, nextMap.mapHeaderID, nextMap.warpId);
        return TRUE;
    }

    return FALSE;
}

static BOOL Field_UpdateDaycare(FieldSystem *fieldSystem)
{
    Party *party = SaveData_GetParty(fieldSystem->saveData);
    Daycare *daycare = SaveData_GetDaycare(fieldSystem->saveData);

    if (Daycare_Update(daycare, party, fieldSystem) == TRUE) {
        GameRecords *records = SaveData_GetGameRecords(fieldSystem->saveData);

        GameRecords_IncrementRecordValue(records, RECORD_EGGS_HATCHED);
        GameRecords_IncrementTrainerScore(records, TRAINER_SCORE_EVENT_UNK_15);
        ScriptManager_Set(fieldSystem, SCRIPT_ID(COMMON_SCRIPTS, 31), NULL);

        return TRUE;
    }

    return FALSE;
}

static BOOL Field_UpdateVsSeeker(FieldSystem *fieldSystem)
{
    VsSeeker_UpdateStepCount(fieldSystem);
    return FALSE;
}

static BOOL Field_UpdatePokeRadar(FieldSystem *fieldSystem)
{
    RadarChargeStep(fieldSystem);
    return FALSE;
}

static BOOL Field_UpdateRepel(FieldSystem *fieldSystem)
{
    return Repel_UpdateSteps(fieldSystem->saveData, fieldSystem);
}

static BOOL Field_UpdateFriendship(FieldSystem *fieldSystem)
{
    VarsFlags *vars;
    BOOL ret = FALSE;

    vars = SaveData_GetVarsFlags(fieldSystem->saveData);
    u16 steps = SystemVars_GetFriendshipStepCount(vars);

    steps++;

    if (steps >= 128) {
        steps = 0;
        ret = TRUE;
    }

    SystemVars_SetFriendshipStepCount(vars, steps);

    return ret;
}

static void Field_CalculateFriendship(FieldSystem *fieldSystem)
{
    // C99-style declarations don't match
    int i, partyCount;
    Party *party = SaveData_GetParty(fieldSystem->saveData);
    u16 mapID = MapHeader_GetMapLabelTextID(fieldSystem->location->mapHeaderID);

    partyCount = Party_GetCurrentCount(party);

    for (i = 0; i < partyCount; i++) {
        Pokemon *mon = Party_GetPokemonBySlotIndex(party, i);
        Pokemon_UpdateFriendship(mon, FRIENDSHIP_EVENT_WALK_CYCLE, mapID);
    }
}

static BOOL Field_UpdatePoison(FieldSystem *fieldSystem)
{
    Party *party = SaveData_GetParty(fieldSystem->saveData);
    u16 *poisonSteps = FieldOverworldState_GetPoisonStepCount(SaveData_GetFieldOverworldState(fieldSystem->saveData));

    (*poisonSteps)++;
    (*poisonSteps) %= 4;

    if (*poisonSteps != 0) {
        return FALSE;
    }

    switch (Pokemon_DoPoisonDamage(party, MapHeader_GetMapLabelTextID(fieldSystem->location->mapHeaderID))) {
    case FLDPSN_NONE:
        return FALSE;
    case FLDPSN_POISONED:
        Field_DoPoisonEffect(fieldSystem->unk_04->unk_20);
        return FALSE;
    case FLDPSN_FAINTED:
        Field_DoPoisonEffect(fieldSystem->unk_04->unk_20);
        ScriptManager_Set(fieldSystem, SCRIPT_ID(COMMON_SCRIPTS, 3), NULL);
        return TRUE;
    }

    return FALSE;
}

static BOOL Field_UpdateSafari(FieldSystem *fieldSystem)
{
    if (SystemFlag_CheckSafariGameActive(SaveData_GetVarsFlags(fieldSystem->saveData)) == FALSE) {
        return FALSE;
    }

    u16 *balls = FieldOverworldState_GetSafariBallCount(SaveData_GetFieldOverworldState(fieldSystem->saveData));

    if (*balls == 0) {
        ScriptManager_Set(fieldSystem, SCRIPT_ID(SAFARI_GAME, 2), NULL);
        return TRUE;
    }

    u16 *steps = FieldOverworldState_GetSafariStepCount(SaveData_GetFieldOverworldState(fieldSystem->saveData));
    (*steps)++;

    if (*steps >= 500) {
        ScriptManager_Set(fieldSystem, SCRIPT_ID(SAFARI_GAME, 1), NULL);
        return TRUE;
    }

    return FALSE;
}

static void Field_GetPlayerPos(const FieldSystem *fieldSystem, int *playerX, int *playerZ)
{
    *playerX = PlayerAvatar_GetXPos(fieldSystem->playerAvatar);
    *playerZ = PlayerAvatar_GetZPos(fieldSystem->playerAvatar);
}

static void Field_Step(const FieldSystem *fieldSystem, int *playerX, int *playerZ)
{
    int playerDir = PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar);
    Field_StepInDirection(fieldSystem, playerDir, playerX, playerZ);
}

static void Field_StepInDirection(const FieldSystem *fieldSystem, int playerDir, int *playerX, int *playerZ)
{
    Field_GetPlayerPos(fieldSystem, playerX, playerZ);

    switch (playerDir) {
    case DIR_NORTH:
        *playerZ -= 1;
        break;
    case DIR_SOUTH:
        *playerZ += 1;
        break;
    case DIR_WEST:
        *playerX -= 1;
        break;
    case DIR_EAST:
        *playerX += 1;
        break;
    default:
        GF_ASSERT("FALSE");
    }
}

static u8 Field_CurrentTileBehavior(const FieldSystem *fieldSystem)
{
    int playerX, playerZ;
    Field_GetPlayerPos(fieldSystem, &playerX, &playerZ);
    return TerrainCollisionManager_GetTileBehavior(fieldSystem, playerX, playerZ);
}

static u8 Field_NextTileBehavior(const FieldSystem *fieldSystem)
{
    int playerX, playerZ;
    Field_Step(fieldSystem, &playerX, &playerZ);
    return TerrainCollisionManager_GetTileBehavior(fieldSystem, playerX, playerZ);
}

static BOOL Field_MapConnection(const FieldSystem *fieldSystem, int playerX, int playerZ, Location *nextMap)
{
    int eventIndex = MapHeaderData_GetIndexOfWarpEventAtPos(fieldSystem, playerX, playerZ);

    if (eventIndex == -1) {
        return FALSE;
    }

    const WarpEvent *warpEvent = MapHeaderData_GetWarpEventByIndex(fieldSystem, eventIndex);

    if (warpEvent == NULL) {
        return FALSE;
    }

    if (warpEvent->destWarpID == 0x100) {
        GF_ASSERT(warpEvent->destHeaderID == 0xfff);
        *nextMap = *(FieldOverworldState_GetSpecialLocation(SaveData_GetFieldOverworldState(fieldSystem->saveData)));
    } else {
        Location_Set(nextMap, warpEvent->destHeaderID, warpEvent->destWarpID, warpEvent->x, warpEvent->z, 1);
    }

    Location *entrance = FieldOverworldState_GetEntranceLocation(SaveData_GetFieldOverworldState(fieldSystem->saveData));
    Location_Set(entrance, fieldSystem->location->mapHeaderID, eventIndex, playerX, playerZ, PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar));

    return TRUE;
}

static void Field_SetMapConnection(FieldSystem *fieldSystem, const int playerX, const int playerZ, const int playerDir)
{
    FieldOverworldState *fieldState = SaveData_GetFieldOverworldState(fieldSystem->saveData);
    Location *nextMap = FieldOverworldState_GetExitLocation(fieldState);

    (*nextMap) = *(fieldSystem->location);
    nextMap->faceDirection = playerDir;
    nextMap->x = playerX;
    nextMap->z = playerZ;

    if (playerDir == DIR_NORTH) {
        (nextMap->z)++;
    }

    nextMap->mapHeaderID = fieldSystem->location->mapHeaderID;
    nextMap->warpId = WARP_ID_NONE;
}

static void Field_TrySetMapConnection(FieldSystem *fieldSystem)
{
    int playerX, playerZ;
    Field_GetPlayerPos(fieldSystem, &playerX, &playerZ);

    Location nextMap;

    if (Field_MapConnection(fieldSystem, playerX, playerZ, &nextMap)) {
        if (MapHeader_IsOnMainMatrix(fieldSystem->location->mapHeaderID) == TRUE && MapHeader_IsOnMainMatrix(nextMap.mapHeaderID) == FALSE) {
            Field_SetMapConnection(fieldSystem, playerX, playerZ, PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar));
        }
    } else {
        Field_Step(fieldSystem, &playerX, &playerZ);

        if (Field_MapConnection(fieldSystem, playerX, playerZ, &nextMap)
            && MapHeader_IsOnMainMatrix(fieldSystem->location->mapHeaderID) == TRUE
            && MapHeader_IsOnMainMatrix(nextMap.mapHeaderID) == FALSE) {

            Field_SetMapConnection(fieldSystem, playerX, playerZ, PlayerAvatar_GetFacingDir(fieldSystem->playerAvatar));
        }
    }
}

static BOOL Field_DistortionInteract(FieldSystem *fieldSystem, MapObject **object)
{
    int objectIndex = 0;
    int playerX, playerY, playerZ, objectX, objectY, objectZ;

    PlayerAvatar_GetFacingDistortionWorldPos(fieldSystem->playerAvatar, &playerX, &playerY, &playerZ);

    while (MapObjectMan_FindObjectWithStatus(fieldSystem->mapObjMan, object, &objectIndex, 1 << 0)) {
        objectX = MapObject_GetX(*object);
        objectY = MapObject_GetY(*object) / 2;
        objectZ = MapObject_GetZ(*object);

        if (playerY == objectY && playerX == objectX && playerZ == objectZ) {
            return TRUE;
        }
    }

    return FALSE;
}
