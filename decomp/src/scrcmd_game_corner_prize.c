#include "scrcmd_game_corner_prize.h"

#include <nitro.h>
#include <string.h>

#include "generated/items.h"

#include "field_script_context.h"
#include "inlines.h"

typedef struct GameCornerPrize {
    u16 item;
    u16 price;
} GameCornerPrize;

BOOL ScrCmd_GetGameCornerPrizeData(ScriptContext *ctx)
{
    u16 index = ScriptContext_GetVar(ctx);
    u16 *item = ScriptContext_GetVarPointer(ctx);
    u16 *price = ScriptContext_GetVarPointer(ctx);

    // Sovereign (E10): Renegade Platinum's prizes, held and evolution items instead of TMs.
    static const GameCornerPrize sGameCornerPrizeData[] = {
        { ITEM_FOCUS_SASH, 1000 },
        { ITEM_WIDE_LENS, 1000 },
        { ITEM_ZOOM_LENS, 1000 },
        { ITEM_METRONOME, 1000 },
        { ITEM_LIGHT_CLAY, 1000 },
        { ITEM_EXPERT_BELT, 1000 },
        { ITEM_MUSCLE_BAND, 1000 },
        { ITEM_WISE_GLASSES, 1000 },
        { ITEM_LIFE_ORB, 1000 },
        { ITEM_TOXIC_ORB, 1000 },
        { ITEM_FLAME_ORB, 1000 },
        { ITEM_LEFTOVERS, 1000 },
        { ITEM_MENTAL_HERB, 1000 },
        { ITEM_POWER_HERB, 1000 },
        { ITEM_WHITE_HERB, 1000 },
        { ITEM_KINGS_ROCK, 2000 },
        { ITEM_METAL_COAT, 2000 },
        { ITEM_DEEPSEATOOTH, 2000 },
        { ITEM_DEEPSEASCALE, 2000 }
    };

    *item = sGameCornerPrizeData[index].item;
    *price = sGameCornerPrizeData[index].price;

    return FALSE;
}
