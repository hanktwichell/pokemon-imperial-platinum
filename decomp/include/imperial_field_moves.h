#ifndef POKEPLATINUM_IMPERIAL_FIELD_MOVES_H
#define POKEPLATINUM_IMPERIAL_FIELD_MOVES_H

#include "savedata.h"

// Imperial QoL: HM field moves without "HM slaves". Once the player has the HM in the bag, its field move works
// even if no party Pokémon knows it (the badge requirements are unchanged).
BOOL Imperial_BagHasHMForMove(SaveData *saveData, u16 move);

// HM moves can be forgotten when learning a new move (summary screen and in battle), since no Pokémon needs to know them.
#define IMPERIAL_HMS_FORGETTABLE TRUE

// The party slot that uses a field move: a Pokémon that knows it, else (if the bag has its HM) the first party
// Pokémon that isn't an Egg. PARTY_SLOT_NONE if neither.
u8 Imperial_FieldMovePartySlot(SaveData *saveData, u16 move);

#endif // POKEPLATINUM_IMPERIAL_FIELD_MOVES_H
