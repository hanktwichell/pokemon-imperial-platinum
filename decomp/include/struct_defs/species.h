#ifndef POKEPLATINUM_SPECIES_H
#define POKEPLATINUM_SPECIES_H

#define MAX_ABILITIES  3 // Sovereign: ability 1, ability 2, hidden ability (vanilla: 2)
#define MAX_EGG_GROUPS 2
#define MAX_TYPES      2

#define MAX_EVOLUTIONS 8 // Sovereign: 8 so Eevee can have Sylveon (Platinum: 7)

#define MAX_LEARNSET_ENTRIES        48 // Sovereign: Gen IX learnsets (vanilla: 20)
#define LEARNSET_NO_MOVE_TO_LEARN   0
#define LEARNSET_MOVE_ALREADY_KNOWN 0xFFFE
#define LEARNSET_ALL_SLOTS_FILLED   0xFFFF
#define LEARNSET_SENTINEL_ENTRY     0xFFFFFFFF // Sovereign: entries are 32-bit (vanilla: 16-bit 0xFFFF)

// Sovereign: a level-up learnset entry is read as one u32: move in the low 16 bits, level in the high 16
// (vanilla packed a 9-bit move and 7-bit level into a u16, which can't hold moves above 511).
#define LEARNSET_ENTRY_MOVE(entry)  ((u16)((entry) & 0xFFFF))
#define LEARNSET_ENTRY_LEVEL(entry) ((u16)((entry) >> 16))

typedef struct SpeciesBaseStats {
    u8 hp;
    u8 attack;
    u8 defense;
    u8 speed;
    u8 spAttack;
    u8 spDefense;
} SpeciesBaseStats;

typedef struct SpeciesEVYields {
    u16 hp : 2;
    u16 attack : 2;
    u16 defense : 2;
    u16 speed : 2;
    u16 spAttack : 2;
    u16 spDefense : 2;
} SpeciesEVYields;

typedef struct SpeciesWildHeldItems {
    u16 common;
    u16 rare;
} SpeciesWildHeldItems;

typedef struct SpeciesData {
    SpeciesBaseStats baseStats;
    u8 types[MAX_TYPES];
    u8 catchRate;
    u8 baseExpReward;
    SpeciesEVYields evYields;
    SpeciesWildHeldItems wildHeldItems;
    u8 genderRatio;
    u8 hatchCycles;
    u8 baseFriendship;
    u8 expRate;
    u8 eggGroups[MAX_EGG_GROUPS];
    u16 abilities[MAX_ABILITIES]; // Sovereign: u16
    u8 safariFleeRate;
    u8 bodyColor : 7;
    u8 flipSprite : 1;
    // u16 padding;

    u32 tmLearnsetMasks[4]; // Bitflags for whether this pokemon can learn a TM
} SpeciesData;

typedef struct SpeciesEvolution {
    u16 method;
    u16 param;
    u16 targetSpecies;
} SpeciesEvolution;

typedef struct SpeciesLearnsetEntry {
    u16 move;
    u16 level;
} SpeciesLearnsetEntry;

// This struct is not explicitly used; it is provided to document and enforce the size of
// the learnset entries.
typedef struct SpeciesLearnset {
    ALIGN_4 SpeciesLearnsetEntry entries[MAX_LEARNSET_ENTRIES + 1];
} SpeciesLearnset;

typedef struct SpeciesPalPark {
    u8 landArea;
    u8 waterArea;
    u8 catchingPoints;
    u8 rarity;

    union {
        u8 asU8[2];
        u16 asU16;
    } unused;
} SpeciesPalPark;

#endif // POKEPLATINUM_SPECIES_H
