#include "macros/scrcmd.inc"


    InitScriptEntry_OnTransition 3
    InitScriptEntry_OnLoad 4
    InitScriptEntry_OnFrameTable InitScriptFrameTable
    InitScriptEntryEnd

InitScriptFrameTable:
    InitScriptGoToIfEqual VAR_EXITED_DISTORTION_WORLD_STATE, 1, 1
    InitScriptFrameTableEnd

    InitScriptEnd
