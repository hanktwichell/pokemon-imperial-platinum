#include "sovereign_options.h"

#include <nitro.h>
#include <string.h>

#include "save_player.h"
#include "savedata.h"

void SovereignOptions_Init(SovereignOptions *options)
{
    MI_CpuFill8(options, 0, sizeof(SovereignOptions));

    options->levelCap = FALSE;
    options->infiniteCandy = FALSE;
    options->partyExpShare = TRUE;
    options->musicVolume = SOVEREIGN_MUSIC_VOLUME_STEPS;
}

SovereignOptions *SaveData_GetSovereignOptions(SaveData *saveData)
{
    PlayerSave *state = SaveData_SaveTable(saveData, SAVE_TABLE_ENTRY_PLAYER);
    return &state->sovereignOptions;
}

BOOL SovereignOptions_LevelCapEnabled(const SovereignOptions *options)
{
    return options->levelCap;
}

BOOL SovereignOptions_InfiniteCandyEnabled(const SovereignOptions *options)
{
    return options->levelCap && options->infiniteCandy;
}

BOOL SovereignOptions_PartyExpShareEnabled(const SovereignOptions *options)
{
    return options->partyExpShare;
}

u8 SovereignOptions_MusicVolumePercent(const SovereignOptions *options)
{
    return options->musicVolume * 5;
}
