#include "macros/scrcmd.inc"
#include "res/text/bank/veilstone_city_northeast_house.h"


    ScriptEntry VeilstoneCityNortheastHouse_PokefanM
    ScriptEntry VeilstoneCityNortheastHouse_PokefanF
    ScriptEntryEnd

// Sovereign (E10): as in Renegade, he gives the Dubious Disc. Porygon is a Poké Ball behind Jupiter in the Eterna
// Galactic Building instead.
VeilstoneCityNortheastHouse_PokefanM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_VEILSTONE_DUBIOUS_DISC, VeilstoneCityNortheastHouse_GalacticsBuildingBugsMe
    SetFlag FLAG_TALKED_TO_VEILSTONE_CITY_NORTHEAST_HOUSE_POKEFAN_M
    Message VeilstoneCityNortheastHouse_Text_FoundCreepyDisc
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, VeilstoneCityNortheastHouse_DontAcceptDisc
    Message VeilstoneCityNortheastHouse_Text_Excellent
    SetVar VAR_0x8004, ITEM_DUBIOUS_DISC
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_VEILSTONE_DUBIOUS_DISC
    CloseMessage
    ReleaseAll
    End

VeilstoneCityNortheastHouse_DontAcceptDisc:
    Message VeilstoneCityNortheastHouse_Text_MaybeSellIt
    GoTo VeilstoneCityNortheastHouse_PokefanMEnd
    End

VeilstoneCityNortheastHouse_GalacticsBuildingBugsMe:
    Message VeilstoneCityNortheastHouse_Text_GalacticsBuildingBugsMe
    GoTo VeilstoneCityNortheastHouse_PokefanMEnd
    End

VeilstoneCityNortheastHouse_PokefanMEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

VeilstoneCityNortheastHouse_PokefanF:
    NPCMessage VeilstoneCityNortheastHouse_Text_IDontUnderstandTheirIdea
    End

    .balign 4, 0
