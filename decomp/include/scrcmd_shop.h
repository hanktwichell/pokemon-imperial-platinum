#ifndef POKEPLATINUM_SCRCMD_SHOP_H
#define POKEPLATINUM_SCRCMD_SHOP_H

#include "field_script_context.h"

BOOL ScrCmd_PokeMartCommon(ScriptContext *ctx);
BOOL ScrCmd_PokeMartSpecialties(ScriptContext *ctx);
BOOL ScrCmd_PokeMartDecor(ScriptContext *ctx);
BOOL ScrCmd_PokeMartSeal(ScriptContext *ctx);
BOOL ScrCmd_ShowAccessoryShop(ScriptContext *ctx);
BOOL Shop_IsItemSoldInMarts(u16 item);

#endif // POKEPLATINUM_SCRCMD_SHOP_H
