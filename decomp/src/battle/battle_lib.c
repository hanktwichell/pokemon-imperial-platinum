#include "battle/battle_lib.h"

#include <nitro.h>
#include <string.h>

#include "constants/battle.h"
#include "constants/battle/battle_script.h"
#include "constants/communication/comm_error.h"
#include "constants/flavor.h"
#include "constants/heap.h"
#include "constants/items.h"
#include "constants/sound.h"
#include "constants/species.h"
#include "constants/string.h"
#include "generated/abilities.h"
#include "generated/game_records.h"
#include "generated/genders.h"

#include "struct_decls/battle_system.h"
#include "struct_defs/battler_data.h"
#include "struct_defs/fraction.h"

#include "battle/battle_context.h"
#include "battle/battle_controller.h"
#include "battle/battle_controller_player.h"
#include "battle/battle_display.h"
#include "battle/battle_mon.h"
#include "battle/battle_system.h"
#include "battle/common.h"

#include "charcode_util.h"
#include "comm_manager.h"
#include "flags.h"
#include "heap.h"
#include "item.h"
#include "move_table.h"
#include "narc.h"
#include "party.h"
#include "pokedex_data_index.h"
#include "pokedex_heightweight.h"
#include "pokemon.h"
#include "sovereign_test.h"
#include "string_gf.h"
#include "trainer_data.h"
#include "trainer_info.h"
#include "unk_0208C098.h"

#include "res/battle/scripts/sub_seq.naix"
#include "res/text/bank/battle_strings.h"

#define TRMSG_ACTIVE_BATTLER_HALF_HP_FLAG 2
#define TRMSG_LAST_BATTLER_FLAG           3
#define TRMSG_LAST_BATTLER_HALF_HP_FLAG   4

static BOOL BasicTypeMulApplies(BattleContext *battleCtx, int attacker, int defender, int chartEntry);
static int MapSideEffectToSubscript(BattleContext *battleCtx, enum BattleSideEffectType type, u32 effect);
static int ApplyTypeMultiplier(BattleContext *battleCtx, int attacker, int mul, int damage, BOOL update, u32 *moveStatus);
static BOOL NoImmunityOverrides(BattleContext *battleCtx, int itemEffect, int chartEntry);
static void UpateMoveStatusForTypeMul(int mul, u32 *moveStatusMask);
static BOOL MoveIsOnDamagingTurn(BattleContext *battleCtx, int move);
static BOOL AbilityAbsorbsMove(int attackerAbility, int defenderAbility, int moveType);
static u8 Battler_MonType(BattleContext *battleCtx, int battler, enum BattleMonParam paramID);
static void BattleAI_ClearKnownMoves(BattleContext *battleCtx, u8 battler);
static void BattleAI_ClearKnownAbility(BattleContext *battleCtx, u8 battler);
static void BattleAI_ClearKnownItem(BattleContext *battleCtx, u8 battler);
static int ChooseTraceTarget(BattleSystem *battleSys, BattleContext *battleCtx, int defender1, int defender2);
static BOOL MoveCannotTriggerAnticipation(BattleContext *battleCtx, int move);
static int CalcMoveType(BattleSystem *battleSys, BattleContext *battleCtx, int item, int move);
static BOOL Sovereign_ProtosynthesisHasSun(BattleSystem *battleSys, BattleContext *battleCtx);
BOOL Sovereign_MakesContact(BattleContext *battleCtx, int attacker, int move);

static const Fraction sStatStageBoosts[];

void BattleSystem_InitBattleMon(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int partySlot)
{
    Pokemon *mon = BattleSystem_GetPartyPokemon(battleSys, battler, partySlot);

    Pokemon_SovereignRevertSwitchOutForm(mon); // Sovereign (FM): Pirouette Meloetta switches back in as Aria

    // Sovereign (item 11): a Pokemon coming in commands no Dondozo and is commanded by no Tatsugiri yet.
    battleCtx->sovereignCommanding &= ~FlagIndex(battler);
    battleCtx->sovereignCommanded &= ~FlagIndex(battler);
    // Nor does it carry or get carried by Sky Drop; BattleSystem_TriggerEffectOnSwitch lets the other Pokemon go.
    battleCtx->sovereignSkyDropTarget[battler] = 0;
    battleCtx->sovereignSkyDropHolder[battler] = 0;
    battleCtx->sovereignHPBeforeAction[battler] = 0; // and has lost no HP yet (Emergency Exit)
    battleCtx->sovereignHPBeforeTurnEnd[battler] = 0;
    battleCtx->sovereignEjectPackPending &= ~FlagIndex(battler); // nor had a stat lowered (Eject Pack)

    battleCtx->battleMons[battler].species = Pokemon_GetValue(mon, MON_DATA_SPECIES, NULL);
    battleCtx->battleMons[battler].attack = Pokemon_GetValue(mon, MON_DATA_ATK, NULL);
    battleCtx->battleMons[battler].defense = Pokemon_GetValue(mon, MON_DATA_DEF, NULL);
    battleCtx->battleMons[battler].speed = Pokemon_GetValue(mon, MON_DATA_SPEED, NULL);
    battleCtx->battleMons[battler].spAttack = Pokemon_GetValue(mon, MON_DATA_SP_ATK, NULL);
    battleCtx->battleMons[battler].spDefense = Pokemon_GetValue(mon, MON_DATA_SP_DEF, NULL);

    int i;
    for (i = 0; i < LEARNED_MOVES_MAX; i++) {
        battleCtx->battleMons[battler].moves[i] = Pokemon_GetValue(mon, MON_DATA_MOVE1 + i, NULL);
        battleCtx->battleMons[battler].ppCur[i] = Pokemon_GetValue(mon, MON_DATA_MOVE1_PP + i, NULL);
        battleCtx->battleMons[battler].ppUps[i] = Pokemon_GetValue(mon, MON_DATA_MOVE1_PP_UPS + i, NULL);
    }

    battleCtx->battleMons[battler].hpIV = Pokemon_GetValue(mon, MON_DATA_HP_IV, NULL);
    battleCtx->battleMons[battler].attackIV = Pokemon_GetValue(mon, MON_DATA_ATK_IV, NULL);
    battleCtx->battleMons[battler].defenseIV = Pokemon_GetValue(mon, MON_DATA_DEF_IV, NULL);
    battleCtx->battleMons[battler].speedIV = Pokemon_GetValue(mon, MON_DATA_SPEED_IV, NULL);
    battleCtx->battleMons[battler].spAttackIV = Pokemon_GetValue(mon, MON_DATA_SPATK_IV, NULL);
    battleCtx->battleMons[battler].spDefenseIV = Pokemon_GetValue(mon, MON_DATA_SPDEF_IV, NULL);
    battleCtx->battleMons[battler].isEgg = Pokemon_GetValue(mon, MON_DATA_IS_EGG, NULL);
    battleCtx->battleMons[battler].hasNickname = Pokemon_GetValue(mon, MON_DATA_HAS_NICKNAME, NULL);

    // Sovereign (item 11): Shed Tail passes on no stat stages.
    if ((battleCtx->battleStatusMask & SYSCTL_BATON_PASS) == FALSE || battleCtx->sovereignShedTail) {
        for (i = 0; i < BATTLE_STAT_MAX; i++) {
            battleCtx->battleMons[battler].statBoosts[i] = DEFAULT_STAT_STAGE;
        }
    }

    battleCtx->battleMons[battler].weatherAbilityAnnounced = FALSE;
    battleCtx->battleMons[battler].intimidateAnnounced = FALSE;
    battleCtx->battleMons[battler].traceAnnounced = FALSE;
    battleCtx->battleMons[battler].downloadAnnounced = FALSE;
    battleCtx->battleMons[battler].anticipationAnnounced = FALSE;
    battleCtx->battleMons[battler].forewarnAnnounced = FALSE;
    battleCtx->battleMons[battler].slowStartAnnounced = FALSE;
    battleCtx->battleMons[battler].slowStartFinished = FALSE;
    battleCtx->battleMons[battler].friskAnnounced = FALSE;
    battleCtx->battleMons[battler].moldBreakerAnnounced = FALSE;
    battleCtx->battleMons[battler].pressureAnnounced = FALSE;
    battleCtx->battleMons[battler].sovereignBoosterEnergy = FALSE;
    battleCtx->battleMons[battler].sovereignProteanUsed = FALSE;
    battleCtx->battleMons[battler].sovereignBalloonAnnounced = FALSE; // Sovereign (item 11)
    battleCtx->battleMons[battler].sovereignGasAnnounced = FALSE; // Sovereign (item 11)
    battleCtx->battleMons[battler].sovereignMimicryTerrain = SOVEREIGN_MIMICRY_UNSEEN; // Sovereign (item 11)
    battleCtx->sovereignCudChewBerry[battler] = ITEM_NONE; // Sovereign (item 11)
    battleCtx->battleMons[battler].sovereignEntryAnnounced = FALSE;
    battleCtx->battleMons[battler].sovereignHPFormChecked = FALSE;
    battleCtx->battleMons[battler].sovereignIceFaceHail = FALSE;
    battleCtx->battleMons[battler].type1 = Pokemon_GetValue(mon, MON_DATA_TYPE_1, NULL);
    battleCtx->battleMons[battler].type2 = Pokemon_GetValue(mon, MON_DATA_TYPE_2, NULL);
    battleCtx->battleMons[battler].sovereignAddedType = 0; // Sovereign (item 11): a new type replaces an added one
    battleCtx->battleMons[battler].gender = Pokemon_GetGender(mon);
    battleCtx->battleMons[battler].isShiny = Pokemon_IsShiny(mon);

    if (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_NO_ABILITIES) {
        battleCtx->battleMons[battler].ability = ABILITY_NONE;
        battleCtx->battleMons[battler].status = MON_CONDITION_NONE;
        battleCtx->battleMons[battler].heldItem = ITEM_NONE;
    } else {
        battleCtx->battleMons[battler].ability = Pokemon_GetValue(mon, MON_DATA_ABILITY, NULL);

        // Sovereign (FM): a Terastal Terapagos switching back in still has its form's Tera Shell.
        u16 sovereignSpecies = battleCtx->battleMons[battler].species;
        int sovereignForm = Pokemon_GetValue(mon, MON_DATA_FORM, NULL);
        if (battleCtx->battleMons[battler].ability == ABILITY_TERA_SHIFT
            && Pokemon_SovereignFormChangesAbility(sovereignSpecies, sovereignForm)) {
            battleCtx->battleMons[battler].ability = SpeciesData_GetFormValue(sovereignSpecies, sovereignForm, SPECIES_DATA_ABILITY_1);
        }

        battleCtx->battleMons[battler].status = Pokemon_GetValue(mon, MON_DATA_STATUS, NULL);
        battleCtx->battleMons[battler].heldItem = Pokemon_GetValue(mon, MON_DATA_HELD_ITEM, NULL);
    }

    if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_NO_ABILITIES) && BattleSystem_GetBattlerSide(battleSys, battler) == BATTLER_US) {
        battleCtx->battleMons[battler].formNum = 0;
    } else {
        battleCtx->battleMons[battler].formNum = Pokemon_GetValue(mon, MON_DATA_FORM, NULL);
    }

    battleCtx->battleMons[battler].level = Pokemon_GetValue(mon, MON_DATA_LEVEL, NULL);
    battleCtx->battleMons[battler].friendship = Pokemon_GetValue(mon, MON_DATA_FRIENDSHIP, NULL);
    battleCtx->battleMons[battler].curHP = Pokemon_GetValue(mon, MON_DATA_HP, NULL);
    battleCtx->battleMons[battler].maxHP = Pokemon_GetValue(mon, MON_DATA_MAX_HP, NULL);
    battleCtx->battleMons[battler].exp = Pokemon_GetValue(mon, MON_DATA_EXPERIENCE, NULL);
    battleCtx->battleMons[battler].personality = Pokemon_GetValue(mon, MON_DATA_PERSONALITY, NULL);
    battleCtx->battleMons[battler].OTId = Pokemon_GetValue(mon, MON_DATA_OT_ID, NULL);
    battleCtx->battleMons[battler].OTGender = Pokemon_GetValue(mon, MON_DATA_OT_GENDER, NULL);
    battleCtx->battleMons[battler].capturedBall = Pokemon_GetValue(mon, MON_DATA_POKEBALL, NULL);

    Pokedex_SetupGiratina(battleCtx->battleMons[battler].formNum);

    HeightWeightData *heightWeightData = Pokedex_HeightWeightData(HEAP_ID_BATTLE);
    Pokedex_HeightWeightData_Load(heightWeightData, 0, HEAP_ID_BATTLE);

    battleCtx->battleMons[battler].weight = Pokedex_HeightWeightData_Weight(heightWeightData, battleCtx->battleMons[battler].species);

    Pokedex_HeightWeightData_Release(heightWeightData);
    Pokedex_HeightWeightData_Free(heightWeightData);
    Pokemon_GetValue(mon, MON_DATA_NICKNAME, battleCtx->battleMons[battler].nickname);
    Pokemon_GetValue(mon, MON_DATA_OT_NAME, battleCtx->battleMons[battler].OTName);

    battleCtx->battleMons[battler].timesDamaged = 0;
    battleCtx->battleMons[battler].trainerMessageFlags = 0;

    int side = BattleSystem_GetBattlerSide(battleSys, battler);
    if (battleCtx->sideConditions[side].knockedOffItemsMask & FlagIndex(battleCtx->selectedPartySlot[battler])) {
        battleCtx->battleMons[battler].heldItem = ITEM_NONE;
        battleCtx->battleMons[battler].moveEffectsData.canUnburden = FALSE;
    } else if (battleCtx->battleMons[battler].heldItem) {
        battleCtx->battleMons[battler].moveEffectsData.canUnburden = TRUE;
    }
}

void BattleSystem_ReloadPokemon(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int partySlot)
{
    Pokemon *mon = BattleSystem_GetPartyPokemon(battleSys, battler, partySlot);

    battleCtx->battleMons[battler].attack = Pokemon_GetValue(mon, MON_DATA_ATK, NULL);
    battleCtx->battleMons[battler].defense = Pokemon_GetValue(mon, MON_DATA_DEF, NULL);
    battleCtx->battleMons[battler].speed = Pokemon_GetValue(mon, MON_DATA_SPEED, NULL);
    battleCtx->battleMons[battler].spAttack = Pokemon_GetValue(mon, MON_DATA_SP_ATK, NULL);
    battleCtx->battleMons[battler].spDefense = Pokemon_GetValue(mon, MON_DATA_SP_DEF, NULL);
    battleCtx->battleMons[battler].level = Pokemon_GetValue(mon, MON_DATA_LEVEL, NULL);
    battleCtx->battleMons[battler].friendship = Pokemon_GetValue(mon, MON_DATA_FRIENDSHIP, NULL);
    battleCtx->battleMons[battler].curHP = Pokemon_GetValue(mon, MON_DATA_HP, NULL);
    battleCtx->battleMons[battler].maxHP = Pokemon_GetValue(mon, MON_DATA_MAX_HP, NULL);

    if ((battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE) {
        for (int i = 0; i < LEARNED_MOVES_MAX; i++) {
            if ((battleCtx->battleMons[battler].moveEffectsData.mimickedMoveSlot & FlagIndex(i)) == FALSE) {
                battleCtx->battleMons[battler].moves[i] = Pokemon_GetValue(mon, MON_DATA_MOVE1 + i, NULL);
                battleCtx->battleMons[battler].ppCur[i] = Pokemon_GetValue(mon, MON_DATA_MOVE1_PP + i, NULL);
                battleCtx->battleMons[battler].ppUps[i] = Pokemon_GetValue(mon, MON_DATA_MOVE1_PP_UPS + i, NULL);
            }
        }

        battleCtx->battleMons[battler].exp = Pokemon_GetValue(mon, MON_DATA_EXPERIENCE, NULL);
    }
}

void BattleSystem_LoadScript(BattleContext *battleCtx, enum NarcID narcID, int file)
{
    GF_ASSERT(NARC_GetMemberSizeByIndexPair(narcID, file) < BATTLE_SCRIPT_SIZE_MAX * sizeof(u32));

    battleCtx->scriptNarc = narcID;
    battleCtx->scriptFile = file;
    battleCtx->scriptCursor = 0;

    NARC_ReadWholeMemberByIndexPair(&battleCtx->battleScript, narcID, file);
}

void BattleSystem_CallScript(BattleContext *battleCtx, enum NarcID narcID, int file)
{
    GF_ASSERT(NARC_GetMemberSizeByIndexPair(narcID, file) < BATTLE_SCRIPT_SIZE_MAX * sizeof(u32));
    GF_ASSERT(battleCtx->scriptStackPointer < 4);

    battleCtx->scriptStackNarc[battleCtx->scriptStackPointer] = battleCtx->scriptNarc;
    battleCtx->scriptStackFile[battleCtx->scriptStackPointer] = battleCtx->scriptFile;
    battleCtx->scriptStackCursor[battleCtx->scriptStackPointer] = battleCtx->scriptCursor;
    battleCtx->scriptStackPointer++;
    battleCtx->scriptNarc = narcID;
    battleCtx->scriptFile = file;
    battleCtx->scriptCursor = 0;

    NARC_ReadWholeMemberByIndexPair(&battleCtx->battleScript, narcID, file);
}

BOOL BattleSystem_PopScript(BattleContext *battleCtx)
{
    if (battleCtx->scriptStackPointer) {
        battleCtx->scriptStackPointer--;
        BattleSystem_LoadScript(battleCtx, battleCtx->scriptStackNarc[battleCtx->scriptStackPointer], battleCtx->scriptStackFile[battleCtx->scriptStackPointer]);

        battleCtx->scriptCursor = battleCtx->scriptStackCursor[battleCtx->scriptStackPointer];
        return FALSE;
    }

    return TRUE;
}

void BattleIO_EnqueueVal(BattleContext *battleCtx, int id, int battler, int val)
{
    int i;

    for (i = 0; i < BATTLE_IO_QUEUE_SIZE; i++) {
        if (battleCtx->ioQueue[id][battler][i] == 0) {
            battleCtx->ioQueue[id][battler][i] = val;
            break;
        }
    }

    GF_ASSERT(i < BATTLE_IO_QUEUE_SIZE);
}

void BattleIO_DequeueVal(BattleContext *battleCtx, int id, int battler, int val)
{
    int i;

    GF_ASSERT(val != 0);

    for (i = 0; i < BATTLE_IO_QUEUE_SIZE; i++) {
        if (battleCtx->ioQueue[id][battler][i] == val) {
            battleCtx->ioQueue[id][battler][i] = 0;
            break;
        }
    }

    GF_ASSERT(i < BATTLE_IO_QUEUE_SIZE);
}

BOOL BattleIO_QueueIsEmpty(BattleContext *battleCtx)
{
    int linkedPlayer, battler, j;
    int sumData = 0;

    for (linkedPlayer = 0; linkedPlayer < MAX_LINK_BATTLERS; linkedPlayer++) {
        for (battler = 0; battler < MAX_BATTLERS; battler++) {
            for (j = 0; j < BATTLE_IO_QUEUE_SIZE; j++) {
                sumData += battleCtx->ioQueue[linkedPlayer][battler][j];
            }
        }
    }

    if (sumData == 0) {
        battleCtx->linkBattleTimeout = 0;
    }

    return sumData == 0;
}

void BattleIO_UpdateTimeout(BattleContext *battleCtx)
{
    battleCtx->linkBattleTimeout++;
    if (battleCtx->linkBattleTimeout > LINK_BATTLE_TIMEOUT) {
        CommManager_SetCommError(COMM_ERROR_RESET_SAVEPOINT);
    }
}

void BattleIO_ClearBuffer(BattleContext *battleCtx, int battler)
{
    for (int i = 0; i < BATTLE_IO_BUFFER_SIZE; i++) {
        battleCtx->ioBuffer[battler][i] = 0;
    }
}

int BattleMon_Get(BattleContext *battleCtx, int battler, enum BattleMonParam paramID, void *buf)
{
    BattleMon *battleMon = &battleCtx->battleMons[battler];

    switch (paramID) {
    case BATTLEMON_SPECIES:
        return battleMon->species;

    case BATTLEMON_ATTACK:
        return battleMon->attack;

    case BATTLEMON_DEFENSE:
        return battleMon->defense;

    case BATTLEMON_SPEED:
        return battleMon->speed;

    case BATTLEMON_SP_ATTACK:
        return battleMon->spAttack;

    case BATTLEMON_SP_DEFENSE:
        return battleMon->spDefense;

    case BATTLEMON_MOVE_1:
    case BATTLEMON_MOVE_2:
    case BATTLEMON_MOVE_3:
    case BATTLEMON_MOVE_4:
        return battleMon->moves[paramID - BATTLEMON_MOVE_1];

    case BATTLEMON_HP_IV:
        return battleMon->hpIV;

    case BATTLEMON_ATTACK_IV:
        return battleMon->attackIV;

    case BATTLEMON_DEFENSE_IV:
        return battleMon->defenseIV;

    case BATTLEMON_SPEED_IV:
        return battleMon->speedIV;

    case BATTLEMON_SP_ATTACK_IV:
        return battleMon->spAttackIV;

    case BATTLEMON_SP_DEFENSE_IV:
        return battleMon->spDefenseIV;

    case BATTLEMON_IS_EGG:
        return battleMon->isEgg;

    case BATTLEMON_HAS_NICKNAME:
        return battleMon->hasNickname;

    case BATTLEMON_HP_STAGE:
    case BATTLEMON_ATTACK_STAGE:
    case BATTLEMON_DEFENSE_STAGE:
    case BATTLEMON_SPEED_STAGE:
    case BATTLEMON_SP_ATTACK_STAGE:
    case BATTLEMON_SP_DEFENSE_STAGE:
    case BATTLEMON_ACCURACY_STAGE:
    case BATTLEMON_EVASION_STAGE:
        return battleMon->statBoosts[paramID - BATTLEMON_HP_STAGE];

    case BATTLEMON_ABILITY:
        return battleMon->ability;

    case BATTLEMON_TYPE_1:
    case BATTLEMON_TYPE_2:
        return Battler_MonType(battleCtx, battler, paramID);

    case BATTLEMON_GENDER:
        return battleMon->gender;

    case BATTLEMON_IS_SHINY:
        return battleMon->isShiny;

    case BATTLEMON_CUR_PP_1:
    case BATTLEMON_CUR_PP_2:
    case BATTLEMON_CUR_PP_3:
    case BATTLEMON_CUR_PP_4:
        return battleMon->ppCur[paramID - BATTLEMON_CUR_PP_1];

    case BATTLEMON_PP_UPS_1:
    case BATTLEMON_PP_UPS_2:
    case BATTLEMON_PP_UPS_3:
    case BATTLEMON_PP_UPS_4:
        return battleMon->ppUps[paramID - BATTLEMON_PP_UPS_1];

    case BATTLEMON_MAX_PP_1:
    case BATTLEMON_MAX_PP_2:
    case BATTLEMON_MAX_PP_3:
    case BATTLEMON_MAX_PP_4:
        return MoveTable_CalcMaxPP(battleMon->moves[paramID - BATTLEMON_MAX_PP_1], battleMon->ppUps[paramID - BATTLEMON_MAX_PP_1]);

    case BATTLEMON_LEVEL:
        return battleMon->level;

    case BATTLEMON_FRIENDSHIP:
        return battleMon->friendship;

    case BATTLEMON_NICKNAME: {
        int i;
        charcode_t *nickname = buf;

        for (i = 0; i < MON_NAME_LEN + 1; i++) {
            nickname[i] = battleMon->nickname[i];
        }
    } break;

    case BATTLEMON_NICKNAME_STRING:
        String_CopyChars((String *)buf, battleMon->nickname);
        break;

    case BATTLEMON_CUR_HP:
        return battleMon->curHP;

    case BATTLEMON_MAX_HP:
        return battleMon->maxHP;

    case BATTLEMON_OT_NAME: {
        int i;
        charcode_t *OTName = buf;

        for (i = 0; i < MON_NAME_LEN + 1; i++) {
            OTName[i] = battleMon->OTName[i];
        }
    } break;

    case BATTLEMON_EXP:
        return battleMon->exp;

    case BATTLEMON_PERSONALITY:
        return battleMon->personality;

    case BATTLEMON_STATUS:
        return battleMon->status;

    case BATTLEMON_VOLATILE_STATUS:
        return battleMon->statusVolatile;

    case BATTLEMON_OT_ID:
        return battleMon->OTId;

    case BATTLEMON_HELD_ITEM:
        return battleMon->heldItem;

    case BATTLEMON_TIMES_DAMAGED:
        return battleMon->timesDamaged;

    case BATTLEMON_TRAINER_MESSAGE_FLAGS:
        return battleMon->trainerMessageFlags;

    case BATTLEMON_OT_GENDER:
        return battleMon->OTGender;

    case BATTLEMON_MOVE_EFFECTS_MASK:
        return battleMon->moveEffectsMask;

    case BATTLEMON_MOVE_EFFECTS_TEMP:
        return battleMon->moveEffectsTemp;

    case BATTLEMON_DISABLED_TURNS:
        return battleMon->moveEffectsData.disabledTurns;

    case BATTLEMON_ENCORED_TURNS:
        return battleMon->moveEffectsData.encoredTurns;

    case BATTLEMON_CHARGED_TURNS:
        return battleMon->moveEffectsData.chargedTurns;

    case BATTLEMON_TAUNTED_TURNS:
        return battleMon->moveEffectsData.tauntedTurns;

    case BATTLEMON_SUCCESSFUL_PROTECT_TURNS:
        return battleMon->moveEffectsData.protectSuccessTurns;

    case BATTLEMON_PERISH_SONG_TURNS:
        return battleMon->moveEffectsData.perishSongTurns;

    case BATTLEMON_ROLLOUT_COUNT:
        return battleMon->moveEffectsData.rolloutCount;

    case BATTLEMON_FURY_CUTTER_COUNT:
        return battleMon->moveEffectsData.furyCutterCount;

    case BATTLEMON_STOCKPILE_COUNT:
        return battleMon->moveEffectsData.stockpileCount;

    case BATTLEMON_STOCKPILE_DEF_BOOSTS:
        return battleMon->moveEffectsData.stockpileDefBoosts;

    case BATTLEMON_STOCKPILE_SPDEF_BOOSTS:
        return battleMon->moveEffectsData.stockpileSpDefBoosts;

    case BATTLEMON_TRUANT:
        return battleMon->moveEffectsData.truant;

    case BATTLEMON_FLASH_FIRE:
        return battleMon->moveEffectsData.flashFire;

    case BATTLEMON_LOCK_ON_TARGET:
        return battleMon->moveEffectsData.lockOnTarget;

    case BATTLEMON_MIMICKED_MOVE_SLOT:
        return battleMon->moveEffectsData.mimickedMoveSlot;

    case BATTLEMON_BIND_TARGET:
        return battleMon->moveEffectsData.bindTarget;

    case BATTLEMON_MEAN_LOOK_TARGET:
        return battleMon->moveEffectsData.meanLookTarget;

    case BATTLEMON_LAST_RESORT_COUNT:
        return battleMon->moveEffectsData.lastResortCount;

    case BATTLEMON_MAGNET_RISE_TURNS:
        return battleMon->moveEffectsData.magnetRiseTurns;

    case BATTLEMON_HEAL_BLOCK_TURNS:
        return battleMon->moveEffectsData.healBlockTurns;

    case BATTLEMON_EMBARGO_TURNS:
        return battleMon->moveEffectsData.embargoTurns;

    case BATTLEMON_CAN_UNBURDEN:
        return battleMon->moveEffectsData.canUnburden;

    case BATTLEMON_METRONOME_TURNS:
        return battleMon->moveEffectsData.metronomeTurns;

    case BATTLEMON_MICLE_BERRY:
        return battleMon->moveEffectsData.micleBerry;

    case BATTLEMON_CUSTAP_BERRY:
        return battleMon->moveEffectsData.custapBerry;

    case BATTLEMON_QUICK_CLAW:
        return battleMon->moveEffectsData.quickClaw;

    case BATTLEMON_RECHARGE_TURN_NUMBER:
        return battleMon->moveEffectsData.rechargeTurnNumber;

    case BATTLEMON_FAKE_OUT_TURN_NUMBER:
        return battleMon->moveEffectsData.fakeOutTurnNumber;

    case BATTLEMON_SLOW_START_TURN_NUMBER:
        return battleMon->moveEffectsData.slowStartTurnNumber;

    case BATTLEMON_SUBSTITUTE_HP:
        return battleMon->moveEffectsData.substituteHP;

    case BATTLEMON_TRANSFORMED_PERSONALITY:
        return battleMon->moveEffectsData.transformedPID;

    case BATTLEMON_DISABLED_MOVE:
        return battleMon->moveEffectsData.disabledMove;

    case BATTLEMON_ENCORED_MOVE:
        return battleMon->moveEffectsData.encoredMove;

    case BATTLEMON_BINDING_MOVE:
        return battleMon->moveEffectsData.bindingMove;

    case BATTLEMON_ITEM_HP_RECOVERY:
        return battleMon->moveEffectsData.itemHPRecovery;

    case BATTLEMON_SLOW_START_ANNOUNCED:
        return battleMon->slowStartAnnounced;

    case BATTLEMON_SLOW_START_FINISHED:
        return battleMon->slowStartFinished;

    case BATTLEMON_FORM_NUM:
        return battleMon->formNum;

    case BATTLEMON_TEMP:
        return BattleMon_Get(battleCtx, battler, battleCtx->scriptTemp, buf);

    default:
        GF_ASSERT(FALSE);
        break;
    }

    return 0;
}

void BattleMon_Set(BattleContext *battleCtx, int battler, enum BattleMonParam paramID, const void *buf)
{
    BattleMon *mon = &battleCtx->battleMons[battler];

    switch (paramID) {
    case BATTLEMON_SPECIES:
        mon->species = *(u16 *)buf;
        break;

    case BATTLEMON_ATTACK:
        mon->attack = *(u16 *)buf;
        break;

    case BATTLEMON_DEFENSE:
        mon->defense = *(u16 *)buf;
        break;

    case BATTLEMON_SPEED:
        mon->speed = *(u16 *)buf;
        break;

    case BATTLEMON_SP_ATTACK:
        mon->spAttack = *(u16 *)buf;
        break;

    case BATTLEMON_SP_DEFENSE:
        mon->spDefense = *(u16 *)buf;
        break;

    case BATTLEMON_MOVE_1:
    case BATTLEMON_MOVE_2:
    case BATTLEMON_MOVE_3:
    case BATTLEMON_MOVE_4:
        mon->moves[paramID - BATTLEMON_MOVE_1] = *(u16 *)buf;
        break;

    case BATTLEMON_HP_IV:
        mon->hpIV = *(u8 *)buf;
        break;

    case BATTLEMON_ATTACK_IV:
        mon->attackIV = *(u8 *)buf;
        break;

    case BATTLEMON_DEFENSE_IV:
        mon->defenseIV = *(u8 *)buf;
        break;

    case BATTLEMON_SPEED_IV:
        mon->speedIV = *(u8 *)buf;
        break;

    case BATTLEMON_SP_ATTACK_IV:
        mon->spAttackIV = *(u8 *)buf;
        break;

    case BATTLEMON_SP_DEFENSE_IV:
        mon->spDefenseIV = *(u8 *)buf;
        break;

    case BATTLEMON_IS_EGG:
        mon->isEgg = *(u8 *)buf;
        break;

    case BATTLEMON_HAS_NICKNAME:
        mon->hasNickname = *(u8 *)buf;
        break;

    case BATTLEMON_HP_STAGE:
    case BATTLEMON_ATTACK_STAGE:
    case BATTLEMON_DEFENSE_STAGE:
    case BATTLEMON_SPEED_STAGE:
    case BATTLEMON_SP_ATTACK_STAGE:
    case BATTLEMON_SP_DEFENSE_STAGE:
    case BATTLEMON_ACCURACY_STAGE:
    case BATTLEMON_EVASION_STAGE:
        mon->statBoosts[paramID - BATTLEMON_HP_STAGE] = *(s8 *)buf;
        break;

    case BATTLEMON_ABILITY:
        mon->ability = *(u8 *)buf;
        break;

    case BATTLEMON_TYPE_1:
        mon->type1 = *(u8 *)buf;
        mon->sovereignAddedType = 0; // Sovereign (item 11): a new type replaces an added one
        break;

    case BATTLEMON_TYPE_2:
        mon->type2 = *(u8 *)buf;
        mon->sovereignAddedType = 0; // Sovereign (item 11): a new type replaces an added one
        break;

    case BATTLEMON_GENDER:
        mon->gender = *(u8 *)buf;
        break;

    case BATTLEMON_IS_SHINY:
        mon->isShiny = *(u8 *)buf;
        break;

    case BATTLEMON_CUR_PP_1:
    case BATTLEMON_CUR_PP_2:
    case BATTLEMON_CUR_PP_3:
    case BATTLEMON_CUR_PP_4:
        mon->ppCur[paramID - BATTLEMON_CUR_PP_1] = *(u8 *)buf;
        break;

    case BATTLEMON_PP_UPS_1:
    case BATTLEMON_PP_UPS_2:
    case BATTLEMON_PP_UPS_3:
    case BATTLEMON_PP_UPS_4:
        mon->ppUps[paramID - BATTLEMON_PP_UPS_1] = *(u8 *)buf;
        break;

    case BATTLEMON_MAX_PP_1:
    case BATTLEMON_MAX_PP_2:
    case BATTLEMON_MAX_PP_3:
    case BATTLEMON_MAX_PP_4:
        GF_ASSERT(FALSE);
        break;

    case BATTLEMON_LEVEL:
        mon->level = *(u8 *)buf;
        break;

    case BATTLEMON_FRIENDSHIP:
        mon->friendship = *(u8 *)buf;
        break;

    case BATTLEMON_NICKNAME:
        for (int i = 0; i < MON_NAME_LEN + 1; i++) {
            mon->nickname[i] = ((u16 *)buf)[i];
        }
        break;

    case BATTLEMON_CUR_HP:
        mon->curHP = *(s16 *)buf;
        break;

    case BATTLEMON_MAX_HP:
        mon->maxHP = *(u16 *)buf;
        break;

    case BATTLEMON_OT_NAME:
        for (int i = 0; i < MON_NAME_LEN + 1; i++) {
            mon->OTName[i] = ((u16 *)buf)[i];
        }
        break;

    case BATTLEMON_EXP:
        mon->exp = *(u32 *)buf;
        break;

    case BATTLEMON_PERSONALITY:
        mon->personality = *(u32 *)buf;
        break;

    case BATTLEMON_STATUS:
        mon->status = *(u32 *)buf;
        break;

    case BATTLEMON_VOLATILE_STATUS:
        mon->statusVolatile = *(u32 *)buf;
        break;

    case BATTLEMON_OT_ID:
        mon->OTId = *(u32 *)buf;
        break;

    case BATTLEMON_HELD_ITEM:
        mon->heldItem = *(u16 *)buf;
        break;

    case BATTLEMON_TIMES_DAMAGED:
        mon->timesDamaged = *(u8 *)buf;
        break;

    case BATTLEMON_TRAINER_MESSAGE_FLAGS:
        mon->trainerMessageFlags = *(u8 *)buf;
        break;

    case BATTLEMON_OT_GENDER:
        mon->OTGender = *(u8 *)buf;
        break;
    case BATTLEMON_MOVE_EFFECTS_MASK:
        mon->moveEffectsMask = *(u32 *)buf;
        break;

    case BATTLEMON_MOVE_EFFECTS_TEMP:
        mon->moveEffectsTemp = *(u32 *)buf;
        break;

    case BATTLEMON_DISABLED_TURNS:
        mon->moveEffectsData.disabledTurns = *(u8 *)buf;
        break;

    case BATTLEMON_ENCORED_TURNS:
        mon->moveEffectsData.encoredTurns = *(u8 *)buf;
        break;

    case BATTLEMON_CHARGED_TURNS:
        mon->moveEffectsData.chargedTurns = *(u8 *)buf;
        break;

    case BATTLEMON_TAUNTED_TURNS:
        mon->moveEffectsData.tauntedTurns = *(u8 *)buf;
        break;

    case BATTLEMON_SUCCESSFUL_PROTECT_TURNS:
        mon->moveEffectsData.protectSuccessTurns = *(u8 *)buf;
        break;

    case BATTLEMON_PERISH_SONG_TURNS:
        mon->moveEffectsData.perishSongTurns = *(u8 *)buf;
        break;

    case BATTLEMON_ROLLOUT_COUNT:
        mon->moveEffectsData.rolloutCount = *(u8 *)buf;
        break;

    case BATTLEMON_FURY_CUTTER_COUNT:
        mon->moveEffectsData.furyCutterCount = *(u8 *)buf;
        break;

    case BATTLEMON_STOCKPILE_COUNT:
        mon->moveEffectsData.stockpileCount = *(u8 *)buf;
        break;

    case BATTLEMON_STOCKPILE_DEF_BOOSTS:
        mon->moveEffectsData.stockpileDefBoosts = *(u8 *)buf;
        break;

    case BATTLEMON_STOCKPILE_SPDEF_BOOSTS:
        mon->moveEffectsData.stockpileSpDefBoosts = *(u8 *)buf;
        break;

    case BATTLEMON_TRUANT:
        mon->moveEffectsData.truant = *(u8 *)buf;
        break;

    case BATTLEMON_FLASH_FIRE:
        mon->moveEffectsData.flashFire = *(u8 *)buf;
        break;

    case BATTLEMON_LOCK_ON_TARGET:
        mon->moveEffectsData.lockOnTarget = *(u8 *)buf;
        break;

    case BATTLEMON_MIMICKED_MOVE_SLOT:
        mon->moveEffectsData.mimickedMoveSlot = *(u8 *)buf;
        break;

    case BATTLEMON_BIND_TARGET:
        mon->moveEffectsData.bindTarget = *(u8 *)buf;
        break;

    case BATTLEMON_MEAN_LOOK_TARGET:
        mon->moveEffectsData.meanLookTarget = *(u8 *)buf;
        break;

    case BATTLEMON_LAST_RESORT_COUNT:
        mon->moveEffectsData.lastResortCount = *(u8 *)buf;
        break;

    case BATTLEMON_MAGNET_RISE_TURNS:
        mon->moveEffectsData.magnetRiseTurns = *(u8 *)buf;
        break;

    case BATTLEMON_HEAL_BLOCK_TURNS:
        mon->moveEffectsData.healBlockTurns = *(u8 *)buf;
        break;

    case BATTLEMON_EMBARGO_TURNS:
        mon->moveEffectsData.embargoTurns = *(u8 *)buf;
        break;

    case BATTLEMON_CAN_UNBURDEN:
        mon->moveEffectsData.canUnburden = *(u8 *)buf;
        break;

    case BATTLEMON_METRONOME_TURNS:
        mon->moveEffectsData.metronomeTurns = *(u8 *)buf;
        break;

    case BATTLEMON_MICLE_BERRY:
        mon->moveEffectsData.micleBerry = *(u8 *)buf;
        break;

    case BATTLEMON_CUSTAP_BERRY:
        mon->moveEffectsData.custapBerry = *(u8 *)buf;
        break;

    case BATTLEMON_QUICK_CLAW:
        mon->moveEffectsData.quickClaw = *(u8 *)buf;
        break;

    case BATTLEMON_RECHARGE_TURN_NUMBER:
        mon->moveEffectsData.rechargeTurnNumber = *(u32 *)buf;
        break;

    case BATTLEMON_FAKE_OUT_TURN_NUMBER:
        mon->moveEffectsData.fakeOutTurnNumber = *(u32 *)buf;
        break;

    case BATTLEMON_SLOW_START_TURN_NUMBER:
        mon->moveEffectsData.slowStartTurnNumber = *(u32 *)buf;
        break;

    case BATTLEMON_SUBSTITUTE_HP:
        mon->moveEffectsData.substituteHP = *(u32 *)buf;
        break;

    case BATTLEMON_TRANSFORMED_PERSONALITY:
        mon->moveEffectsData.transformedPID = *(u32 *)buf;
        break;

    case BATTLEMON_DISABLED_MOVE:
        mon->moveEffectsData.disabledMove = *(u16 *)buf;
        break;

    case BATTLEMON_ENCORED_MOVE:
        mon->moveEffectsData.encoredMove = *(u16 *)buf;
        break;

    case BATTLEMON_BINDING_MOVE:
        mon->moveEffectsData.bindingMove = *(u16 *)buf;
        break;

    case BATTLEMON_ITEM_HP_RECOVERY:
        mon->moveEffectsData.itemHPRecovery = *(u32 *)buf;
        break;

    case BATTLEMON_SLOW_START_ANNOUNCED:
        mon->slowStartAnnounced = *(u8 *)buf;
        break;

    case BATTLEMON_SLOW_START_FINISHED:
        mon->slowStartFinished = *(u8 *)buf;
        break;

    case BATTLEMON_FORM_NUM:
        mon->formNum = *(u8 *)buf;
        break;

    case BATTLEMON_TEMP:
        BattleMon_Set(battleCtx, battler, battleCtx->scriptTemp, buf);
        break;

    default:
        GF_ASSERT(FALSE);
        break;
    }
}

void Battler_AddVal(BattleContext *battleCtx, int battler, enum BattleMonParam paramID, int val)
{
    BattleMon_AddVal(&battleCtx->battleMons[battler], paramID, val);
}

void BattleMon_AddVal(BattleMon *mon, enum BattleMonParam paramID, int val)
{
    switch (paramID) {
    case BATTLEMON_ATTACK:
        mon->attack += val;
        break;

    case BATTLEMON_DEFENSE:
        mon->defense += val;
        break;

    case BATTLEMON_SPEED:
        mon->speed += val;
        break;

    case BATTLEMON_SP_ATTACK:
        mon->spAttack += val;
        break;

    case BATTLEMON_SP_DEFENSE:
        mon->spDefense += val;
        break;

    case BATTLEMON_HP_IV:
        mon->hpIV += val;
        break;

    case BATTLEMON_ATTACK_IV:
        mon->attackIV += val;
        break;

    case BATTLEMON_DEFENSE_IV:
        mon->defenseIV += val;
        break;

    case BATTLEMON_SPEED_IV:
        mon->speedIV += val;
        break;

    case BATTLEMON_SP_ATTACK_IV:
        mon->spAttackIV += val;
        break;

    case BATTLEMON_SP_DEFENSE_IV:
        mon->spDefenseIV += val;
        break;

    case BATTLEMON_HP_STAGE:
    case BATTLEMON_ATTACK_STAGE:
    case BATTLEMON_DEFENSE_STAGE:
    case BATTLEMON_SPEED_STAGE:
    case BATTLEMON_SP_ATTACK_STAGE:
    case BATTLEMON_SP_DEFENSE_STAGE:
    case BATTLEMON_ACCURACY_STAGE:
    case BATTLEMON_EVASION_STAGE:
        if (mon->statBoosts[paramID - BATTLEMON_HP_STAGE] + val < 0) {
            mon->statBoosts[paramID - BATTLEMON_HP_STAGE] = 0;
        } else if (mon->statBoosts[paramID - BATTLEMON_HP_STAGE] + val > 12) {
            mon->statBoosts[paramID - BATTLEMON_HP_STAGE] = 12;
        } else {
            mon->statBoosts[paramID - BATTLEMON_HP_STAGE] += val;
        }
        break;

    case BATTLEMON_CUR_PP_1:
    case BATTLEMON_CUR_PP_2:
    case BATTLEMON_CUR_PP_3:
    case BATTLEMON_CUR_PP_4:
        int maxPP = MoveTable_CalcMaxPP(mon->moves[paramID - BATTLEMON_CUR_PP_1], mon->ppUps[paramID - BATTLEMON_CUR_PP_1]);
        if (mon->ppCur[paramID - BATTLEMON_CUR_PP_1] + val > maxPP) {
            mon->ppCur[paramID - BATTLEMON_CUR_PP_1] = maxPP;
        } else {
            mon->ppCur[paramID - BATTLEMON_CUR_PP_1] += val;
        }
        break;

    case BATTLEMON_PP_UPS_1:
    case BATTLEMON_PP_UPS_2:
    case BATTLEMON_PP_UPS_3:
    case BATTLEMON_PP_UPS_4:
        mon->ppUps[paramID - BATTLEMON_PP_UPS_1] += val;
        break;

    case BATTLEMON_LEVEL:
        mon->level += val;
        break;

    case BATTLEMON_FRIENDSHIP:
        int friendship = mon->friendship;

        if (friendship + val > 255) {
            friendship = 255;
        } else if (friendship + val < 0) {
            friendship = 0;
        } else {
            friendship += val;
        }

        mon->friendship = friendship;
        break;

    case BATTLEMON_CUR_HP:
        if (mon->curHP + val > mon->maxHP) {
            mon->curHP = mon->maxHP;
        } else {
            mon->curHP += val;
        }
        break;

    case BATTLEMON_MAX_HP:
        mon->maxHP += val;
        break;

    case BATTLEMON_EXP:
        mon->exp += val;
        break;

    case BATTLEMON_PERSONALITY:
        mon->personality += val;
        break;

    case BATTLEMON_DISABLED_TURNS:
        mon->moveEffectsData.disabledTurns += val;
        break;

    case BATTLEMON_ENCORED_TURNS:
        mon->moveEffectsData.encoredTurns += val;
        break;

    case BATTLEMON_CHARGED_TURNS:
        mon->moveEffectsData.chargedTurns += val;
        break;

    case BATTLEMON_TAUNTED_TURNS:
        mon->moveEffectsData.tauntedTurns += val;
        break;

    case BATTLEMON_SUCCESSFUL_PROTECT_TURNS:
        mon->moveEffectsData.protectSuccessTurns += val;
        break;

    case BATTLEMON_PERISH_SONG_TURNS:
        mon->moveEffectsData.perishSongTurns += val;
        break;

    case BATTLEMON_ROLLOUT_COUNT:
        mon->moveEffectsData.rolloutCount += val;
        break;

    case BATTLEMON_FURY_CUTTER_COUNT:
        mon->moveEffectsData.furyCutterCount += val;
        break;

    case BATTLEMON_STOCKPILE_COUNT:
        mon->moveEffectsData.stockpileCount += val;
        break;

    case BATTLEMON_STOCKPILE_DEF_BOOSTS:
        mon->moveEffectsData.stockpileDefBoosts += val;
        break;

    case BATTLEMON_STOCKPILE_SPDEF_BOOSTS:
        mon->moveEffectsData.stockpileSpDefBoosts += val;
        break;

    case BATTLEMON_LAST_RESORT_COUNT:
        mon->moveEffectsData.lastResortCount += val;
        break;

    case BATTLEMON_MAGNET_RISE_TURNS:
        mon->moveEffectsData.magnetRiseTurns += val;
        break;

    case BATTLEMON_HEAL_BLOCK_TURNS:
        mon->moveEffectsData.healBlockTurns += val;
        break;

    case BATTLEMON_RECHARGE_TURN_NUMBER:
        mon->moveEffectsData.rechargeTurnNumber += val;
        break;

    case BATTLEMON_FAKE_OUT_TURN_NUMBER:
        mon->moveEffectsData.fakeOutTurnNumber += val;
        break;

    case BATTLEMON_SLOW_START_TURN_NUMBER:
        mon->moveEffectsData.slowStartTurnNumber += val;
        break;

    case BATTLEMON_SUBSTITUTE_HP:
        mon->moveEffectsData.substituteHP += val;
        break;

    case BATTLEMON_ITEM_HP_RECOVERY:
        mon->moveEffectsData.itemHPRecovery += val;
        break;

    case BATTLEMON_SLOW_START_ANNOUNCED:
        mon->slowStartAnnounced += val;
        break;

    case BATTLEMON_SLOW_START_FINISHED:
        mon->slowStartFinished += val;
        break;

    case BATTLEMON_FORM_NUM:
        mon->formNum += val;
        break;

    default:
        GF_ASSERT(FALSE);
        break;
    }
}

static const u8 sSpeedHalvingItemEffects[] = {
    HOLD_EFFECT_EVS_UP_SPEED_DOWN,
    HOLD_EFFECT_SPEED_DOWN_GROUNDED,
    HOLD_EFFECT_LVLUP_HP_EV_UP,
    HOLD_EFFECT_LVLUP_ATK_EV_UP,
    HOLD_EFFECT_LVLUP_DEF_EV_UP,
    HOLD_EFFECT_LVLUP_SPEED_EV_UP,
    HOLD_EFFECT_LVLUP_SPATK_EV_UP,
    HOLD_EFFECT_LVLUP_SPDEF_EV_UP
};

u8 BattleSystem_CompareBattlerSpeed(BattleSystem *battleSys, BattleContext *battleCtx, int battler1, int battler2, BOOL ignoreQuickClaw)
{
    u8 result = COMPARE_SPEED_FASTER;
    u32 battler1Speed, battler2Speed;
    u16 battler1Move = 0, battler2Move = 0;
    u8 battler1ItemEffect, battler1ItemParam;
    u8 battler2ItemEffect, battler2ItemParam;
    s8 battler1Priority = 0, battler2Priority = 0;
    u8 battler1QuickClaw = 0, battler2QuickClaw = 0;
    u8 battler1LaggingTail = 0, battler2LaggingTail = 0;
    int battler1Action, battler2Action;
    int battler1MoveSlot, battler2MoveSlot;
    int battler1Ability, battler2Ability;
    int battler1SpeedStage, battler2SpeedStage;
    int i;

    // If either battler is dead, short-circuit to preferring the other
    if (battleCtx->battleMons[battler1].curHP == 0 && battleCtx->battleMons[battler2].curHP) {
        return 1;
    }

    if (battleCtx->battleMons[battler1].curHP && battleCtx->battleMons[battler2].curHP == 0) {
        return 0;
    }

    battler1Ability = Battler_Ability(battleCtx, battler1);
    battler2Ability = Battler_Ability(battleCtx, battler2);
    battler1ItemEffect = Battler_HeldItemEffect(battleCtx, battler1);
    battler1ItemParam = Battler_HeldItemPower(battleCtx, battler1, ITEM_POWER_CHECK_ALL);
    battler2ItemEffect = Battler_HeldItemEffect(battleCtx, battler2);
    battler2ItemParam = Battler_HeldItemPower(battleCtx, battler2, ITEM_POWER_CHECK_ALL);
    battler1SpeedStage = battleCtx->battleMons[battler1].statBoosts[BATTLE_STAT_SPEED];
    battler2SpeedStage = battleCtx->battleMons[battler2].statBoosts[BATTLE_STAT_SPEED];

    // Sovereign: Simple doubles a stat change as it happens (Gen V+, BtlCmd_ChangeStatStage), not the stage here.

    battler1Speed = battleCtx->battleMons[battler1].speed * sStatStageBoosts[battler1SpeedStage].numerator / sStatStageBoosts[battler1SpeedStage].denominator;
    battler2Speed = battleCtx->battleMons[battler2].speed * sStatStageBoosts[battler2SpeedStage].numerator / sStatStageBoosts[battler2SpeedStage].denominator;

    if (NO_CLOUD_NINE) {
        // Sovereign (item 11): Sand Rush and Slush Rush double Speed in sandstorm and snow.
        if ((battler1Ability == ABILITY_SWIFT_SWIM && (Sovereign_BattlerWeather(battleCtx, battler1) & FIELD_CONDITION_RAINING))
            || (battler1Ability == ABILITY_CHLOROPHYLL && (Sovereign_BattlerWeather(battleCtx, battler1) & FIELD_CONDITION_SUNNY))
            || (battler1Ability == ABILITY_SAND_RUSH && WEATHER_IS_SAND)
            || (battler1Ability == ABILITY_SLUSH_RUSH && WEATHER_IS_HAIL)) {
            battler1Speed *= 2;
        }

        if ((battler2Ability == ABILITY_SWIFT_SWIM && (Sovereign_BattlerWeather(battleCtx, battler2) & FIELD_CONDITION_RAINING))
            || (battler2Ability == ABILITY_CHLOROPHYLL && (Sovereign_BattlerWeather(battleCtx, battler2) & FIELD_CONDITION_SUNNY))
            || (battler2Ability == ABILITY_SAND_RUSH && WEATHER_IS_SAND)
            || (battler2Ability == ABILITY_SLUSH_RUSH && WEATHER_IS_HAIL)) {
            battler2Speed *= 2;
        }
    }

    // Sovereign (item 11): Surge Surfer doubles Speed in Electric Terrain.
    if (battler1Ability == ABILITY_SURGE_SURFER && (battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN_ELECTRIC)) {
        battler1Speed *= 2;
    }
    if (battler2Ability == ABILITY_SURGE_SURFER && (battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN_ELECTRIC)) {
        battler2Speed *= 2;
    }

    // Sovereign (item 11): Protosynthesis raises Speed by 50% when Speed is the boosted stat.
    if (Sovereign_ProtosynthesisStat(battleSys, battleCtx, battler1) == BATTLE_STAT_SPEED) {
        battler1Speed = battler1Speed * 15 / 10;
    }
    if (Sovereign_ProtosynthesisStat(battleSys, battleCtx, battler2) == BATTLE_STAT_SPEED) {
        battler2Speed = battler2Speed * 15 / 10;
    }

    for (i = 0; i < NELEMS(sSpeedHalvingItemEffects); i++) {
        // The speed-halving effect of these items are not ignored by any negation effect
        if (BattleSystem_GetItemData(battleCtx, battleCtx->battleMons[battler1].heldItem, ITEM_PARAM_HOLD_EFFECT) == sSpeedHalvingItemEffects[i]) {
            battler1Speed /= 2;
            break;
        }
    }

    if (battler1ItemEffect == HOLD_EFFECT_CHOICE_SPEED) {
        battler1Speed = battler1Speed * 15 / 10;
    }

    if (battler1ItemEffect == HOLD_EFFECT_DITTO_SPEED_UP
        && battleCtx->battleMons[battler1].species == SPECIES_DITTO) {
        battler1Speed *= 2;
    }

    if (battler1Ability == ABILITY_QUICK_FEET && (battleCtx->battleMons[battler1].status & MON_CONDITION_ANY)) {
        battler1Speed = battler1Speed * 15 / 10;
    } else if (battleCtx->battleMons[battler1].status & MON_CONDITION_PARALYSIS) {
        battler1Speed /= 2; // Sovereign: Gen VII+ / Champions (Gen IV: 1/4)
    }

    if (battler1Ability == ABILITY_SLOW_START
        && battleCtx->totalTurns - battleCtx->battleMons[battler1].moveEffectsData.slowStartTurnNumber < 5) {
        battler1Speed /= 2;
    }

    if (battler1Ability == ABILITY_UNBURDEN
        && battleCtx->battleMons[battler1].moveEffectsData.canUnburden
        && battleCtx->battleMons[battler1].heldItem == ITEM_NONE) {
        battler1Speed *= 2;
    }

    if (battleCtx->sideConditionsMask[BattleSystem_GetBattlerSide(battleSys, battler1)] & SIDE_CONDITION_TAILWIND) {
        battler1Speed *= 2;
    }

    if (battler1ItemEffect == HOLD_EFFECT_SOMETIMES_PRIORITY) {
        if (battleCtx->speedRand[battler1] % (100 / battler1ItemParam) == 0) {
            battler1QuickClaw = 1;

            if (ignoreQuickClaw == FALSE) {
                battleCtx->battleMons[battler1].moveEffectsData.quickClaw = 1;
            }
        }
    }

    if (battler1ItemEffect == HOLD_EFFECT_PINCH_PRIORITY) {
        if (Battler_Ability(battleCtx, battler1) == ABILITY_GLUTTONY) {
            battler1ItemParam /= 2;
        }

        if (battleCtx->battleMons[battler1].curHP <= (battleCtx->battleMons[battler1].maxHP / battler1ItemParam)) {
            battler1QuickClaw = 1;

            if (ignoreQuickClaw == FALSE) {
                battleCtx->battleMons[battler1].moveEffectsData.custapBerry = 1;
            }
        }
    }

    if (battler1ItemEffect == HOLD_EFFECT_PRIORITY_DOWN) {
        battler1LaggingTail = 1;
    }

    for (i = 0; i < NELEMS(sSpeedHalvingItemEffects); i++) {
        // The speed-halving effect of these items are not ignored by any negation effect
        if (BattleSystem_GetItemData(battleCtx, battleCtx->battleMons[battler2].heldItem, ITEM_PARAM_HOLD_EFFECT) == sSpeedHalvingItemEffects[i]) {
            battler2Speed /= 2;
            break;
        }
    }

    if (battler2ItemEffect == HOLD_EFFECT_CHOICE_SPEED) {
        battler2Speed = battler2Speed * 15 / 10;
    }

    if (battler2ItemEffect == HOLD_EFFECT_DITTO_SPEED_UP
        && battleCtx->battleMons[battler2].species == SPECIES_DITTO) {
        battler2Speed *= 2;
    }

    if (battler2Ability == ABILITY_QUICK_FEET && (battleCtx->battleMons[battler2].status & MON_CONDITION_ANY)) {
        battler2Speed = battler2Speed * 15 / 10;
    } else if (battleCtx->battleMons[battler2].status & MON_CONDITION_PARALYSIS) {
        battler2Speed /= 2; // Sovereign: Gen VII+ / Champions (Gen IV: 1/4)
    }

    if (battler2Ability == ABILITY_SLOW_START
        && battleCtx->totalTurns - battleCtx->battleMons[battler2].moveEffectsData.slowStartTurnNumber < 5) {
        battler2Speed /= 2;
    }

    if (battler2Ability == ABILITY_UNBURDEN
        && battleCtx->battleMons[battler2].moveEffectsData.canUnburden
        && battleCtx->battleMons[battler2].heldItem == ITEM_NONE) {
        battler2Speed *= 2;
    }

    if (battleCtx->sideConditionsMask[BattleSystem_GetBattlerSide(battleSys, battler2)] & SIDE_CONDITION_TAILWIND) {
        battler2Speed *= 2;
    }

    if (battler2ItemEffect == HOLD_EFFECT_SOMETIMES_PRIORITY) {
        if (battleCtx->speedRand[battler2] % (100 / battler2ItemParam) == 0) {
            battler2QuickClaw = 1;

            if (ignoreQuickClaw == FALSE) {
                battleCtx->battleMons[battler2].moveEffectsData.quickClaw = 1;
            }
        }
    }

    if (battler2ItemEffect == HOLD_EFFECT_PINCH_PRIORITY) {
        if (Battler_Ability(battleCtx, battler2) == ABILITY_GLUTTONY) {
            battler2ItemParam /= 2;
        }

        if (battleCtx->battleMons[battler2].curHP <= (battleCtx->battleMons[battler2].maxHP / battler2ItemParam)) {
            battler2QuickClaw = 1;

            if (ignoreQuickClaw == FALSE) {
                battleCtx->battleMons[battler2].moveEffectsData.custapBerry = 1;
            }
        }
    }

    if (battler2ItemEffect == HOLD_EFFECT_PRIORITY_DOWN) {
        battler2LaggingTail = 1;
    }

    battleCtx->monSpeedValues[battler1] = battler1Speed;
    battleCtx->monSpeedValues[battler2] = battler2Speed;

    if (ignoreQuickClaw == FALSE) {
        battler1Action = battleCtx->battlerActions[battler1][BATTLE_ACTION_SELECTED_COMMAND];
        battler2Action = battleCtx->battlerActions[battler2][BATTLE_ACTION_SELECTED_COMMAND];
        battler1MoveSlot = battleCtx->moveSlot[battler1];
        battler2MoveSlot = battleCtx->moveSlot[battler2];

        if (battler1Action == PLAYER_INPUT_FIGHT) {
            if (battleCtx->turnFlags[battler1].struggling) {
                battler1Move = MOVE_STRUGGLE;
            } else {
                battler1Move = BattleMon_Get(battleCtx, battler1, BATTLEMON_MOVE_1 + battler1MoveSlot, NULL);
            }
        }

        if (battler2Action == PLAYER_INPUT_FIGHT) {
            if (battleCtx->turnFlags[battler2].struggling) {
                battler2Move = MOVE_STRUGGLE;
            } else {
                battler2Move = BattleMon_Get(battleCtx, battler2, BATTLEMON_MOVE_1 + battler2MoveSlot, NULL);
            }
        }

        // Sovereign (item 11): priority with Prankster, Gale Wings and Triage.
        battler1Priority = Sovereign_MovePriority(battleCtx, battler1, battler1Move);
        battler2Priority = Sovereign_MovePriority(battleCtx, battler2, battler2Move);

        // Sovereign (item 11): Quick Draw lets a Pokemon using a damaging move go first in its priority bracket, 30% of
        // the time (one roll a turn, as Quick Claw's).
        if (battler1Ability == ABILITY_QUICK_DRAW && battler1Move && MOVE_DATA(battler1Move).class != CLASS_STATUS
            && battleCtx->speedRand[battler1] % 10 < 3) {
            battler1QuickClaw = 1;
            battleCtx->sovereignQuickDraw |= FlagIndex(battler1);
        }

        if (battler2Ability == ABILITY_QUICK_DRAW && battler2Move && MOVE_DATA(battler2Move).class != CLASS_STATUS
            && battleCtx->speedRand[battler2] % 10 < 3) {
            battler2QuickClaw = 1;
            battleCtx->sovereignQuickDraw |= FlagIndex(battler2);
        }
    }

    // Sovereign (item 11): Mycelium Might moves last in its priority bracket when it uses a status move, as Stall does.
    BOOL battler1Stall = battler1Ability == ABILITY_STALL
        || (battler1Ability == ABILITY_MYCELIUM_MIGHT && battler1Move && MOVE_DATA(battler1Move).class == CLASS_STATUS);
    BOOL battler2Stall = battler2Ability == ABILITY_STALL
        || (battler2Ability == ABILITY_MYCELIUM_MIGHT && battler2Move && MOVE_DATA(battler2Move).class == CLASS_STATUS);

    if (battler1Priority == battler2Priority) {
        if (battler1QuickClaw && battler2QuickClaw) {
            if (battler1Speed < battler2Speed) {
                result = COMPARE_SPEED_SLOWER;
            } else if (battler1Speed == battler2Speed && (BattleSystem_RandNext(battleSys) & 1)) {
                result = COMPARE_SPEED_TIE;
            }
        } else if (battler1QuickClaw == FALSE && battler2QuickClaw) {
            result = COMPARE_SPEED_SLOWER;
        } else if (battler1QuickClaw && battler2QuickClaw == FALSE) {
            result = COMPARE_SPEED_FASTER;
        } else if (battler1LaggingTail && battler2LaggingTail) {
            if (battler1Speed > battler2Speed) {
                result = COMPARE_SPEED_SLOWER;
            } else if (battler1Speed == battler2Speed && (BattleSystem_RandNext(battleSys) & 1)) {
                result = COMPARE_SPEED_TIE;
            }
        } else if (battler1LaggingTail && battler2LaggingTail == FALSE) {
            result = COMPARE_SPEED_SLOWER;
        } else if (battler1LaggingTail == FALSE && battler2LaggingTail) {
            result = COMPARE_SPEED_FASTER;
        } else if (battler1Stall && battler2Stall) {
            if (battler1Speed > battler2Speed) {
                result = COMPARE_SPEED_SLOWER;
            } else if (battler1Speed == battler2Speed && (BattleSystem_RandNext(battleSys) & 1)) {
                result = COMPARE_SPEED_TIE;
            }
        } else if (battler1Stall && battler2Stall == FALSE) {
            result = COMPARE_SPEED_SLOWER;
        } else if (battler1Stall == FALSE && battler2Stall) {
            result = COMPARE_SPEED_FASTER;
        } else if (battleCtx->fieldConditionsMask & FIELD_CONDITION_TRICK_ROOM) {
            if (battler1Speed > battler2Speed) {
                result = COMPARE_SPEED_SLOWER;
            }

            if (battler1Speed == battler2Speed && (BattleSystem_RandNext(battleSys) & 1)) {
                result = COMPARE_SPEED_TIE;
            }
        } else {
            if (battler1Speed < battler2Speed) {
                result = COMPARE_SPEED_SLOWER;
            }

            if (battler1Speed == battler2Speed && (BattleSystem_RandNext(battleSys) & 1)) {
                result = COMPARE_SPEED_TIE;
            }
        }
    } else if (battler1Priority < battler2Priority) {
        result = COMPARE_SPEED_SLOWER;
    }

    return result;
}

void BattleSystem_ClearSideExpGain(BattleContext *battleCtx, int battler)
{
    battleCtx->sideGetExpMask[(battler >> 1) & 1] = 0;
}

void BattleSystem_FlagBattlerExpGain(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    int side = 0;
    u32 battleType = BattleSystem_GetBattleType(battleSys);

    while (side <= 2) {
        if ((battleCtx->battlersSwitchingMask & FlagIndex(side)) == FALSE
            && (battleCtx->battlersSwitchingMask & FlagIndex(battler)) == FALSE
            && battleCtx->battleMons[battler].curHP) {
            battleCtx->sideGetExpMask[(battler >> 1) & 1] |= FlagIndex(battleCtx->selectedPartySlot[side]);
        }

        side += 2;

        if (battleType == BATTLE_TYPE_AI_PARTNER || battleType == BATTLE_TYPE_TRAINER_WITH_AI_PARTNER) {
            break;
        }
    }
}

BOOL BattleSystem_TriggerPrimaryEffect(BattleSystem *battleSys, BattleContext *battleCtx, int *effect)
{
    BOOL result = FALSE;

    if (battleCtx->sideEffectDirectFlags & MOVE_SIDE_EFFECT_ON_HIT) {
        *effect = MapSideEffectToSubscript(battleCtx, 1, battleCtx->sideEffectDirectFlags);
        battleCtx->sideEffectDirectFlags = 0;

        if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE) {
            result = TRUE;
        }
    } else if (battleCtx->sideEffectDirectFlags) {
        *effect = MapSideEffectToSubscript(battleCtx, 1, battleCtx->sideEffectDirectFlags);

        if (battleCtx->battleMons[battleCtx->sideEffectMon].curHP
            && ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
                // Brick Break's effect still applies even if the target is immune.
                || ((battleCtx->sideEffectDirectFlags & MOVE_SIDE_EFFECT_BREAK_SCREENS)
                    && (battleCtx->moveStatusFlags & MOVE_STATUS_DID_NOT_AFFECT))
                // Various other moves can still apply their effect even if the target
                // is semi-invulnerable.
                || ((battleCtx->sideEffectDirectFlags & MOVE_SIDE_EFFECT_CHECK_HP)
                    && (battleCtx->moveStatusFlags & MOVE_STATUS_GENERAL_MISS)))) {
            result = TRUE;
        }

        battleCtx->sideEffectDirectFlags = 0;
    }

    return result;
}

static inline void SetupSideEffect(BattleContext *battleCtx, int *effect, int source)
{
    *effect = MapSideEffectToSubscript(battleCtx, source, battleCtx->sideEffectIndirectFlags);
    battleCtx->sideEffectIndirectFlags = 0;
}

// Sovereign (item 11): TRUE when Covert Cloak keeps a move's chance effect off its holder (another Pokemon's move).
static BOOL Sovereign_CovertCloakBlocks(BattleContext *battleCtx)
{
    return battleCtx->sideEffectMon != battleCtx->attacker
        && Battler_HeldItem(battleCtx, battleCtx->sideEffectMon) == ITEM_COVERT_CLOAK;
}

BOOL BattleSystem_TriggerSecondaryEffect(BattleSystem *battleSys, BattleContext *battleCtx, int *effect)
{
    BOOL result = FALSE;
    u16 effectChance;

    // Sovereign (item 11): Burning Jealousy burns, and Alluring Voice confuses, only a target whose stats rose this turn.
    if ((battleCtx->moveCur == MOVE_BURNING_JEALOUSY || battleCtx->moveCur == MOVE_ALLURING_VOICE)
        && battleCtx->turnFlags[battleCtx->defender].sovereignStatsRaised == FALSE) {
        battleCtx->sideEffectIndirectFlags = 0;
        return FALSE;
    }

    // Sovereign (item 11): Sheer Force removes the chance effects (the last two cases below) of the moves it powers up.
    if (battleCtx->sideEffectIndirectFlags
        && (battleCtx->sideEffectIndirectFlags & (MOVE_SIDE_EFFECT_ON_HIT | MOVE_SIDE_EFFECT_CHECK_SUBSTITUTE | MOVE_SIDE_EFFECT_CHECK_HP_AND_SUBSTITUTE | MOVE_SIDE_EFFECT_CHECK_HP)) == FALSE
        && Move_SheerForceApplies(battleCtx, battleCtx->attacker, battleCtx->moveCur)) {
        battleCtx->sideEffectIndirectFlags = 0;
        return FALSE;
    }

    if (battleCtx->sideEffectIndirectFlags & MOVE_SIDE_EFFECT_ON_HIT) {
        SetupSideEffect(battleCtx, effect, SIDE_EFFECT_TYPE_INDIRECT);

        if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE) {
            result = TRUE;
        }
    } else if (battleCtx->sideEffectIndirectFlags & MOVE_SIDE_EFFECT_CHECK_SUBSTITUTE) {
        SetupSideEffect(battleCtx, effect, SIDE_EFFECT_TYPE_INDIRECT);

        if (Battler_SubstituteWasHit(battleCtx, battleCtx->sideEffectMon) == FALSE
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE) {
            result = TRUE;
        }
    } else if (battleCtx->sideEffectIndirectFlags & MOVE_SIDE_EFFECT_CHECK_HP_AND_SUBSTITUTE) {
        SetupSideEffect(battleCtx, effect, SIDE_EFFECT_TYPE_INDIRECT);

        if (battleCtx->battleMons[battleCtx->sideEffectMon].curHP
            && Battler_SubstituteWasHit(battleCtx, battleCtx->sideEffectMon) == FALSE
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE) {
            result = TRUE;
        }
    } else if (battleCtx->sideEffectIndirectFlags & MOVE_SIDE_EFFECT_CHECK_HP) {
        SetupSideEffect(battleCtx, effect, SIDE_EFFECT_TYPE_INDIRECT);

        if (battleCtx->battleMons[battleCtx->sideEffectMon].curHP) {
            result = TRUE;
        }
    } else if (battleCtx->sideEffectIndirectFlags & MOVE_SIDE_EFFECT_PROBABILISTIC) {
        if (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_SERENE_GRACE) {
            effectChance = CURRENT_MOVE_DATA.effectChance * 2;
        } else {
            effectChance = CURRENT_MOVE_DATA.effectChance;
        }

        GF_ASSERT(effectChance != 0);

        if (BattleSystem_RandNext(battleSys) % 100 < effectChance) {
            battleCtx->battleStatusMask |= SYSCTL_APPLY_SECONDARY_EFFECT;
        }

        SetupSideEffect(battleCtx, effect, SIDE_EFFECT_TYPE_INDIRECT);
        if (battleCtx->battleMons[battleCtx->sideEffectMon].curHP == 0
            || Sovereign_CovertCloakBlocks(battleCtx)) { // Sovereign (item 11)
            battleCtx->battleStatusMask &= ~SYSCTL_APPLY_SECONDARY_EFFECT;
        }

        result = TRUE;
    } else if (battleCtx->sideEffectIndirectFlags) {
        if (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_SERENE_GRACE) {
            effectChance = CURRENT_MOVE_DATA.effectChance * 2;
        } else {
            effectChance = CURRENT_MOVE_DATA.effectChance;
        }

        GF_ASSERT(effectChance != 0);

        if (BattleSystem_RandNext(battleSys) % 100 < effectChance) {
            SetupSideEffect(battleCtx, effect, SIDE_EFFECT_TYPE_INDIRECT);

            if (battleCtx->battleMons[battleCtx->sideEffectMon].curHP
                && Battler_SubstituteWasHit(battleCtx, battleCtx->sideEffectMon) == FALSE
                && Sovereign_CovertCloakBlocks(battleCtx) == FALSE // Sovereign (item 11)
                && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE) {
                result = TRUE;
            }
        }
    } else if (battleCtx->sideEffectAbilityFlags) {
        *effect = MapSideEffectToSubscript(battleCtx, SIDE_EFFECT_TYPE_ABILITY, battleCtx->sideEffectAbilityFlags);
        battleCtx->sideEffectAbilityFlags = 0;

        if (battleCtx->battleMons[battleCtx->sideEffectMon].curHP) {
            result = TRUE;
        }
    }

    return result;
}

int BattleSystem_Defender(BattleSystem *battleSys, BattleContext *battleCtx, int attacker, u16 move, BOOL randomize, int inRange)
{
    int defender = BATTLER_NONE;

    int range;
    if (move) {
        range = Sovereign_MoveRange(battleCtx, attacker, move); // Sovereign (item 11)
    } else {
        range = inRange;
    }

    if (range == RANGE_ADJACENT_OPPONENTS) { // e.g., Acid, Blizzard
        int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
        BattlerData *battlerData = BattleSystem_GetBattlerData(battleSys, attacker);
        u8 attackerType = BattlerData_GetBattlerType(battlerData);

        // Assign the first possible living target based on speed order
        for (battleCtx->battlerCounter = 0; battleCtx->battlerCounter < maxBattlers; battleCtx->battlerCounter++) {
            int battler = battleCtx->monSpeedOrder[battleCtx->battlerCounter];

            // Check that this battler is an enemy of the attacker
            if (battleCtx->battleMons[battler].curHP != 0) {
                battlerData = BattleSystem_GetBattlerData(battleSys, battler);
                if (((attackerType & BATTLER_TYPE_SOLO_ENEMY) && (BattlerData_GetBattlerType(battlerData) & BATTLER_TYPE_SOLO_ENEMY) == FALSE)
                    || ((attackerType & BATTLER_TYPE_SOLO_ENEMY) == FALSE) && (BattlerData_GetBattlerType(battlerData) & BATTLER_TYPE_SOLO_ENEMY)) {
                    defender = battler;
                    break;
                }
            }
        }

        if (battleCtx->battlerCounter != maxBattlers) {
            battleCtx->battlerCounter++;
        }
    } else if (range == RANGE_ALL_ADJACENT) { // e.g., Earthquake, Surf
        int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

        // Assign the first possible living target based on speed order
        for (battleCtx->battlerCounter = 0; battleCtx->battlerCounter < maxBattlers; battleCtx->battlerCounter++) {
            int battler = battleCtx->monSpeedOrder[battleCtx->battlerCounter];

            // Only care that this battler is not the attacker
            if (battleCtx->battleMons[battler].curHP != 0 && battler != attacker) {
                defender = battler;
                break;
            }
        }

        if (battleCtx->battlerCounter != maxBattlers) {
            battleCtx->battlerCounter++;
        }
    } else if (range == RANGE_USER_OR_ALLY && randomize == TRUE) { // e.g., Acupressure
        if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES)
            && BattleSystem_RandNext(battleSys) % 2 == 0) {
            defender = BattleSystem_GetPartner(battleSys, attacker);
            if (battleCtx->battleMons[defender].curHP == 0) {
                defender = attacker;
            }
        } else {
            defender = attacker;
        }
    } else if (range == RANGE_SINGLE_TARGET_ME_FIRST && randomize == TRUE) { // e.g., Me First
        defender = BattleSystem_RandomOpponent(battleSys, battleCtx, attacker);
    } else if (range == RANGE_OPPONENT_SIDE) { // e.g., Spikes, Stealth Rock
        defender = BattleSystem_RandomOpponent(battleSys, battleCtx, attacker);
    } else if (range == RANGE_USER // e.g., Swords Dance
        || range == RANGE_USER_SIDE // e.g., Light Screen, Reflect
        || range == RANGE_SINGLE_TARGET_SPECIAL // e.g., Counter, Mirror Coat
        || range == RANGE_FIELD) { // e.g., Sunny Day
        defender = attacker;
    } else if (range == RANGE_ALLY) { // e.g., Helping Hand
        if (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES) {
            defender = BattleSystem_GetPartner(battleSys, attacker);
        } else {
            defender = attacker;
        }
    } else if (range == RANGE_USER_OR_ALLY) { // e.g., Acupressure
        if (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES) {
            defender = battleCtx->battlerActions[attacker][BATTLE_ACTION_CHOOSE_TARGET];
            if (battleCtx->battleMons[defender].curHP == 0) {
                defender = attacker;
            }
        } else {
            defender = attacker;
        }
    } else if (range == RANGE_RANDOM_OPPONENT || randomize == TRUE) { // e.g., Outrage, Thrash, any other reason the move should be randomly targeted
        int opponents[2];
        int battleType = BattleSystem_GetBattleType(battleSys);
        int enemySide = BattleSystem_GetBattlerSide(battleSys, attacker) ^ 1;

        opponents[0] = BattleSystem_GetEnemyInSlot(battleSys, attacker, ENEMY_IN_SLOT_RIGHT);
        opponents[1] = BattleSystem_GetEnemyInSlot(battleSys, attacker, ENEMY_IN_SLOT_LEFT);

        if (battleType & BATTLE_TYPE_DOUBLES) {
            if (battleCtx->sideConditions[enemySide].followMe
                && battleCtx->battleMons[battleCtx->sideConditions[enemySide].followMeUser].curHP) {
                // If Follow Me is active and the user is still alive, re-point all targets toward them
                defender = battleCtx->sideConditions[enemySide].followMeUser;
            } else if (battleCtx->battleMons[opponents[0]].curHP
                && battleCtx->battleMons[opponents[1]].curHP) {
                defender = opponents[BattleSystem_RandNext(battleSys) & 1];
            } else if (battleCtx->battleMons[opponents[0]].curHP) {
                defender = opponents[0];
            } else if (battleCtx->battleMons[opponents[1]].curHP) {
                defender = opponents[1];
            }
        } else if (battleCtx->battleMons[attacker ^ 1].curHP) {
            defender = attacker ^ 1;
        }
    } else { // the usual single-target moves, e.g., Flamethrower, Thunderbolt
        int enemySide = BattleSystem_GetBattlerSide(battleSys, attacker) ^ 1;
        int target = battleCtx->battlerActions[attacker][BATTLE_ACTION_CHOOSE_TARGET];
        int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

        if (battleCtx->sideConditions[enemySide].followMe
            && battleCtx->battleMons[battleCtx->sideConditions[enemySide].followMeUser].curHP
            && Battler_Ability(battleCtx, attacker) != ABILITY_STALWART // Sovereign (item 11): these ignore Follow Me
            && Battler_Ability(battleCtx, attacker) != ABILITY_PROPELLER_TAIL
            && move != MOVE_SNIPE_SHOT) {
            // If Follow Me is active and the user is still alive, re-point all targets toward them
            defender = battleCtx->sideConditions[enemySide].followMeUser;
        } else if (battleCtx->battleMons[target].curHP) {
            defender = target;
        } else {
            // If the original target is no longer alive, try to target their partner instead
            target = BattleSystem_RandomOpponent(battleSys, battleCtx, attacker);
            if (battleCtx->battleMons[target].curHP) {
                defender = target;
            }
        }
    }

    return defender;
}

void BattleSystem_CheckRedirectionAbilities(BattleSystem *battleSys, BattleContext *battleCtx, int attacker, u16 move)
{
    int battler, moveType; // must declare these first to match

    if (battleCtx->defender == BATTLER_NONE
        || Battler_Ability(battleCtx, attacker) == ABILITY_NORMALIZE
        || Sovereign_IsMoldBreaker(battleCtx, attacker)
        || Battler_Ability(battleCtx, attacker) == ABILITY_STALWART // Sovereign (item 11)
        || Battler_Ability(battleCtx, attacker) == ABILITY_PROPELLER_TAIL
        || move == MOVE_SNIPE_SHOT) {
        return;
    }

    int defSide = BattleSystem_GetBattlerSide(battleSys, attacker) ^ 1;
    if (battleCtx->sideConditions[defSide].followMe && FOLLOW_ME_MON(defSide).curHP) {
        return;
    }

    moveType = CalcMoveType(battleSys, battleCtx, attacker, move);
    if (moveType == TYPE_NORMAL) {
        moveType = MOVE_DATA(move).type;
    }
    moveType = Sovereign_AbilityMoveType(Battler_Ability(battleCtx, attacker), move, moveType); // Sovereign (item 11)
    moveType = Sovereign_ElectrifyType(battleCtx, attacker, move, moveType);

    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    if (moveType == TYPE_ELECTRIC
        && (MOVE_DATA(move).range == RANGE_SINGLE_TARGET || MOVE_DATA(move).range == RANGE_RANDOM_OPPONENT)
        && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
        && BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_EXCEPT_ME, attacker, ABILITY_LIGHTNING_ROD)) {
        for (int i = 0; i < maxBattlers; i++) {
            battler = battleCtx->monSpeedOrder[i];

            if (Battler_Ability(battleCtx, battler) == ABILITY_LIGHTNING_ROD
                && battleCtx->battleMons[battler].curHP
                && attacker != battler) {
                break;
            }
        }

        if (battler != battleCtx->defender) {
            battleCtx->selfTurnFlags[battler].lightningRodActivated = TRUE;
            battleCtx->defender = battler;
        }
    } else if (moveType == TYPE_WATER
        && (MOVE_DATA(move).range == RANGE_SINGLE_TARGET || MOVE_DATA(move).range == RANGE_RANDOM_OPPONENT)
        && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
        && BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_EXCEPT_ME, attacker, ABILITY_STORM_DRAIN)) {
        for (int i = 0; i < maxBattlers; i++) {
            battler = battleCtx->monSpeedOrder[i];

            if (Battler_Ability(battleCtx, battler) == ABILITY_STORM_DRAIN
                && battleCtx->battleMons[battler].curHP
                && attacker != battler) {
                break;
            }
        }

        if (battler != battleCtx->defender) {
            battleCtx->selfTurnFlags[battler].stormDrainActivated = TRUE;
            battleCtx->defender = battler;
        }
    }
}

BOOL BattleSystem_TriggerRedirectionAbilities(BattleSystem *battleSys, BattleContext *battleCtx)
{
    BOOL result = FALSE;

    if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE && DEFENDER_SELF_TURN_FLAGS.lightningRodActivated) {
        battleCtx->selfTurnFlags[battleCtx->defender].lightningRodActivated = FALSE;

        LOAD_SUBSEQ(subscript_lightning_rod_redirected);
        battleCtx->commandNext = battleCtx->command;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

        result = TRUE;
    }

    if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE && DEFENDER_SELF_TURN_FLAGS.stormDrainActivated) {
        battleCtx->selfTurnFlags[battleCtx->defender].stormDrainActivated = FALSE;

        LOAD_SUBSEQ(subscript_lightning_rod_redirected);
        battleCtx->commandNext = battleCtx->command;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

        result = TRUE;
    }

    return result;
}

void BattleMon_CopyToParty(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    if (battleCtx->battleMons[battler].heldItem == ITEM_NONE) {
        BattleAI_ClearKnownItem(battleCtx, battler);
    }

    BattleController_EmitUpdatePartyMon(battleSys, battleCtx, battler);
}

void Battler_LockMoveChoice(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    battleCtx->battleMons[battler].statusVolatile |= VOLATILE_CONDITION_MOVE_LOCKED;
    battleCtx->moveLockedInto[battler] = battleCtx->moveCur;
}

void Battler_UnlockMoveChoice(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    battleCtx->battleMons[battler].statusVolatile &= ~VOLATILE_CONDITION_MOVE_LOCKED;
    battleCtx->battleMons[battler].statusVolatile &= ~VOLATILE_CONDITION_BIDE;
    battleCtx->battleMons[battler].moveEffectsMask &= ~MOVE_EFFECT_SEMI_INVULNERABLE;
    battleCtx->battleMons[battler].moveEffectsData.rolloutCount = 0;
    battleCtx->battleMons[battler].moveEffectsData.furyCutterCount = 0;
}

enum BattleSubAnimation Battler_StatusCondition(BattleContext *battleCtx, int battler)
{
    if (battleCtx->battleMons[battler].status & MON_CONDITION_SLEEP) {
        return BATTLE_ANIMATION_ASLEEP;
    } else if (battleCtx->battleMons[battler].status & MON_CONDITION_POISON) {
        return BATTLE_ANIMATION_POISONED;
    } else if (battleCtx->battleMons[battler].status & MON_CONDITION_BURN) {
        return BATTLE_ANIMATION_BURNED;
    } else if (battleCtx->battleMons[battler].status & MON_CONDITION_FREEZE) {
        return BATTLE_ANIMATION_FROZEN;
    } else if (battleCtx->battleMons[battler].status & MON_CONDITION_PARALYSIS) {
        return BATTLE_ANIMATION_PARALYZED;
    } else if (battleCtx->battleMons[battler].status & MON_CONDITION_TOXIC) {
        return BATTLE_ANIMATION_POISONED;
    }

    return BATTLE_ANIMATION_NONE;
}

enum CheckTrainerMessageState {
    CHECK_TRMSG_START = 0,

    CHECK_TRMSG_FIRST_DAMAGE = CHECK_TRMSG_START,
    CHECK_TRMSG_ACTIVE_BATTLER_HALF_HP,
    CHECK_TRMSG_LAST_BATTLER,
    CHECK_TRMSG_LAST_BATTLER_HALF_HP,

    CHECK_TRMSG_END,
};

BOOL BattleSystem_CheckTrainerMessage(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int battleType = BattleSystem_GetBattleType(battleSys);

    if (battleType & BATTLE_TYPE_FRONTIER_LINK) {
        return FALSE;
    }

    if ((battleType & BATTLE_TYPE_TRAINER) == FALSE) {
        return FALSE;
    }

    if (battleType & BATTLE_TYPE_DOUBLES) {
        return FALSE;
    }

    int trID = Battler_GetTrainerID(battleSys, BATTLER_THEM);
    int state = CHECK_TRMSG_START;

    do {
        switch (state) {
        case CHECK_TRMSG_FIRST_DAMAGE:
            if (battleCtx->battleMons[BATTLER_THEM].timesDamaged == 1
                && (battleCtx->battleStatusMask2 & SYSCTL_FIRST_DAMAGE_MSG_SHOWN) == FALSE
                && Trainer_HasMessageType(trID, TRMSG_FIRST_DAMAGE, HEAP_ID_BATTLE)) {
                battleCtx->battleStatusMask2 |= SYSCTL_FIRST_DAMAGE_MSG_SHOWN;
                battleCtx->msgTemp = TRMSG_FIRST_DAMAGE;
                return TRUE;
            }

            state++;
            break;

        case CHECK_TRMSG_ACTIVE_BATTLER_HALF_HP:
            if ((battleCtx->battleMons[BATTLER_THEM].trainerMessageFlags & TRMSG_ACTIVE_BATTLER_HALF_HP_FLAG) == FALSE
                && battleCtx->battleMons[BATTLER_THEM].curHP <= battleCtx->battleMons[BATTLER_THEM].maxHP / 2
                && Trainer_HasMessageType(trID, TRMSG_ACTIVE_BATTLER_HALF_HP, HEAP_ID_BATTLE)) {
                battleCtx->battleMons[BATTLER_THEM].trainerMessageFlags |= TRMSG_ACTIVE_BATTLER_HALF_HP_FLAG;
                battleCtx->msgTemp = TRMSG_ACTIVE_BATTLER_HALF_HP;
                return TRUE;
            }

            state++;
            break;

        case CHECK_TRMSG_LAST_BATTLER:
            if ((battleCtx->battleMons[BATTLER_THEM].trainerMessageFlags & TRMSG_LAST_BATTLER_FLAG) == FALSE) {
                Party *party = BattleSystem_GetParty(battleSys, BATTLER_THEM);
                int alive = 0;

                for (int i = 0; i < Party_GetCurrentCount(party); i++) {
                    Pokemon *mon = Party_GetPokemonBySlotIndex(party, i);

                    if (Pokemon_GetValue(mon, MON_DATA_HP, NULL)) {
                        alive++;
                    }
                }

                if (alive == 1 && Trainer_HasMessageType(trID, TRMSG_LAST_BATTLER, HEAP_ID_BATTLE)) {
                    battleCtx->battleMons[BATTLER_THEM].trainerMessageFlags |= TRMSG_LAST_BATTLER_FLAG;
                    battleCtx->msgTemp = TRMSG_LAST_BATTLER;
                    return TRUE;
                }
            }

            state++;
            break;

        case CHECK_TRMSG_LAST_BATTLER_HALF_HP:
            if ((battleCtx->battleMons[BATTLER_THEM].trainerMessageFlags & TRMSG_LAST_BATTLER_HALF_HP_FLAG) == FALSE) {
                Party *party = BattleSystem_GetParty(battleSys, BATTLER_THEM);
                int alive = 0;

                for (int i = 0; i < Party_GetCurrentCount(party); i++) {
                    Pokemon *mon = Party_GetPokemonBySlotIndex(party, i);

                    if (Pokemon_GetValue(mon, MON_DATA_HP, NULL)) {
                        alive++;
                    }
                }

                if (alive == 1
                    && battleCtx->battleMons[BATTLER_THEM].curHP <= battleCtx->battleMons[BATTLER_THEM].maxHP / 2
                    && Trainer_HasMessageType(trID, TRMSG_LAST_BATTLER_HALF_HP, HEAP_ID_BATTLE)) {
                    battleCtx->battleMons[BATTLER_THEM].trainerMessageFlags |= TRMSG_LAST_BATTLER_HALF_HP_FLAG;
                    battleCtx->msgTemp = TRMSG_LAST_BATTLER_HALF_HP;
                    return TRUE;
                }
            }

            state++;
            break;

        case CHECK_TRMSG_END:
            break;
        }
    } while (state != CHECK_TRMSG_END);

    return FALSE;
}

void BattleContext_Init(BattleContext *battleCtx)
{
    battleCtx->damage = 0;
    battleCtx->criticalMul = 1;
    battleCtx->criticalBoosts = 0;
    battleCtx->movePower = 0;
    battleCtx->powerMul = 10;
    battleCtx->moveType = TYPE_NORMAL;
    battleCtx->moveEffectChance = 0;
    battleCtx->moveStatusFlags = 0;
    battleCtx->faintedMon = BATTLER_NONE;
    battleCtx->sideEffectDirectFlags = MOVE_SUBSCRIPT_PTR_NONE;
    battleCtx->sideEffectIndirectFlags = MOVE_SUBSCRIPT_PTR_NONE;
    battleCtx->sideEffectAbilityFlags = MOVE_SUBSCRIPT_PTR_NONE;
    battleCtx->sideEffectType = SIDE_EFFECT_TYPE_NONE;
    battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_NONE;
    battleCtx->sideEffectMon = BATTLER_NONE;
    battleCtx->multiHitCounter = 0;
    battleCtx->multiHitNumHits = 0;
    battleCtx->sovereignParentalBond = FALSE;
    battleCtx->sovereignDarts = 0; // SOVEREIGN_DARTS_NONE
    battleCtx->sovereignThroughProtect = FALSE;
    battleCtx->battlerCounter = 0;
    battleCtx->multiHitLoop = 0;
    battleCtx->afterMoveMessageType = 0;
    battleCtx->multiHitCheckFlags = 0;
    battleCtx->multiHitAccuracyCheck = 0;
    battleCtx->fieldConditionCheckState = 0;
    battleCtx->monConditionCheckState = 0;
    battleCtx->sideConditionCheckState = 0;
    battleCtx->turnStartCheckState = 0;
    battleCtx->afterMoveHitCheckState = 0;
    battleCtx->afterMoveMessageState = 0;
    battleCtx->afterMoveEffectState = 0;
    battleCtx->beforeMoveCheckState = 0;
    battleCtx->tryMoveCheckState = 0;
    battleCtx->statusCheckState = 0;
    battleCtx->abilityCheckState = 0;
    battleCtx->battleStatusMask &= SYSCTL_INIT;
    battleCtx->battleStatusMask2 &= SYSCTL_INIT2;
    battleCtx->magnitude = 0;

    for (int i = 0; i < MAX_BATTLERS; i++) {
        MI_CpuClearFast(&battleCtx->selfTurnFlags[i], sizeof(struct SelfTurnFlags));
        battleCtx->aiSwitchedPartySlot[i] = 6;
    }
}

void BattleContext_InitCounters(BattleSystem *battleSys, BattleContext *battleCtx)
{
    for (int i = 0; i < MAX_BATTLERS; i++) {
        battleCtx->moveHitBattler[i] = BATTLER_NONE;
        battleCtx->switchedPartySlot[i] = 6;
        battleCtx->speedRand[i] = BattleSystem_RandNext(battleSys);
    }

    battleCtx->prizeMoneyMul = 1;
    battleCtx->meFirstTurnOrder = 1;

    int battleType = BattleSystem_GetBattleType(battleSys);
    if ((battleType & BATTLE_TYPE_DOUBLES) == FALSE) {
        battleCtx->battlersSwitchingMask |= FlagIndex(BATTLER_PLAYER_2);
        battleCtx->battlersSwitchingMask |= FlagIndex(BATTLER_ENEMY_2);
    }

    battleCtx->safariCatchStage = 6;
    battleCtx->safariEscapeCount = 6;
}

void BattleSystem_UpdateAfterSwitch(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    // declare C89-style to match
    int i, maxBattlers;
    u32 battleType;
    u8 *addr;
    MoveEffectsData moveEffects;
    BOOL shedTail; // Sovereign (item 11): Shed Tail switches as Baton Pass does, but passes on the substitute only
    u32 substitute;

    moveEffects = battleCtx->battleMons[battler].moveEffectsData;
    shedTail = (battleCtx->battleStatusMask & SYSCTL_BATON_PASS) && battleCtx->sovereignShedTail;
    substitute = battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_SUBSTITUTE;
    battleCtx->sovereignShedTail = FALSE;
    maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    battleType = BattleSystem_GetBattleType(battleSys);

    // Forcefully end the battler's turn after the replacement
    battleCtx->battlerActions[battler][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_MOVE_END;

    if ((battleCtx->battleStatusMask & SYSCTL_BATON_PASS) == FALSE || shedTail) {
        // Clear any Mean Look or Lock On effects from other active battlers
        for (i = 0; i < maxBattlers; i++) {
            if ((battleCtx->battleMons[i].statusVolatile & VOLATILE_CONDITION_MEAN_LOOK)
                && (battleCtx->battleMons[i].moveEffectsData.meanLookTarget == battler)) {
                battleCtx->battleMons[i].statusVolatile &= ~VOLATILE_CONDITION_MEAN_LOOK;
            }

            if ((battleCtx->battleMons[i].moveEffectsMask & MOVE_EFFECT_LOCK_ON)
                && (battleCtx->battleMons[i].moveEffectsData.lockOnTarget == battler)) {
                battleCtx->battleMons[i].moveEffectsMask &= ~MOVE_EFFECT_LOCK_ON;
                battleCtx->battleMons[i].moveEffectsData.lockOnTarget = 0;
            }
        }

        battleCtx->battleMons[battler].statusVolatile = shedTail ? substitute : VOLATILE_CONDITION_NONE;
        battleCtx->battleMons[battler].moveEffectsMask = MOVE_EFFECT_NONE;
    } else {
        // Baton Pass maintains Focus Energy, Mean Look, Confusion, Curse, Substitute,
        // and a variety of move effects (see constants/battle/moves.h)
        battleCtx->battleMons[battler].statusVolatile &= VOLATILE_CONDITION_BATON_PASSED;
        battleCtx->battleMons[battler].moveEffectsMask &= MOVE_EFFECT_BATON_PASSED;

        for (i = 0; i < maxBattlers; i++) {
            if ((battleCtx->battleMons[i].moveEffectsMask & MOVE_EFFECT_LOCK_ON)
                && battleCtx->battleMons[i].moveEffectsData.lockOnTarget == battler) {
                // When transferring Lock On due to Baton Pass, its effect timer is refreshed
                battleCtx->battleMons[i].moveEffectsMask &= ~MOVE_EFFECT_LOCK_ON;
                battleCtx->battleMons[i].moveEffectsMask |= MOVE_EFFECT_LOCK_ON_INITIAL_DURATION;
            }
        }
    }

    // Clear the effects of Attract and Bind sourced from the replaced battler
    for (i = 0; i < maxBattlers; i++) {
        if (battleCtx->battleMons[i].statusVolatile & (FlagIndex(battler) << VOLATILE_CONDITION_ATTRACT_SHIFT)) {
            battleCtx->battleMons[i].statusVolatile &= FLAG_NEGATE(FlagIndex(battler) << VOLATILE_CONDITION_ATTRACT_SHIFT);
        }

        if ((battleCtx->battleMons[i].statusVolatile & VOLATILE_CONDITION_BIND)
            && battleCtx->battleMons[i].moveEffectsData.bindTarget == battler) {
            battleCtx->battleMons[i].statusVolatile &= ~VOLATILE_CONDITION_BIND;
        }
    }

    // Clear all move effects for the battler
    addr = (u8 *)&battleCtx->battleMons[battler].moveEffectsData; // doesn't match with &moveEffectsData
    for (i = 0; i < sizeof(MoveEffectsData); i++) {
        addr[i] = 0;
    }

    // Update the move effects for Baton Pass, if applicable
    if (shedTail) {
        battleCtx->battleMons[battler].moveEffectsData.substituteHP = moveEffects.substituteHP;
    } else if (battleCtx->battleStatusMask & SYSCTL_BATON_PASS) {
        battleCtx->battleMons[battler].moveEffectsData.substituteHP = moveEffects.substituteHP;
        battleCtx->battleMons[battler].moveEffectsData.lockOnTarget = moveEffects.lockOnTarget;
        battleCtx->battleMons[battler].moveEffectsData.perishSongTurns = moveEffects.perishSongTurns;
        battleCtx->battleMons[battler].moveEffectsData.meanLookTarget = moveEffects.meanLookTarget;
        battleCtx->battleMons[battler].moveEffectsData.magnetRiseTurns = moveEffects.magnetRiseTurns;
        battleCtx->battleMons[battler].moveEffectsData.embargoTurns = moveEffects.embargoTurns;
        battleCtx->battleMons[battler].moveEffectsData.healBlockTurns = moveEffects.healBlockTurns;
    }

    battleCtx->battleMons[battler].moveEffectsData.fakeOutTurnNumber = battleCtx->totalTurns + 1;
    battleCtx->battleMons[battler].moveEffectsData.slowStartTurnNumber = battleCtx->totalTurns + 1;
    battleCtx->battleMons[battler].moveEffectsData.truant = (battleCtx->totalTurns + 1) & 1;
    battleCtx->turnFlags[battler].sovereignSwitchedIn = TRUE; // Sovereign (item 11): Core Enforcer
    battleCtx->moveProtect[battler] = MOVE_NONE;
    battleCtx->moveHit[battler] = MOVE_NONE;
    battleCtx->moveHitBattler[battler] = BATTLER_NONE;
    battleCtx->moveHitType[battler] = MOVE_NONE;
    battleCtx->movePrevByBattler[battler] = MOVE_NONE;
    battleCtx->sovereignLastMoveFailed[battler] = FALSE;
    battleCtx->sovereignLastMoveUsed[battler] = MOVE_NONE; // Sovereign (item 11)
    battleCtx->sovereignLaserFocus[battler] = 0;
    battleCtx->sovereignDragonCheer[battler] = 0;
    battleCtx->sovereignTelekinesis[battler] = 0;
    battleCtx->sovereignThroatChop[battler] = 0;
    battleCtx->sovereignSmackedDown[battler] = 0;
    battleCtx->sovereignGlaiveRush &= ~FlagIndex(battler); // Sovereign (item 11)
    battleCtx->sovereignSaltCure &= ~FlagIndex(battler);
    battleCtx->sovereignSyrupBomb[battler] = 0;
    battleCtx->sovereignOctolock[battler] = 0;
    battleCtx->sovereignTarShot &= ~FlagIndex(battler);
    MI_CpuClear8(battleCtx->sovereignMirrorHerbRises[battler], sizeof(battleCtx->sovereignMirrorHerbRises[battler])); // Sovereign (item 11)
    MI_CpuClear8(battleCtx->sovereignTimesHit[battler], sizeof(battleCtx->sovereignTimesHit[battler])); // Rage Fist (Champions)
    battleCtx->moveCopied[battler] = MOVE_NONE;
    battleCtx->moveCopiedHit[battler][0] = MOVE_NONE;
    battleCtx->moveCopiedHit[battler][1] = MOVE_NONE;
    battleCtx->moveCopiedHit[battler][2] = MOVE_NONE;
    battleCtx->moveCopiedHit[battler][3] = MOVE_NONE;
    battleCtx->moveSketched[battler] = MOVE_NONE;
    battleCtx->conversion2Move[battler] = MOVE_NONE;
    battleCtx->conversion2Battler[battler] = MOVE_NONE;
    battleCtx->conversion2Type[battler] = MOVE_NONE;
    battleCtx->metronomeMove[battler] = MOVE_NONE;
    battleCtx->fieldConditionsMask &= FLAG_NEGATE(FlagIndex(battler) << FIELD_CONDITION_UPROAR_SHIFT);

    if (battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_POWER_TRICK) {
        i = battleCtx->battleMons[battler].attack;
        battleCtx->battleMons[battler].attack = battleCtx->battleMons[battler].defense;
        battleCtx->battleMons[battler].defense = i;
    }

    for (i = 0; i < maxBattlers; i++) {
        if (i != battler && BattleSystem_GetBattlerSide(battleSys, i) != BattleSystem_GetBattlerSide(battleSys, battler)) {
            battleCtx->moveCopied[i] = MOVE_NONE;
        }

        battleCtx->moveCopiedHit[i][battler] = MOVE_NONE;
    }

    BattleAI_ClearKnownMoves(battleCtx, battler);
    BattleAI_ClearKnownAbility(battleCtx, battler);
    BattleAI_ClearKnownItem(battleCtx, battler);
}

void BattleSystem_CleanupFaintedMon(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    int i;

    for (i = BATTLE_STAT_HP; i < BATTLE_STAT_MAX; i++) {
        battleCtx->battleMons[battler].statBoosts[i] = DEFAULT_STAT_STAGE;
    }

    battleCtx->battleMons[battler].statusVolatile = 0;
    battleCtx->battleMons[battler].moveEffectsMask = 0;

    // Negate Mean Look, Attract, and Bind flags
    for (i = 0; i < maxBattlers; i++) {
        if ((battleCtx->battleMons[i].statusVolatile & VOLATILE_CONDITION_MEAN_LOOK)
            && battleCtx->battleMons[i].moveEffectsData.meanLookTarget == battler) {
            battleCtx->battleMons[i].statusVolatile &= ~VOLATILE_CONDITION_MEAN_LOOK;
        }

        if (battleCtx->battleMons[i].statusVolatile & (FlagIndex(battler) << VOLATILE_CONDITION_ATTRACT_SHIFT)) {
            battleCtx->battleMons[i].statusVolatile &= (FlagIndex(battler) << VOLATILE_CONDITION_ATTRACT_SHIFT) ^ 0xFFFFFFFF;
        }

        if ((battleCtx->battleMons[i].statusVolatile & VOLATILE_CONDITION_BIND)
            && battleCtx->battleMons[i].moveEffectsData.bindTarget == battler) {
            battleCtx->battleMons[i].statusVolatile &= ~VOLATILE_CONDITION_BIND;
        }
    }

    u8 *addr = (u8 *)&battleCtx->battleMons[battler].moveEffectsData;
    for (i = 0; i < sizeof(MoveEffectsData); i++) {
        addr[i] = 0;
    }

    addr = (u8 *)&battleCtx->turnFlags[battler];
    for (i = 0; i < sizeof(struct TurnFlags); i++) {
        addr[i] = 0;
    }

    battleCtx->battleMons[battler].moveEffectsData.fakeOutTurnNumber = battleCtx->totalTurns + 1;
    battleCtx->battleMons[battler].moveEffectsData.slowStartTurnNumber = battleCtx->totalTurns + 1;
    battleCtx->battleMons[battler].moveEffectsData.truant = (battleCtx->totalTurns + 1) & 1;
    battleCtx->moveProtect[battler] = MOVE_NONE;
    battleCtx->moveHit[battler] = MOVE_NONE;
    battleCtx->moveHitBattler[battler] = BATTLER_NONE;
    battleCtx->moveHitType[battler] = MOVE_NONE;
    battleCtx->movePrevByBattler[battler] = MOVE_NONE;
    battleCtx->sovereignLastMoveFailed[battler] = FALSE;
    battleCtx->sovereignLastMoveUsed[battler] = MOVE_NONE; // Sovereign (item 11)
    battleCtx->sovereignLaserFocus[battler] = 0;
    battleCtx->sovereignDragonCheer[battler] = 0;
    battleCtx->sovereignTelekinesis[battler] = 0;
    battleCtx->sovereignThroatChop[battler] = 0;
    battleCtx->sovereignSmackedDown[battler] = 0;
    battleCtx->sovereignGlaiveRush &= ~FlagIndex(battler); // Sovereign (item 11)
    battleCtx->sovereignSaltCure &= ~FlagIndex(battler);
    battleCtx->sovereignSyrupBomb[battler] = 0;
    battleCtx->sovereignOctolock[battler] = 0;
    battleCtx->sovereignTarShot &= ~FlagIndex(battler);
    MI_CpuClear8(battleCtx->sovereignMirrorHerbRises[battler], sizeof(battleCtx->sovereignMirrorHerbRises[battler])); // Sovereign (item 11)
    MI_CpuClear8(battleCtx->sovereignTimesHit[battler], sizeof(battleCtx->sovereignTimesHit[battler])); // Rage Fist (Champions)
    battleCtx->moveCopied[battler] = MOVE_NONE;
    battleCtx->moveCopiedHit[battler][0] = MOVE_NONE;
    battleCtx->moveCopiedHit[battler][1] = MOVE_NONE;
    battleCtx->moveCopiedHit[battler][2] = MOVE_NONE;
    battleCtx->moveCopiedHit[battler][3] = MOVE_NONE;
    battleCtx->moveSketched[battler] = MOVE_NONE;
    battleCtx->conversion2Move[battler] = MOVE_NONE;
    battleCtx->conversion2Battler[battler] = MOVE_NONE;
    battleCtx->conversion2Type[battler] = MOVE_NONE;
    battleCtx->metronomeMove[battler] = MOVE_NONE;
    battleCtx->fieldConditionsMask &= (FlagIndex(battler) << FIELD_CONDITION_UPROAR_SHIFT) ^ 0xFFFFFFFF;

    for (i = 0; i < maxBattlers; i++) {
        if (i != battler && BattleSystem_GetBattlerSide(battleSys, i) != BattleSystem_GetBattlerSide(battleSys, battler)) {
            battleCtx->moveCopied[i] = MOVE_NONE;
        }
        battleCtx->moveCopiedHit[i][battler] = 0;
    }

    battleCtx->battlerStatusFlags[battler] &= ~BATTLER_STATUS_SWITCHING;
    BattleAI_ClearKnownMoves(battleCtx, battler);
    BattleAI_ClearKnownAbility(battleCtx, battler);
    BattleAI_ClearKnownItem(battleCtx, battler);
}

void BattleSystem_SetupNextTurn(BattleSystem *battleSys, BattleContext *battleCtx)
{
    for (int i = 0; i < MAX_BATTLERS; i++) {
        // Sovereign (item 11): Wide Guard and Quick Guard last one turn; Laser Focus and Throat Chop wear off.
        if (i < 2) {
            battleCtx->sovereignSideGuards[i] = 0;
        }
        if (battleCtx->sovereignLaserFocus[i]) {
            battleCtx->sovereignLaserFocus[i]--;
        }
        if (battleCtx->sovereignThroatChop[i]) {
            battleCtx->sovereignThroatChop[i]--;
        }

        MI_CpuClearFast(&battleCtx->turnFlags[i], sizeof(struct TurnFlags));
        MI_CpuClearFast(&battleCtx->moveFailFlags[i], sizeof(struct MoveFailFlags));

        battleCtx->battleMons[i].statusVolatile &= ~VOLATILE_CONDITION_FLINCH;

        if (battleCtx->battleMons[i].moveEffectsData.rechargeTurnNumber + 1 < battleCtx->totalTurns) {
            battleCtx->battleMons[i].statusVolatile &= ~VOLATILE_CONDITION_RECHARGING;
        }

        if ((battleCtx->battleMons[i].status & MON_CONDITION_SLEEP)
            && (battleCtx->battleMons[i].statusVolatile & VOLATILE_CONDITION_MOVE_LOCKED)) {
            Battler_UnlockMoveChoice(battleSys, battleCtx, i);
        }

        if ((battleCtx->battleMons[i].status & MON_CONDITION_SLEEP)
            && (battleCtx->battleMons[i].statusVolatile & VOLATILE_CONDITION_THRASH)) {
            battleCtx->battleMons[i].statusVolatile &= ~VOLATILE_CONDITION_THRASH;
        }
    }

    battleCtx->sideConditions[BATTLER_US].followMe = FALSE;
    battleCtx->sideConditions[BATTLER_THEM].followMe = FALSE;

    // Sovereign (item 11): Ion Deluge lasts one turn; Fairy Lock, the turn it was used and the next.
    battleCtx->sovereignIonDeluge = FALSE;
    if (battleCtx->sovereignFairyLock) {
        battleCtx->sovereignFairyLock--;
    }
}

int BattleSystem_CheckInvalidMoves(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int invalidMoves, int opMask)
{
    int itemEffect = Battler_HeldItemEffect(battleCtx, battler);

    for (int i = 0; i < LEARNED_MOVES_MAX; i++) {
        if (battleCtx->battleMons[battler].moves[i] == MOVE_NONE
            && (opMask & CHECK_INVALID_NO_MOVE)) {
            invalidMoves |= FlagIndex(i);
        }

        if (battleCtx->battleMons[battler].ppCur[i] == 0
            && (opMask & CHECK_INVALID_NO_PP)) {
            invalidMoves |= FlagIndex(i);
        }

        if (battleCtx->battleMons[battler].moves[i] == battleCtx->battleMons[battler].moveEffectsData.disabledMove
            && (opMask & CHECK_INVALID_DISABLED)) {
            invalidMoves |= FlagIndex(i);
        }

        if (battleCtx->battleMons[battler].moves[i] == battleCtx->movePrevByBattler[battler]
            && (opMask & CHECK_INVALID_TORMENTED)
            && (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_TORMENT)) {
            invalidMoves |= FlagIndex(i);
        }

        if (battleCtx->battleMons[battler].moveEffectsData.tauntedTurns
            && (opMask & CHECK_INVALID_TAUNTED)
            && MOVE_DATA(battleCtx->battleMons[battler].moves[i]).power == 0
            && battleCtx->battleMons[battler].moves[i] != MOVE_ME_FIRST) { // Sovereign: Taunt lets Me First through (Gen V+)
            invalidMoves |= FlagIndex(i);
        }

        if (Move_Imprisoned(battleSys, battleCtx, battler, battleCtx->battleMons[battler].moves[i])
            && (opMask & CHECK_INVALID_IMPRISONED)) {
            invalidMoves |= FlagIndex(i);
        }

        if (Move_FailsInHighGravity(battleSys, battleCtx, battler, battleCtx->battleMons[battler].moves[i])
            && (opMask & CHECK_INVALID_GRAVITY)) {
            invalidMoves |= FlagIndex(i);
        }

        if (Move_HealBlocked(battleSys, battleCtx, battler, battleCtx->battleMons[battler].moves[i])
            && (opMask & CHECK_INVALID_HEAL_BLOCK)) {
            invalidMoves |= FlagIndex(i);
        }

        if (battleCtx->battleMons[battler].moveEffectsData.encoredMove
            && battleCtx->battleMons[battler].moveEffectsData.encoredMove != battleCtx->battleMons[battler].moves[i]) {
            invalidMoves |= FlagIndex(i);
        }

        if (Battler_HeldItem(battleCtx, battler) == ITEM_ASSAULT_VEST
            && MOVE_DATA(battleCtx->battleMons[battler].moves[i]).class == CLASS_STATUS
            && (opMask & CHECK_INVALID_ASSAULT_VEST)) {
            invalidMoves |= FlagIndex(i);
        }

        // Sovereign (item 11): Gigaton Hammer and Blood Moon can't be used twice in a row.
        if ((battleCtx->battleMons[battler].moves[i] == MOVE_GIGATON_HAMMER || battleCtx->battleMons[battler].moves[i] == MOVE_BLOOD_MOON)
            && battleCtx->battleMons[battler].moves[i] == battleCtx->sovereignLastMoveUsed[battler]
            && (opMask & CHECK_INVALID_TWICE_IN_A_ROW)) {
            invalidMoves |= FlagIndex(i);
        }

        // Sovereign (Pokémon Champions): first-turn-only moves can't even be selected after the user's first turn.
        if (battleCtx->sovereignThroatChop[battler]
            && Move_IsSound(battleCtx->battleMons[battler].moves[i])
            && (opMask & CHECK_INVALID_THROAT_CHOP)) {
            invalidMoves |= FlagIndex(i);
        }

        if ((MOVE_DATA(battleCtx->battleMons[battler].moves[i]).effect == BATTLE_EFFECT_ALWAYS_FLINCH_FIRST_TURN_ONLY
                || MOVE_DATA(battleCtx->battleMons[battler].moves[i]).effect == BATTLE_EFFECT_SOVEREIGN_FIRST_IMPRESSION)
            && battleCtx->battleMons[battler].moveEffectsData.fakeOutTurnNumber != battleCtx->totalTurns
            && (opMask & CHECK_INVALID_FIRST_TURN)) {
            invalidMoves |= FlagIndex(i);
        }

        if (Battler_SovereignChoiceLocks(battleCtx, battler) // Sovereign (item 11): Gorilla Tactics too
            && (opMask & CHECK_INVALID_CHOICE_ITEM)) {
            if (Battler_SlotForMove(&battleCtx->battleMons[battler], battleCtx->battleMons[battler].moveEffectsData.choiceLockedMove) == LEARNED_MOVES_MAX) {
                battleCtx->battleMons[battler].moveEffectsData.choiceLockedMove = MOVE_NONE;
            } else if (battleCtx->battleMons[battler].moveEffectsData.choiceLockedMove
                && battleCtx->battleMons[battler].moveEffectsData.choiceLockedMove != battleCtx->battleMons[battler].moves[i]) {
                invalidMoves |= FlagIndex(i);
            }
        }
    }

    return invalidMoves;
}

BOOL BattleSystem_CanUseMove(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int moveSlot, BattleMessage *msgOut)
{
    BOOL result = TRUE;

    if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_DISABLED) & FlagIndex(moveSlot)) {
        msgOut->tags = TAG_NICKNAME_MOVE;
        msgOut->id = BattleStrings_Text_PokemonsMoveIsDisabled_Ally; // "{0}'s {1} is disabled!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        msgOut->params[1] = battleCtx->battleMons[battler].moves[moveSlot];
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_TORMENTED) & FlagIndex(moveSlot)) {
        msgOut->tags = TAG_NICKNAME;
        msgOut->id = BattleStrings_Text_PokemonCantUseTheSameMoveTwiceInARowDueToTheTorment; // "{0} can't use the same move twice in a row due to the torment!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_TAUNTED) & FlagIndex(moveSlot)) {
        msgOut->tags = TAG_NICKNAME_MOVE;
        msgOut->id = BattleStrings_Text_PokemonCantUseMoveAfterTheTaunt_Ally; // "{0} can't use {1} after the taunt!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        msgOut->params[1] = battleCtx->battleMons[battler].moves[moveSlot];
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_IMPRISONED) & FlagIndex(moveSlot)) {
        msgOut->tags = TAG_NICKNAME_MOVE;
        msgOut->id = BattleStrings_Text_PokemonCantUseTheSealedMove_Ally; // "{0} can't use the sealed {1}!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        msgOut->params[1] = battleCtx->battleMons[battler].moves[moveSlot];
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_GRAVITY) & FlagIndex(moveSlot)) {
        msgOut->tags = TAG_NICKNAME_MOVE;
        msgOut->id = BattleStrings_Text_PokemonCantUseMoveBecauseOfGravity_Ally; // "{0} can't use {1} because of gravity!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        msgOut->params[1] = battleCtx->battleMons[battler].moves[moveSlot];
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_HEAL_BLOCK) & FlagIndex(moveSlot)) {
        msgOut->tags = TAG_NICKNAME_MOVE_MOVE;
        msgOut->id = BattleStrings_Text_PokemonCantUseMoveBecauseOfMove_Ally; // "{0} can't use {2} because of {1}!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        msgOut->params[1] = MOVE_HEAL_BLOCK;
        msgOut->params[2] = battleCtx->battleMons[battler].moves[moveSlot];
        result = FALSE;
    } else if ((BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_CHOICE_ITEM) & FlagIndex(moveSlot))
        && Battler_Ability(battleCtx, battler) == ABILITY_GORILLA_TACTICS) {
        // Sovereign (item 11)
        msgOut->tags = TAG_NICKNAME_ABILITY_MOVE;
        msgOut->id = BattleStrings_Text_SovereignAbilityLetsItUseOnlyMove_Ally; // "{0}'s {1} lets it use only {2}!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        msgOut->params[1] = ABILITY_GORILLA_TACTICS;
        msgOut->params[2] = battleCtx->battleMons[battler].moveEffectsData.choiceLockedMove;
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_CHOICE_ITEM) & FlagIndex(moveSlot)) {
        msgOut->tags = TAG_ITEM_MOVE;
        msgOut->id = BattleStrings_Text_TheItemAllowsTheUseOfOnlyMove; // "The {0} allows the use of only {1}!"
        msgOut->params[0] = battleCtx->battleMons[battler].heldItem;
        msgOut->params[1] = battleCtx->battleMons[battler].moveEffectsData.choiceLockedMove;
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_ASSAULT_VEST) & FlagIndex(moveSlot)) {
        // Sovereign (item 11)
        msgOut->tags = TAG_ITEM;
        msgOut->id = BattleStrings_Text_SovereignItemPreventsStatusMoves; // "The {0} prevents status moves from being used!"
        msgOut->params[0] = ITEM_ASSAULT_VEST;
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_TWICE_IN_A_ROW) & FlagIndex(moveSlot)) {
        // Sovereign (item 11)
        msgOut->tags = TAG_NICKNAME_MOVE;
        msgOut->id = BattleStrings_Text_SovereignCantUseMoveTwiceInARow_Ally; // "{0} can't use {1} twice in a row!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        msgOut->params[1] = battleCtx->battleMons[battler].moves[moveSlot];
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_THROAT_CHOP) & FlagIndex(moveSlot)) {
        msgOut->tags = TAG_NICKNAME_MOVE_MOVE;
        msgOut->id = BattleStrings_Text_PokemonCantUseMoveBecauseOfMove_Ally; // "{0} can't use {2} because of {1}!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        msgOut->params[1] = MOVE_THROAT_CHOP;
        msgOut->params[2] = battleCtx->battleMons[battler].moves[moveSlot];
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_FIRST_TURN) & FlagIndex(moveSlot)) {
        msgOut->tags = TAG_NICKNAME_MOVE;
        msgOut->id = BattleStrings_Text_PokemonCanOnlyUseMoveOnItsFirstTurn_Ally; // "{0} can use {1} only on its first turn!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        msgOut->params[1] = battleCtx->battleMons[battler].moves[moveSlot];
        result = FALSE;
    } else if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battler, 0, CHECK_INVALID_NO_PP) & FlagIndex(moveSlot)) {
        msgOut->tags = TAG_NONE;
        msgOut->id = BattleStrings_Text_TheresNoPPLeftForThisMove; // "There's no PP left for this move!"
        result = FALSE;
    }

    return result;
}

int Battler_SlotForMove(BattleMon *mon, u16 move)
{
    int i;

    for (i = 0; i < LEARNED_MOVES_MAX; i++) {
        if (mon->moves[i] == move) {
            break;
        }
    }

    return i;
}

/**
 * @brief The type matchup table. This lists the matchups which are deemed to
 * have a Super Effective, Not Very Effective, or Immune result. The table can
 * be read as such:
 *
 *   attacking type, defending type, matchup multiplier
 *
 * The matchup multiplier is assumed to be divided by 10 at a later stage for
 * any computations which make use of it (hence the values 5 and 20).
 */
static const u8 sTypeMatchupMultipliers[][3] = {
    { TYPE_NORMAL, TYPE_ROCK, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_NORMAL, TYPE_STEEL, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIRE, TYPE_FIRE, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIRE, TYPE_WATER, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIRE, TYPE_GRASS, TYPE_MULTI_SUPER_EFF },
    { TYPE_FIRE, TYPE_ICE, TYPE_MULTI_SUPER_EFF },
    { TYPE_FIRE, TYPE_BUG, TYPE_MULTI_SUPER_EFF },
    { TYPE_FIRE, TYPE_ROCK, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIRE, TYPE_DRAGON, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIRE, TYPE_STEEL, TYPE_MULTI_SUPER_EFF },
    { TYPE_WATER, TYPE_FIRE, TYPE_MULTI_SUPER_EFF },
    { TYPE_WATER, TYPE_WATER, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_WATER, TYPE_GRASS, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_WATER, TYPE_GROUND, TYPE_MULTI_SUPER_EFF },
    { TYPE_WATER, TYPE_ROCK, TYPE_MULTI_SUPER_EFF },
    { TYPE_WATER, TYPE_DRAGON, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_ELECTRIC, TYPE_WATER, TYPE_MULTI_SUPER_EFF },
    { TYPE_ELECTRIC, TYPE_ELECTRIC, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_ELECTRIC, TYPE_GRASS, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_ELECTRIC, TYPE_GROUND, TYPE_MULTI_IMMUNE },
    { TYPE_ELECTRIC, TYPE_FLYING, TYPE_MULTI_SUPER_EFF },
    { TYPE_ELECTRIC, TYPE_DRAGON, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GRASS, TYPE_FIRE, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GRASS, TYPE_WATER, TYPE_MULTI_SUPER_EFF },
    { TYPE_GRASS, TYPE_GRASS, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GRASS, TYPE_POISON, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GRASS, TYPE_GROUND, TYPE_MULTI_SUPER_EFF },
    { TYPE_GRASS, TYPE_FLYING, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GRASS, TYPE_BUG, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GRASS, TYPE_ROCK, TYPE_MULTI_SUPER_EFF },
    { TYPE_GRASS, TYPE_DRAGON, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GRASS, TYPE_STEEL, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_ICE, TYPE_WATER, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_ICE, TYPE_GRASS, TYPE_MULTI_SUPER_EFF },
    { TYPE_ICE, TYPE_ICE, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_ICE, TYPE_GROUND, TYPE_MULTI_SUPER_EFF },
    { TYPE_ICE, TYPE_FLYING, TYPE_MULTI_SUPER_EFF },
    { TYPE_ICE, TYPE_DRAGON, TYPE_MULTI_SUPER_EFF },
    { TYPE_ICE, TYPE_STEEL, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_ICE, TYPE_FIRE, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIGHTING, TYPE_NORMAL, TYPE_MULTI_SUPER_EFF },
    { TYPE_FIGHTING, TYPE_ICE, TYPE_MULTI_SUPER_EFF },
    { TYPE_FIGHTING, TYPE_POISON, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIGHTING, TYPE_FLYING, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIGHTING, TYPE_PSYCHIC, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIGHTING, TYPE_BUG, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIGHTING, TYPE_ROCK, TYPE_MULTI_SUPER_EFF },
    { TYPE_FIGHTING, TYPE_DARK, TYPE_MULTI_SUPER_EFF },
    { TYPE_FIGHTING, TYPE_STEEL, TYPE_MULTI_SUPER_EFF },
    { TYPE_POISON, TYPE_GRASS, TYPE_MULTI_SUPER_EFF },
    { TYPE_POISON, TYPE_POISON, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_POISON, TYPE_GROUND, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_POISON, TYPE_ROCK, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_POISON, TYPE_GHOST, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_POISON, TYPE_STEEL, TYPE_MULTI_IMMUNE },
    { TYPE_GROUND, TYPE_FIRE, TYPE_MULTI_SUPER_EFF },
    { TYPE_GROUND, TYPE_ELECTRIC, TYPE_MULTI_SUPER_EFF },
    { TYPE_GROUND, TYPE_GRASS, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GROUND, TYPE_POISON, TYPE_MULTI_SUPER_EFF },
    { TYPE_GROUND, TYPE_FLYING, TYPE_MULTI_IMMUNE },
    { TYPE_GROUND, TYPE_BUG, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GROUND, TYPE_ROCK, TYPE_MULTI_SUPER_EFF },
    { TYPE_GROUND, TYPE_STEEL, TYPE_MULTI_SUPER_EFF },
    { TYPE_FLYING, TYPE_ELECTRIC, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FLYING, TYPE_GRASS, TYPE_MULTI_SUPER_EFF },
    { TYPE_FLYING, TYPE_FIGHTING, TYPE_MULTI_SUPER_EFF },
    { TYPE_FLYING, TYPE_BUG, TYPE_MULTI_SUPER_EFF },
    { TYPE_FLYING, TYPE_ROCK, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FLYING, TYPE_STEEL, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_PSYCHIC, TYPE_FIGHTING, TYPE_MULTI_SUPER_EFF },
    { TYPE_PSYCHIC, TYPE_POISON, TYPE_MULTI_SUPER_EFF },
    { TYPE_PSYCHIC, TYPE_PSYCHIC, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_PSYCHIC, TYPE_DARK, TYPE_MULTI_IMMUNE },
    { TYPE_PSYCHIC, TYPE_STEEL, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_BUG, TYPE_FIRE, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_BUG, TYPE_GRASS, TYPE_MULTI_SUPER_EFF },
    { TYPE_BUG, TYPE_FIGHTING, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_BUG, TYPE_POISON, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_BUG, TYPE_FLYING, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_BUG, TYPE_PSYCHIC, TYPE_MULTI_SUPER_EFF },
    { TYPE_BUG, TYPE_GHOST, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_BUG, TYPE_DARK, TYPE_MULTI_SUPER_EFF },
    { TYPE_BUG, TYPE_STEEL, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_ROCK, TYPE_FIRE, TYPE_MULTI_SUPER_EFF },
    { TYPE_ROCK, TYPE_ICE, TYPE_MULTI_SUPER_EFF },
    { TYPE_ROCK, TYPE_FIGHTING, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_ROCK, TYPE_GROUND, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_ROCK, TYPE_FLYING, TYPE_MULTI_SUPER_EFF },
    { TYPE_ROCK, TYPE_BUG, TYPE_MULTI_SUPER_EFF },
    { TYPE_ROCK, TYPE_STEEL, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GHOST, TYPE_NORMAL, TYPE_MULTI_IMMUNE },
    { TYPE_GHOST, TYPE_PSYCHIC, TYPE_MULTI_SUPER_EFF },
    { TYPE_GHOST, TYPE_DARK, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_GHOST, TYPE_GHOST, TYPE_MULTI_SUPER_EFF },
    { TYPE_DRAGON, TYPE_DRAGON, TYPE_MULTI_SUPER_EFF },
    { TYPE_DRAGON, TYPE_STEEL, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_DARK, TYPE_FIGHTING, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_DARK, TYPE_PSYCHIC, TYPE_MULTI_SUPER_EFF },
    { TYPE_DARK, TYPE_GHOST, TYPE_MULTI_SUPER_EFF },
    { TYPE_DARK, TYPE_DARK, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_STEEL, TYPE_FIRE, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_STEEL, TYPE_WATER, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_STEEL, TYPE_ELECTRIC, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_STEEL, TYPE_ICE, TYPE_MULTI_SUPER_EFF },
    { TYPE_STEEL, TYPE_ROCK, TYPE_MULTI_SUPER_EFF },
    { TYPE_STEEL, TYPE_STEEL, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FAIRY, TYPE_FIGHTING, TYPE_MULTI_SUPER_EFF },
    { TYPE_FAIRY, TYPE_DRAGON, TYPE_MULTI_SUPER_EFF },
    { TYPE_FAIRY, TYPE_DARK, TYPE_MULTI_SUPER_EFF },
    { TYPE_FAIRY, TYPE_FIRE, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FAIRY, TYPE_POISON, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FAIRY, TYPE_STEEL, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_FIGHTING, TYPE_FAIRY, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_BUG, TYPE_FAIRY, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_DARK, TYPE_FAIRY, TYPE_MULTI_NOT_VERY_EFF },
    { TYPE_POISON, TYPE_FAIRY, TYPE_MULTI_SUPER_EFF },
    { TYPE_STEEL, TYPE_FAIRY, TYPE_MULTI_SUPER_EFF },
    { TYPE_DRAGON, TYPE_FAIRY, TYPE_MULTI_IMMUNE },

    { 0xFE, 0xFE, TYPE_MULTI_IMMUNE },

    // These values are separated from the remainder of the table to support
    // the Foresight effect, which removes these immunities from consideration.
    { TYPE_NORMAL, TYPE_GHOST, TYPE_MULTI_IMMUNE },
    { TYPE_FIGHTING, TYPE_GHOST, TYPE_MULTI_IMMUNE },

    { 0xFF, 0xFF, TYPE_MULTI_IMMUNE },
};

/**
 * @brief Check if the basic type multiplier applies.
 *
 * @param battleCtx
 * @param attacker
 * @param defender
 * @param chartEntry    Index of the entry into the type-chart
 * @return TRUE if there are no active effects to override the given chart-entry,
 * FALSE if the chart-entry should be overriden
 */
static BOOL BasicTypeMulApplies(BattleContext *battleCtx, int attacker, int defender, int chartEntry)
{
    int itemEffect = Battler_HeldItemEffect(battleCtx, defender);
    BOOL result = TRUE;

    if ((itemEffect == HOLD_EFFECT_SPEED_DOWN_GROUNDED || (battleCtx->battleMons[defender].moveEffectsMask & MOVE_EFFECT_INGRAIN))
        && sTypeMatchupMultipliers[chartEntry][1] == TYPE_FLYING
        && sTypeMatchupMultipliers[chartEntry][2] == TYPE_MULTI_IMMUNE) {
        result = FALSE;
    }

    if (battleCtx->turnFlags[defender].roosting
        && sTypeMatchupMultipliers[chartEntry][1] == TYPE_FLYING) {
        result = FALSE;
    }

    if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY)
        && sTypeMatchupMultipliers[chartEntry][1] == TYPE_FLYING
        && sTypeMatchupMultipliers[chartEntry][2] == TYPE_MULTI_IMMUNE) {
        result = FALSE;
    }

    if ((battleCtx->battleMons[defender].moveEffectsMask & MOVE_EFFECT_MIRACLE_EYE)
        && sTypeMatchupMultipliers[chartEntry][1] == TYPE_DARK
        && sTypeMatchupMultipliers[chartEntry][2] == TYPE_MULTI_IMMUNE) {
        result = FALSE;
    }

    // Sovereign (item 11): Ring Target takes away its holder's type immunities.
    if (Battler_HeldItem(battleCtx, defender) == ITEM_RING_TARGET
        && sTypeMatchupMultipliers[chartEntry][2] == TYPE_MULTI_IMMUNE) {
        result = FALSE;
    }

    return result;
}

// Sovereign (item 11): a type chart entry's multiplier for this move. Freeze-Dry is super effective against Water;
// in Delta Stream's strong winds, nothing is super effective against the Flying type.
static u8 Sovereign_ChartMul(BattleContext *battleCtx, int move, int chartEntry)
{
    if (move == MOVE_FREEZE_DRY && sTypeMatchupMultipliers[chartEntry][1] == TYPE_WATER) {
        return TYPE_MULTI_SUPER_EFF;
    }

    if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_SOVEREIGN_STRONG_WINDS)
        && sTypeMatchupMultipliers[chartEntry][1] == TYPE_FLYING
        && sTypeMatchupMultipliers[chartEntry][2] == TYPE_MULTI_SUPER_EFF) {
        return 10; // neutral
    }

    return sTypeMatchupMultipliers[chartEntry][2];
}

int BattleSystem_ApplyTypeChart(BattleSystem *battleSys, BattleContext *battleCtx, int move, int inType, int attacker, int defender, int damage, u32 *moveStatusMask)
{
    int chartEntry;
    int totalMul;
    u8 moveType;
    u32 movePower;
    u8 attackerItemEffect;
    u8 defenderItemEffect;
    u8 attackerItemPower;
    u8 defenderItemPower;

    totalMul = 1;

    if (move == MOVE_STRUGGLE) {
        return damage;
    }

    attackerItemEffect = Battler_HeldItemEffect(battleCtx, attacker);
    attackerItemPower = Battler_HeldItemPower(battleCtx, attacker, ITEM_POWER_CHECK_ALL);
    defenderItemEffect = Battler_HeldItemEffect(battleCtx, defender);
    defenderItemPower = Battler_HeldItemPower(battleCtx, defender, ITEM_POWER_CHECK_ALL);

    moveType = Sovereign_AbilityMoveType(Battler_Ability(battleCtx, attacker), move, inType ? inType : MOVE_DATA(move).type); // Sovereign (item 11)
    moveType = Sovereign_ElectrifyType(battleCtx, attacker, move, moveType);

    movePower = MOVE_DATA(move).power;

    if ((battleCtx->battleStatusMask & SYSCTL_IGNORE_TYPE_CHECKS) == FALSE && MON_HAS_TYPE(attacker, moveType)) {
        if (Battler_Ability(battleCtx, attacker) == ABILITY_ADAPTABILITY) {
            damage *= 2;
        } else {
            damage = damage * 15 / 10;
        }
    }

    int sovereignDamageBeforeChart = damage;

    // Sovereign (item 11): Thousand Arrows hits Pokemon that Ground moves can't (a Flying type's immunity too, below).
    if ((Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_LEVITATE) == TRUE
            || Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_EELEVATE) == TRUE) // Sovereign (item 11)
        && moveType == TYPE_GROUND
        && move != MOVE_THOUSAND_ARROWS
        && defenderItemEffect != HOLD_EFFECT_SPEED_DOWN_GROUNDED) {
        *moveStatusMask |= MOVE_STATUS_LEVITATED;
    } else if (Battler_HeldItem(battleCtx, defender) == ITEM_AIR_BALLOON // Sovereign (item 11): "It doesn't affect {0}…"
        && moveType == TYPE_GROUND
        && move != MOVE_THOUSAND_ARROWS
        && (battleCtx->battleMons[defender].moveEffectsMask & MOVE_EFFECT_INGRAIN) == FALSE
        && (battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY) == FALSE
        && battleCtx->sovereignSmackedDown[defender] == 0) {
        *moveStatusMask |= MOVE_STATUS_INEFFECTIVE;
    } else if ((battleCtx->battleMons[defender].moveEffectsData.magnetRiseTurns || battleCtx->sovereignTelekinesis[defender]) // Sovereign (item 11)
        && (battleCtx->battleMons[defender].moveEffectsMask & MOVE_EFFECT_INGRAIN) == FALSE
        && moveType == TYPE_GROUND
        && move != MOVE_THOUSAND_ARROWS
        && defenderItemEffect != HOLD_EFFECT_SPEED_DOWN_GROUNDED) {
        *moveStatusMask |= MOVE_STATUS_MAGNET_RISE;
    } else {
        chartEntry = 0;

        while (sTypeMatchupMultipliers[chartEntry][0] != 0xFF) {
            if (sTypeMatchupMultipliers[chartEntry][0] == 0xFE) {
                // The Ghost-type immunities are listed separately and ignored as a batch
                if ((battleCtx->battleMons[defender].statusVolatile & VOLATILE_CONDITION_FORESIGHT)
                    || Battler_Ability(battleCtx, attacker) == ABILITY_SCRAPPY
                    || Battler_Ability(battleCtx, attacker) == ABILITY_MINDS_EYE) {
                    break;
                } else {
                    chartEntry++;
                    continue;
                }
            }

            // Sovereign (item 11): Flying Press is Flying type too, for its effectiveness. Thousand Arrows is neutral on a
            // Flying type.
            if ((sTypeMatchupMultipliers[chartEntry][0] == moveType
                    || (move == MOVE_FLYING_PRESS && sTypeMatchupMultipliers[chartEntry][0] == TYPE_FLYING))
                && (move != MOVE_THOUSAND_ARROWS || sTypeMatchupMultipliers[chartEntry][1] != TYPE_FLYING)) {
                if (sTypeMatchupMultipliers[chartEntry][1] == BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_1, NULL)
                    && BasicTypeMulApplies(battleCtx, attacker, defender, chartEntry) == TRUE) {
                    damage = ApplyTypeMultiplier(battleCtx, attacker, Sovereign_ChartMul(battleCtx, move, chartEntry), damage, movePower, moveStatusMask);

                    if (Sovereign_ChartMul(battleCtx, move, chartEntry) == TYPE_MULTI_SUPER_EFF) {
                        totalMul *= 2;
                    }
                }

                if (sTypeMatchupMultipliers[chartEntry][1] == BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_2, NULL)
                    && BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_1, NULL) != BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_2, NULL)
                    && BasicTypeMulApplies(battleCtx, attacker, defender, chartEntry) == TRUE) {
                    damage = ApplyTypeMultiplier(battleCtx, attacker, Sovereign_ChartMul(battleCtx, move, chartEntry), damage, movePower, moveStatusMask);

                    if (Sovereign_ChartMul(battleCtx, move, chartEntry) == TYPE_MULTI_SUPER_EFF) {
                        totalMul *= 2;
                    }
                }

                // Sovereign (item 11): the type Trick-or-Treat or Forest's Curse added.
                if (battleCtx->battleMons[defender].sovereignAddedType == sTypeMatchupMultipliers[chartEntry][1] + 1
                    && BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_1, NULL) != sTypeMatchupMultipliers[chartEntry][1]
                    && BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_2, NULL) != sTypeMatchupMultipliers[chartEntry][1]
                    && BasicTypeMulApplies(battleCtx, attacker, defender, chartEntry) == TRUE) {
                    damage = ApplyTypeMultiplier(battleCtx, attacker, Sovereign_ChartMul(battleCtx, move, chartEntry), damage, movePower, moveStatusMask);

                    if (Sovereign_ChartMul(battleCtx, move, chartEntry) == TYPE_MULTI_SUPER_EFF) {
                        totalMul *= 2;
                    }
                }
            }

            chartEntry++;
        }

        // Sovereign (item 11): Tar Shot makes Fire moves super effective once more against its target.
        if (moveType == TYPE_FIRE
            && (battleCtx->sovereignTarShot & FlagIndex(defender))
            && (*moveStatusMask & MOVE_STATUS_INEFFECTIVE) == FALSE) {
            damage = ApplyTypeMultiplier(battleCtx, attacker, TYPE_MULTI_SUPER_EFF, damage, movePower, moveStatusMask);
            totalMul *= 2;
        }

        // Sovereign (FM): Tera Shell. At full HP, a damaging move it isn't immune to is not very effective on it, for
        // every hit of a multi-hit move. Mold Breaker ignores it.
        if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_TERA_SHELL) == TRUE
            && movePower
            && (*moveStatusMask & MOVE_STATUS_INEFFECTIVE) == FALSE
            && (battleCtx->battleStatusMask & (SYSCTL_IGNORE_TYPE_CHECKS | SYSCTL_IGNORE_IMMUNITIES)) == FALSE) {
            BattleMon *shellMon = &battleCtx->battleMons[defender];
            BOOL shell = shellMon->curHP == shellMon->maxHP;

            // On the move being used, the first hit decides for the later ones.
            if (move == battleCtx->moveCur && attacker == battleCtx->attacker && defender == battleCtx->defender) {
                if (battleCtx->multiHitNumHits == 0 || battleCtx->multiHitCounter == battleCtx->multiHitNumHits) {
                    shellMon->sovereignTeraShell = shell;
                }

                shell = shellMon->sovereignTeraShell;
            }

            if (shell) {
                damage = BattleSystem_Divide(sovereignDamageBeforeChart * TYPE_MULTI_NOT_VERY_EFF, 10);
                *moveStatusMask &= ~MOVE_STATUS_SUPER_EFFECTIVE;
                *moveStatusMask |= MOVE_STATUS_NOT_VERY_EFFECTIVE;
            }
        }
    }

    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_WONDER_GUARD) == TRUE
        && MoveIsOnDamagingTurn(battleCtx, move)
        && ((*moveStatusMask & MOVE_STATUS_SUPER_EFFECTIVE) == FALSE
            || (*moveStatusMask & MOVE_STATUS_BASIC_EFFECTIVENESS) == MOVE_STATUS_BASIC_EFFECTIVENESS)
        && movePower) {
        *moveStatusMask |= MOVE_STATUS_WONDER_GUARD;
    } else if ((battleCtx->battleStatusMask & SYSCTL_IGNORE_TYPE_CHECKS) == FALSE
        && (battleCtx->battleStatusMask & SYSCTL_IGNORE_IMMUNITIES) == FALSE) {
        if ((*moveStatusMask & MOVE_STATUS_SUPER_EFFECTIVE) && movePower) {
            if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_FILTER) == TRUE
                || Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_SOLID_ROCK) == TRUE
                || Battler_Ability(battleCtx, defender) == ABILITY_PRISM_ARMOR) { // Sovereign (item 11)
                damage = BattleSystem_Divide(damage * 3, 4);
            }

            // Sovereign (item 11): Neuroforce powers up super-effective moves by 25%.
            if (Battler_Ability(battleCtx, attacker) == ABILITY_NEUROFORCE) {
                damage = damage * 5 / 4;
            }

            // Sovereign (item 11): Collision Course and Electro Drift are 1.33x when super effective.
            if (move == MOVE_COLLISION_COURSE || move == MOVE_ELECTRO_DRIFT) {
                damage = damage * 5461 / 4096;
            }

            if (attackerItemEffect == HOLD_EFFECT_POWER_UP_SE) {
                damage = damage * (100 + attackerItemPower) / 100;
            }
        }

        if ((*moveStatusMask & MOVE_STATUS_NOT_VERY_EFFECTIVE) && movePower) {
            if (Battler_Ability(battleCtx, attacker) == ABILITY_TINTED_LENS) {
                damage *= 2;
            }
        }
    } else {
        *moveStatusMask &= ~MOVE_STATUS_SUPER_EFFECTIVE;
        *moveStatusMask &= ~MOVE_STATUS_NOT_VERY_EFFECTIVE;
    }

    return damage;
}

// Sovereign (item 11): addedType is a type added by Trick-or-Treat or Forest's Curse, plus 1 (0 for none).
static void CalcEffectiveness(BattleContext *battleCtx, int move, int inType, int attackerAbility, int defenderAbility, int defenderItemEffect, int defenderType1, int defenderType2, int addedType, u32 *moveStatusMask)
{
    int chartEntry;
    u8 moveType;

    if (move == MOVE_STRUGGLE) {
        return;
    }

    moveType = Sovereign_AbilityMoveType(attackerAbility, move, inType ? inType : MOVE_DATA(move).type); // Sovereign (item 11)

    if (attackerAbility != ABILITY_MOLD_BREAKER && attackerAbility != ABILITY_TURBOBLAZE && attackerAbility != ABILITY_TERAVOLT
        && (defenderAbility == ABILITY_LEVITATE || defenderAbility == ABILITY_EELEVATE) // Sovereign (item 11)
        && moveType == TYPE_GROUND
        && (battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY) == FALSE
        && defenderItemEffect != HOLD_EFFECT_SPEED_DOWN_GROUNDED) {
        *moveStatusMask |= MOVE_STATUS_INEFFECTIVE;
    } else if (AbilityAbsorbsMove(attackerAbility, defenderAbility, moveType)) {
        // Sovereign (12b): the trainer AI's switch checks treat a move the target's ability absorbs as having no effect.
        *moveStatusMask |= MOVE_STATUS_INEFFECTIVE;
    } else {
        chartEntry = 0;

        while (sTypeMatchupMultipliers[chartEntry][0] != 0xFF) {
            if (sTypeMatchupMultipliers[chartEntry][0] == 0xFE) {
                if (attackerAbility == ABILITY_SCRAPPY || attackerAbility == ABILITY_MINDS_EYE) {
                    break;
                } else {
                    chartEntry++;
                    continue;
                }
            }

            if (sTypeMatchupMultipliers[chartEntry][0] == moveType) {
                if (sTypeMatchupMultipliers[chartEntry][1] == defenderType1
                    && NoImmunityOverrides(battleCtx, defenderItemEffect, chartEntry) == TRUE) {
                    UpateMoveStatusForTypeMul(Sovereign_ChartMul(battleCtx, move, chartEntry), moveStatusMask);
                }

                if (sTypeMatchupMultipliers[chartEntry][1] == defenderType2
                    && defenderType1 != defenderType2
                    && NoImmunityOverrides(battleCtx, defenderItemEffect, chartEntry) == TRUE) {
                    UpateMoveStatusForTypeMul(Sovereign_ChartMul(battleCtx, move, chartEntry), moveStatusMask);
                }

                // Sovereign (item 11): the added type.
                if (addedType == sTypeMatchupMultipliers[chartEntry][1] + 1
                    && defenderType1 != sTypeMatchupMultipliers[chartEntry][1]
                    && defenderType2 != sTypeMatchupMultipliers[chartEntry][1]
                    && NoImmunityOverrides(battleCtx, defenderItemEffect, chartEntry) == TRUE) {
                    UpateMoveStatusForTypeMul(Sovereign_ChartMul(battleCtx, move, chartEntry), moveStatusMask);
                }
            }

            chartEntry++;
        }
    }

    if (attackerAbility != ABILITY_MOLD_BREAKER && attackerAbility != ABILITY_TURBOBLAZE && attackerAbility != ABILITY_TERAVOLT
        && defenderAbility == ABILITY_WONDER_GUARD
        && MoveIsOnDamagingTurn(battleCtx, move)
        && ((*moveStatusMask & MOVE_STATUS_SUPER_EFFECTIVE) == FALSE
            || (*moveStatusMask & MOVE_STATUS_BASIC_EFFECTIVENESS) == MOVE_STATUS_BASIC_EFFECTIVENESS)) {
        *moveStatusMask |= MOVE_STATUS_INEFFECTIVE;
    }

    return;
}

void BattleSystem_CalcEffectiveness(BattleContext *battleCtx, int move, int inType, int attackerAbility, int defenderAbility, int defenderItemEffect, int defenderType1, int defenderType2, u32 *moveStatusMask)
{
    CalcEffectiveness(battleCtx, move, inType, attackerAbility, defenderAbility, defenderItemEffect, defenderType1, defenderType2, 0, moveStatusMask);
}

// Sovereign (item 11): BattleSystem_CalcEffectiveness against a battler in play, with its ability, held item and types,
// a type added by Trick-or-Treat or Forest's Curse included.
void Sovereign_CalcEffectivenessAgainst(BattleContext *battleCtx, int move, int inType, int attackerAbility, int defender, u32 *moveStatusMask)
{
    CalcEffectiveness(battleCtx,
        move,
        inType,
        attackerAbility,
        Battler_Ability(battleCtx, defender),
        Battler_HeldItemEffect(battleCtx, defender),
        BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_1, NULL),
        BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_2, NULL),
        battleCtx->battleMons[defender].sovereignAddedType,
        moveStatusMask);
}

// Sovereign (12b): whether an ability absorbs moves of this type (it heals, gets a boost or draws them in, and takes
// no damage). The trainer AI's checks use it.
BOOL Sovereign_AbilityAbsorbsMoveType(int ability, int moveType)
{
    switch (moveType) {
    case TYPE_ELECTRIC:
        return ability == ABILITY_VOLT_ABSORB || ability == ABILITY_MOTOR_DRIVE || ability == ABILITY_LIGHTNING_ROD;
    case TYPE_WATER:
        return ability == ABILITY_WATER_ABSORB || ability == ABILITY_DRY_SKIN || ability == ABILITY_STORM_DRAIN;
    case TYPE_FIRE:
        return ability == ABILITY_FLASH_FIRE || ability == ABILITY_WELL_BAKED_BODY;
    case TYPE_GRASS:
        return ability == ABILITY_SAP_SIPPER;
    case TYPE_GROUND:
        return ability == ABILITY_EARTH_EATER;
    }

    return FALSE;
}

// Sovereign (12b): the same, unless the attacker's Mold Breaker (or Turboblaze, Teravolt) ignores the ability.
static BOOL AbilityAbsorbsMove(int attackerAbility, int defenderAbility, int moveType)
{
    return attackerAbility != ABILITY_MOLD_BREAKER && attackerAbility != ABILITY_TURBOBLAZE && attackerAbility != ABILITY_TERAVOLT
        && Sovereign_AbilityAbsorbsMoveType(defenderAbility, moveType);
}

/**
 * @brief Determines if there are no immunity-overriding effects in play.
 *
 * This only checks for the basic immunity-overriding effects: Iron Ball
 * and Gravity for Ground-type attacks against  Flying-type Pokemon.
 *
 * @param battleCtx
 * @param itemEffect
 * @param chartEntry
 * @return TRUE if immunities should be respected, FALSE if not.
 */
static BOOL NoImmunityOverrides(BattleContext *battleCtx, int itemEffect, int chartEntry)
{
    BOOL result = TRUE;

    if (itemEffect == HOLD_EFFECT_SPEED_DOWN_GROUNDED
        && sTypeMatchupMultipliers[chartEntry][1] == TYPE_FLYING
        && sTypeMatchupMultipliers[chartEntry][2] == TYPE_MULTI_IMMUNE) {
        result = FALSE;
    }

    if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY)
        && sTypeMatchupMultipliers[chartEntry][1] == TYPE_FLYING
        && sTypeMatchupMultipliers[chartEntry][2] == TYPE_MULTI_IMMUNE) {
        result = FALSE;
    }

    return result;
}

/**
 * @brief Update the given move status mask according to a type multiplier.
 *
 * @param mul
 * @param moveStatusMask
 */
static void UpateMoveStatusForTypeMul(int mul, u32 *moveStatusMask)
{
    switch (mul) {
    case TYPE_MULTI_IMMUNE:
        *moveStatusMask |= MOVE_STATUS_INEFFECTIVE;
        *moveStatusMask &= ~MOVE_STATUS_NOT_VERY_EFFECTIVE;
        *moveStatusMask &= ~MOVE_STATUS_SUPER_EFFECTIVE;
        break;

    case TYPE_MULTI_NOT_VERY_EFF:
        if (*moveStatusMask & MOVE_STATUS_SUPER_EFFECTIVE) {
            *moveStatusMask &= ~MOVE_STATUS_SUPER_EFFECTIVE;
        } else {
            *moveStatusMask |= MOVE_STATUS_NOT_VERY_EFFECTIVE;
        }
        break;

    case TYPE_MULTI_SUPER_EFF:
        if (*moveStatusMask & MOVE_STATUS_NOT_VERY_EFFECTIVE) {
            *moveStatusMask &= ~MOVE_STATUS_NOT_VERY_EFFECTIVE;
        } else {
            *moveStatusMask |= MOVE_STATUS_SUPER_EFFECTIVE;
        }
        break;
    }
}

BOOL BattleContext_MoveFailed(BattleContext *battleCtx, int battler)
{
    if (battleCtx->moveFailFlags[battler].paralyzed
        || battleCtx->moveFailFlags[battler].noEffect
        || battleCtx->moveFailFlags[battler].imprisoned
        || battleCtx->moveFailFlags[battler].infatuated
        || battleCtx->moveFailFlags[battler].disabled
        || battleCtx->moveFailFlags[battler].taunted
        || battleCtx->moveFailFlags[battler].flinched
        || battleCtx->moveFailFlags[battler].gravity
        || battleCtx->moveFailFlags[battler].confused) {
        return TRUE;
    }

    return FALSE;
}

u8 BattleSystem_CountAliveBattlers(BattleSystem *battleSys, BattleContext *battleCtx, BOOL sameSide, int defender)
{
    u8 count = 0;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    // no clue why they used a switch statement for this, but changing it to an if-else doesn't match
    switch (sameSide) {
    case FALSE:
        for (int i = 0; i < maxBattlers; i++) {
            if (i != defender && battleCtx->battleMons[i].curHP) {
                count++;
            }
        }
        break;

    case TRUE:
        for (int i = 0; i < maxBattlers; i++) {
            if (BattleSystem_GetBattlerSide(battleSys, i) == BattleSystem_GetBattlerSide(battleSys, defender)
                && battleCtx->battleMons[i].curHP) {
                count++;
            }
        }
        break;
    }

    return count;
}

int BattleSystem_NicknameTag(BattleContext *battleSys, int battler)
{
    return battler | (Battler_SovereignShownPartySlot(battleSys, battler) << 8); // Sovereign (item 11): Illusion
}

// Sovereign (item 11): Illusion. A Pokémon with Illusion comes in disguised as the last Pokémon in its party's battle
// order (after its own position, as in Showdown) that isn't fainted. It shows that Pokémon's name, look and cry until a
// damaging move hits it or it loses the ability (BattleSystem_TriggerEffectOnSwitch). Called once the battler's party
// slot is in place (BattleSystem_SwitchSlots).
void Sovereign_SetIllusion(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    battleCtx->sovereignIllusion[battler] = 0;

    if (Battler_Ability(battleCtx, battler) != ABILITY_ILLUSION) {
        return;
    }

    // The same battle order and position as BattleSystem_SwitchSlots.
    u32 battleType = BattleSystem_GetBattleType(battleSys);
    int orderBattler = battler;
    int position = 0;

    if (((battleType & BATTLE_TYPE_DOUBLES) && (battleType & BATTLE_TYPE_2vs2_TAG) == FALSE)
        || ((battleType & BATTLE_TYPE_TAG) && (BattleSystem_GetBattlerType(battleSys, battler) & BATTLER_TYPE_SOLO_ENEMY) == FALSE)) {
        if (BattleSystem_GetBattlerType(battleSys, battler) == BATTLER_TYPE_PLAYER_SIDE_SLOT_2
            || BattleSystem_GetBattlerType(battleSys, battler) == BATTLER_TYPE_ENEMY_SIDE_SLOT_2) {
            position = 1;
        }

        orderBattler &= 1;
    }

    int count = BattleSystem_GetPartyCount(battleSys, battler);

    for (int i = MAX_PARTY_SIZE - 1; i > position; i--) {
        int slot = battleCtx->partyOrder[orderBattler][i];

        if (slot >= count) {
            continue;
        }

        Pokemon *mon = BattleSystem_GetPartyPokemon(battleSys, battler, slot);

        if (Pokemon_GetValue(mon, MON_DATA_SPECIES, NULL) != SPECIES_NONE
            && Pokemon_GetValue(mon, MON_DATA_IS_EGG, NULL) == FALSE
            && Pokemon_GetValue(mon, MON_DATA_HP, NULL)) {
            if (slot != battleCtx->selectedPartySlot[battler]) {
                battleCtx->sovereignIllusion[battler] = slot + 1;
            }

            break;
        }
    }
}

int Battler_SovereignShownPartySlot(BattleContext *battleCtx, int battler)
{
    if (battleCtx->sovereignIllusion[battler]) {
        return battleCtx->sovereignIllusion[battler] - 1;
    }

    return battleCtx->selectedPartySlot[battler];
}

u16 Battler_SelectedMove(BattleContext *battleCtx, int battler)
{
    u16 move = MOVE_NONE;

    if (battleCtx->battlerActions[battler][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_FIGHT
        && battleCtx->battlerActions[battler][BATTLE_ACTION_TEMP_VALUE]) {
        move = battleCtx->battleMons[battler].moves[battleCtx->battlerActions[battler][BATTLE_ACTION_TEMP_VALUE] - 1];
    }

    return move;
}

int BattleSystem_CountAbility(BattleSystem *battleSys, BattleContext *battleCtx, enum CountAbilityMode mode, int battler, int ability)
{
    int result = 0;
    int i;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    switch (mode) {
    case COUNT_ALL_BATTLERS_OUR_SIDE:
        for (i = 0; i < maxBattlers; i++) {
            if (BattleSystem_GetBattlerSide(battleSys, i) == BattleSystem_GetBattlerSide(battleSys, battler)
                && Battler_Ability(battleCtx, i) == ability) {
                result++;
            }
        }
        break;

    case COUNT_ALIVE_BATTLERS_OUR_SIDE:
        for (i = 0; i < maxBattlers; i++) {
            if (BattleSystem_GetBattlerSide(battleSys, i) == BattleSystem_GetBattlerSide(battleSys, battler)
                && battleCtx->battleMons[i].curHP
                && Battler_Ability(battleCtx, i) == ability) {
                result++;
            }
        }
        break;

    case COUNT_ALL_BATTLERS_THEIR_SIDE:
        for (i = 0; i < maxBattlers; i++) {
            if (BattleSystem_GetBattlerSide(battleSys, i) != BattleSystem_GetBattlerSide(battleSys, battler)
                && Battler_Ability(battleCtx, i) == ability) {
                result++;
            }
        }
        break;

    case COUNT_ALIVE_BATTLERS_THEIR_SIDE:
        for (i = 0; i < maxBattlers; i++) {
            if (BattleSystem_GetBattlerSide(battleSys, i) != BattleSystem_GetBattlerSide(battleSys, battler)
                && battleCtx->battleMons[i].curHP
                && Battler_Ability(battleCtx, i) == ability) {
                result++;
            }
        }
        break;

    case COUNT_ALIVE_BATTLERS_THEIR_SIDE_FLAG:
        for (i = 0; i < maxBattlers; i++) {
            if (BattleSystem_GetBattlerSide(battleSys, i) != BattleSystem_GetBattlerSide(battleSys, battler)
                && battleCtx->battleMons[i].curHP
                && Battler_Ability(battleCtx, i) == ability) {
                result |= FlagIndex(i);
            }
        }
        break;

    case COUNT_ALL_BATTLERS:
        for (i = 0; i < maxBattlers; i++) {
            if (Battler_Ability(battleCtx, i) == ability) {
                result++;
            }
        }
        break;

    case COUNT_ALL_BATTLERS_EXCEPT_ME:
        for (i = 0; i < maxBattlers; i++) {
            if (i != battler
                && Battler_Ability(battleCtx, i) == ability) {
                result++;
            }
        }
        break;

    case COUNT_ALL_BATTLERS_EXCEPT_ME_RETURN_BATTLER:
        for (i = 0; i < maxBattlers; i++) {
            if (i != battler
                && Battler_Ability(battleCtx, i) == ability) {
                result = i + 1;
                break;
            }
        }
        break;

    case COUNT_ALIVE_BATTLERS:
        for (i = 0; i < maxBattlers; i++) {
            if (Battler_Ability(battleCtx, i) == ability
                && battleCtx->battleMons[i].curHP) {
                result++;
            }
        }
        break;

    case COUNT_ALIVE_BATTLERS_EXCEPT_ME:
        for (i = 0; i < maxBattlers; i++) {
            if (i != battler
                && Battler_Ability(battleCtx, i) == ability
                && battleCtx->battleMons[i].curHP) {
                result++;
            }
        }
        break;
    }

    return result;
}

BOOL Move_IsMultiTurn(BattleContext *battleCtx, int move)
{
    switch (MOVE_DATA(move).effect) {
    case BATTLE_EFFECT_BIDE:
    case BATTLE_EFFECT_CHARGE_TURN_HIGH_CRIT:
    case BATTLE_EFFECT_CHARGE_TURN_HIGH_CRIT_FLINCH:
    case BATTLE_EFFECT_CHARGE_TURN_DEF_UP:
    case BATTLE_EFFECT_ELECTRO_SHOT: // Sovereign (item 11)
    case BATTLE_EFFECT_SOVEREIGN_CHARGE_TURN_HIT:
    case BATTLE_EFFECT_SOVEREIGN_GEOMANCY:
    case BATTLE_EFFECT_SOVEREIGN_SKY_DROP:
    case BATTLE_EFFECT_SKIP_CHARGE_TURN_IN_SUN:
    case BATTLE_EFFECT_FLY:
    case BATTLE_EFFECT_DIVE:
    case BATTLE_EFFECT_DIG:
    case BATTLE_EFFECT_BOUNCE:
    case BATTLE_EFFECT_SHADOW_FORCE:
        return TRUE;
    }

    return FALSE;
}

// Sovereign (item 11): Instruct works when the target's last move since it came in can be used again now: a move it
// still knows with PP left, and not one that charges, recharges, locks its user in, calls another move or the like
// (Gen IX's list).
BOOL Sovereign_CanInstruct(BattleContext *battleCtx, int target)
{
    int move = battleCtx->movePrevByBattler[target];
    int slot;

    if (move == MOVE_NONE || battleCtx->battleMons[target].curHP == 0) {
        return FALSE;
    }

    slot = Battler_SlotForMove(&battleCtx->battleMons[target], move);

    if (slot >= LEARNED_MOVES_MAX || battleCtx->battleMons[target].ppCur[slot] == 0 || Move_IsMultiTurn(battleCtx, move)) {
        return FALSE;
    }

    switch (MOVE_DATA(move).effect) {
    case BATTLE_EFFECT_RECHARGE_AFTER:
    case BATTLE_EFFECT_CONTINUE_AND_CONFUSE_SELF:
    case BATTLE_EFFECT_DOUBLE_POWER_EACH_TURN_LOCK_INTO:
    case BATTLE_EFFECT_UPROAR:
    case BATTLE_EFFECT_HIT_LAST_WHIFF_IF_HIT:
        return FALSE;
    }

    switch (move) {
    case MOVE_ASSIST:
    case MOVE_BEAK_BLAST:
    case MOVE_BELCH:
    case MOVE_COPYCAT:
    case MOVE_INSTRUCT:
    case MOVE_KINGS_SHIELD:
    case MOVE_ME_FIRST:
    case MOVE_METRONOME:
    case MOVE_MIMIC:
    case MOVE_MIRROR_MOVE:
    case MOVE_NATURE_POWER:
    case MOVE_OBSTRUCT:
    case MOVE_SHELL_TRAP:
    case MOVE_SKETCH:
    case MOVE_SKY_DROP:
    case MOVE_SLEEP_TALK:
    case MOVE_STRUGGLE:
    case MOVE_TRANSFORM:
        return FALSE;
    }

    return TRUE;
}

// Sovereign (item 11): the dance moves a Dancer copies (Gen IX's dance flag).
BOOL Sovereign_IsDanceMove(int move)
{
    switch (move) {
    case MOVE_AQUA_STEP:
    case MOVE_CLANGOROUS_SOUL:
    case MOVE_DRAGON_DANCE:
    case MOVE_FEATHER_DANCE:
    case MOVE_FIERY_DANCE:
    case MOVE_LUNAR_DANCE:
    case MOVE_PETAL_DANCE:
    case MOVE_QUIVER_DANCE:
    case MOVE_REVELATION_DANCE:
    case MOVE_SWORDS_DANCE:
    case MOVE_TEETER_DANCE:
    case MOVE_VICTORY_DANCE:
        return TRUE;
    }

    return FALSE;
}

BOOL BattleSystem_TypeMatchup(BattleSystem *battleSys, int idx, u8 *moveType, u8 *vsType, u8 *multi)
{
    BOOL result = TRUE;
    if (idx >= NELEMS(sTypeMatchupMultipliers)) {
        idx = BattleSystem_RandNext(battleSys) % NELEMS(sTypeMatchupMultipliers);
        result = FALSE;
    }

    *moveType = sTypeMatchupMultipliers[idx][0];
    *vsType = sTypeMatchupMultipliers[idx][1];
    *multi = sTypeMatchupMultipliers[idx][2];

    return result;
}

int BattleSystem_TypeMatchupMultiplier(u8 attackingType, u8 defendingType1, u8 defendingType2)
{
    int i = 0;
    int mul = 40;

    while (sTypeMatchupMultipliers[i][0] != 0xFF) {
        if (sTypeMatchupMultipliers[i][0] == attackingType) {
            if (sTypeMatchupMultipliers[i][1] == defendingType1) {
                mul = mul * sTypeMatchupMultipliers[i][2] / 10;
            }

            if (sTypeMatchupMultipliers[i][1] == defendingType2
                && defendingType1 != defendingType2) {
                mul = mul * sTypeMatchupMultipliers[i][2] / 10;
            }
        }

        i++;
    }

    return mul;
}

BOOL Move_IsInvoker(u16 move)
{
    // declaring this as a single return didn't match
    if (move == MOVE_NONE
        || move == MOVE_SLEEP_TALK
        || move == MOVE_COPYCAT
        || move == MOVE_ASSIST
        || move == MOVE_ME_FIRST
        || move == MOVE_MIRROR_MOVE
        || move == MOVE_METRONOME) {
        return TRUE;
    }

    return FALSE;
}

BOOL Move_IsGhostCurse(BattleContext *battleCtx, u16 move, int battler)
{
    return move == MOVE_CURSE && MON_HAS_TYPE(battler, TYPE_GHOST);
}

BOOL BattleSystem_CanStealItem(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    BOOL result = FALSE;
    int side = BattleSystem_GetBattlerSide(battleSys, battler);

    if (battleCtx->battleMons[battler].heldItem
        && (battleCtx->sideConditions[side].knockedOffItemsMask & FlagIndex(battleCtx->selectedPartySlot[battler])) == FALSE
        && Item_IsMail(battleCtx->battleMons[battler].heldItem) == FALSE) {
        result = TRUE;
    }

    return result;
}

// Sovereign (FM): the battler holds an item that changes its form (a Mega Stone, Orb, Rusted Sword, mask...), so it
// can't be knocked off, stolen, swapped or flung (Pokemon_SovereignItemIsLocked).
BOOL Battler_SovereignHeldItemLocked(BattleContext *battleCtx, int battler)
{
    return Pokemon_SovereignItemIsLocked(battleCtx->battleMons[battler].species, battleCtx->battleMons[battler].heldItem);
}

BOOL BattleSystem_NotHoldingMail(BattleContext *battleCtx, int battler)
{
    return Item_IsMail(battleCtx->battleMons[battler].heldItem) == FALSE;
}

BOOL BattleSystem_CanWhirlwind(BattleSystem *battleSys, BattleContext *battleCtx)
{
    // Sovereign: no level check in a trainer battle, and in a wild one it fails only when the user's level is lower
    // (Gen V+). Platinum rolled a random chance to fail in both whenever the user's level was lower.
    if (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_TRAINER) {
        return TRUE;
    }

    return ATTACKING_MON.level >= DEFENDING_MON.level;
}

// Sovereign (item 11): TRUE while a Pokémon in battle has Neutralizing Gas, not itself suppressed (Gastro Acid).
BOOL Sovereign_NeutralizingGasActive(BattleContext *battleCtx)
{
    for (int i = 0; i < MAX_BATTLERS; i++) {
        if (battleCtx->battleMons[i].curHP
            && battleCtx->battleMons[i].ability == ABILITY_NEUTRALIZING_GAS
            && (battleCtx->battleMons[i].moveEffectsMask & MOVE_EFFECT_ABILITY_SUPPRESSED) == FALSE) {
            return TRUE;
        }
    }

    return FALSE;
}

u16 Battler_Ability(BattleContext *battleCtx, int battler)
{
    if ((battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_ABILITY_SUPPRESSED)
        && Sovereign_AbilityCantBeSuppressed(battleCtx->battleMons[battler].ability) == FALSE) { // Sovereign (item 11)
        return ABILITY_NONE;
    }

    // Sovereign (item 11): Neutralizing Gas suppresses every other ability in battle, but not another Neutralizing Gas,
    // an ability that can't be suppressed or an Ability Shield holder's. (Empty battler slots have no HP.)
    if (battleCtx->battleMons[battler].ability != ABILITY_NEUTRALIZING_GAS
        && Sovereign_AbilityCantBeSuppressed(battleCtx->battleMons[battler].ability) == FALSE
        && Sovereign_HasAbilityShield(battleCtx, battler) == FALSE
        && Sovereign_NeutralizingGasActive(battleCtx)) {
        return ABILITY_NONE;
    }

    if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY)
        && (battleCtx->battleMons[battler].ability == ABILITY_LEVITATE || battleCtx->battleMons[battler].ability == ABILITY_EELEVATE)) {
        return ABILITY_NONE;
    }

    if ((battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_INGRAIN)
        && (battleCtx->battleMons[battler].ability == ABILITY_LEVITATE || battleCtx->battleMons[battler].ability == ABILITY_EELEVATE)) {
        return ABILITY_NONE;
    }

    return battleCtx->battleMons[battler].ability;
}

// Sovereign (item 11): Mold Breaker, Turboblaze and Teravolt ignore the target's ability; Mycelium Might does too, for
// the user's status moves.
BOOL Sovereign_IsMoldBreaker(BattleContext *battleCtx, int battler)
{
    int ability = Battler_Ability(battleCtx, battler);

    if (ability == ABILITY_MOLD_BREAKER || ability == ABILITY_TURBOBLAZE || ability == ABILITY_TERAVOLT) {
        return TRUE;
    }

    // Sunsteel Strike, Moongeist Beam and Photon Geyser ignore the target's ability too.
    if (battleCtx->attacker == battler
        && (battleCtx->moveCur == MOVE_SUNSTEEL_STRIKE || battleCtx->moveCur == MOVE_MOONGEIST_BEAM
            || battleCtx->moveCur == MOVE_PHOTON_GEYSER)) {
        return TRUE;
    }

    return ability == ABILITY_MYCELIUM_MIGHT
        && battleCtx->attacker == battler
        && MOVE_DATA(battleCtx->moveCur).class == CLASS_STATUS;
}

// Sovereign (item 11): TRUE while the battler holds an Ability Shield: its Ability can't be changed, suppressed or
// ignored (Mold Breaker). Klutz doesn't stop it; Magic Room and Embargo do.
BOOL Sovereign_HasAbilityShield(BattleContext *battleCtx, int battler)
{
    return battleCtx->battleMons[battler].heldItem == ITEM_ABILITY_SHIELD
        && battleCtx->sovereignMagicRoomTurns == 0
        && battleCtx->battleMons[battler].moveEffectsData.embargoTurns == 0;
}

BOOL Battler_IgnorableAbility(BattleContext *battleCtx, int attacker, int defender, int ability)
{
    BOOL result = FALSE;

#ifdef SOVEREIGN_TEST
    // Test build only: in god mode the player's moves ignore the foes' abilities, as with Mold Breaker, so Wonder
    // Guard and the like can't hold up a test battle (include/sovereign_test.h).
    if (gSovereignTestGodMode && (attacker & 1) == BATTLE_SIDE_PLAYER && (defender & 1) == BATTLE_SIDE_ENEMY) {
        return FALSE;
    }
#endif

    if (Sovereign_IsMoldBreaker(battleCtx, attacker) == FALSE
        || Sovereign_HasAbilityShield(battleCtx, defender)) { // Sovereign (item 11)
        if (Battler_Ability(battleCtx, defender) == ability) {
            result = TRUE;
        }
    } else if (Battler_Ability(battleCtx, defender) == ability
        && battleCtx->selfTurnFlags[attacker].moldBreakerActivated == FALSE) {
        battleCtx->selfTurnFlags[attacker].moldBreakerActivated = TRUE;
        battleCtx->battleStatusMask |= SYSCTL_APPLY_MOLD_BREAKER;
    }

    return result;
}

BOOL BattleSystem_AnyReplacementMons(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    // Declarations here are done C89-style to match.
    BOOL result;
    Party *party;
    Pokemon *mon;
    int partySize;
    int aliveMons = 0, neededAliveMons;
    int start, end;
    int selectedSlot1, selectedSlot2;
    u32 battleType;

    result = FALSE;
    battleType = BattleSystem_GetBattleType(battleSys);
    party = BattleSystem_GetParty(battleSys, battler);
    partySize = BattleSystem_GetPartyCount(battleSys, battler);

    if ((battleType & BATTLE_TYPE_2vs2)
        || ((battleType & BATTLE_TYPE_TAG)
            && (BattleSystem_GetBattlerType(battleSys, battler) & BATTLER_THEM))) {
        // have to copy these 4 identical assignments across each branch to match
        start = 0;
        end = partySize;
        neededAliveMons = 1;
        selectedSlot1 = battleCtx->selectedPartySlot[battler];
        selectedSlot2 = battleCtx->selectedPartySlot[battler];
    } else if (battleType & BATTLE_TYPE_DOUBLES) {
        start = 0;
        end = partySize;
        neededAliveMons = 1;
        selectedSlot1 = battleCtx->selectedPartySlot[battler];
        selectedSlot2 = battleCtx->selectedPartySlot[BattleSystem_GetPartner(battleSys, battler)];
    } else {
        start = 0;
        end = partySize;
        neededAliveMons = 1;
        selectedSlot1 = battleCtx->selectedPartySlot[battler];
        selectedSlot2 = battleCtx->selectedPartySlot[battler];
    }

    for (int i = start; i < end; i++) {
        mon = Party_GetPokemonBySlotIndex(party, i);
        if (Pokemon_GetValue(mon, MON_DATA_SPECIES, NULL)
            && Pokemon_GetValue(mon, MON_DATA_IS_EGG, NULL) == FALSE
            && Pokemon_GetValue(mon, MON_DATA_HP, NULL)
            && selectedSlot1 != i
            && selectedSlot2 != i) {
            aliveMons++;
        }
    }

    if (aliveMons >= neededAliveMons) {
        result = TRUE;
    }

    return result;
}

BOOL Battler_IsTrappedMsg(BattleSystem *battleSys, BattleContext *battleCtx, int battler, BattleMessage *msgOut)
{
    int tmp;
    int maxBattlers;
    u8 side;
    int itemEffect;
    u32 battleType = BattleSystem_GetBattleType(battleSys);
    itemEffect = Battler_HeldItemEffect(battleCtx, battler);

    // Sovereign (item 11): Commander. The Tatsugiri in its ally Dondozo's mouth and that Dondozo can't leave at all
    // (Shed Shell, Run Away or a Ghost type doesn't help).
    if ((battleCtx->sovereignCommanding | battleCtx->sovereignCommanded) & FlagIndex(battler)) {
        if (msgOut != NULL) {
            msgOut->tags = TAG_NONE;
            msgOut->id = BattleStrings_Text_CantEscape2; // "Can't escape!"
        }

        return TRUE;
    }

    // Sovereign (item 11): a Pokemon carried up by Sky Drop can't leave either (Showdown traps it outright).
    if (Sovereign_SkyDropHolder(battleCtx, battler) != BATTLER_NONE) {
        if (msgOut != NULL) {
            msgOut->tags = TAG_NICKNAME;
            msgOut->id = BattleStrings_Text_SovereignSkyDropWontLetGo_Ally; // "Sky Drop won't let {0} go!"
            msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, battler);
        }

        return TRUE;
    }

    if (itemEffect == HOLD_EFFECT_FLEE
        || (battleType & BATTLE_TYPE_NO_EXPERIENCE)
        || Battler_Ability(battleCtx, battler) == ABILITY_RUN_AWAY
        || MON_HAS_TYPE(battler, TYPE_GHOST)) { // Sovereign (item 11): since Gen VI, nothing traps a Ghost type
        return FALSE;
    }

    side = BattleSystem_GetBattlerSide(battleSys, battler);
    maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    if ((tmp = BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_EXCEPT_ME, battler, ABILITY_SHADOW_TAG))
        && Battler_Ability(battleCtx, battler) != ABILITY_SHADOW_TAG) {
        if (msgOut == NULL) {
            return TRUE;
        }

        msgOut->tags = TAG_NICKNAME_ABILITY;
        msgOut->id = BattleStrings_Text_PokemonPreventsEscapeWithAbility_Ally; // "{0} prevents escape with {1}!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, tmp);
        msgOut->params[1] = ABILITY_SHADOW_TAG;
        return TRUE;
    }

    if ((tmp = BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_THEIR_SIDE, battler, ABILITY_ARENA_TRAP))) {
        if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY) == FALSE && itemEffect != HOLD_EFFECT_SPEED_DOWN_GROUNDED) {
            if (Battler_Ability(battleCtx, battler) != ABILITY_LEVITATE
                && Battler_Ability(battleCtx, battler) != ABILITY_EELEVATE // Sovereign (item 11)
                && battleCtx->battleMons[battler].moveEffectsData.magnetRiseTurns == 0
                && battleCtx->sovereignTelekinesis[battler] == 0 // Sovereign (item 11)
                && Battler_HeldItem(battleCtx, battler) != ITEM_AIR_BALLOON // Sovereign (item 11)
                && MON_IS_NOT_TYPE(battler, TYPE_FLYING)) {
                if (msgOut == NULL) {
                    return TRUE;
                }

                msgOut->tags = TAG_NICKNAME_ABILITY;
                msgOut->id = BattleStrings_Text_PokemonPreventsEscapeWithAbility_Ally; // "{0} prevents escape with {1}!"
                msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, tmp);
                msgOut->params[1] = ABILITY_ARENA_TRAP;
                return TRUE;
            }
        } else {
            if (msgOut == NULL) {
                return TRUE;
            }

            msgOut->tags = TAG_NICKNAME_ABILITY;
            msgOut->id = BattleStrings_Text_PokemonPreventsEscapeWithAbility_Ally; // "{0} prevents escape with {1}!"
            msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, tmp);
            msgOut->params[1] = ABILITY_ARENA_TRAP;
            return TRUE;
        }
    }

    if ((tmp = BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_THEIR_SIDE, battler, ABILITY_MAGNET_PULL))
        && MON_HAS_TYPE(battler, TYPE_STEEL)) {
        if (msgOut == NULL) {
            return TRUE;
        }

        msgOut->tags = TAG_NICKNAME_ABILITY;
        msgOut->id = BattleStrings_Text_PokemonPreventsEscapeWithAbility_Ally; // "{0} prevents escape with {1}!"
        msgOut->params[0] = BattleSystem_NicknameTag(battleCtx, tmp);
        msgOut->params[1] = ABILITY_MAGNET_PULL;
        return TRUE;
    }

    if ((battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_TRAPPED)
        || (battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_INGRAIN)
        || battleCtx->sovereignFairyLock) { // Sovereign (item 11)
        if (msgOut == NULL) {
            return TRUE;
        }

        msgOut->tags = TAG_NONE;
        msgOut->id = BattleStrings_Text_CantEscape2; // "Can't escape!"
        return TRUE;
    }

    return FALSE;
}

BOOL Battler_CanEscape(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    u32 battleType = BattleSystem_GetBattleType(battleSys);
    int itemEffect = Battler_HeldItemEffect(battleCtx, battler);
    BOOL result = FALSE;

    if (itemEffect == HOLD_EFFECT_FLEE) {
        battleCtx->turnFlags[battler].fleeing = 1;
        result = TRUE;
    } else if (battleType & BATTLE_TYPE_NO_EXPERIENCE) {
        result = TRUE;
    } else if (Battler_Ability(battleCtx, battler) == ABILITY_RUN_AWAY) {
        battleCtx->turnFlags[battler].fleeing = 2;
        result = TRUE;
    } else {
        if (battleCtx->battleMons[battler].speed < battleCtx->battleMons[battler ^ 1].speed) {
            u8 escape = battleCtx->battleMons[battler].speed * 128 / battleCtx->battleMons[battler ^ 1].speed + battleCtx->runAttempts * 30;

            if (escape > BattleSystem_RandNext(battleSys) % 256) {
                result = TRUE;
            }
        } else {
            result = TRUE;
        }

        if (result == FALSE) {
            BattleController_EmitIncrementRecord(battleSys, battler, 0, RECORD_FAILED_ESCAPE);
        }

        battleCtx->runAttempts++;
    }

    return result;
}

BOOL Battler_CheckTruant(BattleContext *battleCtx, int battler)
{
    BOOL result = FALSE;

    if (Battler_Ability(battleCtx, battler) == ABILITY_TRUANT
        && battleCtx->battleMons[battler].moveEffectsData.truant != (battleCtx->totalTurns & 1)) {
        result = TRUE;
    }

    return result;
}

BOOL Move_Imprisoned(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int move)
{
    // must declare C89-style to match
    int i, maxBattlers, side, j;
    BOOL result = FALSE;
    maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    side = BattleSystem_GetBattlerSide(battleSys, battler);

    for (i = 0; i < maxBattlers; i++) {
        if (side != BattleSystem_GetBattlerSide(battleSys, i)
            && (battleCtx->battleMons[i].moveEffectsMask & MOVE_EFFECT_IMPRISON)) {
            for (j = 0; j < LEARNED_MOVES_MAX; j++) {
                if (move == battleCtx->battleMons[i].moves[j]) {
                    break;
                }
            }

            if (j != LEARNED_MOVES_MAX) {
                result = TRUE;
            }
        }
    }

    return result;
}

BOOL BattleSystem_AnyBattlersWithMoveEffect(BattleSystem *battleSys, BattleContext *battleCtx, int effectMask)
{
    BOOL result = FALSE;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    for (int i = 0; i < maxBattlers; i++) {
        if (battleCtx->battleMons[i].moveEffectsMask & effectMask) {
            result = TRUE;
            break;
        }
    }

    return result;
}

void BattleSystem_SetupLoop(BattleSystem *battleSys, BattleContext *battleCtx)
{
    battleCtx->moveStatusFlags = 0;
    battleCtx->criticalMul = 1;
    battleCtx->battleStatusMask &= ~SYSCTL_REUSE_LAST_MOVE;
}

void BattleSystem_SortMonSpeedOrder(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    for (int i = 0; i < maxBattlers; i++) {
        battleCtx->monSpeedOrder[i] = i;
    }

    for (int j = 0; j < maxBattlers - 1; j++) {
        for (int k = j + 1; k < maxBattlers; k++) {
            int mon1 = battleCtx->monSpeedOrder[j];
            int mon2 = battleCtx->monSpeedOrder[k];

            if (BattleSystem_CompareBattlerSpeed(battleSys, battleCtx, mon1, mon2, TRUE)) {
                battleCtx->monSpeedOrder[j] = mon2;
                battleCtx->monSpeedOrder[k] = mon1;
            }
        }
    }
}

static const u16 sMovesAffectedByGravity[] = {
    MOVE_FLY,
    MOVE_BOUNCE,
    MOVE_SKY_DROP, // Sovereign (item 11)
    MOVE_JUMP_KICK,
    MOVE_HI_JUMP_KICK,
    MOVE_SPLASH,
    MOVE_MAGNET_RISE,
    MOVE_FLYING_PRESS, // Sovereign: Gen VI+
    MOVE_TELEKINESIS, // Sovereign: Gen V+
};

BOOL Move_FailsInHighGravity(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int move)
{
    BOOL result = FALSE;

    if (battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY) {
        for (int i = 0; i < NELEMS(sMovesAffectedByGravity); i++) {
            if (sMovesAffectedByGravity[i] == move) {
                result = TRUE;
                break;
            }
        }
    }

    return result;
}

// Sovereign (item 11): healing moves (Gen IX's heal flag), given +3 priority by Triage and blocked by Heal Block (Gen VI+:
// the drain moves and the later healing moves too).
static const u16 sHealingMoves[] = {
    MOVE_ABSORB, MOVE_MEGA_DRAIN, MOVE_GIGA_DRAIN, MOVE_DRAIN_PUNCH, MOVE_DRAINING_KISS, MOVE_HORN_LEECH,
    MOVE_LEECH_LIFE, MOVE_OBLIVION_WING, MOVE_PARABOLIC_CHARGE, MOVE_DREAM_EATER, MOVE_BITTER_BLADE,
    MOVE_MATCHA_GOTCHA, MOVE_RECOVER, MOVE_ROOST, MOVE_REST, MOVE_SLACK_OFF, MOVE_SOFTBOILED, MOVE_MILK_DRINK,
    MOVE_MOONLIGHT, MOVE_MORNING_SUN, MOVE_SYNTHESIS, MOVE_HEAL_ORDER, MOVE_WISH, MOVE_SWALLOW, MOVE_HEAL_PULSE,
    MOVE_FLORAL_HEALING, MOVE_SHORE_UP, MOVE_STRENGTH_SAP, MOVE_LIFE_DEW, MOVE_JUNGLE_HEALING, MOVE_LUNAR_BLESSING,
    MOVE_HEALING_WISH, MOVE_LUNAR_DANCE, MOVE_PURIFY, MOVE_BOUNCY_BUBBLE,
};

// Sovereign: Heal Block stops every way a Pokemon restores HP (Gen V+; Showdown's TryHeal event), not only the healing
// moves: its HP Berries aren't eaten, Leftovers, Black Sludge and Shell Bell restore nothing, and healing abilities
// don't heal.
BOOL Sovereign_HealBlocked(BattleContext *battleCtx, int battler)
{
    return battleCtx->battleMons[battler].moveEffectsData.healBlockTurns != 0;
}

// Sovereign: the subscripts by which a Berry or held item restores HP.
static BOOL Sovereign_IsHPRestoreSubscript(int subscript)
{
    return subscript == subscript_held_item_hp_restore
        || subscript == subscript_held_item_dislike_flavor
        || subscript == subscript_restore_a_little_hp;
}

BOOL Move_HealBlocked(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int move)
{
    BOOL result = FALSE;

    if (battleCtx->battleMons[battler].moveEffectsData.healBlockTurns) {
        for (int i = 0; i < NELEMS(sHealingMoves); i++) {
            if (sHealingMoves[i] == move) {
                result = TRUE;
                break;
            }
        }
    }

    return result;
}

void BattleSystem_UpdateLastResort(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (battleCtx->moveTemp == MOVE_LAST_RESORT
        || ATTACKING_MON.moveEffectsData.lastResortCount == 4) {
        return;
    }

    int i;
    for (i = 0; i < ATTACKING_MON.moveEffectsData.lastResortCount; i++) {
        if (ATTACKING_MON.moveEffectsData.lastResortMoves[i] == battleCtx->moveTemp) {
            return;
        }
    }

    ATTACKING_MON.moveEffectsData.lastResortMoves[i] = battleCtx->moveTemp;
    ATTACKING_MON.moveEffectsData.lastResortCount++;
}

int Battler_CountMoves(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    int i;
    for (i = 0; i < LEARNED_MOVES_MAX; i++) {
        if (battleCtx->battleMons[battler].moves[i] == MOVE_NONE) {
            break;
        }
    }

    return i;
}

static u16 sSoundMoves[] = {
    MOVE_GROWL,
    MOVE_ROAR,
    MOVE_SING,
    MOVE_SUPERSONIC,
    MOVE_SCREECH,
    MOVE_SNORE,
    MOVE_UPROAR,
    MOVE_METAL_SOUND,
    MOVE_GRASS_WHISTLE,
    MOVE_HYPER_VOICE,
    MOVE_BUG_BUZZ,
    MOVE_CHATTER,
    // Sovereign (item 11): Gen V+ sound moves.
    MOVE_ROUND,
    MOVE_ECHOED_VOICE,
    MOVE_RELIC_SONG,
    MOVE_SNARL,
    MOVE_NOBLE_ROAR,
    MOVE_DISARMING_VOICE,
    MOVE_PARTING_SHOT,
    MOVE_BOOMBURST,
    MOVE_CONFIDE,
    MOVE_SPARKLING_ARIA,
    MOVE_CLANGING_SCALES,
    MOVE_CLANGOROUS_SOUL,
    MOVE_OVERDRIVE,
    MOVE_EERIE_SPELL,
    MOVE_TORCH_SONG,
    MOVE_ALLURING_VOICE,
    MOVE_PSYCHIC_NOISE,
    MOVE_HEAL_BELL, // Gen IX counts these three too (Throat Chop, Throat Spray, Liquid Voice)
    MOVE_HOWL,
    MOVE_PERISH_SONG,
    MOVE_DRAGON_CHEER, // Pokémon Champions
};

// Sovereign (item 11): sound moves (Soundproof, Punk Rock).
BOOL Move_IsSound(int move)
{
    for (int i = 0; i < NELEMS(sSoundMoves); i++) {
        if (sSoundMoves[i] == move) {
            return TRUE;
        }
    }

    return FALSE;
}

// Sovereign (item 11): wind moves (Wind Rider, Wind Power), as Gen IX flags them.
static const u16 sWindMoves[] = {
    MOVE_AEROBLAST,
    MOVE_AIR_CUTTER,
    MOVE_BLEAKWIND_STORM,
    MOVE_BLIZZARD,
    MOVE_FAIRY_WIND,
    MOVE_GUST,
    MOVE_HEAT_WAVE,
    MOVE_HURRICANE,
    MOVE_ICY_WIND,
    MOVE_PETAL_BLIZZARD,
    MOVE_SANDSEAR_STORM,
    MOVE_SANDSTORM,
    MOVE_SPRINGTIDE_STORM,
    MOVE_TAILWIND,
    MOVE_TWISTER,
    MOVE_WHIRLWIND,
    MOVE_WILDBOLT_STORM,
};

BOOL Move_IsWind(int move)
{
    for (int i = 0; i < NELEMS(sWindMoves); i++) {
        if (sWindMoves[i] == move) {
            return TRUE;
        }
    }

    return FALSE;
}

// Sovereign (item 11): sound moves (Gen VI+) and Infiltrator get past a Substitute.
BOOL Sovereign_BypassesSubstitute(BattleContext *battleCtx, int attacker, int defender, int move)
{
    return attacker != defender && (Move_IsSound(move) || Battler_Ability(battleCtx, attacker) == ABILITY_INFILTRATOR);
}

// Sovereign: TRUE for a move that has a flinch chance of its own, which King's Rock, Razor Fang and Stench don't add to.
BOOL Sovereign_MoveHasFlinchChance(BattleContext *battleCtx, int move)
{
    switch (MOVE_DATA(move).effect) {
    case BATTLE_EFFECT_FLINCH_HIT:
    case BATTLE_EFFECT_CHARGE_TURN_HIGH_CRIT_FLINCH:
    case BATTLE_EFFECT_DAMAGE_WHILE_ASLEEP:
    case BATTLE_EFFECT_ALWAYS_FLINCH_FIRST_TURN_ONLY:
    case BATTLE_EFFECT_FLINCH_DOUBLE_DAMAGE_FLY_OR_BOUNCE:
    case BATTLE_EFFECT_FLINCH_MINIMIZE_DOUBLE_HIT:
    case BATTLE_EFFECT_FLINCH_BURN_HIT:
    case BATTLE_EFFECT_FLINCH_FREEZE_HIT:
    case BATTLE_EFFECT_FLINCH_PARALYZE_HIT:
    case BATTLE_EFFECT_SOVEREIGN_TRIPLE_ARROWS:
        return TRUE;
    }

    return FALSE;
}

// Sovereign: moves whose own rule sets their type. Normalize and the -ate abilities leave them alone (Gen VII+).
BOOL Sovereign_MoveSetsOwnType(int move)
{
    switch (move) {
    case MOVE_STRUGGLE:
    case MOVE_HIDDEN_POWER:
    case MOVE_WEATHER_BALL:
    case MOVE_NATURAL_GIFT:
    case MOVE_JUDGMENT:
    case MOVE_TECHNO_BLAST:
    case MOVE_REVELATION_DANCE:
    case MOVE_MULTI_ATTACK:
    case MOVE_TERRAIN_PULSE:
        return TRUE;
    }

    return FALSE;
}

// Sovereign (item 11): a move's type after its user's ability. Normalize makes every move Normal-type; Pixilate,
// Refrigerate, Aerilate, Galvanize and Dragonize turn Normal-type moves into their type; Liquid Voice makes sound moves
// Water-type. Struggle and the moves that set their own type (Weather Ball, Judgment...) keep it, except for Liquid
// Voice (as in Gen VII+).
int Sovereign_AbilityMoveType(int ability, int move, int type)
{
    if (move == MOVE_STRUGGLE || (ability != ABILITY_LIQUID_VOICE && Sovereign_MoveSetsOwnType(move))) {
        return type;
    }

    switch (ability) {
    case ABILITY_NORMALIZE:
        return TYPE_NORMAL;
    case ABILITY_PIXILATE:
        return type == TYPE_NORMAL ? TYPE_FAIRY : type;
    case ABILITY_REFRIGERATE:
        return type == TYPE_NORMAL ? TYPE_ICE : type;
    case ABILITY_AERILATE:
        return type == TYPE_NORMAL ? TYPE_FLYING : type;
    case ABILITY_GALVANIZE:
        return type == TYPE_NORMAL ? TYPE_ELECTRIC : type;
    case ABILITY_DRAGONIZE:
        return type == TYPE_NORMAL ? TYPE_DRAGON : type;
    case ABILITY_LIQUID_VOICE:
        return Move_IsSound(move) ? TYPE_WATER : type;
    }

    return type;
}


int BattleSystem_TriggerImmunityAbility(BattleContext *battleCtx, int attacker, int defender)
{
    int subscript = NULL, moveType;

    moveType = Sovereign_AbilityMoveType(Battler_Ability(battleCtx, attacker), battleCtx->moveCur, battleCtx->moveType ? battleCtx->moveType : CURRENT_MOVE_DATA.type); // Sovereign (item 11)
    moveType = Sovereign_ElectrifyType(battleCtx, attacker, battleCtx->moveCur, moveType);

    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_VOLT_ABSORB) == TRUE
        && moveType == TYPE_ELECTRIC
        && attacker != defender) {
        battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[defender].maxHP, 4);
        subscript = subscript_ability_restores_hp;
    }

    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_WATER_ABSORB) == TRUE
        && moveType == TYPE_WATER
        && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE // do not proc on first turn of Dive
        && CURRENT_MOVE_DATA.power) {
        battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[defender].maxHP, 4);
        subscript = subscript_ability_restores_hp;
    }

    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_FLASH_FIRE) == TRUE
        && moveType == TYPE_FIRE
        && (battleCtx->battleMons[defender].status & MON_CONDITION_FREEZE) == FALSE
        && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
        && (CURRENT_MOVE_DATA.power || battleCtx->moveCur == MOVE_WILL_O_WISP)) {
        subscript = subscript_absorb_and_boost_fire_type_moves;
    }

    // Sovereign (item 11): not the user's own moves (Clangorous Soul, Howl, Heal Bell, Perish Song), as in Gen V+
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_SOUNDPROOF) == TRUE && attacker != defender) {
        for (int i = 0; i < NELEMS(sSoundMoves); i++) {
            if (sSoundMoves[i] == battleCtx->moveCur) {
                subscript = subscript_blocked_by_soundproof;
                break;
            }
        }
    }

    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_MOTOR_DRIVE) == TRUE
        && moveType == TYPE_ELECTRIC
        && attacker != defender) {
        subscript = subscript_absorb_and_speed_up_1_stage;
    }

    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_DRY_SKIN) == TRUE
        && moveType == TYPE_WATER
        && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
        && CURRENT_MOVE_DATA.power) {
        battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[defender].maxHP, 4);
        subscript = subscript_ability_restores_hp;
    }

    // Sovereign (item 11): the Gen V+ absorbing abilities. Storm Drain and Lightning Rod already draw single-target
    // moves of their type in Platinum; since Gen V the holder also absorbs them. None trigger on the user's own move
    // or on the first turn of a two-turn move.
    if (attacker != defender && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE) {
        if ((Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_STORM_DRAIN) == TRUE && moveType == TYPE_WATER)
            || (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_LIGHTNING_ROD) == TRUE && moveType == TYPE_ELECTRIC)) {
            subscript = subscript_sovereign_absorb_and_sp_atk_up_1_stage;
        }

        if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_SAP_SIPPER) == TRUE && moveType == TYPE_GRASS) {
            subscript = subscript_sovereign_absorb_and_atk_up_1_stage;
        }

        // Wind Rider takes no harm from wind moves aimed at it, and its Attack rises instead.
        if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_WIND_RIDER) == TRUE && Move_IsWind(battleCtx->moveCur)) {
            subscript = subscript_sovereign_absorb_and_atk_up_1_stage;
        }

        if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_WELL_BAKED_BODY) == TRUE && moveType == TYPE_FIRE) {
            subscript = subscript_sovereign_absorb_and_def_up_2_stages;
        }

        if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_EARTH_EATER) == TRUE && moveType == TYPE_GROUND) {
            battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[defender].maxHP, 4);
            subscript = subscript_ability_restores_hp;
        }
    }

    return subscript;
}

// Sovereign (FM): the form its HP gives a Pokémon with Schooling or Shields Down now, or -1 if that's its form
// already, or neither applies.
//   Schooling: a Wishiwashi is in School Form at level 20 or more with over 1/4 of its HP, else Solo.
//   Shields Down: a Minior is in its color's Meteor Form with over half its HP, else its Core.
static int BattleSystem_SovereignHPForm(BattleContext *battleCtx, int battler)
{
    BattleMon *mon = &battleCtx->battleMons[battler];
    int ability = Battler_Ability(battleCtx, battler);
    int form = -1;

    if (mon->curHP == 0 || (mon->statusVolatile & VOLATILE_CONDITION_TRANSFORM)) {
        return -1;
    }

    if (mon->species == SPECIES_WISHIWASHI && ability == ABILITY_SCHOOLING) {
        form = 0;
        if (mon->level >= 20 && mon->curHP > mon->maxHP / 4) {
            form = Pokemon_SovereignAbilityForm(mon->species, 0, ABILITY_SCHOOLING);
        }
    } else if (mon->species == SPECIES_MINIOR && ability == ABILITY_SHIELDS_DOWN) {
        // A Core goes back to its own color's Meteor Form.
        form = Battler_SovereignShieldsUp(battleCtx, battler) ? mon->formNum : Pokemon_SovereignBattleFormBase(mon->species, mon->formNum);
        if (mon->curHP <= mon->maxHP / 2) {
            form = Pokemon_SovereignAbilityForm(mon->species, form, ABILITY_SHIELDS_DOWN);
        }
    }

    return form >= 0 && form != mon->formNum ? form : -1;
}

// Sovereign (FM): TRUE for a Minior in Meteor Form with Shields Down. Its shell keeps off every status condition and
// Yawn, and Mold Breaker can't get past it. (A Core's form is a Shields Down battle form; a Meteor Form isn't.)
BOOL Battler_SovereignShieldsUp(BattleContext *battleCtx, int battler)
{
    BattleMon *mon = &battleCtx->battleMons[battler];

    return mon->species == SPECIES_MINIOR && mon->curHP
        && (mon->statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE
        && Battler_Ability(battleCtx, battler) == ABILITY_SHIELDS_DOWN
        && Pokemon_SovereignAbilityForm(mon->species, mon->formNum, ABILITY_SHIELDS_DOWN) >= 0;
}

// Sovereign (item 11): TRUE when the attacker's move gets past the target side's Safeguard and Mist: Infiltrator,
// against a foe. Not for an Ability's or item's effect, nor for entry hazards (whose attacker is whoever moved last).
BOOL Sovereign_Infiltrates(BattleSystem *battleSys, BattleContext *battleCtx, int target)
{
    return battleCtx->sovereignInHazards == FALSE
        && (battleCtx->sideEffectType == SIDE_EFFECT_TYPE_DIRECT || battleCtx->sideEffectType == SIDE_EFFECT_TYPE_INDIRECT)
        && Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_INFILTRATOR
        && BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker) != BattleSystem_GetBattlerSide(battleSys, target);
}

// Sovereign (item 11): TRUE when the battler's moves lock it into the first one it uses, as long as it stays in: a
// Choice item, or Gorilla Tactics.
BOOL Battler_SovereignChoiceLocks(BattleContext *battleCtx, int battler)
{
    int itemEffect = Battler_HeldItemEffect(battleCtx, battler);

    return itemEffect == HOLD_EFFECT_CHOICE_ATK
        || itemEffect == HOLD_EFFECT_CHOICE_SPEED
        || itemEffect == HOLD_EFFECT_CHOICE_SPATK
        || Battler_Ability(battleCtx, battler) == ABILITY_GORILLA_TACTICS;
}

// Sovereign (item 11): TRUE when nothing can give the battler a status condition (nor make it drowsy): Shields Down's
// shell, Comatose, or Purifying Salt. Mold Breaker gets past Purifying Salt when another battler's move would give the status;
// a held item (Flame Orb) or the battler's own move (Rest) never does.
BOOL Battler_SovereignStatusImmune(BattleContext *battleCtx, int battler)
{
    // Comatose: the holder is always as if asleep, so nothing gives it a status condition (not even through Mold
    // Breaker).
    if (Battler_SovereignShieldsUp(battleCtx, battler) || Battler_Ability(battleCtx, battler) == ABILITY_COMATOSE) {
        return TRUE;
    }

    if (Battler_Ability(battleCtx, battler) != ABILITY_PURIFYING_SALT) {
        return FALSE;
    }

    if (battleCtx->sideEffectType == SIDE_EFFECT_TYPE_HELD_ITEM || battleCtx->attacker == battler) {
        return TRUE;
    }

    return Battler_IgnorableAbility(battleCtx, battleCtx->attacker, battler, ABILITY_PURIFYING_SALT);
}

// Sovereign (item 11): the Pokemon whose veil (Sweet Veil, Pastel Veil, Flower Veil or Aroma Veil) guards the battler:
// the battler itself or, in a double battle, its partner while it's in. BATTLER_NONE when neither has it. The
// attacker's Mold Breaker gets past it (BATTLER_NONE when no move is what would harm the battler).
int Sovereign_VeilHolder(BattleSystem *battleSys, BattleContext *battleCtx, int attacker, int battler, int ability)
{
    int partner = BattleSystem_GetPartner(battleSys, battler);

    if (attacker == BATTLER_NONE ? Battler_Ability(battleCtx, battler) == ability
                                 : Battler_IgnorableAbility(battleCtx, attacker, battler, ability) == TRUE) {
        return battler;
    }

    if (partner != battler
        && battleCtx->battleMons[partner].curHP
        && (attacker == BATTLER_NONE ? Battler_Ability(battleCtx, partner) == ability
                                     : Battler_IgnorableAbility(battleCtx, attacker, partner, ability) == TRUE)) {
        return partner;
    }

    return BATTLER_NONE;
}

// Sovereign (item 11): for the status subscripts, the veil (Sovereign_VeilHolder) guarding the side-effect target, with
// the attacker's Mold Breaker getting past it when the attacker's move gives the condition.
BOOL Sovereign_SideEffectVeil(BattleSystem *battleSys, BattleContext *battleCtx, int ability)
{
    int attacker = battleCtx->sideEffectType == SIDE_EFFECT_TYPE_DIRECT || battleCtx->sideEffectType == SIDE_EFFECT_TYPE_INDIRECT
        ? battleCtx->attacker
        : BATTLER_NONE;

    return Sovereign_VeilHolder(battleSys, battleCtx, attacker, battleCtx->sideEffectMon, ability) != BATTLER_NONE;
}

// Sovereign (item 11): TRUE when Flower Veil keeps another Pokemon from giving the side-effect target, a Grass type, a
// status condition or drowsiness: not one it gives itself (Rest, a Flame Orb).
BOOL Sovereign_FlowerVeilGuards(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int battler = battleCtx->sideEffectMon;

    if (MON_IS_NOT_TYPE(battler, TYPE_GRASS)
        || battleCtx->sideEffectType == SIDE_EFFECT_TYPE_HELD_ITEM
        || ((battleCtx->sideEffectType == SIDE_EFFECT_TYPE_DIRECT || battleCtx->sideEffectType == SIDE_EFFECT_TYPE_INDIRECT)
            && battleCtx->attacker == battler)) {
        return FALSE;
    }

    return Sovereign_SideEffectVeil(battleSys, battleCtx, ABILITY_FLOWER_VEIL);
}

// Sovereign (item 11): TRUE when Aroma Veil keeps the attacker's move off the defender: Attract, Disable, Encore, Heal
// Block, Taunt or Torment.
BOOL Sovereign_AromaVeilBlocks(BattleSystem *battleSys, BattleContext *battleCtx, int attacker, int defender, int move)
{
    return attacker != defender
        && defender != BATTLER_NONE
        && (move == MOVE_ATTRACT
            || move == MOVE_DISABLE
            || move == MOVE_ENCORE
            || move == MOVE_HEAL_BLOCK
            || move == MOVE_TAUNT
            || move == MOVE_TORMENT)
        && Sovereign_VeilHolder(battleSys, battleCtx, attacker, defender, ABILITY_AROMA_VEIL) != BATTLER_NONE;
}

static BOOL BattleSystem_FeedBerryToAttacker(BattleSystem *battleSys, BattleContext *battleCtx, int battler, BOOL stuffCheeks);

BOOL BattleSystem_TriggerTurnEndAbility(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    BOOL result = FALSE;
    int subscript;

    switch (Battler_Ability(battleCtx, battler)) {
    // Sovereign (FM): Schooling forms a school and Shields Down drops or raises Minior's shell at the end of each turn
    // (and on entry: BattleSystem_TriggerFormChange).
    case ABILITY_SCHOOLING:
    case ABILITY_SHIELDS_DOWN: {
        int form = BattleSystem_SovereignHPForm(battleCtx, battler);

        if (form >= 0) {
            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battler, form);
            battleCtx->msgBattlerTemp = battler;
            subscript = subscript_form_change;
            result = TRUE;
        }
        break;
    }

    // Sovereign (FM): Power Construct makes a 10% or 50% Zygarde Complete at the end of a turn at half its HP or less.
    // Its max HP rises and its HP rises by as much (subscript_sovereign_power_construct). It stays Complete until the
    // battle ends, switching out too.
    case ABILITY_POWER_CONSTRUCT: {
        BattleMon *mon = &battleCtx->battleMons[battler];
        int form = Pokemon_SovereignAbilityForm(mon->species, mon->formNum, ABILITY_POWER_CONSTRUCT);

        if (form >= 0 && mon->curHP && mon->curHP <= mon->maxHP / 2 && (mon->statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE) {
            int oldMaxHP = mon->maxHP;

            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battler, form);
            battleCtx->msgBattlerTemp = battler;
            battleCtx->hpCalcTemp = mon->maxHP - oldMaxHP;
            subscript = subscript_sovereign_power_construct;
            result = TRUE;
        }
        break;
    }

    // Sovereign (item 11): Harvest grows back the Berry the holder used up, at the end of half the turns (of every turn
    // in harsh sunlight).
    case ABILITY_HARVEST:
        if (battleCtx->battleMons[battler].curHP
            && battleCtx->battleMons[battler].heldItem == ITEM_NONE
            && Item_IsBerry(battleCtx->recycleItem[battler])
            && (((battleCtx->fieldConditionsMask & FIELD_CONDITION_SUNNY)
                    && BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALL_BATTLERS, 0, ABILITY_CLOUD_NINE) == 0
                    && BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALL_BATTLERS, 0, ABILITY_AIR_LOCK) == 0)
                || BattleSystem_RandNext(battleSys) % 2 == 0)) {
            battleCtx->battleMons[battler].heldItem = battleCtx->recycleItem[battler];
            battleCtx->recycleItem[battler] = ITEM_NONE;
            BattleMon_CopyToParty(battleSys, battleCtx, battler);
            battleCtx->msgBattlerTemp = battler;
            battleCtx->msgItemTemp = battleCtx->battleMons[battler].heldItem;
            subscript = subscript_sovereign_harvest;
            result = TRUE;
        }
        break;

    // Sovereign: Pickup picks up an item another Pokemon on the field used up this turn, at the end of the turn while it
    // holds nothing (Gen V+); a random one when there are more. That item can't be Recycled any more. Platinum's Pickup
    // did nothing in battle.
    case ABILITY_PICKUP:
        if (battleCtx->battleMons[battler].curHP && battleCtx->battleMons[battler].heldItem == ITEM_NONE) {
            int found[MAX_BATTLERS];
            int count = 0;

            for (int i = 0; i < BattleSystem_GetMaxBattlers(battleSys); i++) {
                if (i != battler
                    && battleCtx->battleMons[i].curHP
                    && battleCtx->turnFlags[i].sovereignItemUsed
                    && battleCtx->recycleItem[i] != ITEM_NONE) {
                    found[count++] = i;
                }
            }

            if (count) {
                int from = found[BattleSystem_RandNext(battleSys) % count];

                battleCtx->battleMons[battler].heldItem = battleCtx->recycleItem[from];
                battleCtx->recycleItem[from] = ITEM_NONE;
                battleCtx->turnFlags[from].sovereignItemUsed = FALSE;
                BattleMon_CopyToParty(battleSys, battleCtx, battler);
                battleCtx->msgBattlerTemp = battler;
                battleCtx->msgItemTemp = battleCtx->battleMons[battler].heldItem;
                subscript = subscript_sovereign_pickup;
                result = TRUE;
            }
        }
        break;

    // Sovereign (item 11): Ball Fetch picks up the first ball thrown in a wild battle, which failed to catch (the battle
    // would be over otherwise), at the end of a turn while it holds nothing. Once per battle; the player's side only.
    case ABILITY_BALL_FETCH:
        if (battleCtx->battleMons[battler].curHP
            && battleCtx->battleMons[battler].heldItem == ITEM_NONE
            && battleCtx->sovereignBallFetchBall != ITEM_NONE
            && battleCtx->sovereignBallFetched == FALSE
            && BattleSystem_GetBattlerSide(battleSys, battler) == BATTLE_SIDE_PLAYER) {
            battleCtx->sovereignBallFetched = TRUE;
            battleCtx->battleMons[battler].heldItem = battleCtx->sovereignBallFetchBall;
            BattleMon_CopyToParty(battleSys, battleCtx, battler);
            battleCtx->msgBattlerTemp = battler;
            battleCtx->msgItemTemp = battleCtx->sovereignBallFetchBall;
            subscript = subscript_sovereign_ball_fetch;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Cud Chew eats the Berry its holder ate (BtlCmd_RemoveItem) again, at the end of the next
    // turn: the end of a later turn than the one it was eaten in. It eats it as Stuff Cheeks does, with the holder as the
    // eater, whatever it holds now.
    case ABILITY_CUD_CHEW:
        if (battleCtx->battleMons[battler].curHP
            && battleCtx->sovereignCudChewBerry[battler] != ITEM_NONE
            && battleCtx->sovereignCudChewTurn[battler] < battleCtx->totalTurns) {
            u16 heldItem = battleCtx->battleMons[battler].heldItem;

            battleCtx->battleMons[battler].heldItem = battleCtx->sovereignCudChewBerry[battler];
            battleCtx->sovereignCudChewBerry[battler] = ITEM_NONE;
            battleCtx->attacker = battler;
            BattleSystem_FeedBerryToAttacker(battleSys, battleCtx, battler, TRUE);
            battleCtx->battleMons[battler].heldItem = heldItem;
            BattleMon_CopyToParty(battleSys, battleCtx, battler);
            battleCtx->msgBattlerTemp = battler;
            subscript = subscript_sovereign_cud_chew;
            result = TRUE;
        }
        break;

    // Sovereign (FM): Hunger Switch takes Morpeko between its Full Belly and Hangry Modes at the end of each turn.
    case ABILITY_HUNGER_SWITCH: {
        BattleMon *mon = &battleCtx->battleMons[battler];
        int hangryForm = Pokemon_SovereignAbilityForm(mon->species, 0, ABILITY_HUNGER_SWITCH);

        if (hangryForm >= 0 && mon->curHP && (mon->statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE) {
            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battler, mon->formNum == 0 ? hangryForm : 0);
            battleCtx->msgBattlerTemp = battler;
            subscript = subscript_form_change;
            result = TRUE;
        }
        break;
    }

    // Sovereign (FM): Zen Mode turns Darmanitan to its Zen Mode at half its HP or less, and back above half.
    case ABILITY_ZEN_MODE: {
        BattleMon *mon = &battleCtx->battleMons[battler];
        int form = -1;

        if (mon->curHP && mon->species == SPECIES_DARMANITAN && (mon->statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE) {
            if (mon->curHP <= mon->maxHP / 2) {
                form = Pokemon_SovereignAbilityForm(mon->species, mon->formNum, ABILITY_ZEN_MODE);
            } else if (Pokemon_IsSovereignBattleForm(mon->species, mon->formNum)) {
                form = Pokemon_SovereignBattleFormBase(mon->species, mon->formNum);
            }
        }

        if (form >= 0) {
            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battler, form);
            battleCtx->msgBattlerTemp = battler;
            subscript = subscript_form_change;
            result = TRUE;
        }
        break;
    }

    case ABILITY_SPEED_BOOST:
        if (battleCtx->battleMons[battler].curHP
            && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_SPEED] < MAX_STAT_STAGE
            && battleCtx->battleMons[battler].moveEffectsData.fakeOutTurnNumber != battleCtx->totalTurns + 1) {
            battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_SPEED_UP_1_STAGE;
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battler;
            subscript = subscript_update_stat_stage;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Moody raises a random stat 2 stages and lowers a different one 1 stage (Attack, Defense,
    // Speed, Sp. Atk and Sp. Def, as in Gen VIII+).
    case ABILITY_MOODY:
        if (battleCtx->battleMons[battler].curHP) {
            int up = -1, down = -1, count = 0, pick, stat;

            for (stat = BATTLE_STAT_ATTACK; stat <= BATTLE_STAT_SP_DEFENSE; stat++) {
                if (battleCtx->battleMons[battler].statBoosts[stat] < MAX_STAT_STAGE) {
                    count++;
                }
            }

            if (count) {
                pick = BattleSystem_RandNext(battleSys) % count;
                for (stat = BATTLE_STAT_ATTACK; stat <= BATTLE_STAT_SP_DEFENSE; stat++) {
                    if (battleCtx->battleMons[battler].statBoosts[stat] < MAX_STAT_STAGE && pick-- == 0) {
                        up = stat;
                        break;
                    }
                }
            }

            count = 0;
            for (stat = BATTLE_STAT_ATTACK; stat <= BATTLE_STAT_SP_DEFENSE; stat++) {
                if (stat != up && battleCtx->battleMons[battler].statBoosts[stat] > 0) {
                    count++;
                }
            }

            if (count) {
                pick = BattleSystem_RandNext(battleSys) % count;
                for (stat = BATTLE_STAT_ATTACK; stat <= BATTLE_STAT_SP_DEFENSE; stat++) {
                    if (stat != up && battleCtx->battleMons[battler].statBoosts[stat] > 0 && pick-- == 0) {
                        down = stat;
                        break;
                    }
                }
            }

            if (up >= 0 && down >= 0) {
                battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_ATTACK_UP_2_STAGES + (up - BATTLE_STAT_ATTACK);
                battleCtx->calcTemp = MOVE_SUBSCRIPT_PTR_ATTACK_DOWN_1_STAGE + (down - BATTLE_STAT_ATTACK);
                battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
                battleCtx->sideEffectMon = battler;
                subscript = subscript_sovereign_moody;
                result = TRUE;
            } else if (up >= 0) {
                battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_ATTACK_UP_2_STAGES + (up - BATTLE_STAT_ATTACK);
                battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
                battleCtx->sideEffectMon = battler;
                subscript = subscript_update_stat_stage;
                result = TRUE;
            }
        }
        break;

    // Sovereign (item 11): Healer has a 50% chance each turn to cure its ally's status condition (Pokemon Champions;
    // 30% in Gen V-IX).
    case ABILITY_HEALER:
        if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES)
            && battleCtx->battleMons[battler].curHP
            && battleCtx->battleMons[battler ^ 2].curHP
            && (battleCtx->battleMons[battler ^ 2].status & MON_CONDITION_ANY)
            && BattleSystem_RandNext(battleSys) % 10 < 5) {
            battleCtx->msgBattlerTemp = battler ^ 2;
            battleCtx->sideEffectMon = battler;
            subscript = subscript_sovereign_healer;
            result = TRUE;
        }
        break;

    case ABILITY_SHED_SKIN:
        if ((battleCtx->battleMons[battler].status & MON_CONDITION_ANY)
            && battleCtx->battleMons[battler].curHP
            && BattleSystem_RandNext(battleSys) % 100 < 33) { // Sovereign: 33% (Gen V+), was 30%
            if (battleCtx->battleMons[battler].status & MON_CONDITION_SLEEP) {
                battleCtx->msgTemp = MSGCOND_SLEEP;
            } else if (battleCtx->battleMons[battler].status & MON_CONDITION_ANY_POISON) {
                battleCtx->msgTemp = MSGCOND_POISON;
            } else if (battleCtx->battleMons[battler].status & MON_CONDITION_BURN) {
                battleCtx->msgTemp = MSGCOND_BURN;
            } else if (battleCtx->battleMons[battler].status & MON_CONDITION_PARALYSIS) {
                battleCtx->msgTemp = MSGCOND_PARALYSIS;
            } else {
                battleCtx->msgTemp = MSGCOND_FREEZE;
            }

            battleCtx->msgBattlerTemp = battler;
            subscript = subscript_ability_restore_status;
            result = TRUE;
        }
        break;
    }

    if (result == TRUE) {
        LOAD_SUBSEQ(subscript);
        battleCtx->commandNext = battleCtx->command;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    }

    return result;
}

int BattleSystem_Divide(int dividend, int divisor)
{
    if (dividend == 0) {
        return dividend;
    }

    int signedFloor;
    if (dividend < 0) {
        signedFloor = -1;
    } else {
        signedFloor = 1;
    }

    dividend /= divisor;

    if (dividend == 0) {
        dividend = signedFloor;
    }

    return dividend;
}

enum SwitchInCheckState {
    SWITCH_IN_CHECK_STATE_START = 0,

    SWITCH_IN_CHECK_STATE_FIELD_WEATHER = SWITCH_IN_CHECK_STATE_START,
    SWITCH_IN_CHECK_STATE_SOVEREIGN_NEUTRALIZING_GAS, // Sovereign (item 11)
    SWITCH_IN_CHECK_STATE_SOVEREIGN_SYMBIOSIS, // Sovereign (item 11)
    SWITCH_IN_CHECK_STATE_SOVEREIGN_ILLUSION, // Sovereign (item 11)
    SWITCH_IN_CHECK_STATE_SOVEREIGN_COMMANDER, // Sovereign (item 11)
    SWITCH_IN_CHECK_STATE_SOVEREIGN_SKY_DROP, // Sovereign (item 11)
    SWITCH_IN_CHECK_STATE_SOVEREIGN_PRIMAL, // Sovereign (E8)
    SWITCH_IN_CHECK_STATE_SOVEREIGN_TOTEM_AURA, // Sovereign (decision 18)
    SWITCH_IN_CHECK_STATE_TRACE,
    SWITCH_IN_CHECK_STATE_SOVEREIGN_PRIMAL_WEATHER_END,
    SWITCH_IN_CHECK_STATE_WEATHER_ABILITIES,
    SWITCH_IN_CHECK_STATE_INTIMIDATE,
    SWITCH_IN_CHECK_STATE_SOVEREIGN_STAT_DROP_REACTION,
    SWITCH_IN_CHECK_STATE_SOVEREIGN_BOOSTER_ENERGY,
    SWITCH_IN_CHECK_STATE_SOVEREIGN_TERRAIN_SEED,
    SWITCH_IN_CHECK_STATE_DOWNLOAD,
    SWITCH_IN_CHECK_STATE_SOVEREIGN_ENTRY_BOOSTS,
    SWITCH_IN_CHECK_STATE_ANTICIPATION,
    SWITCH_IN_CHECK_STATE_FOREWARN,
    SWITCH_IN_CHECK_STATE_FRISK,
    SWITCH_IN_CHECK_STATE_SLOW_START,
    SWITCH_IN_CHECK_STATE_MOLD_BREAKER,
    SWITCH_IN_CHECK_STATE_PRESSURE,
    SWITCH_IN_CHECK_STATE_FORM_CHANGE,
    SWITCH_IN_CHECK_STATE_AMULET_COIN,
    SWITCH_IN_CHECK_STATE_FORBIDDEN_STATUS,
    SWITCH_IN_CHECK_STATE_HELD_ITEM_STATUS,
    SWITCH_IN_CHECK_STATE_SOVEREIGN_EMERGENCY_EXIT, // Sovereign (item 11)
    SWITCH_IN_CHECK_STATE_SOVEREIGN_EJECT_PACK, // Sovereign (item 11)

    SWITCH_IN_CHECK_STATE_DONE,
};

enum SwitchInCheckResult {
    SWITCH_IN_CHECK_RESULT_CONTINUE = 0,
    SWITCH_IN_CHECK_RESULT_BREAK,
    SWITCH_IN_CHECK_RESULT_DONE,
};

// Sovereign (item 11): Commander. TRUE when a Tatsugiri with Commander, in a double battle, has a Dondozo for an ally
// that no Tatsugiri commands yet, neither of them switching (not a Pokemon transformed into either).
static BOOL Sovereign_CanCommand(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    int dondozo = BattleSystem_GetPartner(battleSys, battler);

    if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES) == FALSE
        || dondozo == battler
        || battleCtx->battleMons[battler].curHP == 0
        || battleCtx->battleMons[dondozo].curHP == 0
        || ((battleCtx->battlersSwitchingMask | battleCtx->sovereignCommanded) & FlagIndex(dondozo))
        || (battleCtx->battlersSwitchingMask & FlagIndex(battler))
        || Battler_Ability(battleCtx, battler) != ABILITY_COMMANDER
        || battleCtx->battleMons[battler].species != SPECIES_TATSUGIRI
        || battleCtx->battleMons[dondozo].species != SPECIES_DONDOZO
        || (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_TRANSFORM)
        || (battleCtx->battleMons[dondozo].statusVolatile & VOLATILE_CONDITION_TRANSFORM)) {
        return FALSE;
    }

    return TRUE;
}

// Sovereign (item 11): Commander. The Tatsugiri goes into its ally Dondozo's mouth: it can't act or be hit (it still takes
// indirect damage), and neither can leave. The Dondozo's Attack, Defense, Sp. Atk, Sp. Def and Speed rise by 2, and
// Order Up raises its Attack (Curly Form), Defense (Droopy) or Speed (Stretchy). The Tatsugiri's action this turn, if
// still to come, is cancelled. subscript_sovereign_commander shows it (MSG_BATTLER_TEMP, SIDE_EFFECT_MON).
static void Sovereign_StartCommander(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    static const u8 sOrderUpStats[] = { BATTLE_STAT_ATTACK, BATTLE_STAT_DEFENSE, BATTLE_STAT_SPEED };
    static const u8 sBoostedStats[] = { BATTLE_STAT_ATTACK, BATTLE_STAT_DEFENSE, BATTLE_STAT_SP_ATTACK, BATTLE_STAT_SP_DEFENSE, BATTLE_STAT_SPEED };
    int dondozo = BattleSystem_GetPartner(battleSys, battler);

    battleCtx->sovereignCommanding |= FlagIndex(battler);
    battleCtx->sovereignCommanded |= FlagIndex(dondozo);
    battleCtx->sovereignOrderUpStat[dondozo] = sOrderUpStats[battleCtx->battleMons[battler].formNum % 3];
    battleCtx->battlerActions[battler][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_MOVE_END;

    for (int i = 0; i < NELEMS(sBoostedStats); i++) {
        s8 *boost = &battleCtx->battleMons[dondozo].statBoosts[sBoostedStats[i]];

        *boost = (*boost + 2 > MAX_STAT_STAGE) ? MAX_STAT_STAGE : *boost + 2;
    }

    battleCtx->msgBattlerTemp = battler;
    battleCtx->sideEffectMon = dondozo;
}

int BattleSystem_TriggerEffectOnSwitch(BattleSystem *battleSys, BattleContext *battleCtx)
{
    // must declare C89-style to match
    int i;
    int subscript;
    int result;
    int battler;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    subscript = NULL;
    result = SWITCH_IN_CHECK_RESULT_CONTINUE;

    do {
        switch (battleCtx->switchInCheckState) {
        case SWITCH_IN_CHECK_STATE_FIELD_WEATHER:
            if (battleCtx->fieldWeatherChecked == FALSE) {
                switch (BattleSystem_GetFieldWeather(battleSys)) {
                case OVERWORLD_WEATHER_RAINING:
                case OVERWORLD_WEATHER_HEAVY_RAIN:
                case OVERWORLD_WEATHER_THUNDERSTORM:
                    subscript = subscript_overworld_rain;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;

                case OVERWORLD_WEATHER_SNOWING:
                case OVERWORLD_WEATHER_HEAVY_SNOW:
                case OVERWORLD_WEATHER_BLIZZARD:
                    subscript = subscript_overworld_hail;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;

                case OVERWORLD_WEATHER_SANDSTORM:
                    subscript = subscript_overworld_sand;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;

                case OVERWORLD_WEATHER_FOG:
                case OVERWORLD_WEATHER_DEEP_FOG:
                    subscript = subscript_overworld_fog;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;

                case OVERWORLD_WEATHER_HARSH_SUN:
                    subscript = subscript_overworld_sun;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;

                case OVERWORLD_WEATHER_TRICK_ROOM:
                    subscript = subscript_overworld_trick_room;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;

                default:
                    break;
                }

                if (result == SWITCH_IN_CHECK_RESULT_BREAK) {
                    battleCtx->fieldWeatherChecked = TRUE;
                }
            }

            battleCtx->switchInCheckState++;
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_NEUTRALIZING_GAS:
            // Sovereign (item 11): Neutralizing Gas is announced as its user comes in, before any other entry ability.
            // When the last one leaves, faints or loses it, its end is announced, and the states below then run the
            // entry abilities it held back (they only mark themselves announced once they run).
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].sovereignGasAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_NEUTRALIZING_GAS) {
                    battleCtx->battleMons[battler].sovereignGasAnnounced = TRUE;
                    battleCtx->sovereignGasActive = TRUE;
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_sovereign_neutralizing_gas;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                if (battleCtx->sovereignGasActive && Sovereign_NeutralizingGasActive(battleCtx) == FALSE) {
                    battleCtx->sovereignGasActive = FALSE;
                    subscript = subscript_sovereign_neutralizing_gas_end;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                }

                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_SYMBIOSIS:
            // Sovereign (item 11): a Symbiosis pass made while the script stack was full (BtlCmd_RemoveItem).
            battleCtx->switchInCheckState++;

            if (battleCtx->sovereignSymbiosisPending) {
                battleCtx->sovereignSymbiosisPending = FALSE;
                subscript = subscript_sovereign_symbiosis;
                result = SWITCH_IN_CHECK_RESULT_BREAK;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_ILLUSION:
            // Sovereign (item 11): an Illusion Pokémon that lost the ability (Gastro Acid, Worry Seed, Mummy, Neutralizing
            // Gas...) shows as itself again (subscript_sovereign_illusion_end). A fainted one keeps its look to the end.
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->sovereignIllusion[battler]
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) != ABILITY_ILLUSION) {
                    battleCtx->sovereignIllusion[battler] = 0;
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_sovereign_illusion_end;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_COMMANDER:
            // Sovereign (item 11): Commander, in a double battle. A Tatsugiri whose ally is a Dondozo goes into its mouth
            // (Sovereign_StartCommander). It comes back out when that Dondozo faints.
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->sovereignCommanding & FlagIndex(battler)) {
                    int dondozo = BattleSystem_GetPartner(battleSys, battler);

                    if (battleCtx->battleMons[battler].curHP == 0) {
                        battleCtx->sovereignCommanding &= ~FlagIndex(battler);
                    } else if (battleCtx->battleMons[dondozo].curHP == 0
                        || (battleCtx->sovereignCommanded & FlagIndex(dondozo)) == FALSE) { // fainted, maybe replaced already
                        battleCtx->sovereignCommanding &= ~FlagIndex(battler);
                        battleCtx->msgBattlerTemp = battler;
                        subscript = subscript_sovereign_commander_end;
                        result = SWITCH_IN_CHECK_RESULT_BREAK;
                        break;
                    }
                } else if (Sovereign_CanCommand(battleSys, battleCtx, battler)) {
                    Sovereign_StartCommander(battleSys, battleCtx, battler);
                    subscript = subscript_sovereign_commander;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_SKY_DROP:
            // Sovereign (item 11): a Pokemon carried up by Sky Drop is let go when the user faints, leaves or comes down
            // without dropping it (full paralysis, Gravity), as in Showdown. One that fainted up there just leaves the
            // user to land on its turn.
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];
                int holder = battleCtx->sovereignSkyDropHolder[battler] - 1;

                if (holder < 0) {
                    continue;
                }

                if (battleCtx->battleMons[battler].curHP == 0) {
                    Sovereign_SkyDropLetGo(battleCtx, holder, battler);
                } else if (Sovereign_SkyDropHolder(battleCtx, battler) == BATTLER_NONE
                    || battleCtx->battleMons[holder].curHP == 0
                    || (battleCtx->battleMons[holder].moveEffectsMask & MOVE_EFFECT_AIRBORNE) == FALSE) {
                    Sovereign_SkyDropLetGo(battleCtx, holder, battler);
                    battleCtx->battleMons[battler].moveEffectsTemp &= ~MOVE_EFFECT_SEMI_INVULNERABLE;
                    battleCtx->sideEffectMon = battler;
                    subscript = subscript_sovereign_sky_drop_freed;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_PRIMAL:
            // Sovereign (E8): Kyogre holding the Blue Orb and Groudon holding the Red Orb revert as they come in, before
            // weather abilities, with no button or Mega Ring (docs/MegaEvolution.md).
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];
                BattleMon *mon = &battleCtx->battleMons[battler];

                if (mon->curHP && mon->formNum == 0 && (mon->statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE) {
                    int form = Pokemon_SovereignBattleForm(mon->species, mon->formNum, mon->heldItem, mon->moves, TRUE);

                    if (form) {
                        BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battler, form);
                        battleCtx->msgBattlerTemp = battler;
                        subscript = subscript_sovereign_primal_reversion;
                        result = SWITCH_IN_CHECK_RESULT_BREAK;
                        break;
                    }
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_TOTEM_AURA:
            // Sovereign (decision 18): once, at the start of a Totem trial, the Totem's aura raises its stats. The Totem
            // leads the wild party, so it starts in the first enemy slot.
            if (battleCtx->sovereignTotemAuraDone == FALSE
                && (BattleSystem_GetBattleStatusMask(battleSys) & BATTLE_STATUS_SOVEREIGN_TOTEM)) {
                battleCtx->sovereignTotemAuraDone = TRUE;

                if (battleCtx->battleMons[BATTLER_ENEMY_1].curHP
                    && BattleSystem_SovereignApplyTotemAura(battleSys, battleCtx, BATTLER_ENEMY_1)) {
                    battleCtx->msgBattlerTemp = BATTLER_ENEMY_1;
                    subscript = subscript_sovereign_totem_aura;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            battleCtx->switchInCheckState++;
            break;

        case SWITCH_IN_CHECK_STATE_TRACE:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];
                int defender1 = BattleSystem_GetEnemyInSlot(battleSys, battler, ENEMY_IN_SLOT_RIGHT);
                int defender2 = BattleSystem_GetEnemyInSlot(battleSys, battler, ENEMY_IN_SLOT_LEFT);

                battleCtx->msgDefender = ChooseTraceTarget(battleSys, battleCtx, defender1, defender2);

                // Sovereign (item 11): Imposter transforms the holder into the foe facing it as it enters, by
                // Transform's rules: not into a Pokemon behind a Substitute or already transformed. It checks once per
                // entry (traceAnnounced: no holder has Trace). The copied ability's entry effect (Intimidate...) follows.
                if (battleCtx->battleMons[battler].traceAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_IMPOSTER) {
                    int target = BattleSystem_GetEnemyInSlot(battleSys, battler, (BattleSystem_GetBattlerType(battleSys, battler) & 2) ^ 2);

                    battleCtx->battleMons[battler].traceAnnounced = TRUE;

                    if (target < maxBattlers
                        && battleCtx->battleMons[target].curHP
                        && (battleCtx->battleMons[target].statusVolatile & (VOLATILE_CONDITION_SUBSTITUTE | VOLATILE_CONDITION_TRANSFORM)) == FALSE
                        && (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE) {
                        battleCtx->msgBattlerTemp = battler;
                        battleCtx->msgDefender = target;
                        subscript = subscript_sovereign_imposter;
                        result = SWITCH_IN_CHECK_RESULT_BREAK;
                        break;
                    }
                }

                if (battleCtx->battleMons[battler].traceAnnounced == FALSE
                    && battleCtx->msgDefender != BATTLER_NONE
                    && battleCtx->battleMons[battler].curHP
                    && battleCtx->battleMons[battler].heldItem != ITEM_GRISEOUS_ORB
                    && battleCtx->battleMons[battleCtx->msgDefender].curHP
                    && Sovereign_HasAbilityShield(battleCtx, battler) == FALSE // Sovereign (item 11)
                    && Battler_Ability(battleCtx, battler) == ABILITY_TRACE) {
                    battleCtx->battleMons[battler].traceAnnounced = TRUE;
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_trace;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_PRIMAL_WEATHER_END:
            // Sovereign (item 11): a primal weather ends once no Pokemon with its ability is left in battle.
            battleCtx->switchInCheckState++;

            if (battleCtx->fieldConditionsMask & FIELD_CONDITION_SOVEREIGN_PRIMAL) {
                int ability = (battleCtx->fieldConditionsMask & FIELD_CONDITION_RAINING) ? ABILITY_PRIMORDIAL_SEA
                    : (battleCtx->fieldConditionsMask & FIELD_CONDITION_SUNNY)           ? ABILITY_DESOLATE_LAND
                                                                                         : ABILITY_DELTA_STREAM;

                for (i = 0; i < maxBattlers; i++) {
                    if (battleCtx->battleMons[i].curHP && Battler_Ability(battleCtx, i) == ability) {
                        break;
                    }
                }

                if (i == maxBattlers) {
                    battleCtx->msgTemp = ability - ABILITY_PRIMORDIAL_SEA; // 0 rain, 1 sun, 2 winds
                    battleCtx->fieldConditionsMask &= ~(FIELD_CONDITION_WEATHER | FIELD_CONDITION_SOVEREIGN_PRIMAL | FIELD_CONDITION_SOVEREIGN_STRONG_WINDS);
                    subscript = subscript_sovereign_primal_weather_end;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                }
            }
            break;

        case SWITCH_IN_CHECK_STATE_WEATHER_ABILITIES:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].weatherAbilityAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP) {
                    switch (Battler_Ability(battleCtx, battler)) {
                    case ABILITY_DRIZZLE:
                        battleCtx->battleMons[battler].weatherAbilityAnnounced = TRUE;

                        if ((battleCtx->fieldConditionsMask & (FIELD_CONDITION_RAINING | FIELD_CONDITION_SOVEREIGN_PRIMAL)) == FALSE) { // Sovereign: fails in the same weather (Gen VI+) or a primal one
                            subscript = subscript_drizzle;
                            result = SWITCH_IN_CHECK_RESULT_BREAK;
                        }
                        break;

                    case ABILITY_SAND_STREAM:
                        battleCtx->battleMons[battler].weatherAbilityAnnounced = TRUE;

                        if ((battleCtx->fieldConditionsMask & (FIELD_CONDITION_SANDSTORM | FIELD_CONDITION_SOVEREIGN_PRIMAL)) == FALSE) { // Sovereign: fails in the same weather (Gen VI+) or a primal one
                            subscript = subscript_sand_stream;
                            result = SWITCH_IN_CHECK_RESULT_BREAK;
                        }
                        break;

                    case ABILITY_ELECTRIC_SURGE: // Sovereign (item 11): the Surge abilities set their terrain
                    case ABILITY_HADRON_ENGINE:
                    case ABILITY_GRASSY_SURGE:
                    case ABILITY_MISTY_SURGE:
                    case ABILITY_PSYCHIC_SURGE: {
                        int ability = Battler_Ability(battleCtx, battler);
                        u32 terrain = (ability == ABILITY_GRASSY_SURGE) ? FIELD_CONDITION_TERRAIN_GRASSY
                            : (ability == ABILITY_MISTY_SURGE)          ? FIELD_CONDITION_TERRAIN_MISTY
                            : (ability == ABILITY_PSYCHIC_SURGE)        ? FIELD_CONDITION_TERRAIN_PSYCHIC
                                                                        : FIELD_CONDITION_TERRAIN_ELECTRIC;
                        battleCtx->battleMons[battler].weatherAbilityAnnounced = TRUE;

                        if ((battleCtx->fieldConditionsMask & terrain) == FALSE) {
                            battleCtx->fieldConditionsMask &= ~(FIELD_CONDITION_TERRAIN | FIELD_CONDITION_TERRAIN_TURNS);
                            battleCtx->fieldConditionsMask |= terrain
                                | (battleCtx->battleMons[battler].heldItem == ITEM_TERRAIN_EXTENDER ? FIELD_CONDITION_TERRAIN_8_TURNS : FIELD_CONDITION_TERRAIN_5_TURNS);
                            subscript = subscript_sovereign_terrain_start;
                            result = SWITCH_IN_CHECK_RESULT_BREAK;
                        }
                        break;
                    }

                    case ABILITY_ORICHALCUM_PULSE: // Sovereign (item 11): sets harsh sunlight like Drought
                    case ABILITY_DROUGHT:
                        battleCtx->battleMons[battler].weatherAbilityAnnounced = TRUE;

                        if ((battleCtx->fieldConditionsMask & (FIELD_CONDITION_SUNNY | FIELD_CONDITION_SOVEREIGN_PRIMAL)) == FALSE) { // Sovereign: fails in the same weather (Gen VI+) or a primal one
                            subscript = subscript_drought;
                            result = SWITCH_IN_CHECK_RESULT_BREAK;
                        }
                        break;

                    case ABILITY_PRIMORDIAL_SEA: // Sovereign (item 11): the primal weathers last while their Pokemon is in battle
                    case ABILITY_DESOLATE_LAND:
                    case ABILITY_DELTA_STREAM: {
                        int ability = Battler_Ability(battleCtx, battler);
                        u32 weather = (ability == ABILITY_PRIMORDIAL_SEA) ? FIELD_CONDITION_RAINING_PERM
                            : (ability == ABILITY_DESOLATE_LAND)          ? FIELD_CONDITION_SUNNY_PERM
                                                                          : FIELD_CONDITION_SOVEREIGN_STRONG_WINDS;
                        battleCtx->battleMons[battler].weatherAbilityAnnounced = TRUE;

                        if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_SOVEREIGN_PRIMAL) == FALSE
                            || (battleCtx->fieldConditionsMask & weather) == FALSE) {
                            battleCtx->fieldConditionsMask &= ~(FIELD_CONDITION_WEATHER | FIELD_CONDITION_SOVEREIGN_STRONG_WINDS);
                            battleCtx->fieldConditionsMask |= FIELD_CONDITION_SOVEREIGN_PRIMAL | weather;
                            battleCtx->fieldConditions.weatherTurns = 0;
                            subscript = subscript_sovereign_primal_weather_start;
                            result = SWITCH_IN_CHECK_RESULT_BREAK;
                        }
                        break;
                    }

                    case ABILITY_SNOW_WARNING:
                        battleCtx->battleMons[battler].weatherAbilityAnnounced = TRUE;

                        if ((battleCtx->fieldConditionsMask & (FIELD_CONDITION_HAILING | FIELD_CONDITION_SOVEREIGN_PRIMAL)) == FALSE) { // Sovereign: fails in the same weather (Gen VI+) or a primal one
                            subscript = subscript_snow_warning;
                            result = SWITCH_IN_CHECK_RESULT_BREAK;
                        }
                        break;
                    }
                }

                if (result == SWITCH_IN_CHECK_RESULT_BREAK) {
                    battleCtx->msgBattlerTemp = battler;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_INTIMIDATE:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].intimidateAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_INTIMIDATE) {
                    battleCtx->battleMons[battler].intimidateAnnounced = TRUE;
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_intimidate;
                    result = TRUE;
                    break;
                }

                // Sovereign (item 11): Supersweet Syrup lowers the foes' evasiveness 1 stage, the first time the holder
                // enters the battle.
                if (battleCtx->battleMons[battler].intimidateAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_SUPERSWEET_SYRUP) {
                    battleCtx->battleMons[battler].intimidateAnnounced = TRUE;

                    if ((battleCtx->sovereignOncePerBattle[battler] & FlagIndex(battleCtx->selectedPartySlot[battler])) == FALSE) {
                        battleCtx->sovereignOncePerBattle[battler] |= FlagIndex(battleCtx->selectedPartySlot[battler]);
                        battleCtx->msgBattlerTemp = battler;
                        subscript = subscript_sovereign_supersweet_syrup;
                        result = TRUE;
                        break;
                    }
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_BOOSTER_ENERGY:
            // Sovereign (item 11): a Protosynthesis or Quark Drive Pokemon uses its Booster Energy when its ability
            // isn't already active.
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].curHP
                    && battleCtx->battleMons[battler].sovereignBoosterEnergy == FALSE
                    && battleCtx->battleMons[battler].heldItem == ITEM_BOOSTER_ENERGY
                    && ((Battler_Ability(battleCtx, battler) == ABILITY_QUARK_DRIVE
                            && (battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN_ELECTRIC) == FALSE)
                        || (Battler_Ability(battleCtx, battler) == ABILITY_PROTOSYNTHESIS
                            && Sovereign_ProtosynthesisHasSun(battleSys, battleCtx) == FALSE))) {
                    battleCtx->battleMons[battler].sovereignBoosterEnergy = TRUE;
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_sovereign_booster_energy;
                    result = TRUE;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_TERRAIN_SEED:
            // Sovereign (item 11): the Electric and Grassy Seeds raise Defense, the Misty and Psychic Seeds Sp. Def, in
            // their terrain. Checked after every move too, so a terrain set mid-turn triggers them. Room Service lowers
            // Speed under Trick Room the same way.
            for (i = 0; i < maxBattlers; i++) {
                u16 item;
                u32 terrain;
                int stat;

                battler = battleCtx->monSpeedOrder[i];
                item = battleCtx->battleMons[battler].heldItem;
                terrain = battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN;
                stat = (item == ITEM_ELECTRIC_SEED || item == ITEM_GRASSY_SEED) ? BATTLE_STAT_DEFENSE : BATTLE_STAT_SP_DEFENSE;

                // Sovereign (item 11): Mimicry gives its holder the type of a terrain that starts (Electric, Grass,
                // Fairy, Psychic) and its own types back when the terrain ends. It acts only when the terrain changes
                // (or as it enters), so a type a move gave it (Soak...) stays until then.
                if (battleCtx->battleMons[battler].curHP && Battler_Ability(battleCtx, battler) == ABILITY_MIMICRY) {
                    int seen = (terrain & FIELD_CONDITION_TERRAIN_ELECTRIC) ? 1
                        : (terrain & FIELD_CONDITION_TERRAIN_GRASSY)        ? 2
                        : (terrain & FIELD_CONDITION_TERRAIN_MISTY)         ? 3
                        : (terrain & FIELD_CONDITION_TERRAIN_PSYCHIC)       ? 4
                                                                            : 0;

                    if (battleCtx->battleMons[battler].sovereignMimicryTerrain != seen) {
                        static const u8 sMimicryTypes[] = { TYPE_NORMAL, TYPE_ELECTRIC, TYPE_GRASS, TYPE_FAIRY, TYPE_PSYCHIC };
                        Pokemon *mon = BattleSystem_GetPartyPokemon(battleSys, battler, battleCtx->selectedPartySlot[battler]);
                        int type1 = seen ? sMimicryTypes[seen] : Pokemon_GetValue(mon, MON_DATA_TYPE_1, NULL);
                        int type2 = seen ? sMimicryTypes[seen] : Pokemon_GetValue(mon, MON_DATA_TYPE_2, NULL);

                        battleCtx->battleMons[battler].sovereignMimicryTerrain = seen;

                        if (battleCtx->battleMons[battler].type1 != type1 || battleCtx->battleMons[battler].type2 != type2) {
                            battleCtx->battleMons[battler].type1 = type1;
                            battleCtx->battleMons[battler].type2 = type2;
                            battleCtx->battleMons[battler].sovereignAddedType = 0; // Sovereign (item 11): a new type replaces an added one
                            battleCtx->msgBattlerTemp = battler;
                            battleCtx->msgTemp = seen ? type1 : 0xFF; // 0xFF: back to its own types
                            subscript = subscript_sovereign_mimicry;
                            result = TRUE;
                            break;
                        }
                    }
                }

                if (battleCtx->battleMons[battler].curHP
                    && item == ITEM_ROOM_SERVICE
                    && (battleCtx->fieldConditionsMask & FIELD_CONDITION_TRICK_ROOM)
                    && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_SPEED] > 0) {
                    battleCtx->msgBattlerTemp = battler;
                    battleCtx->msgItemTemp = item;
                    battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_SPEED_DOWN_1_STAGE;
                    battleCtx->sideEffectType = SIDE_EFFECT_TYPE_HELD_ITEM;
                    battleCtx->sideEffectMon = battler;
                    subscript = subscript_sovereign_terrain_seed;
                    result = TRUE;
                    break;
                }

                if (battleCtx->battleMons[battler].curHP
                    && ((item == ITEM_ELECTRIC_SEED && (terrain & FIELD_CONDITION_TERRAIN_ELECTRIC))
                        || (item == ITEM_GRASSY_SEED && (terrain & FIELD_CONDITION_TERRAIN_GRASSY))
                        || (item == ITEM_MISTY_SEED && (terrain & FIELD_CONDITION_TERRAIN_MISTY))
                        || (item == ITEM_PSYCHIC_SEED && (terrain & FIELD_CONDITION_TERRAIN_PSYCHIC)))
                    && battleCtx->battleMons[battler].statBoosts[stat] < MAX_STAT_STAGE) {
                    battleCtx->msgBattlerTemp = battler;
                    battleCtx->msgItemTemp = item;
                    battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE + (stat - BATTLE_STAT_ATTACK);
                    battleCtx->sideEffectType = SIDE_EFFECT_TYPE_HELD_ITEM;
                    battleCtx->sideEffectMon = battler;
                    subscript = subscript_sovereign_terrain_seed;
                    result = TRUE;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_STAT_DROP_REACTION:
            // Sovereign (item 11): Defiant, Competitive, Rattled and the Adrenaline Orb answer Intimidate.
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->sovereignDefiantPending & FlagIndex(battler)) {
                    battleCtx->sovereignDefiantPending &= ~FlagIndex(battler);

                    if (Sovereign_SetupStatDropReaction(battleCtx, battler)) {
                        subscript = subscript_update_stat_stage;
                        result = TRUE;
                        break;
                    }
                }

                if (battleCtx->sovereignAdrenalinePending & FlagIndex(battler)) {
                    battleCtx->sovereignAdrenalinePending &= ~FlagIndex(battler);

                    if (Sovereign_SetupAdrenalineOrb(battleCtx, battler)) {
                        subscript = subscript_sovereign_item_stat_up;
                        result = TRUE;
                        break;
                    }
                }

                // Sovereign (item 11): a Mirror Herb or Opportunist copies the foes' stat rises (checked after every move
                // too).
                if (Sovereign_SetupMirrorHerb(battleCtx, battler)) {
                    subscript = Battler_HeldItem(battleCtx, battler) == ITEM_MIRROR_HERB ? subscript_sovereign_mirror_herb : subscript_sovereign_opportunist;
                    result = TRUE;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_DOWNLOAD:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].downloadAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_DOWNLOAD) {
                    int j; // must declare here to match
                    int sumDef = 0, sumSpDef = 0;

                    for (j = 0; j < maxBattlers; j++) {
                        if (BattleSystem_GetBattlerSide(battleSys, battler) != BattleSystem_GetBattlerSide(battleSys, j)
                            && (battleCtx->battleMons[j].statusVolatile & VOLATILE_CONDITION_SUBSTITUTE) == FALSE
                            && battleCtx->battleMons[j].curHP) {
                            sumDef += battleCtx->battleMons[j].defense
                                * sStatStageBoosts[battleCtx->battleMons[j].statBoosts[BATTLE_STAT_DEFENSE]].numerator
                                / sStatStageBoosts[battleCtx->battleMons[j].statBoosts[BATTLE_STAT_DEFENSE]].denominator;
                            sumSpDef += battleCtx->battleMons[j].spDefense
                                * sStatStageBoosts[battleCtx->battleMons[j].statBoosts[BATTLE_STAT_SP_DEFENSE]].numerator
                                / sStatStageBoosts[battleCtx->battleMons[j].statBoosts[BATTLE_STAT_SP_DEFENSE]].denominator;
                        }
                    }

                    battleCtx->battleMons[battler].downloadAnnounced = TRUE;

                    if (sumDef + sumSpDef != 0) {
                        if (sumDef >= sumSpDef) {
                            battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_SP_ATTACK_UP_1_STAGE;
                        } else {
                            battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE;
                        }

                        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
                        battleCtx->sideEffectMon = battler;
                        subscript = subscript_update_stat_stage;
                        result = SWITCH_IN_CHECK_RESULT_BREAK;
                        break;
                    }
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_ENTRY_BOOSTS:
            // Sovereign (item 11): Intrepid Sword raises Attack and Dauntless Shield Defense by 1 stage, the first time
            // the holder enters the battle; Wind Rider raises Attack in a tailwind; Screen Cleaner clears the screens.
            for (i = 0; i < maxBattlers; i++) {
                int ability;

                battler = battleCtx->monSpeedOrder[i];
                ability = Battler_Ability(battleCtx, battler);

                if (battleCtx->battleMons[battler].curHP
                    && (ability == ABILITY_INTREPID_SWORD || ability == ABILITY_DAUNTLESS_SHIELD)
                    && (battleCtx->sovereignOncePerBattle[battler] & FlagIndex(battleCtx->selectedPartySlot[battler])) == FALSE) {
                    battleCtx->sovereignOncePerBattle[battler] |= FlagIndex(battleCtx->selectedPartySlot[battler]);
                    battleCtx->sideEffectParam = ability == ABILITY_INTREPID_SWORD ? MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE : MOVE_SUBSCRIPT_PTR_DEFENSE_UP_1_STAGE;
                    battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
                    battleCtx->sideEffectMon = battler;
                    subscript = subscript_update_stat_stage;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }

                // Wind Rider raises its Attack 1 stage on entry when a tailwind blows on its side.
                if (battleCtx->battleMons[battler].curHP
                    && ability == ABILITY_WIND_RIDER
                    && battleCtx->battleMons[battler].sovereignEntryAnnounced == FALSE) {
                    battleCtx->battleMons[battler].sovereignEntryAnnounced = TRUE;

                    if (battleCtx->sideConditionsMask[BattleSystem_GetBattlerSide(battleSys, battler)] & SIDE_CONDITION_TAILWIND) {
                        battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE;
                        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
                        battleCtx->sideEffectMon = battler;
                        subscript = subscript_update_stat_stage;
                        result = SWITCH_IN_CHECK_RESULT_BREAK;
                        break;
                    }
                }

                // An Air Balloon is announced as its holder enters the battle.
                if (battleCtx->battleMons[battler].curHP
                    && Battler_HeldItem(battleCtx, battler) == ITEM_AIR_BALLOON
                    && battleCtx->battleMons[battler].sovereignBalloonAnnounced == FALSE) {
                    battleCtx->battleMons[battler].sovereignBalloonAnnounced = TRUE;
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_sovereign_air_balloon;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }

                // Hospitality restores a quarter of its partner's max HP, Costar copies its partner's stat stages (and
                // Focus Energy, Dragon Cheer, Laser Focus), and Curious Medicine resets its partner's, on entry (double
                // battles).
                if (battleCtx->battleMons[battler].curHP
                    && (ability == ABILITY_HOSPITALITY || ability == ABILITY_COSTAR || ability == ABILITY_CURIOUS_MEDICINE)
                    && battleCtx->battleMons[battler].sovereignEntryAnnounced == FALSE) {
                    int partner = BattleSystem_GetPartner(battleSys, battler);
                    BattleMon *ally = &battleCtx->battleMons[partner];

                    battleCtx->battleMons[battler].sovereignEntryAnnounced = TRUE;

                    if (partner != battler && ally->curHP
                        && (ability != ABILITY_HOSPITALITY
                            || (ally->curHP < ally->maxHP && Sovereign_HealBlocked(battleCtx, partner) == FALSE))) { // Sovereign: Heal Block
                        battleCtx->msgBattlerTemp = partner;
                        battleCtx->msgAttacker = battler;

                        if (ability == ABILITY_HOSPITALITY) {
                            battleCtx->hpCalcTemp = ally->maxHP / 4;
                            subscript = subscript_sovereign_hospitality;
                        } else if (ability == ABILITY_COSTAR) {
                            BattleMon *mon = &battleCtx->battleMons[battler];

                            for (int stat = BATTLE_STAT_HP; stat < BATTLE_STAT_MAX; stat++) {
                                mon->statBoosts[stat] = ally->statBoosts[stat];
                            }

                            mon->statusVolatile = (mon->statusVolatile & ~VOLATILE_CONDITION_FOCUS_ENERGY)
                                | (ally->statusVolatile & VOLATILE_CONDITION_FOCUS_ENERGY);
                            battleCtx->sovereignDragonCheer[battler] = battleCtx->sovereignDragonCheer[partner];
                            battleCtx->sovereignLaserFocus[battler] = battleCtx->sovereignLaserFocus[partner];
                            subscript = subscript_sovereign_costar;
                        } else {
                            for (int stat = BATTLE_STAT_HP; stat < BATTLE_STAT_MAX; stat++) {
                                ally->statBoosts[stat] = DEFAULT_STAT_STAGE;
                            }

                            subscript = subscript_sovereign_curious_medicine;
                        }

                        result = SWITCH_IN_CHECK_RESULT_BREAK;
                        break;
                    }
                }

                // Screen Cleaner removes Reflect, Light Screen and Aurora Veil from both sides on entry.
                if (battleCtx->battleMons[battler].curHP
                    && ability == ABILITY_SCREEN_CLEANER
                    && battleCtx->battleMons[battler].sovereignEntryAnnounced == FALSE) {
                    battleCtx->battleMons[battler].sovereignEntryAnnounced = TRUE;

                    for (int side = 0; side < 2; side++) {
                        battleCtx->sideConditionsMask[side] &= ~(SIDE_CONDITION_REFLECT | SIDE_CONDITION_LIGHT_SCREEN | SIDE_CONDITION_SOVEREIGN_AURORA_VEIL);
                        battleCtx->sovereignAuroraVeilTurns[side] = 0;
                        battleCtx->sideConditions[side].reflectTurns = 0;
                        battleCtx->sideConditions[side].lightScreenTurns = 0;
                    }

                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_mold_breaker; // "{0} has {1}!"
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_ANTICIPATION:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].anticipationAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_ANTICIPATION) {
                    int j, k;
                    u16 move;
                    u32 effectiveness;

                    battleCtx->battleMons[battler].anticipationAnnounced = TRUE;

                    for (j = 0; j < maxBattlers; j++) {
                        if (BattleSystem_GetBattlerSide(battleSys, battler) != BattleSystem_GetBattlerSide(battleSys, j) && battleCtx->battleMons[j].curHP) {
                            for (k = 0; k < LEARNED_MOVES_MAX; k++) {
                                move = battleCtx->battleMons[j].moves[k];

                                if (move) {
                                    effectiveness = 0;
                                    battleCtx->damage = BattleSystem_ApplyTypeChart(battleSys, battleCtx, move, NULL, j, battler, battleCtx->damage, &effectiveness);

                                    if ((effectiveness & MOVE_STATUS_INEFFECTIVE) == FALSE
                                        && MoveCannotTriggerAnticipation(battleCtx, move) == FALSE
                                        && ((effectiveness & MOVE_STATUS_SUPER_EFFECTIVE)
                                            || (MOVE_DATA(move).effect == BATTLE_EFFECT_ONE_HIT_KO
                                                && battleCtx->battleMons[battler].level <= battleCtx->battleMons[j].level))) {
                                        result = SWITCH_IN_CHECK_RESULT_BREAK;
                                        break;
                                    }
                                }
                            }

                            if (result == SWITCH_IN_CHECK_RESULT_BREAK) {
                                break;
                            }
                        }
                    }

                    if (result == SWITCH_IN_CHECK_RESULT_BREAK) {
                        battleCtx->msgBattlerTemp = battler;
                        subscript = subscript_anticipation;
                    }
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_FOREWARN:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].forewarnAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_FOREWARN) {
                    int j, k;
                    u16 move;
                    u32 movePower, maxPower;
                    int sumEnemyHP;

                    battleCtx->battleMons[battler].forewarnAnnounced = TRUE;
                    maxPower = 0;
                    sumEnemyHP = 0;

                    for (j = 0; j < maxBattlers; j++) {
                        if (BattleSystem_GetBattlerSide(battleSys, battler) != BattleSystem_GetBattlerSide(battleSys, j)
                            && battleCtx->battleMons[j].curHP) {
                            sumEnemyHP += battleCtx->battleMons[j].curHP;

                            for (k = 0; k < LEARNED_MOVES_MAX; k++) {
                                move = battleCtx->battleMons[j].moves[k];
                                movePower = MOVE_DATA(move).power;

                                if (movePower == 1) {
                                    switch (MOVE_DATA(move).effect) {
                                    case BATTLE_EFFECT_ONE_HIT_KO:
                                        if (maxPower < 150 || (maxPower == 150 && (BattleSystem_RandNext(battleSys) & 1))) {
                                            maxPower = 150;
                                            battleCtx->msgMoveTemp = move;
                                        }
                                        break;

                                    case BATTLE_EFFECT_COUNTER:
                                    case BATTLE_EFFECT_MIRROR_COAT:
                                    case BATTLE_EFFECT_METAL_BURST:
                                        if (maxPower < 120 || (maxPower == 120 && (BattleSystem_RandNext(battleSys) & 1))) {
                                            maxPower = 120;
                                            battleCtx->msgMoveTemp = move;
                                        }
                                        break;

                                    default:
                                        if (maxPower < 80 || (maxPower == 80 && (BattleSystem_RandNext(battleSys) & 1))) {
                                            maxPower = 80;
                                            battleCtx->msgMoveTemp = move;
                                        }
                                        break;
                                    }
                                } else if (maxPower < movePower || (maxPower == movePower && (BattleSystem_RandNext(battleSys) & 1))) {
                                    maxPower = movePower;
                                    battleCtx->msgMoveTemp = move;
                                }
                            }
                        }
                    }

                    if (maxPower) {
                        battleCtx->msgBattlerTemp = battler;

                        subscript = subscript_forewarn;
                        result = SWITCH_IN_CHECK_RESULT_BREAK;
                    } else if (sumEnemyHP) {
                        j = BattleSystem_RandomOpponent(battleSys, battleCtx, battler);
                        k = Battler_CountMoves(battleSys, battleCtx, j);

                        battleCtx->msgMoveTemp = battleCtx->battleMons[j].moves[BattleSystem_RandNext(battleSys) % k];
                        battleCtx->msgBattlerTemp = battler;

                        subscript = subscript_forewarn;
                        result = SWITCH_IN_CHECK_RESULT_BREAK;
                    }
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_FRISK:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].friskAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_FRISK) {
                    battleCtx->battleMons[battler].friskAnnounced = TRUE;

                    // Sovereign: Frisk finds every foe's item, each with its own message (Gen VI+). Platinum named
                    // one item, a random foe's in a double battle. subscript_frisk goes through the foes.
                    for (int j = 0; j < maxBattlers; j++) {
                        if (BattleSystem_GetBattlerSide(battleSys, j) != BattleSystem_GetBattlerSide(battleSys, battler)
                            && battleCtx->battleMons[j].curHP
                            && battleCtx->battleMons[j].heldItem) {
                            result = SWITCH_IN_CHECK_RESULT_BREAK;
                        }
                    }
                }

                if (result == SWITCH_IN_CHECK_RESULT_BREAK) {
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_frisk;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SLOW_START:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].slowStartAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_SLOW_START
                    && battleCtx->totalTurns <= battleCtx->battleMons[battler].moveEffectsData.slowStartTurnNumber) {
                    battleCtx->battleMons[battler].slowStartAnnounced = TRUE;
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_slow_start;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }

                if (battleCtx->battleMons[battler].slowStartFinished == 0
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_SLOW_START
                    && (battleCtx->totalTurns - battleCtx->battleMons[battler].moveEffectsData.slowStartTurnNumber) == 5) {
                    battleCtx->battleMons[battler].slowStartFinished = 1;
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_slow_start_end;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_MOLD_BREAKER:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].moldBreakerAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && (Battler_Ability(battleCtx, battler) == ABILITY_MOLD_BREAKER
                        || Battler_Ability(battleCtx, battler) == ABILITY_TURBOBLAZE
                        || Battler_Ability(battleCtx, battler) == ABILITY_TERAVOLT)) {
                    battleCtx->battleMons[battler].moldBreakerAnnounced = TRUE;
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_mold_breaker;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_PRESSURE:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (battleCtx->battleMons[battler].pressureAnnounced == FALSE
                    && battleCtx->battleMons[battler].curHP
                    && Battler_Ability(battleCtx, battler) == ABILITY_PRESSURE) {
                    battleCtx->battleMons[battler].pressureAnnounced = TRUE;
                    battleCtx->msgBattlerTemp = battler;
                    subscript = subscript_pressure;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_FORM_CHANGE:
            if (BattleSystem_TriggerFormChange(battleSys, battleCtx, &subscript) == TRUE) {
                result = SWITCH_IN_CHECK_RESULT_BREAK;
            } else {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_AMULET_COIN:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (BattleSystem_GetItemData(battleCtx, battleCtx->battleMons[battler].heldItem, ITEM_PARAM_HOLD_EFFECT) == HOLD_EFFECT_MONEY_UP) {
                    battleCtx->prizeMoneyMul = 2;
                }
            }

            battleCtx->switchInCheckState++;
            break;

        case SWITCH_IN_CHECK_STATE_FORBIDDEN_STATUS:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (BattleSystem_RecoverStatusByAbility(battleSys, battleCtx, battler, TRUE) == TRUE) {
                    subscript = subscript_ability_forbids_status;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_HELD_ITEM_STATUS:
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];

                if (BattleSystem_TriggerHeldItemOnStatus(battleSys, battleCtx, battler, &subscript) == TRUE) {
                    battleCtx->msgBattlerTemp = battler;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_EMERGENCY_EXIT:
            // Sovereign (item 11): Emergency Exit and Wimp Out after the entry hazards took a Pokemon switched in from above
            // half its HP to half or less, and no Berry has healed it back above half since. Last, after its other switch-in
            // effects, as in Showdown's runSwitch. The checks start over after it, for the Pokemon that comes in instead.
            for (i = 0; i < maxBattlers; i++) {
                battler = battleCtx->monSpeedOrder[i];
                int hpOnEntry = battleCtx->sovereignHPOnEntry[battler];

                battleCtx->sovereignHPOnEntry[battler] = 0;

                if (hpOnEntry && Sovereign_EmergencyExitDue(battleCtx, battler, hpOnEntry)) {
                    battleCtx->switchedMon = battler;
                    battleCtx->switchInCheckState = SWITCH_IN_CHECK_STATE_START;
                    subscript = subscript_sovereign_emergency_exit;
                    result = SWITCH_IN_CHECK_RESULT_BREAK;
                    break;
                }
            }

            if (i == maxBattlers) {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_SOVEREIGN_EJECT_PACK:
            // Sovereign (item 11): an Eject Pack whose holder had a stat lowered by a switch-in (Intimidate, Sticky
            // Web...). Last, as Showdown's ejectpack (onAnySwitchIn, priority -4); the checks start over after it, for
            // the Pokemon that comes in instead.
            battler = Sovereign_EjectPackHolder(battleSys, battleCtx);

            if (battler != BATTLER_NONE) {
                battleCtx->switchedMon = battler;
                battleCtx->switchInCheckState = SWITCH_IN_CHECK_STATE_START;
                subscript = subscript_sovereign_eject_pack;
                result = SWITCH_IN_CHECK_RESULT_BREAK;
            } else {
                battleCtx->switchInCheckState++;
            }
            break;

        case SWITCH_IN_CHECK_STATE_DONE:
            battleCtx->switchInCheckState = 0;
            result = SWITCH_IN_CHECK_RESULT_DONE;
            break;
        }
    } while (result == SWITCH_IN_CHECK_RESULT_CONTINUE);

    return subscript;
}

int BattleSystem_RandomOpponent(BattleSystem *battleSys, BattleContext *battleCtx, int attacker)
{
    int opponents[2];
    u32 battleType = BattleSystem_GetBattleType(battleSys);

    int chosen;
    if (battleType & BATTLE_TYPE_DOUBLES) {
        opponents[0] = BattleSystem_GetEnemyInSlot(battleSys, attacker, ENEMY_IN_SLOT_RIGHT);
        opponents[1] = BattleSystem_GetEnemyInSlot(battleSys, attacker, ENEMY_IN_SLOT_LEFT);

        int rnd = BattleSystem_RandNext(battleSys) & 1;
        chosen = opponents[rnd];

        if (battleCtx->battleMons[chosen].curHP == 0) {
            chosen = opponents[rnd ^ 1];
        }
    } else {
        chosen = attacker ^ 1;
    }

    return chosen;
}

// Sovereign (item 11): abilities Mummy, Lingering Aroma and Wandering Spirit can't overwrite or take (the form and
// signature abilities).
static BOOL Sovereign_AbilityIsFixed(int ability)
{
    switch (ability) {
    case ABILITY_MULTITYPE:
    case ABILITY_STANCE_CHANGE:
    case ABILITY_SCHOOLING:
    case ABILITY_COMATOSE:
    case ABILITY_SHIELDS_DOWN:
    case ABILITY_DISGUISE:
    case ABILITY_RKS_SYSTEM:
    case ABILITY_BATTLE_BOND:
    case ABILITY_POWER_CONSTRUCT:
    case ABILITY_ICE_FACE:
    case ABILITY_GULP_MISSILE:
    case ABILITY_ZERO_TO_HERO:
    case ABILITY_COMMANDER:
    case ABILITY_TERA_SHIFT:
    case ABILITY_ZEN_MODE:
    case ABILITY_MUMMY:
    case ABILITY_LINGERING_AROMA:
        return TRUE;
    }

    return FALSE;
}

// Sovereign (item 11): abilities that can't be suppressed (Gastro Acid, Core Enforcer) or overwritten (Role Play,
// Doodle, Entrainment's target). Gen IX's list.
BOOL Sovereign_AbilityCantBeSuppressed(int ability)
{
    switch (ability) {
    case ABILITY_AS_ONE_GLASTRIER:
    case ABILITY_AS_ONE_SPECTRIER:
    case ABILITY_BATTLE_BOND:
    case ABILITY_COMATOSE:
    case ABILITY_DISGUISE:
    case ABILITY_GULP_MISSILE:
    case ABILITY_ICE_FACE:
    case ABILITY_MULTITYPE:
    case ABILITY_POWER_CONSTRUCT:
    case ABILITY_RKS_SYSTEM:
    case ABILITY_SCHOOLING:
    case ABILITY_SHIELDS_DOWN:
    case ABILITY_STANCE_CHANGE:
    case ABILITY_TERA_SHIFT:
    case ABILITY_ZEN_MODE:
    case ABILITY_ZERO_TO_HERO:
        return TRUE;
    }

    return FALSE;
}

// Sovereign (item 11): abilities Role Play and Doodle can't copy, Entrainment can't pass on and Trace can't take (Trace
// can take Wonder Guard). Gen IX's list.
BOOL Sovereign_AbilityCantBeCopied(int ability)
{
    if (ability == ABILITY_NONE || Sovereign_AbilityCantBeSuppressed(ability)) {
        return TRUE;
    }

    switch (ability) {
    case ABILITY_COMMANDER:
    case ABILITY_EMBODY_ASPECT:
    case ABILITY_FLOWER_GIFT:
    case ABILITY_FORECAST:
    case ABILITY_HUNGER_SWITCH:
    case ABILITY_ILLUSION:
    case ABILITY_IMPOSTER:
    case ABILITY_NEUTRALIZING_GAS:
    case ABILITY_POISON_PUPPETEER:
    case ABILITY_POWER_OF_ALCHEMY:
    case ABILITY_PROTOSYNTHESIS:
    case ABILITY_QUARK_DRIVE:
    case ABILITY_RECEIVER:
    case ABILITY_TERAFORM_ZERO:
    case ABILITY_TERA_SHELL:
    case ABILITY_TRACE:
    case ABILITY_WONDER_GUARD:
        return TRUE;
    }

    return FALSE;
}

// Sovereign (item 11): abilities Skill Swap can't swap, on either side. Gen IX's list.
BOOL Sovereign_AbilityCantBeSwapped(int ability)
{
    if (ability == ABILITY_GULP_MISSILE) {
        return FALSE;
    }

    if (Sovereign_AbilityCantBeSuppressed(ability)) {
        return TRUE;
    }

    switch (ability) {
    case ABILITY_COMMANDER:
    case ABILITY_EMBODY_ASPECT:
    case ABILITY_HUNGER_SWITCH:
    case ABILITY_ILLUSION:
    case ABILITY_NEUTRALIZING_GAS:
    case ABILITY_POISON_PUPPETEER:
    case ABILITY_PROTOSYNTHESIS:
    case ABILITY_QUARK_DRIVE:
    case ABILITY_TERAFORM_ZERO:
    case ABILITY_TERA_SHELL:
    case ABILITY_WONDER_GUARD:
        return TRUE;
    }

    return FALSE;
}

// Sovereign (item 11): gives a battler a new ability, as Role Play does: Truant starts on the right foot and Slow Start
// starts over.
static void Sovereign_SetAbility(BattleContext *battleCtx, int battler, int ability)
{
    BattleMon *mon = &battleCtx->battleMons[battler];

    mon->ability = ability;
    mon->moveEffectsData.truant = battleCtx->totalTurns & 1;

    if (ability == ABILITY_SLOW_START) {
        mon->moveEffectsData.slowStartTurnNumber = battleCtx->totalTurns + 1;
        mon->slowStartAnnounced = FALSE;
        mon->slowStartFinished = FALSE;
    }
}

// Sovereign (item 11): Doodle gives the user and its ally the target's ability, by Role Play's rules, and returns who
// took it (1: the user, 2: its ally), plus 4 when an Ability Shield kept one's own (that one is then msgBattlerTemp).
// 0: it fails.
int Sovereign_Doodle(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int ability = battleCtx->battleMons[battleCtx->defender].ability;
    int result = 0;

    if (Sovereign_AbilityCantBeCopied(ability)) {
        return 0;
    }

    for (int i = 0; i < 2; i++) {
        int battler = battleCtx->attacker;

        if (i == 1) {
            if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES) == FALSE) {
                break;
            }
            battler = BattleSystem_GetPartner(battleSys, battleCtx->attacker);
            if (battleCtx->battleMons[battler].curHP == 0) {
                break;
            }
        }

        if (battleCtx->battleMons[battler].ability == ability
            || Sovereign_AbilityCantBeSuppressed(battleCtx->battleMons[battler].ability)) {
            continue;
        }

        if (Sovereign_HasAbilityShield(battleCtx, battler)) {
            if ((result & 4) == FALSE) {
                result |= 4;
                battleCtx->msgBattlerTemp = battler;
            }
            continue;
        }

        Sovereign_SetAbility(battleCtx, battler, ability);
        result |= 1 << i;
    }

    return result;
}

// Sovereign (item 11): Core Enforcer suppresses the ability of a target that has already acted this turn and didn't
// switch in during it (not one that can't be suppressed, nor through an Ability Shield). TRUE when it does.
BOOL Sovereign_CoreEnforcer(BattleContext *battleCtx, int battler)
{
    BattleMon *mon = &battleCtx->battleMons[battler];

    return mon->curHP
        && Battler_MovedThisTurn(battleCtx, battler)
        && battleCtx->turnFlags[battler].sovereignSwitchedIn == FALSE
        && (mon->moveEffectsMask & MOVE_EFFECT_ABILITY_SUPPRESSED) == FALSE
        && Sovereign_AbilityCantBeSuppressed(mon->ability) == FALSE
        && Sovereign_HasAbilityShield(battleCtx, battler) == FALSE;
}

// Sovereign (item 11): Receiver and Power of Alchemy. When a Pokemon faints, its ally with one of them takes over its
// ability, unless that ability can't be copied (Showdown's noreceiver list) or an Ability Shield keeps the ally's own.
// Returns the ally, or BATTLER_NONE.
int Sovereign_Receiver(BattleSystem *battleSys, BattleContext *battleCtx, int fainted)
{
    int ally;
    int ability;

    if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES) == FALSE || fainted == BATTLER_NONE) {
        return BATTLER_NONE;
    }

    ally = BattleSystem_GetPartner(battleSys, fainted);
    ability = battleCtx->battleMons[fainted].ability;

    if (ally == fainted
        || battleCtx->battleMons[ally].curHP == 0
        || (Battler_Ability(battleCtx, ally) != ABILITY_RECEIVER && Battler_Ability(battleCtx, ally) != ABILITY_POWER_OF_ALCHEMY)
        || Sovereign_AbilityCantBeCopied(ability)
        || Sovereign_HasAbilityShield(battleCtx, ally)) {
        return BATTLER_NONE;
    }

    Sovereign_SetAbility(battleCtx, ally, ability);
    return ally;
}

// Sovereign (item 11): after the ability's type change (Normalize, the -ate abilities, Liquid Voice), Electrify makes all
// of an electrified battler's moves Electric, and Ion Deluge makes Normal moves Electric, for the rest of the turn.
int Sovereign_ElectrifyType(BattleContext *battleCtx, int battler, int move, int type)
{
    if (move == MOVE_STRUGGLE) {
        return type;
    }

    if (battleCtx->turnFlags[battler].sovereignElectrified
        || (battleCtx->sovereignIonDeluge && type == TYPE_NORMAL)) {
        return TYPE_ELECTRIC;
    }

    return type;
}

// Sovereign (item 11): a move's range as it's used: Expanding Force from a grounded user in Psychic Terrain hits both
// foes.
int Sovereign_MoveRange(BattleContext *battleCtx, int attacker, int move)
{
    if (move == MOVE_EXPANDING_FORCE && (Sovereign_TerrainUnder(battleCtx, attacker) & FIELD_CONDITION_TERRAIN_PSYCHIC)) {
        return RANGE_ADJACENT_OPPONENTS;
    }

    return MOVE_DATA(move).range;
}

// Sovereign (item 11): Spectral Thief takes the target's stat rises and adds them to the user's stages (up to +6;
// Contrary turns them into drops), before it hits. TRUE when it takes any.
BOOL Sovereign_SpectralThief(BattleContext *battleCtx, int attacker, int defender)
{
    BattleMon *user = &battleCtx->battleMons[attacker];
    BattleMon *target = &battleCtx->battleMons[defender];
    BOOL contrary = Battler_Ability(battleCtx, attacker) == ABILITY_CONTRARY;
    BOOL stole = FALSE;

    for (int stat = BATTLE_STAT_ATTACK; stat < BATTLE_STAT_MAX; stat++) {
        int rise = target->statBoosts[stat] - DEFAULT_STAT_STAGE;

        if (rise <= 0) {
            continue;
        }

        int stage = user->statBoosts[stat] + (contrary ? -rise : rise);

        if (stage < 0) {
            stage = 0;
        } else if (stage > MAX_STAT_STAGE) {
            stage = MAX_STAT_STAGE;
        }

        user->statBoosts[stat] = stage;
        target->statBoosts[stat] = DEFAULT_STAT_STAGE;
        stole = TRUE;
    }

    if (stole) {
        if (contrary) {
            battleCtx->turnFlags[attacker].sovereignStatsLowered = TRUE;
        } else {
            battleCtx->turnFlags[attacker].sovereignStatsRaised = TRUE;
        }
    }

    return stole;
}

// Sovereign (item 11): Electrify works on a target that hasn't acted yet this turn and isn't electrified already.
BOOL Sovereign_Electrify(BattleContext *battleCtx, int battler)
{
    if (Battler_MovedThisTurn(battleCtx, battler) || battleCtx->turnFlags[battler].sovereignElectrified) {
        return FALSE;
    }

    battleCtx->turnFlags[battler].sovereignElectrified = TRUE;
    return TRUE;
}

// Sovereign (item 11): Ion Deluge and Plasma Fists start the deluge of ions for this turn. FALSE if it's already on.
BOOL Sovereign_StartIonDeluge(BattleContext *battleCtx)
{
    if (battleCtx->sovereignIonDeluge) {
        return FALSE;
    }

    battleCtx->sovereignIonDeluge = TRUE;
    return TRUE;
}

// Sovereign (item 11): Fairy Lock keeps everyone from escaping this turn and the next. FALSE if it's already on.
BOOL Sovereign_StartFairyLock(BattleContext *battleCtx)
{
    if (battleCtx->sovereignFairyLock) {
        return FALSE;
    }

    battleCtx->sovereignFairyLock = 2;
    return TRUE;
}

// Sovereign (item 11): Octolock holds the defender: it can't escape while the attacker stays in, and its Defense and
// Sp. Def fall at the end of each turn. FALSE if it's already held, or a Ghost type (nothing traps a Ghost type).
BOOL Sovereign_StartOctolock(BattleContext *battleCtx)
{
    int battler = battleCtx->defender;

    if (battleCtx->sovereignOctolock[battler] || MON_HAS_TYPE(battler, TYPE_GHOST)) {
        return FALSE;
    }

    battleCtx->sovereignOctolock[battler] = TRUE;
    battleCtx->sovereignOctolockSource[battler] = battleCtx->attacker;
    battleCtx->sovereignOctolockSourceSlot[battler] = battleCtx->selectedPartySlot[battleCtx->attacker];
    return TRUE;
}

// Sovereign (item 11): Spotlight makes the defender the center of attention for its foes this turn, as if it had used
// Follow Me. Double battles only.
BOOL Sovereign_Spotlight(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES) == FALSE) {
        return FALSE;
    }

    int side = BattleSystem_GetBattlerSide(battleSys, battleCtx->defender);
    battleCtx->sideConditions[side].followMe = TRUE;
    FOLLOW_ME_USER(side) = battleCtx->defender;
    return TRUE;
}

// Sovereign (item 11): Teatime. How many battlers on the field hold a Berry; it saves the user, since each eater takes
// the attacker's place in turn (Sovereign_TeatimeNext).
int Sovereign_TeatimeStart(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int count = 0;

    for (int i = 0; i < BattleSystem_GetMaxBattlers(battleSys); i++) {
        if (battleCtx->battleMons[i].curHP && Item_IsBerry(battleCtx->battleMons[i].heldItem)) {
            count++;
        }
    }

    battleCtx->sovereignTeatimeNext = 0;
    battleCtx->sovereignTeatimeUser = battleCtx->attacker;
    return count;
}

// Sovereign (item 11): Teatime makes the next battler holding a Berry the attacker (who eats it), and returns TRUE; when
// none is left, the user is the attacker again and it returns FALSE.
BOOL Sovereign_TeatimeNext(BattleSystem *battleSys, BattleContext *battleCtx)
{
    while (battleCtx->sovereignTeatimeNext < BattleSystem_GetMaxBattlers(battleSys)) {
        int battler = battleCtx->sovereignTeatimeNext++;

        if (battleCtx->battleMons[battler].curHP && Item_IsBerry(battleCtx->battleMons[battler].heldItem)) {
            battleCtx->attacker = battler;
            return TRUE;
        }
    }

    battleCtx->attacker = battleCtx->sovereignTeatimeUser;
    return FALSE;
}

// Sovereign (item 11): Shell Side Arm is physical, and makes contact, when Showdown's formula (with the stat stages, the
// target's Defense against its Sp. Def) says a physical hit would do more damage than a special one.
BOOL Sovereign_ShellSideArmPhysical(BattleContext *battleCtx, int attacker, int defender)
{
    BattleMon *user = &battleCtx->battleMons[attacker];
    BattleMon *target = &battleCtx->battleMons[defender];
    u32 base = 2 * user->level / 5 + 2;
    u32 attack = user->attack * sStatStageBoosts[user->statBoosts[BATTLE_STAT_ATTACK]].numerator
        / sStatStageBoosts[user->statBoosts[BATTLE_STAT_ATTACK]].denominator;
    u32 spAttack = user->spAttack * sStatStageBoosts[user->statBoosts[BATTLE_STAT_SP_ATTACK]].numerator
        / sStatStageBoosts[user->statBoosts[BATTLE_STAT_SP_ATTACK]].denominator;
    u32 defense = target->defense * sStatStageBoosts[target->statBoosts[BATTLE_STAT_DEFENSE]].numerator
        / sStatStageBoosts[target->statBoosts[BATTLE_STAT_DEFENSE]].denominator;
    u32 spDefense = target->spDefense * sStatStageBoosts[target->statBoosts[BATTLE_STAT_SP_DEFENSE]].numerator
        / sStatStageBoosts[target->statBoosts[BATTLE_STAT_SP_DEFENSE]].denominator;

    return base * 90 * attack / (defense ? defense : 1) / 50 > base * 90 * spAttack / (spDefense ? spDefense : 1) / 50;
}

// Sovereign (item 11): TRUE when a move hits as a physical one, Photon Geyser and Shell Side Arm as they choose
// (BattleSystem_CalcMoveDamage). Shell Trap springs on these.
BOOL Sovereign_HitsPhysically(BattleContext *battleCtx, int attacker, int defender, int move)
{
    BattleMon *user = &battleCtx->battleMons[attacker];

    if (move == MOVE_SHELL_SIDE_ARM) {
        return Sovereign_ShellSideArmPhysical(battleCtx, attacker, defender);
    }

    if (move == MOVE_PHOTON_GEYSER) {
        return user->attack * sStatStageBoosts[user->statBoosts[BATTLE_STAT_ATTACK]].numerator
                / sStatStageBoosts[user->statBoosts[BATTLE_STAT_ATTACK]].denominator
            > user->spAttack * sStatStageBoosts[user->statBoosts[BATTLE_STAT_SP_ATTACK]].numerator
                / sStatStageBoosts[user->statBoosts[BATTLE_STAT_SP_ATTACK]].denominator;
    }

    return MOVE_DATA(move).class == CLASS_PHYSICAL;
}

// Sovereign (item 11): Autotomize makes the side-effect battler 100 kg lighter, down to 0.1 kg. FALSE if it was already
// that light.
BOOL Sovereign_Autotomize(BattleContext *battleCtx)
{
    BattleMon *mon = &battleCtx->battleMons[battleCtx->sideEffectMon];

    if (mon->weight <= 1) {
        return FALSE;
    }

    mon->weight = mon->weight > 1001 ? mon->weight - 1000 : 1;
    return TRUE;
}

// Sovereign (item 11): Flame Burst's bursting flame hits the defender's ally for 1/16 of its max HP (not through Magic
// Guard). FALSE when there's none to hit; otherwise the ally is msgBattlerTemp and the damage is in hpCalcTemp.
BOOL Sovereign_FlameBurstSplash(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES) == FALSE) {
        return FALSE;
    }

    int ally = BattleSystem_GetPartner(battleSys, battleCtx->defender);

    if (battleCtx->battleMons[ally].curHP == 0 || Battler_Ability(battleCtx, ally) == ABILITY_MAGIC_GUARD) {
        return FALSE;
    }

    battleCtx->msgBattlerTemp = ally;
    battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[ally].maxHP * -1, 16);
    return TRUE;
}

// Sovereign (item 11): TRUE when the thief can take the victim's held item by Thief's rules (BtlCmd_TryStealItem), for
// Magician and Pickpocket. A Pokemon on the foe's side can't, outside the Battle Frontier, so the player loses no item.
static BOOL Sovereign_CanTakeItem(BattleSystem *battleSys, BattleContext *battleCtx, int thief, int victim)
{
    int thiefSide = BattleSystem_GetBattlerSide(battleSys, thief);

    return (thiefSide == BATTLE_SIDE_PLAYER || (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_FRONTIER_LINK))
        && battleCtx->battleMons[thief].heldItem == ITEM_NONE
        && (battleCtx->sideConditions[thiefSide].knockedOffItemsMask & FlagIndex(battleCtx->selectedPartySlot[thief])) == FALSE
        && Battler_Ability(battleCtx, thief) != ABILITY_MULTITYPE
        && Battler_Ability(battleCtx, victim) != ABILITY_MULTITYPE
        && Battler_Ability(battleCtx, victim) != ABILITY_STICKY_HOLD
        && battleCtx->battleMons[victim].heldItem != ITEM_GRISEOUS_ORB
        && Battler_SovereignHeldItemLocked(battleCtx, victim) == FALSE
        && battleCtx->battleMons[victim].moveEffectsData.custapBerry == FALSE
        && battleCtx->battleMons[victim].moveEffectsData.quickClaw == FALSE
        && BattleSystem_CanStealItem(battleSys, battleCtx, victim);
}

BOOL BattleSystem_TriggerAbilityOnHit(BattleSystem *battleSys, BattleContext *battleCtx, int *subscript)
{
    BOOL result = FALSE;

    // These two sentinels must be separate to match
    if (battleCtx->defender == BATTLER_NONE) {
        return result;
    }

    if (Battler_SubstituteWasHit(battleCtx, battleCtx->defender) == TRUE) {
        return result;
    }

    // Sovereign (item 11): Magician (the attacker's ability) takes the held item of a Pokemon its damaging move hits.
    if (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_MAGICIAN
        && ATTACKING_MON.curHP
        && battleCtx->attacker != battleCtx->defender
        && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
        && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
        && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
        && Sovereign_CanTakeItem(battleSys, battleCtx, battleCtx->attacker, battleCtx->defender)) {
        battleCtx->msgBattlerTemp = battleCtx->attacker;
        battleCtx->sideEffectMon = battleCtx->defender;
        battleCtx->msgItemTemp = DEFENDING_MON.heldItem;
        *subscript = subscript_sovereign_take_item;
        return TRUE;
    }

    // Sovereign (item 11): Toxic Chain (the attacker's ability) has a 30% chance to badly poison a Pokemon its
    // damaging move hits. subscript_badly_poison treats it as a move's added effect, so Shield Dust stops it too.
    if (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_TOXIC_CHAIN
        && DEFENDING_MON.curHP
        && DEFENDING_MON.status == MON_CONDITION_NONE
        && battleCtx->attacker != battleCtx->defender
        && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
        && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
        && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
        && BattleSystem_RandNext(battleSys) % 10 < 3) {
        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;
        battleCtx->sideEffectMon = battleCtx->defender;
        *subscript = subscript_badly_poison;
        return TRUE;
    }

    // Sovereign (item 11): Poison Touch (the attacker's ability) has a 30% chance to poison a Pokemon it hits with a
    // contact move. subscript_poison checks the target's immunities.
    if (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_POISON_TOUCH
        && DEFENDING_MON.curHP
        && DEFENDING_MON.status == MON_CONDITION_NONE
        && battleCtx->attacker != battleCtx->defender
        && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
        && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
        && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
        && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)
        && BattleSystem_RandNext(battleSys) % 10 < 3) {
        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
        battleCtx->sideEffectMon = battleCtx->defender;
        battleCtx->msgBattlerTemp = battleCtx->attacker;
        *subscript = subscript_poison;
        return TRUE;
    }

    switch (Battler_Ability(battleCtx, battleCtx->defender)) {
    case ABILITY_STATIC:
        if (ATTACKING_MON.curHP
            && ATTACKING_MON.status == MON_CONDITION_NONE
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)
            && BattleSystem_RandNext(battleSys) % 10 < 3) {
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->attacker;
            battleCtx->msgBattlerTemp = battleCtx->defender;

            *subscript = subscript_paralyze;
            result = TRUE;
        }
        break;

    case ABILITY_COLOR_CHANGE:
        u8 moveType;

        moveType = Sovereign_AbilityMoveType(Battler_Ability(battleCtx, battleCtx->attacker), battleCtx->moveCur, battleCtx->moveType ? battleCtx->moveType : CURRENT_MOVE_DATA.type); // Sovereign (item 11)
        moveType = Sovereign_ElectrifyType(battleCtx, battleCtx->attacker, battleCtx->moveCur, moveType);

        if (DEFENDING_MON.curHP
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && battleCtx->moveCur != MOVE_STRUGGLE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
            && CURRENT_MOVE_DATA.power
            && BattleMon_Get(battleCtx, battleCtx->defender, BATTLEMON_TYPE_1, NULL) != moveType
            && BattleMon_Get(battleCtx, battleCtx->defender, BATTLEMON_TYPE_2, NULL) != moveType) {
            *subscript = subscript_color_change;
            battleCtx->msgTemp = moveType;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): abilities that raise (or, for Weak Armor, change) the holder's stats when a damaging move
    // hits it, as long as it is still standing. They use subscript_update_stat_stage with the ability as the source.
    case ABILITY_JUSTIFIED:
    case ABILITY_RATTLED:
    case ABILITY_WATER_COMPACTION:
    case ABILITY_THERMAL_EXCHANGE:
    case ABILITY_STEAM_ENGINE:
    case ABILITY_WEAK_ARMOR: {
        int hitType = battleCtx->moveType ? battleCtx->moveType : CURRENT_MOVE_DATA.type;
        int ability = Battler_Ability(battleCtx, battleCtx->defender);
        int param = 0;

        if (DEFENDING_MON.curHP == 0
            || (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS)
            || (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN)
            || (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken) == FALSE) {
            break;
        }

        if (ability == ABILITY_JUSTIFIED && hitType == TYPE_DARK
            && DEFENDING_MON.statBoosts[BATTLE_STAT_ATTACK] < MAX_STAT_STAGE) {
            param = MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE;
        } else if (ability == ABILITY_RATTLED && (hitType == TYPE_BUG || hitType == TYPE_GHOST || hitType == TYPE_DARK)
            && DEFENDING_MON.statBoosts[BATTLE_STAT_SPEED] < MAX_STAT_STAGE) {
            param = MOVE_SUBSCRIPT_PTR_SPEED_UP_1_STAGE;
        } else if (ability == ABILITY_WATER_COMPACTION && hitType == TYPE_WATER
            && DEFENDING_MON.statBoosts[BATTLE_STAT_DEFENSE] < MAX_STAT_STAGE) {
            param = MOVE_SUBSCRIPT_PTR_DEFENSE_UP_2_STAGES;
        } else if (ability == ABILITY_THERMAL_EXCHANGE && hitType == TYPE_FIRE
            && DEFENDING_MON.statBoosts[BATTLE_STAT_ATTACK] < MAX_STAT_STAGE) {
            param = MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE;
        } else if (ability == ABILITY_STEAM_ENGINE && (hitType == TYPE_FIRE || hitType == TYPE_WATER)
            && DEFENDING_MON.statBoosts[BATTLE_STAT_SPEED] < MAX_STAT_STAGE) {
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->defender;
            *subscript = subscript_sovereign_steam_engine;
            result = TRUE;
            break;
        } else if (ability == ABILITY_WEAK_ARMOR && CURRENT_MOVE_DATA.class == CLASS_PHYSICAL) {
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->defender;
            *subscript = subscript_sovereign_weak_armor;
            result = TRUE;
            break;
        }

        if (param) {
            battleCtx->sideEffectParam = param;
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->defender;
            *subscript = subscript_update_stat_stage;
            result = TRUE;
        }
        break;
    }

    // Sovereign (item 11): Seed Sower sets Grassy Terrain when a damaging move hits the holder.
    case ABILITY_SEED_SOWER:
        if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && (battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN_GRASSY) == FALSE) {
            battleCtx->fieldConditionsMask &= ~(FIELD_CONDITION_TERRAIN | FIELD_CONDITION_TERRAIN_TURNS);
            battleCtx->fieldConditionsMask |= FIELD_CONDITION_TERRAIN_GRASSY
                | (DEFENDING_MON.heldItem == ITEM_TERRAIN_EXTENDER ? FIELD_CONDITION_TERRAIN_8_TURNS : FIELD_CONDITION_TERRAIN_5_TURNS);
            *subscript = subscript_sovereign_terrain_start;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Sand Spit whips up a sandstorm when a damaging move hits the holder.
    case ABILITY_SAND_SPIT:
        if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && (battleCtx->fieldConditionsMask & (FIELD_CONDITION_SANDSTORM | FIELD_CONDITION_SOVEREIGN_PRIMAL)) == FALSE) {
            battleCtx->msgBattlerTemp = battleCtx->defender;
            *subscript = subscript_sand_stream;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Stamina raises Defense 1 stage whenever a damaging move hits (contact or not), as long as
    // the holder is still standing.
    // Sovereign (item 11): Berserk raises Sp. Atk, Anger Shell changes five stats, when a hit drops the holder from above
    // half its HP to half or less.
    case ABILITY_BERSERK:
    case ABILITY_ANGER_SHELL:
        if (DEFENDING_MON.curHP
            && DEFENDING_MON.curHP <= DEFENDING_MON.maxHP / 2
            && battleCtx->sovereignHPBeforeHit[battleCtx->defender] > DEFENDING_MON.maxHP / 2
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)) {
            battleCtx->sovereignHPBeforeHit[battleCtx->defender] = DEFENDING_MON.curHP; // once per hit
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->defender;

            if (Battler_Ability(battleCtx, battleCtx->defender) == ABILITY_BERSERK) {
                if (DEFENDING_MON.statBoosts[BATTLE_STAT_SP_ATTACK] < MAX_STAT_STAGE) {
                    battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_SP_ATTACK_UP_1_STAGE;
                    *subscript = subscript_update_stat_stage;
                    result = TRUE;
                }
            } else {
                *subscript = subscript_sovereign_anger_shell;
                result = TRUE;
            }
        }
        break;

    // Sovereign (item 11): Innards Out. When the holder is knocked out by a hit, the attacker loses as much HP as the
    // holder had left.
    case ABILITY_INNARDS_OUT:
        if (battleCtx->defender == battleCtx->faintedMon
            && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_MAGIC_GUARD
            && ATTACKING_MON.curHP
            && battleCtx->sovereignHPBeforeHit[battleCtx->defender]
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE) {
            battleCtx->hpCalcTemp = -battleCtx->sovereignHPBeforeHit[battleCtx->defender];
            battleCtx->sovereignHPBeforeHit[battleCtx->defender] = 0;
            battleCtx->msgBattlerTemp = battleCtx->attacker;
            *subscript = subscript_aftermath; // "{2} was hurt by {0}'s {1}!"
            result = TRUE;
        }
        break;

    case ABILITY_STAMINA:
        if (DEFENDING_MON.curHP
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && DEFENDING_MON.statBoosts[BATTLE_STAT_DEFENSE] < MAX_STAT_STAGE) {
            *subscript = subscript_sovereign_stamina;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Cursed Body has a 30% chance to disable the move that hit it (for 4 turns), unless Aroma Veil
    // guards the attacker.
    case ABILITY_CURSED_BODY:
        if (ATTACKING_MON.curHP
            && battleCtx->attacker != battleCtx->defender
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && ATTACKING_MON.moveEffectsData.disabledMove == MOVE_NONE
            && battleCtx->moveCur != MOVE_STRUGGLE
            && Battler_SlotForMove(&ATTACKING_MON, battleCtx->moveCur) != LEARNED_MOVES_MAX
            && Sovereign_VeilHolder(battleSys, battleCtx, BATTLER_NONE, battleCtx->attacker, ABILITY_AROMA_VEIL) == BATTLER_NONE
            && BattleSystem_RandNext(battleSys) % 10 < 3) {
            ATTACKING_MON.moveEffectsData.disabledMove = battleCtx->moveCur;
            ATTACKING_MON.moveEffectsData.disabledTurns = 4;
            battleCtx->msgMoveTemp = battleCtx->moveCur;
            *subscript = subscript_sovereign_cursed_body;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Electromorphosis (any damaging hit) and Wind Power (a wind move's hit) charge the holder: its
    // next Electric move before the end of next turn has double power, as after Charge.
    case ABILITY_ELECTROMORPHOSIS:
    case ABILITY_WIND_POWER:
        if (DEFENDING_MON.curHP
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && (Battler_Ability(battleCtx, battleCtx->defender) == ABILITY_ELECTROMORPHOSIS || Move_IsWind(battleCtx->moveCur))) {
            battleCtx->msgBattlerTemp = battleCtx->defender;
            *subscript = subscript_sovereign_charged_by_hit;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Pickpocket takes the held item of a Pokemon that makes contact with the holder.
    case ABILITY_PICKPOCKET:
        if (DEFENDING_MON.curHP
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)
            && Sovereign_CanTakeItem(battleSys, battleCtx, battleCtx->defender, battleCtx->attacker)) {
            battleCtx->msgBattlerTemp = battleCtx->defender;
            battleCtx->sideEffectMon = battleCtx->attacker;
            battleCtx->msgItemTemp = ATTACKING_MON.heldItem;
            *subscript = subscript_sovereign_take_item;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Cotton Down lowers the Speed of every other Pokemon on the field when a damaging move hits
    // the holder, even as it faints.
    case ABILITY_COTTON_DOWN:
        if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)) {
            battleCtx->msgBattlerTemp = battleCtx->defender;
            *subscript = subscript_sovereign_cotton_down;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Gooey and Tangling Hair lower the Speed of a Pokemon that makes contact.
    case ABILITY_GOOEY:
    case ABILITY_TANGLING_HAIR:
        if (ATTACKING_MON.curHP
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)
            && ATTACKING_MON.statBoosts[BATTLE_STAT_SPEED] > 0) {
            *subscript = subscript_sovereign_gooey;
            result = TRUE;
        }
        break;

    // Sovereign (FM): Gulp Missile. A Gulping or Gorging Cramorant hit by a damaging move spits its catch at the
    // attacker, even as it faints: 1/4 of the attacker's max HP (not with Magic Guard), then an Arrokuda lowers its
    // Defense and a Pikachu paralyzes it. Cramorant goes back to its base form. Not while it's underwater.
    case ABILITY_GULP_MISSILE:
        if (DEFENDING_MON.species == SPECIES_CRAMORANT
            && Pokemon_SovereignBattleFormBase(DEFENDING_MON.species, DEFENDING_MON.formNum) != DEFENDING_MON.formNum
            && (DEFENDING_MON.statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE
            && (DEFENDING_MON.moveEffectsMask & MOVE_EFFECT_SEMI_INVULNERABLE) == FALSE
            && ATTACKING_MON.curHP
            && battleCtx->attacker != battleCtx->defender
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)) {
            int baseForm = Pokemon_SovereignBattleFormBase(DEFENDING_MON.species, DEFENDING_MON.formNum);

            // MSG_TEMP: 0 for the Gulping Form's Arrokuda, 1 for the Gorging Form's Pikachu.
            battleCtx->msgTemp = DEFENDING_MON.formNum != Pokemon_SovereignAbilityForm(DEFENDING_MON.species, baseForm, ABILITY_GULP_MISSILE);
            battleCtx->hpCalcTemp = Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_MAGIC_GUARD
                ? 0
                : BattleSystem_Divide(ATTACKING_MON.maxHP * -1, 4);
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->attacker;
            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->defender, baseForm);

            *subscript = subscript_sovereign_gulp_missile;
            result = TRUE;
        }
        break;

    case ABILITY_IRON_BARBS: // Sovereign (item 11): same as Rough Skin
    case ABILITY_ROUGH_SKIN:
        if (ATTACKING_MON.curHP
            && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_MAGIC_GUARD
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)) {
            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP * -1, 8);
            battleCtx->msgBattlerTemp = battleCtx->attacker;

            *subscript = subscript_rough_skin;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Mummy and Lingering Aroma pass themselves to an attacker that makes contact; Wandering
    // Spirit swaps abilities with it.
    case ABILITY_MUMMY:
    case ABILITY_LINGERING_AROMA:
    case ABILITY_WANDERING_SPIRIT:
        if (ATTACKING_MON.curHP
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)
            && ATTACKING_MON.ability != DEFENDING_MON.ability
            && Sovereign_AbilityIsFixed(ATTACKING_MON.ability) == FALSE
            && Sovereign_HasAbilityShield(battleCtx, battleCtx->attacker) == FALSE) {
            if (DEFENDING_MON.ability == ABILITY_WANDERING_SPIRIT) {
                // An Ability Shield on the Wandering Spirit holder keeps both Abilities where they are.
                if (DEFENDING_MON.curHP == 0 || Sovereign_HasAbilityShield(battleCtx, battleCtx->defender)) {
                    break;
                }

                DEFENDING_MON.ability = ATTACKING_MON.ability;
                ATTACKING_MON.ability = ABILITY_WANDERING_SPIRIT;
                *subscript = subscript_sovereign_wandering_spirit;
            } else {
                ATTACKING_MON.ability = DEFENDING_MON.ability;
                *subscript = subscript_sovereign_ability_acquired;
            }

            result = TRUE;
        }
        break;

    // Sovereign (item 11): Perish Body gives the holder and an attacker that makes contact a Perish Song count of 3.
    case ABILITY_PERISH_BODY:
        if (ATTACKING_MON.curHP
            && DEFENDING_MON.curHP
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)
            && (ATTACKING_MON.moveEffectsMask & MOVE_EFFECT_PERISH_SONG) == FALSE) {
            ATTACKING_MON.moveEffectsMask |= MOVE_EFFECT_PERISH_SONG;
            ATTACKING_MON.moveEffectsData.perishSongTurns = 3;

            if ((DEFENDING_MON.moveEffectsMask & MOVE_EFFECT_PERISH_SONG) == FALSE) {
                DEFENDING_MON.moveEffectsMask |= MOVE_EFFECT_PERISH_SONG;
                DEFENDING_MON.moveEffectsData.perishSongTurns = 3;
            }

            *subscript = subscript_sovereign_perish_body;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Toxic Debris scatters Toxic Spikes on the attacker's side when a physical move hits the
    // holder (up to 2 layers).
    case ABILITY_TOXIC_DEBRIS: {
        int side = BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker);

        if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken
            && side != BattleSystem_GetBattlerSide(battleSys, battleCtx->defender)
            && battleCtx->sideConditions[side].toxicSpikesLayers < 2) {
            battleCtx->sideConditionsMask[side] |= SIDE_CONDITION_TOXIC_SPIKES;
            battleCtx->sideConditions[side].toxicSpikesLayers++;
            *subscript = subscript_sovereign_toxic_debris;
            result = TRUE;
        }
        break;
    }

    case ABILITY_EFFECT_SPORE: {
        int roll;
        if (ATTACKING_MON.curHP
            && ATTACKING_MON.status == MON_CONDITION_NONE
            && Battler_SovereignPowderImmune(battleCtx, battleCtx->defender, battleCtx->attacker) == FALSE // Sovereign (item 11)
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)
            && (roll = BattleSystem_RandNext(battleSys) % 100) < 30) {
            // Sovereign: 11% sleep, 10% paralysis, 9% poison (Gen V+). Platinum gave each 10%.
            if (roll < 11) {
                *subscript = subscript_fall_asleep;
            } else if (roll < 21) {
                *subscript = subscript_paralyze;
            } else {
                *subscript = subscript_poison;
            }

            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->attacker;
            battleCtx->msgBattlerTemp = battleCtx->defender;

            result = TRUE;
        }
        break;
    }

    case ABILITY_POISON_POINT:
        if (ATTACKING_MON.curHP
            && ATTACKING_MON.status == MON_CONDITION_NONE
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)
            && BattleSystem_RandNext(battleSys) % 10 < 3) {
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->attacker;
            battleCtx->msgBattlerTemp = battleCtx->defender;

            *subscript = subscript_poison;
            result = TRUE;
        }
        break;

    case ABILITY_FLAME_BODY:
        if (ATTACKING_MON.curHP
            && ATTACKING_MON.status == MON_CONDITION_NONE
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)
            && BattleSystem_RandNext(battleSys) % 10 < 3) {
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->attacker;
            battleCtx->msgBattlerTemp = battleCtx->defender;

            *subscript = subscript_burn;
            result = TRUE;
        }
        break;

    // Sovereign (item 11): Spicy Spray burns the attacker whenever a damaging move hits the holder, contact or not, even
    // if the hit knocks the holder out.
    case ABILITY_SPICY_SPRAY:
        if (ATTACKING_MON.curHP
            && ATTACKING_MON.status == MON_CONDITION_NONE
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)) {
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->attacker;
            battleCtx->msgBattlerTemp = battleCtx->defender;

            *subscript = subscript_burn;
            result = TRUE;
        }
        break;

    case ABILITY_CUTE_CHARM:
        if (ATTACKING_MON.curHP
            && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_ATTRACT) == FALSE
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
            && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)
            && DEFENDING_MON.curHP
            && Sovereign_VeilHolder(battleSys, battleCtx, BATTLER_NONE, battleCtx->attacker, ABILITY_AROMA_VEIL) == BATTLER_NONE // Sovereign (item 11)
            && BattleSystem_RandNext(battleSys) % 10 < 3) {
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
            battleCtx->sideEffectMon = battleCtx->attacker;
            battleCtx->msgBattlerTemp = battleCtx->defender;

            *subscript = subscript_infatuate;
            result = TRUE;
        }
        break;

    case ABILITY_AFTERMATH:
        if (battleCtx->defender == battleCtx->faintedMon
            && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_MAGIC_GUARD
            && BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS, 0, ABILITY_DAMP) == 0
            && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
            && ATTACKING_MON.curHP
            && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)) {
            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP * -1, 4);
            battleCtx->msgBattlerTemp = battleCtx->attacker;

            *subscript = subscript_aftermath;
            result = TRUE;
        }
        break;
    }

    return result;
}

BOOL BattleSystem_RecoverStatusByAbility(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int skipLoad)
{
    BOOL result = FALSE;

    switch (Battler_Ability(battleCtx, battler)) {
    case ABILITY_IMMUNITY:
    case ABILITY_PASTEL_VEIL: // Sovereign (item 11)
        if (battleCtx->battleMons[battler].status & MON_CONDITION_ANY_POISON) {
            battleCtx->msgTemp = MSGCOND_POISON;
            result = TRUE;
        }
        break;

    case ABILITY_OWN_TEMPO:
        if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CONFUSION) {
            battleCtx->msgTemp = MSGCOND_CONFUSION;
            result = TRUE;
        }
        break;

    case ABILITY_LIMBER:
        if (battleCtx->battleMons[battler].status & MON_CONDITION_PARALYSIS) {
            battleCtx->msgTemp = MSGCOND_PARALYSIS;
            result = TRUE;
        }
        break;

    case ABILITY_INSOMNIA:
    case ABILITY_VITAL_SPIRIT:
    case ABILITY_SWEET_VEIL: // Sovereign (item 11)
        if (battleCtx->battleMons[battler].status & MON_CONDITION_SLEEP) {
            battleCtx->msgTemp = MSGCOND_SLEEP;
            result = TRUE;
        }
        break;

    case ABILITY_WATER_VEIL:
    case ABILITY_WATER_BUBBLE: // Sovereign (item 11)
    case ABILITY_THERMAL_EXCHANGE: // Sovereign (item 11)
        if (battleCtx->battleMons[battler].status & MON_CONDITION_BURN) {
            battleCtx->msgTemp = MSGCOND_BURN;
            result = TRUE;
        }
        break;

    case ABILITY_MAGMA_ARMOR:
        if (battleCtx->battleMons[battler].status & MON_CONDITION_FREEZE) {
            battleCtx->msgTemp = MSGCOND_FREEZE;
            result = TRUE;
        }
        break;

    case ABILITY_OBLIVIOUS:
        if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_ATTRACT) {
            battleCtx->msgTemp = MSGCOND_INFATUATION;
            result = TRUE;
        }
        break;

    case ABILITY_UNBURDEN:
        if (battleCtx->battleMons[battler].heldItem) {
            battleCtx->battleMons[battler].moveEffectsData.canUnburden = TRUE;
        }
        break;
    }

    if (result == TRUE) {
        battleCtx->msgBattlerTemp = battler;
        battleCtx->msgAbilityTemp = Battler_Ability(battleCtx, battler);

        if (skipLoad == FALSE) {
            LOAD_SUBSEQ(subscript_ability_forbids_status);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        }
    }

    return result;
}

BOOL Ability_ForbidsStatus(BattleContext *battleSys, int ability, int status)
{
    BOOL result = FALSE;

    switch (ability) {
    case ABILITY_IMMUNITY:
    case ABILITY_PASTEL_VEIL: // Sovereign (item 11)
        if (status & MON_CONDITION_ANY_POISON) {
            result = TRUE;
        }
        break;

    case ABILITY_LIMBER:
        if (status & MON_CONDITION_PARALYSIS) {
            result = TRUE;
        }
        break;

    case ABILITY_INSOMNIA:
    case ABILITY_VITAL_SPIRIT:
    case ABILITY_SWEET_VEIL: // Sovereign (item 11)
        if (status & MON_CONDITION_SLEEP) {
            result = TRUE;
        }
        break;

    case ABILITY_WATER_VEIL:
    case ABILITY_WATER_BUBBLE: // Sovereign (item 11)
    case ABILITY_THERMAL_EXCHANGE: // Sovereign (item 11)
        if (status & MON_CONDITION_BURN) {
            result = TRUE;
        }
        break;

    case ABILITY_MAGMA_ARMOR:
        if (status & MON_CONDITION_FREEZE) {
            result = TRUE;
        }
        break;
    }

    return result;
}

BOOL BattleSystem_SynchronizeStatus(BattleSystem *battleSys, BattleContext *battleCtx, int controllerCommand)
{
    BOOL result = FALSE;
    int nextSeq = 0;

    if (battleCtx->defender != BATTLER_NONE
        && Battler_Ability(battleCtx, battleCtx->defender) == ABILITY_SYNCHRONIZE
        && battleCtx->defender == battleCtx->sideEffectMon
        && (battleCtx->battleStatusMask & SYSCTL_TRY_SYNCHRONIZE_STATUS)) {
        battleCtx->msgBattlerTemp = battleCtx->defender;
        battleCtx->sideEffectMon = battleCtx->attacker;
        result = TRUE;
    } else if (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_SYNCHRONIZE
        && battleCtx->attacker == battleCtx->sideEffectMon
        && (battleCtx->battleStatusMask & SYSCTL_TRY_SYNCHRONIZE_STATUS)) {
        // This will try to synchronize a status applied from an ability or item held
        // by the defender, e.g. Static.
        battleCtx->msgBattlerTemp = battleCtx->attacker;
        battleCtx->sideEffectMon = battleCtx->defender;
        result = TRUE;
    }

    if (result == TRUE) {
        // Sovereign: bad poisoning is passed on as bad poisoning (Gen V+), not as plain poison.
        if (battleCtx->battleMons[battleCtx->msgBattlerTemp].status & MON_CONDITION_TOXIC) {
            nextSeq = subscript_sovereign_synchronize_toxic;
        } else if (battleCtx->battleMons[battleCtx->msgBattlerTemp].status & MON_CONDITION_ANY_POISON) {
            nextSeq = subscript_poison;
        } else if (battleCtx->battleMons[battleCtx->msgBattlerTemp].status & MON_CONDITION_BURN) {
            nextSeq = subscript_burn;
        } else if (battleCtx->battleMons[battleCtx->msgBattlerTemp].status & MON_CONDITION_PARALYSIS) {
            nextSeq = subscript_paralyze;
        }

        if (nextSeq) {
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;

            LOAD_SUBSEQ(nextSeq);
            battleCtx->commandNext = controllerCommand;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

            return result;
        }
    }

    // Check for Freeze application to Shaymin-Sky (which would revert to Shaymin-Land).
    result = BattleSystem_TriggerFormChange(battleSys, battleCtx, &nextSeq);
    if (result == TRUE) {
        LOAD_SUBSEQ(nextSeq);
        battleCtx->commandNext = controllerCommand;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

        return result;
    }

    if (battleCtx->defender != BATTLER_NONE
        && Battler_HeldItemEffect(battleCtx, battleCtx->defender) == HOLD_EFFECT_RECIPROCATE_INFAT
        && battleCtx->defender == battleCtx->sideEffectMon
        && (DEFENDER_SELF_TURN_FLAGS.statusFlags & SELF_TURN_FLAG_INFATUATED)) {
        battleCtx->msgBattlerTemp = battleCtx->defender;
        battleCtx->sideEffectMon = battleCtx->attacker;
        result = TRUE;
    } else if (Battler_HeldItemEffect(battleCtx, battleCtx->attacker) == HOLD_EFFECT_RECIPROCATE_INFAT
        && battleCtx->attacker == battleCtx->sideEffectMon
        && (ATTACKER_SELF_TURN_FLAGS.statusFlags & SELF_TURN_FLAG_INFATUATED)) {
        // This should only happen if the defender triggered Cute Charm.
        battleCtx->msgBattlerTemp = battleCtx->attacker;
        battleCtx->sideEffectMon = battleCtx->defender;
        result = TRUE;
    }

    if (result == TRUE) {
        nextSeq = subscript_infatuate;
        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_HELD_ITEM;

        LOAD_SUBSEQ(nextSeq);
        battleCtx->commandNext = controllerCommand;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

        return result; // This line has to stay to match.
    }

    return FALSE;
}

// Sovereign (item 11): a standing foe with Unnerve (or As One) stops this battler from eating its Berry.
BOOL Battler_UnnerveBlocksBerry(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    if (Item_IsBerry(battleCtx->battleMons[battler].heldItem) == FALSE) {
        return FALSE;
    }

    for (int i = 0; i < BattleSystem_GetMaxBattlers(battleSys); i++) {
        int ability = Battler_Ability(battleCtx, i);

        if (battleCtx->battleMons[i].curHP
            && BattleSystem_GetBattlerSide(battleSys, i) != BattleSystem_GetBattlerSide(battleSys, battler)
            && (ability == ABILITY_UNNERVE || ability == ABILITY_AS_ONE_GLASTRIER || ability == ABILITY_AS_ONE_SPECTRIER)) {
            return TRUE;
        }
    }

    return FALSE;
}

// Sovereign (item 11): Ripen doubles the HP a Berry restores. (subscript_held_item_raise_stat doubles a Berry's stat
// rise.)
static void Sovereign_RipenBerryHP(BattleContext *battleCtx, int battler, int subscript)
{
    if (Battler_Ability(battleCtx, battler) == ABILITY_RIPEN
        && Item_IsBerry(battleCtx->battleMons[battler].heldItem)
        && (subscript == subscript_held_item_hp_restore || subscript == subscript_held_item_dislike_flavor)) {
        battleCtx->hpCalcTemp *= 2;
    }
}

// Sovereign: Figy, Wiki, Mago, Aguav and Iapapa Berries are eaten at 1/4 of the holder's max HP, or 1/2 with Gluttony
// (Gen VII+), and restore 1/3 (the item data). Platinum ate them at 1/2 and restored 1/8.
static BOOL Sovereign_PinchBerryHP(BattleContext *battleCtx, int battler)
{
    int divisor = Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY ? 2 : 4;

    return battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / divisor;
}

// Sovereign: the Mental Herb cures infatuation, Taunt, Encore, Torment, Disable and Heal Block (Gen V+;
// subscript_sovereign_mental_herb). Platinum's only cured infatuation.
static BOOL Sovereign_MentalHerbCures(BattleMon *mon)
{
    return (mon->statusVolatile & (VOLATILE_CONDITION_ATTRACT | VOLATILE_CONDITION_TORMENT))
        || mon->moveEffectsData.tauntedTurns
        || mon->moveEffectsData.encoredMove
        || mon->moveEffectsData.disabledMove
        || mon->moveEffectsData.healBlockTurns;
}

BOOL BattleSystem_TriggerHeldItem(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    BOOL result = FALSE;
    int subscript;
    int itemEffect = Battler_HeldItemEffect(battleCtx, battler);
    int itemPower = Battler_HeldItemPower(battleCtx, battler, ITEM_POWER_CHECK_ALL);

    if (Battler_UnnerveBlocksBerry(battleSys, battleCtx, battler)) { // Sovereign (item 11)
        return FALSE;
    }

    if (battleCtx->battleMons[battler].curHP) {
        switch (itemEffect) {
        case HOLD_EFFECT_HP_RESTORE:
            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / 2) {
                battleCtx->hpCalcTemp = itemPower;
                subscript = subscript_held_item_hp_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_PCT_RESTORE:
            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / 2) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP * itemPower, 100);
                subscript = subscript_held_item_hp_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PRZ_RESTORE:
            if (battleCtx->battleMons[battler].status & MON_CONDITION_PARALYSIS) {
                subscript = subscript_held_item_prz_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_SLP_RESTORE:
            if (battleCtx->battleMons[battler].status & MON_CONDITION_SLEEP) {
                subscript = subscript_held_item_slp_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PSN_RESTORE:
            if (battleCtx->battleMons[battler].status & MON_CONDITION_ANY_POISON) {
                subscript = subscript_held_item_psn_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_BRN_RESTORE:
            if (battleCtx->battleMons[battler].status & MON_CONDITION_BURN) {
                subscript = subscript_held_item_brn_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_FRZ_RESTORE:
            if (battleCtx->battleMons[battler].status & MON_CONDITION_FREEZE) {
                subscript = subscript_held_item_frz_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PP_RESTORE: {
            int i;
            for (i = 0; i < LEARNED_MOVES_MAX; i++) {
                if (battleCtx->battleMons[battler].moves[i] && battleCtx->battleMons[battler].ppCur[i] == 0) {
                    break;
                }
            }

            if (i != LEARNED_MOVES_MAX) {
                // Sovereign (item 11): Ripen doubles the PP a Leppa Berry restores.
                BattleMon_AddVal(&battleCtx->battleMons[battler], BATTLEMON_CUR_PP_1 + i, Battler_Ability(battleCtx, battler) == ABILITY_RIPEN ? itemPower * 2 : itemPower);
                BattleMon_CopyToParty(battleSys, battleCtx, battler);
                battleCtx->msgMoveTemp = battleCtx->battleMons[battler].moves[i];
                subscript = subscript_held_item_pp_restore;
                result = TRUE;
            }

            break;
        }

        case HOLD_EFFECT_CONFUSE_RESTORE:
            if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CONFUSION) {
                subscript = subscript_held_item_cnf_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_STATUS_RESTORE:
            if ((battleCtx->battleMons[battler].status & MON_CONDITION_ANY)
                || (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CONFUSION)) {
                if (battleCtx->battleMons[battler].status & MON_CONDITION_PARALYSIS) {
                    subscript = subscript_held_item_prz_restore;
                }

                if (battleCtx->battleMons[battler].status & MON_CONDITION_SLEEP) {
                    subscript = subscript_held_item_slp_restore;
                }

                if (battleCtx->battleMons[battler].status & MON_CONDITION_ANY_POISON) {
                    subscript = subscript_held_item_psn_restore;
                }

                if (battleCtx->battleMons[battler].status & MON_CONDITION_BURN) {
                    subscript = subscript_held_item_brn_restore;
                }

                if (battleCtx->battleMons[battler].status & MON_CONDITION_FREEZE) {
                    subscript = subscript_held_item_frz_restore;
                }

                if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CONFUSION) {
                    subscript = subscript_held_item_cnf_restore;
                }

                if ((battleCtx->battleMons[battler].status & MON_CONDITION_ANY)
                    && (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CONFUSION)) {
                    subscript = subscript_held_item_multi_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_SPICY:
            if (Sovereign_PinchBerryHP(battleCtx, battler)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, itemPower);
                battleCtx->msgTemp = FLAVOR_SPICY;

                if (Pokemon_GetFlavorAffinityOf(battleCtx->battleMons[battler].personality, FLAVOR_SPICY) == -1) {
                    subscript = subscript_held_item_dislike_flavor;
                } else {
                    subscript = subscript_held_item_hp_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_DRY:
            if (Sovereign_PinchBerryHP(battleCtx, battler)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, itemPower);
                battleCtx->msgTemp = FLAVOR_DRY;

                if (Pokemon_GetFlavorAffinityOf(battleCtx->battleMons[battler].personality, FLAVOR_DRY) == -1) {
                    subscript = subscript_held_item_dislike_flavor;
                } else {
                    subscript = subscript_held_item_hp_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_SWEET:
            if (Sovereign_PinchBerryHP(battleCtx, battler)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, itemPower);
                battleCtx->msgTemp = FLAVOR_SWEET;

                if (Pokemon_GetFlavorAffinityOf(battleCtx->battleMons[battler].personality, FLAVOR_SWEET) == -1) {
                    subscript = subscript_held_item_dislike_flavor;
                } else {
                    subscript = subscript_held_item_hp_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_BITTER:
            if (Sovereign_PinchBerryHP(battleCtx, battler)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, itemPower);
                battleCtx->msgTemp = FLAVOR_BITTER;

                if (Pokemon_GetFlavorAffinityOf(battleCtx->battleMons[battler].personality, FLAVOR_BITTER) == -1) {
                    subscript = subscript_held_item_dislike_flavor;
                } else {
                    subscript = subscript_held_item_hp_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_SOUR:
            if (Sovereign_PinchBerryHP(battleCtx, battler)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, itemPower);
                battleCtx->msgTemp = FLAVOR_SOUR;

                if (Pokemon_GetFlavorAffinityOf(battleCtx->battleMons[battler].personality, FLAVOR_SOUR) == -1) {
                    subscript = subscript_held_item_dislike_flavor;
                } else {
                    subscript = subscript_held_item_hp_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_ATK_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_ATTACK] < MAX_STAT_STAGE) {
                battleCtx->msgTemp = BATTLE_STAT_ATTACK;
                subscript = subscript_held_item_raise_stat;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_DEF_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_DEFENSE] < MAX_STAT_STAGE) {
                battleCtx->msgTemp = BATTLE_STAT_DEFENSE;
                subscript = subscript_held_item_raise_stat;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_SPEED_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_SPEED] < MAX_STAT_STAGE) {
                battleCtx->msgTemp = BATTLE_STAT_SPEED;
                subscript = subscript_held_item_raise_stat;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_SPATK_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_SP_ATTACK] < MAX_STAT_STAGE) {
                battleCtx->msgTemp = BATTLE_STAT_SP_ATTACK;
                subscript = subscript_held_item_raise_stat;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_SPDEF_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_SP_DEFENSE] < MAX_STAT_STAGE) {
                battleCtx->msgTemp = BATTLE_STAT_SP_DEFENSE;
                subscript = subscript_held_item_raise_stat;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_CRITRATE_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_FOCUS_ENERGY) == FALSE) {
                subscript = subscript_held_item_raise_crit;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_RANDOM_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= (battleCtx->battleMons[battler].maxHP / itemPower)) {
                int i;
                for (i = 0; i < 5; i++) {
                    if (battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_ATTACK + i] < MAX_STAT_STAGE) {
                        break;
                    }
                }

                if (i != 5) {
                    do {
                        i = BattleSystem_RandNext(battleSys) % 5;
                    } while (battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_ATTACK + i] == MAX_STAT_STAGE);

                    battleCtx->msgTemp = BATTLE_STAT_ATTACK + i;
                    subscript = subscript_held_item_sharply_raise_stat;
                    result = TRUE;
                }
            }
            break;

        case HOLD_EFFECT_STATDOWN_RESTORE: {
            for (int i = BATTLE_STAT_HP; i < BATTLE_STAT_MAX; i++) {
                if (battleCtx->battleMons[battler].statBoosts[i] < DEFAULT_STAT_STAGE) {
                    battleCtx->battleMons[battler].statBoosts[i] = DEFAULT_STAT_STAGE;
                    result = TRUE;
                }
            }

            if (result == TRUE) {
                subscript = subscript_held_item_statdown_restore;
            }
            break;
        }

        case HOLD_EFFECT_HEAL_INFATUATION:
            if (Sovereign_MentalHerbCures(&battleCtx->battleMons[battler])) {
                battleCtx->msgTemp = MSGCOND_INFATUATION;
                subscript = subscript_sovereign_mental_herb;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_ACC_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower) {
                subscript = subscript_held_item_temp_acc_up;
                result = TRUE;
            }
            break;
        }

        // Sovereign: under Heal Block an HP Berry isn't eaten (Gen V+).
        if (result == TRUE && Sovereign_IsHPRestoreSubscript(subscript) && Sovereign_HealBlocked(battleCtx, battler)) {
            result = FALSE;
        }

        if (result == TRUE) {
            battleCtx->msgBattlerTemp = battler;
            battleCtx->msgItemTemp = Battler_HeldItem(battleCtx, battler);
            Sovereign_RipenBerryHP(battleCtx, battler, subscript); // Sovereign (item 11)

            LOAD_SUBSEQ(subscript);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        }
    }

    return result;
}

BOOL BattleSystem_TriggerLeftovers(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    BOOL result = 0;
    int subscript;
    int itemEffect = Battler_HeldItemEffect(battleCtx, battler);
    int itemPower = Battler_HeldItemPower(battleCtx, battler, ITEM_POWER_CHECK_ALL);

    if (battleCtx->battleMons[battler].curHP) {
        switch (itemEffect) {
        case HOLD_EFFECT_HP_RESTORE_GRADUAL:
            if (battleCtx->battleMons[battler].curHP < (battleCtx->battleMons[battler].maxHP)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, 16);
                subscript = subscript_restore_a_little_hp;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_PSN_TYPE:
            if (MON_HAS_TYPE(battler, TYPE_POISON)) {
                if (battleCtx->battleMons[battler].curHP < (battleCtx->battleMons[battler].maxHP)) {
                    battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, 16);
                    subscript = subscript_restore_a_little_hp;
                    result = TRUE;
                }
            } else if (Battler_Ability(battleCtx, battler) != ABILITY_MAGIC_GUARD) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP * -1, 8);
                subscript = subscript_lose_hp_from_item_with_message;
                result = TRUE;
            }
            break;
        }

        // Sovereign: under Heal Block, Leftovers and Black Sludge restore nothing (Gen V+). Black Sludge still hurts.
        if (result == TRUE && subscript == subscript_restore_a_little_hp && Sovereign_HealBlocked(battleCtx, battler)) {
            result = FALSE;
        }

        if (result == TRUE) {
            battleCtx->msgBattlerTemp = battler;
            battleCtx->msgItemTemp = Battler_HeldItem(battleCtx, battler);

            LOAD_SUBSEQ(subscript);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        }
    }

    return result;
}

BOOL BattleSystem_TriggerHeldItemOnStatus(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int *subscript)
{
    BOOL result = FALSE;
    int itemEffect = Battler_HeldItemEffect(battleCtx, battler);
    int itemPower = Battler_HeldItemPower(battleCtx, battler, ITEM_POWER_CHECK_ALL);

    if (Battler_UnnerveBlocksBerry(battleSys, battleCtx, battler)) { // Sovereign (item 11)
        return FALSE;
    }

    if (battleCtx->battleMons[battler].curHP) {
        switch (itemEffect) {
        case HOLD_EFFECT_HP_RESTORE:
            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / 2) {
                battleCtx->hpCalcTemp = itemPower;
                *subscript = subscript_held_item_hp_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_PCT_RESTORE:
            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / 2) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP * itemPower, 100);
                *subscript = subscript_held_item_hp_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PRZ_RESTORE:
            if (battleCtx->battleMons[battler].status & MON_CONDITION_PARALYSIS) {
                *subscript = subscript_held_item_prz_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_SLP_RESTORE:
            if (battleCtx->battleMons[battler].status & MON_CONDITION_SLEEP) {
                *subscript = subscript_held_item_slp_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PSN_RESTORE:
            if (battleCtx->battleMons[battler].status & MON_CONDITION_ANY_POISON) {
                *subscript = subscript_held_item_psn_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_BRN_RESTORE:
            if (battleCtx->battleMons[battler].status & MON_CONDITION_BURN) {
                *subscript = subscript_held_item_brn_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_FRZ_RESTORE:
            if (battleCtx->battleMons[battler].status & MON_CONDITION_FREEZE) {
                *subscript = subscript_held_item_frz_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PP_RESTORE: {
            int i;
            for (i = 0; i < LEARNED_MOVES_MAX; i++) {
                if (battleCtx->battleMons[battler].moves[i] && battleCtx->battleMons[battler].ppCur[i] == 0) {
                    break;
                }
            }

            if (i != LEARNED_MOVES_MAX) {
                // Sovereign (item 11): Ripen doubles the PP a Leppa Berry restores.
                BattleMon_AddVal(&battleCtx->battleMons[battler], BATTLEMON_CUR_PP_1 + i, Battler_Ability(battleCtx, battler) == ABILITY_RIPEN ? itemPower * 2 : itemPower);
                BattleMon_CopyToParty(battleSys, battleCtx, battler);
                battleCtx->msgMoveTemp = battleCtx->battleMons[battler].moves[i];
                *subscript = subscript_held_item_pp_restore;
                result = TRUE;
            }

            break;
        }

        case HOLD_EFFECT_CONFUSE_RESTORE:
            if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CONFUSION) {
                *subscript = subscript_held_item_cnf_restore;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_STATUS_RESTORE:
            if ((battleCtx->battleMons[battler].status & MON_CONDITION_ANY)
                || (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CONFUSION)) {
                if (battleCtx->battleMons[battler].status & MON_CONDITION_PARALYSIS) {
                    *subscript = subscript_held_item_prz_restore;
                }

                if (battleCtx->battleMons[battler].status & MON_CONDITION_SLEEP) {
                    *subscript = subscript_held_item_slp_restore;
                }

                if (battleCtx->battleMons[battler].status & MON_CONDITION_ANY_POISON) {
                    *subscript = subscript_held_item_psn_restore;
                }

                if (battleCtx->battleMons[battler].status & MON_CONDITION_BURN) {
                    *subscript = subscript_held_item_brn_restore;
                }

                if (battleCtx->battleMons[battler].status & MON_CONDITION_FREEZE) {
                    *subscript = subscript_held_item_frz_restore;
                }

                if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CONFUSION) {
                    *subscript = subscript_held_item_cnf_restore;
                }

                if ((battleCtx->battleMons[battler].status & MON_CONDITION_ANY)
                    && (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CONFUSION)) {
                    *subscript = subscript_held_item_multi_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_STATDOWN_RESTORE: {
            for (int i = BATTLE_STAT_HP; i < BATTLE_STAT_MAX; i++) {
                if (battleCtx->battleMons[battler].statBoosts[i] < DEFAULT_STAT_STAGE) {
                    battleCtx->battleMons[battler].statBoosts[i] = DEFAULT_STAT_STAGE;
                    result = TRUE;
                }
            }

            if (result == TRUE) {
                *subscript = subscript_held_item_statdown_restore;
            }
            break;
        }

        case HOLD_EFFECT_HEAL_INFATUATION:
            if (Sovereign_MentalHerbCures(&battleCtx->battleMons[battler])) {
                battleCtx->msgTemp = MSGCOND_INFATUATION;
                *subscript = subscript_sovereign_mental_herb;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_ACC_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower) {
                *subscript = subscript_held_item_temp_acc_up;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_SPICY:
            if (Sovereign_PinchBerryHP(battleCtx, battler)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, itemPower);
                battleCtx->msgTemp = FLAVOR_SPICY;

                if (Pokemon_GetFlavorAffinityOf(battleCtx->battleMons[battler].personality, FLAVOR_SPICY) == -1) {
                    *subscript = subscript_held_item_dislike_flavor;
                } else {
                    *subscript = subscript_held_item_hp_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_DRY:
            if (Sovereign_PinchBerryHP(battleCtx, battler)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, itemPower);
                battleCtx->msgTemp = FLAVOR_DRY;

                if (Pokemon_GetFlavorAffinityOf(battleCtx->battleMons[battler].personality, FLAVOR_DRY) == -1) {
                    *subscript = subscript_held_item_dislike_flavor;
                } else {
                    *subscript = subscript_held_item_hp_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_SWEET:
            if (Sovereign_PinchBerryHP(battleCtx, battler)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, itemPower);
                battleCtx->msgTemp = FLAVOR_SWEET;

                if (Pokemon_GetFlavorAffinityOf(battleCtx->battleMons[battler].personality, FLAVOR_SWEET) == -1) {
                    *subscript = subscript_held_item_dislike_flavor;
                } else {
                    *subscript = subscript_held_item_hp_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_BITTER:
            if (Sovereign_PinchBerryHP(battleCtx, battler)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, itemPower);
                battleCtx->msgTemp = FLAVOR_BITTER;

                if (Pokemon_GetFlavorAffinityOf(battleCtx->battleMons[battler].personality, FLAVOR_BITTER) == -1) {
                    *subscript = subscript_held_item_dislike_flavor;
                } else {
                    *subscript = subscript_held_item_hp_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_HP_RESTORE_SOUR:
            if (Sovereign_PinchBerryHP(battleCtx, battler)) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, itemPower);
                battleCtx->msgTemp = FLAVOR_SOUR;

                if (Pokemon_GetFlavorAffinityOf(battleCtx->battleMons[battler].personality, FLAVOR_SOUR) == -1) {
                    *subscript = subscript_held_item_dislike_flavor;
                } else {
                    *subscript = subscript_held_item_hp_restore;
                }

                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_ATK_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_ATTACK] < MAX_STAT_STAGE) {
                battleCtx->msgTemp = BATTLE_STAT_ATTACK;
                *subscript = subscript_held_item_raise_stat;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_DEF_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_DEFENSE] < MAX_STAT_STAGE) {
                battleCtx->msgTemp = BATTLE_STAT_DEFENSE;
                *subscript = subscript_held_item_raise_stat;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_SPEED_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_SPEED] < MAX_STAT_STAGE) {
                battleCtx->msgTemp = BATTLE_STAT_SPEED;
                *subscript = subscript_held_item_raise_stat;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_SPATK_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_SP_ATTACK] < MAX_STAT_STAGE) {
                battleCtx->msgTemp = BATTLE_STAT_SP_ATTACK;
                *subscript = subscript_held_item_raise_stat;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_SPDEF_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_SP_DEFENSE] < MAX_STAT_STAGE) {
                battleCtx->msgTemp = BATTLE_STAT_SP_DEFENSE;
                *subscript = subscript_held_item_raise_stat;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_CRITRATE_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= battleCtx->battleMons[battler].maxHP / itemPower
                && (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_FOCUS_ENERGY) == FALSE) {
                *subscript = subscript_held_item_raise_crit;
                result = TRUE;
            }
            break;

        case HOLD_EFFECT_PINCH_RANDOM_UP:
            if (Battler_Ability(battleCtx, battler) == ABILITY_GLUTTONY) {
                itemPower /= 2;
            }

            if (battleCtx->battleMons[battler].curHP <= (battleCtx->battleMons[battler].maxHP / itemPower)) {
                int i;
                for (i = 0; i < 5; i++) {
                    if (battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_ATTACK + i] < MAX_STAT_STAGE) {
                        break;
                    }
                }

                if (i != 5) {
                    do {
                        i = BattleSystem_RandNext(battleSys) % 5;
                    } while (battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_ATTACK + i] == MAX_STAT_STAGE);

                    battleCtx->msgTemp = BATTLE_STAT_ATTACK + i;
                    *subscript = subscript_held_item_sharply_raise_stat;
                    result = TRUE;
                }
            }
            break;
        }

        // Sovereign: under Heal Block an HP Berry isn't eaten (Gen V+). BattleSystem_TriggerEffectOnSwitch returns
        // *subscript as it stands, so clear it too.
        if (result == TRUE && Sovereign_IsHPRestoreSubscript(*subscript) && Sovereign_HealBlocked(battleCtx, battler)) {
            *subscript = 0;
            result = FALSE;
        }

        if (result == TRUE) {
            battleCtx->msgItemTemp = Battler_HeldItem(battleCtx, battler);
            Sovereign_RipenBerryHP(battleCtx, battler, *subscript); // Sovereign (item 11)
        }
    }

    return result;
}

BOOL BattleSystem_TriggerDetrimentalHeldItem(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    BOOL result = FALSE;
    int subscript;
    int itemEffect = Battler_HeldItemEffect(battleCtx, battler);
    int itemPower = Battler_HeldItemPower(battleCtx, battler, 0);

    if (battleCtx->battleMons[battler].curHP) {
        switch (itemEffect) {
        case HOLD_EFFECT_PSN_USER:
            battleCtx->sideEffectMon = battler;
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_HELD_ITEM;
            subscript = subscript_badly_poison;
            result = TRUE;
            break;

        case HOLD_EFFECT_BRN_USER:
            battleCtx->sideEffectMon = battler;
            battleCtx->sideEffectType = SIDE_EFFECT_TYPE_HELD_ITEM;
            subscript = subscript_burn;
            result = TRUE;
            break;

        case HOLD_EFFECT_DMG_USER_CONTACT_XFR:
            if (Battler_Ability(battleCtx, battler) != ABILITY_MAGIC_GUARD) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP * -1, itemPower);
                subscript = subscript_lose_hp_from_item_with_message;
                result = TRUE;
            }
            break;
        }

        if (result == TRUE) {
            battleCtx->msgBattlerTemp = battler;
            battleCtx->msgItemTemp = Battler_HeldItem(battleCtx, battler);

            LOAD_SUBSEQ(subscript);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        }
    }

    return result;
}

u16 Battler_HeldItem(BattleContext *battleCtx, int battler)
{
    if (Battler_Ability(battleCtx, battler) == ABILITY_KLUTZ) {
        return ITEM_NONE;
    }

    // Sovereign (item 11): no held item has any effect in Magic Room.
    if (battleCtx->sovereignMagicRoomTurns) {
        return ITEM_NONE;
    }

    if (battleCtx->battleMons[battler].moveEffectsData.embargoTurns) {
        return ITEM_NONE;
    }

    return battleCtx->battleMons[battler].heldItem;
}

BOOL Battler_MovedThisTurn(BattleContext *battleCtx, int battler)
{
    return battleCtx->battlerActions[battler][BATTLE_ACTION_PICK_COMMAND] == BATTLE_CONTROL_MOVE_END;
}

// Sovereign (item 11): the held items that raise their holder's stats once when a damaging move hits it, then are
// used up: Weakness Policy (a super-effective hit: Attack and Sp. Atk +2), Absorb Bulb (Water: Sp. Atk +1), Cell Battery
// (Electric: Attack +1), Luminous Moss (Water: Sp. Def +1) and Snowball (Ice: Attack +1). Not while the stats are
// already at +6, nor once the holder has fainted. Sets up subscript_sovereign_item_stat_up.
static BOOL Sovereign_ItemStatUpOnHit(BattleContext *battleCtx)
{
    int item = Battler_HeldItem(battleCtx, battleCtx->defender);
    int hitType = battleCtx->moveType ? battleCtx->moveType : CURRENT_MOVE_DATA.type;
    int stat = -1, stat2 = -1, stages = 1;

    if (DEFENDING_MON.curHP == 0
        || battleCtx->attacker == battleCtx->defender
        || (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken == 0 && DEFENDER_SELF_TURN_FLAGS.specialDamageTaken == 0)) {
        return FALSE;
    }

    if (item == ITEM_WEAKNESS_POLICY && (battleCtx->moveStatusFlags & MOVE_STATUS_SUPER_EFFECTIVE)) {
        stat = BATTLE_STAT_ATTACK;
        stat2 = BATTLE_STAT_SP_ATTACK;
        stages = 2;
    } else if (item == ITEM_ABSORB_BULB && hitType == TYPE_WATER) {
        stat = BATTLE_STAT_SP_ATTACK;
    } else if (item == ITEM_CELL_BATTERY && hitType == TYPE_ELECTRIC) {
        stat = BATTLE_STAT_ATTACK;
    } else if (item == ITEM_LUMINOUS_MOSS && hitType == TYPE_WATER) {
        stat = BATTLE_STAT_SP_DEFENSE;
    } else if (item == ITEM_SNOWBALL && hitType == TYPE_ICE) {
        stat = BATTLE_STAT_ATTACK;
    }

    if (stat < 0
        || (DEFENDING_MON.statBoosts[stat] == 12 && (stat2 < 0 || DEFENDING_MON.statBoosts[stat2] == 12))) { // MAX_STAT_STAGE
        return FALSE;
    }

    int first = stages == 2 ? MOVE_SUBSCRIPT_PTR_ATTACK_UP_2_STAGES : MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE;

    battleCtx->msgBattlerTemp = battleCtx->defender;
    battleCtx->msgItemTemp = item;
    battleCtx->sideEffectParam = first + (stat - BATTLE_STAT_ATTACK);
    battleCtx->msgTemp = stat2 < 0 ? 0 : first + (stat2 - BATTLE_STAT_ATTACK);

    return TRUE;
}

BOOL BattleSystem_TriggerHeldItemOnHit(BattleSystem *battleSys, BattleContext *battleCtx, int *subscript)
{
    BOOL result = FALSE;

    if (battleCtx->defender == BATTLER_NONE) {
        return result;
    }

    if (Battler_SubstituteWasHit(battleCtx, battleCtx->defender) == TRUE) {
        return result;
    }

    // Sovereign (item 11): Emergency Exit and Wimp Out switch their holder out (a wild one flees) when another Pokemon's
    // damaging move drops it from above half its HP to half or less, as an Eject Button does. As in Champions, a U-turn
    // user still switches out too, and Sheer Force doesn't stop it (Showdown's Champions mod runs the target's
    // after-hit effects for a Sheer Force move: Gen IX skips them).
    if ((Battler_Ability(battleCtx, battleCtx->defender) == ABILITY_EMERGENCY_EXIT
            || Battler_Ability(battleCtx, battleCtx->defender) == ABILITY_WIMP_OUT)
        && battleCtx->attacker != battleCtx->defender
        && DEFENDING_MON.curHP
        && DEFENDING_MON.curHP <= DEFENDING_MON.maxHP / 2
        && battleCtx->sovereignHPBeforeHit[battleCtx->defender] > DEFENDING_MON.maxHP / 2
        && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
        && (battleCtx->battlersSwitchingMask & FlagIndex(battleCtx->defender)) == FALSE) {
        battleCtx->sovereignHPBeforeHit[battleCtx->defender] = DEFENDING_MON.curHP; // once per hit
        battleCtx->switchedMon = battleCtx->defender;
        *subscript = subscript_sovereign_emergency_exit;
        return TRUE;
    }

    if (Battler_UnnerveBlocksBerry(battleSys, battleCtx, battleCtx->defender)) { // Sovereign (item 11)
        return result;
    }

    int itemEffect = Battler_HeldItemEffect(battleCtx, battleCtx->defender);
    int itemPower = Battler_HeldItemPower(battleCtx, battleCtx->defender, 0);
    int side = BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker);

    // Sovereign (item 11): an Air Balloon pops when a damaging move hits its holder.
    if (Battler_HeldItem(battleCtx, battleCtx->defender) == ITEM_AIR_BALLOON
        && battleCtx->attacker != battleCtx->defender
        && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)) {
        battleCtx->msgBattlerTemp = battleCtx->defender;
        *subscript = subscript_sovereign_air_balloon_popped;
        return TRUE;
    }

    if (Sovereign_ItemStatUpOnHit(battleCtx)) { // Sovereign (item 11)
        *subscript = subscript_sovereign_item_stat_up;
        return TRUE;
    }

    // Sovereign (item 11): a Red Card drags out the Pokemon that hit its holder with a damaging move; an Eject Button
    // switches its holder out. After a U-turn or the like, an Eject Button still works (Champions: both switch out) but
    // a Red Card doesn't (the user switched out already). Neither works against a Pokemon already switching out
    // (Pursuit). As in Champions, both work after a Sheer Force move too (Gen IX: neither).
    u16 item = Battler_HeldItem(battleCtx, battleCtx->defender);
    if ((item == ITEM_RED_CARD || item == ITEM_EJECT_BUTTON)
        && battleCtx->attacker != battleCtx->defender
        && DEFENDING_MON.curHP
        && (item == ITEM_EJECT_BUTTON || ATTACKING_MON.curHP)
        && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
        && (item == ITEM_EJECT_BUTTON || (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE)
        && (battleCtx->battlersSwitchingMask & FlagIndex(battleCtx->defender)) == FALSE) {
        *subscript = item == ITEM_RED_CARD ? subscript_sovereign_red_card : subscript_sovereign_eject_button;
        return TRUE;
    }

    switch (itemEffect) {
    case HOLD_EFFECT_DMG_USER_CONTACT_XFR:
        if (ATTACKING_MON.curHP
            && ATTACKING_MON.heldItem == ITEM_NONE
            && (battleCtx->sideConditions[side].knockedOffItemsMask & FlagIndex(battleCtx->selectedPartySlot[battleCtx->attacker])) == FALSE
            && battleCtx->moveCur != MOVE_KNOCK_OFF
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
            && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)) {
            *subscript = subscript_transfer_sticky_barb;
            result = TRUE;
        }
        break;

    case HOLD_EFFECT_RECOIL_PHYSICAL:
        if (ATTACKING_MON.curHP
            && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_MAGIC_GUARD
            && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
            && DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken) {
            // Sovereign (item 11): a Ripen holder's Jaboca and Rowap Berries take 1/4 of the attacker's max HP.
            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP * -1, Battler_Ability(battleCtx, battleCtx->defender) == ABILITY_RIPEN ? itemPower / 2 : itemPower);
            *subscript = subscript_held_item_recoil_when_hit;
            result = TRUE;
        }
        break;

    case HOLD_EFFECT_RECOIL_SPECIAL:
        if (ATTACKING_MON.curHP
            && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_MAGIC_GUARD
            && DEFENDER_SELF_TURN_FLAGS.specialDamageTaken) {
            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP * -1, Battler_Ability(battleCtx, battleCtx->defender) == ABILITY_RIPEN ? itemPower / 2 : itemPower);
            *subscript = subscript_held_item_recoil_when_hit;
            result = TRUE;
        }
        break;

    case HOLD_EFFECT_HP_RESTORE_SE:
        if (DEFENDING_MON.curHP && (battleCtx->moveStatusFlags & MOVE_STATUS_SUPER_EFFECTIVE)
            && Sovereign_HealBlocked(battleCtx, battleCtx->defender) == FALSE) { // Sovereign: Heal Block (Gen V+)
            battleCtx->hpCalcTemp = BattleSystem_Divide(DEFENDING_MON.maxHP, itemPower);
            *subscript = subscript_held_item_hp_restore;
            Sovereign_RipenBerryHP(battleCtx, battleCtx->defender, *subscript); // Sovereign (item 11): Enigma Berry
            battleCtx->msgBattlerTemp = battleCtx->defender;
            battleCtx->msgItemTemp = battleCtx->battleMons[battleCtx->defender].heldItem;
            result = TRUE;
        }
        break;

    default:
        break;
    }

    return result;
}

s32 Battler_HeldItemEffect(BattleContext *battleCtx, int battler)
{
    u16 item = Battler_HeldItem(battleCtx, battler);
    return BattleSystem_GetItemData(battleCtx, item, ITEM_PARAM_HOLD_EFFECT);
}

s32 Battler_HeldItemPower(BattleContext *battleCtx, int battler, enum HeldItemPowerOp opcode)
{
    u16 item;
    switch (opcode) {
    case ITEM_POWER_CHECK_ALL:
        item = Battler_HeldItem(battleCtx, battler);
        break;

    case ITEM_POWER_CHECK_EMBARGO:
        if (battleCtx->battleMons[battler].moveEffectsData.embargoTurns) {
            return 0;
        }

    case ITEM_POWER_CHECK_NONE:
        item = battleCtx->battleMons[battler].heldItem;
        break;
    }

    return BattleSystem_GetItemData(battleCtx, item, ITEM_PARAM_EFFECT_PARAM);
}

s32 Battler_NaturalGiftPower(BattleContext *battleCtx, int battler)
{
    u16 item = Battler_HeldItem(battleCtx, battler);
    return BattleSystem_GetItemData(battleCtx, item, ITEM_PARAM_NATURAL_GIFT_POWER);
}

s32 Battler_NaturalGiftType(BattleContext *battleCtx, int battler)
{
    u16 item = Battler_HeldItem(battleCtx, battler);
    return BattleSystem_GetItemData(battleCtx, item, ITEM_PARAM_NATURAL_GIFT_TYPE);
}

s32 Battler_ItemPluckEffect(BattleContext *battleCtx, int battler)
{
    return BattleSystem_GetItemData(battleCtx, battleCtx->battleMons[battler].heldItem, ITEM_PARAM_PLUCK_EFFECT);
}

s32 Battler_ItemFlingEffect(BattleContext *battleCtx, int battler)
{
    if (battleCtx->battleMons[battler].moveEffectsData.embargoTurns) {
        return FLING_EFFECT_NONE;
    }

    return BattleSystem_GetItemData(battleCtx, battleCtx->battleMons[battler].heldItem, ITEM_PARAM_FLING_EFFECT);
}

s32 Battler_ItemFlingPower(BattleContext *battleCtx, int battler)
{
    if (battleCtx->battleMons[battler].moveEffectsData.embargoTurns) {
        return 0;
    }

    return BattleSystem_GetItemData(battleCtx, battleCtx->battleMons[battler].heldItem, ITEM_PARAM_FLING_POWER);
}

static inline BOOL BattlerIsGrounded(BattleContext *battleCtx, int battler)
{
    return (Battler_Ability(battleCtx, battler) != ABILITY_LEVITATE
               && Battler_Ability(battleCtx, battler) != ABILITY_EELEVATE // Sovereign (item 11)
               && Battler_HeldItem(battleCtx, battler) != ITEM_AIR_BALLOON // Sovereign (item 11)
               && battleCtx->battleMons[battler].moveEffectsData.magnetRiseTurns == 0
               && battleCtx->sovereignTelekinesis[battler] == 0 // Sovereign (item 11)
               && MON_IS_NOT_TYPE(battler, TYPE_FLYING))
        || Battler_HeldItemEffect(battleCtx, battler) == HOLD_EFFECT_SPEED_DOWN_GROUNDED
        || battleCtx->sovereignSmackedDown[battler] // Sovereign (item 11)
        || (battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY);
}

// Sovereign (item 11): BattlerIsGrounded, for the terrains.
BOOL Sovereign_IsGrounded(BattleContext *battleCtx, int battler)
{
    return BattlerIsGrounded(battleCtx, battler);
}

// Sovereign (item 11): field conditions as the weather acts on one battler. A Utility Umbrella holder ignores rain and
// harsh sunlight (its Abilities and moves, and Fire and Water moves hitting it), though not a primal weather's failed
// Fire or Water moves.
static u32 Sovereign_UmbrellaWeather(BattleContext *battleCtx, int battler, u32 fieldConditions)
{
    if (Battler_HeldItem(battleCtx, battler) == ITEM_UTILITY_UMBRELLA) {
        return fieldConditions & ~(FIELD_CONDITION_RAINING | FIELD_CONDITION_SUNNY);
    }

    return fieldConditions;
}

// Sovereign (item 11): the field conditions as the weather acts on one battler (Sovereign_UmbrellaWeather).
u32 Sovereign_BattlerWeather(BattleContext *battleCtx, int battler)
{
    return Sovereign_UmbrellaWeather(battleCtx, battler, battleCtx->fieldConditionsMask);
}

// Sovereign (item 11): the field conditions as the weather acts on one battler's own moves. A Mega Sol user's moves
// act as if the sunlight were harsh, whatever the weather and even beside Cloud Nine or Air Lock (Mega Sol changes no
// weather). Otherwise Cloud Nine and Air Lock clear the weather, and a Utility Umbrella keeps rain and sunlight off.
u32 Sovereign_MoveWeather(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    if (Battler_Ability(battleCtx, battler) == ABILITY_MEGA_SOL) {
        return (battleCtx->fieldConditionsMask & ~FIELD_CONDITION_WEATHER) | FIELD_CONDITION_SUNNY_TEMP;
    }

    if (NO_CLOUD_NINE == FALSE) {
        return battleCtx->fieldConditionsMask & ~FIELD_CONDITION_WEATHER;
    }

    return Sovereign_BattlerWeather(battleCtx, battler);
}

// Sovereign (item 11): Terrain Pulse takes the type of the terrain under a grounded user.
int Sovereign_TerrainPulseType(BattleContext *battleCtx, int battler)
{
    u32 terrain = Sovereign_TerrainUnder(battleCtx, battler);

    if (terrain & FIELD_CONDITION_TERRAIN_ELECTRIC) {
        return TYPE_ELECTRIC;
    } else if (terrain & FIELD_CONDITION_TERRAIN_GRASSY) {
        return TYPE_GRASS;
    } else if (terrain & FIELD_CONDITION_TERRAIN_MISTY) {
        return TYPE_FAIRY;
    } else if (terrain & FIELD_CONDITION_TERRAIN_PSYCHIC) {
        return TYPE_PSYCHIC;
    }

    return TYPE_NORMAL;
}

// Sovereign (item 11): the terrain under a battler: its FIELD_CONDITION_TERRAIN_* flag, or 0 if there is none or the
// battler isn't grounded.
u32 Sovereign_TerrainUnder(BattleContext *battleCtx, int battler)
{
    if (BattlerIsGrounded(battleCtx, battler) == FALSE) {
        return 0;
    }

    return battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN;
}

static inline int CountAbilityTheirSide(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int ability)
{
    return BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_THEIR_SIDE, battler, ability);
}

BOOL Battler_IsTrapped(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    int result = FALSE;

    // Sovereign (item 11): Commander and Sky Drop (Battler_IsTrappedMsg).
    if (((battleCtx->sovereignCommanding | battleCtx->sovereignCommanded) & FlagIndex(battler))
        || Sovereign_SkyDropHolder(battleCtx, battler) != BATTLER_NONE) {
        return TRUE;
    }

    if (Battler_HeldItemEffect(battleCtx, battler) == HOLD_EFFECT_SWITCH
        || MON_HAS_TYPE(battler, TYPE_GHOST) // Sovereign (item 11): since Gen VI, nothing traps a Ghost type
        || Battler_Ability(battleCtx, battler) == ABILITY_RUN_AWAY) { // Sovereign (Pokémon Champions): nor Run Away
        return FALSE;
    }

    if ((battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_TRAPPED)
        || (battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_INGRAIN)
        || battleCtx->sovereignFairyLock) { // Sovereign (item 11)
        result = TRUE;
    }

    if ((Battler_Ability(battleCtx, battler) != ABILITY_SHADOW_TAG && CountAbilityTheirSide(battleSys, battleCtx, battler, ABILITY_SHADOW_TAG))
        || (MON_HAS_TYPE(battler, TYPE_STEEL) && CountAbilityTheirSide(battleSys, battleCtx, battler, ABILITY_MAGNET_PULL))) {
        result = TRUE;
    }

    if (BattlerIsGrounded(battleCtx, battler) && CountAbilityTheirSide(battleSys, battleCtx, battler, ABILITY_ARENA_TRAP)) {
        result = TRUE;
    }

    return result;
}

static BOOL BattleSystem_FeedBerryToAttacker(BattleSystem *battleSys, BattleContext *battleCtx, int battler, BOOL stuffCheeks);

BOOL BattleSystem_PluckBerry(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    if (Battler_SubstituteWasHit(battleCtx, battleCtx->defender) == TRUE) {
        return FALSE;
    }

    return BattleSystem_FeedBerryToAttacker(battleSys, battleCtx, battler, FALSE);
}

// Sovereign (item 11): Stuff Cheeks. The attacker eats its own Berry; Klutz and Embargo don't stop it. TRUE if it holds
// one.
BOOL Sovereign_EatOwnBerry(BattleSystem *battleSys, BattleContext *battleCtx)
{
    return BattleSystem_FeedBerryToAttacker(battleSys, battleCtx, battleCtx->attacker, TRUE);
}

// The attacker eats the Berry held by battler (Bug Bite, Pluck and Stuff Cheeks): its effect subscript goes in scriptTemp,
// the Berry in msgItemTemp. TRUE if battler holds a Berry.
static BOOL BattleSystem_FeedBerryToAttacker(BattleSystem *battleSys, BattleContext *battleCtx, int battler, BOOL stuffCheeks)
{
    BOOL result = FALSE;
    int nextSeq = 0;
    int effect = Battler_ItemPluckEffect(battleCtx, battler);
    int power = Battler_HeldItemPower(battleCtx, battler, 1);

    switch (effect) {
    case PLUCK_EFFECT_HP_RESTORE:
        if (ATTACKING_MON.curHP != ATTACKING_MON.maxHP) {
            battleCtx->hpCalcTemp = power;
            nextSeq = subscript_held_item_hp_restore;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_HP_PCT_RESTORE:
        if (ATTACKING_MON.curHP != ATTACKING_MON.maxHP) {
            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP * power, 100);
            nextSeq = subscript_held_item_hp_restore;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_PRZ_RESTORE:
        if (ATTACKING_MON.status & MON_CONDITION_PARALYSIS) {
            nextSeq = subscript_held_item_prz_restore;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_SLP_RESTORE:
        if (ATTACKING_MON.status & MON_CONDITION_SLEEP) {
            nextSeq = subscript_held_item_slp_restore;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_PSN_RESTORE:
        if (ATTACKING_MON.status & MON_CONDITION_ANY_POISON) {
            nextSeq = subscript_held_item_psn_restore;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_BRN_RESTORE:
        if (ATTACKING_MON.status & MON_CONDITION_BURN) {
            nextSeq = subscript_held_item_brn_restore;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_FRZ_RESTORE:
        if (ATTACKING_MON.status & MON_CONDITION_FREEZE) {
            nextSeq = subscript_held_item_frz_restore;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_PP_RESTORE: {
        int diff, i, maxDiff, slot; // must declare in this order to match.

        // Find the move that has the highest difference between its current
        // and maximum PP.
        maxDiff = 0;
        for (i = 0; i < LEARNED_MOVES_MAX; i++) {
            if (ATTACKING_MON.moves[i]) {
                diff = MoveTable_CalcMaxPP(ATTACKING_MON.moves[i], ATTACKING_MON.ppUps[i]) - ATTACKING_MON.ppCur[i];

                if (diff > maxDiff) {
                    maxDiff = diff;
                    slot = i;
                }
            }
        }

        BattleMon_AddVal(&ATTACKING_MON, BATTLEMON_CUR_PP_1 + slot, power);
        BattleMon_CopyToParty(battleSys, battleCtx, battleCtx->attacker);
        battleCtx->msgMoveTemp = ATTACKING_MON.moves[slot];
        nextSeq = subscript_held_item_pp_restore;

        result = TRUE;
        break;
    }

    case PLUCK_EFFECT_CNF_RESTORE:
        if (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_CONFUSION) {
            nextSeq = subscript_held_item_cnf_restore;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_ALL_RESTORE:
        if ((ATTACKING_MON.status & MON_CONDITION_ANY) || (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_CONFUSION)) {
            if (ATTACKING_MON.status & MON_CONDITION_PARALYSIS) {
                nextSeq = subscript_held_item_prz_restore;
            }

            if (ATTACKING_MON.status & MON_CONDITION_SLEEP) {
                nextSeq = subscript_held_item_slp_restore;
            }

            if (ATTACKING_MON.status & MON_CONDITION_ANY_POISON) {
                nextSeq = subscript_held_item_psn_restore;
            }

            if (ATTACKING_MON.status & MON_CONDITION_BURN) {
                nextSeq = subscript_held_item_brn_restore;
            }

            if (ATTACKING_MON.status & MON_CONDITION_FREEZE) {
                nextSeq = subscript_held_item_frz_restore;
            }

            if (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_CONFUSION) {
                nextSeq = subscript_held_item_cnf_restore;
            }

            if ((ATTACKING_MON.status & MON_CONDITION_ANY)
                && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_CONFUSION)) {
                nextSeq = subscript_held_item_multi_restore;
            }
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_HP_RESTORE_SPICY:
        if (ATTACKING_MON.curHP != ATTACKING_MON.maxHP) {
            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP, power);
            battleCtx->msgTemp = FLAVOR_SPICY;

            if (Pokemon_GetFlavorAffinityOf(ATTACKING_MON.personality, FLAVOR_SPICY) == -1) {
                nextSeq = subscript_held_item_dislike_flavor;
            } else {
                nextSeq = subscript_held_item_hp_restore;
            }
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_HP_RESTORE_DRY:
        if (ATTACKING_MON.curHP != ATTACKING_MON.maxHP) {
            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP, power);
            battleCtx->msgTemp = FLAVOR_DRY;

            if (Pokemon_GetFlavorAffinityOf(ATTACKING_MON.personality, FLAVOR_DRY) == -1) {
                nextSeq = subscript_held_item_dislike_flavor;
            } else {
                nextSeq = subscript_held_item_hp_restore;
            }
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_HP_RESTORE_SWEET:
        if (ATTACKING_MON.curHP != ATTACKING_MON.maxHP) {
            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP, power);
            battleCtx->msgTemp = FLAVOR_SWEET;

            if (Pokemon_GetFlavorAffinityOf(ATTACKING_MON.personality, FLAVOR_SWEET) == -1) {
                nextSeq = subscript_held_item_dislike_flavor;
            } else {
                nextSeq = subscript_held_item_hp_restore;
            }
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_HP_RESTORE_BITTER:
        if (ATTACKING_MON.curHP != ATTACKING_MON.maxHP) {
            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP, power);
            battleCtx->msgTemp = FLAVOR_BITTER;

            if (Pokemon_GetFlavorAffinityOf(ATTACKING_MON.personality, FLAVOR_BITTER) == -1) {
                nextSeq = subscript_held_item_dislike_flavor;
            } else {
                nextSeq = subscript_held_item_hp_restore;
            }
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_HP_RESTORE_SOUR:
        if (ATTACKING_MON.curHP != ATTACKING_MON.maxHP) {
            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP, power);
            battleCtx->msgTemp = FLAVOR_SOUR;

            if (Pokemon_GetFlavorAffinityOf(ATTACKING_MON.personality, FLAVOR_SOUR) == -1) {
                nextSeq = subscript_held_item_dislike_flavor;
            } else {
                nextSeq = subscript_held_item_hp_restore;
            }
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_ATK_UP:
        if (ATTACKING_MON.statBoosts[BATTLE_STAT_ATTACK] < MAX_STAT_STAGE) {
            battleCtx->msgTemp = BATTLE_STAT_ATTACK;
            nextSeq = subscript_held_item_raise_stat;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_DEF_UP:
        if (ATTACKING_MON.statBoosts[BATTLE_STAT_DEFENSE] < MAX_STAT_STAGE) {
            battleCtx->msgTemp = BATTLE_STAT_DEFENSE;
            nextSeq = subscript_held_item_raise_stat;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_SPEED_UP:
        if (ATTACKING_MON.statBoosts[BATTLE_STAT_SPEED] < MAX_STAT_STAGE) {
            battleCtx->msgTemp = BATTLE_STAT_SPEED;
            nextSeq = subscript_held_item_raise_stat;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_SPATK_UP:
        if (ATTACKING_MON.statBoosts[BATTLE_STAT_SP_ATTACK] < MAX_STAT_STAGE) {
            battleCtx->msgTemp = BATTLE_STAT_SP_ATTACK;
            nextSeq = subscript_held_item_raise_stat;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_SPDEF_UP:
        if (ATTACKING_MON.statBoosts[BATTLE_STAT_SP_DEFENSE] < MAX_STAT_STAGE) {
            battleCtx->msgTemp = BATTLE_STAT_SP_DEFENSE;
            nextSeq = subscript_held_item_raise_stat;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_RANDOM_UP2: {
        int stat;
        for (stat = 0; stat < 5; stat++) {
            if (ATTACKING_MON.statBoosts[BATTLE_STAT_ATTACK + stat] < MAX_STAT_STAGE) {
                break;
            }
        }

        if (stat != 5) {
            do {
                stat = BattleSystem_RandNext(battleSys) % 5;
            } while (ATTACKING_MON.statBoosts[BATTLE_STAT_ATTACK + stat] == MAX_STAT_STAGE);

            battleCtx->msgTemp = BATTLE_STAT_ATTACK + stat;
            nextSeq = subscript_held_item_sharply_raise_stat;
        }

        result = TRUE;
        break;
    }

    case PLUCK_EFFECT_CRIT_UP:
        if ((ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_FOCUS_ENERGY) == FALSE) {
            nextSeq = subscript_held_item_raise_crit;
        }

        result = TRUE;
        break;

    case PLUCK_EFFECT_TEMP_ACC_UP:
        nextSeq = subscript_held_item_temp_acc_up;
        result = TRUE;
        break;

    default:
        if (Item_IsBerry(battleCtx->battleMons[battler].heldItem) == TRUE) {
            result = TRUE;
        }
        break;
    }

    if (result == TRUE) {
        if (stuffCheeks == FALSE
            && (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_KLUTZ
                || (ATTACKING_MON.moveEffectsMask & MOVE_EFFECT_EMBARGO))) {
            battleCtx->scriptTemp = 0;
        } else if (Sovereign_IsHPRestoreSubscript(nextSeq) && Sovereign_HealBlocked(battleCtx, battleCtx->attacker)) {
            battleCtx->scriptTemp = 0; // Sovereign: under Heal Block the Berry is eaten for nothing (Gen V+)
        } else {
            battleCtx->scriptTemp = nextSeq;
        }

        battleCtx->msgItemTemp = battleCtx->battleMons[battler].heldItem;
        ATTACKER_SELF_TURN_FLAGS.statusFlags |= SELF_TURN_FLAG_PLUCK_BERRY;
    }

    return result;
}

BOOL BattleSystem_FlingItem(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    int effect = Battler_ItemFlingEffect(battleCtx, battler);
    int effectPower = Battler_HeldItemPower(battleCtx, battler, ITEM_PARAM_EFFECT_PARAM);

    battleCtx->movePower = Battler_ItemFlingPower(battleCtx, battler);
    battleCtx->flingScript = 0;
    battleCtx->sideEffectType = SIDE_EFFECT_TYPE_NONE;

    if (battleCtx->movePower == 0 || Battler_SovereignHeldItemLocked(battleCtx, battler)) {
        return FALSE;
    }

    switch (effect) {
    case FLING_EFFECT_HP_RESTORE:
        battleCtx->flingTemp = effectPower;
        battleCtx->flingScript = subscript_held_item_hp_restore;
        break;

    case FLING_EFFECT_HP_PCT_RESTORE:
        battleCtx->flingTemp = BattleSystem_Divide(DEFENDING_MON.maxHP * effectPower, 100);
        battleCtx->flingScript = subscript_held_item_hp_restore;
        break;

    case FLING_EFFECT_PRZ_RESTORE:
        if (DEFENDING_MON.status & MON_CONDITION_PARALYSIS) {
            battleCtx->flingScript = subscript_held_item_prz_restore;
        }
        break;

    case FLING_EFFECT_SLP_RESTORE:
        if (DEFENDING_MON.status & MON_CONDITION_SLEEP) {
            battleCtx->flingScript = subscript_held_item_slp_restore;
        }
        break;

    case FLING_EFFECT_PSN_RESTORE:
        if (DEFENDING_MON.status & MON_CONDITION_ANY_POISON) {
            battleCtx->flingScript = subscript_held_item_psn_restore;
        }
        break;

    case FLING_EFFECT_BRN_RESTORE:
        if (DEFENDING_MON.status & MON_CONDITION_BURN) {
            battleCtx->flingScript = subscript_held_item_brn_restore;
        }
        break;

    case FLING_EFFECT_FRZ_RESTORE:
        if (DEFENDING_MON.status & MON_CONDITION_FREEZE) {
            battleCtx->flingScript = subscript_held_item_frz_restore;
        }
        break;

    case FLING_EFFECT_PP_RESTORE: {
        int diff, i, maxDiff, slot; // must declare in this order to match.

        // Find the move that has the highest difference between its current
        // and maximum PP.
        maxDiff = 0;
        for (i = 0; i < LEARNED_MOVES_MAX; i++) {
            if (DEFENDING_MON.moves[i]) {
                diff = MoveTable_CalcMaxPP(DEFENDING_MON.moves[i], DEFENDING_MON.ppUps[i]) - DEFENDING_MON.ppCur[i];

                if (diff > maxDiff) {
                    maxDiff = diff;
                    slot = i;
                }
            }
        }

        if (maxDiff) {
            BattleMon_AddVal(&DEFENDING_MON, BATTLEMON_CUR_PP_1 + slot, effectPower);
            BattleMon_CopyToParty(battleSys, battleCtx, battleCtx->defender);
            battleCtx->msgMoveTemp = DEFENDING_MON.moves[slot];
            battleCtx->flingScript = subscript_held_item_pp_restore;
        }

        break;
    }

    case FLING_EFFECT_CNF_RESTORE:
        if (DEFENDING_MON.statusVolatile & VOLATILE_CONDITION_CONFUSION) {
            battleCtx->flingScript = subscript_held_item_cnf_restore;
        }
        break;

    case FLING_EFFECT_ALL_RESTORE:
        if ((DEFENDING_MON.status & MON_CONDITION_ANY) || (DEFENDING_MON.statusVolatile & VOLATILE_CONDITION_CONFUSION)) {
            if (DEFENDING_MON.status & MON_CONDITION_PARALYSIS) {
                battleCtx->flingScript = subscript_held_item_prz_restore;
            }

            if (DEFENDING_MON.status & MON_CONDITION_SLEEP) {
                battleCtx->flingScript = subscript_held_item_slp_restore;
            }

            if (DEFENDING_MON.status & MON_CONDITION_ANY_POISON) {
                battleCtx->flingScript = subscript_held_item_psn_restore;
            }

            if (DEFENDING_MON.status & MON_CONDITION_BURN) {
                battleCtx->flingScript = subscript_held_item_brn_restore;
            }

            if (DEFENDING_MON.status & MON_CONDITION_FREEZE) {
                battleCtx->flingScript = subscript_held_item_frz_restore;
            }

            if (DEFENDING_MON.statusVolatile & VOLATILE_CONDITION_CONFUSION) {
                battleCtx->flingScript = subscript_held_item_cnf_restore;
            }

            if ((DEFENDING_MON.status & MON_CONDITION_ANY)
                && (DEFENDING_MON.statusVolatile & VOLATILE_CONDITION_CONFUSION)) {
                battleCtx->flingScript = subscript_held_item_multi_restore;
            }
        }
        break;

    case FLING_EFFECT_HP_RESTORE_SPICY:
        battleCtx->flingTemp = BattleSystem_Divide(DEFENDING_MON.maxHP, effectPower);
        battleCtx->msgTemp = FLAVOR_SPICY;

        if (Pokemon_GetFlavorAffinityOf(DEFENDING_MON.personality, FLAVOR_SPICY) == -1) {
            battleCtx->flingScript = subscript_held_item_dislike_flavor;
        } else {
            battleCtx->flingScript = subscript_held_item_hp_restore;
        }
        break;

    case FLING_EFFECT_HP_RESTORE_DRY:
        battleCtx->flingTemp = BattleSystem_Divide(DEFENDING_MON.maxHP, effectPower);
        battleCtx->msgTemp = FLAVOR_DRY;

        if (Pokemon_GetFlavorAffinityOf(DEFENDING_MON.personality, FLAVOR_DRY) == -1) {
            battleCtx->flingScript = subscript_held_item_dislike_flavor;
        } else {
            battleCtx->flingScript = subscript_held_item_hp_restore;
        }
        break;

    case FLING_EFFECT_HP_RESTORE_SWEET:
        battleCtx->flingTemp = BattleSystem_Divide(DEFENDING_MON.maxHP, effectPower);
        battleCtx->msgTemp = FLAVOR_SWEET;

        if (Pokemon_GetFlavorAffinityOf(DEFENDING_MON.personality, FLAVOR_SWEET) == -1) {
            battleCtx->flingScript = subscript_held_item_dislike_flavor;
        } else {
            battleCtx->flingScript = subscript_held_item_hp_restore;
        }
        break;

    case FLING_EFFECT_HP_RESTORE_BITTER:
        battleCtx->flingTemp = BattleSystem_Divide(DEFENDING_MON.maxHP, effectPower);
        battleCtx->msgTemp = FLAVOR_BITTER;

        if (Pokemon_GetFlavorAffinityOf(DEFENDING_MON.personality, FLAVOR_BITTER) == -1) {
            battleCtx->flingScript = subscript_held_item_dislike_flavor;
        } else {
            battleCtx->flingScript = subscript_held_item_hp_restore;
        }
        break;

    case FLING_EFFECT_HP_RESTORE_SOUR:
        battleCtx->flingTemp = BattleSystem_Divide(DEFENDING_MON.maxHP, effectPower);
        battleCtx->msgTemp = FLAVOR_SOUR;

        if (Pokemon_GetFlavorAffinityOf(DEFENDING_MON.personality, FLAVOR_SOUR) == -1) {
            battleCtx->flingScript = subscript_held_item_dislike_flavor;
        } else {
            battleCtx->flingScript = subscript_held_item_hp_restore;
        }
        break;

    case FLING_EFFECT_STATDOWN_RESTORE:
        for (int i = BATTLE_STAT_HP; i < BATTLE_STAT_MAX; i++) {
            if (DEFENDING_MON.statBoosts[i] < DEFAULT_STAT_STAGE) {
                DEFENDING_MON.statBoosts[i] = DEFAULT_STAT_STAGE;
                battleCtx->flingScript = subscript_held_item_statdown_restore;
            }
        }
        break;

    case FLING_EFFECT_HEAL_INFATUATION:
        if (Sovereign_MentalHerbCures(&DEFENDING_MON)) {
            battleCtx->msgTemp = MSGCOND_INFATUATION;
            battleCtx->flingScript = subscript_sovereign_mental_herb;
        }
        break;

    case FLING_EFFECT_FLINCH:
        battleCtx->sideEffectMon = battler;
        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;
        battleCtx->flingScript = subscript_flinch_mon;
        break;

    case FLING_EFFECT_PARALYZE:
        battleCtx->sideEffectMon = battler;
        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;
        battleCtx->flingScript = subscript_paralyze;
        break;

    case FLING_EFFECT_POISON:
        battleCtx->sideEffectMon = battler;
        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;
        battleCtx->flingScript = subscript_poison;
        break;

    case FLING_EFFECT_BADLY_POISON:
        battleCtx->sideEffectMon = battler;
        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;
        battleCtx->flingScript = subscript_badly_poison;
        break;

    case FLING_EFFECT_BURN:
        battleCtx->sideEffectMon = battler;
        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;
        battleCtx->flingScript = subscript_burn;
        break;

    case FLING_EFFECT_ATK_UP:
        if (DEFENDING_MON.statBoosts[BATTLE_STAT_ATTACK] < MAX_STAT_STAGE) {
            battleCtx->msgTemp = BATTLE_STAT_ATTACK;
            battleCtx->flingScript = subscript_held_item_raise_stat;
        }
        break;

    case FLING_EFFECT_DEF_UP:
        if (DEFENDING_MON.statBoosts[BATTLE_STAT_DEFENSE] < MAX_STAT_STAGE) {
            battleCtx->msgTemp = BATTLE_STAT_DEFENSE;
            battleCtx->flingScript = subscript_held_item_raise_stat;
        }
        break;

    case FLING_EFFECT_SPEED_UP:
        if (DEFENDING_MON.statBoosts[BATTLE_STAT_SPEED] < MAX_STAT_STAGE) {
            battleCtx->msgTemp = BATTLE_STAT_SPEED;
            battleCtx->flingScript = subscript_held_item_raise_stat;
        }
        break;

    case FLING_EFFECT_SPATK_UP:
        if (DEFENDING_MON.statBoosts[BATTLE_STAT_SP_ATTACK] < MAX_STAT_STAGE) {
            battleCtx->msgTemp = BATTLE_STAT_SP_ATTACK;
            battleCtx->flingScript = subscript_held_item_raise_stat;
        }
        break;

    case FLING_EFFECT_SPDEF_UP:
        if (DEFENDING_MON.statBoosts[BATTLE_STAT_SP_DEFENSE] < MAX_STAT_STAGE) {
            battleCtx->msgTemp = BATTLE_STAT_SP_DEFENSE;
            battleCtx->flingScript = subscript_held_item_raise_stat;
        }
        break;

    case FLING_EFFECT_RANDOM_UP2: {
        int stat;

        for (stat = 0; stat < 5; stat++) {
            if (DEFENDING_MON.statBoosts[BATTLE_STAT_ATTACK + stat] < MAX_STAT_STAGE) {
                break;
            }
        }

        if (stat != 5) {
            do {
                stat = BattleSystem_RandNext(battleSys) % 5;
            } while (DEFENDING_MON.statBoosts[BATTLE_STAT_ATTACK + stat] == MAX_STAT_STAGE);

            battleCtx->msgTemp = BATTLE_STAT_ATTACK + stat;
            battleCtx->flingScript = subscript_held_item_sharply_raise_stat;
        }

        break;
    }

    case FLING_EFFECT_CRIT_UP:
        if ((DEFENDING_MON.statusVolatile & VOLATILE_CONDITION_FOCUS_ENERGY) == FALSE) {
            battleCtx->flingScript = subscript_held_item_raise_crit;
        }
        break;

    case FLING_EFFECT_TEMP_ACC_UP:
        battleCtx->flingScript = subscript_held_item_temp_acc_up;
        break;

    default:
        break;
    }

    // Sovereign: a flung HP Berry restores nothing to a target under Heal Block (Gen V+).
    if (Sovereign_IsHPRestoreSubscript(battleCtx->flingScript) && Sovereign_HealBlocked(battleCtx, battleCtx->defender)) {
        battleCtx->flingScript = 0;
    }

    if (DEFENDING_MON.moveEffectsMask & MOVE_EFFECT_EMBARGO) {
        battleCtx->flingScript = 0;
    } else {
        battleCtx->msgItemTemp = battleCtx->battleMons[battler].heldItem;

        if (battleCtx->sideEffectType == SIDE_EFFECT_TYPE_NONE && battleCtx->flingScript) {
            ATTACKER_SELF_TURN_FLAGS.statusFlags |= SELF_TURN_FLAG_PLUCK_BERRY;
        }

        battleCtx->msgBattlerTemp = battleCtx->defender;
    }

    return TRUE;
}

void BattleSystem_UpdateMetronomeCount(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (Battler_HeldItemEffect(battleCtx, battleCtx->attacker) == HOLD_EFFECT_BOOST_REPEATED) {
        if ((ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_THRASH) == FALSE
            && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_UPROAR) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_LAST_OF_MULTI_TURN) == FALSE
            && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_MOVE_LOCKED) == FALSE) {
            if (battleCtx->metronomeMove[battleCtx->attacker] == battleCtx->moveTemp) {
                if (ATTACKING_MON.moveEffectsData.metronomeTurns < 5) { // Sovereign: ×2 after 5 (Gen V+)
                    ATTACKING_MON.moveEffectsData.metronomeTurns++;
                }
            } else {
                ATTACKING_MON.moveEffectsData.metronomeTurns = 0;
                battleCtx->metronomeMove[battleCtx->attacker] = battleCtx->moveTemp;
            }
        }
    } else {
        ATTACKING_MON.moveEffectsData.metronomeTurns = 0;
    }
}

void BattleSystem_VerifyMetronomeCount(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (Battler_HeldItemEffect(battleCtx, battleCtx->attacker) == HOLD_EFFECT_BOOST_REPEATED) {
        if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS)
            && battleCtx->metronomeMove[battleCtx->attacker] == battleCtx->moveTemp
            && ATTACKING_MON.moveEffectsData.metronomeTurns
            && ATTACKER_SELF_TURN_FLAGS.repeatedMoveCount == 0
            && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_THRASH) == FALSE
            && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_UPROAR) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_LAST_OF_MULTI_TURN) == FALSE
            && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_MOVE_LOCKED) == FALSE) {
            ATTACKING_MON.moveEffectsData.metronomeTurns--;
        }
    } else {
        ATTACKING_MON.moveEffectsData.metronomeTurns = 0;
    }
}

enum PokemonCryMod Battler_CryModulation(BattleContext *battleCtx, int battler, int battlerType, BOOL encounter)
{
    BOOL doubles;
    if (encounter == TRUE
        && (battlerType == BATTLER_TYPE_PLAYER_SIDE_SLOT_1 || battlerType == BATTLER_TYPE_ENEMY_SIDE_SLOT_1)) {
        doubles = TRUE;
    } else {
        doubles = FALSE;
    }

    int cryMod = POKECRY_NORMAL;
    if (doubles == TRUE) { // conditional must stay to match, even though it's superfluous
        cryMod = POKECRY_NORMAL;
    }

    int hpColor = HealthBar_Color(battleCtx->battleMons[battler].curHP, battleCtx->battleMons[battler].maxHP, (8 * 6));

    if ((battleCtx->battleMons[battler].status & MON_CONDITION_ANY)
        || (hpColor != BARCOLOR_MAX && hpColor != BARCOLOR_GREEN)) {
        cryMod = POKECRY_PINCH_NORMAL;
    }

    return cryMod;
}

BOOL Battler_CanPickCommand(BattleContext *battleSys, int battler)
{
    BOOL result = TRUE;

    if ((battleSys->battleMons[battler].statusVolatile & VOLATILE_CONDITION_RECHARGING)
        || (battleSys->battleMons[battler].statusVolatile & VOLATILE_CONDITION_THRASH)
        || (battleSys->battleMons[battler].statusVolatile & VOLATILE_CONDITION_UPROAR)
        || (battleSys->battleMons[battler].statusVolatile & VOLATILE_CONDITION_MOVE_LOCKED)) {
        result = FALSE;
    }

    return result;
}

void BattleSystem_SetPokemonCatchData(BattleSystem *battleSys, BattleContext *battleCtx, Pokemon *mon)
{
    TrainerInfo *trInfo = BattleSystem_GetTrainerInfo(battleSys, BATTLER_US);
    int mapHeader = BattleSystem_GetMapHeader(battleSys);
    int terrain = BattleSystem_GetTerrain(battleSys);

    int ball;
    if (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_PAL_PARK) {
        ball = Pokemon_GetValue(mon, MON_DATA_POKEBALL, NULL);
    } else {
        ball = battleCtx->msgItemTemp;
    }

    Pokemon_SetCatchData(mon, trInfo, ball, mapHeader, terrain, HEAP_ID_BATTLE);

    // Sovereign (E8, FM): a caught Primal or Crowned Pokemon goes straight to the party or PC, so it reverts here, not
    // at the battle's end.
    Pokemon_SovereignRevertBattleForm(mon);
}

u8 BattleContext_IOBufferVal(BattleContext *battleCtx, int battler)
{
    return battleCtx->ioBuffer[battler][0];
}

BOOL Battler_SubstituteWasHit(BattleContext *battleCtx, int battler)
{
    BOOL result = FALSE;

    if (battleCtx->selfTurnFlags[battler].statusFlags & SELF_TURN_FLAG_SUBSTITUTE_HIT) {
        result = TRUE;
    }

    return result;
}

BOOL BattleSystem_TrainerIsOT(BattleSystem *battleSys, BattleContext *battleCtx)
{
    TrainerInfo *trInfo = BattleSystem_GetTrainerInfo(battleSys, BATTLER_US);
    u32 trID = TrainerInfo_ID(trInfo);
    u32 trGender = TrainerInfo_Gender(trInfo);
    const charcode_t *trName = TrainerInfo_Name(trInfo);

    if (trID == ATTACKING_MON.OTId
        && trGender == ATTACKING_MON.OTGender
        && CharCode_CompareNumChars(trName, ATTACKING_MON.OTName, TRAINER_NAME_LEN) == 0) {
        return TRUE;
    }

    return FALSE;
}

BOOL BattleSystem_PokemonIsOT(BattleSystem *battleSys, Pokemon *mon)
{
    TrainerInfo *trInfo = BattleSystem_GetTrainerInfo(battleSys, BATTLER_US);
    u32 trID = TrainerInfo_ID(trInfo);
    u32 trGender = TrainerInfo_Gender(trInfo);
    const charcode_t *trName = TrainerInfo_Name(trInfo);

    charcode_t monOTName[TRAINER_NAME_LEN + 1];
    Pokemon_GetValue(mon, MON_DATA_OT_NAME, monOTName);

    if (trID == Pokemon_GetValue(mon, MON_DATA_OT_ID, NULL)
        && trGender == Pokemon_GetValue(mon, MON_DATA_OT_GENDER, NULL)
        && CharCode_CompareNumChars(trName, monOTName, TRAINER_NAME_LEN) == 0) {
        return TRUE;
    }

    return FALSE;
}

BOOL BattleSystem_TriggerFormChange(BattleSystem *battleSys, BattleContext *battleCtx, int *subscript)
{
    int i;
    int arceusForm;
    BOOL result = FALSE;

    for (i = 0; i < BattleSystem_GetMaxBattlers(battleSys); i++) {
        battleCtx->msgBattlerTemp = battleCtx->monSpeedOrder[i];

        // Sovereign (FM): a Palafin that became Hero as it switched out says so as it comes back in.
        u32 heroBit = BattleSystem_SovereignHeroBit(battleSys, battleCtx->msgBattlerTemp, battleCtx->selectedPartySlot[battleCtx->msgBattlerTemp]);
        if ((battleCtx->sovereignHeroPending & heroBit) && battleCtx->battleMons[battleCtx->msgBattlerTemp].curHP) {
            battleCtx->sovereignHeroPending &= ~heroBit;
            *subscript = subscript_sovereign_zero_to_hero;
            result = TRUE;
            break;
        }

        // Sovereign (FM): Schooling forms a school (or not) and Shields Down drops Minior's shell (or not) as the
        // Pokémon enters; after that, at the end of each turn (BattleSystem_TriggerTurnEndAbility).
        BattleMon *hpFormMon = &battleCtx->battleMons[battleCtx->msgBattlerTemp];
        if (hpFormMon->sovereignHPFormChecked == FALSE && hpFormMon->curHP) {
            hpFormMon->sovereignHPFormChecked = TRUE;

            int hpForm = BattleSystem_SovereignHPForm(battleCtx, battleCtx->msgBattlerTemp);
            if (hpForm >= 0) {
                BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->msgBattlerTemp, hpForm);
                *subscript = subscript_form_change;
                result = TRUE;
                break;
            }
        }

        // Sovereign (FM): Xerneas is in its Active Mode in battle (Fairy Aura), as in X and Y. It's only how it looks.
        if (hpFormMon->species == SPECIES_XERNEAS && hpFormMon->curHP
            && (hpFormMon->statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE
            && Battler_Ability(battleCtx, battleCtx->msgBattlerTemp) == ABILITY_FAIRY_AURA
            && Pokemon_SovereignAbilityForm(hpFormMon->species, hpFormMon->formNum, ABILITY_FAIRY_AURA) >= 0) {
            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->msgBattlerTemp,
                Pokemon_SovereignAbilityForm(hpFormMon->species, hpFormMon->formNum, ABILITY_FAIRY_AURA));
            *subscript = subscript_sovereign_gulp_missile_catch; // a quiet form change
            result = TRUE;
            break;
        }

        // Sovereign (FM): Tera Shift makes Terapagos Terastal as it enters battle (it then has Tera Shell). Its max HP
        // rises, and its HP by as much (subscript_sovereign_tera_shift).
        if (hpFormMon->species == SPECIES_TERAPAGOS && hpFormMon->curHP
            && (hpFormMon->statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE
            && Battler_Ability(battleCtx, battleCtx->msgBattlerTemp) == ABILITY_TERA_SHIFT
            && Pokemon_SovereignAbilityForm(hpFormMon->species, hpFormMon->formNum, ABILITY_TERA_SHIFT) >= 0) {
            int oldMaxHP = hpFormMon->maxHP;

            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->msgBattlerTemp,
                Pokemon_SovereignAbilityForm(hpFormMon->species, hpFormMon->formNum, ABILITY_TERA_SHIFT));
            battleCtx->hpCalcTemp = hpFormMon->maxHP - oldMaxHP;
            *subscript = subscript_sovereign_tera_shift;
            result = TRUE;
            break;
        }

        // Sovereign (FM): snow (Platinum's hail) brings back a Noice Face Eiscue's ice when it switches in during snow
        // or when snow starts, not on every turn of it (as in Scarlet and Violet). Snow that Cloud Nine or Air Lock
        // hides doesn't, nor does it when they leave.
        if (hpFormMon->species == SPECIES_EISCUE && hpFormMon->curHP
            && (hpFormMon->statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE
            && Battler_Ability(battleCtx, battleCtx->msgBattlerTemp) == ABILITY_ICE_FACE) {
            if (WEATHER_IS_HAIL) {
                if (hpFormMon->sovereignIceFaceHail == FALSE) {
                    hpFormMon->sovereignIceFaceHail = TRUE;

                    int iceForm = Pokemon_SovereignBattleFormBase(hpFormMon->species, hpFormMon->formNum);
                    if (NO_CLOUD_NINE && iceForm != hpFormMon->formNum) {
                        BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->msgBattlerTemp, iceForm);
                        *subscript = subscript_form_change;
                        result = TRUE;
                        break;
                    }
                }
            } else {
                hpFormMon->sovereignIceFaceHail = FALSE;
            }
        }

        if (battleCtx->battleMons[battleCtx->msgBattlerTemp].species == SPECIES_CASTFORM
            && battleCtx->battleMons[battleCtx->msgBattlerTemp].curHP
            && Battler_Ability(battleCtx, battleCtx->msgBattlerTemp) == ABILITY_FORECAST) {
            if (NO_CLOUD_NINE) {
                if ((Sovereign_BattlerWeather(battleCtx, battleCtx->msgBattlerTemp) & FIELD_CONDITION_CASTFORM) == FALSE // Sovereign (item 11)
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].type1 != TYPE_NORMAL
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].type2 != TYPE_NORMAL) {
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].type1 = TYPE_NORMAL;
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].type2 = TYPE_NORMAL;
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].sovereignAddedType = 0; // Sovereign (item 11): a new type replaces an added one
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = CASTFORM_FORM_NORMAL;
                    *subscript = subscript_form_change;
                    result = TRUE;
                    break;
                } else if ((Sovereign_BattlerWeather(battleCtx, battleCtx->msgBattlerTemp) & FIELD_CONDITION_SUNNY)
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].type1 != TYPE_FIRE
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].type2 != TYPE_FIRE) {
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].type1 = TYPE_FIRE;
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].type2 = TYPE_FIRE;
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].sovereignAddedType = 0; // Sovereign (item 11): a new type replaces an added one
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = CASTFORM_FORM_SUNNY;
                    *subscript = subscript_form_change;
                    result = TRUE;
                    break;
                } else if ((Sovereign_BattlerWeather(battleCtx, battleCtx->msgBattlerTemp) & FIELD_CONDITION_RAINING)
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].type1 != TYPE_WATER
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].type2 != TYPE_WATER) {
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].type1 = TYPE_WATER;
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].type2 = TYPE_WATER;
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].sovereignAddedType = 0; // Sovereign (item 11): a new type replaces an added one
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = CASTFORM_FORM_RAINY;
                    *subscript = subscript_form_change;
                    result = TRUE;
                    break;
                } else if (WEATHER_IS_HAIL
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].type1 != TYPE_ICE
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].type2 != TYPE_ICE) {
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].type1 = TYPE_ICE;
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].type2 = TYPE_ICE;
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].sovereignAddedType = 0; // Sovereign (item 11): a new type replaces an added one
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = CASTFORM_FORM_SNOWY;
                    *subscript = subscript_form_change;
                    result = TRUE;
                    break;
                }
            } else if (battleCtx->battleMons[battleCtx->msgBattlerTemp].type1 != TYPE_NORMAL
                && battleCtx->battleMons[battleCtx->msgBattlerTemp].type2 != TYPE_NORMAL) {
                battleCtx->battleMons[battleCtx->msgBattlerTemp].type1 = TYPE_NORMAL;
                battleCtx->battleMons[battleCtx->msgBattlerTemp].type2 = TYPE_NORMAL;
                battleCtx->battleMons[battleCtx->msgBattlerTemp].sovereignAddedType = 0; // Sovereign (item 11): a new type replaces an added one
                battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = CASTFORM_FORM_NORMAL;
                *subscript = subscript_form_change;
                result = TRUE;
                break;
            }
        }

        if (battleCtx->battleMons[battleCtx->msgBattlerTemp].species == SPECIES_CHERRIM
            && battleCtx->battleMons[battleCtx->msgBattlerTemp].curHP) {
            if (NO_CLOUD_NINE) {
                if ((Sovereign_BattlerWeather(battleCtx, battleCtx->msgBattlerTemp) & FIELD_CONDITION_CASTFORM) == FALSE // Sovereign (item 11)
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum == CHERRIM_FORM_SUNSHINE) {
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = CHERRIM_FORM_OVERCAST;
                    *subscript = subscript_form_change;
                    result = TRUE;
                    break;
                } else if ((Sovereign_BattlerWeather(battleCtx, battleCtx->msgBattlerTemp) & FIELD_CONDITION_SUNNY)
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum == CHERRIM_FORM_OVERCAST) {
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = CHERRIM_FORM_SUNSHINE;
                    *subscript = subscript_form_change;
                    result = TRUE;
                    break;
                } else if (WEATHER_IS_RAIN && battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum == CHERRIM_FORM_SUNSHINE) {
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = CHERRIM_FORM_OVERCAST;
                    *subscript = subscript_form_change;
                    result = TRUE;
                    break;
                } else if (WEATHER_IS_HAIL && battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum == CHERRIM_FORM_SUNSHINE) {
                    battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = CHERRIM_FORM_OVERCAST;
                    *subscript = subscript_form_change;
                    result = TRUE;
                    break;
                }
            } else if (battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum == 1) {
                battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = CHERRIM_FORM_OVERCAST;
                *subscript = subscript_form_change;
                result = TRUE;
                break;
            }
        }

        if (battleCtx->battleMons[battleCtx->msgBattlerTemp].species == SPECIES_ARCEUS
            && battleCtx->battleMons[battleCtx->msgBattlerTemp].curHP
            && Battler_Ability(battleCtx, battleCtx->msgBattlerTemp) == ABILITY_MULTITYPE) {
            arceusForm = Pokemon_GetArceusTypeOf(Item_LoadParam(battleCtx->battleMons[battleCtx->msgBattlerTemp].heldItem, ITEM_PARAM_HOLD_EFFECT, HEAP_ID_BATTLE));
            if (battleCtx->battleMons[battleCtx->msgBattlerTemp].heldItem == ITEM_PIXIE_PLATE) {
                arceusForm = TYPE_FAIRY; // Sovereign (FM): Fairy Arceus
            }

            if (battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum != arceusForm) {
                battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = arceusForm;
                *subscript = subscript_form_change;
                result = TRUE;
                break;
            }
        }

        if (battleCtx->battleMons[battleCtx->msgBattlerTemp].species == SPECIES_GIRATINA
            && battleCtx->battleMons[battleCtx->msgBattlerTemp].curHP
            && battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum == GIRATINA_FORM_ORIGIN
            && ((battleCtx->battleMons[battleCtx->msgBattlerTemp].statusVolatile & VOLATILE_CONDITION_TRANSFORM)
                || ((BattleSystem_GetBattleStatusMask(battleSys) & BATTLE_STATUS_DISTORTION) == FALSE
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].heldItem != ITEM_GRISEOUS_ORB
                    && battleCtx->battleMons[battleCtx->msgBattlerTemp].heldItem != ITEM_GRISEOUS_CORE))) {
            if (battleCtx->battleMons[battleCtx->msgBattlerTemp].statusVolatile & VOLATILE_CONDITION_TRANSFORM) {
                Pokemon *mon = Pokemon_New(HEAP_ID_BATTLE);

                int target;
                if (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES) {
                    target = battleCtx->battlerActions[battleCtx->msgBattlerTemp][BATTLE_ACTION_CHOOSE_TARGET];
                } else {
                    target = battleCtx->msgBattlerTemp ^ 1;
                }

                Pokemon_Copy(BattleSystem_GetPartyPokemon(battleSys, target, battleCtx->selectedPartySlot[target]), mon);

                // Don't copy the Griseous Orb
                int tmp = ITEM_NONE;
                Pokemon_SetValue(mon, MON_DATA_HELD_ITEM, &tmp);

                // Force Giratina-Altered form
                tmp = GIRATINA_FORM_ALTERED;
                Pokemon_SetValue(mon, MON_DATA_FORM, &tmp);
                Pokemon_SetGiratinaFormByHeldItem(mon);

                battleCtx->battleMons[battleCtx->msgBattlerTemp].attack = Pokemon_GetValue(mon, MON_DATA_ATK, 0);
                battleCtx->battleMons[battleCtx->msgBattlerTemp].defense = Pokemon_GetValue(mon, MON_DATA_DEF, 0);
                battleCtx->battleMons[battleCtx->msgBattlerTemp].speed = Pokemon_GetValue(mon, MON_DATA_SPEED, 0);
                battleCtx->battleMons[battleCtx->msgBattlerTemp].spAttack = Pokemon_GetValue(mon, MON_DATA_SP_ATK, 0);
                battleCtx->battleMons[battleCtx->msgBattlerTemp].spDefense = Pokemon_GetValue(mon, MON_DATA_SP_DEF, 0);
                battleCtx->battleMons[battleCtx->msgBattlerTemp].ability = Pokemon_GetValue(mon, MON_DATA_ABILITY, 0);
                battleCtx->battleMons[battleCtx->msgBattlerTemp].formNum = GIRATINA_FORM_ALTERED;
                battleCtx->battleStatusMask2 |= SYSCTL_FORM_CHANGE;

                BattleController_EmitUpdatePartyMon(battleSys, battleCtx, battleCtx->msgBattlerTemp);
                Heap_Free(mon);

                *subscript = subscript_form_change;
                result = TRUE;
                break;
            } else {
                *subscript = subscript_giratina_form_change;
                result = TRUE;
                break;
            }
        }
    }

    return result;
}

// Sovereign (E8): the bit in sovereignMegaUsed for the trainer who owns this battler. Each trainer may Mega Evolve once
// per battle: in a multi or tag battle each battler is its own trainer's; otherwise a side's battlers share one.
u8 BattleSystem_SovereignMegaTrainerBit(BattleSystem *battleSys, int battler)
{
    if (BattleSystem_GetBattleType(battleSys) & (BATTLE_TYPE_2vs2 | BATTLE_TYPE_TAG)) {
        return FlagIndex(battler);
    }

    return FlagIndex(BattleSystem_GetBattlerSide(battleSys, battler));
}

// Sovereign (E8): the form this battler can Mega Evolve into right now, or 0 (docs/MegaEvolution.md). Ultra Burst (FM)
// goes through the MEGA button too and counts as the trainer's Mega Evolution (owner, 2026-10-24: no Z-Moves).
int BattleSystem_SovereignMegaForm(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    BattleMon *mon = &battleCtx->battleMons[battler];
    u32 battleType = BattleSystem_GetBattleType(battleSys);
    u8 side = BattleSystem_GetBattlerSide(battleSys, battler);
    int ultraForm = Pokemon_SovereignUltraBurstForm(mon->species, mon->formNum, mon->heldItem);

    // A form for good can have a Mega of its own (Female Meowstic, Eternal Floette); a battle form can't Mega Evolve
    // again (Pokemon_SovereignBattleForm decides which forms have one).
    if ((battleType & BATTLE_TYPE_NO_MOVES)
        || mon->curHP == 0
        || (Pokemon_IsSovereignBattleForm(mon->species, mon->formNum) && ultraForm == 0)
        || (mon->statusVolatile & VOLATILE_CONDITION_TRANSFORM)
        || (battleCtx->sovereignMegaUsed & BattleSystem_SovereignMegaTrainerBit(battleSys, battler))) {
        return 0;
    }

    // Wild Pokémon never Mega Evolve. The player needs the Mega Ring; AI partners and opposing trainers don't.
    if (side != BATTLER_US) {
        if ((battleType & BATTLE_TYPE_TRAINER) == FALSE) {
            return 0;
        }
    } else if (BattlerData_GetBootState(BattleSystem_GetBattlerData(battleSys, battler)) != BATTLER_BOOT_STATE_AI
        && BattleSystem_IsMegaUnlocked(battleSys) == FALSE) {
        return 0;
    }

    if (ultraForm != 0) {
        return ultraForm;
    }

    return Pokemon_SovereignBattleForm(mon->species, mon->formNum, mon->heldItem, mon->moves, FALSE);
}

// Sovereign (E8): change a battler into its Mega or Primal form: stats, types and, when the engine has it, the form's
// ability. The party Pokémon takes the form too (it keeps it if it switches out) and reverts when the battle ends
// (BattleMain_CopyBattleSysToDTOAndFree).
void BattleSystem_SovereignChangeBattleForm(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int form)
{
    BattleMon *mon = &battleCtx->battleMons[battler];
    Pokemon *tmp = Pokemon_New(HEAP_ID_BATTLE);

    Pokemon_Copy(BattleSystem_GetPartyPokemon(battleSys, battler, battleCtx->selectedPartySlot[battler]), tmp);
    Pokemon_SetValue(tmp, MON_DATA_FORM, &form);
    Pokemon_CalcLevelAndStats(tmp);

    mon->attack = Pokemon_GetValue(tmp, MON_DATA_ATK, NULL);
    mon->defense = Pokemon_GetValue(tmp, MON_DATA_DEF, NULL);
    mon->speed = Pokemon_GetValue(tmp, MON_DATA_SPEED, NULL);
    mon->spAttack = Pokemon_GetValue(tmp, MON_DATA_SP_ATK, NULL);
    mon->spDefense = Pokemon_GetValue(tmp, MON_DATA_SP_DEF, NULL);
    mon->type1 = SpeciesData_GetFormValue(mon->species, form, SPECIES_DATA_TYPE_1);
    mon->type2 = SpeciesData_GetFormValue(mon->species, form, SPECIES_DATA_TYPE_2);
    mon->sovereignAddedType = 0; // Sovereign (item 11): a new type replaces an added one
    mon->formNum = form;
    // A form with more HP (Complete Zygarde) raises its max HP; the caller raises its HP to match.
    mon->maxHP = Pokemon_GetValue(tmp, MON_DATA_MAX_HP, NULL);
    if (mon->curHP > mon->maxHP) {
        mon->curHP = mon->maxHP;
    }
    Heap_Free(tmp);

    // A Mega whose ability the engine lacks keeps its own (its form data lists none: tools/engine/gen_forms.py).
    // A new ability takes effect at once, as if the Pokémon had just switched in (Mega Charizard Y's Drought).
    u16 ability = SpeciesData_GetFormValue(mon->species, form, SPECIES_DATA_ABILITY_1);
    if (ability != ABILITY_NONE && ability != mon->ability && Pokemon_SovereignFormChangesAbility(mon->species, form)) {
        mon->ability = ability;
        mon->weatherAbilityAnnounced = FALSE;
        mon->intimidateAnnounced = FALSE;
        mon->traceAnnounced = FALSE;
        mon->downloadAnnounced = FALSE;
        mon->anticipationAnnounced = FALSE;
        mon->forewarnAnnounced = FALSE;
        mon->friskAnnounced = FALSE;
        mon->moldBreakerAnnounced = FALSE;
        mon->pressureAnnounced = FALSE;
    }

    battleCtx->battleStatusMask2 |= SYSCTL_RECALC_MON_STATS;
    BattleController_EmitUpdatePartyMon(battleSys, battleCtx, battler);

#ifdef SOVEREIGN_TEST
    if (BattleSystem_GetBattlerSide(battleSys, battler) == BATTLER_US && gSovereignTestPlayerBattleForm == 0) {
        gSovereignTestPlayerBattleForm = form;
    }
#endif
}

// Sovereign (E8): Mega Evolve (or Ultra Burst) a battler; its trainer can't Mega Evolve or Ultra Burst again this
// battle.
void BattleSystem_SovereignMegaEvolve(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int form)
{
    BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battler, form);
    battleCtx->sovereignMegaUsed |= BattleSystem_SovereignMegaTrainerBit(battleSys, battler);
}

void BattleSystem_InitPartyOrder(BattleSystem *battleSys, BattleContext *battleCtx)
{
    for (int i = 0; i < BattleSystem_GetMaxBattlers(battleSys); i++) {
        for (int j = 0; j < MAX_PARTY_SIZE; j++) {
            battleCtx->partyOrder[i][j] = j;
        }

        // Sovereign (decision 18): a battler that starts empty (party slot 6, battle_main.c) has no Pokémon to move.
        if (battleCtx->selectedPartySlot[i] == MAX_PARTY_SIZE) {
            continue;
        }

        BattleSystem_SwitchSlots(battleSys, battleCtx, i, battleCtx->selectedPartySlot[i]);
    }
}

void BattleSystem_SwitchSlots(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int partySlot)
{
    // declare C89-style to match
    int i;
    int tmp;
    int targetSlot;
    u32 battleType = BattleSystem_GetBattleType(battleSys);

    if (((battleType & BATTLE_TYPE_DOUBLES) && (battleType & BATTLE_TYPE_2vs2_TAG) == FALSE)
        || ((battleType & BATTLE_TYPE_TAG) && (BattleSystem_GetBattlerType(battleSys, battler) & BATTLER_TYPE_SOLO_ENEMY) == FALSE)) {
        if (BattleSystem_GetBattlerType(battleSys, battler) == BATTLER_TYPE_PLAYER_SIDE_SLOT_2
            || BattleSystem_GetBattlerType(battleSys, battler) == BATTLER_TYPE_ENEMY_SIDE_SLOT_2) {
            targetSlot = 1;
        } else {
            targetSlot = 0;
        }

        battler &= 1;
    } else {
        targetSlot = 0;
    }

    for (i = 0; i < MAX_PARTY_SIZE; i++) {
        if (battleCtx->partyOrder[battler][i] == partySlot) {
            break;
        }
    }

    tmp = battleCtx->partyOrder[battler][targetSlot];
    battleCtx->partyOrder[battler][targetSlot] = battleCtx->partyOrder[battler][i];
    battleCtx->partyOrder[battler][i] = tmp;
}

typedef struct ItemEffectTypePair {
    u8 itemEffect;
    u8 type;
} ItemEffectTypePair;

static const ItemEffectTypePair sTypeBoostingItems[] = {
    { HOLD_EFFECT_STRENGTHEN_BUG, TYPE_BUG },
    { HOLD_EFFECT_STRENGTHEN_STEEL, TYPE_STEEL },
    { HOLD_EFFECT_STRENGTHEN_GROUND, TYPE_GROUND },
    { HOLD_EFFECT_STRENGTHEN_ROCK, TYPE_ROCK },
    { HOLD_EFFECT_STRENGTHEN_GRASS, TYPE_GRASS },
    { HOLD_EFFECT_STRENGTHEN_DARK, TYPE_DARK },
    { HOLD_EFFECT_STRENGTHEN_FIGHT, TYPE_FIGHTING },
    { HOLD_EFFECT_STRENGTHEN_ELECTRIC, TYPE_ELECTRIC },
    { HOLD_EFFECT_STRENGTHEN_WATER, TYPE_WATER },
    { HOLD_EFFECT_STRENGTHEN_FLYING, TYPE_FLYING },
    { HOLD_EFFECT_STRENGTHEN_POISON, TYPE_POISON },
    { HOLD_EFFECT_STRENGTHEN_ICE, TYPE_ICE },
    { HOLD_EFFECT_STRENGTHEN_GHOST, TYPE_GHOST },
    { HOLD_EFFECT_STRENGTHEN_PSYCHIC, TYPE_PSYCHIC },
    { HOLD_EFFECT_STRENGTHEN_FIRE, TYPE_FIRE },
    { HOLD_EFFECT_STRENGTHEN_DRAGON, TYPE_DRAGON },
    { HOLD_EFFECT_STRENGTHEN_NORMAL, TYPE_NORMAL },
    { HOLD_EFFECT_ARCEUS_FIRE, TYPE_FIRE },
    { HOLD_EFFECT_ARCEUS_WATER, TYPE_WATER },
    { HOLD_EFFECT_ARCEUS_ELECTRIC, TYPE_ELECTRIC },
    { HOLD_EFFECT_ARCEUS_GRASS, TYPE_GRASS },
    { HOLD_EFFECT_ARCEUS_ICE, TYPE_ICE },
    { HOLD_EFFECT_ARCEUS_FIGHTING, TYPE_FIGHTING },
    { HOLD_EFFECT_ARCEUS_POISON, TYPE_POISON },
    { HOLD_EFFECT_ARCEUS_GROUND, TYPE_GROUND },
    { HOLD_EFFECT_ARCEUS_FLYING, TYPE_FLYING },
    { HOLD_EFFECT_ARCEUS_PSYCHIC, TYPE_PSYCHIC },
    { HOLD_EFFECT_ARCEUS_BUG, TYPE_BUG },
    { HOLD_EFFECT_ARCEUS_ROCK, TYPE_ROCK },
    { HOLD_EFFECT_ARCEUS_GHOST, TYPE_GHOST },
    { HOLD_EFFECT_ARCEUS_DRAGON, TYPE_DRAGON },
    { HOLD_EFFECT_ARCEUS_DARK, TYPE_DARK },
    { HOLD_EFFECT_ARCEUS_STEEL, TYPE_STEEL }
};

static const Fraction sStatStageBoosts[] = {
    { 10, 40 }, // -6
    { 10, 35 }, // -5
    { 10, 30 }, // -4
    { 10, 25 }, // -3
    { 10, 20 }, // -2
    { 10, 15 }, // -1
    { 10, 10 }, // neutral
    { 15, 10 }, // +1
    { 20, 10 }, // +2
    { 25, 10 }, // +3
    { 30, 10 }, // +4
    { 35, 10 }, // +5
    { 40, 10 }, // +6
};

static const u16 sPunchingMoves[] = {
    MOVE_ICE_PUNCH,
    MOVE_FIRE_PUNCH,
    MOVE_THUNDER_PUNCH,
    MOVE_MACH_PUNCH,
    MOVE_FOCUS_PUNCH,
    MOVE_DIZZY_PUNCH,
    MOVE_DYNAMIC_PUNCH,
    MOVE_HAMMER_ARM,
    MOVE_MEGA_PUNCH,
    MOVE_COMET_PUNCH,
    MOVE_METEOR_MASH,
    MOVE_SHADOW_PUNCH,
    MOVE_DRAIN_PUNCH,
    MOVE_BULLET_PUNCH,
    MOVE_SKY_UPPERCUT,
    // Sovereign (item 11): Gen V+ punching moves
    MOVE_POWER_UP_PUNCH,
    MOVE_DOUBLE_IRON_BASH,
    MOVE_ICE_HAMMER,
    MOVE_SURGING_STRIKES,
    MOVE_WICKED_BLOW,
    MOVE_JET_PUNCH,
    MOVE_RAGE_FIST,
    MOVE_HEADLONG_RUSH,
    MOVE_PLASMA_FISTS,
    MOVE_DOUBLE_SHOCK, // Pokémon Champions
};

// Sovereign (item 11): whether a move counts as making contact for the target's contact abilities and items. Long
// Reach and Protective Pads remove contact; Punching Glove removes it from punching moves.
BOOL Sovereign_MakesContact(BattleContext *battleCtx, int attacker, int move)
{
    if (((MOVE_DATA(move).flags & MOVE_FLAG_MAKES_CONTACT) == FALSE
            && (move != MOVE_SHELL_SIDE_ARM || Sovereign_ShellSideArmPhysical(battleCtx, attacker, battleCtx->defender) == FALSE))
        || Battler_Ability(battleCtx, attacker) == ABILITY_LONG_REACH
        || battleCtx->battleMons[attacker].heldItem == ITEM_PROTECTIVE_PADS) {
        return FALSE;
    }

    if (battleCtx->battleMons[attacker].heldItem == ITEM_PUNCHING_GLOVE) {
        for (int i = 0; i < NELEMS(sPunchingMoves); i++) {
            if (sPunchingMoves[i] == move) {
                return FALSE;
            }
        }
    }

    return TRUE;
}

// Sovereign (item 11): the moves that share Protect's chain of falling success chances (Gen VI+).
BOOL Sovereign_IsProtectionMove(int move)
{
    switch (move) {
    case MOVE_PROTECT:
    case MOVE_DETECT:
    case MOVE_ENDURE:
    case MOVE_KINGS_SHIELD:
    case MOVE_SPIKY_SHIELD:
    case MOVE_BANEFUL_BUNKER:
    case MOVE_OBSTRUCT:
    case MOVE_SILK_TRAP:
    case MOVE_BURNING_BULWARK:
    case MOVE_WIDE_GUARD:
    case MOVE_QUICK_GUARD:
        return TRUE;
    }

    return FALSE;
}

// Sovereign (item 11): King's Shield, Obstruct, Silk Trap and Burning Bulwark let status moves through.
BOOL Sovereign_ShieldBlocksStatusMoves(int shield)
{
    return shield != MOVE_KINGS_SHIELD && shield != MOVE_OBSTRUCT && shield != MOVE_SILK_TRAP
        && shield != MOVE_BURNING_BULWARK;
}

// Sovereign (item 11): the shields that punish a Pokemon whose contact move they block
// (subscript_sovereign_shield_contact).
BOOL Sovereign_ShieldHasContactPenalty(int shield)
{
    return shield == MOVE_KINGS_SHIELD || shield == MOVE_SPIKY_SHIELD || shield == MOVE_BANEFUL_BUNKER
        || shield == MOVE_OBSTRUCT || shield == MOVE_SILK_TRAP || shield == MOVE_BURNING_BULWARK;
}

// Sovereign (item 11): ball and bomb moves, which Bulletproof blocks.
static const u16 sBallAndBombMoves[] = {
    MOVE_ACID_SPRAY, MOVE_AURA_SPHERE, MOVE_BARRAGE, MOVE_BEAK_BLAST, MOVE_BULLET_SEED, MOVE_EGG_BOMB,
    MOVE_ELECTRO_BALL, MOVE_ENERGY_BALL, MOVE_FOCUS_BLAST, MOVE_GYRO_BALL, MOVE_ICE_BALL, MOVE_MAGNET_BOMB,
    MOVE_MIST_BALL, MOVE_MUD_BOMB, MOVE_OCTAZOOKA, MOVE_POLLEN_PUFF, MOVE_PYRO_BALL, MOVE_ROCK_BLAST,
    MOVE_ROCK_WRECKER, MOVE_SEARING_SHOT, MOVE_SEED_BOMB, MOVE_SHADOW_BALL, MOVE_SLUDGE_BOMB, MOVE_WEATHER_BALL,
    MOVE_ZAP_CANNON, MOVE_SYRUP_BOMB,
};

BOOL Move_IsBallOrBomb(int move)
{
    for (int i = 0; i < NELEMS(sBallAndBombMoves); i++) {
        if (sBallAndBombMoves[i] == move) {
            return TRUE;
        }
    }

    return FALSE;
}

// Sovereign: the moves that never miss a Minimized target and deal it double damage (Gen VI+). Platinum had only
// Stomp's double damage (effect_script_0150.s).
static const u16 sMinimizePunishMoves[] = {
    MOVE_BODY_SLAM, MOVE_STOMP, MOVE_STEAMROLLER, MOVE_DRAGON_RUSH, MOVE_HEAT_CRASH, MOVE_HEAVY_SLAM, MOVE_FLYING_PRESS,
    MOVE_SUPERCELL_SLAM,
};

BOOL Move_PunishesMinimize(int move)
{
    for (int i = 0; i < NELEMS(sMinimizePunishMoves); i++) {
        if (sMinimizePunishMoves[i] == move) {
            return TRUE;
        }
    }

    return FALSE;
}

// Sovereign (item 11): the type a Gem powers up, or -1 for any other item.
static const u16 sGemTypes[][2] = {
    { ITEM_NORMAL_GEM, TYPE_NORMAL },
    { ITEM_FIRE_GEM, TYPE_FIRE },
    { ITEM_WATER_GEM, TYPE_WATER },
    { ITEM_ELECTRIC_GEM, TYPE_ELECTRIC },
    { ITEM_GRASS_GEM, TYPE_GRASS },
    { ITEM_ICE_GEM, TYPE_ICE },
    { ITEM_FIGHTING_GEM, TYPE_FIGHTING },
    { ITEM_POISON_GEM, TYPE_POISON },
    { ITEM_GROUND_GEM, TYPE_GROUND },
    { ITEM_FLYING_GEM, TYPE_FLYING },
    { ITEM_PSYCHIC_GEM, TYPE_PSYCHIC },
    { ITEM_BUG_GEM, TYPE_BUG },
    { ITEM_ROCK_GEM, TYPE_ROCK },
    { ITEM_GHOST_GEM, TYPE_GHOST },
    { ITEM_DRAGON_GEM, TYPE_DRAGON },
    { ITEM_DARK_GEM, TYPE_DARK },
    { ITEM_STEEL_GEM, TYPE_STEEL },
    { ITEM_FAIRY_GEM, TYPE_FAIRY },
};

int Item_SovereignGemType(u16 item)
{
    for (int i = 0; i < NELEMS(sGemTypes); i++) {
        if (sGemTypes[i][0] == item) {
            return sGemTypes[i][1];
        }
    }

    return -1;
}

// Sovereign (item 11): powder moves, which don't affect Grass types or Overcoat (Gen VI+).
static const u16 sPowderMoves[] = {
    MOVE_COTTON_SPORE, MOVE_MAGIC_POWDER, MOVE_POISON_POWDER, MOVE_POWDER, MOVE_RAGE_POWDER, MOVE_SLEEP_POWDER,
    MOVE_SPORE, MOVE_STUN_SPORE,
};

BOOL Move_IsPowder(int move)
{
    for (int i = 0; i < NELEMS(sPowderMoves); i++) {
        if (sPowderMoves[i] == move) {
            return TRUE;
        }
    }

    return FALSE;
}

// Sovereign (item 11): TRUE when powder (powder moves, Effect Spore) can't affect the battler: a Grass type, Safety
// Goggles, or Overcoat (which Mold Breaker gets past when attacker uses the powder move).
BOOL Battler_SovereignPowderImmune(BattleContext *battleCtx, int attacker, int battler)
{
    return MON_HAS_TYPE(battler, TYPE_GRASS)
        || Battler_HeldItem(battleCtx, battler) == ITEM_SAFETY_GOGGLES
        || Battler_IgnorableAbility(battleCtx, attacker, battler, ABILITY_OVERCOAT) == TRUE;
}

// Sovereign (item 11): a move's priority for this battler, with Prankster (status moves +1), Gale Wings (Flying moves
// +1 at full HP) and Triage (healing moves +3).
int Sovereign_MovePriority(BattleContext *battleCtx, int battler, int move)
{
    int priority = MOVE_DATA(move).priority;
    int ability = Battler_Ability(battleCtx, battler);

    // Grassy Glide: +1 priority from a grounded user in Grassy Terrain.
    if (move == MOVE_GRASSY_GLIDE && (Sovereign_TerrainUnder(battleCtx, battler) & FIELD_CONDITION_TERRAIN_GRASSY)) {
        priority++;
    }

    if (ability == ABILITY_PRANKSTER && MOVE_DATA(move).class == CLASS_STATUS) {
        priority++;
    } else if (ability == ABILITY_GALE_WINGS && MOVE_DATA(move).type == TYPE_FLYING
        && battleCtx->battleMons[battler].curHP == battleCtx->battleMons[battler].maxHP) {
        priority++;
    } else if (ability == ABILITY_TRIAGE) {
        for (int i = 0; i < NELEMS(sHealingMoves); i++) {
            if (sHealingMoves[i] == move) {
                priority += 3;
                break;
            }
        }
    }

    return priority;
}

// Sovereign (item 11): Defiant (Attack +2), Competitive (Sp. Atk +2) and Rattled (Speed +1) after a stat drop. Sets the
// side effect for subscript_update_stat_stage; FALSE if there's nothing to raise.
BOOL Sovereign_SetupStatDropReaction(BattleContext *battleCtx, int battler)
{
    int ability = Battler_Ability(battleCtx, battler);
    int stat, param;

    if (ability == ABILITY_DEFIANT) {
        stat = BATTLE_STAT_ATTACK;
        param = MOVE_SUBSCRIPT_PTR_ATTACK_UP_2_STAGES;
    } else if (ability == ABILITY_COMPETITIVE) {
        stat = BATTLE_STAT_SP_ATTACK;
        param = MOVE_SUBSCRIPT_PTR_SP_ATTACK_UP_2_STAGES;
    } else if (ability == ABILITY_RATTLED) {
        stat = BATTLE_STAT_SPEED;
        param = MOVE_SUBSCRIPT_PTR_SPEED_UP_1_STAGE;
    } else {
        return FALSE;
    }

    if (battleCtx->battleMons[battler].curHP == 0 || battleCtx->battleMons[battler].statBoosts[stat] >= MAX_STAT_STAGE) {
        return FALSE;
    }

    battleCtx->sideEffectParam = param;
    battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
    battleCtx->sideEffectMon = battler;
    return TRUE;
}

// Sovereign (item 11): the Adrenaline Orb raises its holder's Speed after an Intimidate that targeted it (even one an
// Ability kept off; not one that found its Attack already at -6) and is used up. Sets up
// subscript_sovereign_item_stat_up.
BOOL Sovereign_SetupAdrenalineOrb(BattleContext *battleCtx, int battler)
{
    if (battleCtx->battleMons[battler].curHP == 0
        || Battler_HeldItem(battleCtx, battler) != ITEM_ADRENALINE_ORB
        || battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_SPEED] >= MAX_STAT_STAGE) {
        return FALSE;
    }

    battleCtx->msgBattlerTemp = battler;
    battleCtx->msgItemTemp = ITEM_ADRENALINE_ORB;
    battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_SPEED_UP_1_STAGE;
    battleCtx->msgTemp = 0;
    return TRUE;
}

// Sovereign (item 11): notes a battler's stat rise for the Mirror Herb holders and Opportunist Pokemon on the other side,
// which copy it once the move (or the switch-in) is over. Not a rise a Mirror Herb or Opportunist made itself.
void Sovereign_NoteMirrorHerbRise(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int stat, int stages)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    if (stages <= 0
        || (battleCtx->sideEffectType == SIDE_EFFECT_TYPE_HELD_ITEM && battleCtx->battleMons[battler].heldItem == ITEM_MIRROR_HERB)
        || (battleCtx->sideEffectType == SIDE_EFFECT_TYPE_ABILITY && Battler_Ability(battleCtx, battler) == ABILITY_OPPORTUNIST)) {
        return;
    }

    for (int i = 0; i < maxBattlers; i++) {
        if (BattleSystem_GetBattlerSide(battleSys, i) != BattleSystem_GetBattlerSide(battleSys, battler)
            && battleCtx->battleMons[i].curHP
            && (Battler_HeldItem(battleCtx, i) == ITEM_MIRROR_HERB || Battler_Ability(battleCtx, i) == ABILITY_OPPORTUNIST)) {
            battleCtx->sovereignMirrorHerbRises[i][stat] += stages;
        }
    }
}

// Sovereign (item 11): TRUE when a Mirror Herb holder or an Opportunist Pokemon has foes' stat rises to copy
// (Sovereign_NoteMirrorHerbRise). Sets up subscript_sovereign_mirror_herb, which copies them
// (BTLVAR_SOVEREIGN_MIRROR_HERB_NEXT) and uses the herb up, or subscript_sovereign_opportunist.
BOOL Sovereign_SetupMirrorHerb(BattleContext *battleCtx, int battler)
{
    int stat;

    for (stat = BATTLE_STAT_ATTACK; stat < BATTLE_STAT_MAX; stat++) {
        if (battleCtx->sovereignMirrorHerbRises[battler][stat]) {
            break;
        }
    }

    if (stat == BATTLE_STAT_MAX) {
        return FALSE;
    }

    if (battleCtx->battleMons[battler].curHP == 0
        || (Battler_HeldItem(battleCtx, battler) != ITEM_MIRROR_HERB && Battler_Ability(battleCtx, battler) != ABILITY_OPPORTUNIST)) {
        MI_CpuClear8(battleCtx->sovereignMirrorHerbRises[battler], sizeof(battleCtx->sovereignMirrorHerbRises[battler]));
        return FALSE;
    }

    battleCtx->msgBattlerTemp = battler;
    battleCtx->msgItemTemp = ITEM_MIRROR_HERB;
    battleCtx->sovereignMirrorHerbHolder = battler;
    return TRUE;
}

// Sovereign (item 11): Sheer Force applies to damaging moves with a chance of a secondary effect (the "chance" in the
// move data), except charge moves that use it for their own boost.
BOOL Move_SheerForceApplies(BattleContext *battleCtx, int attacker, int move)
{
    return Battler_Ability(battleCtx, attacker) == ABILITY_SHEER_FORCE
        && MOVE_DATA(move).class != CLASS_STATUS
        && MOVE_DATA(move).effectChance > 0
        && MOVE_DATA(move).effect != BATTLE_EFFECT_CHARGE_TURN_DEF_UP
        && MOVE_DATA(move).effect != BATTLE_EFFECT_ELECTRO_SHOT;
}

// Sovereign (item 11): moves that always land a critical hit, and moves with a raised critical-hit ratio that keep
// another battle effect. Read by BtlCmd_CalcCrit.
int Move_SovereignCritStage(int move)
{
    switch (move) {
    case MOVE_STORM_THROW:
    case MOVE_FROST_BREATH:
    case MOVE_WICKED_BLOW:
    case MOVE_SURGING_STRIKES:
    case MOVE_FLOWER_TRICK:
        return 3;
    case MOVE_ESPER_WING:
    case MOVE_IVY_CUDGEL:
    case MOVE_DIRE_CLAW:
    case MOVE_TRIPLE_ARROWS:
    case MOVE_CEASELESS_EDGE:
    case MOVE_STONE_AXE:
        return 1;
    }

    return 0;
}

// Sovereign (item 11): rolls a move's second chance effect, whose chance isn't the one in its data (Triple Arrows' 30%
// flinch next to its 50% Defense drop). Serene Grace doubles it; Sheer Force and Covert Cloak keep it off.
BOOL Sovereign_RollSecondEffect(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int chance;

    switch (battleCtx->moveCur) {
    case MOVE_TRIPLE_ARROWS:
        chance = 30;
        break;
    default:
        return FALSE;
    }

    if (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_SERENE_GRACE) {
        chance *= 2;
    }

    if (Move_SheerForceApplies(battleCtx, battleCtx->attacker, battleCtx->moveCur)
        || Sovereign_CovertCloakBlocks(battleCtx)
        || battleCtx->battleMons[battleCtx->sideEffectMon].curHP == 0) {
        return FALSE;
    }

    return BattleSystem_RandNext(battleSys) % 100 < chance;
}

// Sovereign (item 11): Salt Cure takes hold of the side-effect battler. FALSE if it already had.
BOOL Sovereign_StartSaltCure(BattleContext *battleCtx)
{
    if (battleCtx->sovereignSaltCure & FlagIndex(battleCtx->sideEffectMon)) {
        return FALSE;
    }

    battleCtx->sovereignSaltCure |= FlagIndex(battleCtx->sideEffectMon);
    return TRUE;
}

// Sovereign (item 11): Syrup Bomb covers the side-effect battler: its Speed falls at the end of the next 3 turns, for
// as long as the attacker stays in. FALSE if it was already covered.
BOOL Sovereign_StartSyrupBomb(BattleContext *battleCtx)
{
    int battler = battleCtx->sideEffectMon;

    if (battleCtx->sovereignSyrupBomb[battler]) {
        return FALSE;
    }

    battleCtx->sovereignSyrupBomb[battler] = 3;
    battleCtx->sovereignSyrupBombSource[battler] = battleCtx->attacker;
    battleCtx->sovereignSyrupBombSourceSlot[battler] = battleCtx->selectedPartySlot[battleCtx->attacker];
    return TRUE;
}

// Sovereign (item 11): Tar Shot makes the side-effect battler weaker to Fire. FALSE if it already was.
BOOL Sovereign_StartTarShot(BattleContext *battleCtx)
{
    if (battleCtx->sovereignTarShot & FlagIndex(battleCtx->sideEffectMon)) {
        return FALSE;
    }

    battleCtx->sovereignTarShot |= FlagIndex(battleCtx->sideEffectMon);
    return TRUE;
}

// Sovereign (item 11): Court Change swaps the two sides' field effects (Reflect, Light Screen, Aurora Veil, Mist,
// Safeguard, Tailwind, Lucky Chant and the entry hazards). FALSE when neither side has any.
BOOL Sovereign_CourtChange(BattleContext *battleCtx)
{
    u32 swapMask = SIDE_CONDITION_REFLECT | SIDE_CONDITION_LIGHT_SCREEN | SIDE_CONDITION_SOVEREIGN_AURORA_VEIL
        | SIDE_CONDITION_MIST | SIDE_CONDITION_SAFEGUARD | SIDE_CONDITION_TAILWIND | SIDE_CONDITION_LUCKY_CHANT
        | SIDE_CONDITION_SPIKES | SIDE_CONDITION_TOXIC_SPIKES | SIDE_CONDITION_STEALTH_ROCK
        | SIDE_CONDITION_SOVEREIGN_STICKY_WEB;
    u32 mask0 = battleCtx->sideConditionsMask[0] & swapMask;
    u32 mask1 = battleCtx->sideConditionsMask[1] & swapMask;

    if (mask0 == 0 && mask1 == 0) {
        return FALSE;
    }

    battleCtx->sideConditionsMask[0] = (battleCtx->sideConditionsMask[0] & ~swapMask) | mask1;
    battleCtx->sideConditionsMask[1] = (battleCtx->sideConditionsMask[1] & ~swapMask) | mask0;

    // Follow Me and the knocked-off items stay with their side.
    SideConditions *side0 = &battleCtx->sideConditions[0];
    SideConditions *side1 = &battleCtx->sideConditions[1];
    SideConditions temp = *side0;

    side0->reflectUser = side1->reflectUser;
    side0->reflectTurns = side1->reflectTurns;
    side0->lightScreenUser = side1->lightScreenUser;
    side0->lightScreenTurns = side1->lightScreenTurns;
    side0->mistUser = side1->mistUser;
    side0->mistTurns = side1->mistTurns;
    side0->safeguardUser = side1->safeguardUser;
    side0->safeguardTurns = side1->safeguardTurns;
    side0->spikesLayers = side1->spikesLayers;
    side0->toxicSpikesLayers = side1->toxicSpikesLayers;
    side1->reflectUser = temp.reflectUser;
    side1->reflectTurns = temp.reflectTurns;
    side1->lightScreenUser = temp.lightScreenUser;
    side1->lightScreenTurns = temp.lightScreenTurns;
    side1->mistUser = temp.mistUser;
    side1->mistTurns = temp.mistTurns;
    side1->safeguardUser = temp.safeguardUser;
    side1->safeguardTurns = temp.safeguardTurns;
    side1->spikesLayers = temp.spikesLayers;
    side1->toxicSpikesLayers = temp.toxicSpikesLayers;

    int veilTurns = battleCtx->sovereignAuroraVeilTurns[0];
    battleCtx->sovereignAuroraVeilTurns[0] = battleCtx->sovereignAuroraVeilTurns[1];
    battleCtx->sovereignAuroraVeilTurns[1] = veilTurns;
    return TRUE;
}

// Sovereign (item 11): Tidy Up clears the entry hazards from both sides. FALSE when there were none.
BOOL Sovereign_TidyUpHazards(BattleContext *battleCtx)
{
    u32 hazards = SIDE_CONDITION_SPIKES | SIDE_CONDITION_TOXIC_SPIKES | SIDE_CONDITION_STEALTH_ROCK
        | SIDE_CONDITION_SOVEREIGN_STICKY_WEB;
    BOOL cleared = FALSE;

    for (int side = 0; side < NUM_BATTLE_SIDES; side++) {
        if (battleCtx->sideConditionsMask[side] & hazards) {
            cleared = TRUE;
        }

        battleCtx->sideConditionsMask[side] &= ~hazards;
        battleCtx->sideConditions[side].spikesLayers = 0;
        battleCtx->sideConditions[side].toxicSpikesLayers = 0;
    }

    return cleared;
}

// Sovereign (item 11): a battler's Attack with its stat stage applied (Strength Sap).
u32 Sovereign_StagedAttack(BattleContext *battleCtx, int battler)
{
    int stage = battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_ATTACK];
    return battleCtx->battleMons[battler].attack * sStatStageBoosts[stage].numerator / sStatStageBoosts[stage].denominator;
}

// Sovereign (item 11): a battler's Speed with its stat stage applied.
static u32 Sovereign_StagedSpeed(BattleContext *battleCtx, int battler)
{
    int stage = battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_SPEED];
    return battleCtx->battleMons[battler].speed * sStatStageBoosts[stage].numerator / sStatStageBoosts[stage].denominator;
}

// Sovereign (item 11): a battler's weight, with Heavy Metal, Light Metal and Float Stone.
static u32 Sovereign_Weight(BattleContext *battleCtx, int attacker, int battler)
{
    u32 weight = battleCtx->battleMons[battler].weight;

    if (Battler_IgnorableAbility(battleCtx, attacker, battler, ABILITY_HEAVY_METAL) == TRUE) {
        weight *= 2;
    } else if (Battler_IgnorableAbility(battleCtx, attacker, battler, ABILITY_LIGHT_METAL) == TRUE) {
        weight /= 2;
    }

    if (Battler_HeldItem(battleCtx, battler) == ITEM_FLOAT_STONE) {
        weight /= 2;
    }

    return weight ? weight : 1;
}

// Sovereign (item 11): the Pokemon the holder carries up by Sky Drop, BATTLER_NONE for none.
int Sovereign_SkyDropTarget(BattleContext *battleCtx, int holder)
{
    int target = battleCtx->sovereignSkyDropTarget[holder] - 1;

    if (target < 0 || battleCtx->sovereignSkyDropHolder[target] != holder + 1) {
        return BATTLER_NONE;
    }

    return target;
}

// Sovereign (item 11): the Pokemon carrying the target up by Sky Drop, BATTLER_NONE for none.
int Sovereign_SkyDropHolder(BattleContext *battleCtx, int target)
{
    int holder = battleCtx->sovereignSkyDropHolder[target] - 1;

    if (holder < 0 || battleCtx->sovereignSkyDropTarget[holder] != target + 1) {
        return BATTLER_NONE;
    }

    return holder;
}

// Sovereign (item 11): Sky Drop's first turn, past Protect and the like (Showdown's onTryHit). 1: it fails on the
// user's ally and on a substitute. 2: a target of 200 kg or more is too heavy. 0: the user carries the target up; both
// are in the air (out of reach of most moves), and the target can't move or switch out until it's dropped or let go.
int Sovereign_SkyDropTryLift(BattleSystem *battleSys, BattleContext *battleCtx, int holder, int target)
{
    if (BattleSystem_GetBattlerSide(battleSys, holder) == BattleSystem_GetBattlerSide(battleSys, target)
        || (battleCtx->battleMons[target].statusVolatile & VOLATILE_CONDITION_SUBSTITUTE)) {
        return 1;
    }

    if (Sovereign_Weight(battleCtx, holder, target) >= 2000) {
        return 2;
    }

    battleCtx->sovereignSkyDropTarget[holder] = target + 1;
    battleCtx->sovereignSkyDropHolder[target] = holder + 1;
    battleCtx->battleMons[holder].moveEffectsMask |= MOVE_EFFECT_AIRBORNE;
    battleCtx->battleMons[target].moveEffectsMask |= MOVE_EFFECT_AIRBORNE;
    return 0;
}

// Sovereign (item 11): the holder lets its Sky Drop target go; the target is back on the ground.
void Sovereign_SkyDropLetGo(BattleContext *battleCtx, int holder, int target)
{
    battleCtx->sovereignSkyDropTarget[holder] = 0;
    battleCtx->sovereignSkyDropHolder[target] = 0;
    battleCtx->battleMons[target].moveEffectsMask &= ~MOVE_EFFECT_AIRBORNE;
}

// Sovereign (item 11): Smack Down and Thousand Arrows bring a Pokemon in the air by Fly or Bounce down: its move ends,
// and if its turn is still to come, it's lost (Showdown). Sky Drop's pair stays up. TRUE if the battler came down.
BOOL Sovereign_SmackDownFlyer(BattleContext *battleCtx, int battler)
{
    if ((battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_AIRBORNE) == FALSE
        || battleCtx->sovereignSkyDropTarget[battler]
        || battleCtx->sovereignSkyDropHolder[battler]) {
        return FALSE;
    }

    Battler_UnlockMoveChoice(NULL, battleCtx, battler);
    battleCtx->battlerActions[battler][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_MOVE_END;
    return TRUE;
}

// Sovereign (item 11): Emergency Exit and Wimp Out also switch their holder out when its HP fell from above half to
// half or less by something other than another Pokemon's hit (BattleSystem_TriggerHeldItemOnHit): its own damaging
// move's recoil, crash or Life Orb, a Rocky Helmet, or the end-of-turn damage (Showdown's EmergencyExit events).
// hpBefore is its HP before that; TRUE if it switches (or a wild one flees).
BOOL Sovereign_EmergencyExitDue(BattleContext *battleCtx, int battler, int hpBefore)
{
    BattleMon *mon = &battleCtx->battleMons[battler];

    return (Battler_Ability(battleCtx, battler) == ABILITY_EMERGENCY_EXIT || Battler_Ability(battleCtx, battler) == ABILITY_WIMP_OUT)
        && mon->curHP
        && mon->curHP <= mon->maxHP / 2
        && hpBefore > mon->maxHP / 2
        && (battleCtx->battlersSwitchingMask & FlagIndex(battler)) == FALSE;
}

// Sovereign (item 11): the next Eject Pack holder (fastest first) that had a stat lowered and switches out now, or
// BATTLER_NONE. Checked after a move, after the switch-in effects and at the end of the turn (Showdown's ejectpack:
// AfterMove, SwitchIn, Residual). A holder that has fainted, lost its Eject Pack or is in a Commander pair since is
// dropped; subscript_sovereign_eject_pack leaves the pack with one that has no Pokemon to switch to.
int Sovereign_EjectPackHolder(BattleSystem *battleSys, BattleContext *battleCtx)
{
    for (int i = 0; i < BattleSystem_GetMaxBattlers(battleSys); i++) {
        int battler = battleCtx->monSpeedOrder[i];

        if ((battleCtx->sovereignEjectPackPending & FlagIndex(battler)) == FALSE) {
            continue;
        }

        battleCtx->sovereignEjectPackPending &= ~FlagIndex(battler);

        if (battleCtx->battleMons[battler].curHP
            && Battler_HeldItem(battleCtx, battler) == ITEM_EJECT_PACK
            && ((battleCtx->sovereignCommanding | battleCtx->sovereignCommanded) & FlagIndex(battler)) == FALSE
            && (battleCtx->battlersSwitchingMask & FlagIndex(battler)) == FALSE) {
            return battler;
        }
    }

    return BATTLER_NONE;
}

// Sovereign (item 11): how many consecutive turns Echoed Voice will have been used if used now (1-5).
int Sovereign_EchoedVoiceCount(BattleContext *battleCtx)
{
    int count;

    if (battleCtx->sovereignEchoedVoiceTurn == battleCtx->totalTurns + 1) {
        count = battleCtx->sovereignEchoedVoiceCount; // already used this turn
    } else if (battleCtx->sovereignEchoedVoiceTurn == battleCtx->totalTurns) {
        count = battleCtx->sovereignEchoedVoiceCount + 1; // used last turn
    } else {
        count = 1;
    }

    return count > 5 ? 5 : count;
}

// Sovereign (12b): the power of the moves whose battle script works it out (BtlCmd_CalcFlailPower and the like), here
// so the trainer AI's damage estimates (TrainerAI_CalcDamage) use the same numbers as the moves.

// Flail and Reversal: by the user's HP out of 48 (Gen V+), not the HP bar's 64 pixels.
static const u8 sHPOutOf48ToFlailPower[][2] = {
    { 1, 200 },
    { 4, 150 },
    { 9, 100 },
    { 16, 80 },
    { 32, 40 },
    { 48, 20 },
};

int Sovereign_FlailPower(BattleMon *mon)
{
    int i, hp = mon->curHP * 48 / mon->maxHP;

    if (hp < 1) {
        hp = 1;
    }

    for (i = 0; i < NELEMS(sHPOutOf48ToFlailPower) - 1; i++) {
        if (hp <= sHPOutOf48ToFlailPower[i][0]) {
            break;
        }
    }

    return sHPOutOf48ToFlailPower[i][1];
}

// Crush Grip and Wring Out (maxPower 120), Hard Press (100): by the target's HP, through a 4096ths ratio as in Showdown,
// at least 1.
int Sovereign_HPRatioPower(BattleMon *mon, int maxPower)
{
    int hpRatio = mon->curHP * 4096 / mon->maxHP;
    int power = (maxPower * 100 * hpRatio + 4096 / 2 - 1) / 4096 / 100;

    return power ? power : 1;
}

// Eruption, Water Spout and Dragon Energy: their power scaled by the user's HP, at least 1.
int Sovereign_HPFalloffPower(BattleMon *mon, int power)
{
    power = power * mon->curHP / mon->maxHP;

    return power ? power : 1;
}

// Punishment: 60, and 20 more for each stage the target's stats are raised, up to 200.
int Sovereign_PunishmentPower(BattleMon *mon)
{
    int i, sumBoosts = 0;

    for (i = BATTLE_STAT_HP; i < BATTLE_STAT_MAX; i++) {
        if (mon->statBoosts[i] > DEFAULT_STAT_STAGE) {
            sumBoosts += mon->statBoosts[i] - DEFAULT_STAT_STAGE;
        }
    }

    return 60 + 20 * sumBoosts > 200 ? 200 : 60 + 20 * sumBoosts;
}

// Trump Card: by the PP it has left once used (0: 200, 1: 80, 2: 60, 3: 50, 4 or more: 40).
int Sovereign_TrumpCardPower(int ppLeft)
{
    static const u8 sPPLeftToPower[] = { 200, 80, 60, 50, 40 };

    return sPPLeftToPower[ppLeft > 4 ? 4 : ppLeft];
}

// Sovereign (item 11): the power of Gen V+ moves whose power depends on the battle (the move keeps the plain hit
// effect; BattleSystem_CalcMoveDamage asks here). Returns the power unchanged for every other move.
int Sovereign_MovePower(BattleSystem *battleSys, BattleContext *battleCtx, int move, int attacker, int defender, int power)
{
    u32 ratio;
    int i, boosts;

    switch (move) {
    case MOVE_HEX: // double against a Pokemon with a status condition
    case MOVE_INFERNAL_PARADE:
        if ((battleCtx->battleMons[defender].status & MON_CONDITION_ANY)
            || Battler_Ability(battleCtx, defender) == ABILITY_COMATOSE) { // Sovereign (item 11): as if asleep
            power *= 2;
        }
        break;

    case MOVE_VENOSHOCK: // double against a poisoned Pokemon
    case MOVE_BARB_BARRAGE:
        if (battleCtx->battleMons[defender].status & MON_CONDITION_ANY_POISON) {
            power *= 2;
        }
        break;

    case MOVE_WATER_SHURIKEN: // Sovereign (FM): 20 power from Ash-Greninja
        if (Sovereign_IsAshGreninja(&battleCtx->battleMons[attacker])) {
            power = 20;
        }
        break;

    case MOVE_ACROBATICS: // double when the user holds no item
        if (battleCtx->battleMons[attacker].heldItem == ITEM_NONE) {
            power *= 2;
        }
        break;

    case MOVE_KNOCK_OFF: // ×1.5 against a target holding an item it can lose (Gen VI+), Sticky Hold or not
        if (battleCtx->battleMons[defender].heldItem != ITEM_NONE
            && Battler_SovereignHeldItemLocked(battleCtx, defender) == FALSE) {
            power = power * 3 / 2;
        }
        break;

    case MOVE_ELECTRO_BALL: // the faster the user is than the target, the stronger
        ratio = Sovereign_StagedSpeed(battleCtx, attacker) / (Sovereign_StagedSpeed(battleCtx, defender) ? Sovereign_StagedSpeed(battleCtx, defender) : 1);
        power = ratio >= 4 ? 150 : ratio >= 3 ? 120 : ratio >= 2 ? 80 : ratio >= 1 ? 60 : 40;
        break;

    case MOVE_HEAVY_SLAM: // the heavier the user is than the target, the stronger
    case MOVE_HEAT_CRASH:
        ratio = Sovereign_Weight(battleCtx, attacker, attacker) / Sovereign_Weight(battleCtx, attacker, defender);
        power = ratio >= 5 ? 120 : ratio >= 4 ? 100 : ratio >= 3 ? 80 : ratio >= 2 ? 60 : 40;
        break;

    case MOVE_STORED_POWER: // 20 more power for each stage the user's stats are raised
    case MOVE_POWER_TRIP:
        boosts = 0;
        for (i = BATTLE_STAT_ATTACK; i < BATTLE_STAT_MAX; i++) {
            if (battleCtx->battleMons[attacker].statBoosts[i] > 6) {
                boosts += battleCtx->battleMons[attacker].statBoosts[i] - 6;
            }
        }
        power = 20 + 20 * boosts;
        break;

    case MOVE_FISHIOUS_REND: // double if the target hasn't moved yet this turn
    case MOVE_BOLT_BEAK:
        if (Battler_MovedThisTurn(battleCtx, defender) == FALSE) {
            power *= 2;
        }
        break;

    case MOVE_HARD_PRESS: // up to 100 power, by the target's remaining HP (as Crush Grip's, up to 120)
        power = Sovereign_HPRatioPower(&battleCtx->battleMons[defender], 100);
        break;

    case MOVE_FICKLE_BEAM: // 30% chance of double power
        if (BattleSystem_RandNext(battleSys) % 10 < 3) {
            power *= 2;
        }
        break;

    case MOVE_RISING_VOLTAGE: // double in Electric Terrain against a grounded target
        if (Sovereign_TerrainUnder(battleCtx, defender) & FIELD_CONDITION_TERRAIN_ELECTRIC) {
            power *= 2;
        }
        break;

    case MOVE_EXPANDING_FORCE: // 1.5x from a grounded user in Psychic Terrain (and it hits both foes: Sovereign_MoveRange)
        if (Sovereign_TerrainUnder(battleCtx, attacker) & FIELD_CONDITION_TERRAIN_PSYCHIC) {
            power = power * 15 / 10;
        }
        break;

    case MOVE_MISTY_EXPLOSION: // 1.5x from a grounded user in Misty Terrain
        if (Sovereign_TerrainUnder(battleCtx, attacker) & FIELD_CONDITION_TERRAIN_MISTY) {
            power = power * 15 / 10;
        }
        break;

    case MOVE_PSYBLADE: // 1.5x in Electric Terrain
        if (battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN_ELECTRIC) {
            power = power * 15 / 10;
        }
        break;

    case MOVE_TERRAIN_PULSE: // double from a grounded user in a terrain (its type follows the terrain)
        if (Sovereign_TerrainUnder(battleCtx, attacker)) {
            power *= 2;
        }
        break;

    case MOVE_ECHOED_VOICE: // 40 more power for each consecutive turn it's been used (by anyone), up to 200
        power = 40 * Sovereign_EchoedVoiceCount(battleCtx);
        break;

    case MOVE_RETALIATE: // double if a Pokemon on the user's side fainted last turn
        if (battleCtx->sovereignSideFaintTurn[BattleSystem_GetBattlerSide(battleSys, attacker)] == battleCtx->totalTurns) {
            power *= 2;
        }
        break;

    case MOVE_STOMPING_TANTRUM: // double if the user's last move failed
    case MOVE_TEMPER_FLARE:
        if (battleCtx->sovereignLastMoveFailed[attacker]) {
            power *= 2;
        }
        break;

    case MOVE_LASH_OUT: // double if the user's stats were lowered this turn
        if (battleCtx->turnFlags[attacker].sovereignStatsLowered) {
            power *= 2;
        }
        break;

    case MOVE_ROUND: // double when another Pokemon's Round called this one up (Sovereign_CallNextRound)
        if (battleCtx->turnFlags[attacker].sovereignRoundCalled) {
            power *= 2;
        }
        break;

    case MOVE_GRAV_APPLE: // 1.5x under Gravity
        if (battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY) {
            power = power * 15 / 10;
        }
        break;

    case MOVE_LAST_RESPECTS: { // 50 more power for each fainted Pokemon in the user's party
        int partyCount = BattleSystem_GetPartyCount(battleSys, attacker);

        for (i = 0; i < partyCount; i++) {
            Pokemon *mon = BattleSystem_GetPartyPokemon(battleSys, attacker, i);

            if (Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_NONE
                && Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_EGG
                && Pokemon_GetValue(mon, MON_DATA_HP, NULL) == 0) {
                power += 50;
            }
        }
        break;
    }

    case MOVE_RAGE_FIST: // 50 more power for each hit the user has taken this battle, up to 350
        power += 50 * battleCtx->sovereignTimesHit[attacker][battleCtx->selectedPartySlot[attacker]];
        break;

    case MOVE_FUSION_FLARE: // double right after a Fusion Bolt worked this turn, and the other way round
    case MOVE_FUSION_BOLT:
        if (battleCtx->sovereignLastMoveTurn == battleCtx->totalTurns + 1
            && battleCtx->sovereignLastMoveThisTurn == (move == MOVE_FUSION_FLARE ? MOVE_FUSION_BOLT : MOVE_FUSION_FLARE)) {
            power *= 2;
        }
        break;
    }

    // Sovereign: double against a Minimized target (Gen VI+; Move_PunishesMinimize).
    if (Move_PunishesMinimize(move) && (battleCtx->battleMons[defender].moveEffectsMask & MOVE_EFFECT_MINIMIZE)) {
        power *= 2;
    }

    return power;
}

// Sovereign (item 11): pulse moves, boosted by Mega Launcher.
static const u16 sPulseMoves[] = {
    MOVE_AURA_SPHERE,
    MOVE_DARK_PULSE,
    MOVE_DRAGON_PULSE,
    MOVE_WATER_PULSE,
    MOVE_ORIGIN_PULSE,
    MOVE_TERRAIN_PULSE,
};

// Sovereign (item 11): slicing moves, boosted by Sharpness. Pokémon Champions adds the claws (Crush Claw, Dire Claw,
// Dragon Claw, Metal Claw, Shadow Claw).
static const u16 sSlicingMoves[] = {
    MOVE_AERIAL_ACE,
    MOVE_AIR_CUTTER,
    MOVE_AIR_SLASH,
    MOVE_AQUA_CUTTER,
    MOVE_BEHEMOTH_BLADE,
    MOVE_BITTER_BLADE,
    MOVE_CEASELESS_EDGE,
    MOVE_CROSS_POISON,
    MOVE_CRUSH_CLAW,
    MOVE_CUT,
    MOVE_DIRE_CLAW,
    MOVE_DRAGON_CLAW,
    MOVE_FURY_CUTTER,
    MOVE_KOWTOW_CLEAVE,
    MOVE_LEAF_BLADE,
    MOVE_METAL_CLAW,
    MOVE_MIGHTY_CLEAVE,
    MOVE_NIGHT_SLASH,
    MOVE_POPULATION_BOMB,
    MOVE_PSYBLADE,
    MOVE_PSYCHO_CUT,
    MOVE_RAZOR_LEAF,
    MOVE_RAZOR_SHELL,
    MOVE_SACRED_SWORD,
    MOVE_SECRET_SWORD,
    MOVE_SHADOW_CLAW,
    MOVE_SLASH,
    MOVE_SOLAR_BLADE,
    MOVE_STONE_AXE,
    MOVE_TACHYON_CUTTER,
    MOVE_X_SCISSOR,
};

static BOOL Sovereign_MoveInList(const u16 *list, int count, int move)
{
    for (int i = 0; i < count; i++) {
        if (list[i] == move) {
            return TRUE;
        }
    }

    return FALSE;
}

// Sovereign (item 11): TRUE if a battler other than `except` is on the field with this ability (Ruin abilities, Auras).
static BOOL Sovereign_FieldHasAbility(BattleSystem *battleSys, BattleContext *battleCtx, int ability, int except)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    for (int i = 0; i < maxBattlers; i++) {
        if (i != except && battleCtx->battleMons[i].curHP && Battler_Ability(battleCtx, i) == ability) {
            return TRUE;
        }
    }

    return FALSE;
}

// Sovereign (item 11): TRUE while Protosynthesis has harsh sunlight.
static BOOL Sovereign_ProtosynthesisHasSun(BattleSystem *battleSys, BattleContext *battleCtx)
{
    return (battleCtx->fieldConditionsMask & FIELD_CONDITION_SUNNY)
        && BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALL_BATTLERS, 0, ABILITY_CLOUD_NINE) == 0
        && BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALL_BATTLERS, 0, ABILITY_AIR_LOCK) == 0;
}

// Sovereign (item 11): Protosynthesis (in harsh sunlight) and Quark Drive (in Electric Terrain) boost the holder's
// highest stat, as does a Booster Energy it used. Returns that BATTLE_STAT_*, or -1 if inactive.
int Sovereign_ProtosynthesisStat(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    BattleMon *mon = &battleCtx->battleMons[battler];
    int ability = Battler_Ability(battleCtx, battler);

    if ((ability != ABILITY_PROTOSYNTHESIS && ability != ABILITY_QUARK_DRIVE)
        || (mon->sovereignBoosterEnergy == FALSE
            && (ability != ABILITY_PROTOSYNTHESIS || Sovereign_ProtosynthesisHasSun(battleSys, battleCtx) == FALSE)
            && (ability != ABILITY_QUARK_DRIVE || (battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN_ELECTRIC) == FALSE))) {
        return -1;
    }

    u16 stats[5] = { mon->attack, mon->defense, mon->spAttack, mon->spDefense, mon->speed };
    u8 statIDs[5] = { BATTLE_STAT_ATTACK, BATTLE_STAT_DEFENSE, BATTLE_STAT_SP_ATTACK, BATTLE_STAT_SP_DEFENSE, BATTLE_STAT_SPEED };
    int best = 0;

    for (int i = 1; i < 5; i++) {
        if (stats[i] > stats[best]) {
            best = i;
        }
    }

    return statIDs[best];
}

// Sovereign (item 11): biting moves, boosted by Strong Jaw.
static const u16 sBitingMoves[] = {
    MOVE_BITE,
    MOVE_CRUNCH,
    MOVE_FIRE_FANG,
    MOVE_ICE_FANG,
    MOVE_THUNDER_FANG,
    MOVE_POISON_FANG,
    MOVE_HYPER_FANG,
    MOVE_PSYCHIC_FANGS,
    MOVE_JAW_LOCK,
    MOVE_FISHIOUS_REND,
};

typedef struct DamageCalcParams {
    u16 species;
    s16 curHP;
    u16 maxHP;
    u16 _padding06;

    int heldItemEffect;
    int heldItemPower;

    u32 statusMask;

    u16 ability;
    u8 gender;
    u8 type1;
    u8 type2;
} DamageCalcParams;

int BattleSystem_CalcMoveDamage(BattleSystem *battleSys,
    BattleContext *battleCtx,
    int move,
    u32 sideConditions,
    u32 fieldConditions,
    u16 inPower,
    u8 inType,
    u8 attacker,
    u8 defender,
    u8 criticalMul)
{
    // vars have to all be declared C89-style to match
    int i;
    s32 damage = 0;
    s32 stageDivisor = 0;
    u8 moveType;
    u8 moveClass;
    u16 attackStat;
    u16 defenseStat;
    u16 spAttackStat;
    u16 spDefenseStat;
    s8 attackStage;
    s8 defenseStage;
    s8 spAttackStage;
    s8 spDefenseStage;
    u8 attackerLevel;
    u16 movePower;
    u16 itemTmp;
    u32 battleType;
    DamageCalcParams attackerParams;
    DamageCalcParams defenderParams;

    GF_ASSERT(criticalMul == 1 || criticalMul > 1);

    attackStat = BattleMon_Get(battleCtx, attacker, BATTLEMON_ATTACK, NULL);
    defenseStat = BattleMon_Get(battleCtx, defender, BATTLEMON_DEFENSE, NULL);
    spAttackStat = BattleMon_Get(battleCtx, attacker, BATTLEMON_SP_ATTACK, NULL);
    spDefenseStat = BattleMon_Get(battleCtx, defender, BATTLEMON_SP_DEFENSE, NULL);
    attackStage = BattleMon_Get(battleCtx, attacker, BATTLEMON_ATTACK_STAGE, NULL) - DEFAULT_STAT_STAGE;
    defenseStage = BattleMon_Get(battleCtx, defender, BATTLEMON_DEFENSE_STAGE, NULL) - DEFAULT_STAT_STAGE;
    spAttackStage = BattleMon_Get(battleCtx, attacker, BATTLEMON_SP_ATTACK_STAGE, NULL) - DEFAULT_STAT_STAGE;
    spDefenseStage = BattleMon_Get(battleCtx, defender, BATTLEMON_SP_DEFENSE_STAGE, NULL) - DEFAULT_STAT_STAGE;

    // Sovereign (item 11): Wonder Room swaps the target's Defense and Sp. Def stats (not their stages).
    if (battleCtx->sovereignWonderRoomTurns) {
        u16 swap = defenseStat;
        defenseStat = spDefenseStat;
        spDefenseStat = swap;
    }

    attackerLevel = BattleMon_Get(battleCtx, attacker, BATTLEMON_LEVEL, NULL);

    attackerParams.species = BattleMon_Get(battleCtx, attacker, BATTLEMON_SPECIES, NULL);
    defenderParams.species = BattleMon_Get(battleCtx, defender, BATTLEMON_SPECIES, NULL);
    attackerParams.curHP = BattleMon_Get(battleCtx, attacker, BATTLEMON_CUR_HP, NULL);
    defenderParams.curHP = BattleMon_Get(battleCtx, defender, BATTLEMON_CUR_HP, NULL);
    attackerParams.maxHP = BattleMon_Get(battleCtx, attacker, BATTLEMON_MAX_HP, NULL);
    defenderParams.maxHP = BattleMon_Get(battleCtx, defender, BATTLEMON_MAX_HP, NULL);
    attackerParams.statusMask = BattleMon_Get(battleCtx, attacker, BATTLEMON_STATUS, NULL);
    defenderParams.statusMask = BattleMon_Get(battleCtx, defender, BATTLEMON_STATUS, NULL);
    attackerParams.ability = Battler_Ability(battleCtx, attacker);
    defenderParams.ability = Battler_Ability(battleCtx, defender);
    attackerParams.gender = BattleMon_Get(battleCtx, attacker, BATTLEMON_GENDER, NULL);
    defenderParams.gender = BattleMon_Get(battleCtx, defender, BATTLEMON_GENDER, NULL);
    attackerParams.type1 = BattleMon_Get(battleCtx, attacker, BATTLEMON_TYPE_1, NULL);
    defenderParams.type1 = BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_1, NULL);
    attackerParams.type2 = BattleMon_Get(battleCtx, attacker, BATTLEMON_TYPE_2, NULL);
    defenderParams.type2 = BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_2, NULL);

    itemTmp = Battler_HeldItem(battleCtx, attacker);
    attackerParams.heldItemEffect = BattleSystem_GetItemData(battleCtx, itemTmp, ITEM_PARAM_HOLD_EFFECT);
    attackerParams.heldItemPower = BattleSystem_GetItemData(battleCtx, itemTmp, ITEM_PARAM_EFFECT_PARAM);

    itemTmp = Battler_HeldItem(battleCtx, defender);
    defenderParams.heldItemEffect = BattleSystem_GetItemData(battleCtx, itemTmp, ITEM_PARAM_HOLD_EFFECT);
    defenderParams.heldItemPower = BattleSystem_GetItemData(battleCtx, itemTmp, ITEM_PARAM_EFFECT_PARAM);

    battleType = BattleSystem_GetBattleType(battleSys);

    // Assign power; prefer the input power (used by variable-power moves, e.g. Gyro Ball)
    if (inPower == 0) {
        movePower = MOVE_DATA(move).power;
    } else {
        movePower = inPower;
    }

    movePower = Sovereign_MovePower(battleSys, battleCtx, move, attacker, defender, movePower);

    // Sovereign (item 11): Normalize, the -ate abilities (1.2x, as since Gen VII) and Liquid Voice.
    moveType = Sovereign_AbilityMoveType(attackerParams.ability, move, inType == TYPE_NORMAL ? MOVE_DATA(move).type : (inType & 0x3F));
    if (attackerParams.ability != ABILITY_NORMALIZE
        && attackerParams.ability != ABILITY_LIQUID_VOICE
        && MOVE_DATA(move).type == TYPE_NORMAL
        && moveType == Sovereign_AbilityMoveType(attackerParams.ability, move, TYPE_NORMAL)
        && moveType != TYPE_NORMAL) {
        movePower = movePower * 12 / 10;
    }
    // Sovereign: Normalize also powers up the moves it makes Normal-type by 1.2x, Normal-type ones too (Gen VII+).
    if (attackerParams.ability == ABILITY_NORMALIZE && Sovereign_MoveSetsOwnType(move) == FALSE) {
        movePower = movePower * 12 / 10;
    }
    moveType = Sovereign_ElectrifyType(battleCtx, attacker, move, moveType); // Sovereign (item 11)

    GF_ASSERT(battleCtx->powerMul >= 10);
    movePower = movePower * battleCtx->powerMul / 10;

    if ((battleCtx->battleMons[attacker].moveEffectsMask & MOVE_EFFECT_CHARGE) && moveType == TYPE_ELECTRIC) {
        movePower *= 2;
    }

    if (battleCtx->turnFlags[attacker].helpingHand) {
        movePower = movePower * 15 / 10;
    }

    if (attackerParams.ability == ABILITY_TECHNICIAN
        && move != MOVE_STRUGGLE
        && movePower <= 60) {
        movePower = movePower * 15 / 10;
    }

    moveClass = MOVE_DATA(move).class;

    if (attackerParams.ability == ABILITY_HUGE_POWER || attackerParams.ability == ABILITY_PURE_POWER) {
        attackStat = attackStat * 2;
    }
    if (attackerParams.ability == ABILITY_SLOW_START
        && BattleContext_Get(battleSys, battleCtx, BATTLECTX_TOTAL_TURNS, NULL)
                - BattleMon_Get(battleCtx, attacker, BATTLEMON_SLOW_START_TURN_NUMBER, NULL)
            < 5) {
        attackStat /= 2;
    }

    for (i = 0; i < NELEMS(sTypeBoostingItems); i++) {
        if (attackerParams.heldItemEffect == sTypeBoostingItems[i].itemEffect
            && moveType == sTypeBoostingItems[i].type) {
            movePower = movePower * (100 + attackerParams.heldItemPower) / 100;
            break;
        }
    }

    // Sovereign (FM): the Pixie Plate and the Fairy Feather power up Fairy moves by 20%, like the other plates.
    if ((Battler_HeldItem(battleCtx, attacker) == ITEM_PIXIE_PLATE || Battler_HeldItem(battleCtx, attacker) == ITEM_FAIRY_FEATHER)
        && moveType == TYPE_FAIRY) {
        movePower = movePower * 120 / 100;
    }

    if (attackerParams.heldItemEffect == HOLD_EFFECT_CHOICE_ATK) {
        attackStat = attackStat * 150 / 100;
    }
    if (attackerParams.heldItemEffect == HOLD_EFFECT_CHOICE_SPATK) {
        spAttackStat = spAttackStat * 150 / 100;
    }
    // Sovereign: the Soul Dew powers up Latios's and Latias's Psychic and Dragon moves ×1.2, in any battle (Gen VII+).
    // Platinum raised their Sp. Atk and Sp. Def ×1.5, outside the Battle Frontier.
    if (attackerParams.heldItemEffect == HOLD_EFFECT_LATI_SPECIAL
        && (attackerParams.species == SPECIES_LATIOS || attackerParams.species == SPECIES_LATIAS)
        && (moveType == TYPE_PSYCHIC || moveType == TYPE_DRAGON)) {
        movePower = movePower * 120 / 100;
    }
    if (attackerParams.heldItemEffect == HOLD_EFFECT_CLAMPERL_SPATK
        && attackerParams.species == SPECIES_CLAMPERL) {
        spAttackStat *= 2;
    }
    if (defenderParams.heldItemEffect == HOLD_EFFECT_CLAMPERL_SPDEF
        && defenderParams.species == SPECIES_CLAMPERL) {
        spDefenseStat *= 2;
    }
    if (attackerParams.heldItemEffect == HOLD_EFFECT_PIKA_SPATK_UP
        && attackerParams.species == SPECIES_PIKACHU) {
        movePower *= 2;
    }
    if (defenderParams.heldItemEffect == HOLD_EFFECT_DITTO_DEF_UP
        && defenderParams.species == SPECIES_DITTO) {
        defenseStat *= 2;
    }
    // Sovereign (item 11): a Gem of the move's type powers up the attacker's damaging move ×1.3, and is used up as the
    // hit lands (BTLVAR_SOVEREIGN_GEM_USED, subscript_update_hp), so only a multi-hit move's first hit.
    if (Item_SovereignGemType(Battler_HeldItem(battleCtx, attacker)) == moveType
        && attacker == battleCtx->attacker
        && move == battleCtx->moveCur
        && MOVE_DATA(move).power > 1) {
        movePower = movePower * 13 / 10;
        battleCtx->sovereignGemBoost = attacker + 1;
    }
    // Sovereign (item 11): Eviolite raises Defense and Sp. Def by half for a Pokemon that can still evolve, Assault Vest
    // Sp. Def by half.
    if (Battler_HeldItem(battleCtx, defender) == ITEM_EVIOLITE
        && Pokemon_SovereignCanEvolve(defenderParams.species, BattleMon_Get(battleCtx, defender, BATTLEMON_FORM_NUM, NULL))) {
        defenseStat = defenseStat * 150 / 100;
        spDefenseStat = spDefenseStat * 150 / 100;
    }
    if (Battler_HeldItem(battleCtx, defender) == ITEM_ASSAULT_VEST) {
        spDefenseStat = spDefenseStat * 150 / 100;
    }
    if (attackerParams.heldItemEffect == HOLD_EFFECT_CUBONE_ATK_UP
        && (attackerParams.species == SPECIES_CUBONE || attackerParams.species == SPECIES_MAROWAK)) {
        attackStat *= 2;
    }
    if (attackerParams.heldItemEffect == HOLD_EFFECT_DIALGA_BOOST
        && (moveType == TYPE_DRAGON || moveType == TYPE_STEEL)
        && attackerParams.species == SPECIES_DIALGA) {
        movePower = movePower * (100 + attackerParams.heldItemPower) / 100;
    }
    if (attackerParams.heldItemEffect == HOLD_EFFECT_PALKIA_BOOST
        && (moveType == TYPE_DRAGON || moveType == TYPE_WATER)
        && attackerParams.species == SPECIES_PALKIA) {
        movePower = movePower * (100 + attackerParams.heldItemPower) / 100;
    }
    if (attackerParams.heldItemEffect == HOLD_EFFECT_GIRATINA_BOOST
        && (moveType == TYPE_DRAGON || moveType == TYPE_GHOST)
        && (BattleMon_Get(battleCtx, attacker, BATTLEMON_VOLATILE_STATUS, NULL) & VOLATILE_CONDITION_TRANSFORM) == FALSE
        && attackerParams.species == SPECIES_GIRATINA) {
        movePower = movePower * (100 + attackerParams.heldItemPower) / 100;
    }
    if (attackerParams.heldItemEffect == HOLD_EFFECT_POWER_UP_PHYS
        && moveClass == CLASS_PHYSICAL) {
        movePower = movePower * (100 + attackerParams.heldItemPower) / 100;
    }
    if (attackerParams.heldItemEffect == HOLD_EFFECT_POWER_UP_SPEC
        && moveClass == CLASS_SPECIAL) {
        movePower = movePower * (100 + attackerParams.heldItemPower) / 100;
    }

    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_THICK_FAT) == TRUE
        && (moveType == TYPE_FIRE || moveType == TYPE_ICE)) {
        movePower /= 2;
    }

    if (attackerParams.ability == ABILITY_HUSTLE) {
        attackStat = attackStat * 150 / 100;
    }
    if (attackerParams.ability == ABILITY_GUTS && attackerParams.statusMask) {
        attackStat = attackStat * 150 / 100;
    }

    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_MARVEL_SCALE) == TRUE
        && defenderParams.statusMask) {
        defenseStat = defenseStat * 150 / 100;
    }

    // Sovereign: Plus and Minus work with a partner that has either of them (Gen V+), not only the other one.
    // Counting the user's own side, a lone Plus counts once and a Plus with a Plus partner twice.
    if ((attackerParams.ability == ABILITY_PLUS || attackerParams.ability == ABILITY_MINUS)
        && BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_OUR_SIDE, attacker, ABILITY_PLUS)
                + BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_OUR_SIDE, attacker, ABILITY_MINUS)
            > 1) {
        spAttackStat = spAttackStat * 150 / 100;
    }

    // Sovereign: Mud Sport and Water Sport are 5-turn field effects with a 1352/4096 power modifier (Gen VI+); Platinum
    // halved the power while their user stayed in.
    if (moveType == TYPE_ELECTRIC && battleCtx->sovereignMudSportTurns) {
        movePower = movePower * 1352 / 4096;
    }
    if (moveType == TYPE_FIRE && battleCtx->sovereignWaterSportTurns) {
        movePower = movePower * 1352 / 4096;
    }

    if (moveType == TYPE_GRASS
        && attackerParams.ability == ABILITY_OVERGROW
        && attackerParams.curHP <= (attackerParams.maxHP / 3)) {
        movePower = movePower * 150 / 100;
    }
    if (moveType == TYPE_FIRE
        && attackerParams.ability == ABILITY_BLAZE
        && attackerParams.curHP <= (attackerParams.maxHP / 3)) {
        movePower = movePower * 150 / 100;
    }
    if (moveType == TYPE_WATER
        && attackerParams.ability == ABILITY_TORRENT
        && attackerParams.curHP <= (attackerParams.maxHP / 3)) {
        movePower = movePower * 150 / 100;
    }
    if (moveType == TYPE_BUG
        && attackerParams.ability == ABILITY_SWARM
        && attackerParams.curHP <= (attackerParams.maxHP / 3)) {
        movePower = movePower * 150 / 100;
    }

    if (moveType == TYPE_FIRE
        && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_HEATPROOF) == TRUE) {
        movePower /= 2;
    }
    if (moveType == TYPE_FIRE
        && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_DRY_SKIN) == TRUE) {
        movePower = movePower * 125 / 100;
    }

    // Sovereign (item 11): Body Press uses the user's Defense and Defense stage in place of its Attack. Effects that
    // raise Attack (Choice Band, Huge Power, Hustle, Guts...) don't apply, as in Gen IX.
    if (MOVE_DATA(move).effect == BATTLE_EFFECT_BODY_PRESS) {
        attackStat = BattleMon_Get(battleCtx, attacker, BATTLEMON_DEFENSE, NULL);
        attackStage = BattleMon_Get(battleCtx, attacker, BATTLEMON_DEFENSE_STAGE, NULL) - DEFAULT_STAT_STAGE;
    }

    // Sovereign (item 11): Foul Play uses the target's Attack and Attack stage.
    if (move == MOVE_FOUL_PLAY) {
        attackStat = BattleMon_Get(battleCtx, defender, BATTLEMON_ATTACK, NULL);
        attackStage = BattleMon_Get(battleCtx, defender, BATTLEMON_ATTACK_STAGE, NULL) - DEFAULT_STAT_STAGE;
    }

    // Sovereign (item 11): Photon Geyser is physical when the user's Attack is higher than its Sp. Atk (with their stages).
    if (move == MOVE_PHOTON_GEYSER
        && BattleMon_Get(battleCtx, attacker, BATTLEMON_ATTACK, NULL) * sStatStageBoosts[attackStage + DEFAULT_STAT_STAGE].numerator
                / sStatStageBoosts[attackStage + DEFAULT_STAT_STAGE].denominator
            > BattleMon_Get(battleCtx, attacker, BATTLEMON_SP_ATTACK, NULL) * sStatStageBoosts[spAttackStage + DEFAULT_STAT_STAGE].numerator
                / sStatStageBoosts[spAttackStage + DEFAULT_STAT_STAGE].denominator) {
        moveClass = CLASS_PHYSICAL;
    }

    // Sovereign (item 11): Shell Side Arm is physical when a physical hit would do more damage.
    if (move == MOVE_SHELL_SIDE_ARM && Sovereign_ShellSideArmPhysical(battleCtx, attacker, defender)) {
        moveClass = CLASS_PHYSICAL;
    }

    // Sovereign (item 11): Psyshock, Psystrike and Secret Sword are special moves that hit the target's Defense.
    if (move == MOVE_PSYSHOCK || move == MOVE_PSYSTRIKE || move == MOVE_SECRET_SWORD) {
        spDefenseStat = defenseStat;
        spDefenseStage = defenseStage;
    }

    // Sovereign (item 11): Sacred Sword, Chip Away and Darkest Lariat ignore the target's defensive stat stages.
    if (move == MOVE_SACRED_SWORD || move == MOVE_CHIP_AWAY || move == MOVE_DARKEST_LARIAT) {
        defenseStage = 0;
        spDefenseStage = 0;
    }

    // Sovereign: Simple doubles a stat change as it happens (Gen V+, BtlCmd_ChangeStatStage), not the stages here.

    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_UNAWARE) == TRUE) {
        attackStage = 0;
        spAttackStage = 0;
    }

    if (attackerParams.ability == ABILITY_UNAWARE) {
        defenseStage = 0;
        spDefenseStage = 0;
    }

    attackStage += DEFAULT_STAT_STAGE;
    defenseStage += DEFAULT_STAT_STAGE;
    spAttackStage += DEFAULT_STAT_STAGE;
    spDefenseStage += DEFAULT_STAT_STAGE;

    if (attackerParams.ability == ABILITY_RIVALRY
        && attackerParams.gender == defenderParams.gender
        && attackerParams.gender != GENDER_NONE
        && defenderParams.gender != GENDER_NONE) {
        movePower = movePower * 125 / 100;
    }
    if (attackerParams.ability == ABILITY_RIVALRY
        && attackerParams.gender != defenderParams.gender
        && attackerParams.gender != GENDER_NONE
        && defenderParams.gender != GENDER_NONE) {
        movePower = movePower * 75 / 100;
    }

    for (i = 0; i < NELEMS(sPunchingMoves); i++) {
        if (sPunchingMoves[i] == move && attackerParams.ability == ABILITY_IRON_FIST) {
            movePower = movePower * 12 / 10;
            break;
        }
    }

    // Sovereign (item 11): Punching Glove powers up punching moves by 10%.
    for (i = 0; i < NELEMS(sPunchingMoves); i++) {
        if (sPunchingMoves[i] == move && battleCtx->battleMons[attacker].heldItem == ITEM_PUNCHING_GLOVE) {
            movePower = movePower * 11 / 10;
            break;
        }
    }

    if (Move_SheerForceApplies(battleCtx, attacker, move)) {
        movePower = movePower * 13 / 10;
    }

    // Sovereign (item 11): Fluffy halves damage from contact moves and doubles damage from Fire moves.
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_FLUFFY) == TRUE) {
        if (Sovereign_MakesContact(battleCtx, attacker, move)) {
            movePower /= 2;
        }

        if (moveType == TYPE_FIRE) {
            movePower *= 2;
        }
    }

    // Sovereign (item 11): Aura Guard halves damage from contact moves.
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_AURA_GUARD) == TRUE
        && Sovereign_MakesContact(battleCtx, attacker, move)) {
        movePower /= 2;
    }

    for (i = 0; i < NELEMS(sBitingMoves); i++) {
        if (sBitingMoves[i] == move && attackerParams.ability == ABILITY_STRONG_JAW) {
            movePower = movePower * 15 / 10;
            break;
        }
    }

    // Sovereign (item 11): Gen V+ damage-modifying abilities (Gen IX values).
    switch (attackerParams.ability) {
    case ABILITY_TOUGH_CLAWS:
        if (MOVE_DATA(move).flags & MOVE_FLAG_MAKES_CONTACT) {
            movePower = movePower * 13 / 10;
        }
        break;
    case ABILITY_MEGA_LAUNCHER:
        if (Sovereign_MoveInList(sPulseMoves, NELEMS(sPulseMoves), move)) {
            movePower = movePower * 15 / 10;
        }
        break;
    case ABILITY_SHARPNESS:
        if (Sovereign_MoveInList(sSlicingMoves, NELEMS(sSlicingMoves), move)) {
            movePower = movePower * 15 / 10;
        }
        break;
    case ABILITY_PUNK_ROCK:
        if (Move_IsSound(move)) {
            movePower = movePower * 13 / 10;
        }
        break;
    case ABILITY_TRANSISTOR:
        if (moveType == TYPE_ELECTRIC) {
            attackStat = attackStat * 13 / 10;
            spAttackStat = spAttackStat * 13 / 10;
        }
        break;
    case ABILITY_DRAGONS_MAW:
        if (moveType == TYPE_DRAGON) {
            attackStat = attackStat * 15 / 10;
            spAttackStat = spAttackStat * 15 / 10;
        }
        break;
    case ABILITY_FIRE_MANE:
        if (moveType == TYPE_FIRE) {
            attackStat = attackStat * 15 / 10;
            spAttackStat = spAttackStat * 15 / 10;
        }
        break;
    case ABILITY_ROCKY_PAYLOAD:
        if (moveType == TYPE_ROCK) {
            attackStat = attackStat * 15 / 10;
            spAttackStat = spAttackStat * 15 / 10;
        }
        break;
    case ABILITY_STEELWORKER:
        if (moveType == TYPE_STEEL) {
            attackStat = attackStat * 15 / 10;
            spAttackStat = spAttackStat * 15 / 10;
        }
        break;
    case ABILITY_WATER_BUBBLE:
        if (moveType == TYPE_WATER) {
            attackStat *= 2;
            spAttackStat *= 2;
        }
        break;
    case ABILITY_TOXIC_BOOST:
        if (attackerParams.statusMask & MON_CONDITION_ANY_POISON) {
            attackStat = attackStat * 15 / 10;
        }
        break;
    case ABILITY_FLARE_BOOST:
        if (attackerParams.statusMask & MON_CONDITION_BURN) {
            spAttackStat = spAttackStat * 15 / 10;
        }
        break;
    case ABILITY_GORILLA_TACTICS:
        attackStat = attackStat * 15 / 10;
        break;
    case ABILITY_DEFEATIST:
        if (attackerParams.curHP <= attackerParams.maxHP / 2) {
            attackStat /= 2;
            spAttackStat /= 2;
        }
        break;
    case ABILITY_STAKEOUT:
        // Double power against a target that switched in this turn.
        if (battleCtx->battleMons[defender].moveEffectsData.fakeOutTurnNumber == battleCtx->totalTurns + 1) {
            movePower *= 2;
        }
        break;
    case ABILITY_SUPREME_OVERLORD: {
        // 10% more power for each fainted party member, up to 5.
        Party *party = BattleSystem_GetParty(battleSys, attacker);
        int fainted = 0;

        for (i = 0; i < Party_GetCurrentCount(party); i++) {
            Pokemon *mon = Party_GetPokemonBySlotIndex(party, i);

            if (Pokemon_GetValue(mon, MON_DATA_SPECIES, NULL) != SPECIES_NONE
                && Pokemon_GetValue(mon, MON_DATA_IS_EGG, NULL) == FALSE
                && Pokemon_GetValue(mon, MON_DATA_HP, NULL) == 0) {
                fainted++;
            }
        }

        if (fainted > 5) {
            fainted = 5;
        }

        movePower = movePower * (10 + fainted) / 10;
        break;
    }
    case ABILITY_ANALYTIC: {
        // 1.3x when every other Pokemon on the field has already moved this turn.
        int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
        for (i = 0; i < maxBattlers; i++) {
            if (i != attacker && battleCtx->battleMons[i].curHP && Battler_MovedThisTurn(battleCtx, i) == FALSE) {
                break;
            }
        }
        if (i == maxBattlers) {
            movePower = movePower * 13 / 10;
        }
        break;
    }
    }

    // Sovereign (item 11): Battery powers up its ally's special moves, Power Spot all its ally's moves, by 30%.
    if ((battleType & BATTLE_TYPE_DOUBLES) && battleCtx->battleMons[attacker ^ 2].curHP) {
        if (Battler_Ability(battleCtx, attacker ^ 2) == ABILITY_BATTERY && MOVE_DATA(move).class == CLASS_SPECIAL) {
            movePower = movePower * 13 / 10;
        }

        if (Battler_Ability(battleCtx, attacker ^ 2) == ABILITY_POWER_SPOT) {
            movePower = movePower * 13 / 10;
        }
    }

    // Steely Spirit boosts the Steel moves of the holder and its ally.
    if (moveType == TYPE_STEEL
        && (attackerParams.ability == ABILITY_STEELY_SPIRIT
            || ((battleType & BATTLE_TYPE_DOUBLES) && battleCtx->battleMons[attacker ^ 2].curHP
                && Battler_Ability(battleCtx, attacker ^ 2) == ABILITY_STEELY_SPIRIT))) {
        movePower = movePower * 15 / 10;
    }

    // Terrains: Electric, Grassy and Psychic Terrain power up their type's moves from a grounded user by 30%; Misty
    // Terrain halves Dragon moves against a grounded target, and Grassy Terrain halves Earthquake, Bulldoze and
    // Magnitude against one. Grass Pelt and Hadron Engine work in their terrain.
    if (((Sovereign_TerrainUnder(battleCtx, attacker) & FIELD_CONDITION_TERRAIN_ELECTRIC) && moveType == TYPE_ELECTRIC)
        || ((Sovereign_TerrainUnder(battleCtx, attacker) & FIELD_CONDITION_TERRAIN_GRASSY) && moveType == TYPE_GRASS)
        || ((Sovereign_TerrainUnder(battleCtx, attacker) & FIELD_CONDITION_TERRAIN_PSYCHIC) && moveType == TYPE_PSYCHIC)) {
        movePower = movePower * 13 / 10;
    }
    if ((Sovereign_TerrainUnder(battleCtx, defender) & FIELD_CONDITION_TERRAIN_MISTY) && moveType == TYPE_DRAGON) {
        movePower /= 2;
    }
    if ((Sovereign_TerrainUnder(battleCtx, defender) & FIELD_CONDITION_TERRAIN_GRASSY)
        && (move == MOVE_EARTHQUAKE || move == MOVE_BULLDOZE || move == MOVE_MAGNITUDE)) {
        movePower /= 2;
    }
    if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN_GRASSY)
        && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_GRASS_PELT) == TRUE) {
        defenseStat = defenseStat * 15 / 10;
    }
    if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN_ELECTRIC) && attackerParams.ability == ABILITY_HADRON_ENGINE) {
        spAttackStat = spAttackStat * 4 / 3;
    }
    if (NO_CLOUD_NINE && (Sovereign_UmbrellaWeather(battleCtx, attacker, fieldConditions) & FIELD_CONDITION_SUNNY) && attackerParams.ability == ABILITY_ORICHALCUM_PULSE) {
        attackStat = attackStat * 4 / 3;
    }

    i = Sovereign_ProtosynthesisStat(battleSys, battleCtx, attacker);
    if (i == BATTLE_STAT_ATTACK) {
        attackStat = attackStat * 13 / 10;
    } else if (i == BATTLE_STAT_SP_ATTACK) {
        spAttackStat = spAttackStat * 13 / 10;
    }
    i = Sovereign_ProtosynthesisStat(battleSys, battleCtx, defender);
    if (i == BATTLE_STAT_DEFENSE) {
        defenseStat = defenseStat * 13 / 10;
    } else if (i == BATTLE_STAT_SP_DEFENSE) {
        spDefenseStat = spDefenseStat * 13 / 10;
    }

    // Abilities on the target.
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_MULTISCALE) == TRUE
        || defenderParams.ability == ABILITY_SHADOW_SHIELD) {
        if (defenderParams.curHP == defenderParams.maxHP) {
            movePower /= 2;
        }
    }
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_FUR_COAT) == TRUE) {
        defenseStat *= 2;
    }
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_ICE_SCALES) == TRUE && moveClass == CLASS_SPECIAL) {
        movePower /= 2;
    }
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_PUNK_ROCK) == TRUE && Move_IsSound(move)) {
        movePower /= 2;
    }
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_PURIFYING_SALT) == TRUE && moveType == TYPE_GHOST) {
        movePower /= 2;
    }
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_WATER_BUBBLE) == TRUE && moveType == TYPE_FIRE) {
        movePower /= 2;
    }

    // The Ruin abilities lower the stat of every other Pokemon on the field by 25%.
    if (attackerParams.ability != ABILITY_TABLETS_OF_RUIN && Sovereign_FieldHasAbility(battleSys, battleCtx, ABILITY_TABLETS_OF_RUIN, attacker)) {
        attackStat = attackStat * 3 / 4;
    }
    if (attackerParams.ability != ABILITY_VESSEL_OF_RUIN && Sovereign_FieldHasAbility(battleSys, battleCtx, ABILITY_VESSEL_OF_RUIN, attacker)) {
        spAttackStat = spAttackStat * 3 / 4;
    }
    if (defenderParams.ability != ABILITY_SWORD_OF_RUIN && Sovereign_FieldHasAbility(battleSys, battleCtx, ABILITY_SWORD_OF_RUIN, defender)) {
        defenseStat = defenseStat * 3 / 4;
    }
    if (defenderParams.ability != ABILITY_BEADS_OF_RUIN && Sovereign_FieldHasAbility(battleSys, battleCtx, ABILITY_BEADS_OF_RUIN, defender)) {
        spDefenseStat = spDefenseStat * 3 / 4;
    }

    // Dark Aura and Fairy Aura power up Dark and Fairy moves by a third; Aura Break turns that into a 25% cut.
    if ((moveType == TYPE_DARK && Sovereign_FieldHasAbility(battleSys, battleCtx, ABILITY_DARK_AURA, -1))
        || (moveType == TYPE_FAIRY && Sovereign_FieldHasAbility(battleSys, battleCtx, ABILITY_FAIRY_AURA, -1))) {
        if (Sovereign_FieldHasAbility(battleSys, battleCtx, ABILITY_AURA_BREAK, -1)) {
            movePower = movePower * 3 / 4;
        } else {
            movePower = movePower * 4 / 3;
        }
    }

    if (NO_CLOUD_NINE) {
        if ((Sovereign_UmbrellaWeather(battleCtx, attacker, fieldConditions) & FIELD_CONDITION_SUNNY) && attackerParams.ability == ABILITY_SOLAR_POWER) {
            spAttackStat = spAttackStat * 15 / 10;
        }

        if ((fieldConditions & FIELD_CONDITION_SANDSTORM)
            && (defenderParams.type1 == TYPE_ROCK || defenderParams.type2 == TYPE_ROCK)) {
            spDefenseStat = spDefenseStat * 15 / 10;
        }

        // Sovereign (item 11): Sand Force powers up Rock, Ground and Steel moves by 30% in a sandstorm.
        if ((fieldConditions & FIELD_CONDITION_SANDSTORM)
            && attackerParams.ability == ABILITY_SAND_FORCE
            && (moveType == TYPE_ROCK || moveType == TYPE_GROUND || moveType == TYPE_STEEL)) {
            movePower = movePower * 13 / 10;
        }

        // Sovereign: Snow (Gen IX / Pokémon Champions) boosts Ice types' Defense by 50%.
        if ((fieldConditions & FIELD_CONDITION_HAILING)
            && (defenderParams.type1 == TYPE_ICE || defenderParams.type2 == TYPE_ICE)) {
            defenseStat = defenseStat * 15 / 10;
        }

        if ((Sovereign_UmbrellaWeather(battleCtx, attacker, fieldConditions) & FIELD_CONDITION_SUNNY)
            && BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_OUR_SIDE, attacker, ABILITY_FLOWER_GIFT)) {
            attackStat = attackStat * 15 / 10;
        }

        if ((Sovereign_UmbrellaWeather(battleCtx, defender, fieldConditions) & FIELD_CONDITION_SUNNY)
            && Sovereign_IsMoldBreaker(battleCtx, attacker) == FALSE
            && BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_OUR_SIDE, defender, ABILITY_FLOWER_GIFT)) {
            spDefenseStat = spDefenseStat * 15 / 10;
        }
    }

    // Sovereign (item 11): Explosion, Self-Destruct and Misty Explosion no longer halve the target's Defense (Gen V+,
    // Champions); their power is already Gen V+'s.

    if (moveClass == CLASS_PHYSICAL) {
        if (criticalMul > 1) {
            if (attackStage > DEFAULT_STAT_STAGE) {
                damage = attackStat * sStatStageBoosts[attackStage].numerator;
                damage /= sStatStageBoosts[attackStage].denominator;
            } else {
                damage = attackStat;
            }
        } else {
            damage = attackStat * sStatStageBoosts[attackStage].numerator;
            damage /= sStatStageBoosts[attackStage].denominator;
        }

        damage *= movePower;
        damage *= (attackerLevel * 2 / 5 + 2);

        if (criticalMul > 1) {
            if (defenseStage < DEFAULT_STAT_STAGE) {
                stageDivisor = defenseStat * sStatStageBoosts[defenseStage].numerator;
                stageDivisor /= sStatStageBoosts[defenseStage].denominator;
            } else {
                stageDivisor = defenseStat;
            }
        } else {
            stageDivisor = defenseStat * sStatStageBoosts[defenseStage].numerator;
            stageDivisor /= sStatStageBoosts[defenseStage].denominator;
        }

        damage /= stageDivisor;
        damage /= 50;

        if ((attackerParams.statusMask & MON_CONDITION_BURN) && attackerParams.ability != ABILITY_GUTS) {
            damage /= 2;
        }

        if ((sideConditions & (SIDE_CONDITION_REFLECT | SIDE_CONDITION_SOVEREIGN_AURORA_VEIL)) != FALSE // Sovereign (item 11): Aurora Veil
            && criticalMul == 1
            && attackerParams.ability != ABILITY_INFILTRATOR // Sovereign (item 11)
            && MOVE_DATA(move).effect != BATTLE_EFFECT_REMOVE_SCREENS) {
            // Sovereign: x2732/4096 in any double battle (Gen V+). Platinum used x2/3, and only while both Pokemon on the
            // side were in.
            if (battleType & BATTLE_TYPE_DOUBLES) {
                damage = damage * 2732 / 4096;
            } else {
                damage /= 2;
            }
        }
    } else if (moveClass == CLASS_SPECIAL) {
        if (criticalMul > 1) {
            if (spAttackStage > DEFAULT_STAT_STAGE) {
                damage = spAttackStat * sStatStageBoosts[spAttackStage].numerator;
                damage /= sStatStageBoosts[spAttackStage].denominator;
            } else {
                damage = spAttackStat;
            }
        } else {
            damage = spAttackStat * sStatStageBoosts[spAttackStage].numerator;
            damage /= sStatStageBoosts[spAttackStage].denominator;
        }

        damage *= movePower;
        damage *= (attackerLevel * 2 / 5 + 2);

        if (criticalMul > 1) {
            if (spDefenseStage < DEFAULT_STAT_STAGE) {
                stageDivisor = spDefenseStat * sStatStageBoosts[spDefenseStage].numerator;
                stageDivisor /= sStatStageBoosts[spDefenseStage].denominator;
            } else {
                stageDivisor = spDefenseStat;
            }
        } else {
            stageDivisor = spDefenseStat * sStatStageBoosts[spDefenseStage].numerator;
            stageDivisor /= sStatStageBoosts[spDefenseStage].denominator;
        }

        damage /= stageDivisor;
        damage /= 50;

        if ((sideConditions & (SIDE_CONDITION_LIGHT_SCREEN | SIDE_CONDITION_SOVEREIGN_AURORA_VEIL)) != FALSE // Sovereign (item 11): Aurora Veil
            && criticalMul == 1
            && attackerParams.ability != ABILITY_INFILTRATOR // Sovereign (item 11)
            && MOVE_DATA(move).effect != BATTLE_EFFECT_REMOVE_SCREENS) {
            // Sovereign: x2732/4096 in any double battle (Gen V+). Platinum used x2/3, and only while both Pokemon on the
            // side were in.
            if (battleType & BATTLE_TYPE_DOUBLES) {
                damage = damage * 2732 / 4096;
            } else {
                damage /= 2;
            }
        }
    }

    if ((battleType & BATTLE_TYPE_DOUBLES)
        && Sovereign_MoveRange(battleCtx, attacker, move) == RANGE_ADJACENT_OPPONENTS // Sovereign (item 11)
        && BattleSystem_CountAliveBattlers(battleSys, battleCtx, TRUE, defender) == 2) {
        damage = damage * 3 / 4;
    }
    if ((battleType & BATTLE_TYPE_DOUBLES)
        && MOVE_DATA(move).range == RANGE_ALL_ADJACENT
        && BattleSystem_CountAliveBattlers(battleSys, battleCtx, FALSE, defender) >= 2) {
        damage = damage * 3 / 4;
    }

    // Sovereign (item 11): Friend Guard on the defender's partner cuts the damage it takes by 25%.
    if ((battleType & BATTLE_TYPE_DOUBLES)
        && battleCtx->battleMons[defender ^ 2].curHP
        && Battler_Ability(battleCtx, defender ^ 2) == ABILITY_FRIEND_GUARD) {
        damage = damage * 3 / 4;
    }

    // Sovereign (item 11): Mega Sol's moves work as if the sunlight were harsh, whatever the weather, even beside
    // Cloud Nine or Air Lock.
    if (attackerParams.ability == ABILITY_MEGA_SOL) {
        fieldConditions = (fieldConditions & ~FIELD_CONDITION_WEATHER) | FIELD_CONDITION_SUNNY_TEMP;
    }

    if (NO_CLOUD_NINE || attackerParams.ability == ABILITY_MEGA_SOL) {
        // Sovereign (item 11): a Utility Umbrella keeps rain and sunlight off the Fire and Water moves hitting its
        // holder (not off Mega Sol's), and off its holder's Solar Beam and Hydro Steam.
        u32 attackerWeather = attackerParams.ability == ABILITY_MEGA_SOL ? fieldConditions : Sovereign_UmbrellaWeather(battleCtx, attacker, fieldConditions);
        u32 defenderWeather = attackerParams.ability == ABILITY_MEGA_SOL ? fieldConditions : Sovereign_UmbrellaWeather(battleCtx, defender, fieldConditions);

        if (defenderWeather & FIELD_CONDITION_RAINING) {
            switch (moveType) {
            case TYPE_FIRE:
                damage /= 2;
                break;
            case TYPE_WATER:
                damage = damage * 15 / 10;
                break;
            }
        }

        if ((attackerWeather & FIELD_CONDITION_SOLAR_DOWN) && (move == MOVE_SOLAR_BEAM || move == MOVE_SOLAR_BLADE)) { // Sovereign (item 11): Solar Blade too
            damage /= 2;
        }

        // Sovereign (item 11): Hydro Steam is boosted, not weakened, in harsh sunlight (the user's).
        if (moveType == TYPE_WATER && move == MOVE_HYDRO_STEAM && (attackerWeather & FIELD_CONDITION_SUNNY)) {
            damage = damage * 15 / 10;
        } else if (defenderWeather & FIELD_CONDITION_SUNNY) {
            switch (moveType) {
            case TYPE_FIRE:
                damage = damage * 15 / 10;
                break;
            case TYPE_WATER:
                damage /= 2;
                break;
            }
        }
    }

    if (BattleMon_Get(battleCtx, attacker, BATTLEMON_FLASH_FIRE, NULL) && moveType == TYPE_FIRE) {
        damage = damage * 15 / 10;
    }

    return damage + 2;
}

int BattleSystem_CalcDamageVariance(BattleSystem *battleSys, BattleContext *battleCtx, int damage)
{
    if (damage) {
        damage *= (100 - (BattleSystem_RandNext(battleSys) % 16));
        damage /= 100;

        // Always deal at least 1 damage
        if (damage == 0) {
            damage = 1;
        }
    }

    return damage;
}

// each value here is implicitly 1 / N
// Sovereign: Gen VII+ / Pokémon Champions odds (Gen IV was 1/16, 1/8, 1/4, 1/3, 1/2).
static const u8 sCriticalStageRates[] = {
    24, // neutral
    8, // +1
    2, // +2
    1, // +3 and above
};

int BattleSystem_CalcCriticalMulti(BattleSystem *battleSys, BattleContext *battleCtx, int attacker, int defender, int criticalStage, u32 sideConditions)
{
    // have to declare vars C89-style to match
    u16 effectiveCritStage;
    u16 item;
    int itemEffect;
    u16 attackerSpecies;
    u32 attackerVolStatus;
    u32 defenderMoveEffects;
    int criticalMul = 1;
    int attackerAbility;

    item = Battler_HeldItem(battleCtx, attacker);
    itemEffect = BattleSystem_GetItemData(battleCtx, item, ITEM_PARAM_HOLD_EFFECT);
    attackerSpecies = battleCtx->battleMons[attacker].species;
    attackerVolStatus = battleCtx->battleMons[attacker].statusVolatile;
    defenderMoveEffects = battleCtx->battleMons[defender].moveEffectsMask;
    attackerAbility = battleCtx->battleMons[attacker].ability;
    effectiveCritStage = (((attackerVolStatus & VOLATILE_CONDITION_FOCUS_ENERGY) != FALSE) * 2)
        + (itemEffect == HOLD_EFFECT_CRITRATE_UP)
        + criticalStage
        + (attackerAbility == ABILITY_SUPER_LUCK)
        + (2 * (itemEffect == HOLD_EFFECT_CHANSEY_CRITRATE_UP && attackerSpecies == SPECIES_CHANSEY))
        + (2 * (itemEffect == HOLD_EFFECT_FARFETCHD_CRITRATE_UP && (attackerSpecies == SPECIES_FARFETCHD || attackerSpecies == SPECIES_SIRFETCHD))); // Sovereign: Sirfetch'd too (Gen VIII+)

    if (effectiveCritStage > NELEMS(sCriticalStageRates) - 1) {
        effectiveCritStage = NELEMS(sCriticalStageRates) - 1;
    }

    if (BattleSystem_RandNext(battleSys) % sCriticalStageRates[effectiveCritStage] == 0
        && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_BATTLE_ARMOR) == FALSE
        && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_SHELL_ARMOR) == FALSE
        && (sideConditions & SIDE_CONDITION_LUCKY_CHANT) == FALSE
        && (defenderMoveEffects & MOVE_EFFECT_NO_CRITICAL) == FALSE) {
        criticalMul = 2;
    }

    if (criticalMul == 2 && Battler_Ability(battleCtx, attacker) == ABILITY_SNIPER) {
        criticalMul = 3;
    }

    return criticalMul;
}

int BattleSystem_ApplyCriticalMul(int damage, int criticalMul)
{
    // Sovereign: Gen VI+ / Pokémon Champions multipliers, x1.5 (x2.25 with Sniper) instead of Gen IV's x2 (x3).
    // criticalMul keeps Gen IV's values (1 = no crit, 2 = crit, 3 = Sniper crit) for the code that checks them.
    switch (criticalMul) {
    case 2:
        return damage * 3 / 2;
    case 3:
        return damage * 9 / 4;
    default:
        return damage;
    }
}

// Sovereign: the lists of moves Metronome, Assist, Copycat, Encore, Me First and Sleep Talk can't call, copy or lock in:
// Gen IX's (Showdown's metronome, noassist, failcopycat, failencore, failmefirst and nosleeptalk flags) for every move
// in the game. Platinum shared one short list between Metronome, Assist, Copycat and Mimic, and matched Encore's and
// Me First's by battle effect.
static const u16 sCannotMetronomeMoves[] = {
    MOVE_COUNTER, MOVE_MIMIC, MOVE_METRONOME, MOVE_MIRROR_MOVE, MOVE_TRANSFORM, MOVE_STRUGGLE, MOVE_SKETCH, MOVE_THIEF,
    MOVE_SNORE, MOVE_PROTECT, MOVE_DESTINY_BOND, MOVE_DETECT, MOVE_ENDURE, MOVE_SLEEP_TALK, MOVE_MIRROR_COAT,
    MOVE_FOCUS_PUNCH, MOVE_FOLLOW_ME, MOVE_NATURE_POWER, MOVE_HELPING_HAND, MOVE_TRICK, MOVE_ASSIST, MOVE_SNATCH,
    MOVE_COVET, MOVE_FEINT, MOVE_ME_FIRST, MOVE_COPYCAT, MOVE_SWITCHEROO, MOVE_CHATTER, MOVE_WIDE_GUARD,
    MOVE_RAGE_POWDER, MOVE_AFTER_YOU, MOVE_QUICK_GUARD, MOVE_QUASH, MOVE_BESTOW, MOVE_TECHNO_BLAST, MOVE_RELIC_SONG,
    MOVE_SECRET_SWORD, MOVE_FREEZE_SHOCK, MOVE_ICE_BURN, MOVE_SNARL, MOVE_V_CREATE, MOVE_MAT_BLOCK, MOVE_BELCH,
    MOVE_CRAFTY_SHIELD, MOVE_KINGS_SHIELD, MOVE_DIAMOND_STORM, MOVE_STEAM_ERUPTION, MOVE_HYPERSPACE_HOLE,
    MOVE_SPIKY_SHIELD, MOVE_CELEBRATE, MOVE_HOLD_HANDS, MOVE_THOUSAND_ARROWS, MOVE_THOUSAND_WAVES, MOVE_LIGHT_OF_RUIN,
    MOVE_ORIGIN_PULSE, MOVE_PRECIPICE_BLADES, MOVE_DRAGON_ASCENT, MOVE_HYPERSPACE_FURY, MOVE_BANEFUL_BUNKER,
    MOVE_SPOTLIGHT, MOVE_INSTRUCT, MOVE_BEAK_BLAST, MOVE_SHELL_TRAP, MOVE_FLEUR_CANNON, MOVE_SPECTRAL_THIEF,
    MOVE_SUNSTEEL_STRIKE, MOVE_MOONGEIST_BEAM, MOVE_NATURES_MADNESS, MOVE_MIND_BLOWN, MOVE_PLASMA_FISTS,
    MOVE_PHOTON_GEYSER, MOVE_ZIPPY_ZAP, MOVE_SPLISHY_SPLASH, MOVE_FLOATY_FALL, MOVE_PIKA_PAPOW, MOVE_BOUNCY_BUBBLE,
    MOVE_BUZZY_BUZZ, MOVE_SIZZLY_SLIDE, MOVE_GLITZY_GLOW, MOVE_BADDY_BAD, MOVE_SAPPY_SEED, MOVE_FREEZY_FROST,
    MOVE_SPARKLY_SWIRL, MOVE_VEEVEE_VOLLEY, MOVE_DOUBLE_IRON_BASH, MOVE_DYNAMAX_CANNON, MOVE_CLANGOROUS_SOUL,
    MOVE_BODY_PRESS, MOVE_DECORATE, MOVE_DRUM_BEATING, MOVE_SNAP_TRAP, MOVE_PYRO_BALL, MOVE_BEHEMOTH_BLADE,
    MOVE_BEHEMOTH_BASH, MOVE_AURA_WHEEL, MOVE_BREAKING_SWIPE, MOVE_BRANCH_POKE, MOVE_OVERDRIVE, MOVE_APPLE_ACID,
    MOVE_GRAV_APPLE, MOVE_SPIRIT_BREAK, MOVE_STRANGE_STEAM, MOVE_LIFE_DEW, MOVE_OBSTRUCT, MOVE_FALSE_SURRENDER,
    MOVE_METEOR_ASSAULT, MOVE_ETERNABEAM, MOVE_STEEL_BEAM, MOVE_JUNGLE_HEALING, MOVE_WICKED_BLOW, MOVE_SURGING_STRIKES,
    MOVE_THUNDER_CAGE, MOVE_DRAGON_ENERGY, MOVE_FREEZING_GLARE, MOVE_FIERY_WRATH, MOVE_THUNDEROUS_KICK,
    MOVE_GLACIAL_LANCE, MOVE_ASTRAL_BARRAGE, MOVE_POWER_SHIFT, MOVE_SPRINGTIDE_STORM, MOVE_RAGING_FURY, MOVE_SILK_TRAP,
    MOVE_ORDER_UP, MOVE_JET_PUNCH, MOVE_SPICY_EXTRACT, MOVE_POPULATION_BOMB, MOVE_REVIVAL_BLESSING, MOVE_SALT_CURE,
    MOVE_DOODLE, MOVE_FILLET_AWAY, MOVE_RAGING_BULL, MOVE_MAKE_IT_RAIN, MOVE_RUINATION, MOVE_COLLISION_COURSE,
    MOVE_ELECTRO_DRIFT, MOVE_SHED_TAIL, MOVE_CHILLY_RECEPTION, MOVE_TIDY_UP, MOVE_SNOWSCAPE, MOVE_POUNCE,
    MOVE_TRAILBLAZE, MOVE_CHILLING_WATER, MOVE_HYPER_DRILL, MOVE_TWIN_BEAM, MOVE_RAGE_FIST, MOVE_ARMOR_CANNON,
    MOVE_DOUBLE_SHOCK, MOVE_COMEUPPANCE, MOVE_BLAZING_TORQUE, MOVE_WICKED_TORQUE, MOVE_NOXIOUS_TORQUE,
    MOVE_COMBAT_TORQUE, MOVE_MAGICAL_TORQUE, MOVE_TERA_STARSTORM
};

static const u16 sCannotAssistMoves[] = {
    MOVE_WHIRLWIND, MOVE_FLY, MOVE_ROAR, MOVE_COUNTER, MOVE_DIG, MOVE_MIMIC, MOVE_METRONOME, MOVE_MIRROR_MOVE,
    MOVE_TRANSFORM, MOVE_STRUGGLE, MOVE_SKETCH, MOVE_THIEF, MOVE_PROTECT, MOVE_DESTINY_BOND, MOVE_DETECT, MOVE_ENDURE,
    MOVE_SLEEP_TALK, MOVE_MIRROR_COAT, MOVE_FOCUS_PUNCH, MOVE_FOLLOW_ME, MOVE_NATURE_POWER, MOVE_HELPING_HAND,
    MOVE_TRICK, MOVE_ASSIST, MOVE_SNATCH, MOVE_DIVE, MOVE_BOUNCE, MOVE_COVET, MOVE_FEINT, MOVE_ME_FIRST, MOVE_COPYCAT,
    MOVE_SWITCHEROO, MOVE_CHATTER, MOVE_SHADOW_FORCE, MOVE_RAGE_POWDER, MOVE_SKY_DROP, MOVE_CIRCLE_THROW, MOVE_BESTOW,
    MOVE_DRAGON_TAIL, MOVE_MAT_BLOCK, MOVE_BELCH, MOVE_PHANTOM_FORCE, MOVE_KINGS_SHIELD, MOVE_SPIKY_SHIELD,
    MOVE_CELEBRATE, MOVE_HOLD_HANDS, MOVE_BANEFUL_BUNKER, MOVE_SPOTLIGHT, MOVE_BEAK_BLAST, MOVE_SHELL_TRAP,
    MOVE_BLAZING_TORQUE, MOVE_WICKED_TORQUE, MOVE_NOXIOUS_TORQUE, MOVE_COMBAT_TORQUE, MOVE_MAGICAL_TORQUE,
    MOVE_TERA_STARSTORM, MOVE_BURNING_BULWARK
};

static const u16 sCannotCopycatMoves[] = {
    MOVE_WHIRLWIND, MOVE_ROAR, MOVE_COUNTER, MOVE_MIMIC, MOVE_METRONOME, MOVE_MIRROR_MOVE, MOVE_TRANSFORM,
    MOVE_STRUGGLE, MOVE_SKETCH, MOVE_THIEF, MOVE_PROTECT, MOVE_DESTINY_BOND, MOVE_DETECT, MOVE_ENDURE, MOVE_SLEEP_TALK,
    MOVE_FOCUS_PUNCH, MOVE_FOLLOW_ME, MOVE_NATURE_POWER, MOVE_HELPING_HAND, MOVE_TRICK, MOVE_ASSIST, MOVE_SNATCH,
    MOVE_COVET, MOVE_FEINT, MOVE_ME_FIRST, MOVE_COPYCAT, MOVE_SWITCHEROO, MOVE_CHATTER, MOVE_RAGE_POWDER,
    MOVE_CIRCLE_THROW, MOVE_BESTOW, MOVE_DRAGON_TAIL, MOVE_MAT_BLOCK, MOVE_BELCH, MOVE_KINGS_SHIELD, MOVE_SPIKY_SHIELD,
    MOVE_CELEBRATE, MOVE_HOLD_HANDS, MOVE_BANEFUL_BUNKER, MOVE_SPOTLIGHT, MOVE_BEAK_BLAST, MOVE_SHELL_TRAP,
    MOVE_DYNAMAX_CANNON, MOVE_BEHEMOTH_BLADE, MOVE_BEHEMOTH_BASH, MOVE_BLAZING_TORQUE, MOVE_WICKED_TORQUE,
    MOVE_NOXIOUS_TORQUE, MOVE_COMBAT_TORQUE, MOVE_MAGICAL_TORQUE, MOVE_TERA_STARSTORM, MOVE_BURNING_BULWARK
};

// Sovereign: the moves Mimic can't copy (Gen IX's failmimic moves). Platinum shared Metronome's first five.
static const u16 sCannotMimicMoves[] = {
    MOVE_MIMIC, MOVE_METRONOME, MOVE_MIRROR_MOVE, MOVE_TRANSFORM, MOVE_STRUGGLE, MOVE_SKETCH, MOVE_SLEEP_TALK,
    MOVE_NATURE_POWER, MOVE_ASSIST, MOVE_ME_FIRST, MOVE_COPYCAT, MOVE_CHATTER, MOVE_BELCH, MOVE_CELEBRATE,
    MOVE_HOLD_HANDS, MOVE_DYNAMAX_CANNON, MOVE_BEHEMOTH_BLADE, MOVE_BEHEMOTH_BASH, MOVE_BLAZING_TORQUE,
    MOVE_WICKED_TORQUE, MOVE_NOXIOUS_TORQUE, MOVE_COMBAT_TORQUE, MOVE_MAGICAL_TORQUE, MOVE_TERA_STARSTORM,
};

BOOL Move_CanBeMimicked(u16 move)
{
    return Sovereign_MoveInList(sCannotMimicMoves, NELEMS(sCannotMimicMoves), move) == FALSE;
}

// Sovereign: the moves Sketch can't copy (Gen IX's nosketch moves). Platinum's were Struggle, Sketch and Chatter.
static const u16 sCannotSketchMoves[] = {
    MOVE_STRUGGLE, MOVE_SKETCH, MOVE_DARK_VOID, MOVE_HYPERSPACE_FURY, MOVE_REVIVAL_BLESSING, MOVE_BLAZING_TORQUE,
    MOVE_WICKED_TORQUE, MOVE_NOXIOUS_TORQUE, MOVE_COMBAT_TORQUE, MOVE_MAGICAL_TORQUE, MOVE_TERA_STARSTORM,
};

BOOL Move_CanBeSketched(u16 move)
{
    return Sovereign_MoveInList(sCannotSketchMoves, NELEMS(sCannotSketchMoves), move) == FALSE;
}

BOOL Move_CanBeMetronomed(BattleSystem *battleSys, BattleContext *battleCtx, int battler, u16 move)
{
    // Sovereign: empty move slots (the official numbers of Z-Moves and Max Moves, which aren't in the game) have 0 PP.
    // A move Gravity or Heal Block stops can be called, and then fails (Gen V+).
    return MOVE_DATA(move).pp != 0 && Sovereign_MoveInList(sCannotMetronomeMoves, NELEMS(sCannotMetronomeMoves), move) == FALSE;
}

// Sovereign: Assist's and Copycat's own lists (Gen V+); Platinum used Metronome's.
BOOL Move_CanBeAssisted(u16 move)
{
    return Sovereign_MoveInList(sCannotAssistMoves, NELEMS(sCannotAssistMoves), move) == FALSE;
}

BOOL Move_CanBeCopycatted(u16 move)
{
    return Sovereign_MoveInList(sCannotCopycatMoves, NELEMS(sCannotCopycatMoves), move) == FALSE;
}

static const u16 sCannotEncoreMoves[] = {
    MOVE_MIMIC, MOVE_METRONOME, MOVE_MIRROR_MOVE, MOVE_TRANSFORM, MOVE_STRUGGLE, MOVE_SKETCH, MOVE_SLEEP_TALK,
    MOVE_ENCORE, MOVE_NATURE_POWER, MOVE_ASSIST, MOVE_ME_FIRST, MOVE_COPYCAT, MOVE_DYNAMAX_CANNON, MOVE_BLAZING_TORQUE,
    MOVE_WICKED_TORQUE, MOVE_NOXIOUS_TORQUE, MOVE_COMBAT_TORQUE, MOVE_MAGICAL_TORQUE
};

BOOL Move_CanBeEncored(BattleContext *battleCtx, u16 move)
{
    return Sovereign_MoveInList(sCannotEncoreMoves, NELEMS(sCannotEncoreMoves), move) == FALSE;
}

static const u16 sCannotMeFirstMoves[] = {
    MOVE_COUNTER, MOVE_STRUGGLE, MOVE_THIEF, MOVE_MIRROR_COAT, MOVE_FOCUS_PUNCH, MOVE_COVET, MOVE_METAL_BURST,
    MOVE_ME_FIRST, MOVE_BELCH, MOVE_BEAK_BLAST, MOVE_SHELL_TRAP, MOVE_COMEUPPANCE, MOVE_BLAZING_TORQUE,
    MOVE_WICKED_TORQUE, MOVE_NOXIOUS_TORQUE, MOVE_COMBAT_TORQUE, MOVE_MAGICAL_TORQUE
};

BOOL Move_MeFirstCanCopy(BattleContext *battleCtx, u16 move)
{
    return Sovereign_MoveInList(sCannotMeFirstMoves, NELEMS(sCannotMeFirstMoves), move) == FALSE;
}

static const u16 sCannotSleepTalkMoves[] = {
    MOVE_RAZOR_WIND, MOVE_FLY, MOVE_SOLAR_BEAM, MOVE_DIG, MOVE_MIMIC, MOVE_BIDE, MOVE_METRONOME, MOVE_MIRROR_MOVE,
    MOVE_SKULL_BASH, MOVE_SKY_ATTACK, MOVE_STRUGGLE, MOVE_SKETCH, MOVE_SLEEP_TALK, MOVE_UPROAR, MOVE_FOCUS_PUNCH,
    MOVE_NATURE_POWER, MOVE_ASSIST, MOVE_DIVE, MOVE_BOUNCE, MOVE_ME_FIRST, MOVE_COPYCAT, MOVE_CHATTER,
    MOVE_SHADOW_FORCE, MOVE_SKY_DROP, MOVE_FREEZE_SHOCK, MOVE_ICE_BURN, MOVE_BELCH, MOVE_PHANTOM_FORCE, MOVE_GEOMANCY,
    MOVE_CELEBRATE, MOVE_HOLD_HANDS, MOVE_SOLAR_BLADE, MOVE_BEAK_BLAST, MOVE_SHELL_TRAP, MOVE_DYNAMAX_CANNON,
    MOVE_BLAZING_TORQUE, MOVE_WICKED_TORQUE, MOVE_NOXIOUS_TORQUE, MOVE_COMBAT_TORQUE, MOVE_MAGICAL_TORQUE
};

BOOL Move_CanBeSleepTalked(u16 move)
{
    return Sovereign_MoveInList(sCannotSleepTalkMoves, NELEMS(sCannotSleepTalkMoves), move) == FALSE;
}

s32 BattleSystem_GetItemData(BattleContext *battleCtx, u16 item, enum ItemDataParam paramID)
{
    u16 dataID = Item_FileID(item, ITEM_FILE_TYPE_DATA);
    ItemData *data = ItemTable_Index(battleCtx->aiContext.itemTable, dataID);

    return Item_Get(data, paramID);
}

int BattleSystem_SideToBattler(BattleSystem *battleSys, BattleContext *battleCtx, int side)
{
    int battler;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    for (battler = 0; battler < maxBattlers; battler++) {
        if (BattleSystem_GetBattlerSide(battleSys, battler) == side) {
            break;
        }
    }

    return battler;
}

void BattleSystem_SortMonActionOrder(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int i, j;
    int battler1, battler2;
    int ignoreQuickClaw;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    for (i = 0; i < maxBattlers - 1; i++) {
        for (j = i + 1; j < maxBattlers; j++) {
            battler1 = battleCtx->battlerActionOrder[i];
            battler2 = battleCtx->battlerActionOrder[j];

            if (battleCtx->battlerActions[battler1][BATTLE_ACTION_SELECTED_COMMAND] == battleCtx->battlerActions[battler2][BATTLE_ACTION_SELECTED_COMMAND]) {
                if (battleCtx->battlerActions[battler1][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_FIGHT) {
                    ignoreQuickClaw = FALSE;
                } else {
                    ignoreQuickClaw = TRUE;
                }

                if (BattleSystem_CompareBattlerSpeed(battleSys, battleCtx, battler1, battler2, ignoreQuickClaw)) {
                    battleCtx->battlerActionOrder[i] = battler2;
                    battleCtx->battlerActionOrder[j] = battler1;
                }
            }
        }
    }
}

static const enum BattleSubAnimation sEffectsAlwaysShown[] = {
    BATTLE_ANIMATION_SUB_OUT,
    BATTLE_ANIMATION_SUB_IN,
    BATTLE_ANIMATION_ITEM_ESCAPE,
    BATTLE_ANIMATION_WEATHER_FOG,
    BATTLE_ANIMATION_WEATHER_RAIN,
    BATTLE_ANIMATION_WEATHER_HAIL,
    BATTLE_ANIMATION_WEATHER_SAND,
    BATTLE_ANIMATION_WEATHER_SUN,
    BATTLE_ANIMATION_SUBSTITUTE_IN,
    BATTLE_ANIMATION_SUBSTITUTE_OUT,
};

BOOL BattleSystem_ShouldShowStatusEffect(BattleContext *battleCtx, int battler, int status)
{
    BOOL result = FALSE;

    if ((battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_SUBSTITUTE)
        || (battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_SEMI_INVULNERABLE)) {
        for (int i = 0; i < NELEMS(sEffectsAlwaysShown); i++) {
            if (sEffectsAlwaysShown[i] == status) {
                result = TRUE;
                break;
            }
        }
    } else {
        result = TRUE;
    }

    return result;
}

BOOL BattleSystem_TriggerHeldItemOnPivotMove(BattleSystem *battleSys, BattleContext *battleCtx, int *subscript)
{
    BOOL result = FALSE;
    int attackerItemEffect = Battler_HeldItemEffect(battleCtx, battleCtx->attacker);
    int attackerItemPower = Battler_HeldItemPower(battleCtx, battleCtx->attacker, ITEM_POWER_CHECK_ALL);
    int defenderItemEffect = Battler_HeldItemEffect(battleCtx, battleCtx->defender);
    int defenderItemPower = Battler_HeldItemPower(battleCtx, battleCtx->defender, ITEM_POWER_CHECK_ALL);
    int attackingSide = BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker);

    if (attackerItemEffect == HOLD_EFFECT_HP_RESTORE_ON_DMG
        && (battleCtx->battleStatusMask & SYSCTL_MOVE_HIT)
        && Sovereign_HealBlocked(battleCtx, battleCtx->attacker) == FALSE // Sovereign: Heal Block (Gen V+)
        && ATTACKER_SELF_TURN_FLAGS.shellBellDamageDealt
        && battleCtx->attacker != battleCtx->defender
        && ATTACKING_MON.curHP < ATTACKING_MON.maxHP
        && ATTACKING_MON.curHP) {
        battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKER_SELF_TURN_FLAGS.shellBellDamageDealt * -1, attackerItemPower);
        battleCtx->msgBattlerTemp = battleCtx->attacker;
        *subscript = subscript_restore_a_little_hp;
        result = TRUE;
    }

    if (attackerItemEffect == HOLD_EFFECT_HP_DRAIN_ON_ATK
        && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_MAGIC_GUARD
        && (battleCtx->battleStatusMask & SYSCTL_MOVE_HIT)
        && CURRENT_MOVE_DATA.class != CLASS_STATUS
        && ATTACKING_MON.curHP) {
        battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP * -1, 10);
        battleCtx->msgBattlerTemp = battleCtx->attacker;
        *subscript = subscript_lose_hp_from_item;
        result = TRUE;
    }

    if (defenderItemEffect == HOLD_EFFECT_RECOIL_PHYSICAL
        && battleCtx->battleMons[battleCtx->attacker].curHP
        && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_MAGIC_GUARD
        && DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken) {
        battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP * -1, defenderItemPower);
        *subscript = subscript_held_item_recoil_when_hit;
        result = TRUE;
    }

    if (defenderItemEffect == HOLD_EFFECT_DMG_USER_CONTACT_XFR
        && ATTACKING_MON.curHP
        && ATTACKING_MON.heldItem == ITEM_NONE
        && (battleCtx->sideConditions[attackingSide].knockedOffItemsMask & FlagIndex(battleCtx->selectedPartySlot[battleCtx->attacker])) == FALSE
        && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
        && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur)) {
        *subscript = subscript_transfer_sticky_barb;
        result = TRUE;
    }

    return result;
}

void BattleSystem_DecPPForPressure(BattleContext *battleCtx, int attacker, int defender)
{
    if (defender != BATTLER_NONE
        && Battler_Ability(battleCtx, defender) == ABILITY_PRESSURE
        && battleCtx->battleMons[attacker].ppCur[battleCtx->moveSlot[attacker]]) {
        battleCtx->battleMons[attacker].ppCur[battleCtx->moveSlot[attacker]]--;
    }
}

BOOL BattleSystem_IsRecordingStopped(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (BattleSystem_GetRecordingStopped(battleSys)) {
        battleCtx->command = BATTLE_CONTROL_SCREEN_WIPE;
        return TRUE;
    }

    return FALSE;
}

int BattleContext_Get(BattleSystem *battleSys, BattleContext *battleCtx, enum BattleContextParam paramID, int battler)
{
    int side;
    switch (paramID) {
    case BATTLECTX_SIDE_CONDITIONS_MASK:
        side = BattleSystem_GetBattlerSide(battleSys, battler);
        return battleCtx->sideConditionsMask[side];

    case BATTLECTX_SIDE_MIST_TURNS:
        side = BattleSystem_GetBattlerSide(battleSys, battler);
        return battleCtx->sideConditions[side].mistTurns;

    case BATTLECTX_SELECTED_PARTY_SLOT:
        return battleCtx->selectedPartySlot[battler];

    case BATTLECTX_TOTAL_TURNS:
        return battleCtx->totalTurns;

    case BATTLECTX_LEVEL_UP_MONS:
        return battleCtx->levelUpMons;

    case BATTLECTX_SAFARI_ESCAPE_COUNT:
        return battleCtx->safariEscapeCount;

    case BATTLECTX_TOTAL_FAINTED_FOR:
        return battleCtx->totalFainted[battler];

    case BATTLECTX_TOTAL_DAMAGE_FOR:
        return battleCtx->totalDamage[battler];

    case BATTLECTX_ACTION_FOR:
        return battleCtx->battlerActions[battler][BATTLE_ACTION_PICK_COMMAND];

    case BATTLECTX_AICTX_DEFENDER:
        return battleCtx->aiContext.defender;

    case BATTLECTX_SWITCHING_MASK:
        return battleCtx->battlersSwitchingMask;

    case BATTLECTX_AICTX_SELECTED_TARGET:
        return battleCtx->aiContext.selectedTarget[battler];

    case BATTLECTX_ACTION_TEMP_FOR:
        return battleCtx->battlerActions[battler][BATTLE_ACTION_TEMP_VALUE];

    case BATTLECTX_CONTROL_COMMAND:
        return battleCtx->command;

    case BATTLECTX_NEXT_CONTROL_COMMAND:
        return battleCtx->commandNext;
    }

    GF_ASSERT(FALSE);
    return 0;
}

void BattleContext_Set(BattleSystem *battleSys, BattleContext *battleCtx, enum BattleContextParam paramID, int battler, int val)
{
    int side;
    switch (paramID) {
    case BATTLECTX_SIDE_CONDITIONS_MASK:
        side = BattleSystem_GetBattlerSide(battleSys, battler);
        battleCtx->sideConditionsMask[side] = val;
        break;

    case BATTLECTX_SIDE_MIST_TURNS:
        side = BattleSystem_GetBattlerSide(battleSys, battler);
        battleCtx->sideConditions[side].mistTurns = val;
        break;

    case BATTLECTX_SELECTED_PARTY_SLOT:
        battleCtx->selectedPartySlot[battler] = val;
        break;

    case BATTLECTX_TOTAL_TURNS:
        battleCtx->totalTurns = val;
        break;

    case BATTLECTX_AICTX_DEFENDER:
        battleCtx->aiContext.defender = val;
        break;

    case BATTLECTX_AICTX_SELECTED_TARGET:
        battleCtx->aiContext.selectedTarget[battler] = val;
        break;

    default:
        GF_ASSERT(FALSE);
        break;
    }
}

#include "data/move_side_effect_subscripts.h"

/**
 * @brief Map the given side effect to an appropriate subscript.
 *
 * @param battleCtx
 * @param type      Type of side effect; see enum BattleSideEffectType
 * @param effect    Effect which should be mapped to a corresponding subscript
 * @return int
 */
static int MapSideEffectToSubscript(BattleContext *battleCtx, enum BattleSideEffectType type, u32 effect)
{
    battleCtx->sideEffectType = type;
    battleCtx->sideEffectParam = effect & MOVE_SIDE_EFFECT_SUBSCRIPT_POINTER;
    battleCtx->sideEffectFlags = effect & MOVE_SIDE_EFFECT_FLAGS;

    if (effect & MOVE_SIDE_EFFECT_TO_ATTACKER) {
        battleCtx->sideEffectMon = battleCtx->attacker;
    } else if (effect & MOVE_SIDE_EFFECT_TO_DEFENDER) {
        battleCtx->sideEffectMon = battleCtx->defender;
    } else if ((effect & MOVE_SIDE_EFFECT_ON_HIT) || (effect & MOVE_SIDE_EFFECT_CHECK_HP)) {
        battleCtx->sideEffectMon = 0;
    }

    GF_ASSERT(NELEMS(sSideEffectSubscripts) > (effect & MOVE_SIDE_EFFECT_SUBSCRIPT_POINTER));

    return sSideEffectSubscripts[effect & MOVE_SIDE_EFFECT_SUBSCRIPT_POINTER];
}

/**
 * @brief Apply the type multiplier to the given damage value and update the
 * move status mask.
 *
 * @param battleCtx
 * @param attacker
 * @param mul
 * @param damage
 * @param update        If TRUE, the move status mask will be updated
 * @param[out] moveStatus
 * @return The resulting damage value after applying type effectiveness
 */
static int ApplyTypeMultiplier(BattleContext *battleCtx, int attacker, int mul, int damage, BOOL update, u32 *moveStatus)
{
    if ((battleCtx->battleStatusMask & SYSCTL_IGNORE_TYPE_CHECKS) == FALSE
        && (battleCtx->battleStatusMask & SYSCTL_IGNORE_IMMUNITIES) == FALSE
        && damage) {
        damage = BattleSystem_Divide(damage * mul, 10);
    }

    switch (mul) {
    case TYPE_MULTI_IMMUNE:
        *moveStatus |= MOVE_STATUS_INEFFECTIVE;
        *moveStatus &= ~MOVE_STATUS_NOT_VERY_EFFECTIVE;
        *moveStatus &= ~MOVE_STATUS_SUPER_EFFECTIVE;
        break;

    case TYPE_MULTI_NOT_VERY_EFF:
        if (update) {
            if (*moveStatus & MOVE_STATUS_SUPER_EFFECTIVE) {
                *moveStatus &= ~MOVE_STATUS_SUPER_EFFECTIVE;
            } else {
                *moveStatus |= MOVE_STATUS_NOT_VERY_EFFECTIVE;
            }
        }
        break;

    case TYPE_MULTI_SUPER_EFF:
        if (update) {
            if (*moveStatus & MOVE_STATUS_NOT_VERY_EFFECTIVE) {
                *moveStatus &= ~MOVE_STATUS_NOT_VERY_EFFECTIVE;
            } else {
                *moveStatus |= MOVE_STATUS_SUPER_EFFECTIVE;
            }
        }
        break;
    }

    return damage;
}

/**
 * @brief Checks if a move is on its damaging turn.
 *
 * @param battleCtx
 * @param move
 * @return TRUE if the move is on its damaging turn, FALSE otherwise
 */
static BOOL MoveIsOnDamagingTurn(BattleContext *battleCtx, int move)
{
    switch (MOVE_DATA(move).effect) {
    case BATTLE_EFFECT_BIDE:
    case BATTLE_EFFECT_CHARGE_TURN_HIGH_CRIT:
    case BATTLE_EFFECT_CHARGE_TURN_HIGH_CRIT_FLINCH:
    case BATTLE_EFFECT_CHARGE_TURN_DEF_UP:
    case BATTLE_EFFECT_ELECTRO_SHOT: // Sovereign (item 11)
    case BATTLE_EFFECT_SOVEREIGN_CHARGE_TURN_HIT:
    case BATTLE_EFFECT_SOVEREIGN_GEOMANCY:
    case BATTLE_EFFECT_SOVEREIGN_SKY_DROP:
    case BATTLE_EFFECT_SKIP_CHARGE_TURN_IN_SUN:
    case BATTLE_EFFECT_FLY:
    case BATTLE_EFFECT_DIVE:
    case BATTLE_EFFECT_DIG:
    case BATTLE_EFFECT_BOUNCE:
    case BATTLE_EFFECT_SHADOW_FORCE: // Sovereign: BATTLE_EFFECT_FLINCH_BURN_HIT in Platinum, so Fire Fang always bypassed Wonder Guard (docs/bugs_and_glitches.md)
        return battleCtx->battleStatusMask & SYSCTL_LAST_OF_MULTI_TURN;
        break;
    }

    return TRUE;
}

/**
 * @brief Get the type of the battler (e.g. Normal, Fighting, etc.).
 *
 * An additional layer of logic is applied to Arceus to account for Multitype.
 *
 * @param battleCtx
 * @param battler
 * @param paramID   Either BATTLEMON_TYPE_1 or BATTLEMON_TYPE_2
 * @return The battler's type
 */
static u8 Battler_MonType(BattleContext *battleCtx, int battler, enum BattleMonParam paramID)
{
    u8 type;
    if (paramID == BATTLEMON_TYPE_1) {
        type = battleCtx->battleMons[battler].type1;
    } else if (paramID == BATTLEMON_TYPE_2) {
        type = battleCtx->battleMons[battler].type2;
    } else {
        GF_ASSERT(FALSE);
    }

    // Sovereign (FM): Fairy Arceus.
    if (battleCtx->battleMons[battler].species == SPECIES_ARCEUS
        && battleCtx->battleMons[battler].ability == ABILITY_MULTITYPE
        && battleCtx->battleMons[battler].heldItem == ITEM_PIXIE_PLATE) {
        type = TYPE_FAIRY;
    } else if (battleCtx->battleMons[battler].species == SPECIES_ARCEUS
        && battleCtx->battleMons[battler].ability == ABILITY_MULTITYPE) {
        switch (BattleSystem_GetItemData(battleCtx, battleCtx->battleMons[battler].heldItem, ITEM_PARAM_HOLD_EFFECT)) {
        case HOLD_EFFECT_ARCEUS_FIRE:
            type = TYPE_FIRE;
            break;

        case HOLD_EFFECT_ARCEUS_WATER:
            type = TYPE_WATER;
            break;

        case HOLD_EFFECT_ARCEUS_ELECTRIC:
            type = TYPE_ELECTRIC;
            break;

        case HOLD_EFFECT_ARCEUS_GRASS:
            type = TYPE_GRASS;
            break;

        case HOLD_EFFECT_ARCEUS_ICE:
            type = TYPE_ICE;
            break;

        case HOLD_EFFECT_ARCEUS_FIGHTING:
            type = TYPE_FIGHTING;
            break;

        case HOLD_EFFECT_ARCEUS_POISON:
            type = TYPE_POISON;
            break;

        case HOLD_EFFECT_ARCEUS_GROUND:
            type = TYPE_GROUND;
            break;

        case HOLD_EFFECT_ARCEUS_FLYING:
            type = TYPE_FLYING;
            break;

        case HOLD_EFFECT_ARCEUS_PSYCHIC:
            type = TYPE_PSYCHIC;
            break;

        case HOLD_EFFECT_ARCEUS_BUG:
            type = TYPE_BUG;
            break;

        case HOLD_EFFECT_ARCEUS_ROCK:
            type = TYPE_ROCK;
            break;

        case HOLD_EFFECT_ARCEUS_GHOST:
            type = TYPE_GHOST;
            break;

        case HOLD_EFFECT_ARCEUS_DRAGON:
            type = TYPE_DRAGON;
            break;

        case HOLD_EFFECT_ARCEUS_DARK:
            type = TYPE_DARK;
            break;

        case HOLD_EFFECT_ARCEUS_STEEL:
            type = TYPE_STEEL;
            break;

        default:
            type = TYPE_NORMAL;
            break;
        }
    }

    return type;
}

/**
 * @brief Clear the AI's knowledge of any moves for the given battler.
 *
 * @param battleCtx
 * @param battler
 */
static void BattleAI_ClearKnownMoves(BattleContext *battleCtx, u8 battler)
{
    for (int i = 0; i < LEARNED_MOVES_MAX; i++) {
        battleCtx->aiContext.battlerMoves[battler][i] = MOVE_NONE;
    }
}

/**
 * @brief Clear the AI's knowledge of the given battler's ability.
 *
 * @param battleCtx
 * @param battler
 */
static void BattleAI_ClearKnownAbility(BattleContext *battleCtx, u8 battler)
{
    battleCtx->aiContext.battlerAbilities[battler] = ABILITY_NONE;
}

/**
 * @brief Clear the AI's knowledge of the given battler's held item.
 *
 * @param battleCtx
 * @param battler
 */
static void BattleAI_ClearKnownItem(BattleContext *battleCtx, u8 battler)
{
    battleCtx->aiContext.battlerHeldItems[battler] = ITEM_NONE;
}

/**
 * @brief Choose the target for Trace.
 *
 * @param battleSys
 * @param battleCtx
 * @param defender1
 * @param defender2
 * @return Either of defender1 or defender2, if at least one has a Traceable
 * ability, or BATTLER_NONE, if there is no valid Trace target.
 */
static int ChooseTraceTarget(BattleSystem *battleSys, BattleContext *battleCtx, int defender1, int defender2)
{
    int trace = BATTLER_NONE;

    // Sovereign (item 11): Gen IX's list of abilities Trace can't take (Wonder Guard it can).
#define SOVEREIGN_TRACEABLE(battler) (battleCtx->battleMons[battler].curHP \
    && (Sovereign_AbilityCantBeCopied(battleCtx->battleMons[battler].ability) == FALSE \
        || battleCtx->battleMons[battler].ability == ABILITY_WONDER_GUARD))

    if (SOVEREIGN_TRACEABLE(defender1) && SOVEREIGN_TRACEABLE(defender2)) {
        // Both targets are eligible; choose randomly
        if (BattleSystem_RandNext(battleSys) & 1) {
            trace = defender2;
        } else {
            trace = defender1;
        }
    } else if (SOVEREIGN_TRACEABLE(defender1)) {
        trace = defender1;
    } else if (SOVEREIGN_TRACEABLE(defender2)) {
        trace = defender2;
    }

#undef SOVEREIGN_TRACEABLE

    return trace;
}

static const u16 sMovesCannotTriggerAnticipation[] = {
    BATTLE_EFFECT_40_DAMAGE_FLAT,
    BATTLE_EFFECT_LEVEL_DAMAGE_FLAT,
    BATTLE_EFFECT_RANDOM_DAMAGE_1_TO_150_LEVEL,
    BATTLE_EFFECT_COUNTER,
    BATTLE_EFFECT_MIRROR_COAT,
    BATTLE_EFFECT_METAL_BURST,
};

static BOOL MoveCannotTriggerAnticipation(BattleContext *battleCtx, int move)
{
    for (int i = 0; i < NELEMS(sMovesCannotTriggerAnticipation); i++) {
        if (sMovesCannotTriggerAnticipation[i] == MOVE_DATA(move).effect) {
            return TRUE;
        }
    }

    return FALSE;
}

/**
 * @brief Compute the type of a move which has variable typing.
 *
 * This routine is functionally identical to Move_CalcVariableType.
 *
 * @param battleSys
 * @param battleCtx
 * @param item      The attacker's held item. Affects the typing of Natural Gift
 *                  and Judgment.
 * @param move      The move being used.
 * @return The variable-type of the given move.
 */
// Sovereign (FM): the sovereignHeroPending bit of a battler's party slot. Battlers that share a party (a trainer's two
// in a double battle) share its bits.
u32 BattleSystem_SovereignHeroBit(BattleSystem *battleSys, int battler, int slot)
{
    int party = battler;

    for (int i = 0; i < battler; i++) {
        if (BattleSystem_GetParty(battleSys, i) == BattleSystem_GetParty(battleSys, battler)) {
            party = i;
            break;
        }
    }

    return 1 << (party * MAX_PARTY_SIZE + slot);
}

// Sovereign (FM): TRUE for Ash-Greninja (Battle Bond's battle form), whose Water Shuriken is stronger.
BOOL Sovereign_IsAshGreninja(BattleMon *mon)
{
    const int ashForm = Pokemon_SovereignAbilityForm(SPECIES_GRENINJA, Pokemon_SovereignBattleFormBase(SPECIES_GRENINJA, mon->formNum), ABILITY_BATTLE_BOND);

    return mon->species == SPECIES_GRENINJA && mon->formNum != 0 && mon->formNum == ashForm;
}

// Sovereign (FM): Aura Wheel is Dark-type when a Hangry Morpeko uses it, else Electric.
// Sovereign (item 11): Raging Bull's type: Fighting, Fire or Water from a Paldean Tauros (Combat, Blaze or Aqua Breed),
// Normal otherwise.
int Sovereign_RagingBullType(u16 species, int form)
{
    static const u8 breedTypes[] = { TYPE_NORMAL, TYPE_FIGHTING, TYPE_FIRE, TYPE_WATER };

    return species == SPECIES_TAUROS && form < NELEMS(breedTypes) ? breedTypes[form] : TYPE_NORMAL;
}

int Sovereign_AuraWheelType(u16 species, int form)
{
    return species == SPECIES_MORPEKO && form != 0 ? TYPE_DARK : TYPE_ELECTRIC;
}

static int CalcMoveType(BattleSystem *battleSys, BattleContext *battleCtx, int item, int move)
{
    int type;
    u32 weather;

    // Sovereign (FM): Judgment with the Pixie Plate, Multi-Attack with a Memory, Techno Blast with a Drive. (item is
    // the battler; Klutz and Embargo leave Battler_HeldItem empty.)
    if (Pokemon_SovereignItemMoveType(move, Battler_HeldItem(battleCtx, item)) >= 0) {
        return Pokemon_SovereignItemMoveType(move, Battler_HeldItem(battleCtx, item));
    }

    switch (move) {
    case MOVE_NATURAL_GIFT:
        type = Battler_NaturalGiftType(battleCtx, item);
        break;

    case MOVE_JUDGMENT:
        switch (Battler_HeldItemEffect(battleCtx, item)) {
        case HOLD_EFFECT_ARCEUS_FIGHTING:
            type = TYPE_FIGHTING;
            break;
        case HOLD_EFFECT_ARCEUS_FLYING:
            type = TYPE_FLYING;
            break;
        case HOLD_EFFECT_ARCEUS_POISON:
            type = TYPE_POISON;
            break;
        case HOLD_EFFECT_ARCEUS_GROUND:
            type = TYPE_GROUND;
            break;
        case HOLD_EFFECT_ARCEUS_ROCK:
            type = TYPE_ROCK;
            break;
        case HOLD_EFFECT_ARCEUS_BUG:
            type = TYPE_BUG;
            break;
        case HOLD_EFFECT_ARCEUS_GHOST:
            type = TYPE_GHOST;
            break;
        case HOLD_EFFECT_ARCEUS_STEEL:
            type = TYPE_STEEL;
            break;
        case HOLD_EFFECT_ARCEUS_FIRE:
            type = TYPE_FIRE;
            break;
        case HOLD_EFFECT_ARCEUS_WATER:
            type = TYPE_WATER;
            break;
        case HOLD_EFFECT_ARCEUS_GRASS:
            type = TYPE_GRASS;
            break;
        case HOLD_EFFECT_ARCEUS_ELECTRIC:
            type = TYPE_ELECTRIC;
            break;
        case HOLD_EFFECT_ARCEUS_PSYCHIC:
            type = TYPE_PSYCHIC;
            break;
        case HOLD_EFFECT_ARCEUS_ICE:
            type = TYPE_ICE;
            break;
        case HOLD_EFFECT_ARCEUS_DRAGON:
            type = TYPE_DRAGON;
            break;
        case HOLD_EFFECT_ARCEUS_DARK:
            type = TYPE_DARK;
            break;
        default:
            type = TYPE_NORMAL;
            break;
        }
        break;

    case MOVE_HIDDEN_POWER:
        type = ((battleCtx->battleMons[item].hpIV & 1) >> 0)
            | ((battleCtx->battleMons[item].attackIV & 1) << 1)
            | ((battleCtx->battleMons[item].defenseIV & 1) << 2)
            | ((battleCtx->battleMons[item].speedIV & 1) << 3)
            | ((battleCtx->battleMons[item].spAttackIV & 1) << 4)
            | ((battleCtx->battleMons[item].spDefenseIV & 1) << 5);
        type = (type * 15 / 63) + 1;

        // Hidden Power is never Fairy-type; skip over it.
        if (type >= TYPE_FAIRY) {
            type++;
        }
        break;

    case MOVE_TERRAIN_PULSE: // Sovereign (item 11)
        type = Sovereign_TerrainPulseType(battleCtx, item);
        break;

    case MOVE_AURA_WHEEL: // Sovereign (FM): Dark-type from a Hangry Morpeko (the parameter is the battler)
        type = Sovereign_AuraWheelType(battleCtx->battleMons[item].species, battleCtx->battleMons[item].formNum);
        break;

    case MOVE_RAGING_BULL: // Sovereign (item 11): the type of a Paldean Tauros's breed
        type = Sovereign_RagingBullType(battleCtx->battleMons[item].species, battleCtx->battleMons[item].formNum);
        break;

    case MOVE_WEATHER_BALL: // Sovereign (item 11): the weather as it acts on the user's moves (Utility Umbrella, Mega Sol)
        weather = Sovereign_MoveWeather(battleSys, battleCtx, item);
        type = TYPE_NORMAL;

        if (weather & FIELD_CONDITION_RAINING) {
            type = TYPE_WATER;
        }

        if (weather & FIELD_CONDITION_SANDSTORM) {
            type = TYPE_ROCK;
        }

        if (weather & FIELD_CONDITION_SUNNY) {
            type = TYPE_FIRE;
        }

        if (weather & FIELD_CONDITION_HAILING) {
            type = TYPE_ICE;
        }
        break;

    default:
        type = TYPE_NORMAL;
        break;
    }

    return type;
}

int BattleAI_PostKOSwitchIn(BattleSystem *battleSys, int battler)
{
    // Must keep C89-style declaration to match
    int i, j;
    u8 defender, defenderType1, defenderType2;
    u8 monType1, monType2;
    u16 monSpecies;
    u16 move;
    int moveType;
    u8 battlersDisregarded;
    u32 score, maxScore; // Sovereign (12b): u8 in Platinum, which overflowed (Post-KO Switch-In AI Scoring Overflow, docs/bugs_and_glitches.md)
    u8 picked = 6;
    u8 slot1, slot2;
    u32 moveStatusFlags;
    int partySize;
    int monAbility;
    Pokemon *mon;
    BattleContext *battleCtx = BattleSystem_GetBattleContext(battleSys);

    slot1 = battler;
    if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_TAG)
        || (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_2vs2)) {
        slot2 = slot1;
    } else {
        slot2 = BattleSystem_GetPartner(battleSys, battler);
    }

    defender = BattleSystem_RandomOpponent(battleSys, battleCtx, battler);
    partySize = BattleSystem_GetPartyCount(battleSys, battler);
    battlersDisregarded = 0;

    // Stage 1: Loop through all the party slots and find the one with the most favorable
    // offensive type-matchup against the chosen defender which also has a super-effective
    // move against that defender. Choose the Pokemon with the highest such score, breaking
    // ties by party-order. If no such Pokemon exists, proceed to Stage 2.
    //
    // Mono-type Pokemon are regarded as being dual-type of the same type.
    while (battlersDisregarded != 0x3F) {
        maxScore = 0;
        picked = 6;

        for (i = 0; i < partySize; i++) {
            mon = BattleSystem_GetPartyPokemon(battleSys, battler, i);
            monSpecies = Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL);

            if (monSpecies != SPECIES_NONE
                && monSpecies != SPECIES_EGG
                && Pokemon_GetValue(mon, MON_DATA_HP, NULL)
                && (battlersDisregarded & FlagIndex(i)) == FALSE
                && battleCtx->selectedPartySlot[slot1] != i
                && battleCtx->selectedPartySlot[slot2] != i
                && i != battleCtx->aiSwitchedPartySlot[slot1]
                && i != battleCtx->aiSwitchedPartySlot[slot2]) {
                defenderType1 = BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_1, NULL);
                defenderType2 = BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_2, NULL);
                monType1 = Pokemon_GetValue(mon, MON_DATA_TYPE_1, NULL);
                monType2 = Pokemon_GetValue(mon, MON_DATA_TYPE_2, NULL);

                score = BattleSystem_TypeMatchupMultiplier(monType1, defenderType1, defenderType2);
                score += BattleSystem_TypeMatchupMultiplier(monType2, defenderType1, defenderType2);

                if (maxScore < score) {
                    maxScore = score;
                    picked = i;
                }
            } else {
                battlersDisregarded |= FlagIndex(i);
            }
        }

        if (picked != 6) {
            // Determine if this mon has any super-effective moves against the defender
            mon = BattleSystem_GetPartyPokemon(battleSys, battler, picked);

            for (i = 0; i < LEARNED_MOVES_MAX; i++) {
                move = Pokemon_GetValue(mon, MON_DATA_MOVE1 + i, NULL);
                moveType = Move_CalcVariableType(battleSys, battleCtx, mon, move);

                if (move) {
                    moveStatusFlags = 0;
                    Sovereign_CalcEffectivenessAgainst(battleCtx,
                        move,
                        moveType,
                        Pokemon_GetValue(mon, MON_DATA_ABILITY, NULL),
                        defender,
                        &moveStatusFlags);

                    if (moveStatusFlags & MOVE_STATUS_SUPER_EFFECTIVE) {
                        break;
                    }
                }
            }

            // If this mon has no moves which would be super-effective against the
            // defender, mark it as disregarded and move to the next in priority.
            if (i == LEARNED_MOVES_MAX) {
                battlersDisregarded |= FlagIndex(picked);
            } else {
                return picked;
            }
        } else {
            // No valid battlers to further-evaluate, break out
            battlersDisregarded = 0x3F;
        }
    }

    maxScore = 0;
    picked = 6;

    // Stage 2: Loop through all the party slots and score them by how much damage would be done
    // by the maximum non-critical roll of each of their moves if it were used by the battler
    // which just fainted. Choose the Pokemon with the highest such score, breaking ties by
    // party-order.
    for (i = 0; i < partySize; i++) {
        mon = BattleSystem_GetPartyPokemon(battleSys, battler, i);
        monSpecies = Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL);

        if (monSpecies != SPECIES_NONE
            && monSpecies != SPECIES_EGG
            && Pokemon_GetValue(mon, MON_DATA_HP, NULL)
            && battleCtx->selectedPartySlot[slot1] != i
            && battleCtx->selectedPartySlot[slot2] != i
            && i != battleCtx->aiSwitchedPartySlot[slot1]
            && i != battleCtx->aiSwitchedPartySlot[slot2]) {
            for (j = 0; j < LEARNED_MOVES_MAX; j++) {
                move = Pokemon_GetValue(mon, MON_DATA_MOVE1 + j, NULL);
                moveType = Move_CalcVariableType(battleSys, battleCtx, mon, move);

                if (move && MOVE_DATA(move).power != 1) {
                    score = BattleSystem_CalcMoveDamage(battleSys,
                        battleCtx,
                        move,
                        battleCtx->sideConditionsMask[BattleSystem_GetBattlerSide(battleSys, defender)],
                        battleCtx->fieldConditionsMask,
                        0,
                        0,
                        battler,
                        defender,
                        1);

                    moveStatusFlags = 0;
                    score = BattleSystem_ApplyTypeChart(battleSys,
                        battleCtx,
                        move,
                        moveType,
                        battler,
                        defender,
                        score,
                        &moveStatusFlags);

                    if (moveStatusFlags & MOVE_STATUS_IMMUNE) {
                        score = 0;
                    }

                    // Sovereign (12b): so is a move the target's ability absorbs (Water Absorb, Lightning Rod...).
                    monAbility = Pokemon_GetValue(mon, MON_DATA_ABILITY, NULL);
                    if (AbilityAbsorbsMove(monAbility, Battler_Ability(battleCtx, defender), Sovereign_AbilityMoveType(monAbility, move, moveType ? moveType : MOVE_DATA(move).type))) {
                        score = 0;
                    }
                }

                if (maxScore < score) {
                    maxScore = score;
                    picked = i;
                }
            }
        }
    }

    return picked;
}

int BattleAI_SwitchedSlot(BattleSystem *battleSys, int battler)
{
    BattleContext *battleCtx = BattleSystem_GetBattleContext(battleSys);
    return battleCtx->aiSwitchedPartySlot[battler];
}

int Move_CalcVariableType(BattleSystem *battleSys, BattleContext *battleCtx, Pokemon *mon, int move)
{
    int type;

    // Sovereign (FM): Judgment with the Pixie Plate, Multi-Attack with a Memory, Techno Blast with a Drive.
    if (Pokemon_SovereignItemMoveType(move, Pokemon_GetValue(mon, MON_DATA_HELD_ITEM, NULL)) >= 0) {
        return Pokemon_SovereignItemMoveType(move, Pokemon_GetValue(mon, MON_DATA_HELD_ITEM, NULL));
    }

    switch (move) {
    case MOVE_AURA_WHEEL: // Sovereign (FM)
        type = Sovereign_AuraWheelType(Pokemon_GetValue(mon, MON_DATA_SPECIES, NULL), Pokemon_GetValue(mon, MON_DATA_FORM, NULL));
        break;

    case MOVE_RAGING_BULL: // Sovereign (item 11)
        type = Sovereign_RagingBullType(Pokemon_GetValue(mon, MON_DATA_SPECIES, NULL), Pokemon_GetValue(mon, MON_DATA_FORM, NULL));
        break;

    case MOVE_NATURAL_GIFT:
        type = BattleSystem_GetItemData(battleCtx, Pokemon_GetValue(mon, MON_DATA_HELD_ITEM, NULL), ITEM_PARAM_NATURAL_GIFT_TYPE);
        break;

    case MOVE_JUDGMENT:
        switch (BattleSystem_GetItemData(battleCtx, Pokemon_GetValue(mon, MON_DATA_HELD_ITEM, NULL), ITEM_PARAM_HOLD_EFFECT)) {
        case HOLD_EFFECT_ARCEUS_FIGHTING:
            type = TYPE_FIGHTING;
            break;
        case HOLD_EFFECT_ARCEUS_FLYING:
            type = TYPE_FLYING;
            break;
        case HOLD_EFFECT_ARCEUS_POISON:
            type = TYPE_POISON;
            break;
        case HOLD_EFFECT_ARCEUS_GROUND:
            type = TYPE_GROUND;
            break;
        case HOLD_EFFECT_ARCEUS_ROCK:
            type = TYPE_ROCK;
            break;
        case HOLD_EFFECT_ARCEUS_BUG:
            type = TYPE_BUG;
            break;
        case HOLD_EFFECT_ARCEUS_GHOST:
            type = TYPE_GHOST;
            break;
        case HOLD_EFFECT_ARCEUS_STEEL:
            type = TYPE_STEEL;
            break;
        case HOLD_EFFECT_ARCEUS_FIRE:
            type = TYPE_FIRE;
            break;
        case HOLD_EFFECT_ARCEUS_WATER:
            type = TYPE_WATER;
            break;
        case HOLD_EFFECT_ARCEUS_GRASS:
            type = TYPE_GRASS;
            break;
        case HOLD_EFFECT_ARCEUS_ELECTRIC:
            type = TYPE_ELECTRIC;
            break;
        case HOLD_EFFECT_ARCEUS_PSYCHIC:
            type = TYPE_PSYCHIC;
            break;
        case HOLD_EFFECT_ARCEUS_ICE:
            type = TYPE_ICE;
            break;
        case HOLD_EFFECT_ARCEUS_DRAGON:
            type = TYPE_DRAGON;
            break;
        case HOLD_EFFECT_ARCEUS_DARK:
            type = TYPE_DARK;
            break;
        default:
            type = TYPE_NORMAL;
            break;
        }
        break;

    case MOVE_HIDDEN_POWER:
        type = ((Pokemon_GetValue(mon, MON_DATA_HP_IV, NULL) & 1) >> 0)
            | ((Pokemon_GetValue(mon, MON_DATA_ATK_IV, NULL) & 1) << 1)
            | ((Pokemon_GetValue(mon, MON_DATA_DEF_IV, NULL) & 1) << 2)
            | ((Pokemon_GetValue(mon, MON_DATA_SPEED_IV, NULL) & 1) << 3)
            | ((Pokemon_GetValue(mon, MON_DATA_SPATK_IV, NULL) & 1) << 4)
            | ((Pokemon_GetValue(mon, MON_DATA_SPDEF_IV, NULL) & 1) << 5);
        type = (type * 15 / 63) + 1;

        // Hidden Power is never Fairy-type; skip over it.
        if (type >= TYPE_FAIRY) {
            type++;
        }
        break;

    case MOVE_WEATHER_BALL:
        if (NO_CLOUD_NINE) {
            if (battleCtx->fieldConditionsMask & FIELD_CONDITION_WEATHER) {
                if (WEATHER_IS_RAIN) {
                    type = TYPE_WATER;
                }

                if (WEATHER_IS_SAND) {
                    type = TYPE_ROCK;
                }

                if (WEATHER_IS_SUN) {
                    type = TYPE_FIRE;
                }

                if (WEATHER_IS_HAIL) {
                    type = TYPE_ICE;
                }
            }
        }
        break;

    default:
        type = TYPE_NORMAL;
        break;
    }

    return type;
}

// Sovereign (decision 18): raises the Totem's stats by its trial's aura (BATTLE_STATUS_TOTEM_AURA) and buffers the
// message for subscript_sovereign_totem_aura. FALSE if the aura raises nothing.
BOOL BattleSystem_SovereignApplyTotemAura(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    u32 statusMask = BattleSystem_GetBattleStatusMask(battleSys);
    int count = 0, lastStat = 0, maxStages = 0;

    for (int i = 0; i < TOTEM_AURA_STATS; i++) {
        int stages = BATTLE_STATUS_TOTEM_AURA_STAGES(statusMask, i);
        s8 *boost = &battleCtx->battleMons[battler].statBoosts[BATTLE_STAT_ATTACK + i];

        if (stages == 0) {
            continue;
        }

        *boost = (*boost + stages > MAX_STAT_STAGE) ? MAX_STAT_STAGE : *boost + stages;
        count++;
        lastStat = i;
        maxStages = stages > maxStages ? stages : maxStages;
    }

    if (count == 0) {
        return FALSE;
    }

    if (count == 1) {
        battleCtx->msgBuffer.id = maxStages >= 2 ? BattleStrings_Text_SovereignTotemStatSharplyRose : BattleStrings_Text_SovereignTotemStatRose;
        battleCtx->msgBuffer.tags = TAG_NICKNAME_STAT | TAG_GLOBAL_MESSAGE;
        battleCtx->msgBuffer.params[1] = BATTLE_STAT_ATTACK + lastStat;
    } else {
        battleCtx->msgBuffer.id = BattleStrings_Text_SovereignTotemStatsRose;
        battleCtx->msgBuffer.tags = TAG_NICKNAME | TAG_GLOBAL_MESSAGE;
    }

    battleCtx->msgBuffer.params[0] = BattleSystem_NicknameTag(battleCtx, battler);
    return TRUE;
}

// Sovereign (decision 18): TRUE in a Totem trial once the Totem (the first Pokemon of the wild party) has fainted. It
// calls no more helpers then (battle_controller_player.c).
BOOL BattleSystem_SovereignTotemFainted(BattleSystem *battleSys)
{
    if ((BattleSystem_GetBattleStatusMask(battleSys) & BATTLE_STATUS_SOVEREIGN_TOTEM) == FALSE) {
        return FALSE;
    }

    Pokemon *totem = Party_GetPokemonBySlotIndex(BattleSystem_GetParty(battleSys, BATTLER_ENEMY_1), 0);
    return Pokemon_GetValue(totem, MON_DATA_HP, NULL) == 0;
}
