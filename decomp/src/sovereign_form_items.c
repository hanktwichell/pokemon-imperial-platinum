#include "sovereign_form_items.h"

#include <nitro.h>

#include "generated/items.h"
#include "generated/moves.h"
#include "generated/species.h"

#include "pal_park_transfers.h"
#include "party.h"
#include "pokemon.h"
#include "savedata.h"

#include "savedata/save_table.h"

// Sovereign (FM): the form-change key items (docs/TechnicalDesign.md §4b).
//
// Each fusion item holds the partner it fused, like in the official games. The partners are kept in Pal Park's
// transfer storage (decision 22 removes Pal Park and GBA migration), one slot per item, so the save layout is
// unchanged. Pal Park only opens with all 6 slots filled, which these 4 can't do.
#define FUSION_ITEM_COUNT 4

static const struct {
    u16 item;
    u16 partners[2];
} sFusionItems[FUSION_ITEM_COUNT] = {
    { ITEM_DNA_SPLICERS, { SPECIES_RESHIRAM, SPECIES_ZEKROM } },
    { ITEM_N_SOLARIZER, { SPECIES_SOLGALEO, SPECIES_NONE } },
    { ITEM_N_LUNARIZER, { SPECIES_LUNALA, SPECIES_NONE } },
    { ITEM_REINS_OF_UNITY, { SPECIES_GLASTRIER, SPECIES_SPECTRIER } },
};

// The moves a form changes, as in the official games: { species, form, base form's move, the form's move }. A row
// with no base move teaches the form's move in a free slot, and the Pokemon forgets it when the form ends.
static const u16 sFormMoves[][4] = {
    { SPECIES_KYUREM, 1, MOVE_GLACIATE, MOVE_ICE_BURN },
    { SPECIES_KYUREM, 1, MOVE_SCARY_FACE, MOVE_FUSION_FLARE },
    { SPECIES_KYUREM, 2, MOVE_GLACIATE, MOVE_FREEZE_SHOCK },
    { SPECIES_KYUREM, 2, MOVE_SCARY_FACE, MOVE_FUSION_BOLT },
    { SPECIES_HOOPA, 1, MOVE_HYPERSPACE_HOLE, MOVE_HYPERSPACE_FURY },
    { SPECIES_NECROZMA, 1, MOVE_NONE, MOVE_SUNSTEEL_STRIKE },
    { SPECIES_NECROZMA, 2, MOVE_NONE, MOVE_MOONGEIST_BEAM },
    { SPECIES_CALYREX, 1, MOVE_NONE, MOVE_GLACIAL_LANCE },
    { SPECIES_CALYREX, 2, MOVE_NONE, MOVE_ASTRAL_BARRAGE },
};

static int FusionItemIndex(u16 item)
{
    for (int i = 0; i < FUSION_ITEM_COUNT; i++) {
        if (sFusionItems[i].item == item) {
            return i;
        }
    }

    return -1;
}

BOOL SovereignFormItem_IsFormItem(u16 item)
{
    return item == ITEM_REVEAL_GLASS || item == ITEM_PRISON_BOTTLE || FusionItemIndex(item) >= 0;
}

static int FindMoveSlot(Pokemon *mon, u16 move)
{
    for (int i = 0; i < LEARNED_MOVES_MAX; i++) {
        if (Pokemon_GetValue(mon, MON_DATA_MOVE1 + i, NULL) == move) {
            return i;
        }
    }

    return -1;
}

// Applies the moves of entering (enter = TRUE) or leaving the form.
static void ChangeFormMoves(Pokemon *mon, u16 species, int form, BOOL enter)
{
    for (int i = 0; i < NELEMS(sFormMoves); i++) {
        u16 baseMove = sFormMoves[i][2], formMove = sFormMoves[i][3];

        if (sFormMoves[i][0] != species || sFormMoves[i][1] != form) {
            continue;
        }

        if (baseMove != MOVE_NONE) {
            Pokemon_SovereignReplaceMove(mon, enter ? baseMove : formMove, enter ? formMove : baseMove);
        } else if (enter) {
            int slot = FindMoveSlot(mon, MOVE_NONE);

            if (FindMoveSlot(mon, formMove) < 0 && slot >= 0) {
                Pokemon_SetMoveSlot(mon, formMove, slot);
            }
        } else {
            int slot = FindMoveSlot(mon, formMove);

            if (slot < 0) {
                continue;
            }

            if (Pokemon_GetValue(mon, MON_DATA_MOVE2, NULL) == MOVE_NONE) {
                Pokemon_ResetMoveSlot(mon, MOVE_CONFUSION, slot); // its only move: the official games teach Confusion
            } else {
                Pokemon_ClearMoveSlot(mon, slot);
            }
        }
    }
}

static void SetForm(Pokemon *mon, int form)
{
    u16 species = Pokemon_GetValue(mon, MON_DATA_SPECIES, NULL);
    int oldForm = Pokemon_GetValue(mon, MON_DATA_FORM, NULL);

    if (oldForm != 0) {
        ChangeFormMoves(mon, species, oldForm, FALSE);
    }

    Pokemon_SetValue(mon, MON_DATA_FORM, &form);

    if (form != 0) {
        ChangeFormMoves(mon, species, form, TRUE);
    }

    Pokemon_CalcAbility(mon);
    Pokemon_CalcLevelAndStats(mon);
}

static BOOL IsUsable(Pokemon *mon)
{
    return Pokemon_GetValue(mon, MON_DATA_IS_EGG, NULL) == FALSE;
}

// The party slot of the first Pokemon that can fuse with mon through this item, or -1. mon is either the one that
// takes the fused form (Kyurem) or its partner (Reshiram), so with both partners in the party the player picks one by
// using the item on it.
static int FindFusionMate(Party *party, int slot, int fusionIndex, int *hostSlot, u16 *partner)
{
    u16 species = Pokemon_GetValue(Party_GetPokemonBySlotIndex(party, slot), MON_DATA_SPECIES, NULL);

    for (int i = 0; i < Party_GetCurrentCount(party); i++) {
        Pokemon *other = Party_GetPokemonBySlotIndex(party, i);
        u16 otherSpecies = Pokemon_GetValue(other, MON_DATA_SPECIES, NULL);

        if (i == slot || IsUsable(other) == FALSE || Pokemon_GetValue(other, MON_DATA_FORM, NULL) != 0) {
            continue;
        }

        for (int j = 0; j < 2; j++) {
            u16 itemPartner = sFusionItems[fusionIndex].partners[j];

            if (itemPartner == SPECIES_NONE) {
                continue;
            }

            if (otherSpecies == itemPartner && Pokemon_SovereignFusionForm(species, itemPartner) != 0) {
                *hostSlot = slot;
                *partner = itemPartner;
                return i;
            }

            if (species == itemPartner && Pokemon_SovereignFusionForm(otherSpecies, itemPartner) != 0) {
                *hostSlot = i;
                *partner = itemPartner;
                return slot;
            }
        }
    }

    return -1;
}

static int UseFusionItem(SaveData *saveData, Party *party, int slot, int fusionIndex, int *changedSlot, int *fusedPartnerSlot)
{
    Pokemon *mon = Party_GetPokemonBySlotIndex(party, slot);
    Pokemon *stored = &SaveData_GetPalParkTransfer(saveData)->mons[fusionIndex];
    u16 species = Pokemon_GetValue(mon, MON_DATA_SPECIES, NULL);
    u16 fusedPartner = Pokemon_SovereignFusionPartner(species, Pokemon_GetValue(mon, MON_DATA_FORM, NULL));

    if (fusedPartner != SPECIES_NONE) {
        // Separate: the partner the item holds goes back to the party.
        if (fusedPartner != sFusionItems[fusionIndex].partners[0] && fusedPartner != sFusionItems[fusionIndex].partners[1]) {
            return SOVEREIGN_FORM_ITEM_NO_EFFECT;
        }

        if (Pokemon_GetValue(stored, MON_DATA_SPECIES, NULL) != fusedPartner) {
            return SOVEREIGN_FORM_ITEM_NO_EFFECT; // this item doesn't hold its partner (it was fused in another game)
        }

        if (Party_GetCurrentCount(party) >= MAX_PARTY_SIZE) {
            return SOVEREIGN_FORM_ITEM_NO_ROOM;
        }

        Party_AddPokemon(party, stored);
        Pokemon_Init(stored);
        SetForm(mon, 0);
        return SOVEREIGN_FORM_ITEM_CHANGED;
    }

    if (Pokemon_GetValue(stored, MON_DATA_SPECIES_EXISTS, NULL)) {
        return SOVEREIGN_FORM_ITEM_NO_EFFECT; // the item already holds a fused partner
    }

    int hostSlot;
    u16 partner;
    int partnerSlot = FindFusionMate(party, slot, fusionIndex, &hostSlot, &partner);

    if (partnerSlot < 0) {
        return SOVEREIGN_FORM_ITEM_NO_EFFECT;
    }

    // Fuse: the item takes the partner. The party menu removes it from the party after the animation, so the slots
    // it shows stay put until then.
    Pokemon *host = Party_GetPokemonBySlotIndex(party, hostSlot);

    Pokemon_Copy(Party_GetPokemonBySlotIndex(party, partnerSlot), stored);
    SetForm(host, Pokemon_SovereignFusionForm(Pokemon_GetValue(host, MON_DATA_SPECIES, NULL), partner));
    *changedSlot = hostSlot;
    *fusedPartnerSlot = partnerSlot;
    return SOVEREIGN_FORM_ITEM_CHANGED;
}

// Uses a form-change key item on the Pokemon in the party slot. *changedSlot is the slot of the Pokemon that changed
// form: the one the item was used on, or the Pokemon that fused with it when the item was used on a partner. A fusion
// leaves the partner in the party, in *fusedPartnerSlot (-1 otherwise): the caller removes it with
// Party_RemovePokemonBySlotIndex once it's done showing the party.
int SovereignFormItem_Use(SaveData *saveData, Party *party, int slot, u16 item, int *changedSlot, int *fusedPartnerSlot)
{
    Pokemon *mon = Party_GetPokemonBySlotIndex(party, slot);
    int fusionIndex = FusionItemIndex(item);

    *changedSlot = slot;
    *fusedPartnerSlot = -1;

    if (SovereignFormItem_IsFormItem(item) == FALSE) {
        return SOVEREIGN_FORM_ITEM_NONE;
    }

    if (IsUsable(mon) == FALSE) {
        return SOVEREIGN_FORM_ITEM_NO_EFFECT;
    }

    if (fusionIndex >= 0) {
        return UseFusionItem(saveData, party, slot, fusionIndex, changedSlot, fusedPartnerSlot);
    }

    u16 species = Pokemon_GetValue(mon, MON_DATA_SPECIES, NULL);
    int keyForm = Pokemon_SovereignKeyItemForm(species, item);
    int form = Pokemon_GetValue(mon, MON_DATA_FORM, NULL);

    if (keyForm == 0 || (form != 0 && form != keyForm)) {
        return SOVEREIGN_FORM_ITEM_NO_EFFECT;
    }

    SetForm(mon, form == 0 ? keyForm : 0);
    return SOVEREIGN_FORM_ITEM_CHANGED;
}
