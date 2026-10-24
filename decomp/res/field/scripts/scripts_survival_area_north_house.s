#include "macros/scrcmd.inc"
#include "res/text/bank/survival_area_north_house.h"


    ScriptEntry SurvivalAreaNorthHouse_Psychic
    ScriptEntry SurvivalAreaNorthHouse_Psyduck
    ScriptEntry SurvivalAreaNorthHouse_Book
    ScriptEntryEnd

SurvivalAreaNorthHouse_Psychic:
    NPCMessage SurvivalAreaNorthHouse_Text_LookingForwardToVisitors
    End

// Sovereign (E10): as in Renegade, the move tutor moved to the Route 212 house; his Psyduck stayed.
SurvivalAreaNorthHouse_Psyduck:
    PokemonCryAndMessage SPECIES_PSYDUCK, SurvivalAreaNorthHouse_Text_PsyduckCry
    End

SurvivalAreaNorthHouse_Book:
    EventMessage SurvivalAreaNorthHouse_Text_ShardColorsEmphasize
    End

    .balign 4, 0
