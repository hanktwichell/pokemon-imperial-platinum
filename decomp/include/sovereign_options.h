#ifndef POKEPLATINUM_SOVEREIGN_OPTIONS_H
#define POKEPLATINUM_SOVEREIGN_OPTIONS_H

#include "savedata.h"

// Sovereign Platinum's extra settings (Options -> SOVEREIGN page). Stored in the two bytes of
// padding that follow the vanilla Options bitfield in PlayerSave, so the save layout is unchanged.
typedef struct SovereignOptions {
    u16 levelCap : 1;
    u16 infiniteCandy : 1; // only honoured while levelCap is on
    u16 partyExpShare : 1;
    u16 musicVolume : 5; // in steps of 5%: 0..20 -> 0..100%
    u16 : 8;
} SovereignOptions;

#define SOVEREIGN_MUSIC_VOLUME_STEPS 20 // 20 steps of 5% = 100%

void SovereignOptions_Init(SovereignOptions *options);
SovereignOptions *SaveData_GetSovereignOptions(SaveData *saveData);

BOOL SovereignOptions_LevelCapEnabled(const SovereignOptions *options);
BOOL SovereignOptions_InfiniteCandyEnabled(const SovereignOptions *options);
BOOL SovereignOptions_PartyExpShareEnabled(const SovereignOptions *options);
u8 SovereignOptions_MusicVolumePercent(const SovereignOptions *options);

#endif // POKEPLATINUM_SOVEREIGN_OPTIONS_H
