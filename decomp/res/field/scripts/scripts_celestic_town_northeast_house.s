#include "macros/scrcmd.inc"
#include "res/text/bank/celestic_town_northeast_house.h"


    ScriptEntry CelesticTownNortheastHouse_PokefanM
    ScriptEntry CelesticTownNortheastHouse_NinjaBoy
    ScriptEntryEnd

@ Sovereign (the Chronicles, the Masked Ogre): with an Ogerpon at the front of the party, he gives the Wellspring,
@ Hearthflame and Cornerstone Masks once (FLAG_SOVEREIGN_RECEIVED_OGERPON_MASKS).
CelesticTownNortheastHouse_PokefanM:
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_OGERPON_MASKS, CelesticTownNortheastHouse_PokefanMPlain
    GetPartyMonSpecies 0, VAR_RESULT
    GoToIfNe VAR_RESULT, SPECIES_OGERPON, CelesticTownNortheastHouse_PokefanMPlain
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message CelesticTownNortheastHouse_Text_SovereignOgerponMasks
    SetVar VAR_0x8004, ITEM_WELLSPRING_MASK
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_HEARTHFLAME_MASK
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_CORNERSTONE_MASK
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_OGERPON_MASKS
    Message CelesticTownNortheastHouse_Text_SovereignOgerponMasksAfter
    WaitButton
    CloseMessage
    ReleaseAll
    End

CelesticTownNortheastHouse_PokefanMPlain:
    NPCMessage CelesticTownNortheastHouse_Text_MtCoronetCenter
    End

CelesticTownNortheastHouse_NinjaBoy:
    NPCMessage CelesticTownNortheastHouse_Text_SeeAllOfSinnoh
    End
