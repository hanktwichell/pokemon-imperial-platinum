#include "imperial_options.h"

#include <nitro.h>
#include <string.h>

#include "save_player.h"
#include "savedata.h"

void ImperialOptions_Init(ImperialOptions *options)
{
    MI_CpuFill8(options, 0, sizeof(ImperialOptions));

    options->levelCap = FALSE;
    options->infiniteCandy = FALSE;
    options->partyExpShare = TRUE;
    options->musicVolume = IMPERIAL_MUSIC_VOLUME_STEPS;
}

ImperialOptions *SaveData_GetImperialOptions(SaveData *saveData)
{
    PlayerSave *state = SaveData_SaveTable(saveData, SAVE_TABLE_ENTRY_PLAYER);
    return &state->imperialOptions;
}

BOOL ImperialOptions_LevelCapEnabled(const ImperialOptions *options)
{
    return options->levelCap;
}

BOOL ImperialOptions_InfiniteCandyEnabled(const ImperialOptions *options)
{
    return options->levelCap && options->infiniteCandy;
}

BOOL ImperialOptions_PartyExpShareEnabled(const ImperialOptions *options)
{
    return options->partyExpShare;
}

u8 ImperialOptions_MusicVolumePercent(const ImperialOptions *options)
{
    return options->musicVolume * 5;
}
