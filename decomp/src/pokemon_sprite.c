#include "pokemon_sprite.h"

#include "constants/graphics.h"
#include "generated/shadow_sizes.h"

#include "struct_defs/sprite_animation_frame.h"

#include "heap.h"
#include "math_util.h"
#include "narc.h"
#include "palette.h"
#include "pokemon_sprite.h"

#include "res/pokemon/pl_otherpoke.naix"

#define MAX_SPINDA_SPOTS       4
#define SPINDA_SPOT_COORDS_END 0xFF

#define MAX_MON_SHADOWS         2
#define MAX_MON_SPRITE_PALETTES (MAX_MON_SPRITES + MAX_MON_SHADOWS)

// Sovereign (docs/FrontSprites96.md): a sprite's frames are drawn from 96x96 slots, so a front can be 96x96; an 80x80
// sprite sits centred in its slot, where it was drawn before. The four sprites' slots are stacked down a 256-pixel-wide
// texture (two frames side by side, 96 rows each), the shadows to their right: 384 rows in all, in a texture declared
// 512 rows tall.
#define NUM_MON_SPRITE_FRAMES_H 2
#define NUM_MON_SPRITE_FRAMES_V 1

#define MON_SPRITE_SLOT_SIZE   96
#define MON_SPRITE_SLOT_MARGIN ((MON_SPRITE_SLOT_SIZE - MON_SPRITE_FRAME_WIDTH) / 2)

#define MON_SPRITE_CHAR_BUF_TILES_W     32
#define MON_SPRITE_CHAR_BUF_TILES_H     (MON_SPRITE_SLOT_SIZE * MAX_MON_SPRITES / TILE_HEIGHT_PIXELS)

#define MON_SPRITE_CHAR_BUF_SIZE (MON_SPRITE_CHAR_BUF_TILES_W * MON_SPRITE_CHAR_BUF_TILES_H * TILE_SIZE_4BPP)
#define MON_SPRITE_PLTT_BUF_SIZE (MAX_MON_SPRITE_PALETTES * PALETTE_SIZE_BYTES)

#define NCGR_Y_OFFSET        0x50 // an 80x80 sprite's row (two frames), in bytes
#define MAN_Y_OFFSET         0x80 // the texture's row, in bytes
#define MAN_SLOT_CHAR_OFFSET (MON_SPRITE_SLOT_SIZE * MAN_Y_OFFSET)
#define MAN_SHADOW_X         (MON_SPRITE_SLOT_SIZE * NUM_MON_SPRITE_FRAMES_H)
#define MAN_SHADOW_ROWS      (SHADOW_SPRITE_FRAME_HEIGHT * 3)

#define MON_SPRITE_WIDTH  (MON_SPRITE_FRAME_WIDTH * NUM_MON_SPRITE_FRAMES_H)
#define MON_SPRITE_HEIGHT (MON_SPRITE_FRAME_HEIGHT * NUM_MON_SPRITE_FRAMES_V)

#define MON_SHADOW_BASE_PLTT_SLOT 3

// one particular usage of the PLTT_OFFSET macro in this file doesn't match without the cast
#define PLTT_OFFSET_CAST(i) ((i) * (u16)PALETTE_SIZE_BYTES)

typedef struct {
    u8 x;
    u8 y;
} SpindaSpotCoords;

static const SpindaSpotCoords sSpindaSpot0Coords[] = {
    { 27, 15 },
    { 28, 15 },
    { 29, 15 },
    { 30, 15 },
    { 26, 16 },
    { 27, 16 },
    { 28, 16 },
    { 29, 16 },
    { 30, 16 },
    { 31, 16 },
    { 25, 17 },
    { 26, 17 },
    { 27, 17 },
    { 28, 17 },
    { 29, 17 },
    { 30, 17 },
    { 31, 17 },
    { 32, 17 },
    { 25, 18 },
    { 26, 18 },
    { 27, 18 },
    { 28, 18 },
    { 29, 18 },
    { 30, 18 },
    { 31, 18 },
    { 32, 18 },
    { 25, 19 },
    { 26, 19 },
    { 27, 19 },
    { 28, 19 },
    { 29, 19 },
    { 30, 19 },
    { 31, 19 },
    { 32, 19 },
    { 25, 20 },
    { 26, 20 },
    { 27, 20 },
    { 28, 20 },
    { 29, 20 },
    { 30, 20 },
    { 31, 20 },
    { 32, 20 },
    { 26, 21 },
    { 27, 21 },
    { 28, 21 },
    { 29, 21 },
    { 30, 21 },
    { 31, 21 },
    { 27, 22 },
    { 28, 22 },
    { 29, 22 },
    { 30, 22 },
    { SPINDA_SPOT_COORDS_END, SPINDA_SPOT_COORDS_END }
};

static const SpindaSpotCoords sSpindaSpot1Coords[] = {
    { 51, 17 },
    { 52, 17 },
    { 53, 17 },
    { 54, 17 },
    { 50, 18 },
    { 51, 18 },
    { 52, 18 },
    { 53, 18 },
    { 54, 18 },
    { 55, 18 },
    { 49, 19 },
    { 50, 19 },
    { 51, 19 },
    { 52, 19 },
    { 53, 19 },
    { 54, 19 },
    { 55, 19 },
    { 56, 19 },
    { 49, 20 },
    { 50, 20 },
    { 51, 20 },
    { 52, 20 },
    { 53, 20 },
    { 54, 20 },
    { 55, 20 },
    { 56, 20 },
    { 49, 21 },
    { 50, 21 },
    { 51, 21 },
    { 52, 21 },
    { 53, 21 },
    { 54, 21 },
    { 55, 21 },
    { 56, 21 },
    { 49, 22 },
    { 50, 22 },
    { 51, 22 },
    { 52, 22 },
    { 53, 22 },
    { 54, 22 },
    { 55, 22 },
    { 56, 22 },
    { 50, 23 },
    { 51, 23 },
    { 52, 23 },
    { 53, 23 },
    { 54, 23 },
    { 55, 23 },
    { 51, 24 },
    { 52, 24 },
    { 53, 24 },
    { 54, 24 },
    { SPINDA_SPOT_COORDS_END, SPINDA_SPOT_COORDS_END }
};

static const SpindaSpotCoords sSpindaSpot2Coords[] = {
    { 30, 33 },
    { 31, 33 },
    { 32, 33 },
    { 29, 34 },
    { 30, 34 },
    { 31, 34 },
    { 32, 34 },
    { 33, 34 },
    { 28, 35 },
    { 29, 35 },
    { 30, 35 },
    { 31, 35 },
    { 32, 35 },
    { 33, 35 },
    { 34, 35 },
    { 28, 36 },
    { 29, 36 },
    { 30, 36 },
    { 31, 36 },
    { 32, 36 },
    { 33, 36 },
    { 34, 36 },
    { 28, 37 },
    { 29, 37 },
    { 30, 37 },
    { 31, 37 },
    { 32, 37 },
    { 33, 37 },
    { 34, 37 },
    { 28, 38 },
    { 29, 38 },
    { 30, 38 },
    { 31, 38 },
    { 32, 38 },
    { 33, 38 },
    { 34, 38 },
    { 28, 39 },
    { 29, 39 },
    { 30, 39 },
    { 31, 39 },
    { 32, 39 },
    { 33, 39 },
    { 34, 39 },
    { 29, 40 },
    { 30, 40 },
    { 31, 40 },
    { 32, 40 },
    { 33, 40 },
    { 30, 41 },
    { 31, 41 },
    { 32, 41 },
    { SPINDA_SPOT_COORDS_END, SPINDA_SPOT_COORDS_END }
};

static const SpindaSpotCoords sSpindaSpot3Coords[] = {
    { 43, 33 },
    { 44, 33 },
    { 45, 33 },
    { 41, 34 },
    { 42, 34 },
    { 43, 34 },
    { 44, 34 },
    { 45, 34 },
    { 46, 34 },
    { 47, 34 },
    { 40, 35 },
    { 41, 35 },
    { 42, 35 },
    { 43, 35 },
    { 44, 35 },
    { 45, 35 },
    { 46, 35 },
    { 47, 35 },
    { 48, 35 },
    { 40, 36 },
    { 41, 36 },
    { 42, 36 },
    { 43, 36 },
    { 44, 36 },
    { 45, 36 },
    { 46, 36 },
    { 47, 36 },
    { 48, 36 },
    { 40, 37 },
    { 41, 37 },
    { 42, 37 },
    { 43, 37 },
    { 44, 37 },
    { 45, 37 },
    { 46, 37 },
    { 47, 37 },
    { 48, 37 },
    { 40, 38 },
    { 41, 38 },
    { 42, 38 },
    { 43, 38 },
    { 44, 38 },
    { 45, 38 },
    { 46, 38 },
    { 47, 38 },
    { 48, 38 },
    { 40, 39 },
    { 41, 39 },
    { 42, 39 },
    { 43, 39 },
    { 44, 39 },
    { 45, 39 },
    { 46, 39 },
    { 47, 39 },
    { 48, 39 },
    { 40, 40 },
    { 41, 40 },
    { 42, 40 },
    { 43, 40 },
    { 44, 40 },
    { 45, 40 },
    { 46, 40 },
    { 47, 40 },
    { 48, 40 },
    { 41, 41 },
    { 42, 41 },
    { 43, 41 },
    { 44, 41 },
    { 45, 41 },
    { 46, 41 },
    { 47, 41 },
    { 43, 42 },
    { 44, 42 },
    { 45, 42 },
    { SPINDA_SPOT_COORDS_END, SPINDA_SPOT_COORDS_END }
};

static const SpindaSpotCoords *sSpindaSpotCoords[MAX_SPINDA_SPOTS] = {
    sSpindaSpot0Coords,
    sSpindaSpot1Coords,
    sSpindaSpot2Coords,
    sSpindaSpot3Coords,
};

#define SLOT_TEXTURE_COORDS(slot, frame)                                                      \
    {                                                                                         \
        (frame) * MON_SPRITE_SLOT_SIZE, (slot) * MON_SPRITE_SLOT_SIZE,                        \
            ((frame) + 1) * MON_SPRITE_SLOT_SIZE, ((slot) + 1) * MON_SPRITE_SLOT_SIZE \
    }

static const int sMonSpriteTextureCoords[MAX_MON_SPRITES][NUM_MON_SPRITE_FRAMES_H][4] = {
    { SLOT_TEXTURE_COORDS(0, 0), SLOT_TEXTURE_COORDS(0, 1) },
    { SLOT_TEXTURE_COORDS(1, 0), SLOT_TEXTURE_COORDS(1, 1) },
    { SLOT_TEXTURE_COORDS(2, 0), SLOT_TEXTURE_COORDS(2, 1) },
    { SLOT_TEXTURE_COORDS(3, 0), SLOT_TEXTURE_COORDS(3, 1) },
};

#define SHADOW_TEXTURE_COORDS(row)                                                                        \
    {                                                                                                     \
        MAN_SHADOW_X, (row) * SHADOW_SPRITE_FRAME_HEIGHT, MAN_SHADOW_X + SHADOW_SPRITE_FRAME_WIDTH, \
            ((row) + 1) * SHADOW_SPRITE_FRAME_HEIGHT                                                    \
    }

static const int sShadowTextureCoords[MAX_SHADOW_SIZES][4] = {
    [SHADOW_SIZE_NONE] = SHADOW_TEXTURE_COORDS(0), // meaningless: the shadow is hidden
    [SHADOW_SIZE_SMALL] = SHADOW_TEXTURE_COORDS(0),
    [SHADOW_SIZE_MEDIUM] = SHADOW_TEXTURE_COORDS(1),
    [SHADOW_SIZE_LARGE] = SHADOW_TEXTURE_COORDS(2),
};

static void BufferPokemonSpriteCharData(PokemonSpriteManager *monSpriteMan);
static void BufferPokemonSpritePlttData(PokemonSpriteManager *monSpriteMan);
static void TickPokemonSpriteAnim(PokemonSprite *monSprite);
static void PokemonSprite_TickAnim(PokemonSprite *monSprite);
static u8 SwapNybbles(u8 value);
static void TryDrawSpindaSpots(PokemonSprite *monSprite, u8 *rawCharData);
static void PokemonSprite_WidenPartialDraw(int *offset, int *length);
static BOOL IsUnscaled(int scale);

// Sovereign: a manager of numSlots sprites keeps a texture of numSlots slots (96 rows each), so one that shows a single
// sprite (PokemonSpriteManager_NewOneSlot) takes 12 KB instead of 48.
static void *PokemonSpriteManager_NewWithSlots(enum HeapID heapID, int numSlots)
{
    PokemonSpriteManager *monSpriteMan = Heap_Alloc(heapID, sizeof(PokemonSpriteManager));
    u32 charBufSize = numSlots * MAN_SLOT_CHAR_OFFSET;

    monSpriteMan->heapID = heapID;
    monSpriteMan->dummy330 = 0;
    monSpriteMan->numSlots = numSlots;
    monSpriteMan->charBaseAddr = 0;
    monSpriteMan->charSize = charBufSize;
    monSpriteMan->plttBaseAddr = 0;
    monSpriteMan->plttSize = PALETTE_SIZE_BYTES * MAX_MON_SPRITES;
    monSpriteMan->charRawData = Heap_Alloc(heapID, charBufSize);
    monSpriteMan->plttRawData = Heap_Alloc(heapID, MON_SPRITE_PLTT_BUF_SIZE);

    MI_CpuClearFast(monSpriteMan->plttRawData, sizeof(u32));
    monSpriteMan->plttRawDataUnfaded = Heap_Alloc(heapID, MON_SPRITE_PLTT_BUF_SIZE);
    MI_CpuClearFast(monSpriteMan->plttRawDataUnfaded, sizeof(u32));

    for (int i = 0; i < MAX_MON_SPRITES; i++) {
        MI_CpuClearFast(&monSpriteMan->sprites[i], sizeof(PokemonSprite));
    }

    NNS_G2dSetupSoftwareSpriteCamera();

    monSpriteMan->excludeIdentity = FALSE;

    NNSG2dCharacterData *charData;
    u8 *rawCharData;

    void *shadowsNCGR = NARC_AllocAndReadWholeMemberByIndexPair(NARC_INDEX_POKETOOL__POKEGRA__PL_OTHERPOKE, pokemon_shadows_NCGR, monSpriteMan->heapID);
    NNS_G2dGetUnpackedCharacterData(shadowsNCGR, &charData);

    monSpriteMan->charData.pixelFmt = charData->pixelFmt;
    monSpriteMan->charData.mappingType = charData->mappingType;
    monSpriteMan->charData.characterFmt = charData->characterFmt;
    rawCharData = charData->pRawData;

    PokemonSprite_DecryptPt(rawCharData);
    MI_CpuFill8(&monSpriteMan->charRawData[0], rawCharData[0], charBufSize);

    // the three shadows, 64x16 each, one above the other at the top left of their sheet
    for (int i = 0; i < MAN_SHADOW_ROWS; i++) {
        for (int j = 0; j < SHADOW_SPRITE_FRAME_WIDTH / 2; j++) {
            monSpriteMan->charRawData[i * MAN_Y_OFFSET + MAN_SHADOW_X / 2 + j] = rawCharData[i * NCGR_Y_OFFSET + j];
        }
    }

    Heap_Free(shadowsNCGR);

    monSpriteMan->needLoadChar = TRUE;
    monSpriteMan->needLoadPltt = TRUE;

    return monSpriteMan;
}

void *PokemonSpriteManager_New(enum HeapID heapID)
{
    return PokemonSpriteManager_NewWithSlots(heapID, MAX_MON_SPRITES);
}

void *PokemonSpriteManager_NewOneSlot(enum HeapID heapID)
{
    return PokemonSpriteManager_NewWithSlots(heapID, 1);
}

void PokemonSpriteManager_DrawSprites(PokemonSpriteManager *monSpriteMan)
{
    int width, height;
    int u0, v0, u1, v1;

    BufferPokemonSpriteCharData(monSpriteMan);
    BufferPokemonSpritePlttData(monSpriteMan);

    NNS_G3dGeFlushBuffer();

    G3_PushMtx();
    G3_TexImageParam(monSpriteMan->imageProxy.attr.fmt, GX_TEXGEN_TEXCOORD, monSpriteMan->imageProxy.attr.sizeS, monSpriteMan->imageProxy.attr.sizeT, GX_TEXREPEAT_NONE, GX_TEXFLIP_NONE, monSpriteMan->imageProxy.attr.plttUse, monSpriteMan->charBaseAddr);

    for (int i = 0; i < MAX_MON_SPRITES; i++) {
        if (monSpriteMan->sprites[i].active
            && monSpriteMan->sprites[i].transforms.hide == FALSE
            && monSpriteMan->sprites[i].transforms.hide2 == FALSE) {
            if (monSpriteMan->sprites[i].callback != NULL) {
                monSpriteMan->sprites[i].callback(&monSpriteMan->sprites[i], &monSpriteMan->sprites[i].transforms);
            }

            NNS_G3dGeFlushBuffer();

            if (monSpriteMan->excludeIdentity != TRUE) {
                G3_Identity();
            }

            PokemonSprite_TickAnim(&monSpriteMan->sprites[i]);

            G3_TexPlttBase(monSpriteMan->plttBaseAddr + PLTT_OFFSET_CAST(i), monSpriteMan->imageProxy.attr.fmt);
            G3_Translate((monSpriteMan->sprites[i].transforms.xCenter + monSpriteMan->sprites[i].transforms.xPivot) << FX32_SHIFT, (monSpriteMan->sprites[i].transforms.yCenter + monSpriteMan->sprites[i].transforms.yPivot) << FX32_SHIFT, monSpriteMan->sprites[i].transforms.zCenter << FX32_SHIFT);
            G3_RotX(FX_SinIdx(monSpriteMan->sprites[i].transforms.rotationX), FX_CosIdx(monSpriteMan->sprites[i].transforms.rotationX));
            G3_RotY(FX_SinIdx(monSpriteMan->sprites[i].transforms.rotationY), FX_CosIdx(monSpriteMan->sprites[i].transforms.rotationY));
            G3_RotZ(FX_SinIdx(monSpriteMan->sprites[i].transforms.rotationZ), FX_CosIdx(monSpriteMan->sprites[i].transforms.rotationZ));
            G3_Translate(-((monSpriteMan->sprites[i].transforms.xCenter + monSpriteMan->sprites[i].transforms.xPivot) << FX32_SHIFT), -((monSpriteMan->sprites[i].transforms.yCenter + monSpriteMan->sprites[i].transforms.yPivot) << FX32_SHIFT), -(monSpriteMan->sprites[i].transforms.zCenter << FX32_SHIFT));
            G3_MaterialColorDiffAmb(GX_RGB(monSpriteMan->sprites[i].transforms.diffuseR, monSpriteMan->sprites[i].transforms.diffuseG, monSpriteMan->sprites[i].transforms.diffuseB), GX_RGB(monSpriteMan->sprites[i].transforms.ambientR, monSpriteMan->sprites[i].transforms.ambientG, monSpriteMan->sprites[i].transforms.ambientB), TRUE);
            G3_MaterialColorSpecEmi(GX_RGB(16, 16, 16), GX_RGB(0, 0, 0), FALSE);
            G3_PolygonAttr(GX_LIGHTMASK_NONE, GX_POLYGONMODE_MODULATE, GX_CULL_NONE, monSpriteMan->sprites[i].polygonID, monSpriteMan->sprites[i].transforms.alpha, 0);

            BOOL clipped = monSpriteMan->sprites[i].transforms.clipToFrame
                && monSpriteMan->sprites[i].transforms.partialDraw == FALSE
                && IsUnscaled(monSpriteMan->sprites[i].transforms.scaleX)
                && IsUnscaled(monSpriteMan->sprites[i].transforms.scaleY);

            if (monSpriteMan->sprites[i].transforms.partialDraw || clipped) {
                // The drawn part is given in the 80x80 box centred in the slot; a side of it on the box's edge stands
                // for the slot's edge, so a 96x96 sprite keeps the parts outside the box.
                int drawX = monSpriteMan->sprites[i].transforms.drawXOffset;
                int drawY = monSpriteMan->sprites[i].transforms.drawYOffset;
                int drawW = monSpriteMan->sprites[i].transforms.drawWidth;
                int drawH = monSpriteMan->sprites[i].transforms.drawHeight;

                if (clipped) {
                    // The frame's rows, clipFrameY down in the box (within the slot), and the box's columns.
                    int top = monSpriteMan->sprites[i].transforms.clipFrameY;
                    int bottom = top + MON_SPRITE_FRAME_HEIGHT;

                    if (top < -MON_SPRITE_SLOT_MARGIN) {
                        top = -MON_SPRITE_SLOT_MARGIN;
                    }

                    if (bottom > MON_SPRITE_FRAME_HEIGHT + MON_SPRITE_SLOT_MARGIN) {
                        bottom = MON_SPRITE_FRAME_HEIGHT + MON_SPRITE_SLOT_MARGIN;
                    }

                    drawX = 0;
                    drawW = MON_SPRITE_FRAME_WIDTH;
                    drawY = top;
                    drawH = bottom - top;
                } else {
                    PokemonSprite_WidenPartialDraw(&drawX, &drawW);
                    PokemonSprite_WidenPartialDraw(&drawY, &drawH);
                }

                u0 = sMonSpriteTextureCoords[i][monSpriteMan->sprites[i].currSpriteFrame][0] + MON_SPRITE_SLOT_MARGIN + drawX;
                u1 = u0 + drawW;
                v0 = sMonSpriteTextureCoords[i][monSpriteMan->sprites[i].currSpriteFrame][1] + MON_SPRITE_SLOT_MARGIN + drawY;
                v1 = v0 + drawH;

                NNS_G2dDrawSpriteFast(
                    monSpriteMan->sprites[i].transforms.xCenter - MON_SPRITE_FRAME_WIDTH / 2 + drawX + monSpriteMan->sprites[i].transforms.xOffset,
                    monSpriteMan->sprites[i].transforms.yCenter - MON_SPRITE_FRAME_HEIGHT / 2 + drawY + monSpriteMan->sprites[i].transforms.yOffset - monSpriteMan->sprites[i].shadow.height,
                    monSpriteMan->sprites[i].transforms.zCenter + monSpriteMan->sprites[i].transforms.zOffset,
                    drawW,
                    drawH,
                    u0,
                    v0,
                    u1,
                    v1);
            } else {
                width = (MON_SPRITE_SLOT_SIZE * monSpriteMan->sprites[i].transforms.scaleX) >> MON_AFFINE_SHIFT;
                height = (MON_SPRITE_SLOT_SIZE * monSpriteMan->sprites[i].transforms.scaleY) >> MON_AFFINE_SHIFT;
                u0 = sMonSpriteTextureCoords[i][monSpriteMan->sprites[i].currSpriteFrame][0];
                u1 = sMonSpriteTextureCoords[i][monSpriteMan->sprites[i].currSpriteFrame][2];
                v0 = sMonSpriteTextureCoords[i][monSpriteMan->sprites[i].currSpriteFrame][1];
                v1 = sMonSpriteTextureCoords[i][monSpriteMan->sprites[i].currSpriteFrame][3];

                NNS_G2dDrawSpriteFast(
                    monSpriteMan->sprites[i].transforms.xCenter - width / 2 + monSpriteMan->sprites[i].transforms.xOffset,
                    monSpriteMan->sprites[i].transforms.yCenter - height / 2 + monSpriteMan->sprites[i].transforms.yOffset - monSpriteMan->sprites[i].shadow.height,
                    monSpriteMan->sprites[i].transforms.zCenter + monSpriteMan->sprites[i].transforms.zOffset,
                    width,
                    height,
                    u0,
                    v0,
                    u1,
                    v1);
            }

            if (monSpriteMan->sprites[i].shadow.plttSlot
                && monSpriteMan->sprites[i].shadow.size != SHADOW_SIZE_NONE
                && monSpriteMan->sprites[i].transforms.partialDraw == FALSE
                && (monSpriteMan->hideShadows & 1) == 0) {

                if (monSpriteMan->excludeIdentity != TRUE) {
                    G3_Identity();
                }

                G3_TexPlttBase(monSpriteMan->plttBaseAddr + PLTT_OFFSET(MON_SHADOW_BASE_PLTT_SLOT + monSpriteMan->sprites[i].shadow.plttSlot), monSpriteMan->imageProxy.attr.fmt);

                if (monSpriteMan->sprites[i].shadow.isAffine) {
                    width = (SHADOW_SPRITE_FRAME_WIDTH * monSpriteMan->sprites[i].transforms.scaleX) >> MON_AFFINE_SHIFT;
                    height = (SHADOW_SPRITE_FRAME_HEIGHT * monSpriteMan->sprites[i].transforms.scaleY) >> MON_AFFINE_SHIFT;
                } else {
                    width = SHADOW_SPRITE_FRAME_WIDTH;
                    height = SHADOW_SPRITE_FRAME_HEIGHT;
                }

                if (monSpriteMan->sprites[i].shadow.shouldFollowX) {
                    monSpriteMan->sprites[i].shadow.x = monSpriteMan->sprites[i].transforms.xCenter + monSpriteMan->sprites[i].transforms.xOffset + monSpriteMan->sprites[i].shadow.xOffset;
                }

                if (monSpriteMan->sprites[i].shadow.shouldFollowY) {
                    monSpriteMan->sprites[i].shadow.y = monSpriteMan->sprites[i].transforms.yCenter + monSpriteMan->sprites[i].transforms.yOffset + monSpriteMan->sprites[i].shadow.yOffset;
                }

                u0 = sShadowTextureCoords[monSpriteMan->sprites[i].shadow.size][0];
                v0 = sShadowTextureCoords[monSpriteMan->sprites[i].shadow.size][1];
                u1 = sShadowTextureCoords[monSpriteMan->sprites[i].shadow.size][2];
                v1 = sShadowTextureCoords[monSpriteMan->sprites[i].shadow.size][3];

                NNS_G2dDrawSpriteFast(monSpriteMan->sprites[i].shadow.x - width / 2, monSpriteMan->sprites[i].shadow.y - height / 2, -1000, width, height, u0, v0, u1, v1);
            }
        }
    }

    G3_PopMtx(1);
}

void PokemonSpriteManager_Free(PokemonSpriteManager *monSpriteMan)
{
    Heap_Free(monSpriteMan->charRawData);
    Heap_Free(monSpriteMan->plttRawData);
    Heap_Free(monSpriteMan->plttRawDataUnfaded);
    Heap_Free(monSpriteMan);
}

void PokemonSprite_InitAnim(PokemonSprite *monSprite, int dummy)
{
    monSprite->currAnimFrame = 0;

    for (int i = 0; i < MAX_ANIMATION_FRAMES; i++) {
        monSprite->animLoopTimers[i] = 0;
    }

    if (monSprite->animFrames[monSprite->currAnimFrame].spriteFrame == -1) {
        monSprite->currSpriteFrame = 0;
    } else {
        monSprite->animActive = TRUE;
        monSprite->currSpriteFrame = monSprite->animFrames[monSprite->currAnimFrame].spriteFrame;
        monSprite->animFrameDelay = monSprite->animFrames[monSprite->currAnimFrame].frameDelay;
        monSprite->transforms.xOffset = monSprite->animFrames[monSprite->currAnimFrame].xOffset;
    }
}

void PokemonSprite_SetAnimFrames(PokemonSprite *monSprite, SpriteAnimFrame *animFrames)
{
    MI_CpuCopy8(animFrames, &monSprite->animFrames, sizeof(SpriteAnimFrame) * MAX_ANIMATION_FRAMES);
}

BOOL PokemonSprite_IsAnimActive(PokemonSprite *monSprite)
{
    // Doesn't match when simplified.
    return monSprite->animActive != FALSE;
}

PokemonSprite *PokemonSpriteManager_CreateSprite(PokemonSpriteManager *monSpriteMan, PokemonSpriteTemplate *spriteTemplate, int x, int y, int z, int polygonID, SpriteAnimFrame *animFrames, PokemonSpriteCallback *callback)
{
    int i;
    for (i = 0; i < monSpriteMan->numSlots; i++) {
        if (monSpriteMan->sprites[i].active == FALSE) {
            break;
        }
    }

    GF_ASSERT(i != monSpriteMan->numSlots);

    return PokemonSpriteManager_CreateSpriteAtIndex(monSpriteMan, spriteTemplate, x, y, z, polygonID, i, animFrames, callback);
}

PokemonSprite *PokemonSpriteManager_CreateSpriteAtIndex(PokemonSpriteManager *monSpriteMan, PokemonSpriteTemplate *spriteTemplate, int x, int y, int z, int polygonID, int index, SpriteAnimFrame *animFrames, PokemonSpriteCallback *callback)
{
    GF_ASSERT(index < monSpriteMan->numSlots);
    GF_ASSERT(monSpriteMan->sprites[index].active == FALSE);

    MI_CpuClearFast(&monSpriteMan->sprites[index], sizeof(PokemonSprite));

    monSpriteMan->sprites[index].active = TRUE;
    monSpriteMan->sprites[index].needReloadChar = TRUE;
    monSpriteMan->sprites[index].needReloadPltt = TRUE;
    monSpriteMan->sprites[index].polygonID = polygonID;
    monSpriteMan->sprites[index].template = *spriteTemplate;
    monSpriteMan->sprites[index].templateBackup = *spriteTemplate;
    monSpriteMan->sprites[index].transforms.xCenter = x;
    monSpriteMan->sprites[index].transforms.yCenter = y;
    monSpriteMan->sprites[index].transforms.zCenter = z;
    monSpriteMan->sprites[index].transforms.scaleX = MON_AFFINE_SCALE(1);
    monSpriteMan->sprites[index].transforms.scaleY = MON_AFFINE_SCALE(1);
    monSpriteMan->sprites[index].transforms.alpha = 31;
    monSpriteMan->sprites[index].transforms.diffuseR = 31;
    monSpriteMan->sprites[index].transforms.diffuseG = 31;
    monSpriteMan->sprites[index].transforms.diffuseB = 31;
    monSpriteMan->sprites[index].transforms.ambientR = 16;
    monSpriteMan->sprites[index].transforms.ambientG = 16;
    monSpriteMan->sprites[index].transforms.ambientB = 16;
    monSpriteMan->sprites[index].callback = callback;
    monSpriteMan->sprites[index].shadow.x = x;
    monSpriteMan->sprites[index].shadow.y = y;
    monSpriteMan->sprites[index].shadow.shouldFollowX = TRUE;
    monSpriteMan->sprites[index].shadow.shouldFollowY = TRUE;
    monSpriteMan->sprites[index].shadow.isAffine = TRUE;

    if (animFrames != NULL) {
        MI_CpuCopy8(animFrames, &monSpriteMan->sprites[index].animFrames, sizeof(SpriteAnimFrame) * MAX_ANIMATION_FRAMES);
    }

    return &monSpriteMan->sprites[index];
}

void PokemonSprite_Delete(PokemonSprite *monSprite)
{
    monSprite->active = FALSE;
}

void PokemonSpriteManager_DeleteAll(PokemonSpriteManager *monSpriteMan)
{
    for (int i = 0; i < MAX_MON_SPRITES; i++) {
        PokemonSprite_Delete(&monSpriteMan->sprites[i]);
    }
}

void PokemonSprite_SetAttribute(PokemonSprite *monSprite, enum PokemonSpriteAttribute attribute, int value)
{
    switch (attribute) {
    case MON_SPRITE_X_CENTER:
        monSprite->transforms.xCenter = value;
        break;
    case MON_SPRITE_Y_CENTER:
        monSprite->transforms.yCenter = value;
        break;
    case MON_SPRITE_Z_CENTER:
        monSprite->transforms.zCenter = value;
        break;
    case MON_SPRITE_X_OFFSET:
        monSprite->transforms.xOffset = value;
        break;
    case MON_SPRITE_Y_OFFSET:
        monSprite->transforms.yOffset = value;
        break;
    case MON_SPRITE_Z_OFFSET:
        monSprite->transforms.zOffset = value;
        break;
    case MON_SPRITE_HIDE:
        monSprite->transforms.hide = value;
        break;
    case MON_SPRITE_ROTATION_X:
        monSprite->transforms.rotationX = value;
        break;
    case MON_SPRITE_ROTATION_Y:
        monSprite->transforms.rotationY = value;
        break;
    case MON_SPRITE_ROTATION_Z:
        monSprite->transforms.rotationZ = value;
        break;
    case MON_SPRITE_X_PIVOT:
        monSprite->transforms.xPivot = value;
        break;
    case MON_SPRITE_Y_PIVOT:
        monSprite->transforms.yPivot = value;
        break;
    case MON_SPRITE_SCALE_X:
        monSprite->transforms.scaleX = value;
        break;
    case MON_SPRITE_SCALE_Y:
        monSprite->transforms.scaleY = value;
        break;
    case MON_SPRITE_PARTIAL_DRAW:
        monSprite->transforms.partialDraw = value;
        break;
    case MON_SPRITE_DRAW_X_OFFSET:
        monSprite->transforms.drawXOffset = value;
        break;
    case MON_SPRITE_DRAW_Y_OFFSET:
        monSprite->transforms.drawYOffset = value;
        break;
    case MON_SPRITE_DRAW_WIDTH:
        monSprite->transforms.drawWidth = value;
        break;
    case MON_SPRITE_DRAW_HEIGHT:
        monSprite->transforms.drawHeight = value;
        break;
    case MON_SPRITE_SHADOW_X:
        monSprite->shadow.x = value;
        break;
    case MON_SPRITE_SHADOW_Y:
        monSprite->shadow.y = value;
        break;
    case MON_SPRITE_SHADOW_X_OFFSET:
        monSprite->shadow.xOffset = value;
        break;
    case MON_SPRITE_SHADOW_Y_OFFSET:
        monSprite->shadow.yOffset = value;
        break;
    case MON_SPRITE_ALPHA:
        monSprite->transforms.alpha = value;
        break;
    case MON_SPRITE_DIFFUSE_R:
        monSprite->transforms.diffuseR = value;
        break;
    case MON_SPRITE_DIFFUSE_G:
        monSprite->transforms.diffuseG = value;
        break;
    case MON_SPRITE_DIFFUSE_B:
        monSprite->transforms.diffuseB = value;
        break;
    case MON_SPRITE_AMBIENT_R:
        monSprite->transforms.ambientR = value;
        break;
    case MON_SPRITE_AMBIENT_G:
        monSprite->transforms.ambientG = value;
        break;
    case MON_SPRITE_AMBIENT_B:
        monSprite->transforms.ambientB = value;
        break;
    case MON_SPRITE_FADE_ACTIVE:
        monSprite->transforms.fadeActive = value;
        monSprite->needReloadPltt = TRUE;
        break;
    case MON_SPRITE_FADE_TARGET_COLOR:
        monSprite->transforms.fadeTargetColor = value;
        monSprite->needReloadPltt = TRUE;
        break;
    case MON_SPRITE_FADE_INIT_ALPHA:
        monSprite->transforms.fadeInitAlpha = value;
        monSprite->needReloadPltt = TRUE;
        break;
    case MON_SPRITE_FADE_TARGET_ALPHA:
        monSprite->transforms.fadeTargetAlpha = value;
        monSprite->needReloadPltt = TRUE;
        break;
    case MON_SPRITE_FADE_DELAY_COUNTER:
        monSprite->transforms.fadeDelayCounter = value;
        break;
    case MON_SPRITE_FLIP_H:
        monSprite->transforms.flipH = value;
        monSprite->needReloadChar = TRUE;
        break;
    case MON_SPRITE_FLIP_V:
        monSprite->transforms.flipV = value;
        monSprite->needReloadChar = TRUE;
        break;
    case MON_SPRITE_HIDE_2:
        monSprite->transforms.hide2 = value;
        break;
    case MON_SPRITE_CURR_SPRITE_FRAME:
        monSprite->currSpriteFrame = value;
        break;
    case MON_SPRITE_MOSAIC_INTENSITY:
        monSprite->transforms.mosaicIntensity = value;
        monSprite->needReloadChar = TRUE;
        break;
    case MON_SPRITE_SHADOW_HEIGHT:
        monSprite->shadow.height = value;
        break;
    case MON_SPRITE_SHADOW_PLTT_SLOT:
        monSprite->shadow.plttSlot = value;
        monSprite->needReloadPltt = TRUE;
        break;
    case MON_SPRITE_SHADOW_SHOULD_FOLLOW_X:
        monSprite->shadow.shouldFollowX = value;
        break;
    case MON_SPRITE_SHADOW_SHOULD_FOLLOW_Y:
        monSprite->shadow.shouldFollowY = value;
        break;
    case MON_SPRITE_SHADOW_IS_AFFINE:
        monSprite->shadow.isAffine = value;
        break;
    case MON_SPRITE_SHADOW_SIZE:
        monSprite->shadow.size = value;
        break;
    default:
        break;
    }
}

int PokemonSprite_GetAttribute(PokemonSprite *monSprite, enum PokemonSpriteAttribute attribute)
{
    switch (attribute) {
    case MON_SPRITE_X_CENTER:
        return monSprite->transforms.xCenter;
    case MON_SPRITE_Y_CENTER:
        return monSprite->transforms.yCenter;
    case MON_SPRITE_Z_CENTER:
        return monSprite->transforms.zCenter;
    case MON_SPRITE_X_OFFSET:
        return monSprite->transforms.xOffset;
    case MON_SPRITE_Y_OFFSET:
        return monSprite->transforms.yOffset;
    case MON_SPRITE_Z_OFFSET:
        return monSprite->transforms.zOffset;
    case MON_SPRITE_HIDE:
        return monSprite->transforms.hide;
    case MON_SPRITE_ROTATION_X:
        return monSprite->transforms.rotationX;
    case MON_SPRITE_ROTATION_Y:
        return monSprite->transforms.rotationY;
    case MON_SPRITE_ROTATION_Z:
        return monSprite->transforms.rotationZ;
    case MON_SPRITE_X_PIVOT:
        return monSprite->transforms.xPivot;
    case MON_SPRITE_Y_PIVOT:
        return monSprite->transforms.yPivot;
    case MON_SPRITE_SCALE_X:
        return monSprite->transforms.scaleX;
    case MON_SPRITE_SCALE_Y:
        return monSprite->transforms.scaleY;
    case MON_SPRITE_PARTIAL_DRAW:
        return monSprite->transforms.partialDraw;
    case MON_SPRITE_DRAW_X_OFFSET:
        return monSprite->transforms.drawXOffset;
    case MON_SPRITE_DRAW_Y_OFFSET:
        return monSprite->transforms.drawYOffset;
    case MON_SPRITE_DRAW_WIDTH:
        return monSprite->transforms.drawWidth;
    case MON_SPRITE_DRAW_HEIGHT:
        return monSprite->transforms.drawHeight;
    case MON_SPRITE_SHADOW_X:
        return monSprite->shadow.x;
    case MON_SPRITE_SHADOW_Y:
        return monSprite->shadow.y;
    case MON_SPRITE_SHADOW_X_OFFSET:
        return monSprite->shadow.xOffset;
    case MON_SPRITE_SHADOW_Y_OFFSET:
        return monSprite->shadow.yOffset;
    case MON_SPRITE_ALPHA:
        return monSprite->transforms.alpha;
    case MON_SPRITE_DIFFUSE_R:
        return monSprite->transforms.diffuseR;
    case MON_SPRITE_DIFFUSE_G:
        return monSprite->transforms.diffuseG;
    case MON_SPRITE_DIFFUSE_B:
        return monSprite->transforms.diffuseB;
    case MON_SPRITE_AMBIENT_R:
        return monSprite->transforms.ambientR;
    case MON_SPRITE_AMBIENT_G:
        return monSprite->transforms.ambientG;
    case MON_SPRITE_AMBIENT_B:
        return monSprite->transforms.ambientB;
    case MON_SPRITE_FADE_ACTIVE:
        return monSprite->transforms.fadeActive;
    case MON_SPRITE_FADE_TARGET_COLOR:
        return monSprite->transforms.fadeTargetColor;
    case MON_SPRITE_FADE_INIT_ALPHA:
        return monSprite->transforms.fadeInitAlpha;
    case MON_SPRITE_FADE_TARGET_ALPHA:
        return monSprite->transforms.fadeTargetAlpha;
    case MON_SPRITE_FADE_DELAY_COUNTER:
        return monSprite->transforms.fadeDelayCounter;
    case MON_SPRITE_FLIP_H:
        return monSprite->transforms.flipH;
    case MON_SPRITE_FLIP_V:
        return monSprite->transforms.flipV;
    case MON_SPRITE_HIDE_2:
        return monSprite->transforms.hide2;
    case MON_SPRITE_CURR_SPRITE_FRAME:
        return monSprite->currSpriteFrame;
    case MON_SPRITE_MOSAIC_INTENSITY:
        return monSprite->transforms.mosaicIntensity;
    case MON_SPRITE_SHADOW_HEIGHT:
        return monSprite->shadow.height;
    case MON_SPRITE_SHADOW_PLTT_SLOT:
        return monSprite->shadow.plttSlot;
    case MON_SPRITE_SHADOW_SHOULD_FOLLOW_X:
        return monSprite->shadow.shouldFollowX;
    case MON_SPRITE_SHADOW_SHOULD_FOLLOW_Y:
        return monSprite->shadow.shouldFollowY;
    case MON_SPRITE_SHADOW_IS_AFFINE:
        return monSprite->shadow.isAffine;
    case MON_SPRITE_SHADOW_SIZE:
        return monSprite->shadow.size;
    default:
        break;
    }

    GF_ASSERT(FALSE);
    return 0;
}

void PokemonSprite_AddAttribute(PokemonSprite *monSprite, enum PokemonSpriteAttribute attribute, int delta)
{
    switch (attribute) {
    case MON_SPRITE_X_CENTER:
        monSprite->transforms.xCenter += delta;
        break;
    case MON_SPRITE_Y_CENTER:
        monSprite->transforms.yCenter += delta;
        break;
    case MON_SPRITE_Z_CENTER:
        monSprite->transforms.zCenter += delta;
        break;
    case MON_SPRITE_X_OFFSET:
        monSprite->transforms.xOffset += delta;
        break;
    case MON_SPRITE_Y_OFFSET:
        monSprite->transforms.yOffset += delta;
        break;
    case MON_SPRITE_Z_OFFSET:
        monSprite->transforms.zOffset += delta;
        break;
    case MON_SPRITE_HIDE:
        monSprite->transforms.hide += delta;
        break;
    case MON_SPRITE_ROTATION_X:
        monSprite->transforms.rotationX += delta;
        break;
    case MON_SPRITE_ROTATION_Y:
        monSprite->transforms.rotationY += delta;
        break;
    case MON_SPRITE_ROTATION_Z:
        monSprite->transforms.rotationZ += delta;
        break;
    case MON_SPRITE_X_PIVOT:
        monSprite->transforms.xPivot += delta;
        break;
    case MON_SPRITE_Y_PIVOT:
        monSprite->transforms.yPivot += delta;
        break;
    case MON_SPRITE_SCALE_X:
        monSprite->transforms.scaleX += delta;
        break;
    case MON_SPRITE_SCALE_Y:
        monSprite->transforms.scaleY += delta;
        break;
    case MON_SPRITE_PARTIAL_DRAW:
        monSprite->transforms.partialDraw += delta;
        break;
    case MON_SPRITE_DRAW_X_OFFSET:
        monSprite->transforms.drawXOffset += delta;
        break;
    case MON_SPRITE_DRAW_Y_OFFSET:
        monSprite->transforms.drawYOffset += delta;
        break;
    case MON_SPRITE_DRAW_WIDTH:
        monSprite->transforms.drawWidth += delta;
        break;
    case MON_SPRITE_DRAW_HEIGHT:
        monSprite->transforms.drawHeight += delta;
        break;
    case MON_SPRITE_SHADOW_X:
        monSprite->shadow.x += delta;
        break;
    case MON_SPRITE_SHADOW_Y:
        monSprite->shadow.y += delta;
        break;
    case MON_SPRITE_SHADOW_X_OFFSET:
        monSprite->shadow.xOffset += delta;
        break;
    case MON_SPRITE_SHADOW_Y_OFFSET:
        monSprite->shadow.yOffset += delta;
        break;
    case MON_SPRITE_ALPHA:
        monSprite->transforms.alpha += delta;
        break;
    case MON_SPRITE_DIFFUSE_R:
        monSprite->transforms.diffuseR += delta;
        break;
    case MON_SPRITE_DIFFUSE_G:
        monSprite->transforms.diffuseG += delta;
        break;
    case MON_SPRITE_DIFFUSE_B:
        monSprite->transforms.diffuseB += delta;
        break;
    case MON_SPRITE_AMBIENT_R:
        monSprite->transforms.ambientR += delta;
        break;
    case MON_SPRITE_AMBIENT_G:
        monSprite->transforms.ambientG += delta;
        break;
    case MON_SPRITE_AMBIENT_B:
        monSprite->transforms.ambientB += delta;
        break;
    case MON_SPRITE_FADE_ACTIVE:
        monSprite->transforms.fadeActive += delta;
        monSprite->needReloadPltt = TRUE;
        break;
    case MON_SPRITE_FADE_TARGET_COLOR:
        monSprite->transforms.fadeTargetColor += delta;
        monSprite->needReloadPltt = TRUE;
        break;
    case MON_SPRITE_FADE_INIT_ALPHA:
        monSprite->transforms.fadeInitAlpha += delta;
        monSprite->needReloadPltt = TRUE;
        break;
    case MON_SPRITE_FADE_TARGET_ALPHA:
        monSprite->transforms.fadeTargetAlpha += delta;
        monSprite->needReloadPltt = TRUE;
        break;
    case MON_SPRITE_FADE_DELAY_COUNTER:
        monSprite->transforms.fadeDelayCounter += delta;
        break;
    case MON_SPRITE_FLIP_H:
        monSprite->transforms.flipH += delta;
        monSprite->needReloadChar = TRUE;
        break;
    case MON_SPRITE_FLIP_V:
        monSprite->transforms.flipV += delta;
        monSprite->needReloadChar = TRUE;
        break;
    case MON_SPRITE_HIDE_2:
        monSprite->transforms.hide2 += delta;
        break;
    case MON_SPRITE_CURR_SPRITE_FRAME:
        monSprite->currSpriteFrame += delta;
        break;
    case MON_SPRITE_MOSAIC_INTENSITY:
        monSprite->transforms.mosaicIntensity += delta;
        monSprite->needReloadChar = TRUE;
        break;
    case MON_SPRITE_SHADOW_HEIGHT:
        monSprite->shadow.height += delta;
        break;
    case MON_SPRITE_SHADOW_PLTT_SLOT:
        monSprite->shadow.plttSlot += delta;
        monSprite->needReloadPltt = TRUE;
        break;
    case MON_SPRITE_SHADOW_SHOULD_FOLLOW_X:
        monSprite->shadow.shouldFollowX += delta;
        break;
    case MON_SPRITE_SHADOW_SHOULD_FOLLOW_Y:
        monSprite->shadow.shouldFollowY += delta;
        break;
    case MON_SPRITE_SHADOW_IS_AFFINE:
        monSprite->shadow.isAffine += delta;
        break;
    case MON_SPRITE_SHADOW_SIZE:
        monSprite->shadow.size += delta;
        break;
    default:
        break;
    }
}

void PokemonSprite_SetPartialDraw(PokemonSprite *monSprite, int xOffset, int yOffset, int width, int height)
{
    monSprite->transforms.partialDraw = TRUE;
    monSprite->transforms.drawXOffset = xOffset;
    monSprite->transforms.drawYOffset = yOffset;
    monSprite->transforms.drawWidth = width;
    monSprite->transforms.drawHeight = height;
}

void PokemonSprite_ClipToFrame(PokemonSprite *monSprite, int frameY)
{
    monSprite->transforms.clipToFrame = TRUE;
    monSprite->transforms.clipFrameY = frameY;
}

void PokemonSprite_StartFade(PokemonSprite *monSprite, int initAlpha, int targetAlpha, int delay, int color)
{
    monSprite->transforms.fadeActive = TRUE;
    monSprite->transforms.fadeInitAlpha = initAlpha;
    monSprite->transforms.fadeTargetAlpha = targetAlpha;
    monSprite->transforms.fadeDelayCounter = 0;
    monSprite->transforms.fadeDelayLength = delay;
    monSprite->transforms.fadeTargetColor = color;
}

void PokemonSpriteManager_StartFadeAll(PokemonSpriteManager *monSpriteMan, int initAlpha, int targetAlpha, int delay, int color)
{
    for (int i = 0; i < MAX_MON_SPRITES; i++) {
        if (monSpriteMan->sprites[i].active) {
            monSpriteMan->sprites[i].transforms.fadeActive = TRUE;
            monSpriteMan->sprites[i].transforms.fadeInitAlpha = initAlpha;
            monSpriteMan->sprites[i].transforms.fadeTargetAlpha = targetAlpha;
            monSpriteMan->sprites[i].transforms.fadeDelayCounter = 0;
            monSpriteMan->sprites[i].transforms.fadeDelayLength = delay;
            monSpriteMan->sprites[i].transforms.fadeTargetColor = color;
        }
    }
}

void PokemonSprite_ClearFade(PokemonSprite *monSprite)
{
    monSprite->transforms.fadeActive = FALSE;
    monSprite->transforms.fadeInitAlpha = 0;
    monSprite->transforms.fadeTargetAlpha = 0;
    monSprite->transforms.fadeDelayCounter = 0;
    monSprite->transforms.fadeDelayLength = 0;
    monSprite->transforms.fadeTargetColor = 0;
    monSprite->needReloadPltt = TRUE;
}

BOOL PokemonSprite_IsFadeActive(PokemonSprite *monSprite)
{
    return monSprite->transforms.fadeActive == TRUE;
}

void PokemonSprite_CalcScaledYOffset(PokemonSprite *monSprite, int height)
{
    monSprite->transforms.yOffset = ((MON_SPRITE_HEIGHT / 2) - height) - ((((MON_SPRITE_HEIGHT / 2) - height) * monSprite->transforms.scaleY) >> 8);
}

static inline void TickPokemonSpriteTaskAnim(u8 *active, u8 *currSpriteFrame, u8 *currAnimFrame, u8 *frameDelay, u8 *loopTimers, const SpriteAnimFrame *animFrames)
{
    if (*active) {
        if (*frameDelay == 0) {
            (*currAnimFrame)++;

            while (animFrames[*currAnimFrame].spriteFrame < -1) {
                loopTimers[*currAnimFrame]++;

                if (animFrames[*currAnimFrame].frameDelay == loopTimers[*currAnimFrame] || animFrames[*currAnimFrame].frameDelay == 0) {
                    loopTimers[*currAnimFrame] = 0;
                    (void)*currAnimFrame++;
                } else {
                    *currAnimFrame = animFrames[*currAnimFrame].spriteFrame * -1 - 2;
                }
            }

            if (animFrames[*currAnimFrame].spriteFrame == -1 || *currAnimFrame >= MAX_ANIMATION_FRAMES) {
                *currSpriteFrame = 0;
                *active = FALSE;
                return;
            }

            *currSpriteFrame = animFrames[*currAnimFrame].spriteFrame;
            *frameDelay = animFrames[*currAnimFrame].frameDelay;
        } else {
            (*frameDelay)--;
        }
    }
}

static void TickPokemonSpriteAnim(PokemonSprite *monSprite)
{
    if (monSprite->animActive) {
        if (monSprite->animFrameDelay == 0) {
            monSprite->currAnimFrame++;

            while (monSprite->animFrames[monSprite->currAnimFrame].spriteFrame < -1) {
                monSprite->animLoopTimers[monSprite->currAnimFrame]++;

                if (monSprite->animFrames[monSprite->currAnimFrame].frameDelay == monSprite->animLoopTimers[monSprite->currAnimFrame]
                    || monSprite->animFrames[monSprite->currAnimFrame].frameDelay == 0) {
                    monSprite->animLoopTimers[monSprite->currAnimFrame] = 0;
                    monSprite->currAnimFrame++;
                } else {
                    monSprite->currAnimFrame = (monSprite->animFrames[monSprite->currAnimFrame].spriteFrame * -1) - 2;
                }
            }

            if (monSprite->currAnimFrame >= MAX_ANIMATION_FRAMES || monSprite->animFrames[monSprite->currAnimFrame].spriteFrame == -1) {
                monSprite->currSpriteFrame = 0;
                monSprite->animActive = FALSE;
                monSprite->transforms.xOffset = 0;

                return;
            }

            monSprite->currSpriteFrame = monSprite->animFrames[monSprite->currAnimFrame].spriteFrame;
            monSprite->animFrameDelay = monSprite->animFrames[monSprite->currAnimFrame].frameDelay;
            monSprite->transforms.xOffset = monSprite->animFrames[monSprite->currAnimFrame].xOffset;
        } else {
            monSprite->animFrameDelay--;
        }
    }
}

static void PokemonSprite_TickAnim(PokemonSprite *monSprite)
{
    TickPokemonSpriteAnim(monSprite);
}

void PokemonSpriteTaskAnim_Init(PokemonSpriteTaskAnim *anim, const SpriteAnimFrame *animFrames)
{
    anim->active = TRUE;
    anim->currAnimFrame = 0;
    anim->currSpriteFrame = animFrames[0].spriteFrame;
    anim->frameDelay = animFrames[0].frameDelay;
    anim->animFrames = animFrames;

    for (int i = 0; i < MAX_ANIMATION_FRAMES; i++) {
        anim->loopTimers[i] = 0;
    }
}

int PokemonSpriteTaskAnim_Tick(PokemonSpriteTaskAnim *anim)
{
    if (anim->active) {
        TickPokemonSpriteTaskAnim(&anim->active, &anim->currSpriteFrame, &anim->currAnimFrame, &anim->frameDelay, anim->loopTimers, anim->animFrames);
        return anim->currSpriteFrame;
    }

    return -1;
}

void PokemonSprite_ScheduleReloadFromNARC(PokemonSprite *monSprite)
{
    monSprite->needReloadChar = TRUE;
    monSprite->needReloadPltt = TRUE;
}

void PokemonSprite_Push(PokemonSprite *monSprite)
{
    monSprite->templateBackup = monSprite->template;
    monSprite->shadowBackup = monSprite->shadow;
}

void PokemonSprite_Pop(PokemonSprite *monSprite)
{
    monSprite->template = monSprite->templateBackup;
    monSprite->shadow = monSprite->shadowBackup;
    monSprite->needReloadChar = TRUE;
    monSprite->needReloadPltt = TRUE;
}

void PokemonSpriteManager_SetCharBaseAddrAndSize(PokemonSpriteManager *monSpriteMan, u32 addr, u32 size)
{
    monSpriteMan->charBaseAddr = addr;
    monSpriteMan->charSize = size;
}

void PokemonSpriteManager_SetPlttBaseAddrAndSize(PokemonSpriteManager *monSpriteMan, u32 addr, u32 size)
{
    monSpriteMan->plttBaseAddr = addr;
    monSpriteMan->plttSize = size;
}

PokemonSpriteTemplate *PokemonSprite_GetTemplate(PokemonSprite *monSprite)
{
    return &monSprite->template;
}

void PokemonSpriteManager_UpdateCharAndPltt(PokemonSpriteManager *monSpriteMan)
{
    if (monSpriteMan->needLoadChar) {
        monSpriteMan->needLoadChar = FALSE;

        NNS_G2dInitImageProxy(&monSpriteMan->imageProxy);

        // NitroSystem sizes a texture up to 256 rows, so the texture is declared 512 rows tall here; only charSize bytes
        // (the rows in use) are loaded.
        monSpriteMan->charData.H = MON_SPRITE_CHAR_BUF_TILES_W;
        monSpriteMan->charData.W = MON_SPRITE_CHAR_BUF_TILES_W;
        monSpriteMan->charData.szByte = monSpriteMan->charSize;
        monSpriteMan->charData.pRawData = monSpriteMan->charRawData;

        NNS_G2dLoadImage2DMapping(&monSpriteMan->charData, monSpriteMan->charBaseAddr, NNS_G2D_VRAM_TYPE_3DMAIN, &monSpriteMan->imageProxy);
        monSpriteMan->imageProxy.attr.sizeT = GX_TEXSIZE_T512;
    }

    if (monSpriteMan->needLoadPltt) {
        monSpriteMan->needLoadPltt = FALSE;

        NNS_G2dInitImagePaletteProxy(&monSpriteMan->plttProxy);

        monSpriteMan->plttData.szByte = monSpriteMan->plttSize;
        monSpriteMan->plttData.pRawData = monSpriteMan->plttRawData;

        NNS_G2dLoadPalette(&monSpriteMan->plttData, monSpriteMan->plttBaseAddr, NNS_G2D_VRAM_TYPE_3DMAIN, &monSpriteMan->plttProxy);
    }
}

void PokemonSpriteManager_SetExcludeIdentity(PokemonSpriteManager *monSpriteMan, int value)
{
    monSpriteMan->excludeIdentity = value;
}

BOOL PokemonSprite_IsActive(PokemonSprite *monSprite)
{
    GF_ASSERT(monSprite != NULL);
    return monSprite->active != FALSE;
}

void PokemonSpriteManager_SetHideShadows(PokemonSpriteManager *monSpriteMan, u32 value)
{
    monSpriteMan->hideShadows |= value;
}

void PokemonSpriteManager_ClearHideShadows(PokemonSpriteManager *monSpriteMan, u32 value)
{
    monSpriteMan->hideShadows &= (value ^ -1);
}

// Sovereign: one side of a partial draw (offset and length in the 80x80 box): an end on the box's edge moves out to the
// edge of the 96x96 slot. A partial draw that would show nothing still shows nothing.
// Sovereign: a scale of 1, flipped or not (PokemonSprite_ClipToFrame clips only such a sprite).
static BOOL IsUnscaled(int scale)
{
    return scale == MON_AFFINE_SCALE(1) || scale == -MON_AFFINE_SCALE(1);
}

static void PokemonSprite_WidenPartialDraw(int *offset, int *length)
{
    int start = *offset;
    int end = *offset + *length;

    if (*length <= 0) {
        return;
    }

    if (start <= 0) {
        start = -MON_SPRITE_SLOT_MARGIN;
    }

    if (end >= MON_SPRITE_FRAME_WIDTH) {
        end = MON_SPRITE_FRAME_WIDTH + MON_SPRITE_SLOT_MARGIN;
    }

    *offset = start;
    *length = end - start;
}

// Copies a sprite's two frames (an 80x80 or 96x96 pair, its width and height in pixels) into its slot, centred,
// flipped or with mosaic as its transforms say.
static void CopySpriteToSlot(u8 *slotData, const u8 *rawCharData, int width, int height, const PokemonSpriteTransforms *transforms)
{
    int frameBytes = width / NUM_MON_SPRITE_FRAMES_H / 2;
    int srcStride = width / 2;
    int marginX = (MON_SPRITE_SLOT_SIZE - width / NUM_MON_SPRITE_FRAMES_H) / 4;
    int marginY = (MON_SPRITE_SLOT_SIZE - height) / 2;
    int mosaic = transforms->mosaicIntensity;

    for (int y = 0; y < MON_SPRITE_SLOT_SIZE; y++) {
        MI_CpuClear8(&slotData[y * MAN_Y_OFFSET], MON_SPRITE_SLOT_SIZE * NUM_MON_SPRITE_FRAMES_H / 2);
    }

    for (int frame = 0; frame < NUM_MON_SPRITE_FRAMES_H; frame++) {
        u8 *dest = &slotData[marginY * MAN_Y_OFFSET + frame * MON_SPRITE_SLOT_SIZE / 2 + marginX];
        const u8 *src = &rawCharData[frame * frameBytes];

        for (int y = 0; y < height; y++) {
            int srcY = transforms->flipV ? height - 1 - y : y;

            for (int x = 0; x < frameBytes; x++) {
                if (transforms->flipH) {
                    dest[y * MAN_Y_OFFSET + x] = SwapNybbles(src[srcY * srcStride + frameBytes - 1 - x]);
                } else if (transforms->flipV) {
                    dest[y * MAN_Y_OFFSET + x] = src[srcY * srcStride + x];
                } else if (mosaic) {
                    if (y % (mosaic * 2)) {
                        dest[y * MAN_Y_OFFSET + x] = dest[(y - 1) * MAN_Y_OFFSET + x];
                    } else if (x % mosaic) {
                        dest[y * MAN_Y_OFFSET + x] = dest[y * MAN_Y_OFFSET + x - 1];
                    } else {
                        dest[y * MAN_Y_OFFSET + x] = (src[y * srcStride + x] & 0xF) | (src[y * srcStride + x] & 0xF) << 4;
                    }
                } else {
                    dest[y * MAN_Y_OFFSET + x] = src[y * srcStride + x];
                }
            }
        }
    }
}

static void BufferPokemonSpriteCharData(PokemonSpriteManager *monSpriteMan)
{
    NNSG2dCharacterData *charData;
    u8 *rawCharData;
    void *ncgrFile;
    u8 needLoadChar = FALSE;

    for (int i = 0; i < MAX_MON_SPRITES; i++) {
        if (monSpriteMan->sprites[i].active && monSpriteMan->sprites[i].needReloadChar) {
            monSpriteMan->sprites[i].needReloadChar = FALSE;

            needLoadChar = TRUE;
            ncgrFile = NARC_AllocAndReadWholeMemberByIndexPair(monSpriteMan->sprites[i].template.narcID, monSpriteMan->sprites[i].template.character, monSpriteMan->heapID);

            NNS_G2dGetUnpackedCharacterData(ncgrFile, &charData);

            monSpriteMan->charData.pixelFmt = charData->pixelFmt;
            monSpriteMan->charData.mappingType = charData->mappingType;
            monSpriteMan->charData.characterFmt = charData->characterFmt;

            rawCharData = charData->pRawData;

            PokemonSprite_DecryptSized(rawCharData, monSpriteMan->sprites[i].template.narcID, charData->szByte);
            TryDrawSpindaSpots(&monSpriteMan->sprites[i], rawCharData);
            CopySpriteToSlot(&monSpriteMan->charRawData[i * MAN_SLOT_CHAR_OFFSET], rawCharData, charData->W * TILE_WIDTH_PIXELS, charData->H * TILE_HEIGHT_PIXELS, &monSpriteMan->sprites[i].transforms);

            Heap_Free(ncgrFile);
        }
    }

    monSpriteMan->needLoadChar = needLoadChar;
}

static void BufferPokemonSpritePlttData(PokemonSpriteManager *monSpriteMan)
{
    NNSG2dPaletteData *plttData;
    int i, j;
    u16 *rawPlttData;
    void *nclrFile;
    u8 needReloadPltt = FALSE;

    for (i = 0; i < MAX_MON_SPRITES; i++) {
        if (monSpriteMan->sprites[i].active && monSpriteMan->sprites[i].needReloadPltt) {
            monSpriteMan->sprites[i].needReloadPltt = FALSE;

            needReloadPltt = TRUE;
            nclrFile = NARC_AllocAndReadWholeMemberByIndexPair(monSpriteMan->sprites[i].template.narcID, monSpriteMan->sprites[i].template.palette, monSpriteMan->heapID);

            NNS_G2dGetUnpackedPaletteData(nclrFile, &plttData);

            monSpriteMan->plttData.fmt = plttData->fmt;
            rawPlttData = plttData->pRawData;

            for (j = 0; j < PALETTE_SIZE; j++) {
                monSpriteMan->plttRawData[j + PALETTE_SIZE * i] = rawPlttData[j];
                monSpriteMan->plttRawDataUnfaded[j + PALETTE_SIZE * i] = rawPlttData[j];
            }

            Heap_Free(nclrFile);

            if (monSpriteMan->sprites[i].shadow.plttSlot) {
                nclrFile = NARC_AllocAndReadWholeMemberByIndexPair(NARC_INDEX_POKETOOL__POKEGRA__PL_OTHERPOKE, pokemon_shadows_pal_NCLR, monSpriteMan->heapID);
                NNS_G2dGetUnpackedPaletteData(nclrFile, &plttData);
                rawPlttData = plttData->pRawData;

                for (j = 0; j < PALETTE_SIZE; j++) {
                    monSpriteMan->plttRawData[j + PALETTE_SIZE * (MON_SHADOW_BASE_PLTT_SLOT + monSpriteMan->sprites[i].shadow.plttSlot)] = rawPlttData[j];
                    monSpriteMan->plttRawDataUnfaded[j + PALETTE_SIZE * (MON_SHADOW_BASE_PLTT_SLOT + monSpriteMan->sprites[i].shadow.plttSlot)] = rawPlttData[j];
                }

                Heap_Free(nclrFile);
            }
        }

        if (monSpriteMan->sprites[i].active && monSpriteMan->sprites[i].transforms.fadeActive) {
            if (monSpriteMan->sprites[i].transforms.fadeDelayCounter == 0) {
                needReloadPltt = TRUE;
                monSpriteMan->sprites[i].transforms.fadeDelayCounter = monSpriteMan->sprites[i].transforms.fadeDelayLength;

                BlendPalette(
                    &monSpriteMan->plttRawDataUnfaded[PALETTE_SIZE * i],
                    &monSpriteMan->plttRawData[PALETTE_SIZE * i],
                    PALETTE_SIZE,
                    monSpriteMan->sprites[i].transforms.fadeInitAlpha,
                    monSpriteMan->sprites[i].transforms.fadeTargetColor);

                if (monSpriteMan->sprites[i].shadow.plttSlot) {
                    BlendPalette(
                        &monSpriteMan->plttRawDataUnfaded[PALETTE_SIZE * (MON_SHADOW_BASE_PLTT_SLOT + monSpriteMan->sprites[i].shadow.plttSlot)],
                        &monSpriteMan->plttRawData[PALETTE_SIZE * (MON_SHADOW_BASE_PLTT_SLOT + monSpriteMan->sprites[i].shadow.plttSlot)],
                        PALETTE_SIZE,
                        monSpriteMan->sprites[i].transforms.fadeInitAlpha,
                        monSpriteMan->sprites[i].transforms.fadeTargetColor);
                }

                if (monSpriteMan->sprites[i].transforms.fadeInitAlpha == monSpriteMan->sprites[i].transforms.fadeTargetAlpha) {
                    monSpriteMan->sprites[i].transforms.fadeActive = FALSE;
                } else if (monSpriteMan->sprites[i].transforms.fadeInitAlpha > monSpriteMan->sprites[i].transforms.fadeTargetAlpha) {
                    monSpriteMan->sprites[i].transforms.fadeInitAlpha--;
                } else {
                    monSpriteMan->sprites[i].transforms.fadeInitAlpha++;
                }
            } else {
                monSpriteMan->sprites[i].transforms.fadeDelayCounter--;
            }
        }
    }

    monSpriteMan->needLoadPltt = needReloadPltt;
}

static u8 SwapNybbles(u8 value)
{
    u8 ret = (value & 0xF0) >> 4;
    return ret |= (value & 0x0F) << 4;
}

static void TryDrawSpindaSpots(PokemonSprite *monSprite, u8 *rawCharData)
{
    if (monSprite->template.spindaSpots != 0) {
        PokemonSprite_DrawSpindaSpots(rawCharData, monSprite->template.personality, TRUE);
    }
}

void PokemonSprite_DrawSpindaSpots(u8 *rawCharData, u32 personality, BOOL isAnimated)
{
    const SpindaSpotCoords *currSpotCoords;
    int i, destOffset;
    u8 x, y, j;
    u32 originalPersonality = personality;

    for (i = 0; i < MAX_SPINDA_SPOTS; i++) {
        currSpotCoords = sSpindaSpotCoords[i];
        j = 0;

        while (currSpotCoords[j].x != SPINDA_SPOT_COORDS_END) {
            x = currSpotCoords[j].x + ((personality & 0x0F) - 8);
            y = currSpotCoords[j].y + (((personality & 0xF0) >> 4) - 8);
            destOffset = x / 2 + y * NCGR_Y_OFFSET;

            if (x & 1) {
                if ((rawCharData[destOffset] & 0xF0) >= 0x10 && (rawCharData[destOffset] & 0xF0) <= 0x30) {
                    rawCharData[destOffset] += 0x50;
                }
            } else {
                if ((rawCharData[destOffset] & 0x0F) >= 0x01 && (rawCharData[destOffset] & 0x0F) <= 0x03) {
                    rawCharData[destOffset] += 0x05;
                }
            }

            j++;
        }

        personality >>= 8;
    }

    personality = originalPersonality;

    if (isAnimated) {
        for (i = 0; i < MAX_SPINDA_SPOTS; i++) {
            currSpotCoords = sSpindaSpotCoords[i];
            j = 0;

            while (currSpotCoords[j].x != SPINDA_SPOT_COORDS_END) {
                x = (currSpotCoords[j].x - 14) + ((personality & 0x0F) - 8) + 80;
                y = currSpotCoords[j].y + (((personality & 0xF0) >> 4) - 8);
                destOffset = x / 2 + y * NCGR_Y_OFFSET;

                if (x & 1) {
                    if ((rawCharData[destOffset] & 0xF0) >= 0x10 && (rawCharData[destOffset] & 0xF0) <= 0x30) {
                        rawCharData[destOffset] += 0x50;
                    }
                } else {
                    if ((rawCharData[destOffset] & 0x0F) >= 0x01 && (rawCharData[destOffset] & 0x0F) <= 0x03) {
                        rawCharData[destOffset] += 0x05;
                    }
                }

                j++;
            }

            personality >>= 8;
        }
    }
}

static u16 PokemonSprite_LCRNGNext(u32 *seed)
{
    *seed = *seed * LCRNG_MULTIPLIER + LCRNG_INCREMENT;
    return (u16)(*seed / LCRNG_DIVISOR);
}

// Sovereign: a sprite's whole image is scrambled (nitrogfx -encodefronttoback), whatever its size; sizeBytes is its
// pixel data's size (6400 for an 80x80 pair, 9216 for a 96x96 one).
static void PokemonSprite_DecryptPtSized(u8 *rawCharData, u32 sizeBytes)
{
    u16 *charData = (u16 *)rawCharData;
    u32 seed = *charData;

    for (int i = 0; i < sizeBytes / 2; i++) {
        charData[i] ^= seed;
        PokemonSprite_LCRNGNext(&seed);
    }
}

static void PokemonSprite_DecryptDPSized(u8 *rawCharData, u32 sizeBytes)
{
    u16 *charData = (u16 *)rawCharData;
    u32 seed = charData[sizeBytes / 2 - 1];

    for (int i = sizeBytes / 2 - 1; i > -1; i--) {
        charData[i] ^= seed;
        PokemonSprite_LCRNGNext(&seed);
    }
}

void PokemonSprite_DecryptPt(u8 *rawCharData)
{
    PokemonSprite_DecryptPtSized(rawCharData, MON_SPRITE_FRAME_MAX_SIZE_BYTES * NUM_MON_SPRITE_FRAMES_H);
}

void PokemonSprite_DecryptDP(u8 *rawCharData)
{
    PokemonSprite_DecryptDPSized(rawCharData, MON_SPRITE_FRAME_MAX_SIZE_BYTES * NUM_MON_SPRITE_FRAMES_H);
}

void PokemonSprite_Decrypt(u8 *rawCharData, enum NarcID narcID)
{
    PokemonSprite_DecryptSized(rawCharData, narcID, MON_SPRITE_FRAME_MAX_SIZE_BYTES * NUM_MON_SPRITE_FRAMES_H);
}

void PokemonSprite_DecryptSized(u8 *rawCharData, enum NarcID narcID, u32 sizeBytes)
{
    if (narcID == NARC_INDEX_POKETOOL__POKEGRA__POKEGRA || narcID == NARC_INDEX_POKETOOL__POKEGRA__OTHERPOKE) {
        PokemonSprite_DecryptDPSized(rawCharData, sizeBytes);
    } else {
        PokemonSprite_DecryptPtSized(rawCharData, sizeBytes);
    }
}
