#include "sovereign_field_moves.h"

#include <nitro.h>

#include "constants/heap.h"
#include "constants/pokemon.h"
#include "generated/items.h"
#include "generated/moves.h"

#include "bag.h"
#include "party.h"
#include "pokemon.h"
#include "unk_02054884.h"

static const struct {
    u16 move;
    u16 hm;
} sHMs[] = {
    { MOVE_CUT, ITEM_HM01 },
    { MOVE_FLY, ITEM_HM02 },
    { MOVE_SURF, ITEM_HM03 },
    { MOVE_STRENGTH, ITEM_HM04 },
    { MOVE_DEFOG, ITEM_HM05 },
    { MOVE_ROCK_SMASH, ITEM_HM06 },
    { MOVE_WATERFALL, ITEM_HM07 },
    { MOVE_ROCK_CLIMB, ITEM_HM08 },
};

BOOL Sovereign_BagHasHMForMove(SaveData *saveData, u16 move)
{
    for (int i = 0; i < NELEMS(sHMs); i++) {
        if (sHMs[i].move == move) {
            return Bag_CanRemoveItem(SaveData_GetBag(saveData), sHMs[i].hm, 1, HEAP_ID_FIELD2);
        }
    }

    return FALSE;
}

u8 Sovereign_FieldMovePartySlot(SaveData *saveData, u16 move)
{
    Party *party = SaveData_GetParty(saveData);
    u8 slot = Party_HasMonWithMove(party, move);

    if (slot != PARTY_SLOT_NONE || Sovereign_BagHasHMForMove(saveData, move) == FALSE) {
        return slot;
    }

    for (slot = 0; slot < Party_GetCurrentCount(party); slot++) {
        if (Pokemon_GetValue(Party_GetPokemonBySlotIndex(party, slot), MON_DATA_IS_EGG, NULL) == FALSE) {
            return slot;
        }
    }

    return PARTY_SLOT_NONE;
}
