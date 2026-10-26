#include "macros/scrcmd.inc"


    InitScriptEntry_OnTransition 1
    InitScriptEntry_OnFrameTable InitScriptFrameTable
    InitScriptEntryEnd

InitScriptFrameTable:
    InitScriptGoToIfEqual VAR_MAP_LOCAL_0x01, 1, 10 // Sovereign: Oak's first visit, after the Hall of Fame
    InitScriptGoToIfEqual VAR_PAL_PARK_STATE, 1, 3
    InitScriptGoToIfEqual VAR_PAL_PARK_STATE, 2, 12
    InitScriptGoToIfEqual VAR_PAL_PARK_STATE, 3, 12 // Sovereign: back from the Regional Forms Park
    InitScriptFrameTableEnd

    InitScriptEnd
