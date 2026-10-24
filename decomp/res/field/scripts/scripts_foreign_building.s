#include "macros/scrcmd.inc"
#include "res/text/bank/foreign_building.h"


    ScriptEntry ForeignBuilding_RuinManiac
    ScriptEntry ForeignBuilding_OldMan
    ScriptEntry ForeignBuilding_NinjaBoy
    ScriptEntry ForeignBuilding_OldWoman
    ScriptEntry ForeignBuilding_AceTrainerF
    ScriptEntry ForeignBuilding_PokefanF
    ScriptEntry ForeignBuilding_ExpertM
    ScriptEntry ForeignBuilding_Psychic
    ScriptEntry ForeignBuilding_Lady
    ScriptEntry ForeignBuilding_SovereignExpertF
    ScriptEntryEnd

ForeignBuilding_RuinManiac:
    NPCMessage ForeignBuilding_Text_ThereDoISeeMyFather
    End

ForeignBuilding_OldMan:
    NPCMessage ForeignBuilding_Text_CraftingFatiguesOnesSpirit
    End

ForeignBuilding_NinjaBoy:
    NPCMessage ForeignBuilding_Text_ItMakesEveryoneComeTogether
    End

ForeignBuilding_OldWoman:
    NPCMessage ForeignBuilding_Text_ThatPeopleAreLonelyIsNatural
    End

ForeignBuilding_AceTrainerF:
    NPCMessage ForeignBuilding_Text_WordsThatNotEveryoneCanDescribe
    End

ForeignBuilding_PokefanF:
    NPCMessage ForeignBuilding_Text_OnlyNaturalWeAreDifferent
    End

ForeignBuilding_ExpertM:
    NPCMessage ForeignBuilding_Text_TheStrongMustShowRestraint
    End

ForeignBuilding_Psychic:
    NPCMessage ForeignBuilding_Text_WeCannotReadMinds
    End

ForeignBuilding_Lady:
    NPCMessage ForeignBuilding_Text_BalanceIsWhatsNeeded
    End

    .balign 4, 0

// Sovereign (E10): as in Renegade Platinum, an old woman gives TM44 (Rest).
ForeignBuilding_SovereignExpertF:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_FOREIGN_BUILDING_TM44, ForeignBuilding_SovereignExpertFAgain
    Message ForeignBuilding_Text_SovereignExpertFGives
    SetVar VAR_0x8004, ITEM_TM44
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_FOREIGN_BUILDING_TM44
    Message ForeignBuilding_Text_SovereignExpertFExplains
    WaitButton
    CloseMessage
    ReleaseAll
    End

ForeignBuilding_SovereignExpertFAgain:
    Message ForeignBuilding_Text_SovereignExpertFAgain
    WaitButton
    CloseMessage
    ReleaseAll
    End
