#include "macros/scrcmd.inc"
#include "res/text/bank/oreburgh_gate_b1f.h"
#include "res/field/events/events_oreburgh_gate_b1f.h"


    ScriptEntry OreburghGateB1F_CyclistF
    ScriptEntry OreburghGateB1F_OnTransition
    ScriptEntry OreburghGateB1F_OnLoad
    ScriptEntry OreburghGateB1F_LegendaryMewtwo
    ScriptEntryEnd

OreburghGateB1F_CyclistF:
    NPCMessage OreburghGateB1F_Text_DoYouSeeThoseBumps
    End

OreburghGateB1F_OnTransition:
    Call OreburghGateB1F_SovereignSetMewtwoVisibility
    End

OreburghGateB1F_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, OreburghGateB1F_RemoveLegendaryMewtwo
    End

@ Sovereign (E10, Renegade's legendary events): Mewtwo in the north-west pocket, beside the TM01 ball (Renegade's
@ portal stands on the ball's spot; Sovereign keeps the Strength boulder, so the ball stays), after the Hall of Fame,
@ until it's caught (Renegade: Lv. 70).
OreburghGateB1F_SovereignSetMewtwoVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfUnset FLAG_GAME_COMPLETED, OreburghGateB1F_SovereignSetMewtwoVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_MEWTWO, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, OreburghGateB1F_SovereignSetMewtwoVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
OreburghGateB1F_SovereignSetMewtwoVisibilityEnd:
    Return

OreburghGateB1F_RemoveLegendaryMewtwo:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_MEWTWO, OreburghGateB1F_RemoveLegendaryMewtwoEnd
    RemoveObject LOCALID_LEGENDARY_MEWTWO
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
OreburghGateB1F_RemoveLegendaryMewtwoEnd:
    Return

OreburghGateB1F_LegendaryMewtwo:
    SetVar VAR_0x8004, SPECIES_MEWTWO
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

    .balign 4, 0
