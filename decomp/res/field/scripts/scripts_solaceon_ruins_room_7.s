#include "macros/scrcmd.inc"
#include "res/text/bank/solaceon_ruins_room_7.h"
#include "res/field/events/events_solaceon_ruins_room_7.h"


    ScriptEntry SolaceonRuinsRoom7_Inscription
    ScriptEntry SolaceonRuinsRoom7_OnTransition
    ScriptEntry SolaceonRuinsRoom7_OnLoad
    ScriptEntry SolaceonRuinsRoom7_LegendaryHoopa
    ScriptEntryEnd

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Hoopa plays in the ruins' innermost room while the player
@ carries the Prison Bottle, which the Archivist gives, until it's caught.
SolaceonRuinsRoom7_OnTransition:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    CheckItem ITEM_PRISON_BOTTLE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, SolaceonRuinsRoom7_OnTransitionEnd
    SovereignCheckSpeciesCaught SPECIES_HOOPA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, SolaceonRuinsRoom7_OnTransitionEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
SolaceonRuinsRoom7_OnTransitionEnd:
    End

SolaceonRuinsRoom7_OnLoad:
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, SolaceonRuinsRoom7_RemoveLegendaryHoopa
    End

SolaceonRuinsRoom7_RemoveLegendaryHoopa:
    RemoveObject LOCALID_LEGENDARY_HOOPA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

SolaceonRuinsRoom7_LegendaryHoopa:
    SetVar VAR_0x8004, SPECIES_HOOPA
    SetVar VAR_0x8005, 55
    Common_SovereignLegendaryEncounter
    End

SolaceonRuinsRoom7_Inscription:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    MessageUnown SolaceonRuinsRoom7_Text_AllLivesTouchOtherLives
    WaitButton
    CloseMessage
    ReleaseAll
    End
