#ifndef POKEPLATINUM_LEVEL_CAP_H
#define POKEPLATINUM_LEVEL_CAP_H

#include "savedata.h"

// Level cap for the player's party: the ace level of the next big fight the player hasn't won
// (see data/level_caps.yaml). MAX_POKEMON_LEVEL when the option is off or the post-game is done.
u8 LevelCap_Get(SaveData *saveData);

// The cap the current story position implies, whether or not the option is on.
u8 LevelCap_ForProgress(SaveData *saveData);

#endif // POKEPLATINUM_LEVEL_CAP_H
