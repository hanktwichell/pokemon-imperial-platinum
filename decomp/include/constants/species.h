#ifndef POKEPLATINUM_CONSTANTS_SPECIES_H
#define POKEPLATINUM_CONSTANTS_SPECIES_H

#include "generated/species.h"

#define MAX_SPECIES        SPECIES_BAD_EGG
#define NATIONAL_DEX_COUNT (MAX_SPECIES - 2)

// Imperial: digits used to show a National Dex number or count; 3 as in Platinum, 4 from 1000 on.
#define DEX_NUMBER_DIGITS(n) ((n) >= 1000 ? 4 : 3)

#endif // POKEPLATINUM_CONSTANTS_SPECIES_H
