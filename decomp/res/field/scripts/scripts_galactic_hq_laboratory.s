#include "macros/scrcmd.inc"
#include "res/text/bank/galactic_hq_laboratory.h"
#include "res/field/events/events_galactic_hq_laboratory.h"


    ScriptEntry GalacticHQLaboratory_ScientistM
    ScriptEntry GalacticHQLaboratory_ScientistF
    ScriptEntry GalacticHQLaboratory_Machine
    ScriptEntry GalacticHQLaboratory_OnTransition
    ScriptEntry GalacticHQLaboratory_OnLoad
    ScriptEntry GalacticHQLaboratory_LegendaryGenesect
    ScriptEntryEnd

GalacticHQLaboratory_ScientistM:
    GoToIfGe VAR_SOVEREIGN_CHRONICLE, 1, GalacticHQLaboratory_SovereignScientist
    NPCMessage GalacticHQLaboratory_Text_ExperimentWentTooFar
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): once the Unova Chronicle is open, the scientist confesses
@ that the lab revived and remade a fossil Pokémon, Genesect, which broke out into the back room
@ (FLAG_SOVEREIGN_GENESECT_FREED). It stays there until it's caught.
GalacticHQLaboratory_SovereignScientist:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    SovereignCheckSpeciesCaught SPECIES_GENESECT, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, GalacticHQLaboratory_SovereignScientistGenesectCaught
    GoToIfSet FLAG_SOVEREIGN_GENESECT_FREED, GalacticHQLaboratory_SovereignScientistStopIt
    Message GalacticHQLaboratory_Text_SovereignScientistConfess
    SetFlag FLAG_SOVEREIGN_GENESECT_FREED
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    AddObject LOCALID_LEGENDARY_GENESECT
    GoTo GalacticHQLaboratory_SovereignScientistEnd

GalacticHQLaboratory_SovereignScientistStopIt:
    Message GalacticHQLaboratory_Text_SovereignScientistStopIt
    GoTo GalacticHQLaboratory_SovereignScientistEnd

GalacticHQLaboratory_SovereignScientistGenesectCaught:
    Message GalacticHQLaboratory_Text_SovereignScientistGenesectCaught
GalacticHQLaboratory_SovereignScientistEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

GalacticHQLaboratory_ScientistF:
    NPCMessage GalacticHQLaboratory_Text_IFeelTooSickened
    End

GalacticHQLaboratory_Machine:
    EventMessage GalacticHQLaboratory_Text_SomethingInGreenFluid
    End

GalacticHQLaboratory_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfUnset FLAG_SOVEREIGN_GENESECT_FREED, GalacticHQLaboratory_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_GENESECT, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, GalacticHQLaboratory_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
GalacticHQLaboratory_OnTransitionEnd:
    End

GalacticHQLaboratory_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, GalacticHQLaboratory_RemoveLegendaryGenesect
    End

GalacticHQLaboratory_RemoveLegendaryGenesect:
    RemoveObject LOCALID_LEGENDARY_GENESECT
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

GalacticHQLaboratory_LegendaryGenesect:
    SetVar VAR_0x8004, SPECIES_GENESECT
    SetVar VAR_0x8005, 60
    Common_SovereignLegendaryEncounter
    End

    .balign 4, 0
