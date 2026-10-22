#ifndef POKEPLATINUM_IMPERIAL_OPTIONS_H
#define POKEPLATINUM_IMPERIAL_OPTIONS_H

#include "savedata.h"

// Imperial Platinum's extra settings (Options -> IMPERIAL page). Stored in the two bytes of
// padding that follow the vanilla Options bitfield in PlayerSave, so the save layout is unchanged.
typedef struct ImperialOptions {
    u16 levelCap : 1;
    u16 infiniteCandy : 1; // only honoured while levelCap is on
    u16 partyExpShare : 1;
    u16 musicVolume : 5; // in steps of 5%: 0..20 -> 0..100%
    u16 : 8;
} ImperialOptions;

#define IMPERIAL_MUSIC_VOLUME_STEPS 20 // 20 steps of 5% = 100%

void ImperialOptions_Init(ImperialOptions *options);
ImperialOptions *SaveData_GetImperialOptions(SaveData *saveData);

BOOL ImperialOptions_LevelCapEnabled(const ImperialOptions *options);
BOOL ImperialOptions_InfiniteCandyEnabled(const ImperialOptions *options);
BOOL ImperialOptions_PartyExpShareEnabled(const ImperialOptions *options);
u8 ImperialOptions_MusicVolumePercent(const ImperialOptions *options);

#endif // POKEPLATINUM_IMPERIAL_OPTIONS_H
