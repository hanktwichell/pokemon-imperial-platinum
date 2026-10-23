#ifndef POKEPLATINUM_SOVEREIGN_FORM_ITEMS_H
#define POKEPLATINUM_SOVEREIGN_FORM_ITEMS_H

#include "party.h"
#include "pokemon.h"
#include "savedata.h"

// Sovereign (FM): key items used on a Pokemon from the bag to change its form. The Reveal Glass and the Prison Bottle
// switch a form on and off; the DNA Splicers, N-Solarizer, N-Lunarizer and Reins of Unity fuse two Pokemon and
// separate them again.
enum SovereignFormItemResult {
    SOVEREIGN_FORM_ITEM_NONE = 0, // not a form-change key item
    SOVEREIGN_FORM_ITEM_NO_EFFECT, // nothing to change ("It won't have any effect.")
    SOVEREIGN_FORM_ITEM_NO_ROOM, // a fused Pokemon can't separate: the party is full
    SOVEREIGN_FORM_ITEM_CHANGED,
};

BOOL SovereignFormItem_IsFormItem(u16 item);
int SovereignFormItem_Use(SaveData *saveData, Party *party, int slot, u16 item, int *changedSlot, int *fusedPartnerSlot);

#endif // POKEPLATINUM_SOVEREIGN_FORM_ITEMS_H
