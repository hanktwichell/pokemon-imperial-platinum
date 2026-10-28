#ifndef POKEPLATINUM_CHARACTER_SPRITE_H
#define POKEPLATINUM_CHARACTER_SPRITE_H

#include "constants/heap.h"
#include "constants/narc.h"
#include "constants/species.h"

#define FRAME_0_REGION { 0, 0, 10, 10 }
#define FRAME_1_REGION { 10, 0, 10, 10 }

// Sovereign: the OAM cells of a 96x96 copy (64x64, 32x64, 64x32, 32x32), in tiles, in the order its tiles are stored.
#define MON_SPRITE_96_CELLS { { 0, 0, 8, 8 }, { 8, 0, 4, 8 }, { 0, 8, 8, 4 }, { 8, 8, 4, 4 } }

typedef struct TileRegion {
    int x;
    int y;
    int width;
    int height;
} TileRegion;

void CharacterSprite_LoadTiledData(enum NarcID narcID, int narcIdx, enum HeapID heapID, int x, int y, int width, int height, void *dest);
void CharacterSprite_LoadSpriteRegion(enum NarcID narcID, int narcIdx, enum HeapID heapID, const TileRegion *region, void *dest);
void CharacterSprite_LoadSpriteFrame0(enum NarcID narcID, int narcIdx, enum HeapID heapID, void *dest);
void *CharacterSprite_LoadTiles(enum NarcID narcID, int narcIdx, enum HeapID heapID);
void *CharacterSprite_LoadPalette(enum NarcID narcID, int paletteIndex, enum HeapID heapID);

void CharacterSprite_LoadPokemonSpriteRect(enum NarcID narcID, int narcIdx, enum HeapID heapID, int x, int y, int width, int height, u8 *dest, u32 personality, BOOL isAnimated, int face, enum Species species);
void CharacterSprite_LoadPokemonSpriteRegion(enum NarcID narcID, int narcIdx, enum HeapID heapID, const TileRegion *frameTiles, void *dest, u32 personality, BOOL isAnimated, int face, enum Species species);
void CharacterSprite_LoadPokemonSprite(enum NarcID narcID, int narcIdx, enum HeapID heapID, void *destPtr, u32 personality, BOOL isAnimated, int face, enum Species species);

// Sovereign: 96x96 copies (MON_SPRITE_96_SIZE_BYTES, in the OAM cell order of include/constants/graphics.h); an 80x80
// sprite sits in the middle. The other functions above give the middle 80x80 of a 96x96 sprite.
void CharacterSprite_LoadPokemonSprite96(enum NarcID narcID, int narcIdx, enum HeapID heapID, int frame, void *dest, u32 personality, BOOL isAnimated, int face, enum Species species);
void CharacterSprite_LoadSprite96(enum NarcID narcID, int narcIdx, enum HeapID heapID, int frame, void *dest);

#endif // POKEPLATINUM_CHARACTER_SPRITE_H
