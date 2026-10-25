#include "macros/scrcmd.inc"
#include "res/text/bank/foreign_building.h"
#include "res/field/events/events_foreign_building.h"


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
    ScriptEntry ForeignBuilding_SovereignElder
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

@ Sovereign (E10, Renegade): the elder of the Original One's worshippers. After the Hall of Fame she asks the Champion
@ to beat the sixteen Type Masters (E10 part 20) for their Plates. With all sixteen in the bag she gives the Azure Flute
@ for Spear Pillar (Arceus). Renegade then asks for a Pokedex worthy of the National diploma too; the owner dropped that
@ task (2026-10-24), since Sovereign's National Dex is over 1,000 species. The flute is a key item, so having it marks
@ the event done.
ForeignBuilding_SovereignElder:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CheckItem ITEM_AZURE_FLUTE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, ForeignBuilding_SovereignElderSpearPillar
    GoToIfUnset FLAG_GAME_COMPLETED, ForeignBuilding_SovereignElderGreeting
    CheckItem ITEM_FLAME_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_SPLASH_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_ZAP_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_MEADOW_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_ICICLE_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_FIST_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_TOXIC_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_EARTH_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_SKY_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_MIND_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_INSECT_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_STONE_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_SPOOKY_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_DRACO_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_DREAD_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    CheckItem ITEM_IRON_PLATE, 1, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, ForeignBuilding_SovereignElderTask
    ApplyMovement LOCALID_SOVEREIGN_ELDER, ForeignBuilding_SovereignElderMovement_Exclamation
    WaitMovement
    Message ForeignBuilding_Text_SovereignElderAllPlates
    SetVar VAR_0x8004, ITEM_AZURE_FLUTE
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
ForeignBuilding_SovereignElderSpearPillar:
    Message ForeignBuilding_Text_SovereignElderSpearPillar
    GoTo ForeignBuilding_SovereignElderEnd

ForeignBuilding_SovereignElderGreeting:
    Message ForeignBuilding_Text_SovereignElderGreeting
    GoTo ForeignBuilding_SovereignElderEnd

ForeignBuilding_SovereignElderTask:
    Message ForeignBuilding_Text_SovereignElderChampion
    Message ForeignBuilding_Text_SovereignElderTypeMasters
ForeignBuilding_SovereignElderEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
ForeignBuilding_SovereignElderMovement_Exclamation:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
