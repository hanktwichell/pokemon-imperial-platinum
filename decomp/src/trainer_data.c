#include "trainer_data.h"

#include "constants/battle.h"
#include "constants/pokemon.h"
#include "generated/abilities.h"
#include "generated/gender_ratios.h"
#include "generated/natures.h"
#include "generated/trainer_message_types.h"

#include "struct_defs/trainer.h"

#include "data/trainer_class_genders.h"

#include "charcode_util.h"
#include "field_battle_data_transfer.h"
#include "heap.h"
#include "math_util.h"
#include "message.h"
#include "narc.h"
#include "party.h"
#include "pokemon.h"
#include "savedata.h"
#include "savedata_misc.h"
#include "string_gf.h"

static void TrainerData_BuildParty(FieldBattleDTO *dto, int battler, enum HeapID heapID);
static void TrainerData_InitSovereignMon(Pokemon *mon, const TrainerMonSovereign *trmon, u32 personality, enum HeapID heapID);
static void TrainerData_SovereignFormMoves(Pokemon *mon);

void Trainer_Encounter(FieldBattleDTO *dto, const SaveData *saveData, enum HeapID heapID)
{
    Trainer trdata;
    MessageLoader *msgLoader = MessageLoader_Init(MSG_LOADER_LOAD_ON_DEMAND, NARC_INDEX_MSGDATA__PL_MSG, TEXT_BANK_NPC_TRAINER_NAMES, heapID);
    const charcode_t *rivalName = MiscSaveBlock_RivalName(SaveData_MiscSaveBlockConst(saveData));

    for (int i = 0; i < MAX_BATTLERS; i++) {
        if (!dto->trainerIDs[i]) {
            continue;
        }

        Trainer_Load(dto->trainerIDs[i], &trdata);
        dto->trainer[i] = trdata;

        if (trdata.header.trainerType == TRAINER_CLASS_RIVAL) {
            CharCode_Copy(dto->trainer[i].name, rivalName);
        } else {
            String *trainerName = MessageLoader_GetNewString(msgLoader, dto->trainerIDs[i]);
            String_ToChars(trainerName, dto->trainer[i].name, TRAINER_NAME_LEN + 1);
            String_Free(trainerName);
        }

        TrainerData_BuildParty(dto, i, heapID);
    }

    dto->battleType |= trdata.header.battleType;
    MessageLoader_Free(msgLoader);
}

u32 Trainer_LoadParam(int trainerID, enum TrainerDataParam paramID)
{
    // TODO: can this be trainerheader?
    u32 result;
    Trainer trdata;

    Trainer_Load(trainerID, &trdata);

    switch (paramID) {
    case TRDATA_TYPE:
        result = trdata.header.monDataType;
        break;

    case TRDATA_CLASS:
        result = trdata.header.trainerType;
        break;

    case TRDATA_SPRITE:
        result = trdata.header.sprite;
        break;

    case TRDATA_PARTY_SIZE:
        result = trdata.header.partySize;
        break;

    case TRDATA_ITEM_1:
    case TRDATA_ITEM_2:
    case TRDATA_ITEM_3:
    case TRDATA_ITEM_4:
        result = trdata.header.items[paramID - TRDATA_ITEM_1];
        break;

    case TRDATA_AI_MASK:
        result = trdata.header.aiMask;
        break;

    case TRDATA_BATTLE_TYPE:
        result = trdata.header.battleType;
        break;
    }

    return result;
}

BOOL Trainer_HasMessageType(int trainerID, enum TrainerMessageType msgType, enum HeapID heapID)
{
    NARC *narc; // must declare up here to match
    u16 offset, data[2];

    BOOL result = FALSE;
    int size = NARC_GetMemberSizeByIndexPair(NARC_INDEX_POKETOOL__TRMSG__TRTBL, 0);
    NARC_ReadFromMemberByIndexPair(&offset, NARC_INDEX_POKETOOL__TRMSG__TRTBLOFS, 0, trainerID * 2, 2);
    narc = NARC_ctor(NARC_INDEX_POKETOOL__TRMSG__TRTBL, heapID);

    while (offset != size) {
        NARC_ReadFromMember(narc, 0, offset, 4, data);

        if (data[0] == trainerID && data[1] == msgType) {
            result = TRUE;
            break;
        }

        if (data[0] != trainerID) {
            break;
        }

        offset += 4;
    }

    NARC_dtor(narc);
    return result;
}

void Trainer_LoadMessage(int trainerID, enum TrainerMessageType msgType, String *string, enum HeapID heapID)
{
    NARC *narc; // must declare up here to match
    u16 offset, data[2];

    int size = NARC_GetMemberSizeByIndexPair(NARC_INDEX_POKETOOL__TRMSG__TRTBL, 0);
    NARC_ReadFromMemberByIndexPair(&offset, NARC_INDEX_POKETOOL__TRMSG__TRTBLOFS, 0, trainerID * 2, 2);
    narc = NARC_ctor(NARC_INDEX_POKETOOL__TRMSG__TRTBL, heapID);

    while (offset != size) {
        NARC_ReadFromMember(narc, 0, offset, 4, data);

        if (data[0] == trainerID && data[1] == msgType) {
            MessageBank_GetStringFromNARC(NARC_INDEX_MSGDATA__PL_MSG, TEXT_BANK_NPC_TRAINER_MESSAGES, offset / 4, heapID, string);
            break;
        }

        offset += 4;
    }

    NARC_dtor(narc);

    if (offset == size) {
        String_Clear(string);
    }
}

void Trainer_Load(int trainerID, Trainer *trdata)
{
    NARC_ReadWholeMemberByIndexPair(trdata, NARC_INDEX_POKETOOL__TRAINER__TRDATA, trainerID);
}

void Trainer_LoadParty(int trainerID, void *trparty)
{
    NARC_ReadWholeMemberByIndexPair(trparty, NARC_INDEX_POKETOOL__TRAINER__TRPOKE, trainerID);
}

u8 TrainerClass_Gender(int trclass)
{
    return sTrainerClassGender[trclass];
}

/**
 * @brief Build the party for a trainer as loaded in the FieldBattleDTO struct.
 *
 * @param dto  The parent FieldBattleDTO struct containing trainer data.
 * @param battler       Which battler's party is to be loaded.
 * @param heapID        Heap on which to perform any allocations.
 */
// Sovereign: a Pokémon whose trainer data gives it no moves knows its form's level-up moves, not the base form's.
static void TrainerData_SovereignFormMoves(Pokemon *mon)
{
    if (Pokemon_GetValue(mon, MON_DATA_FORM, NULL) != 0) {
        Pokemon_SovereignSetDefaultMoves(mon);
    }
}

static void TrainerData_BuildParty(FieldBattleDTO *dto, int battler, enum HeapID heapID)
{
    // must make declarations C89-style to match
    void *buf;
    int i, j;
    u32 genderMod, rnd, oldSeed;
    u8 ivs;
    Pokemon *mon;

    oldSeed = LCRNG_GetSeed();

    // alloc enough space to support the maximum possible data size
    Party_InitWithCapacity(dto->parties[battler], MAX_PARTY_SIZE);
    buf = Heap_Alloc(heapID, TRAINER_PARTY_BUFFER_SIZE);
    mon = Pokemon_New(heapID);

    Trainer_LoadParty(dto->trainerIDs[battler], buf);

    // determine which magic gender-specific modifier to use for the RNG function
    genderMod = TrainerClass_Gender(dto->trainer[battler].header.trainerType) == GENDER_FEMALE
        ? 120
        : 136;

    switch (dto->trainer[battler].header.monDataType) {
    case TRDATATYPE_BASE: {
        TrainerMonBase *trmon = (TrainerMonBase *)buf;
        for (i = 0; i < dto->trainer[battler].header.partySize; i++) {
            u16 species = trmon[i].species & TRAINER_MON_SPECIES_MASK;
            u8 form = trmon[i].species >> TRAINER_MON_FORM_SHIFT;

            rnd = trmon[i].ivScale + trmon[i].level + species + dto->trainerIDs[battler];
            LCRNG_SetSeed(rnd);

            for (j = 0; j < dto->trainer[battler].header.trainerType; j++) {
                rnd = LCRNG_Next();
            }

            rnd = (rnd << 8) + genderMod;
            ivs = trmon[i].ivScale * MAX_IVS_SINGLE_STAT / MAX_IV_SCALE;

            Pokemon_InitWith(mon, species, trmon[i].level, ivs, TRUE, rnd, OTID_NOT_SHINY, 0);
            Pokemon_SetBallSeal(trmon[i].cbSeal, mon, heapID);
            Pokemon_SetValue(mon, MON_DATA_FORM, &form);
            Pokemon_SovereignSetGenderForm(mon); // Sovereign (FM): a Female Meowstic's form follows its gender
            TrainerData_SovereignFormMoves(mon);
            Pokemon_CalcStats(mon); // Sovereign: the form's stats (Platinum kept the base form's)
            Party_AddPokemon(dto->parties[battler], mon);
        }

        break;
    }

    case TRDATATYPE_WITH_MOVES: {
        TrainerMonWithMoves *trmon = (TrainerMonWithMoves *)buf;
        for (i = 0; i < dto->trainer[battler].header.partySize; i++) {
            u16 species = trmon[i].species & TRAINER_MON_SPECIES_MASK;
            u8 form = trmon[i].species >> TRAINER_MON_FORM_SHIFT;

            rnd = trmon[i].ivScale + trmon[i].level + species + dto->trainerIDs[battler];
            LCRNG_SetSeed(rnd);

            for (j = 0; j < dto->trainer[battler].header.trainerType; j++) {
                rnd = LCRNG_Next();
            }

            rnd = (rnd << 8) + genderMod;
            ivs = trmon[i].ivScale * MAX_IVS_SINGLE_STAT / MAX_IV_SCALE;

            Pokemon_InitWith(mon, species, trmon[i].level, ivs, TRUE, rnd, OTID_NOT_SHINY, 0);

            for (j = 0; j < 4; j++) {
                Pokemon_SetMoveSlot(mon, trmon[i].moves[j], j);
            }

            Pokemon_SetBallSeal(trmon[i].cbSeal, mon, heapID);
            Pokemon_SetValue(mon, MON_DATA_FORM, &form);
            Pokemon_SovereignSetGenderForm(mon); // Sovereign (FM): a Female Meowstic's form follows its gender
            Pokemon_CalcStats(mon); // Sovereign: the form's stats (Platinum kept the base form's)
            Party_AddPokemon(dto->parties[battler], mon);
        }

        break;
    }

    case TRDATATYPE_WITH_ITEM: {
        TrainerMonWithItem *trmon = (TrainerMonWithItem *)buf;
        for (i = 0; i < dto->trainer[battler].header.partySize; i++) {
            u16 species = trmon[i].species & TRAINER_MON_SPECIES_MASK;
            u8 form = trmon[i].species >> TRAINER_MON_FORM_SHIFT;

            rnd = trmon[i].ivScale + trmon[i].level + species + dto->trainerIDs[battler];
            LCRNG_SetSeed(rnd);

            for (j = 0; j < dto->trainer[battler].header.trainerType; j++) {
                rnd = LCRNG_Next();
            }

            rnd = (rnd << 8) + genderMod;
            ivs = trmon[i].ivScale * MAX_IVS_SINGLE_STAT / MAX_IV_SCALE;

            Pokemon_InitWith(mon, species, trmon[i].level, ivs, TRUE, rnd, OTID_NOT_SHINY, 0);
            Pokemon_SetValue(mon, MON_DATA_HELD_ITEM, &trmon[i].item);
            Pokemon_SetBallSeal(trmon[i].cbSeal, mon, heapID);
            Pokemon_SetValue(mon, MON_DATA_FORM, &form);
            Pokemon_SovereignSetGenderForm(mon); // Sovereign (FM): a Female Meowstic's form follows its gender
            TrainerData_SovereignFormMoves(mon);
            Pokemon_CalcStats(mon); // Sovereign: the form's stats (Platinum kept the base form's)
            Party_AddPokemon(dto->parties[battler], mon);
        }

        break;
    }

    case TRDATATYPE_WITH_MOVES_AND_ITEM: {
        TrainerMonWithMovesAndItem *trmon = (TrainerMonWithMovesAndItem *)buf;
        for (i = 0; i < dto->trainer[battler].header.partySize; i++) {
            u16 species = trmon[i].species & TRAINER_MON_SPECIES_MASK;
            u8 form = trmon[i].species >> TRAINER_MON_FORM_SHIFT;

            rnd = trmon[i].ivScale + trmon[i].level + species + dto->trainerIDs[battler];
            LCRNG_SetSeed(rnd);

            for (j = 0; j < dto->trainer[battler].header.trainerType; j++) {
                rnd = LCRNG_Next();
            }

            rnd = (rnd << 8) + genderMod;
            ivs = trmon[i].ivScale * MAX_IVS_SINGLE_STAT / MAX_IV_SCALE;

            Pokemon_InitWith(mon, species, trmon[i].level, ivs, TRUE, rnd, OTID_NOT_SHINY, 0);
            Pokemon_SetValue(mon, MON_DATA_HELD_ITEM, &trmon[i].item);

            for (j = 0; j < 4; j++) {
                Pokemon_SetMoveSlot(mon, trmon[i].moves[j], j);
            }

            Pokemon_SetBallSeal(trmon[i].cbSeal, mon, heapID);
            Pokemon_SetValue(mon, MON_DATA_FORM, &form);
            Pokemon_SovereignSetGenderForm(mon); // Sovereign (FM): a Female Meowstic's form follows its gender
            Pokemon_CalcStats(mon); // Sovereign: the form's stats (Platinum kept the base form's)
            Party_AddPokemon(dto->parties[battler], mon);
        }

        break;
    }

    case TRDATATYPE_SOVEREIGN: {
        TrainerMonSovereign *trmon = (TrainerMonSovereign *)buf;
        for (i = 0; i < dto->trainer[battler].header.partySize; i++) {
            // The same seeded personality value as Platinum's layouts; TrainerData_InitSovereignMon adjusts it.
            rnd = trmon[i].ivScale + trmon[i].level + trmon[i].species + dto->trainerIDs[battler];
            LCRNG_SetSeed(rnd);

            for (j = 0; j < dto->trainer[battler].header.trainerType; j++) {
                rnd = LCRNG_Next();
            }

            rnd = (rnd << 8) + genderMod;

            TrainerData_InitSovereignMon(mon, &trmon[i], rnd, heapID);
            Party_AddPokemon(dto->parties[battler], mon);
        }

        break;
    }
    }

    Heap_Free(buf);
    Heap_Free(mon);
    LCRNG_SetSeed(oldSeed);
}

// Sovereign (milestone E9): change a personality value as little as possible so that it gives the requested
// nature, gender and ability slot (abilitySlot: 0 or 1, or -1 for either). The low byte decides the gender and the
// ability slot (bit 0); the rest is stepped until the value % NATURE_COUNT is the nature (each step adds 256, and
// 256 % 25 = 6, which is coprime with 25, so 25 steps reach every nature).
static u32 TrainerData_SovereignPersonality(u32 personality, u16 species, u8 nature, u8 gender, int abilitySlot)
{
    u32 genderRatio = SpeciesData_GetSpeciesValue(species, SPECIES_DATA_GENDER_RATIO);
    BOOL fixedGender = genderRatio == GENDER_RATIO_MALE_ONLY || genderRatio == GENDER_RATIO_FEMALE_ONLY || genderRatio == GENDER_RATIO_NO_GENDER;
    u32 low = personality & 0xFF;
    u32 high = personality >> 8;
    int i;

    for (i = 0; i < 256; i++) {
        u32 candidate = (low + i) & 0xFF;

        if (gender != TRAINER_MON_GENDER_DEFAULT && !fixedGender) {
            u8 candidateGender = genderRatio > candidate ? GENDER_FEMALE : GENDER_MALE;

            if (candidateGender != gender) {
                continue;
            }
        }

        if (abilitySlot >= 0 && (candidate & 1) != (u32)abilitySlot) {
            continue;
        }

        low = candidate;
        break;
    }

    if (nature != TRAINER_MON_NATURE_DEFAULT) {
        if (high > 0xFFFFFF - NATURE_COUNT) {
            high -= NATURE_COUNT;
        }

        for (i = 0; i < NATURE_COUNT; i++) {
            if (((high + i) << 8 | low) % NATURE_COUNT == nature) {
                high += i;
                break;
            }
        }
    }

    return high << 8 | low;
}

static void TrainerData_InitSovereignMon(Pokemon *mon, const TrainerMonSovereign *trmon, u32 personality, enum HeapID heapID)
{
    u32 ability1 = SpeciesData_GetFormValue(trmon->species, trmon->form, SPECIES_DATA_ABILITY_1);
    u32 ability2 = SpeciesData_GetFormValue(trmon->species, trmon->form, SPECIES_DATA_ABILITY_2);
    u32 hiddenAbility = SpeciesData_GetFormValue(trmon->species, trmon->form, SPECIES_DATA_ABILITY_HIDDEN);
    int abilitySlot = -1;
    u8 hasHiddenAbility = FALSE;
    BOOL customAbility = FALSE;
    u8 value;
    int i;

    // Pick the ability by its slot when the species has it, so form changes keep it; anything else is set as is.
    if (trmon->ability != ABILITY_NONE) {
        if (trmon->ability == ability1) {
            abilitySlot = ability2 == ABILITY_NONE || ability2 == ability1 ? -1 : 0;
        } else if (trmon->ability == ability2) {
            abilitySlot = 1;
        } else if (trmon->ability == hiddenAbility) {
            hasHiddenAbility = TRUE;
        } else {
            customAbility = TRUE;
        }
    }

    personality = TrainerData_SovereignPersonality(personality, trmon->species, trmon->nature, trmon->gender, abilitySlot);

    if (trmon->flags & TRAINER_MON_FLAG_SHINY) {
        // An OT ID whose two halves XOR to the personality's two halves always makes a shiny Pokémon.
        Pokemon_InitWith(mon, trmon->species, trmon->level, 0, TRUE, personality, OTID_SET, ((personality >> 16) ^ (personality & 0xFFFF)) << 16);
    } else {
        Pokemon_InitWith(mon, trmon->species, trmon->level, 0, TRUE, personality, OTID_NOT_SHINY, 0);
    }

    Pokemon_SetValue(mon, MON_DATA_FORM, &trmon->form);
    Pokemon_SetValue(mon, MON_DATA_HAS_HIDDEN_ABILITY, &hasHiddenAbility);
    Pokemon_CalcAbility(mon);

    if (customAbility) {
        Pokemon_SetValue(mon, MON_DATA_ABILITY, &trmon->ability);
    }

    for (i = 0; i < TRAINER_MON_STAT_COUNT; i++) {
        value = trmon->ivs[i];
        Pokemon_SetValue(mon, MON_DATA_HP_IV + i, &value);
        value = trmon->evs[i];
        Pokemon_SetValue(mon, MON_DATA_HP_EV + i, &value);
    }

    Pokemon_SetValue(mon, MON_DATA_HELD_ITEM, &trmon->item);

    if (trmon->flags & TRAINER_MON_FLAG_MOVES) {
        for (i = 0; i < LEARNED_MOVES_MAX; i++) {
            Pokemon_SetMoveSlot(mon, trmon->moves[i], i);
        }
    } else {
        TrainerData_SovereignFormMoves(mon);
    }

    if (trmon->ball != ITEM_NONE) {
        u8 ball = trmon->ball; // the Pokémon stores its ball in one byte; trainerproc checks it fits
        Pokemon_SetValue(mon, MON_DATA_POKEBALL, &ball);
    }

    Pokemon_SetBallSeal(trmon->cbSeal, mon, heapID);
    Pokemon_CalcStats(mon);
}
