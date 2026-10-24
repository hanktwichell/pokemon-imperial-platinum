#include "macros/scrcmd.inc"
#include "res/text/bank/solaceon_ruins_room_7.h"
#include "res/field/events/events_solaceon_ruins_room_7.h"


    ScriptEntry SolaceonRuinsRoom7_Inscription
    ScriptEntry SolaceonRuinsRoom7_OnTransition
    ScriptEntry SolaceonRuinsRoom7_OnLoad
    ScriptEntry SolaceonRuinsRoom7_LegendaryJirachi
    ScriptEntryEnd

SolaceonRuinsRoom7_OnTransition:
    Call SolaceonRuinsRoom7_SovereignSetJirachiVisibility
    End

@ Sovereign (E10, Renegade's Jirachi event): once the three wishes are granted (Eterna City's Pokémon Center, Solaceon
@ Town's north-east house, Pastoria City) and the sign read, Jirachi sleeps at the top of the room until it's caught.
@ A Jigglypuff's song wakes it (Renegade: Lv. 40).
SolaceonRuinsRoom7_SovereignSetJirachiVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfUnset FLAG_SOVEREIGN_JIRACHI_SIGN_CHANGED, SolaceonRuinsRoom7_SovereignSetJirachiVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_JIRACHI, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SolaceonRuinsRoom7_SovereignSetJirachiVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
SolaceonRuinsRoom7_SovereignSetJirachiVisibilityEnd:
    Return

SolaceonRuinsRoom7_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, SolaceonRuinsRoom7_RemoveLegendaryJirachi
    End

SolaceonRuinsRoom7_RemoveLegendaryJirachi:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_JIRACHI, SolaceonRuinsRoom7_RemoveLegendaryJirachiEnd
    RemoveObject LOCALID_LEGENDARY_JIRACHI
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
SolaceonRuinsRoom7_RemoveLegendaryJirachiEnd:
    Return

SolaceonRuinsRoom7_LegendaryJirachi:
    GoToIfSet FLAG_SOVEREIGN_JIRACHI_AWAKE, SolaceonRuinsRoom7_JirachiBattle
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    CheckPartyHasSpecies VAR_RESULT, SPECIES_JIGGLYPUFF
    GoToIfEq VAR_RESULT, FALSE, SolaceonRuinsRoom7_JirachiDeepSleep
    Message SolaceonRuinsRoom7_Text_SovereignAskJigglypuff
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, SolaceonRuinsRoom7_JirachiDontWake
    CloseMessage
    PlayCry SPECIES_JIGGLYPUFF
    Message SolaceonRuinsRoom7_Text_SovereignJigglypuffPwff
    WaitCry
    CloseMessage
    PlayFanfare SEQ_FUE_sseq
    WaitFanfare
    ApplyMovement LOCALID_LEGENDARY_JIRACHI, SolaceonRuinsRoom7_Movement_JirachiWakeUp
    WaitMovement
    Message SolaceonRuinsRoom7_Text_SovereignWokeUp
    WaitButton
    CloseMessage
    SetFlag FLAG_SOVEREIGN_JIRACHI_AWAKE
    ReleaseAll
SolaceonRuinsRoom7_JirachiBattle:
    SetVar VAR_0x8004, SPECIES_JIRACHI
    SetVar VAR_0x8005, 40
    Common_SovereignLegendaryEncounter
    End

SolaceonRuinsRoom7_JirachiDeepSleep:
    Message SolaceonRuinsRoom7_Text_SovereignDeepSleep
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonRuinsRoom7_JirachiDontWake:
    CloseMessage
    ReleaseAll
    End

SolaceonRuinsRoom7_Inscription:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    GoToIfSet FLAG_SOVEREIGN_JIRACHI_SIGN_CHANGED, SolaceonRuinsRoom7_JirachiSign
    MessageUnown SolaceonRuinsRoom7_Text_AllLivesTouchOtherLives
    WaitButton
    CloseMessage
    Message SolaceonRuinsRoom7_Text_SovereignThreeWishes
    WaitButton
    CloseMessage
    GoToIfUnset FLAG_SOVEREIGN_JIRACHI_WISH_ETERNA, SolaceonRuinsRoom7_InscriptionEnd
    GoToIfUnset FLAG_SOVEREIGN_JIRACHI_WISH_SOLACEON, SolaceonRuinsRoom7_InscriptionEnd
    GoToIfUnset FLAG_SOVEREIGN_JIRACHI_WISH_PASTORIA, SolaceonRuinsRoom7_InscriptionEnd
    WaitTime 10, VAR_RESULT
    FadeScreenOut FADE_SCREEN_SPEED_FAST, COLOR_WHITE
    WaitFadeScreen
    PlayCry SPECIES_JIRACHI
    WaitCry
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    AddObject LOCALID_LEGENDARY_JIRACHI
    FadeScreenIn FADE_SCREEN_SPEED_SLOW, COLOR_WHITE
    WaitFadeScreen
    WaitTime 10, VAR_RESULT
    Message SolaceonRuinsRoom7_Text_SovereignSignChanged
    WaitButton
    CloseMessage
    SetFlag FLAG_SOVEREIGN_JIRACHI_SIGN_CHANGED
SolaceonRuinsRoom7_InscriptionEnd:
    ReleaseAll
    End

SolaceonRuinsRoom7_JirachiSign:
    SovereignCheckSpeciesCaught SPECIES_JIRACHI, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SolaceonRuinsRoom7_JirachiSignBlank
    Message SolaceonRuinsRoom7_Text_SovereignBringBestVoice
    WaitButton
    CloseMessage
    ReleaseAll
    End

SolaceonRuinsRoom7_JirachiSignBlank:
    Message SolaceonRuinsRoom7_Text_SovereignSignBlank
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
SolaceonRuinsRoom7_Movement_JirachiWakeUp:
    EmoteExclamationMark
    EndMovement
