#ifndef POKEPLATINUM_STRUCT_TRAINER_DATA_H
#define POKEPLATINUM_STRUCT_TRAINER_DATA_H

/*
 * Note: *most* source files should not include this header directly, and should
 * instead including `struct_defs/trainer.h`. This header is held separately for
 * use by data-packing routines.
 */

#include "constants/moves.h"

// Sovereign: species in the low 11 bits (up to 2047; vanilla had 10, max 1023), form in the high 5 bits.
#define TRAINER_MON_FORM_SHIFT   11
#define TRAINER_MON_SPECIES_MASK ((1 << TRAINER_MON_FORM_SHIFT) - 1)

#define MAX_TRAINER_ITEMS 4
#define MAX_IV_SCALE      255

enum TrainerDataType {
    TRDATATYPE_BASE = 0,
    TRDATATYPE_WITH_MOVES,
    TRDATATYPE_WITH_ITEM,
    TRDATATYPE_WITH_MOVES_AND_ITEM,
    TRDATATYPE_SOVEREIGN, // Sovereign (milestone E9): every field, see TrainerMonSovereign
};

typedef struct TrainerHeader {
    u8 monDataType;
    u8 trainerType;
    u8 sprite;
    u8 partySize;
    u16 items[MAX_TRAINER_ITEMS];
    u32 aiMask;
    u32 battleType;
} TrainerHeader;

typedef struct TrainerMonBase {
    u16 ivScale;
    u16 level;
    u16 species;
    u16 cbSeal;
} TrainerMonBase;

typedef struct TrainerMonWithMoves {
    u16 ivScale;
    u16 level;
    u16 species;
    u16 moves[LEARNED_MOVES_MAX];
    u16 cbSeal;
} TrainerMonWithMoves;

typedef struct TrainerMonWithItem {
    u16 ivScale;
    u16 level;
    u16 species;
    u16 item;
    u16 cbSeal;
} TrainerMonWithItem;

typedef struct TrainerMonWithMovesAndItem {
    u16 ivScale;
    u16 level;
    u16 species;
    u16 item;
    u16 moves[LEARNED_MOVES_MAX];
    u16 cbSeal;
} TrainerMonWithMovesAndItem;

// Sovereign (milestone E9): the trainer format for hand-built teams. A party uses it when any member sets nature,
// ability, ivs, evs, gender, shiny or ball (see tools/dataproc/src/trainerproc.c); every other party keeps
// Platinum's layouts above, so Platinum's trainers pack and behave exactly as before.
#define TRAINER_MON_NATURE_DEFAULT 0xFF // nature, gender: take it from the personality value, as Platinum does
#define TRAINER_MON_GENDER_DEFAULT 0xFF

#define TRAINER_MON_FLAG_MOVES (1 << 0) // the moves below replace the level-up moves
#define TRAINER_MON_FLAG_SHINY (1 << 1)

// The IVs and EVs, in this order.
enum TrainerMonStat {
    TRAINER_MON_STAT_HP = 0,
    TRAINER_MON_STAT_ATTACK,
    TRAINER_MON_STAT_DEFENSE,
    TRAINER_MON_STAT_SPEED,
    TRAINER_MON_STAT_SP_ATTACK,
    TRAINER_MON_STAT_SP_DEFENSE,
    TRAINER_MON_STAT_COUNT,
};

typedef struct TrainerMonSovereign {
    u16 ivScale; // only seeds the personality value, as in Platinum's layouts; the IVs are below
    u16 level;
    u16 species; // the whole species ID (no form bits)
    u16 item;
    u16 moves[LEARNED_MOVES_MAX];
    u16 ability; // ABILITY_NONE: from the personality value, as Platinum does
    u16 ball; // the Poké Ball item; ITEM_NONE: a Poké Ball
    u16 cbSeal;
    u8 form;
    u8 nature;
    u8 gender;
    u8 flags;
    u8 ivs[TRAINER_MON_STAT_COUNT];
    u8 evs[TRAINER_MON_STAT_COUNT];
} TrainerMonSovereign;

// Big enough for a full party in any layout.
#define TRAINER_PARTY_BUFFER_SIZE (sizeof(TrainerMonSovereign) * MAX_PARTY_SIZE)

#endif // POKEPLATINUM_STRUCT_TRAINER_DATA_H
