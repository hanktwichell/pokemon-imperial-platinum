#ifndef POKEPLATIUM_CONSTANTS_WILD_ENCOUNTERS_H
#define POKEPLATIUM_CONSTANTS_WILD_ENCOUNTERS_H

#define MAX_GRASS_ENCOUNTERS     12

// Sovereign (FM): an encounter slot's species can carry a form in its upper 16 bits (the Regional Forms Park).
#define WILD_SLOT(species, form)    ((species) | ((form) << 16))
#define WILD_SLOT_SPECIES(slot)     ((slot) & 0xFFFF)
#define WILD_SLOT_FORM(slot)        ((slot) >> 16)
#define MAX_SWARM_ENCOUNTERS     2
#define MAX_TIMED_ENCOUNTERS     2
#define MAX_RADAR_ENCOUNTERS     4
#define MAX_DUAL_SLOT_ENCOUNTERS 2
#define MAX_WATER_ENCOUNTERS     5

enum ENCOUNTER_TYPE {
    ENCOUNTER_TYPE_GRASS = 0,
    ENCOUNTER_TYPE_SURF,
    ENCOUNTER_TYPE_FISHING
};

enum EncounterFishingRodType {
    FISHING_TYPE_OLD_ROD = 0,
    FISHING_TYPE_GOOD_ROD,
    FISHING_TYPE_SUPER_ROD
};

#endif // POKEPLATIUM_CONSTANTS_WILD_ENCOUNTERS_H
